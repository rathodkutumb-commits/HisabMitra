-- Family hisab (app 1.3.0): a shared home purse. Members record money in
-- (salary, extra income, contribution) and money out (expenses); nothing is
-- split. Each month's opening, money in/out and closing are calculated on the
-- phone from the entries, so no balance is stored here.
--
-- Access works like groups: only active members read (RLS), and every write
-- goes through apply_family_op (membership, admin rights, revision checks,
-- idempotency via processed_ops). Each change is appended to
-- family_sync_events, the feed phones pull from and listen to (Realtime).
-- People can be added by name and number without an account (user_id null);
-- removing a person keeps their entries.

-- ------------------------------------------------------------------ tables

create table public.family_hisabs (
  id uuid primary key,
  name text not null check (char_length(name) between 1 and 80),
  opening_balance_paise bigint not null default 0,
  owner_id uuid references auth.users (id) on delete set null,
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.family_members (
  id uuid primary key,
  family_id uuid not null references public.family_hisabs (id) on delete cascade,
  -- Set only by the server (creation, or joining from an invitation).
  user_id uuid references auth.users (id) on delete set null,
  name text not null check (char_length(name) between 1 and 80),
  phone text check (char_length(phone) <= 20),
  role text not null default 'member' check (role in ('owner', 'admin', 'member')),
  status text not null default 'active' check (status in ('active', 'removed')),
  sort_order integer not null default 0,
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index family_members_family_idx on public.family_members (family_id);
create index family_members_user_idx on public.family_members (user_id);

create table public.family_entries (
  id uuid primary key,
  family_id uuid not null references public.family_hisabs (id) on delete cascade,
  member_id uuid not null references public.family_members (id),
  kind text not null check (kind in ('salary', 'extra_income', 'contribution', 'expense')),
  amount_paise bigint not null check (amount_paise > 0),
  entry_date date not null,
  category_id text check (char_length(category_id) between 1 and 60),
  category_name text check (char_length(category_name) between 1 and 60),
  category_name_gu text check (char_length(category_name_gu) between 1 and 60),
  category_icon text check (char_length(category_icon) <= 40),
  category_color bigint,
  note text check (char_length(note) <= 200),
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- Money out always has a category; money in never does.
  check ((kind = 'expense') = (category_id is not null and category_name is not null))
);
create index family_entries_family_date_idx on public.family_entries (family_id, entry_date);

-- Append-only change feed (cursor = seq).
create table public.family_sync_events (
  seq bigserial primary key,
  family_id uuid not null references public.family_hisabs (id) on delete cascade,
  entity_type text not null check (entity_type in ('family', 'member', 'entry')),
  entity_id uuid not null,
  op_type text not null check (op_type in ('upsert', 'delete')),
  revision bigint not null,
  payload jsonb not null,
  op_id uuid,
  actor_id uuid,
  created_at timestamptz not null default now()
);
create index family_sync_events_family_seq_idx on public.family_sync_events (family_id, seq);

-- ---------------------------------------------------- authorisation helpers

create or replace function public.is_family_member(p_family_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.family_members m
    join public.family_hisabs f on f.id = m.family_id
    where m.family_id = p_family_id and m.user_id = auth.uid()
      and m.status = 'active' and m.deleted_at is null and f.deleted_at is null
  );
$$;

-- The change feed stays readable for a Family hisab's people after it is
-- deleted, so their other phones learn about the delete.
create or replace function public.is_family_reader(p_family_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.family_members m
    where m.family_id = p_family_id and m.user_id = auth.uid()
      and m.status = 'active' and m.deleted_at is null
  );
$$;

create or replace function public.is_family_admin(p_family_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.family_members m
    where m.family_id = p_family_id and m.user_id = auth.uid()
      and m.status = 'active' and m.deleted_at is null and m.role in ('owner', 'admin')
  );
$$;

-- ---------------------------------------------------------------------- RLS

alter table public.family_hisabs enable row level security;
alter table public.family_members enable row level security;
alter table public.family_entries enable row level security;
alter table public.family_sync_events enable row level security;

create policy family_member_select on public.family_hisabs
  for select to authenticated using (public.is_family_member(id));
create policy family_members_member_select on public.family_members
  for select to authenticated using (public.is_family_member(family_id));
create policy family_entries_member_select on public.family_entries
  for select to authenticated using (public.is_family_member(family_id));
create policy family_events_member_select on public.family_sync_events
  for select to authenticated using (public.is_family_reader(family_id));

-- -------------------------------------------------------------- row shapes

create or replace function public._family_json(p_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', f.id, 'name', f.name, 'opening_balance_paise', f.opening_balance_paise,
    'owner_id', f.owner_id, 'revision', f.revision, 'deleted_at', f.deleted_at)
  from public.family_hisabs f where f.id = p_id;
$$;

create or replace function public._family_member_json(p_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', m.id, 'family_id', m.family_id, 'user_id', m.user_id, 'name', m.name,
    'phone', m.phone, 'role', m.role, 'status', m.status, 'sort_order', m.sort_order,
    'revision', m.revision, 'deleted_at', m.deleted_at)
  from public.family_members m where m.id = p_id;
$$;

create or replace function public._family_entry_json(p_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', e.id, 'family_id', e.family_id, 'member_id', e.member_id, 'kind', e.kind,
    'amount_paise', e.amount_paise, 'entry_date', e.entry_date,
    'category_id', e.category_id, 'category_name', e.category_name,
    'category_name_gu', e.category_name_gu, 'category_icon', e.category_icon,
    'category_color', e.category_color, 'note', e.note, 'created_by', e.created_by,
    'revision', e.revision, 'deleted_at', e.deleted_at)
  from public.family_entries e where e.id = p_id;
$$;

create or replace function public._family_emit(
  p_family uuid, p_type text, p_entity uuid, p_op text, p_rev bigint, p_payload jsonb, p_op_id uuid
) returns void language sql security definer set search_path = '' as $$
  insert into public.family_sync_events (family_id, entity_type, entity_id, op_type, revision, payload, op_id, actor_id)
  values (p_family, p_type, p_entity, p_op, p_rev, p_payload, p_op_id, auth.uid());
$$;

-- --------------------------------------------------------- apply_family_op

-- Applies one client operation:
--   {op_id, family_id, entity_type ('family' | 'member' | 'entry'), entity_id,
--    op_type ('upsert' | 'delete'), base_revision, payload}
-- Returns {status: 'applied', revision} | {status: 'conflict', revision, current}
--       | {status: 'rejected', code}. The same op_id returns its first result.
create or replace function public.apply_family_op(p_op jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_op_id uuid := (p_op ->> 'op_id')::uuid;
  v_family uuid := (p_op ->> 'family_id')::uuid;
  v_type text := p_op ->> 'entity_type';
  v_entity uuid := (p_op ->> 'entity_id')::uuid;
  v_kind text := p_op ->> 'op_type';
  v_base bigint := coalesce((p_op ->> 'base_revision')::bigint, 0);
  v_p jsonb := coalesce(p_op -> 'payload', '{}'::jsonb);
  v_result jsonb;
  v_rev bigint;
  v_exists boolean;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if v_op_id is null or v_family is null or v_entity is null
     or v_kind not in ('upsert', 'delete') then
    return jsonb_build_object('status', 'rejected', 'code', 'bad_request');
  end if;

  select result into v_result from public.processed_ops where op_id = v_op_id;
  if found then
    return v_result;
  end if;

  if v_type = 'family' then
    if v_entity <> v_family then
      return jsonb_build_object('status', 'rejected', 'code', 'bad_request');
    end if;
    select revision into v_rev from public.family_hisabs where id = v_family and deleted_at is null;
    v_exists := found;
    if not v_exists then
      if v_kind <> 'upsert' or exists (select 1 from public.family_hisabs where id = v_family) then
        return jsonb_build_object('status', 'rejected', 'code', 'not_found');
      end if;
      -- Create the Family hisab and the caller's own (owner) member.
      insert into public.family_hisabs (id, name, opening_balance_paise, owner_id, last_op_id)
      values (v_family, v_p ->> 'name', coalesce((v_p ->> 'opening_balance_paise')::bigint, 0),
              v_uid, v_op_id);
      insert into public.family_members (id, family_id, user_id, name, role, status, sort_order, last_op_id)
      values ((v_p ->> 'owner_member_id')::uuid, v_family, v_uid,
              coalesce(v_p ->> 'owner_display_name', 'Owner'), 'owner', 'active', 0, v_op_id);
      perform public._family_emit(v_family, 'family', v_family, 'upsert', 1,
                                  public._family_json(v_family), v_op_id);
      perform public._family_emit(v_family, 'member', (v_p ->> 'owner_member_id')::uuid, 'upsert', 1,
                                  public._family_member_json((v_p ->> 'owner_member_id')::uuid), v_op_id);
      v_result := jsonb_build_object('status', 'applied', 'revision', 1);
    else
      if not public.is_family_admin(v_family) then
        return jsonb_build_object('status', 'rejected', 'code', 'forbidden');
      end if;
      if v_rev <> v_base then
        return jsonb_build_object('status', 'conflict', 'revision', v_rev,
                                  'current', public._family_json(v_family));
      end if;
      if v_kind = 'delete' then
        update public.family_hisabs set deleted_at = now(), revision = revision + 1,
          last_op_id = v_op_id, updated_at = now()
        where id = v_family returning revision into v_rev;
        perform public._family_emit(v_family, 'family', v_family, 'delete', v_rev,
                                    public._family_json(v_family), v_op_id);
      else
        update public.family_hisabs set
          name = v_p ->> 'name',
          opening_balance_paise = coalesce((v_p ->> 'opening_balance_paise')::bigint, opening_balance_paise),
          revision = revision + 1, last_op_id = v_op_id, updated_at = now()
        where id = v_family returning revision into v_rev;
        perform public._family_emit(v_family, 'family', v_family, 'upsert', v_rev,
                                    public._family_json(v_family), v_op_id);
      end if;
      v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);
    end if;

  elsif not public.is_family_member(v_family) then
    return jsonb_build_object('status', 'rejected', 'code', 'forbidden');

  elsif v_type = 'member' then
    if not public.is_family_admin(v_family) then
      return jsonb_build_object('status', 'rejected', 'code', 'forbidden');
    end if;
    select revision into v_rev from public.family_members
      where id = v_entity and family_id = v_family and deleted_at is null;
    v_exists := found;
    if v_kind = 'delete' then
      if not v_exists then
        return jsonb_build_object('status', 'rejected', 'code', 'not_found');
      end if;
      if (select role from public.family_members where id = v_entity) = 'owner' then
        return jsonb_build_object('status', 'rejected', 'code', 'forbidden');
      end if;
      if v_rev <> v_base then
        return jsonb_build_object('status', 'conflict', 'revision', v_rev,
                                  'current', public._family_member_json(v_entity));
      end if;
      -- Removing a person keeps their entries (old months must still add up).
      update public.family_members set status = 'removed', deleted_at = now(),
        revision = revision + 1, last_op_id = v_op_id, updated_at = now()
      where id = v_entity returning revision into v_rev;
      perform public._family_emit(v_family, 'member', v_entity, 'delete', v_rev,
                                  public._family_member_json(v_entity), v_op_id);
    elsif v_exists then
      if v_rev <> v_base then
        return jsonb_build_object('status', 'conflict', 'revision', v_rev,
                                  'current', public._family_member_json(v_entity));
      end if;
      update public.family_members set
        name = v_p ->> 'name', phone = nullif(trim(v_p ->> 'phone'), ''),
        sort_order = coalesce((v_p ->> 'sort_order')::integer, sort_order),
        revision = revision + 1, last_op_id = v_op_id, updated_at = now()
      where id = v_entity returning revision into v_rev;
      perform public._family_emit(v_family, 'member', v_entity, 'upsert', v_rev,
                                  public._family_member_json(v_entity), v_op_id);
    else
      if exists (select 1 from public.family_members where id = v_entity) then
        return jsonb_build_object('status', 'rejected', 'code', 'not_found');
      end if;
      insert into public.family_members (id, family_id, name, phone, role, status, sort_order, last_op_id)
      values (v_entity, v_family, v_p ->> 'name', nullif(trim(v_p ->> 'phone'), ''), 'member', 'active',
              coalesce((v_p ->> 'sort_order')::integer, 0), v_op_id)
      returning revision into v_rev;
      perform public._family_emit(v_family, 'member', v_entity, 'upsert', v_rev,
                                  public._family_member_json(v_entity), v_op_id);
    end if;
    v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);

  elsif v_type = 'entry' then
    select revision into v_rev from public.family_entries
      where id = v_entity and family_id = v_family and deleted_at is null;
    v_exists := found;
    if v_kind = 'delete' then
      if not v_exists then
        -- Deleting something the server never had (or already deleted) is harmless.
        v_result := jsonb_build_object('status', 'applied', 'revision', 0);
        insert into public.processed_ops (op_id, user_id, result) values (v_op_id, v_uid, v_result);
        return v_result;
      end if;
      if v_rev <> v_base then
        return jsonb_build_object('status', 'conflict', 'revision', v_rev,
                                  'current', public._family_entry_json(v_entity));
      end if;
      update public.family_entries set deleted_at = now(), revision = revision + 1,
        last_op_id = v_op_id, updated_at = now()
      where id = v_entity returning revision into v_rev;
      perform public._family_emit(v_family, 'entry', v_entity, 'delete', v_rev,
                                  public._family_entry_json(v_entity), v_op_id);
    else
      if not exists (select 1 from public.family_members
                     where id = (v_p ->> 'member_id')::uuid and family_id = v_family) then
        return jsonb_build_object('status', 'rejected', 'code', 'invalid_reference');
      end if;
      if v_exists then
        if v_rev <> v_base then
          return jsonb_build_object('status', 'conflict', 'revision', v_rev,
                                    'current', public._family_entry_json(v_entity));
        end if;
        update public.family_entries set
          member_id = (v_p ->> 'member_id')::uuid, kind = v_p ->> 'kind',
          amount_paise = (v_p ->> 'amount_paise')::bigint, entry_date = (v_p ->> 'entry_date')::date,
          category_id = v_p ->> 'category_id', category_name = v_p ->> 'category_name',
          category_name_gu = v_p ->> 'category_name_gu', category_icon = v_p ->> 'category_icon',
          category_color = (v_p ->> 'category_color')::bigint, note = nullif(trim(v_p ->> 'note'), ''),
          revision = revision + 1, last_op_id = v_op_id, updated_at = now()
        where id = v_entity returning revision into v_rev;
      else
        if exists (select 1 from public.family_entries where id = v_entity) then
          return jsonb_build_object('status', 'rejected', 'code', 'not_found');
        end if;
        insert into public.family_entries (id, family_id, member_id, kind, amount_paise, entry_date,
          category_id, category_name, category_name_gu, category_icon, category_color, note,
          created_by, last_op_id)
        values (v_entity, v_family, (v_p ->> 'member_id')::uuid, v_p ->> 'kind',
          (v_p ->> 'amount_paise')::bigint, (v_p ->> 'entry_date')::date,
          v_p ->> 'category_id', v_p ->> 'category_name', v_p ->> 'category_name_gu',
          v_p ->> 'category_icon', (v_p ->> 'category_color')::bigint, nullif(trim(v_p ->> 'note'), ''),
          v_uid, v_op_id)
        returning revision into v_rev;
      end if;
      perform public._family_emit(v_family, 'entry', v_entity, 'upsert', v_rev,
                                  public._family_entry_json(v_entity), v_op_id);
    end if;
    v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);

  else
    return jsonb_build_object('status', 'rejected', 'code', 'bad_request');
  end if;

  insert into public.processed_ops (op_id, user_id, result) values (v_op_id, v_uid, v_result);
  return v_result;
