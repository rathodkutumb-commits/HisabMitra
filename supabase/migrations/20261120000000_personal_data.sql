-- HisabMitra cloud schema: personal data (Part B, 2026-11-20).
--
-- Every user's own records live here: people, income/expense entries,
-- khata (money given/taken) and repayments, reminders and bill metadata.
-- Income/expense categories stay on the phone; entries carry a snapshot of
-- their category so a new phone can show and re-create it.
--
-- Same security model as groups (docs/RLS_SECURITY.md):
--  * RLS on every table; a user can only SELECT their own rows.
--  * All writes go through apply_personal_op (SECURITY DEFINER), which checks
--    auth.uid(), ownership of every referenced row, idempotency (op_id) and
--    optimistic concurrency (revision). Deletes are tombstones.
--  * personal_sync_events is each user's change feed (cursor = seq).

-- ---------------------------------------------------------------- tables

create table public.personal_people (
  id uuid primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80),
  phone text check (char_length(phone) <= 40),
  email text check (char_length(email) <= 254),
  description text check (char_length(description) <= 500),
  notes text check (char_length(notes) <= 2000),
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index personal_people_owner_idx on public.personal_people (owner_id);

create table public.personal_transactions (
  id uuid primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  type text not null check (type in ('income', 'expense')),
  amount_paise bigint not null check (amount_paise > 0 and amount_paise <= 99999999999),
  category_id text not null check (char_length(category_id) between 1 and 60),
  category_name text not null check (char_length(category_name) between 1 and 60),
  category_system_key text check (char_length(category_system_key) <= 40),
  category_icon text not null check (char_length(category_icon) between 1 and 40),
  category_color bigint not null,
  txn_date date not null,
  payment_method text not null check (payment_method in ('cash', 'upi', 'bankTransfer', 'creditCard', 'debitCard', 'other')),
  person_id uuid references public.personal_people (id),
  description text not null default '' check (char_length(description) <= 500),
  notes text check (char_length(notes) <= 2000),
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index personal_transactions_owner_idx on public.personal_transactions (owner_id, txn_date);

create table public.personal_ledger_entries (
  id uuid primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  person_id uuid not null references public.personal_people (id),
  direction text not null check (direction in ('given', 'taken')),
  principal_paise bigint not null check (principal_paise > 0 and principal_paise <= 99999999999),
  entry_date date not null,
  due_date date,
  payment_method text not null check (payment_method in ('cash', 'upi', 'bankTransfer', 'creditCard', 'debitCard', 'other')),
  description text not null default '' check (char_length(description) <= 500),
  notes text check (char_length(notes) <= 2000),
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index personal_ledger_entries_owner_idx on public.personal_ledger_entries (owner_id);
create index personal_ledger_entries_person_idx on public.personal_ledger_entries (person_id);

create table public.personal_ledger_repayments (
  id uuid primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  ledger_id uuid not null references public.personal_ledger_entries (id),
  amount_paise bigint not null check (amount_paise > 0 and amount_paise <= 99999999999),
  settled_on date not null,
  payment_method text not null check (payment_method in ('cash', 'upi', 'bankTransfer', 'creditCard', 'debitCard', 'other')),
  notes text check (char_length(notes) <= 2000),
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index personal_ledger_repayments_owner_idx on public.personal_ledger_repayments (owner_id);
create index personal_ledger_repayments_ledger_idx on public.personal_ledger_repayments (ledger_id);

create table public.personal_reminders (
  id uuid primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  kind text not null check (kind in ('repayment', 'collection', 'groupSettlement', 'custom', 'emi', 'sip',
    'installment', 'maintenance', 'insurance', 'rent', 'subscription', 'bill')),
  title text not null check (char_length(title) between 1 and 120),
  note text check (char_length(note) <= 2000),
  due_at timestamptz not null,
  repeat text not null default 'none' check (repeat in ('none', 'daily', 'weekly', 'monthly', 'quarterly',
    'halfYearly', 'yearly')),
  person_id uuid references public.personal_people (id),
  ledger_entry_id uuid references public.personal_ledger_entries (id),
  -- Groups are shared rows; membership is checked by apply_personal_op.
  group_id uuid,
  amount_paise bigint check (amount_paise > 0 and amount_paise <= 99999999999),
  category_id text check (char_length(category_id) <= 60),
  category_name text check (char_length(category_name) <= 60),
  category_system_key text check (char_length(category_system_key) <= 40),
  category_icon text check (char_length(category_icon) <= 40),
  category_color bigint,
  anchor_day integer check (anchor_day between 1 and 31),
  total_occurrences integer check (total_occurrences >= 1),
  completed_occurrences integer not null default 0 check (completed_occurrences >= 0),
  status text not null default 'pending' check (status in ('pending', 'done', 'cancelled')),
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index personal_reminders_owner_idx on public.personal_reminders (owner_id);

-- Bills/receipts of personal records. The file lives in the private
-- `personal-attachments` bucket at storage_path = '<owner_id>/<storage_name>'.
create table public.personal_attachments (
  id uuid primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  parent_type text not null check (parent_type in ('transaction', 'ledger_entry')),
  parent_id uuid not null,
  storage_name text not null check (storage_name ~ '^[A-Za-z0-9._-]{1,100}$'),
  storage_path text not null,
  original_name text not null check (char_length(original_name) between 1 and 255),
  mime_type text not null check (mime_type in ('image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf')),
  size_bytes integer not null check (size_bytes > 0 and size_bytes <= 10485760),
  sha256 text not null check (char_length(sha256) = 64),
  revision bigint not null default 1,
  last_op_id uuid,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index personal_attachments_owner_idx on public.personal_attachments (owner_id);
create index personal_attachments_parent_idx on public.personal_attachments (parent_id);

-- Each user's change feed (cursor = seq). entity_id is null for 'reset'.
create table public.personal_sync_events (
  seq bigserial primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  entity_type text not null check (entity_type in ('person', 'transaction', 'ledger_entry',
    'ledger_repayment', 'reminder', 'attachment', 'all')),
  entity_id uuid,
  op_type text not null check (op_type in ('upsert', 'delete', 'reset')),
  revision bigint not null,
  payload jsonb not null,
  op_id uuid,
  created_at timestamptz not null default now()
);
create index personal_sync_events_owner_seq_idx on public.personal_sync_events (owner_id, seq);

-- ------------------------------------------------------------------- RLS

alter table public.personal_people enable row level security;
alter table public.personal_transactions enable row level security;
alter table public.personal_ledger_entries enable row level security;
alter table public.personal_ledger_repayments enable row level security;
alter table public.personal_reminders enable row level security;
alter table public.personal_attachments enable row level security;
alter table public.personal_sync_events enable row level security;

create policy personal_people_own on public.personal_people
  for select to authenticated using (owner_id = auth.uid());
create policy personal_transactions_own on public.personal_transactions
  for select to authenticated using (owner_id = auth.uid());
create policy personal_ledger_entries_own on public.personal_ledger_entries
  for select to authenticated using (owner_id = auth.uid());
create policy personal_ledger_repayments_own on public.personal_ledger_repayments
  for select to authenticated using (owner_id = auth.uid());
create policy personal_reminders_own on public.personal_reminders
  for select to authenticated using (owner_id = auth.uid());
create policy personal_attachments_own on public.personal_attachments
  for select to authenticated using (owner_id = auth.uid());
create policy personal_sync_events_own on public.personal_sync_events
  for select to authenticated using (owner_id = auth.uid());

-- Read-only for clients (default privileges grant nothing since 000200).
grant select on
  public.personal_people, public.personal_transactions, public.personal_ledger_entries,
  public.personal_ledger_repayments, public.personal_reminders, public.personal_attachments,
  public.personal_sync_events
  to authenticated;

-- --------------------------------------------------------------- helpers

create or replace function public._personal_table(p_type text) returns text
language sql immutable security definer set search_path = '' as $$
  select case p_type
    when 'person' then 'personal_people'
    when 'transaction' then 'personal_transactions'
    when 'ledger_entry' then 'personal_ledger_entries'
    when 'ledger_repayment' then 'personal_ledger_repayments'
    when 'reminder' then 'personal_reminders'
    when 'attachment' then 'personal_attachments'
  end;
$$;

create or replace function public._personal_emit(
  p_owner uuid, p_type text, p_entity uuid, p_op text, p_rev bigint, p_payload jsonb, p_op_id uuid
) returns void
language sql security definer set search_path = '' as $$
  insert into public.personal_sync_events (owner_id, entity_type, entity_id, op_type, revision, payload, op_id)
  values (p_owner, p_type, p_entity, p_op, p_rev, p_payload, p_op_id);
$$;

-- The full row as JSON (null when absent).
create or replace function public._personal_row(p_type text, p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  v jsonb;
begin
  execute format('select to_jsonb(t) from public.%I t where id = $1', public._personal_table(p_type))
    into v using p_id;
  return v;
end;
$$;

-- True when p_id is a live row of p_type owned by p_owner.
create or replace function public._personal_owns(p_owner uuid, p_type text, p_id uuid) returns boolean
language plpgsql stable security definer set search_path = '' as $$
declare
  v boolean;
begin
  if p_id is null then
    return true;
  end if;
  execute format('select exists (select 1 from public.%I where id = $1 and owner_id = $2 and deleted_at is null)',
                 public._personal_table(p_type))
    into v using p_id, p_owner;
  return v;
end;
$$;

-- Tombstones one live row and emits a delete event.
create or replace function public._personal_tombstone(p_owner uuid, p_type text, p_id uuid, p_op_id uuid)
returns bigint
language plpgsql security definer set search_path = '' as $$
declare
  v_rev bigint;
begin
  execute format('update public.%I set deleted_at = now(), revision = revision + 1, last_op_id = $2,
                  updated_at = now() where id = $1 and deleted_at is null returning revision',
                 public._personal_table(p_type))
    into v_rev using p_id, p_op_id;
  if v_rev is not null then
    perform public._personal_emit(p_owner, p_type, p_id, 'delete', v_rev,
                                  public._personal_row(p_type, p_id), p_op_id);
  end if;
  return v_rev;
end;
$$;

-- Clears a reference column on one live row (person deleted) and emits it.
create or replace function public._personal_unlink(
  p_owner uuid, p_type text, p_id uuid, p_column text, p_op_id uuid
) returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_rev bigint;
begin
  execute format('update public.%I set %I = null, revision = revision + 1, last_op_id = $2,
                  updated_at = now() where id = $1 and deleted_at is null returning revision',
                 public._personal_table(p_type), p_column)
    into v_rev using p_id, p_op_id;
  if v_rev is not null then
    perform public._personal_emit(p_owner, p_type, p_id, 'upsert', v_rev,
                                  public._personal_row(p_type, p_id), p_op_id);
  end if;
end;
$$;

-- Deletes a row and everything that depends on it, mirroring the phone's
-- foreign keys. Returns the row's new revision.
create or replace function public._personal_delete(p_owner uuid, p_type text, p_id uuid, p_op_id uuid)
returns bigint
language plpgsql security definer set search_path = '' as $$
declare
  r record;
begin
  if p_type = 'person' then
    for r in select id from public.personal_ledger_entries
             where person_id = p_id and owner_id = p_owner and deleted_at is null loop
      perform public._personal_delete(p_owner, 'ledger_entry', r.id, p_op_id);
    end loop;
    for r in select id from public.personal_transactions
             where person_id = p_id and owner_id = p_owner and deleted_at is null loop
      perform public._personal_unlink(p_owner, 'transaction', r.id, 'person_id', p_op_id);
    end loop;
    for r in select id from public.personal_reminders
             where person_id = p_id and owner_id = p_owner and deleted_at is null loop
      perform public._personal_unlink(p_owner, 'reminder', r.id, 'person_id', p_op_id);
    end loop;
  elsif p_type = 'transaction' then
    for r in select id from public.personal_attachments
             where parent_type = 'transaction' and parent_id = p_id and owner_id = p_owner and deleted_at is null loop
      perform public._personal_tombstone(p_owner, 'attachment', r.id, p_op_id);
    end loop;
  elsif p_type = 'ledger_entry' then
    for r in select id from public.personal_ledger_repayments
             where ledger_id = p_id and owner_id = p_owner and deleted_at is null loop
      perform public._personal_tombstone(p_owner, 'ledger_repayment', r.id, p_op_id);
    end loop;
    for r in select id from public.personal_attachments
             where parent_type = 'ledger_entry' and parent_id = p_id and owner_id = p_owner and deleted_at is null loop
      perform public._personal_tombstone(p_owner, 'attachment', r.id, p_op_id);
    end loop;
    for r in select id from public.personal_reminders
             where ledger_entry_id = p_id and owner_id = p_owner and deleted_at is null loop
      perform public._personal_tombstone(p_owner, 'reminder', r.id, p_op_id);
    end loop;
  end if;
  return public._personal_tombstone(p_owner, p_type, p_id, p_op_id);
end;
$$;

-- ------------------------------------------------------ apply_personal_op

-- Applies one client operation:
--   {op_id, entity_type, entity_id, op_type: upsert|delete|reset, base_revision, payload}
-- Returns {status: 'applied', revision} | {status: 'conflict', revision, current}
--       | {status: 'rejected', code}. Re-sending an op_id returns the original
-- result. A row of another user is answered as not_found.
create or replace function public.apply_personal_op(p_op jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_op_id uuid := (p_op ->> 'op_id')::uuid;
  v_type text := p_op ->> 'entity_type';
  v_entity uuid := nullif(p_op ->> 'entity_id', '')::uuid;
  v_kind text := p_op ->> 'op_type';
  v_base bigint := coalesce((p_op ->> 'base_revision')::bigint, 0);
  v_p jsonb := coalesce(p_op -> 'payload', '{}'::jsonb);
  v_table text := public._personal_table(v_type);
  v_result jsonb;
  v_owner uuid;
  v_rev bigint;
  v_deleted timestamptz;
  v_created timestamptz;
  v_row jsonb;
  v_set text;
  v_ok boolean := true;
  v_name text;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if v_op_id is null or v_kind not in ('upsert', 'delete', 'reset') then
    return jsonb_build_object('status', 'rejected', 'code', 'bad_request');
  end if;

  select result into v_result from public.processed_ops where op_id = v_op_id;
  if found then
    return v_result;
  end if;

  if v_kind = 'reset' then
    if v_type <> 'all' then
      return jsonb_build_object('status', 'rejected', 'code', 'bad_request');
    end if;
    foreach v_name in array array['personal_attachments', 'personal_ledger_repayments', 'personal_reminders',
                                  'personal_ledger_entries', 'personal_transactions', 'personal_people'] loop
      execute format('update public.%I set deleted_at = now(), revision = revision + 1, last_op_id = $2,
                      updated_at = now() where owner_id = $1 and deleted_at is null', v_name)
        using v_uid, v_op_id;
    end loop;
    perform public._personal_emit(v_uid, 'all', null, 'reset', 0, '{}'::jsonb, v_op_id);
    v_result := jsonb_build_object('status', 'applied', 'revision', 0);
    insert into public.processed_ops (op_id, user_id, result) values (v_op_id, v_uid, v_result);
    return v_result;
  end if;

  if v_table is null or v_entity is null then
    return jsonb_build_object('status', 'rejected', 'code', 'bad_request');
  end if;

  execute format('select owner_id, revision, deleted_at, created_at from public.%I where id = $1', v_table)
    into v_owner, v_rev, v_deleted, v_created using v_entity;
  if v_owner is not null and v_owner <> v_uid then
    return jsonb_build_object('status', 'rejected', 'code', 'not_found');
  end if;

  if v_kind = 'delete' then
    if v_owner is null then
      -- Never reached the server (or already gone): nothing to delete.
      v_result := jsonb_build_object('status', 'applied', 'revision', 0);
    elsif v_deleted is not null then
      v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);
    elsif v_rev <> v_base then
      return jsonb_build_object('status', 'conflict', 'revision', v_rev,
                                'current', public._personal_row(v_type, v_entity));
    else
      v_rev := public._personal_delete(v_uid, v_type, v_entity, v_op_id);
      v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);
    end if;
    insert into public.processed_ops (op_id, user_id, result) values (v_op_id, v_uid, v_result);
    return v_result;
  end if;

  -- upsert ------------------------------------------------------------------
  if v_owner is not null then
    if v_deleted is not null and v_base = 0 then
      null; -- re-upload of a deleted record (restore): resurrect below
    elsif v_deleted is not null or v_rev <> v_base then
      return jsonb_build_object('status', 'conflict', 'revision', v_rev,
                                'current', public._personal_row(v_type, v_entity));
    end if;
  end if;

  -- Every referenced record must be a live record of the same user.
  if v_type = 'transaction' then
    v_ok := public._personal_owns(v_uid, 'person', (v_p ->> 'person_id')::uuid);
  elsif v_type = 'ledger_entry' then
    v_ok := (v_p ->> 'person_id') is not null
            and public._personal_owns(v_uid, 'person', (v_p ->> 'person_id')::uuid);
  elsif v_type = 'ledger_repayment' then
    v_ok := (v_p ->> 'ledger_id') is not null
            and public._personal_owns(v_uid, 'ledger_entry', (v_p ->> 'ledger_id')::uuid);
  elsif v_type = 'reminder' then
    v_ok := public._personal_owns(v_uid, 'person', (v_p ->> 'person_id')::uuid)
            and public._personal_owns(v_uid, 'ledger_entry', (v_p ->> 'ledger_entry_id')::uuid)
            and ((v_p ->> 'group_id') is null or public.is_group_member((v_p ->> 'group_id')::uuid));
  elsif v_type = 'attachment' then
    v_ok := (v_p ->> 'parent_id') is not null
            and (v_p ->> 'parent_type') in ('transaction', 'ledger_entry')
            and public._personal_owns(v_uid, v_p ->> 'parent_type', (v_p ->> 'parent_id')::uuid);
  end if;
  if not v_ok then
    return jsonb_build_object('status', 'rejected', 'code', 'invalid_reference');
  end if;

  v_rev := coalesce(v_rev, 0) + 1;
  -- Column defaults for fields a client may leave out (jsonb_populate_record
  -- would otherwise write NULL).
  v_row := case v_type
             when 'transaction' then '{"description": ""}'::jsonb
             when 'ledger_entry' then '{"description": ""}'::jsonb
             when 'reminder' then '{"repeat": "none", "completed_occurrences": 0, "status": "pending"}'::jsonb
             else '{}'::jsonb
           end;
  v_row := v_row || v_p || jsonb_build_object(
    'id', v_entity,
    'owner_id', v_uid,
    'revision', v_rev,
    'last_op_id', v_op_id,
    'deleted_at', null,
    'created_at', coalesce(v_created::text, v_p ->> 'created_at', now()::text),
    'updated_at', now());
  if v_type = 'attachment' then
    v_row := v_row || jsonb_build_object('storage_path', v_uid::text || '/' || (v_p ->> 'storage_name'));
  end if;

  select string_agg(format('%1$I = excluded.%1$I', column_name), ', ')
    into v_set
    from information_schema.columns
   where table_schema = 'public' and table_name = v_table
     and column_name not in ('id', 'owner_id', 'created_at');
  execute format('insert into public.%1$I select * from jsonb_populate_record(null::public.%1$I, $1)
                  on conflict (id) do update set %2$s', v_table, v_set)
    using v_row;

  perform public._personal_emit(v_uid, v_type, v_entity, 'upsert', v_rev,
                                public._personal_row(v_type, v_entity), v_op_id);
  v_result := jsonb_build_object('status', 'applied', 'revision', v_rev);
  insert into public.processed_ops (op_id, user_id, result) values (v_op_id, v_uid, v_result);
  return v_result;
exception
  when check_violation or not_null_violation or foreign_key_violation
       or invalid_text_representation or datetime_field_overflow or invalid_datetime_format
       or numeric_value_out_of_range then
    return jsonb_build_object('status', 'rejected', 'code', 'invalid_data');
end;
$$;

-- ---------------------------------------------------------------- snapshot

-- All of the caller's live records (for a new or reset phone) and the feed
-- position to continue from.
create or replace function public.get_personal_snapshot()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  return jsonb_build_object(
    'people', coalesce((select jsonb_agg(to_jsonb(t)) from public.personal_people t
                        where owner_id = v_uid and deleted_at is null), '[]'::jsonb),
    'transactions', coalesce((select jsonb_agg(to_jsonb(t)) from public.personal_transactions t
                              where owner_id = v_uid and deleted_at is null), '[]'::jsonb),
    'ledger_entries', coalesce((select jsonb_agg(to_jsonb(t)) from public.personal_ledger_entries t
                                where owner_id = v_uid and deleted_at is null), '[]'::jsonb),
    'ledger_repayments', coalesce((select jsonb_agg(to_jsonb(t)) from public.personal_ledger_repayments t
                                   where owner_id = v_uid and deleted_at is null), '[]'::jsonb),
    'reminders', coalesce((select jsonb_agg(to_jsonb(t)) from public.personal_reminders t
                           where owner_id = v_uid and deleted_at is null), '[]'::jsonb),
    'attachments', coalesce((select jsonb_agg(to_jsonb(t)) from public.personal_attachments t
                             where owner_id = v_uid and deleted_at is null), '[]'::jsonb),
    'max_seq', coalesce((select max(seq) from public.personal_sync_events where owner_id = v_uid), 0)
  );
end;
$$;

-- ----------------------------------------------------------------- grants

revoke execute on function
  public._personal_table(text),
  public._personal_emit(uuid, text, uuid, text, bigint, jsonb, uuid),
  public._personal_row(text, uuid),
  public._personal_owns(uuid, text, uuid),
  public._personal_tombstone(uuid, text, uuid, uuid),
  public._personal_unlink(uuid, text, uuid, text, uuid),
  public._personal_delete(uuid, text, uuid, uuid),
  public.apply_personal_op(jsonb),
  public.get_personal_snapshot()
  from public, anon, authenticated;
grant execute on function public.apply_personal_op(jsonb), public.get_personal_snapshot() to authenticated;
