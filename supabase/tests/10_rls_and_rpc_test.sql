-- Executable security & behaviour tests for the HisabMitra cloud schema.
-- Run with: tool/run_supabase_tests.sh  (disposable PostgreSQL container)
-- Every check raises an exception on failure, so psql exits non-zero.
\set ON_ERROR_STOP 1
set client_min_messages = notice;

-- Users: A = group owner, B = invitee, C = outsider.
insert into auth.users (id, phone) values
  ('aaaaaaaa-0000-0000-0000-000000000001', '+919800000001'),
  ('bbbbbbbb-0000-0000-0000-000000000002', '+919800000002'),
  ('cccccccc-0000-0000-0000-000000000003', '+919800000003');

create or replace function pg_temp.as_user(p_uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', coalesce(p_uid, ''), false);
end $$;

create or replace function pg_temp.ok(p_cond boolean, p_msg text) returns void language plpgsql as $$
begin
  if p_cond is distinct from true then raise exception 'ASSERTION FAILED: %', p_msg; end if;
  raise notice 'ok - %', p_msg;
end $$;

create or replace function pg_temp.fails(p_sql text, p_expected text, p_msg text) returns void language plpgsql as $$
begin
  begin
    execute p_sql;
  exception when others then
    if position(p_expected in sqlerrm) > 0 then
      raise notice 'ok - % (got: %)', p_msg, sqlerrm;
      return;
    end if;
    raise exception 'ASSERTION FAILED: % (expected "%", got "%")', p_msg, p_expected, sqlerrm;
  end;
  raise exception 'ASSERTION FAILED: % (no error raised)', p_msg;
end $$;

grant execute on all functions in schema pg_temp to authenticated, anon;

-- IDs
-- group G, owner member MA, local participant MB, expense E, settlement S
\set G '''11111111-1111-1111-1111-111111111111'''
\set MA '''22222222-2222-2222-2222-222222222221'''
\set MB '''22222222-2222-2222-2222-222222222222'''
\set E '''33333333-3333-3333-3333-333333333333'''

set role authenticated;

-- 1. Owner creates a shared group (with own member record) -------------
select pg_temp.as_user('aaaaaaaa-0000-0000-0000-000000000001');
do $$
declare r jsonb; r2 jsonb;
begin
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000001', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'group', 'entity_id', '11111111-1111-1111-1111-111111111111', 'op_type', 'upsert',
    'base_revision', 0, 'payload', jsonb_build_object('name', 'Goa trip', 'group_type', 'trip',
    'owner_member_id', '22222222-2222-2222-2222-222222222221', 'owner_display_name', 'Amit')));
  perform pg_temp.ok(r ->> 'status' = 'applied', 'owner creates group');
  r2 := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000001', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'group', 'entity_id', '11111111-1111-1111-1111-111111111111', 'op_type', 'upsert',
    'base_revision', 0, 'payload', '{}'::jsonb));
  perform pg_temp.ok(r2 = r, 'replaying the same op_id is idempotent');
  perform pg_temp.ok((select count(*) from public.sync_events) = 2, 'replay emitted no duplicate events');
  perform pg_temp.ok(public.is_group_admin('11111111-1111-1111-1111-111111111111'), 'creator is owner/admin');
end $$;

-- 2. Local participant + expense with exact reconciliation -------------
do $$
declare r jsonb;
begin
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000002', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'member', 'entity_id', '22222222-2222-2222-2222-222222222222', 'op_type', 'upsert',
    'base_revision', 0, 'payload', jsonb_build_object('display_name', 'Bhavna', 'sort_order', 1,
    'user_id', 'cccccccc-0000-0000-0000-000000000003')));
  perform pg_temp.ok(r ->> 'status' = 'applied', 'owner adds a local participant');
  perform pg_temp.ok((select user_id from public.group_members where id = '22222222-2222-2222-2222-222222222222') is null,
    'client cannot link a participant to someone else''s account');

  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000003', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'expense', 'entity_id', '33333333-3333-3333-3333-333333333333', 'op_type', 'upsert',
    'base_revision', 0, 'payload', jsonb_build_object('description', 'Hotel', 'category_key', 'stay',
    'amount_paise', 100000, 'paid_by_member_id', '22222222-2222-2222-2222-222222222221',
    'expense_date', '2026-11-01', 'split_method', 'equal', 'splits', jsonb_build_array(
      jsonb_build_object('id', '44444444-4444-4444-4444-444444444441', 'member_id', '22222222-2222-2222-2222-222222222221', 'share_paise', 50000),
      jsonb_build_object('id', '44444444-4444-4444-4444-444444444442', 'member_id', '22222222-2222-2222-2222-222222222222', 'share_paise', 50000)))));
  perform pg_temp.ok(r ->> 'status' = 'applied' and (r ->> 'revision')::int = 1, 'member adds a reconciled expense');

  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000004', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'expense', 'entity_id', '33333333-3333-3333-3333-333333333334', 'op_type', 'upsert',
    'base_revision', 0, 'payload', jsonb_build_object('description', 'Bad', 'category_key', 'food',
    'amount_paise', 1000, 'paid_by_member_id', '22222222-2222-2222-2222-222222222221',
    'expense_date', '2026-11-01', 'split_method', 'exact', 'splits', jsonb_build_array(
      jsonb_build_object('id', '44444444-4444-4444-4444-444444444443', 'member_id', '22222222-2222-2222-2222-222222222221', 'share_paise', 400)))));
  perform pg_temp.ok(r ->> 'code' = 'split_mismatch', 'split that does not add up is rejected');

  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000005', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'expense', 'entity_id', '33333333-3333-3333-3333-333333333335', 'op_type', 'upsert',
    'base_revision', 0, 'payload', jsonb_build_object('description', 'Neg', 'category_key', 'food',
    'amount_paise', -5, 'paid_by_member_id', '22222222-2222-2222-2222-222222222221',
    'expense_date', '2026-11-01', 'split_method', 'exact', 'splits', jsonb_build_array(
      jsonb_build_object('id', '44444444-4444-4444-4444-444444444444', 'member_id', '22222222-2222-2222-2222-222222222221', 'share_paise', -5)))));
  perform pg_temp.ok(r ->> 'status' = 'rejected', 'negative amounts are rejected by constraints');
