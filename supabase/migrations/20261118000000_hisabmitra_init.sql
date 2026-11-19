-- HisabMitra cloud schema v1
-- Only *shared group* data lives here. Personal transactions, people, the
-- personal ledger, reminders and attachments never reach the cloud.
--
-- Security model (docs/RLS_SECURITY.md):
--  * RLS is enabled on every table.
--  * Clients may only SELECT, and only rows of groups they actively belong to.
--  * All writes go through SECURITY DEFINER functions that check auth.uid(),
--    membership, idempotency (op_id) and optimistic concurrency (revision).

create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------- tables

create table public.user_profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 80),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_devices (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null default 'android' check (platform in ('android', 'ios')),
  app_version text check (char_length(app_version) <= 40),
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index user_devices_user_idx on public.user_devices (user_id);

create table public.groups (
  id uuid primary key,
  name text not null check (char_length(name) between 1 and 80),
  description text check (char_length(description) <= 200),
  group_type text not null check (group_type in ('trip', 'family', 'friends', 'event', 'household', 'other')),
  currency text not null default 'INR' check (currency = 'INR'),
  status text not null default 'active' check (status in ('active', 'archived')),
  owner_id uuid references auth.users (id) on delete set null,
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.group_members (
  id uuid primary key,
  group_id uuid not null references public.groups (id) on delete cascade,
  -- Set only by the server (group creation or invitation acceptance).
  user_id uuid references auth.users (id) on delete set null,
  display_name text not null check (char_length(display_name) between 1 and 80),
  role text not null default 'member' check (role in ('owner', 'admin', 'member')),
  status text not null default 'active' check (status in ('active', 'invited', 'removed')),
  sort_order integer not null default 0,
  joined_at timestamptz not null default now(),
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index group_members_group_idx on public.group_members (group_id);
create index group_members_user_idx on public.group_members (user_id);
create unique index group_members_one_user_per_group
  on public.group_members (group_id, user_id)
  where user_id is not null and deleted_at is null;

create table public.group_expenses (
  id uuid primary key,
  group_id uuid not null references public.groups (id) on delete cascade,
  description text not null check (char_length(description) between 1 and 120),
  category_key text not null check (char_length(category_key) between 1 and 30),
  amount_paise bigint not null check (amount_paise > 0 and amount_paise <= 99999999999),
  paid_by_member_id uuid not null references public.group_members (id),
  expense_date date not null,
  split_method text not null check (split_method in ('equal', 'exact', 'percentage', 'ratio', 'adjustment')),
  notes text check (char_length(notes) <= 500),
  created_by uuid references auth.users (id) on delete set null,
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index group_expenses_group_date_idx on public.group_expenses (group_id, expense_date);

create table public.group_expense_splits (
  id uuid primary key,
  expense_id uuid not null references public.group_expenses (id) on delete cascade,
  member_id uuid not null references public.group_members (id),
  share_paise bigint not null check (share_paise >= 0),
  input_value bigint,
  unique (expense_id, member_id)
);
create index group_expense_splits_expense_idx on public.group_expense_splits (expense_id);

create table public.group_settlements (
  id uuid primary key,
  group_id uuid not null references public.groups (id) on delete cascade,
  from_member_id uuid not null references public.group_members (id),
  to_member_id uuid not null references public.group_members (id),
  amount_paise bigint not null check (amount_paise > 0 and amount_paise <= 99999999999),
  settled_on date not null,
  payment_method text not null check (payment_method in ('cash', 'upi', 'bankTransfer', 'creditCard', 'debitCard', 'other')),
  notes text check (char_length(notes) <= 500),
  created_by uuid references auth.users (id) on delete set null,
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (from_member_id <> to_member_id)
);
create index group_settlements_group_idx on public.group_settlements (group_id, settled_on);

-- Metadata of attachments a member explicitly shared with the group. The
-- files live in the private `group-attachments` storage bucket.
create table public.group_attachments (
  id uuid primary key,
  group_id uuid not null references public.groups (id) on delete cascade,
  expense_id uuid not null references public.group_expenses (id) on delete cascade,
  storage_path text not null unique,
  mime_type text not null check (mime_type in ('image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf')),
  size_bytes integer not null check (size_bytes > 0 and size_bytes <= 10485760),
  sha256 text not null check (char_length(sha256) = 64),
  uploaded_by uuid references auth.users (id) on delete set null,
  deleted_at timestamptz,
  created_at timestamptz not null default now()
);
create index group_attachments_expense_idx on public.group_attachments (expense_id);

create table public.group_invitations (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  -- SHA-256 of the invitation code; the plain code is shown once to the inviter.
  code_hash text not null unique,
  created_by uuid not null references auth.users (id) on delete cascade,
  -- Optional local participant record the invitee will take over.
  member_id uuid references public.group_members (id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'cancelled', 'expired')),
  expires_at timestamptz not null,
  accepted_by uuid references auth.users (id) on delete set null,
  accepted_at timestamptz,
  created_at timestamptz not null default now()
);
create index group_invitations_group_idx on public.group_invitations (group_id);
create unique index group_invitations_one_pending_per_member
  on public.group_invitations (member_id)
  where status = 'pending' and member_id is not null;

-- Append-only change feed for synchronisation (cursor = seq).
create table public.sync_events (
  seq bigserial primary key,
  group_id uuid not null references public.groups (id) on delete cascade,
  entity_type text not null check (entity_type in ('group', 'member', 'expense', 'settlement', 'attachment')),
  entity_id uuid not null,
  op_type text not null check (op_type in ('upsert', 'delete')),
  revision bigint not null,
  payload jsonb not null,
  op_id uuid,
  actor_id uuid,
  created_at timestamptz not null default now()
);
create index sync_events_group_seq_idx on public.sync_events (group_id, seq);

-- Idempotency log: the result of every applied client operation.
create table public.processed_ops (
  op_id uuid primary key,
  user_id uuid not null,
  result jsonb not null,
  created_at timestamptz not null default now()
);

-- -------------------------------------------------------- authorisation helpers

create or replace function public.is_group_member(p_group_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.group_members m
    join public.groups g on g.id = m.group_id
    where m.group_id = p_group_id
      and m.user_id = auth.uid()
      and m.status = 'active'
      and m.deleted_at is null
      and g.deleted_at is null
  );
$$;

create or replace function public.is_group_admin(p_group_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.group_members m
    where m.group_id = p_group_id
      and m.user_id = auth.uid()
      and m.status = 'active'
      and m.deleted_at is null
      and m.role in ('owner', 'admin')
  );
$$;

-- ----------------------------------------------------------------- RLS

alter table public.user_profiles enable row level security;
alter table public.user_devices enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.group_expenses enable row level security;
alter table public.group_expense_splits enable row level security;
alter table public.group_settlements enable row level security;
alter table public.group_attachments enable row level security;
alter table public.group_invitations enable row level security;
alter table public.sync_events enable row level security;
alter table public.processed_ops enable row level security;

create policy profiles_own_select on public.user_profiles
  for select to authenticated using (id = auth.uid());
create policy profiles_own_insert on public.user_profiles
  for insert to authenticated with check (id = auth.uid());
create policy profiles_own_update on public.user_profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

create policy devices_own_all on public.user_devices
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy groups_member_select on public.groups
  for select to authenticated using (public.is_group_member(id));
create policy members_member_select on public.group_members
  for select to authenticated using (public.is_group_member(group_id));
create policy expenses_member_select on public.group_expenses
  for select to authenticated using (public.is_group_member(group_id));
create policy splits_member_select on public.group_expense_splits
  for select to authenticated using (
    exists (select 1 from public.group_expenses e
            where e.id = expense_id and public.is_group_member(e.group_id))
  );
create policy settlements_member_select on public.group_settlements
  for select to authenticated using (public.is_group_member(group_id));
create policy attachments_member_select on public.group_attachments
  for select to authenticated using (public.is_group_member(group_id));
create policy invitations_admin_select on public.group_invitations
  for select to authenticated using (public.is_group_admin(group_id));
create policy events_member_select on public.sync_events
  for select to authenticated using (public.is_group_member(group_id));
-- processed_ops: no policy at all → no client access.

-- Clients never write group data directly.
revoke all on all tables in schema public from anon;
revoke insert, update, delete, truncate on
  public.groups, public.group_members, public.group_expenses, public.group_expense_splits,
  public.group_settlements, public.group_attachments, public.group_invitations,
  public.sync_events, public.processed_ops
  from authenticated;
grant select on all tables in schema public to authenticated;
grant insert, update on public.user_profiles to authenticated;
grant insert, update, delete on public.user_devices to authenticated;

-- ------------------------------------------------------------ row → json

create or replace function public._member_json(p_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', m.id, 'group_id', m.group_id, 'user_id', m.user_id,
    'display_name', m.display_name, 'role', m.role, 'status', m.status,
    'sort_order', m.sort_order, 'joined_at', m.joined_at, 'revision', m.revision,
    'deleted_at', m.deleted_at)
  from public.group_members m where m.id = p_id;
$$;

create or replace function public._group_json(p_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', g.id, 'name', g.name, 'description', g.description, 'group_type', g.group_type,
    'currency', g.currency, 'status', g.status, 'owner_id', g.owner_id,
    'revision', g.revision, 'deleted_at', g.deleted_at)
  from public.groups g where g.id = p_id;
$$;

create or replace function public._expense_json(p_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', e.id, 'group_id', e.group_id, 'description', e.description,
    'category_key', e.category_key, 'amount_paise', e.amount_paise,
    'paid_by_member_id', e.paid_by_member_id, 'expense_date', e.expense_date,
    'split_method', e.split_method, 'notes', e.notes, 'revision', e.revision,
    'deleted_at', e.deleted_at,
    'splits', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', s.id, 'member_id', s.member_id, 'share_paise', s.share_paise,
        'input_value', s.input_value) order by s.member_id)
      from public.group_expense_splits s where s.expense_id = e.id), '[]'::jsonb))
  from public.group_expenses e where e.id = p_id;
