-- Executable tests for personal data in the cloud (Part B).
-- Run with: tool/run_supabase_tests.sh (after 10_rls_and_rpc_test.sql, whose
-- users and group G exist). Every check raises on failure.
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

-- One client operation: apply_personal_op({op_id, entity_type, entity_id,
-- op_type, base_revision, payload}).
create or replace function pg_temp.op(
  p_op text, p_type text, p_entity text, p_kind text, p_base int, p_payload jsonb
) returns jsonb language sql as $$
  select public.apply_personal_op(jsonb_build_object(
    'op_id', p_op, 'entity_type', p_type, 'entity_id', p_entity,
    'op_type', p_kind, 'base_revision', p_base, 'payload', p_payload))
$$;

grant execute on all functions in schema pg_temp to authenticated, anon;

\set A '''aaaaaaaa-0000-0000-0000-000000000001'''
\set B '''bbbbbbbb-0000-0000-0000-000000000002'''
\set P1 '''44444444-0000-0000-0000-000000000001'''
\set P2 '''44444444-0000-0000-0000-000000000002'''
\set T1 '''55555555-0000-0000-0000-000000000001'''
\set L1 '''66666666-0000-0000-0000-000000000001'''
\set R1 '''77777777-0000-0000-0000-000000000001'''
\set M1 '''88888888-0000-0000-0000-000000000001'''
\set F1 '''99999999-0000-0000-0000-000000000001'''

set role authenticated;

-- 1. Creating records ------------------------------------------------------
select pg_temp.as_user(:A);
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000001', 'person', :P1, 'upsert', 0,
             '{"name": "Rahul Patel", "phone": "+919800000010"}')
  = '{"status": "applied", "revision": 1}'::jsonb, 'a person is created at revision 1');
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000001', 'person', :P1, 'upsert', 0,
             '{"name": "Rahul Patel", "phone": "+919800000010"}')
  = '{"status": "applied", "revision": 1}'::jsonb, 'replaying the same op returns the same result');
select pg_temp.ok((select count(*) from public.personal_sync_events
  where entity_id = :P1) = 1, 'a replayed op emits no second event');

select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000002', 'transaction', :T1, 'upsert', 0,
    jsonb_build_object('type', 'expense', 'amount_paise', 25000, 'category_id', 'cat_groceries',
      'category_name', 'Groceries', 'category_system_key', 'groceries',
      'category_icon', 'grocery', 'category_color', 4283341407,
      'txn_date', '2026-11-20', 'payment_method', 'upi', 'person_id', :P1,
      'description', 'Vegetables'))
  ->> 'status' = 'applied', 'an expense with its category snapshot is created');
select pg_temp.ok((select category_name from public.personal_transactions where id = :T1) = 'Groceries',
  'the category snapshot is stored');

select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000003', 'ledger_entry', :L1, 'upsert', 0,
    jsonb_build_object('person_id', :P1, 'direction', 'given', 'principal_paise', 300000,
      'entry_date', '2026-11-01', 'payment_method', 'cash'))
  ->> 'status' = 'applied', 'a khata entry is created');
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000004', 'ledger_repayment', :R1, 'upsert', 0,
    jsonb_build_object('ledger_id', :L1, 'amount_paise', 100000,
      'settled_on', '2026-11-10', 'payment_method', 'upi'))
  ->> 'status' = 'applied', 'a repayment is created');
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000005', 'reminder', :M1, 'upsert', 0,
    jsonb_build_object('kind', 'collection', 'title', 'Collect from Rahul',
      'due_at', '2026-11-25T04:30:00Z', 'repeat', 'none', 'person_id', :P1,
      'ledger_entry_id', :L1, 'status', 'pending', 'completed_occurrences', 0))
  ->> 'status' = 'applied', 'a reminder is created');
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000006', 'attachment', :F1, 'upsert', 0,
    jsonb_build_object('parent_type', 'transaction', 'parent_id', :T1,
      'storage_name', '99999999-0000-0000-0000-000000000001.jpg', 'original_name', 'bill.jpg',
      'mime_type', 'image/jpeg', 'size_bytes', 2048, 'sha256', repeat('a', 64)))
  ->> 'status' = 'applied', 'a bill record is created');
select pg_temp.ok((select storage_path from public.personal_attachments where id = :F1)
  = 'aaaaaaaa-0000-0000-0000-000000000001/99999999-0000-0000-0000-000000000001.jpg',
  'the server sets the storage path inside the owner''s folder');

