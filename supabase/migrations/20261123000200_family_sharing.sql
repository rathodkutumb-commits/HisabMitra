-- Family hisab sharing (app 1.3.0, phase 3).
--
-- * family_invitations: single-use hashed codes (like group invitations),
--   optionally for a named person whose account takes over that person and
--   their earlier entries.
-- * accept_invitation: ONE accept for group and Family hisab codes, so the
--   invitation link, the website and the app's join flow stay the same.
--   accept_group_invitation is kept unchanged for app 1.2.x.
-- * set_family_member_role: the owner makes people admins or members again.
-- * A removed person can read the feed event of their own removal, so their
--   phone forgets the Family hisab.
-- * prepare_account_deletion also hands Family hisabs over.

-- ----------------------------------------------------------- invitations

create table public.family_invitations (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.family_hisabs (id) on delete cascade,
  -- SHA-256 of the code; the plain code is shown once to the inviter.
  code_hash text not null unique,
  created_by uuid not null references auth.users (id) on delete cascade,
  -- Optional person (without an account) the invitee will take over.
  member_id uuid references public.family_members (id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'cancelled', 'expired')),
  expires_at timestamptz not null,
  accepted_by uuid references auth.users (id) on delete set null,
  accepted_at timestamptz,
  created_at timestamptz not null default now()
);
create index family_invitations_family_idx on public.family_invitations (family_id);
create unique index family_invitations_one_pending_per_member
  on public.family_invitations (member_id)
  where status = 'pending' and member_id is not null;

alter table public.family_invitations enable row level security;
create policy family_invitations_admin_select on public.family_invitations
  for select to authenticated using (public.is_family_admin(family_id));
grant select on public.family_invitations to authenticated;

create or replace function public.create_family_invitation(
  p_family_id uuid, p_member_id uuid default null, p_ttl_hours integer default 72
) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  v_bytes bytea := extensions.gen_random_bytes(10);
  v_code text := '';
  v_id uuid;
  v_expires timestamptz := now() + make_interval(hours => least(greatest(p_ttl_hours, 1), 720));
  i integer;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if not public.is_family_member(p_family_id) or not public.is_family_admin(p_family_id) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_member_id is not null then
    if not exists (select 1 from public.family_members where id = p_member_id and family_id = p_family_id
                   and user_id is null and status = 'active' and deleted_at is null) then
      raise exception 'invalid_member' using errcode = '22023';
    end if;
    update public.family_invitations set status = 'expired'
      where member_id = p_member_id and status = 'pending' and expires_at <= now();
    if exists (select 1 from public.family_invitations where member_id = p_member_id and status = 'pending') then
      raise exception 'invitation_pending' using errcode = '23505';
    end if;
  end if;
  for i in 0..9 loop
    v_code := v_code || substr(v_alphabet, (get_byte(v_bytes, i) % length(v_alphabet)) + 1, 1);
  end loop;
  insert into public.family_invitations (family_id, code_hash, created_by, member_id, expires_at)
  values (p_family_id, encode(extensions.digest(v_code, 'sha256'), 'hex'), auth.uid(), p_member_id, v_expires)
  returning id into v_id;
  return jsonb_build_object('invitation_id', v_id, 'code', v_code, 'expires_at', v_expires);
end;
$$;