end $$;

-- 3. Outsider sees nothing and cannot write ----------------------------
select pg_temp.as_user('cccccccc-0000-0000-0000-000000000003');
do $$
declare r jsonb;
begin
  perform pg_temp.ok((select count(*) from public.groups) = 0, 'outsider sees no groups');
  perform pg_temp.ok((select count(*) from public.group_expenses) = 0, 'outsider sees no expenses');
  perform pg_temp.ok((select count(*) from public.group_expense_splits) = 0, 'outsider sees no splits');
  perform pg_temp.ok((select count(*) from public.group_members) = 0, 'outsider sees no members');
  perform pg_temp.ok((select count(*) from public.sync_events) = 0, 'outsider sees no change events');
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000006', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'expense', 'entity_id', '33333333-3333-3333-3333-333333333336', 'op_type', 'upsert',
    'base_revision', 0, 'payload', '{}'::jsonb));
  perform pg_temp.ok(r ->> 'code' = 'forbidden', 'outsider cannot add expenses');
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000007', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'group', 'entity_id', '11111111-1111-1111-1111-111111111111', 'op_type', 'upsert',
    'base_revision', 1, 'payload', jsonb_build_object('name', 'Hijacked', 'group_type', 'trip')));
  perform pg_temp.ok(r ->> 'code' = 'forbidden', 'outsider cannot rename the group');
end $$;
select pg_temp.fails($$select public.get_group_snapshot('11111111-1111-1111-1111-111111111111')$$, 'forbidden',
  'outsider cannot read a group snapshot');
select pg_temp.fails($$insert into public.group_expenses (id, group_id, description, category_key, amount_paise,
  paid_by_member_id, expense_date, split_method) values (gen_random_uuid(), '11111111-1111-1111-1111-111111111111',
  'x', 'food', 1, '22222222-2222-2222-2222-222222222221', '2026-01-01', 'equal')$$, 'permission denied',
  'direct table writes are denied');
select pg_temp.ok((select count(*) from public.processed_ops) = 0, 'idempotency log is not readable by clients');

-- 4. Invitations --------------------------------------------------------
select pg_temp.as_user('aaaaaaaa-0000-0000-0000-000000000001');
create temp table invite as
  select public.create_group_invitation('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222') as inv;
select pg_temp.ok(length((select inv ->> 'code' from invite)) = 10, 'owner creates a 10-character invitation code');
select pg_temp.fails($$select public.create_group_invitation('11111111-1111-1111-1111-111111111111',
  '22222222-2222-2222-2222-222222222222')$$, 'invitation_pending', 'duplicate pending invitation is prevented');
select pg_temp.ok((select count(*) from public.group_invitations where code_hash = (select inv ->> 'code' from invite)) = 0,
  'only a hash of the code is stored');

select pg_temp.as_user('bbbbbbbb-0000-0000-0000-000000000002');
select pg_temp.fails($$select public.create_group_invitation('11111111-1111-1111-1111-111111111111')$$, 'forbidden',
  'non-member cannot create invitations');
select pg_temp.fails($$select public.accept_group_invitation('WRONGCODE1', 'Bhavna')$$, 'invalid_code',
  'wrong code is rejected');
