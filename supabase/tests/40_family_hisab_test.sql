-- Executable tests for Family hisab (app 1.3.0, phase 2).
-- Run with: tool/run_supabase_tests.sh (after 10_rls_and_rpc_test.sql, whose
-- users A and B exist). Every check raises on failure.
\set ON_ERROR_STOP 1
set client_min_messages = notice;

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

-- One client operation on a Family hisab.
create or replace function pg_temp.fop(
  p_op text, p_family text, p_type text, p_entity text, p_kind text, p_base int, p_payload jsonb
) returns jsonb language sql as $$
  select public.apply_family_op(jsonb_build_object(
    'op_id', p_op, 'family_id', p_family, 'entity_type', p_type, 'entity_id', p_entity,
    'op_type', p_kind, 'base_revision', p_base, 'payload', p_payload))
$$;

grant execute on all functions in schema pg_temp to authenticated, anon;

\set A '''aaaaaaaa-0000-0000-0000-000000000001'''
\set B '''bbbbbbbb-0000-0000-0000-000000000002'''
\set H '''f1000000-0000-0000-0000-000000000001'''
\set H2 '''f1000000-0000-0000-0000-000000000002'''
\set YOU '''f2000000-0000-0000-0000-000000000001'''
\set RAHUL '''f2000000-0000-0000-0000-000000000002'''
\set OTHER '''f2000000-0000-0000-0000-000000000003'''
\set E1 '''f3000000-0000-0000-0000-000000000001'''
\set E2 '''f3000000-0000-0000-0000-000000000002'''

set role authenticated;

-- 1. Creating a Family hisab -------------------------------------------------------------
select pg_temp.as_user(:A);
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000001', :H, 'family', :H, 'upsert', 0,
    jsonb_build_object('name', 'Home', 'opening_balance_paise', 1200000,
      'owner_member_id', :YOU, 'owner_display_name', 'Hemang'))
  = '{"status": "applied", "revision": 1}'::jsonb, 'a Family hisab is created');
select pg_temp.ok((select role = 'owner' and user_id = :A from public.family_members where id = :YOU),
  'the creator is its owner member');
select pg_temp.ok((select count(*) from public.family_sync_events where family_id = :H) = 2,
  'creating emits the Family hisab and the owner member');
select pg_temp.ok((select opening_balance_paise from public.family_hisabs where id = :H) = 1200000,
  'the starting balance is saved');

-- 2. People and entries ------------------------------------------------------------------
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000002', :H, 'member', :RAHUL, 'upsert', 0,
    '{"name": "Rahul Patel", "phone": "+919800000001", "sort_order": 1}')
  ->> 'status' = 'applied', 'a person is added by name and number');
select pg_temp.ok((select user_id is null and role = 'member' from public.family_members where id = :RAHUL),
  'a person added by number has no account');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000003', :H, 'entry', :E1, 'upsert', 0,
    jsonb_build_object('member_id', :YOU, 'kind', 'salary', 'amount_paise', 6000000,
      'entry_date', '2026-11-01'))
  ->> 'status' = 'applied', 'money in is recorded');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000004', :H, 'entry', :E2, 'upsert', 0,
    jsonb_build_object('member_id', :RAHUL, 'kind', 'expense', 'amount_paise', 750000,
      'entry_date', '2026-11-05', 'category_id', 'cat_rent', 'category_name', 'Rent',
      'category_name_gu', 'ભાડું', 'category_icon', 'home', 'category_color', 4283341407))
  ->> 'status' = 'applied', 'money out is recorded with its category');
select pg_temp.ok((select created_by = :A from public.family_entries where id = :E2),
  'the entry remembers who wrote it');

-- 3. Only members ------------------------------------------------------------------------
select pg_temp.as_user(:B);
select pg_temp.ok((select count(*) from public.family_hisabs) = 0, 'a non-member sees no Family hisab');
select pg_temp.ok((select count(*) from public.family_entries) = 0, 'a non-member sees no entries');
select pg_temp.ok((select count(*) from public.family_sync_events) = 0, 'a non-member sees no events');
select pg_temp.ok(
  pg_temp.fop('c2000000-0000-0000-0000-000000000001', :H, 'entry', 'f3000000-0000-0000-0000-000000000009',
    'upsert', 0, jsonb_build_object('member_id', :RAHUL, 'kind', 'salary', 'amount_paise', 100,
      'entry_date', '2026-11-01'))
  = '{"status": "rejected", "code": "forbidden"}'::jsonb, 'a non-member cannot write');
select pg_temp.fails(format('select public.get_family_snapshot(%L)', :H), 'forbidden',
  'a non-member cannot read the snapshot');
select pg_temp.as_user(null);
select pg_temp.fails($$select pg_temp.fop('c2000000-0000-0000-0000-000000000002',
  'f1000000-0000-0000-0000-000000000001', 'entry', 'f3000000-0000-0000-0000-000000000009', 'upsert', 0, '{}')$$,
  'not_authenticated', 'signed-out callers are refused');