create or replace function public.cancel_family_invitation(p_invitation_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_family uuid;
begin
  select family_id into v_family from public.family_invitations where id = p_invitation_id;
  if v_family is null or not public.is_family_admin(v_family) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  update public.family_invitations set status = 'cancelled'
    where id = p_invitation_id and status = 'pending';
end;
$$;

-- One accept for both kinds of code.
create or replace function public.accept_invitation(p_code text, p_display_name text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_hash text := encode(extensions.digest(upper(trim(coalesce(p_code, ''))), 'sha256'), 'hex');
  v_inv public.family_invitations%rowtype;
  v_member uuid;
  v_rev bigint;
  v_name text := left(coalesce(nullif(trim(p_display_name), ''), 'Member'), 80);
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if exists (select 1 from public.group_invitations where code_hash = v_hash) then
    return public.accept_group_invitation(p_code, p_display_name) || jsonb_build_object('kind', 'group');
  end if;

  select * into v_inv from public.family_invitations where code_hash = v_hash for update;
  if not found or v_inv.status in ('cancelled', 'accepted') then
    raise exception 'invalid_code' using errcode = '22023';
  end if;
  if v_inv.status = 'expired' or v_inv.expires_at <= now() then
    raise exception 'expired' using errcode = '22023';
  end if;
  if exists (select 1 from public.family_hisabs where id = v_inv.family_id and deleted_at is not null) then
    raise exception 'invalid_code' using errcode = '22023';
  end if;
  if exists (select 1 from public.family_members where family_id = v_inv.family_id
             and user_id = v_uid and status = 'active' and deleted_at is null) then
    raise exception 'already_member' using errcode = '23505';
  end if;

  if v_inv.member_id is not null then
    update public.family_members set user_id = v_uid, revision = revision + 1, updated_at = now()
    where id = v_inv.member_id and user_id is null and status = 'active' and deleted_at is null
    returning id, revision into v_member, v_rev;
    if v_member is null then
      raise exception 'invalid_code' using errcode = '22023';
    end if;
  else
    v_member := gen_random_uuid();
    insert into public.family_members (id, family_id, user_id, name, role, status, sort_order)
    values (v_member, v_inv.family_id, v_uid, v_name, 'member', 'active',
            coalesce((select max(sort_order) + 1 from public.family_members where family_id = v_inv.family_id), 1))
    returning revision into v_rev;
  end if;
  update public.family_invitations set status = 'accepted', accepted_by = v_uid, accepted_at = now()
    where id = v_inv.id;
  perform public._family_emit(v_inv.family_id, 'member', v_member, 'upsert', v_rev,
                              public._family_member_json(v_member), null);
  return jsonb_build_object('kind', 'family', 'family_id', v_inv.family_id, 'member_id', v_member);
end;
$$;

-- ------------------------------------------------------------------- roles

-- The owner makes a person who has the app an admin, or a member again.
create or replace function public.set_family_member_role(p_member_id uuid, p_role text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_m public.family_members%rowtype;
  v_rev bigint;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  select * into v_m from public.family_members where id = p_member_id;
  if not found or not exists (select 1 from public.family_hisabs
                              where id = v_m.family_id and owner_id = auth.uid() and deleted_at is null) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if v_m.role = 'owner' or v_m.user_id is null or v_m.status <> 'active' or v_m.deleted_at is not null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_role not in ('admin', 'member') then
    raise exception 'invalid_data' using errcode = '22023';
  end if;
  update public.family_members set role = p_role, revision = revision + 1, updated_at = now()
    where id = p_member_id returning revision into v_rev;
  perform public._family_emit(v_m.family_id, 'member', p_member_id, 'upsert', v_rev,
                              public._family_member_json(p_member_id), null);
  return jsonb_build_object('revision', v_rev);
end;
$$;

-- ----------------------------------------------------- a removed person's feed

-- People read their Family hisabs' feed; a removed person still reads the
-- events of their own person row (their removal), so their phone forgets it.
create or replace function public.can_read_family_event(p_family_id uuid, p_entity_type text, p_entity_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.is_family_reader(p_family_id)
      or (p_entity_type = 'member' and exists (
            select 1 from public.family_members m
            where m.id = p_entity_id and m.family_id = p_family_id and m.user_id = auth.uid()));
$$;

drop policy family_events_member_select on public.family_sync_events;
create policy family_events_member_select on public.family_sync_events
  for select to authenticated using (public.can_read_family_event(family_id, entity_type, entity_id));

-- -------------------------------------------------------- account deletion

-- Called by the `delete-account` Edge Function with the user's JWT before
-- the auth user is removed. Groups as before; Family hisabs pass to another
-- person who has the app (admins first), or are deleted when nobody is left.
create or replace function public.prepare_account_deletion()
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_group record;
  v_family record;
  v_person record;
  v_next uuid;
  v_next_member uuid;
  v_rev bigint;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  for v_group in select id from public.groups where owner_id = v_uid and deleted_at is null loop
    select m.user_id into v_next from public.group_members m
      where m.group_id = v_group.id and m.user_id is not null and m.user_id <> v_uid
        and m.status = 'active' and m.deleted_at is null
      order by (m.role = 'admin') desc, m.joined_at
      limit 1;
    if v_next is null then
      update public.groups set deleted_at = now(), revision = revision + 1, updated_at = now()
        where id = v_group.id;
    else
      update public.groups set owner_id = v_next, revision = revision + 1, updated_at = now()
        where id = v_group.id;
      update public.group_members set role = 'owner', revision = revision + 1, updated_at = now()
        where group_id = v_group.id and user_id = v_next;
    end if;
  end loop;
  update public.group_members set user_id = null, role = 'member', revision = revision + 1, updated_at = now()
    where user_id = v_uid;
  update public.group_invitations set status = 'cancelled' where created_by = v_uid and status = 'pending';

  for v_family in select id from public.family_hisabs where owner_id = v_uid and deleted_at is null loop
    v_next_member := null;
    select m.id into v_next_member from public.family_members m
      where m.family_id = v_family.id and m.user_id is not null and m.user_id <> v_uid
        and m.status = 'active' and m.deleted_at is null
      order by (m.role = 'admin') desc, m.created_at
      limit 1;
    if v_next_member is null then
      update public.family_hisabs set deleted_at = now(), revision = revision + 1, updated_at = now()
        where id = v_family.id returning revision into v_rev;
      perform public._family_emit(v_family.id, 'family', v_family.id, 'delete', v_rev,
                                  public._family_json(v_family.id), null);
    else
      update public.family_hisabs
        set owner_id = (select user_id from public.family_members where id = v_next_member),
            revision = revision + 1, updated_at = now()
        where id = v_family.id returning revision into v_rev;
      perform public._family_emit(v_family.id, 'family', v_family.id, 'upsert', v_rev,
                                  public._family_json(v_family.id), null);
      update public.family_members set role = 'owner', revision = revision + 1, updated_at = now()
        where id = v_next_member returning revision into v_rev;
      perform public._family_emit(v_family.id, 'member', v_next_member, 'upsert', v_rev,
                                  public._family_member_json(v_next_member), null);
    end if;
  end loop;
  -- The user's people stay (with their entries) as plain people.
  for v_person in select id, family_id from public.family_members where user_id = v_uid loop
    update public.family_members set user_id = null, role = 'member', revision = revision + 1, updated_at = now()
      where id = v_person.id returning revision into v_rev;
    perform public._family_emit(v_person.family_id, 'member', v_person.id, 'upsert', v_rev,
                                public._family_member_json(v_person.id), null);
  end loop;
  update public.family_invitations set status = 'cancelled' where created_by = v_uid and status = 'pending';

  delete from public.user_devices where user_id = v_uid;
  delete from public.user_profiles where id = v_uid;
end;
$$;

-- ------------------------------------------------------------------ access

revoke execute on function
  public.create_family_invitation(uuid, uuid, integer), public.cancel_family_invitation(uuid),
  public.accept_invitation(text, text), public.set_family_member_role(uuid, text),
  public.can_read_family_event(uuid, text, uuid), public.prepare_account_deletion()
  from public, anon, authenticated;
grant execute on function
  public.create_family_invitation(uuid, uuid, integer), public.cancel_family_invitation(uuid),
  public.accept_invitation(text, text), public.set_family_member_role(uuid, text),
  public.can_read_family_event(uuid, text, uuid), public.prepare_account_deletion()
  to authenticated;