do $$
declare r jsonb;
begin
  r := public.accept_group_invitation((select lower(inv ->> 'code') from invite), 'Bhavna');
  perform pg_temp.ok(r ->> 'member_id' = '22222222-2222-2222-2222-222222222222',
    'invitee takes over the invited participant record (code is case-insensitive)');
  perform pg_temp.ok((select count(*) from public.groups) = 1, 'invitee now sees the group');
  perform pg_temp.ok((select count(*) from public.group_expense_splits) = 2, 'invitee sees the splits');
  perform pg_temp.ok((public.get_group_snapshot('11111111-1111-1111-1111-111111111111') -> 'expenses' -> 0 ->> 'amount_paise')::bigint = 100000,
    'invitee can load the group snapshot');
end $$;
select pg_temp.fails($$select public.accept_group_invitation((select inv ->> 'code' from invite), 'Again')$$,
  'invalid_code', 'an invitation cannot be used twice');

-- 5. Optimistic concurrency ---------------------------------------------
do $$
declare r jsonb;
  v_payload jsonb := jsonb_build_object('description', 'Hotel + breakfast', 'category_key', 'stay',
    'amount_paise', 120000, 'paid_by_member_id', '22222222-2222-2222-2222-222222222221',
    'expense_date', '2026-11-01', 'split_method', 'equal', 'splits', jsonb_build_array(
      jsonb_build_object('id', '44444444-4444-4444-4444-444444444451', 'member_id', '22222222-2222-2222-2222-222222222221', 'share_paise', 60000),
      jsonb_build_object('id', '44444444-4444-4444-4444-444444444452', 'member_id', '22222222-2222-2222-2222-222222222222', 'share_paise', 60000)));
begin
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000010', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'expense', 'entity_id', '33333333-3333-3333-3333-333333333333', 'op_type', 'upsert',
    'base_revision', 1, 'payload', v_payload));
  perform pg_temp.ok(r ->> 'status' = 'applied' and (r ->> 'revision')::int = 2, 'member edits with the current revision');
end $$;

select pg_temp.as_user('aaaaaaaa-0000-0000-0000-000000000001');
do $$
declare r jsonb;
begin
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000011', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'expense', 'entity_id', '33333333-3333-3333-3333-333333333333', 'op_type', 'delete',
    'base_revision', 1, 'payload', '{}'::jsonb));
  perform pg_temp.ok(r ->> 'status' = 'conflict' and (r ->> 'revision')::int = 2, 'stale delete is reported as a conflict');
  perform pg_temp.ok((r -> 'current' ->> 'amount_paise')::bigint = 120000, 'conflict carries the current server version');
  perform pg_temp.ok((select deleted_at from public.group_expenses where id = '33333333-3333-3333-3333-333333333333') is null,
    'conflicting change is not applied');
end $$;

-- 6. Settlements are immutable; members in use cannot be removed --------
do $$
declare r jsonb;
begin
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000020', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'settlement', 'entity_id', '55555555-5555-5555-5555-555555555555', 'op_type', 'upsert',
    'base_revision', 0, 'payload', jsonb_build_object('from_member_id', '22222222-2222-2222-2222-222222222222',
    'to_member_id', '22222222-2222-2222-2222-222222222221', 'amount_paise', 20000, 'settled_on', '2026-11-02',
    'payment_method', 'upi')));
  perform pg_temp.ok(r ->> 'status' = 'applied', 'settlement is recorded');
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000021', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'settlement', 'entity_id', '55555555-5555-5555-5555-555555555555', 'op_type', 'upsert',
    'base_revision', 1, 'payload', jsonb_build_object('from_member_id', '22222222-2222-2222-2222-222222222222',
    'to_member_id', '22222222-2222-2222-2222-222222222221', 'amount_paise', 1, 'settled_on', '2026-11-02',
    'payment_method', 'upi')));
  perform pg_temp.ok(r ->> 'code' = 'unsupported', 'recorded settlements cannot be edited');
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000022', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'member', 'entity_id', '22222222-2222-2222-2222-222222222222', 'op_type', 'delete',
    'base_revision', 2, 'payload', '{}'::jsonb));
  perform pg_temp.ok(r ->> 'code' = 'member_in_use', 'member with history cannot be removed');
end $$;

select pg_temp.as_user('bbbbbbbb-0000-0000-0000-000000000002');
do $$
declare r jsonb;
begin
  r := public.apply_group_op(jsonb_build_object(
    'op_id', '90000000-0000-0000-0000-000000000030', 'group_id', '11111111-1111-1111-1111-111111111111',
    'entity_type', 'group', 'entity_id', '11111111-1111-1111-1111-111111111111', 'op_type', 'upsert',
    'base_revision', 1, 'payload', jsonb_build_object('name', 'Renamed', 'group_type', 'trip')));
  perform pg_temp.ok(r ->> 'code' = 'forbidden', 'regular member cannot change group settings');
