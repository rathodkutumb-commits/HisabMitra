-- Private storage for attachments a member *explicitly* shares with a group.
-- Personal bills are never uploaded. Object path: <group_id>/<expense_id>/<attachment_id>.<ext>
-- (Requires the Supabase Storage schema, so it is skipped by the local
-- PostgreSQL test harness.)

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('group-attachments', 'group-attachments', false, 10485760,
        array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'])
on conflict (id) do nothing;

create policy "group attachments: members can read"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'group-attachments'
    and public.is_group_member(((storage.foldername(name))[1])::uuid)
  );

create policy "group attachments: members can upload"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'group-attachments'
    and public.is_group_member(((storage.foldername(name))[1])::uuid)
  );
-- No update/delete policies: shared files are immutable for clients.

-- Registers metadata after the file was uploaded.
create or replace function public.register_group_attachment(p jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_group uuid := (p ->> 'group_id')::uuid;
  v_expense uuid := (p ->> 'expense_id')::uuid;
  v_id uuid := (p ->> 'id')::uuid;
  v_path text := p ->> 'storage_path';
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if not public.is_group_member(v_group) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not exists (select 1 from public.group_expenses where id = v_expense and group_id = v_group and deleted_at is null) then
    raise exception 'invalid_expense' using errcode = '22023';
  end if;
  if v_path is distinct from format('%s/%s/%s', v_group, v_expense, split_part(v_path, '/', 3))
     or not exists (select 1 from storage.objects where bucket_id = 'group-attachments' and name = v_path) then
    raise exception 'invalid_path' using errcode = '22023';
  end if;
  insert into public.group_attachments (id, group_id, expense_id, storage_path, mime_type, size_bytes, sha256, uploaded_by)
  values (v_id, v_group, v_expense, v_path, p ->> 'mime_type', (p ->> 'size_bytes')::int, p ->> 'sha256', auth.uid())
  on conflict (id) do nothing;
  perform public._emit(v_group, 'attachment', v_id, 'upsert', 1, jsonb_build_object(
    'id', v_id, 'group_id', v_group, 'expense_id', v_expense, 'storage_path', v_path,
    'mime_type', p ->> 'mime_type', 'size_bytes', (p ->> 'size_bytes')::int, 'sha256', p ->> 'sha256'), null);
  return jsonb_build_object('status', 'applied');
end;
$$;

revoke execute on function public.register_group_attachment(jsonb) from public, anon;
grant execute on function public.register_group_attachment(jsonb) to authenticated;