$$;

create or replace function public._settlement_json(p_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', s.id, 'group_id', s.group_id, 'from_member_id', s.from_member_id,
    'to_member_id', s.to_member_id, 'amount_paise', s.amount_paise,
    'settled_on', s.settled_on, 'payment_method', s.payment_method, 'notes', s.notes,
    'revision', s.revision, 'deleted_at', s.deleted_at)
  from public.group_settlements s where s.id = p_id;
$$;

create or replace function public._emit(
  p_group uuid, p_type text, p_entity uuid, p_op text, p_rev bigint, p_payload jsonb, p_op_id uuid
) returns void
language sql security definer set search_path = '' as $$
  insert into public.sync_events (group_id, entity_type, entity_id, op_type, revision, payload, op_id, actor_id)
  values (p_group, p_type, p_entity, p_op, p_rev, p_payload, p_op_id, auth.uid());
$$;

-- --------------------------------------------------------- apply_group_op

-- Applies one client operation:
--   {op_id, group_id, entity_type, entity_id, op_type, base_revision, payload}
-- Returns {status: 'applied', revision} | {status: 'conflict', revision, current}
--       | {status: 'rejected', code}.
-- Re-sending the same op_id returns the original result (idempotent).
create or replace function public.apply_group_op(p_op jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_op_id uuid := (p_op ->> 'op_id')::uuid;
  v_group uuid := (p_op ->> 'group_id')::uuid;
  v_type text := p_op ->> 'entity_type';
  v_entity uuid := (p_op ->> 'entity_id')::uuid;
  v_kind text := p_op ->> 'op_type';
  v_base bigint := coalesce((p_op ->> 'base_revision')::bigint, 0);
  v_p jsonb := coalesce(p_op -> 'payload', '{}'::jsonb);
  v_result jsonb;
  v_rev bigint;
  v_exists boolean;
  v_split jsonb;
  v_sum bigint;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if v_op_id is null or v_group is null or v_entity is null
     or v_kind not in ('upsert', 'delete') then
    return jsonb_build_object('status', 'rejected', 'code', 'bad_request');
  end if;

  select result into v_result from public.processed_ops where op_id = v_op_id;
  if found then
    return v_result;
  end if;

  if v_type = 'group' then
    if v_entity <> v_group then
      return jsonb_build_object('status', 'rejected', 'code', 'bad_request');
    end if;
    select revision into v_rev from public.groups where id = v_group and deleted_at is null;
    v_exists := found;
    if not v_exists then
      if v_kind <> 'upsert' or exists (select 1 from public.groups where id = v_group) then
        return jsonb_build_object('status', 'rejected', 'code', 'not_found');
      end if;
      -- Create the group and the caller's own (owner) member record.
      insert into public.groups (id, name, description, group_type, status, owner_id, last_op_id)
      values (v_group, v_p ->> 'name', v_p ->> 'description', v_p ->> 'group_type',
              coalesce(v_p ->> 'status', 'active'), v_uid, v_op_id);
      insert into public.group_members (id, group_id, user_id, display_name, role, status, sort_order, last_op_id)
      values ((v_p ->> 'owner_member_id')::uuid, v_group, v_uid,
              coalesce(v_p ->> 'owner_display_name', 'Owner'), 'owner', 'active', 0, v_op_id);
      perform public._emit(v_group, 'group', v_group, 'upsert', 1, public._group_json(v_group), v_op_id);
      perform public._emit(v_group, 'member', (v_p ->> 'owner_member_id')::uuid, 'upsert', 1,
                           public._member_json((v_p ->> 'owner_member_id')::uuid), v_op_id);
      v_result := jsonb_build_object('status', 'applied', 'revision', 1);
    else
      if not public.is_group_admin(v_group) then
        return jsonb_build_object('status', 'rejected', 'code', 'forbidden');
      end if;
      if v_kind = 'delete' then
        return jsonb_build_object('status', 'rejected', 'code', 'unsupported');
      end if;
      if v_rev <> v_base then
        return jsonb_build_object('status', 'conflict', 'revision', v_rev, 'current', public._group_json(v_group));
      end if;
      update public.groups set
        name = v_p ->> 'name', description = v_p ->> 'description',
        group_type = v_p ->> 'group_type', status = coalesce(v_p ->> 'status', status),
        revision = revision + 1, last_op_id = v_op_id, updated_at = now()
      where id = v_group returning revision into v_rev;
      perform public._emit(v_group, 'group', v_group, 'upsert', v_rev, public._group_json(v_group), v_op_id);
      v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);
    end if;

  elsif not public.is_group_member(v_group) then
    return jsonb_build_object('status', 'rejected', 'code', 'forbidden');

  elsif v_type = 'member' then
    select revision into v_rev from public.group_members
      where id = v_entity and group_id = v_group and deleted_at is null;
    v_exists := found;
    if v_kind = 'delete' then
      if not v_exists then
        return jsonb_build_object('status', 'rejected', 'code', 'not_found');
      end if;
      if not public.is_group_admin(v_group) then
        return jsonb_build_object('status', 'rejected', 'code', 'forbidden');
      end if;
      if v_rev <> v_base then
        return jsonb_build_object('status', 'conflict', 'revision', v_rev, 'current', public._member_json(v_entity));
      end if;
      if exists (select 1 from public.group_expenses where paid_by_member_id = v_entity and deleted_at is null)
         or exists (select 1 from public.group_expense_splits s join public.group_expenses e on e.id = s.expense_id
                    where s.member_id = v_entity and e.deleted_at is null)
         or exists (select 1 from public.group_settlements where (from_member_id = v_entity or to_member_id = v_entity)
                    and deleted_at is null)
         or exists (select 1 from public.group_members where id = v_entity and role = 'owner') then
        return jsonb_build_object('status', 'rejected', 'code', 'member_in_use');
      end if;
      update public.group_members set status = 'removed', deleted_at = now(),
        revision = revision + 1, last_op_id = v_op_id, updated_at = now()
      where id = v_entity returning revision into v_rev;
      perform public._emit(v_group, 'member', v_entity, 'delete', v_rev, public._member_json(v_entity), v_op_id);
    elsif not v_exists then
      if exists (select 1 from public.group_members where id = v_entity) then
        return jsonb_build_object('status', 'rejected', 'code', 'not_found');
      end if;
      -- New local participant: never linked to an account by the client.
      insert into public.group_members (id, group_id, user_id, display_name, role, status, sort_order, last_op_id)
      values (v_entity, v_group, null, v_p ->> 'display_name', 'member', 'active',
              coalesce((v_p ->> 'sort_order')::int, 0), v_op_id)
      returning revision into v_rev;
      perform public._emit(v_group, 'member', v_entity, 'upsert', v_rev, public._member_json(v_entity), v_op_id);
    else
      if v_rev <> v_base then
        return jsonb_build_object('status', 'conflict', 'revision', v_rev, 'current', public._member_json(v_entity));
      end if;
      update public.group_members set display_name = v_p ->> 'display_name',
        sort_order = coalesce((v_p ->> 'sort_order')::int, sort_order),
        revision = revision + 1, last_op_id = v_op_id, updated_at = now()
      where id = v_entity returning revision into v_rev;
      perform public._emit(v_group, 'member', v_entity, 'upsert', v_rev, public._member_json(v_entity), v_op_id);
    end if;
    v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);

  elsif v_type = 'expense' then
    select revision into v_rev from public.group_expenses
      where id = v_entity and group_id = v_group and deleted_at is null;
    v_exists := found;
    if v_kind = 'delete' then
      if not v_exists then
        return jsonb_build_object('status', 'rejected', 'code', 'not_found');
      end if;
      if v_rev <> v_base then
        return jsonb_build_object('status', 'conflict', 'revision', v_rev, 'current', public._expense_json(v_entity));
      end if;
      update public.group_expenses set deleted_at = now(), revision = revision + 1,
        last_op_id = v_op_id, updated_at = now()
      where id = v_entity returning revision into v_rev;
      perform public._emit(v_group, 'expense', v_entity, 'delete', v_rev, public._expense_json(v_entity), v_op_id);
      v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);
    else
      -- Validate payer, participants and exact reconciliation of the split.
      if not exists (select 1 from public.group_members where id = (v_p ->> 'paid_by_member_id')::uuid
                     and group_id = v_group and deleted_at is null) then
        return jsonb_build_object('status', 'rejected', 'code', 'invalid_member');
      end if;
      select coalesce(sum((s ->> 'share_paise')::bigint), -1) into v_sum
        from jsonb_array_elements(coalesce(v_p -> 'splits', '[]'::jsonb)) s;
      if v_sum <> (v_p ->> 'amount_paise')::bigint then
        return jsonb_build_object('status', 'rejected', 'code', 'split_mismatch');
      end if;
      if exists (select 1 from jsonb_array_elements(v_p -> 'splits') s
                 where not exists (select 1 from public.group_members m
                                   where m.id = (s ->> 'member_id')::uuid and m.group_id = v_group
                                     and m.deleted_at is null)) then
        return jsonb_build_object('status', 'rejected', 'code', 'invalid_member');
      end if;
      if not v_exists then
        if exists (select 1 from public.group_expenses where id = v_entity) then
          return jsonb_build_object('status', 'rejected', 'code', 'not_found');
        end if;
        insert into public.group_expenses (id, group_id, description, category_key, amount_paise,
          paid_by_member_id, expense_date, split_method, notes, created_by, last_op_id)
        values (v_entity, v_group, v_p ->> 'description', v_p ->> 'category_key',
          (v_p ->> 'amount_paise')::bigint, (v_p ->> 'paid_by_member_id')::uuid,
          (v_p ->> 'expense_date')::date, v_p ->> 'split_method', v_p ->> 'notes', v_uid, v_op_id)
        returning revision into v_rev;
      else
        if v_rev <> v_base then
          return jsonb_build_object('status', 'conflict', 'revision', v_rev, 'current', public._expense_json(v_entity));
        end if;
        update public.group_expenses set description = v_p ->> 'description',
          category_key = v_p ->> 'category_key', amount_paise = (v_p ->> 'amount_paise')::bigint,
          paid_by_member_id = (v_p ->> 'paid_by_member_id')::uuid,
          expense_date = (v_p ->> 'expense_date')::date, split_method = v_p ->> 'split_method',
          notes = v_p ->> 'notes', revision = revision + 1, last_op_id = v_op_id, updated_at = now()
        where id = v_entity returning revision into v_rev;
        delete from public.group_expense_splits where expense_id = v_entity;
      end if;
      for v_split in select * from jsonb_array_elements(v_p -> 'splits') loop
        insert into public.group_expense_splits (id, expense_id, member_id, share_paise, input_value)
        values ((v_split ->> 'id')::uuid, v_entity, (v_split ->> 'member_id')::uuid,
                (v_split ->> 'share_paise')::bigint, (v_split ->> 'input_value')::bigint);
      end loop;
      perform public._emit(v_group, 'expense', v_entity, 'upsert', v_rev, public._expense_json(v_entity), v_op_id);
      v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);
    end if;

  elsif v_type = 'settlement' then
    select revision into v_rev from public.group_settlements
      where id = v_entity and group_id = v_group and deleted_at is null;
    v_exists := found;
    if v_kind = 'delete' then
      if not v_exists then
        return jsonb_build_object('status', 'rejected', 'code', 'not_found');
      end if;
      if v_rev <> v_base then
        return jsonb_build_object('status', 'conflict', 'revision', v_rev, 'current', public._settlement_json(v_entity));
      end if;
      update public.group_settlements set deleted_at = now(), revision = revision + 1,
        last_op_id = v_op_id, updated_at = now()
      where id = v_entity returning revision into v_rev;
      perform public._emit(v_group, 'settlement', v_entity, 'delete', v_rev, public._settlement_json(v_entity), v_op_id);
    elsif v_exists then
      -- Settlements are immutable once recorded (audit trail).
      return jsonb_build_object('status', 'rejected', 'code', 'unsupported');
    else
      if exists (select 1 from public.group_settlements where id = v_entity) then
        return jsonb_build_object('status', 'rejected', 'code', 'not_found');
      end if;
      if (select count(*) from public.group_members
          where group_id = v_group and deleted_at is null
            and id in ((v_p ->> 'from_member_id')::uuid, (v_p ->> 'to_member_id')::uuid)) <> 2 then
        return jsonb_build_object('status', 'rejected', 'code', 'invalid_member');
      end if;
      insert into public.group_settlements (id, group_id, from_member_id, to_member_id, amount_paise,
        settled_on, payment_method, notes, created_by, last_op_id)
      values (v_entity, v_group, (v_p ->> 'from_member_id')::uuid, (v_p ->> 'to_member_id')::uuid,
        (v_p ->> 'amount_paise')::bigint, (v_p ->> 'settled_on')::date, v_p ->> 'payment_method',
        v_p ->> 'notes', v_uid, v_op_id)
      returning revision into v_rev;
      perform public._emit(v_group, 'settlement', v_entity, 'upsert', v_rev, public._settlement_json(v_entity), v_op_id);
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