-- 2. Revisions and conflicts -------------------------------------------------
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000007', 'person', :P1, 'upsert', 1,
             '{"name": "Rahul Patel", "phone": "+919800000011"}')
  = '{"status": "applied", "revision": 2}'::jsonb, 'an edit on the current revision applies');
select pg_temp.ok(
  (pg_temp.op('a0000000-0000-0000-0000-000000000008', 'person', :P1, 'upsert', 1,
              '{"name": "Rahul P."}') ->> 'status') = 'conflict',
  'an edit on an old revision is a conflict');
select pg_temp.ok(
  (pg_temp.op('a0000000-0000-0000-0000-000000000009', 'person', :P1, 'upsert', 1,
              '{"name": "Rahul P."}') -> 'current' ->> 'name') = 'Rahul Patel',
  'the conflict carries the server version');

-- 3. Validation -----------------------------------------------------------------
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000010', 'transaction',
    '55555555-0000-0000-0000-000000000009', 'upsert', 0,
    jsonb_build_object('type', 'expense', 'amount_paise', 0, 'category_id', 'cat_groceries',
      'category_name', 'Groceries', 'category_icon', 'grocery', 'category_color', 1,
      'txn_date', '2026-11-20', 'payment_method', 'upi'))
  ->> 'code' = 'invalid_data', 'an amount of zero is rejected');
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000011', 'reminder',
    '88888888-0000-0000-0000-000000000009', 'upsert', 0,
    jsonb_build_object('kind', 'custom', 'title', 'X', 'due_at', '2026-11-25T04:30:00Z',
      'repeat', 'none', 'status', 'pending', 'completed_occurrences', 0,
      'group_id', 'dddddddd-0000-0000-0000-000000000000'))
  ->> 'code' = 'invalid_reference', 'a reminder cannot point at a group the user is not in');

-- 4. Other users ------------------------------------------------------------------
select pg_temp.as_user(:B);
select pg_temp.ok((select count(*) from public.personal_people) = 0, 'another user sees no people');
select pg_temp.ok((select count(*) from public.personal_transactions) = 0, 'another user sees no entries');
select pg_temp.ok((select count(*) from public.personal_sync_events) = 0, 'another user sees no events');
select pg_temp.ok(
  pg_temp.op('b0000000-0000-0000-0000-000000000001', 'person', :P1, 'upsert', 2, '{"name": "Mine now"}')
  ->> 'code' = 'not_found', 'another user cannot change someone''s person');
select pg_temp.ok(
  pg_temp.op('b0000000-0000-0000-0000-000000000002', 'transaction',
    '55555555-0000-0000-0000-000000000002', 'upsert', 0,
    jsonb_build_object('type', 'expense', 'amount_paise', 100, 'category_id', 'cat_groceries',
      'category_name', 'Groceries', 'category_icon', 'grocery', 'category_color', 1,
      'txn_date', '2026-11-20', 'payment_method', 'upi', 'person_id', :P1))
  ->> 'code' = 'invalid_reference', 'an entry cannot point at someone else''s person');
select pg_temp.fails($$insert into public.personal_people (id, owner_id, name)
  values (gen_random_uuid(), 'bbbbbbbb-0000-0000-0000-000000000002', 'X')$$,
  'permission denied', 'clients cannot write personal tables directly');
select pg_temp.as_user(null);
select pg_temp.fails($$select pg_temp.op('c0000000-0000-0000-0000-000000000001', 'person',
  '44444444-0000-0000-0000-000000000003', 'upsert', 0, '{"name": "X"}')$$,
  'not_authenticated', 'signed-out callers are refused');

-- 5. Linked deletes ------------------------------------------------------------------
select pg_temp.as_user(:A);
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000012', 'person', :P1, 'delete', 2, '{}')
  = '{"status": "applied", "revision": 3}'::jsonb, 'deleting a person applies');
select pg_temp.ok((select deleted_at is not null from public.personal_ledger_entries where id = :L1),
  'their khata entry is deleted too');
select pg_temp.ok((select deleted_at is not null from public.personal_ledger_repayments where id = :R1),
  'its repayment is deleted too');
select pg_temp.ok((select deleted_at is not null from public.personal_reminders where id = :M1),
  'the khata reminder is deleted too');
select pg_temp.ok((select person_id is null and deleted_at is null and revision = 2
  from public.personal_transactions where id = :T1), 'the expense stays, without the person');