end $$;
select pg_temp.fails($$select public.cancel_group_invitation((select (inv ->> 'invitation_id')::uuid from invite))$$,
  'forbidden', 'regular member cannot cancel invitations');

-- 7. Expired invitations -------------------------------------------------
select pg_temp.as_user('aaaaaaaa-0000-0000-0000-000000000001');
create temp table invite2 as select public.create_group_invitation('11111111-1111-1111-1111-111111111111') as inv;
reset role;
update public.group_invitations set expires_at = now() - interval '1 minute'
  where id = (select (inv ->> 'invitation_id')::uuid from invite2);
set role authenticated;
select pg_temp.as_user('cccccccc-0000-0000-0000-000000000003');
select pg_temp.fails($$select public.accept_group_invitation((select inv ->> 'code' from invite2), 'Chetan')$$,
  'expired', 'expired invitation is rejected');

-- 8. Anonymous access ----------------------------------------------------
reset role;
set role anon;
select pg_temp.as_user(null);
select pg_temp.fails($$select count(*) from public.groups$$, 'permission denied', 'anon cannot read tables');
select pg_temp.fails($$select public.apply_group_op('{}'::jsonb)$$, 'permission denied', 'anon cannot call RPCs');

-- 9. Account deletion keeps shared history ------------------------------
reset role;
set role authenticated;
select pg_temp.as_user('aaaaaaaa-0000-0000-0000-000000000001');
select public.prepare_account_deletion();
reset role;
select pg_temp.ok((select owner_id from public.groups where id = '11111111-1111-1111-1111-111111111111')
  = 'bbbbbbbb-0000-0000-0000-000000000002', 'ownership passes to the remaining account holder');
select pg_temp.ok((select user_id from public.group_members where id = '22222222-2222-2222-2222-222222222221') is null,
  'deleted user becomes a plain participant');
select pg_temp.ok((select count(*) from public.group_expenses where deleted_at is null) = 1, 'expense history is kept');

-- 10. API surface: only the intended RPCs and tables are reachable --------
reset role;
select pg_temp.ok(not exists (
  select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and has_function_privilege('anon', p.oid, 'execute')
), 'anon cannot execute any public function');
select pg_temp.ok(not exists (
  select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname like '\_%'
    and has_function_privilege('authenticated', p.oid, 'execute')
), 'internal _helpers (e.g. _emit) are not callable by signed-in users');
set role authenticated;
select pg_temp.as_user('cccccccc-0000-0000-0000-000000000003');
select pg_temp.fails($$select public._emit('11111111-1111-1111-1111-111111111111', 'expense',
  gen_random_uuid(), 'upsert', 1, '{}'::jsonb, gen_random_uuid())$$,
  'permission denied', 'an outsider cannot inject sync events');
reset role;
select pg_temp.ok(not exists (
  select 1 from information_schema.role_table_grants
  where grantee = 'authenticated' and table_schema = 'public'
    and privilege_type <> 'SELECT'
    and not (table_name = 'user_profiles' and privilege_type in ('INSERT', 'UPDATE'))
    and not (table_name = 'user_devices' and privilege_type in ('INSERT', 'UPDATE', 'DELETE'))
), 'signed-in users only read tables, and write just their profile and devices');

-- 11. Profiles: compulsory phone, owner-only -----------------------------
set role authenticated;
select pg_temp.as_user('bbbbbbbb-0000-0000-0000-000000000002');
select pg_temp.fails($$insert into public.user_profiles (id, display_name)
  values ('bbbbbbbb-0000-0000-0000-000000000002', 'Bhavna')$$,
  'null value', 'a profile needs a mobile number');
select pg_temp.fails($$insert into public.user_profiles (id, display_name, phone)
  values ('bbbbbbbb-0000-0000-0000-000000000002', 'Bhavna', '98765')$$,
  'user_profiles_phone_e164', 'the mobile number must be in +E.164 form');
insert into public.user_profiles (id, display_name, phone)
  values ('bbbbbbbb-0000-0000-0000-000000000002', 'Bhavna', '+919876543210');
select pg_temp.ok((select phone from public.user_profiles
  where id = 'bbbbbbbb-0000-0000-0000-000000000002') = '+919876543210', 'own profile stores the phone');
select pg_temp.fails($$insert into public.user_profiles (id, display_name, phone)
  values ('cccccccc-0000-0000-0000-000000000003', 'X', '+919876543211')$$,
  'row-level security', 'nobody can create a profile for someone else');
select pg_temp.as_user('cccccccc-0000-0000-0000-000000000003');
select pg_temp.ok((select count(*) from public.user_profiles
  where id = 'bbbbbbbb-0000-0000-0000-000000000002') = 0, 'another user cannot read the phone');
reset role;

\echo 'ALL CLOUD TESTS PASSED'