-- Full current state of one group (used when joining or recovering).
create or replace function public.get_group_snapshot(p_group_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_group_member(p_group_id) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'group', public._group_json(p_group_id),
    'members', coalesce((select jsonb_agg(public._member_json(id)) from public.group_members
                         where group_id = p_group_id), '[]'::jsonb),
    'expenses', coalesce((select jsonb_agg(public._expense_json(id)) from public.group_expenses
                          where group_id = p_group_id), '[]'::jsonb),
    'settlements', coalesce((select jsonb_agg(public._settlement_json(id)) from public.group_settlements
                             where group_id = p_group_id), '[]'::jsonb),
    'max_seq', coalesce((select max(seq) from public.sync_events where group_id = p_group_id), 0)
  );
end;
$$;

-- ------------------------------------------------------------- invitations

create or replace function public.create_group_invitation(
  p_group_id uuid, p_member_id uuid default null, p_ttl_hours integer default 72
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
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
  if not public.is_group_admin(p_group_id) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_member_id is not null then
    if not exists (select 1 from public.group_members where id = p_member_id and group_id = p_group_id
                   and user_id is null and deleted_at is null) then
      raise exception 'invalid_member' using errcode = '22023';
    end if;
    if exists (select 1 from public.group_invitations where member_id = p_member_id
               and status = 'pending' and expires_at > now()) then
      raise exception 'invitation_pending' using errcode = '23505';
    end if;
    update public.group_invitations set status = 'expired'
      where member_id = p_member_id and status = 'pending' and expires_at <= now();
  end if;
  for i in 0..9 loop
    v_code := v_code || substr(v_alphabet, (get_byte(v_bytes, i) % length(v_alphabet)) + 1, 1);
  end loop;
  insert into public.group_invitations (group_id, code_hash, created_by, member_id, expires_at)
  values (p_group_id, encode(extensions.digest(v_code, 'sha256'), 'hex'), auth.uid(), p_member_id, v_expires)
  returning id into v_id;
  return jsonb_build_object('invitation_id', v_id, 'code', v_code, 'expires_at', v_expires);
end;
$$;

create or replace function public.accept_group_invitation(p_code text, p_display_name text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_inv public.group_invitations%rowtype;
  v_member uuid;
  v_rev bigint;
  v_name text := left(coalesce(nullif(trim(p_display_name), ''), 'Member'), 80);
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  select * into v_inv from public.group_invitations
    where code_hash = encode(extensions.digest(upper(trim(p_code)), 'sha256'), 'hex')
    for update;
  if not found or v_inv.status in ('cancelled', 'accepted') then
    raise exception 'invalid_code' using errcode = '22023';
  end if;
  if v_inv.status = 'expired' or v_inv.expires_at <= now() then
    update public.group_invitations set status = 'expired' where id = v_inv.id;
    raise exception 'expired' using errcode = '22023';
  end if;
  if exists (select 1 from public.groups where id = v_inv.group_id and deleted_at is not null) then
    raise exception 'invalid_code' using errcode = '22023';
  end if;
  if exists (select 1 from public.group_members where group_id = v_inv.group_id
             and user_id = v_uid and deleted_at is null) then
    raise exception 'already_member' using errcode = '23505';
  end if;

  if v_inv.member_id is not null then
    update public.group_members set user_id = v_uid, status = 'active',
      revision = revision + 1, updated_at = now()
    where id = v_inv.member_id and user_id is null and deleted_at is null
    returning id, revision into v_member, v_rev;
    if v_member is null then
      raise exception 'invalid_code' using errcode = '22023';
    end if;
  else
    v_member := gen_random_uuid();
    insert into public.group_members (id, group_id, user_id, display_name, role, status, sort_order)
    values (v_member, v_inv.group_id, v_uid, v_name, 'member', 'active',
            coalesce((select max(sort_order) + 1 from public.group_members where group_id = v_inv.group_id), 1))
    returning revision into v_rev;
  end if;
  update public.group_invitations set status = 'accepted', accepted_by = v_uid, accepted_at = now()
    where id = v_inv.id;
  perform public._emit(v_inv.group_id, 'member', v_member, 'upsert', v_rev, public._member_json(v_member), null);
  return jsonb_build_object('group_id', v_inv.group_id, 'member_id', v_member);
end;
$$;

create or replace function public.cancel_group_invitation(p_invitation_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_group uuid;
begin
  select group_id into v_group from public.group_invitations where id = p_invitation_id;
  if v_group is null or not public.is_group_admin(v_group) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  update public.group_invitations set status = 'cancelled'
    where id = p_invitation_id and status = 'pending';
end;
$$;

-- ---------------------------------------------------------- account deletion

-- Called by the `delete-account` Edge Function with the user's JWT before
-- the auth user is removed. Shared history stays intact: the user's member
-- records become plain participants; owned groups pass to another member
-- or are closed when nobody else has an account.
create or replace function public.prepare_account_deletion()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_group record;
  v_next uuid;
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
  delete from public.user_devices where user_id = v_uid;
  delete from public.user_profiles where id = v_uid;
end;
$$;

-- Function execution: only signed-in users (and never anon).
revoke execute on all functions in schema public from public, anon;
grant execute on function
  public.apply_group_op(jsonb),
  public.get_group_snapshot(uuid),
  public.create_group_invitation(uuid, uuid, integer),
  public.accept_group_invitation(text, text),
  public.cancel_group_invitation(uuid),
  public.prepare_account_deletion(),
  public.is_group_member(uuid),
  public.is_group_admin(uuid)
  to authenticated;
