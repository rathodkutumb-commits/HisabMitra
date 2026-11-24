-- Executable tests for Family hisab bills and reminder links (app 1.3.0,
-- phase 4). Run with: tool/run_supabase_tests.sh (after 10_, 40_ and 50_).
-- Every check raises on failure.
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

create or replace function pg_temp.fop(
  p_op text, p_family text, p_type text, p_entity text, p_kind text, p_base int, p_payload jsonb
) returns jsonb language sql as $$
  select public.apply_family_op(jsonb_build_object(
    'op_id', p_op, 'family_id', p_family, 'entity_type', p_type, 'entity_id', p_entity,
    'op_type', p_kind, 'base_revision', p_base, 'payload', p_payload))
$$;

-- A bill's registration payload.
create or replace function pg_temp.bill(p_id text, p_family text, p_entry text, p_path text) returns jsonb
language sql as $$
  select jsonb_build_object('id', p_id, 'family_id', p_family, 'entry_id', p_entry, 'storage_path', p_path,
    'mime_type', 'image/jpeg', 'size_bytes', 2048, 'sha256', repeat('a', 64))
$$;

grant execute on all functions in schema pg_temp to authenticated, anon;

\set A '''aaaaaaaa-0000-0000-0000-000000000001'''
\set B '''bbbbbbbb-0000-0000-0000-000000000002'''
\set C '''cccccccc-0000-0000-0000-000000000003'''
\set F '''f8000000-0000-0000-0000-000000000001'''
\set ME '''f8100000-0000-0000-0000-000000000001'''
\set BHAI '''f8100000-0000-0000-0000-000000000002'''
\set RENT '''f8200000-0000-0000-0000-000000000001'''
\set OTHER_ENTRY '''f3000000-0000-0000-0000-000000000001'''
\set BILL '''f8300000-0000-0000-0000-000000000001'''

-- 1. A Family hisab with a money-out entry, and B joined -------------------------------
set role authenticated;
select pg_temp.as_user(:B);
select pg_temp.ok(
  pg_temp.fop('e1000000-0000-0000-0000-000000000001', :F, 'family', :F, 'upsert', 0,
    jsonb_build_object('name', 'Flat', 'owner_member_id', :ME, 'owner_display_name', 'Rahul'))
  ->> 'status' = 'applied', 'B creates Flat');
select pg_temp.ok(
  pg_temp.fop('e1000000-0000-0000-0000-000000000002', :F, 'member', :BHAI, 'upsert', 0, '{"name": "Kaka"}')
  ->> 'status' = 'applied', 'with Kaka');
select pg_temp.ok(
  pg_temp.fop('e1000000-0000-0000-0000-000000000003', :F, 'entry', :RENT, 'upsert', 0,
    jsonb_build_object('member_id', :ME, 'kind', 'expense', 'amount_paise', 1500000, 'entry_date', '2026-11-05',
      'category_id', 'cat_rent', 'category_name', 'Rent', 'category_name_gu', 'ભાડું'))
  ->> 'status' = 'applied', 'and the rent paid');
create temp table inv as select public.create_family_invitation(:F, :BHAI) as inv;
select pg_temp.as_user(:A);
select public.accept_invitation((select inv ->> 'code' from inv), 'Hemang');

-- 2. Registering a bill --------------------------------------------------------------
reset role;
insert into storage.objects (bucket_id, name) values
  ('family-attachments', 'f8000000-0000-0000-0000-000000000001/f8200000-0000-0000-0000-000000000001/bill.jpg');
set role authenticated;
select pg_temp.as_user(:C);
select pg_temp.fails(format('select public.register_family_attachment(%L)',
  pg_temp.bill(:BILL, :F, :RENT, :F || '/' || :RENT || '/bill.jpg')), 'forbidden', 'an outsider cannot add bills');
select pg_temp.as_user(:A);
select pg_temp.fails(format('select public.register_family_attachment(%L)',
  pg_temp.bill(:BILL, :F, :RENT, :F || '/' || :OTHER_ENTRY || '/bill.jpg')), 'invalid_path',
  'the path must be the entry''s folder');
select pg_temp.fails(format('select public.register_family_attachment(%L)',
  pg_temp.bill(:BILL, :F, :OTHER_ENTRY, :F || '/' || :OTHER_ENTRY || '/bill.jpg')), 'invalid_entry',
  'the entry must belong to this Family hisab');
select pg_temp.fails(format('select public.register_family_attachment(%L)',
  pg_temp.bill(:BILL, :F, :RENT, :F || '/' || :RENT || '/missing.jpg')), 'invalid_path',
  'a file that was not uploaded cannot be registered');
select pg_temp.ok(public.register_family_attachment(pg_temp.bill(:BILL, :F, :RENT, :F || '/' || :RENT || '/bill.jpg'))
  ->> 'status' = 'applied', 'a member adds a bill to money out');
select pg_temp.ok(public.register_family_attachment(pg_temp.bill(:BILL, :F, :RENT, :F || '/' || :RENT || '/bill.jpg'))
  ->> 'status' = 'applied', 'registering again is harmless');
select pg_temp.ok((select count(*) from public.family_attachments where id = :BILL) = 1, 'one bill row');
select pg_temp.ok((select count(*) from public.family_sync_events
                   where entity_type = 'attachment' and entity_id = :BILL and op_type = 'upsert') = 1,
  'the bill reaches the other phones once');
select pg_temp.ok(jsonb_array_length(public.get_family_snapshot(:F) -> 'attachments') = 1
  and public.get_family_snapshot(:F) -> 'attachments' -> 0 ->> 'entry_id' = :RENT,
  'a new phone gets the bill with the snapshot');

-- 3. Reading and deleting -------------------------------------------------------------
select pg_temp.as_user(:C);
select pg_temp.ok((select count(*) from public.family_attachments) = 0, 'outsiders see no bills');
select pg_temp.fails(format('select public.delete_family_attachment(%L)', :BILL), 'forbidden',
  'outsiders cannot delete bills');
select pg_temp.as_user(:B);
select public.delete_family_attachment(:BILL);
select pg_temp.ok(jsonb_array_length(public.get_family_snapshot(:F) -> 'attachments') = 0,
  'a deleted bill leaves the snapshot');
select pg_temp.ok((select count(*) from public.family_sync_events
                   where entity_type = 'attachment' and entity_id = :BILL and op_type = 'delete') = 1,
  'and disappears on the other phones');

-- 4. A personal reminder linked to a Family hisab ---------------------------------------
select pg_temp.ok(
  public.apply_personal_op(jsonb_build_object(
    'op_id', 'e2000000-0000-0000-0000-000000000001', 'entity_type', 'reminder',
    'entity_id', 'e3000000-0000-0000-0000-000000000001', 'op_type', 'upsert', 'base_revision', 0,
    'payload', jsonb_build_object('kind', 'rent', 'title', 'Rent', 'due_at', '2026-12-05T04:30:00Z',
      'repeat', 'monthly', 'family_id', :F, 'status', 'pending', 'completed_occurrences', 0)))
  ->> 'status' = 'applied', 'a reminder can be linked to a Family hisab');
select pg_temp.ok(exists (select 1 from jsonb_array_elements(public.get_personal_snapshot() -> 'reminders') r
                          where r ->> 'family_id' = :F),
  'the link comes back on a new phone');
reset role;

\echo 'ALL FAMILY EXTRAS TESTS PASSED'