select pg_temp.ok((select count(*) from public.personal_sync_events
  where entity_id in (:L1, :R1, :M1, :T1) and op_id = 'a0000000-0000-0000-0000-000000000012') = 4,
  'every linked change emits its own event');

select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000013', 'person', :P1, 'upsert', 0, '{"name": "Rahul Patel"}')
  = '{"status": "applied", "revision": 4}'::jsonb, 'a deleted record can be uploaded again (restore)');
select pg_temp.ok((select deleted_at is null from public.personal_people where id = :P1),
  'the record is live again');
select pg_temp.ok(
  (pg_temp.op('a0000000-0000-0000-0000-000000000014', 'transaction',
     '55555555-0000-0000-0000-000000000077', 'delete', 0, '{}') ->> 'status') = 'applied',
  'deleting a record the server never had is harmless');

-- 5b. Category names in English and Gujarati (app 1.3.0) ---------------------------------
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000020', 'transaction',
    '55555555-0000-0000-0000-000000000020', 'upsert', 0,
    jsonb_build_object('type', 'expense', 'amount_paise', 50000, 'category_id', 'cat_pooja',
      'category_name', 'Pooja', 'category_name_gu', 'પૂજા',
      'category_icon', 'more', 'category_color', 4283341407,
      'txn_date', '2026-11-23', 'payment_method', 'cash'))
  ->> 'status' = 'applied', 'an expense with a Gujarati category name is created');
select pg_temp.ok((select category_name_gu from public.personal_transactions
  where id = '55555555-0000-0000-0000-000000000020') = 'પૂજા', 'the Gujarati category name is saved');
select pg_temp.ok(exists (select 1 from jsonb_array_elements(public.get_personal_snapshot() -> 'transactions') t
  where t ->> 'id' = '55555555-0000-0000-0000-000000000020' and t ->> 'category_name_gu' = 'પૂજા'),
  'the snapshot carries the Gujarati category name');
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000021', 'transaction',
    '55555555-0000-0000-0000-000000000021', 'upsert', 0,
    jsonb_build_object('type', 'expense', 'amount_paise', 1000, 'category_id', 'cat_pooja',
      'category_name', 'Pooja', 'category_icon', 'more', 'category_color', 4283341407,
      'txn_date', '2026-11-23', 'payment_method', 'cash'))
  ->> 'status' = 'applied', 'an older app without the Gujarati name still saves');
select pg_temp.ok((select category_name_gu is null from public.personal_transactions
  where id = '55555555-0000-0000-0000-000000000021'), 'its Gujarati name stays empty');
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000022', 'transaction',
    '55555555-0000-0000-0000-000000000022', 'upsert', 0,
    jsonb_build_object('type', 'expense', 'amount_paise', 1000, 'category_id', 'cat_pooja',
      'category_name', 'Pooja', 'category_name_gu', repeat('પ', 61),
      'category_icon', 'more', 'category_color', 4283341407,
      'txn_date', '2026-11-23', 'payment_method', 'cash'))
  ->> 'status' = 'rejected', 'a Gujarati name over 60 characters is refused');

-- 6. Reset and snapshot ------------------------------------------------------------------
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000015', 'all', '', 'reset', 0, '{}')
  = '{"status": "applied", "revision": 0}'::jsonb, 'reset applies');
select pg_temp.ok((select count(*) from public.personal_people where deleted_at is null) = 0
  and (select count(*) from public.personal_transactions where deleted_at is null) = 0,
  'reset deletes every record of the user');
select pg_temp.ok((select count(*) from public.personal_sync_events where op_type = 'reset') = 1,
  'reset emits exactly one event');
select pg_temp.ok(
  pg_temp.op('a0000000-0000-0000-0000-000000000016', 'person', :P2, 'upsert', 0, '{"name": "Priya Shah"}')
  ->> 'status' = 'applied', 'records can be added after a reset');
select pg_temp.ok(jsonb_array_length(public.get_personal_snapshot() -> 'people') = 1
  and public.get_personal_snapshot() -> 'people' -> 0 ->> 'name' = 'Priya Shah',
  'the snapshot holds only live records');
select pg_temp.ok((public.get_personal_snapshot() ->> 'max_seq')::bigint
  = (select max(seq) from public.personal_sync_events), 'the snapshot reports the latest event');
select pg_temp.as_user(:B);
select pg_temp.ok(jsonb_array_length(public.get_personal_snapshot() -> 'people') = 0,
  'another user''s snapshot is empty');
reset role;

\echo 'ALL PERSONAL DATA TESTS PASSED'
