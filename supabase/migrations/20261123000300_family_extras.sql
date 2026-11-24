-- Family hisab extras (app 1.3.0, phase 4).
--
-- * Bills on money out: files live in the private `family-attachments`
--   bucket at <family_id>/<entry_id>/<file> (bucket and policies in
--   20261123000400_family_attachments_storage.sql). A member registers an
--   uploaded file here; the row reaches the other phones on the family feed.
--   Any member can delete a bill; it disappears for everyone.
-- * A personal reminder can be linked to a Family hisab (personal_reminders
--   .family_id). apply_personal_op copies columns by name, so it needs no
--   change; there is no foreign key — it only links the user's own reminder.

-- ------------------------------------------------------------------ bills

create table public.family_attachments (
  id uuid primary key,
  family_id uuid not null references public.family_hisabs (id) on delete cascade,
  entry_id uuid not null references public.family_entries (id) on delete cascade,
  storage_path text not null unique,
  mime_type text not null check (mime_type in ('image/jpeg', 'image/png', 'image/webp', 'image/heic',
                                               'application/pdf')),
  size_bytes integer not null check (size_bytes between 1 and 10485760),
  sha256 text not null check (char_length(sha256) = 64),
  uploaded_by uuid references auth.users (id) on delete set null,
  deleted_at timestamptz,
  created_at timestamptz not null default now()
);
create index family_attachments_entry_idx on public.family_attachments (entry_id);

alter table public.family_attachments enable row level security;
create policy family_attachments_member_select on public.family_attachments
  for select to authenticated using (public.is_family_member(family_id));
grant select on public.family_attachments to authenticated;

-- The feed carries bills too.
alter table public.family_sync_events drop constraint family_sync_events_entity_type_check;
alter table public.family_sync_events add constraint family_sync_events_entity_type_check
  check (entity_type in ('family', 'member', 'entry', 'attachment'));

create or replace function public._family_attachment_json(p_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', a.id, 'family_id', a.family_id, 'entry_id', a.entry_id, 'storage_path', a.storage_path,
    'mime_type', a.mime_type, 'size_bytes', a.size_bytes, 'sha256', a.sha256, 'deleted_at', a.deleted_at)
  from public.family_attachments a where a.id = p_id;
$$;

-- Registers a bill after its file was uploaded:
--   {id, family_id, entry_id, storage_path, mime_type, size_bytes, sha256}.
create or replace function public.register_family_attachment(p jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_family uuid := (p ->> 'family_id')::uuid;
  v_entry uuid := (p ->> 'entry_id')::uuid;
  v_id uuid := (p ->> 'id')::uuid;
  v_path text := p ->> 'storage_path';
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if not public.is_family_member(v_family) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if exists (select 1 from public.family_attachments where id = v_id) then
    return jsonb_build_object('status', 'applied');
  end if;
  if not exists (select 1 from public.family_entries
                 where id = v_entry and family_id = v_family and deleted_at is null) then
    raise exception 'invalid_entry' using errcode = '22023';
  end if;
  if v_path is distinct from format('%s/%s/%s', v_family, v_entry, split_part(v_path, '/', 3))
     or split_part(v_path, '/', 3) = ''
     or not exists (select 1 from storage.objects where bucket_id = 'family-attachments' and name = v_path) then
    raise exception 'invalid_path' using errcode = '22023';
  end if;
  insert into public.family_attachments (id, family_id, entry_id, storage_path, mime_type, size_bytes, sha256,
                                         uploaded_by)
  values (v_id, v_family, v_entry, v_path, p ->> 'mime_type', (p ->> 'size_bytes')::integer, p ->> 'sha256',
          auth.uid());
  perform public._family_emit(v_family, 'attachment', v_id, 'upsert', 1, public._family_attachment_json(v_id), null);
  return jsonb_build_object('status', 'applied');
end;
$$;

create or replace function public.delete_family_attachment(p_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_family uuid;
begin
  select family_id into v_family from public.family_attachments where id = p_id and deleted_at is null;
  if v_family is null then
    if exists (select 1 from public.family_attachments a where a.id = p_id
               and not public.is_family_member(a.family_id)) then
      raise exception 'forbidden' using errcode = '42501';
    end if;
    return; -- already deleted
  end if;
  if not public.is_family_member(v_family) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  update public.family_attachments set deleted_at = now() where id = p_id;
  perform public._family_emit(v_family, 'attachment', p_id, 'delete', 2, public._family_attachment_json(p_id), null);
end;
$$;

-- The snapshot of a Family hisab now carries its live bills.
create or replace function public.get_family_snapshot(p_family_id uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_family_member(p_family_id) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'family', public._family_json(p_family_id),
    'members', coalesce((select jsonb_agg(public._family_member_json(id) order by sort_order)
                         from public.family_members where family_id = p_family_id), '[]'::jsonb),
    'entries', coalesce((select jsonb_agg(public._family_entry_json(id)) from public.family_entries
                         where family_id = p_family_id and deleted_at is null), '[]'::jsonb),
    'attachments', coalesce((select jsonb_agg(public._family_attachment_json(a.id))
                             from public.family_attachments a
                             join public.family_entries e on e.id = a.entry_id and e.deleted_at is null
                             where a.family_id = p_family_id and a.deleted_at is null), '[]'::jsonb),
    'max_seq', coalesce((select max(seq) from public.family_sync_events where family_id = p_family_id), 0)
  );
end;
$$;

-- --------------------------------------------------------- reminder link

alter table public.personal_reminders add column family_id uuid;

-- ------------------------------------------------------------------ access

revoke execute on function
  public._family_attachment_json(uuid), public.register_family_attachment(jsonb),
  public.delete_family_attachment(uuid), public.get_family_snapshot(uuid)
  from public, anon, authenticated;
grant execute on function
  public.register_family_attachment(jsonb), public.delete_family_attachment(uuid),
  public.get_family_snapshot(uuid)
  to authenticated;