exception
  when check_violation or not_null_violation or foreign_key_violation
       or invalid_text_representation or datetime_field_overflow or invalid_datetime_format then
    return jsonb_build_object('status', 'rejected', 'code', 'invalid_data');
end;
$$;

-- ---------------------------------------------------------------- snapshot

-- Full current state of one Family hisab (joining, a new phone, recovery).
-- Removed people are included so their old entries keep their names.
create or replace function public.get_family_snapshot(p_family_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
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
    'max_seq', coalesce((select max(seq) from public.family_sync_events where family_id = p_family_id), 0)
  );
end;
$$;

-- ------------------------------------------------------------------ access

-- Read-only for clients (default privileges grant nothing since 000200).
grant select on public.family_hisabs, public.family_members, public.family_entries,
  public.family_sync_events to authenticated;
-- New functions are executable by PUBLIC by default; take that away first.
revoke execute on function
  public._family_json(uuid), public._family_member_json(uuid), public._family_entry_json(uuid),
  public._family_emit(uuid, text, uuid, text, bigint, jsonb, uuid),
  public.apply_family_op(jsonb), public.get_family_snapshot(uuid),
  public.is_family_member(uuid), public.is_family_reader(uuid), public.is_family_admin(uuid)
  from public, anon, authenticated;
grant execute on function
  public.apply_family_op(jsonb), public.get_family_snapshot(uuid),
  public.is_family_member(uuid), public.is_family_reader(uuid), public.is_family_admin(uuid)
  to authenticated;

-- Live updates: phones listen for new rows (Realtime applies the RLS above).
alter publication supabase_realtime add table public.family_sync_events;