-- 4. Validation, retries and conflicts ---------------------------------------------------
select pg_temp.as_user(:A);
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000005', :H, 'entry', 'f3000000-0000-0000-0000-000000000005',
    'upsert', 0, jsonb_build_object('member_id', :YOU, 'kind', 'expense', 'amount_paise', 100,
      'entry_date', '2026-11-01'))
  = '{"status": "rejected", "code": "invalid_data"}'::jsonb, 'money out needs a category');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000006', :H, 'entry', 'f3000000-0000-0000-0000-000000000006',
    'upsert', 0, jsonb_build_object('member_id', :YOU, 'kind', 'salary', 'amount_paise', 0,
      'entry_date', '2026-11-01'))
  = '{"status": "rejected", "code": "invalid_data"}'::jsonb, 'an amount must be more than zero');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000007', :H2, 'family', :H2, 'upsert', 0,
    jsonb_build_object('name', 'Village house', 'owner_member_id', :OTHER, 'owner_display_name', 'Hemang'))
  ->> 'status' = 'applied', 'a second Family hisab is created');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000008', :H, 'entry', 'f3000000-0000-0000-0000-000000000008',
    'upsert', 0, jsonb_build_object('member_id', :OTHER, 'kind', 'salary', 'amount_paise', 100,
      'entry_date', '2026-11-01'))
  = '{"status": "rejected", "code": "invalid_reference"}'::jsonb,
  'a person of another Family hisab is refused');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000003', :H, 'entry', :E1, 'upsert', 0, '{}')
  = '{"status": "applied", "revision": 1}'::jsonb, 'a replayed op returns its first result');
select pg_temp.ok((select count(*) from public.family_sync_events where entity_id = :E1) = 1,
  'a replayed op emits nothing');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000009', :H, 'entry', :E1, 'upsert', 1,
    jsonb_build_object('member_id', :YOU, 'kind', 'salary', 'amount_paise', 6500000,
      'entry_date', '2026-11-01'))
  = '{"status": "applied", "revision": 2}'::jsonb, 'an entry is edited');
select pg_temp.ok(
  (pg_temp.fop('c1000000-0000-0000-0000-000000000010', :H, 'entry', :E1, 'upsert', 1,
    jsonb_build_object('member_id', :YOU, 'kind', 'salary', 'amount_paise', 1,
      'entry_date', '2026-11-01')) ->> 'status') = 'conflict', 'a stale edit is a conflict');
select pg_temp.ok(
  (pg_temp.fop('c1000000-0000-0000-0000-000000000011', :H, 'entry', :E1, 'upsert', 1,
    jsonb_build_object('member_id', :YOU, 'kind', 'salary', 'amount_paise', 1,
      'entry_date', '2026-11-01')) -> 'current' ->> 'amount_paise')::bigint = 6500000,
  'the conflict carries the current row');

-- 5. Removing people ---------------------------------------------------------------------
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000012', :H, 'member', :RAHUL, 'delete', 1, '{}')
  ->> 'status' = 'applied', 'a person can be deleted');
select pg_temp.ok((select status = 'removed' and deleted_at is not null from public.family_members where id = :RAHUL),
  'the person is marked removed');
select pg_temp.ok((select deleted_at is null from public.family_entries where id = :E2),
  'their entries stay');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000013', :H, 'member', :YOU, 'delete', 1, '{}')
  = '{"status": "rejected", "code": "forbidden"}'::jsonb, 'the owner member cannot be deleted');

-- 6. Snapshot ----------------------------------------------------------------------------
select pg_temp.ok(public.get_family_snapshot(:H) -> 'family' ->> 'name' = 'Home', 'the snapshot has the Family hisab');
select pg_temp.ok(jsonb_array_length(public.get_family_snapshot(:H) -> 'members') = 2,
  'the snapshot keeps removed people (for old entries)');
select pg_temp.ok(jsonb_array_length(public.get_family_snapshot(:H) -> 'entries') = 2,
  'the snapshot has the live entries');
select pg_temp.ok((public.get_family_snapshot(:H) ->> 'max_seq')::bigint
  = (select max(seq) from public.family_sync_events where family_id = :H), 'the snapshot reports its latest event');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000014', :H, 'entry', :E2, 'delete', 1, '{}')
  ->> 'status' = 'applied', 'an entry can be deleted');
select pg_temp.ok(jsonb_array_length(public.get_family_snapshot(:H) -> 'entries') = 1,
  'a deleted entry leaves the snapshot');

-- 7. Deleting a Family hisab -------------------------------------------------------------
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000015', :H2, 'family', :H2, 'delete', 1, '{}')
  ->> 'status' = 'applied', 'the owner can delete a Family hisab');
select pg_temp.ok(
  (select count(*) from public.family_sync_events
   where family_id = :H2 and entity_type = 'family' and op_type = 'delete') = 1,
  'members still see that it was deleted (so their other phones remove it)');
select pg_temp.ok((select count(*) from public.family_hisabs where id = :H2) = 0,
  'a deleted Family hisab is no longer readable');
select pg_temp.ok(
  pg_temp.fop('c1000000-0000-0000-0000-000000000016', :H2, 'entry', 'f3000000-0000-0000-0000-000000000016',
    'upsert', 0, jsonb_build_object('member_id', :OTHER, 'kind', 'salary', 'amount_paise', 100,
      'entry_date', '2026-11-01'))
  ->> 'code' = 'forbidden', 'nothing can be added to a deleted Family hisab');
select pg_temp.as_user(:B);
select pg_temp.ok((select count(*) from public.family_sync_events where family_id = :H2) = 0,
  'a non-member never sees its events');
reset role;

\echo 'ALL FAMILY HISAB TESTS PASSED'
