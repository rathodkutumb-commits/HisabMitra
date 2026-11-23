-- Executable tests for sharing a Family hisab (app 1.3.0, phase 3):
-- invitations, one accept for group and Family hisab codes, roles, a removed
-- person's feed and account-deletion hand-over.
-- Run with: tool/run_supabase_tests.sh (after 10_ and 40_). Every check
-- raises on failure.
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

-- A person's current revision (for deletes and edits).
create or replace function pg_temp.rev(p_member text) returns int language sql as $$
  select revision::int from public.family_members where id = p_member::uuid
$$;

grant execute on all functions in schema pg_temp to authenticated, anon;

\set A '''aaaaaaaa-0000-0000-0000-000000000001'''
\set B '''bbbbbbbb-0000-0000-0000-000000000002'''
\set C '''cccccccc-0000-0000-0000-000000000003'''
\set F '''f5000000-0000-0000-0000-000000000001'''
\set V '''f5000000-0000-0000-0000-000000000002'''
\set ME '''f6000000-0000-0000-0000-000000000001'''
\set RAHUL '''f6000000-0000-0000-0000-000000000002'''
\set PRIYA '''f6000000-0000-0000-0000-000000000003'''
\set V_ME '''f6000000-0000-0000-0000-000000000011'''
\set V_C '''f6000000-0000-0000-0000-000000000012'''
\set V_B '''f6000000-0000-0000-0000-000000000013'''
\set OTHER_PERSON '''f2000000-0000-0000-0000-000000000003'''
\set CONTRIB '''f7000000-0000-0000-0000-000000000001'''

set role authenticated;

-- 1. Home with Rahul Patel and Priya Shah, and Rahul's contribution ---------------------
select pg_temp.as_user(:A);
select pg_temp.ok(
  pg_temp.fop('d1000000-0000-0000-0000-000000000001', :F, 'family', :F, 'upsert', 0,
    jsonb_build_object('name', 'Home', 'owner_member_id', :ME, 'owner_display_name', 'Hemang'))
  ->> 'status' = 'applied', 'A creates Home');
select pg_temp.ok(
  pg_temp.fop('d1000000-0000-0000-0000-000000000002', :F, 'member', :RAHUL, 'upsert', 0,
    '{"name": "Rahul Patel", "sort_order": 1}') ->> 'status' = 'applied', 'A adds Rahul Patel');
select pg_temp.ok(
  pg_temp.fop('d1000000-0000-0000-0000-000000000003', :F, 'member', :PRIYA, 'upsert', 0,
    '{"name": "Priya Shah", "sort_order": 2}') ->> 'status' = 'applied', 'A adds Priya Shah');
select pg_temp.ok(
  pg_temp.fop('d1000000-0000-0000-0000-000000000004', :F, 'entry', :CONTRIB, 'upsert', 0,
    jsonb_build_object('member_id', :RAHUL, 'kind', 'contribution', 'amount_paise', 1000000,
      'entry_date', '2026-11-12')) ->> 'status' = 'applied', 'A writes Rahul''s contribution');

-- 2. Creating invitations ---------------------------------------------------------------
select pg_temp.as_user(:B);
select pg_temp.fails(format('select public.create_family_invitation(%L, %L)', :F, :RAHUL), 'forbidden',
  'a non-member cannot invite');
select pg_temp.as_user(:A);
select pg_temp.fails(format('select public.create_family_invitation(%L, %L)', :F, :OTHER_PERSON),
  'invalid_member', 'a person of another Family hisab cannot be invited here');
create temp table inv_rahul as select public.create_family_invitation(:F, :RAHUL) as inv;
select pg_temp.ok(length(inv ->> 'code') = 10, 'an invitation has a 10-character code') from inv_rahul;
select pg_temp.fails(format('select public.create_family_invitation(%L, %L)', :F, :RAHUL),
  'invitation_pending', 'one pending invitation per person');
select pg_temp.ok((select count(*) from public.family_invitations where family_id = :F) = 1,
  'admins can list the invitations');

-- 3. Accepting: the named person becomes B -------------------------------------------------
select pg_temp.as_user(:B);
select pg_temp.ok((select count(*) from public.family_invitations) = 0, 'others cannot list invitations');
create temp table acc_b as
  select public.accept_invitation((select inv ->> 'code' from inv_rahul), 'Bhai') as res;
select pg_temp.ok(res ->> 'kind' = 'family' and res ->> 'family_id' = :F and res ->> 'member_id' = :RAHUL,
  'a Family hisab code joins the named person') from acc_b;
select pg_temp.ok((select user_id = :B and name = 'Rahul Patel' from public.family_members where id = :RAHUL),
  'Rahul Patel is now B''s person and keeps the name');
select pg_temp.ok((select count(*) from public.family_hisabs where id = :F) = 1, 'B now sees Home');
select pg_temp.ok((select created_by = :A and member_id = :RAHUL from public.family_entries where id = :CONTRIB),
  'Rahul''s earlier entry stays his');
select pg_temp.as_user(:C);
select pg_temp.fails(format('select public.accept_invitation(%L, %L)', (select inv ->> 'code' from inv_rahul), 'C'),
  'invalid_code', 'a used code cannot be used again');
select pg_temp.as_user(:A);
create temp table inv_new as select public.create_family_invitation(:F) as inv;
select pg_temp.as_user(:B);
select pg_temp.fails(format('select public.accept_invitation(%L, %L)', (select inv ->> 'code' from inv_new), 'Bhai'),
  'already_member', 'joining twice is refused');

-- 4. Expired, cancelled and removed-person codes -------------------------------------------
select pg_temp.as_user(:A);
create temp table inv_old as select public.create_family_invitation(:F, :PRIYA, 1) as inv;
reset role;
update public.family_invitations set expires_at = now() - interval '1 minute'
  where id = (select (inv ->> 'invitation_id')::uuid from inv_old);
set role authenticated;
select pg_temp.as_user(:C);
select pg_temp.fails(format('select public.accept_invitation(%L, %L)', (select inv ->> 'code' from inv_old), 'C'),
  'expired', 'an expired code says so');
select pg_temp.fails(format('select public.cancel_family_invitation(%L)', (select inv ->> 'invitation_id' from inv_new)),
  'forbidden', 'only admins cancel invitations');
select pg_temp.as_user(:A);
select public.cancel_family_invitation((select (inv ->> 'invitation_id')::uuid from inv_new));
select pg_temp.as_user(:C);
select pg_temp.fails(format('select public.accept_invitation(%L, %L)', (select inv ->> 'code' from inv_new), 'C'),
  'invalid_code', 'a cancelled code is invalid');
select pg_temp.as_user(:A);
create temp table inv_priya as select public.create_family_invitation(:F, :PRIYA) as inv;
select pg_temp.ok(
  pg_temp.fop('d1000000-0000-0000-0000-000000000005', :F, 'member', :PRIYA, 'delete', pg_temp.rev(:PRIYA), '{}')
  ->> 'status' = 'applied', 'A removes Priya after inviting her');
select pg_temp.as_user(:C);
select pg_temp.fails(format('select public.accept_invitation(%L, %L)', (select inv ->> 'code' from inv_priya), 'C'),
  'invalid_code', 'a code for a removed person is invalid');

-- 5. One accept for group codes too ------------------------------------------------------
select pg_temp.as_user(:B);
create temp table inv_group as
  select public.create_group_invitation('11111111-1111-1111-1111-111111111111') as inv;
select pg_temp.as_user(:A);
create temp table acc_group as
  select public.accept_invitation((select inv ->> 'code' from inv_group), 'Hemang') as res;
select pg_temp.ok(res ->> 'kind' = 'group' and res ->> 'group_id' = '11111111-1111-1111-1111-111111111111',
  'a group code joins the group through the same accept') from acc_group;

-- 6. Roles ------------------------------------------------------------------------------
select pg_temp.as_user(:B);
select pg_temp.ok(
  pg_temp.fop('d2000000-0000-0000-0000-000000000001', :F, 'family', :F, 'upsert', 1, '{"name": "Our home"}')
  ->> 'code' = 'forbidden', 'a member cannot rename the Family hisab');
select pg_temp.ok(
  pg_temp.fop('d2000000-0000-0000-0000-000000000002', :F, 'member', 'f6000000-0000-0000-0000-000000000004',
    'upsert', 0, '{"name": "Kaka"}') ->> 'code' = 'forbidden', 'a member cannot add people');
select pg_temp.ok(
  pg_temp.fop('d2000000-0000-0000-0000-000000000003', :F, 'entry', 'f7000000-0000-0000-0000-000000000002',
    'upsert', 0, jsonb_build_object('member_id', :RAHUL, 'kind', 'salary', 'amount_paise', 3500000,
      'entry_date', '2026-11-01')) ->> 'status' = 'applied', 'a member adds entries');
select pg_temp.fails(format('select public.set_family_member_role(%L, %L)', :RAHUL, 'admin'), 'forbidden',
  'a member cannot change roles');
select pg_temp.as_user(:A);
select pg_temp.ok((public.set_family_member_role(:RAHUL, 'admin') ->> 'revision')::int > 0,
  'the owner makes Rahul an admin');
select pg_temp.as_user(:B);
select pg_temp.ok(
  pg_temp.fop('d2000000-0000-0000-0000-000000000004', :F, 'member', 'f6000000-0000-0000-0000-000000000004',
    'upsert', 0, '{"name": "Kaka"}') ->> 'status' = 'applied', 'an admin adds people');
select pg_temp.as_user(:A);
select pg_temp.fails(format('select public.set_family_member_role(%L, %L)', :ME, 'member'), 'forbidden',
  'the owner''s own role does not change');
select pg_temp.fails(format('select public.set_family_member_role(%L, %L)', :RAHUL, 'boss'), 'invalid_data',
  'only admin or member');
select pg_temp.ok((public.set_family_member_role(:RAHUL, 'member') ->> 'revision')::int > 0,
  'the owner makes Rahul a member again');
select pg_temp.ok((select count(*) from public.family_sync_events where entity_id = :RAHUL) >= 4,
  'linking and role changes reach the other phones');

-- 7. A removed person reads only their own removal -------------------------------------------
select pg_temp.ok(
  pg_temp.fop('d1000000-0000-0000-0000-000000000006', :F, 'member', :RAHUL, 'delete', pg_temp.rev(:RAHUL), '{}')
  ->> 'status' = 'applied', 'A removes Rahul');
select pg_temp.ok(
  pg_temp.fop('d1000000-0000-0000-0000-000000000007', :F, 'entry', 'f7000000-0000-0000-0000-000000000003',
    'upsert', 0, jsonb_build_object('member_id', :ME, 'kind', 'salary', 'amount_paise', 100,
      'entry_date', '2026-11-02')) ->> 'status' = 'applied', 'A adds an entry afterwards');
select pg_temp.as_user(:B);
select pg_temp.ok((select count(*) from public.family_sync_events
                   where entity_id = :RAHUL and op_type = 'delete') = 1,
  'B sees that they were removed (so their phone forgets Home)');
select pg_temp.ok((select count(*) from public.family_sync_events
                   where entity_id = 'f7000000-0000-0000-0000-000000000003') = 0,
  'B does not see anything added after the removal');
select pg_temp.ok((select count(*) from public.family_hisabs where id = :F) = 0, 'B no longer reads Home');

-- 8. Account deletion hands a Family hisab over -------------------------------------------
select pg_temp.as_user(:A);
select pg_temp.ok(
  pg_temp.fop('d3000000-0000-0000-0000-000000000001', :V, 'family', :V, 'upsert', 0,
    jsonb_build_object('name', 'Village', 'owner_member_id', :V_ME, 'owner_display_name', 'Hemang'))
  ->> 'status' = 'applied', 'A creates Village');
select pg_temp.ok(
  pg_temp.fop('d3000000-0000-0000-0000-000000000002', :V, 'member', :V_C, 'upsert', 0, '{"name": "Kaka"}')
  ->> 'status' = 'applied', 'with Kaka');
select pg_temp.ok(
  pg_temp.fop('d3000000-0000-0000-0000-000000000003', :V, 'member', :V_B, 'upsert', 0, '{"name": "Rahul Patel"}')
  ->> 'status' = 'applied', 'and Rahul');
create temp table inv_vc as select public.create_family_invitation(:V, :V_C) as inv;
create temp table inv_vb as select public.create_family_invitation(:V, :V_B) as inv;
select pg_temp.as_user(:C);
select public.accept_invitation((select inv ->> 'code' from inv_vc), 'Kaka');
select pg_temp.as_user(:B);
select public.accept_invitation((select inv ->> 'code' from inv_vb), 'Rahul');
select pg_temp.as_user(:A);
select public.set_family_member_role(:V_C, 'admin');
select pg_temp.ok(
  pg_temp.fop('d3000000-0000-0000-0000-000000000004', :V, 'member', :V_B, 'delete', pg_temp.rev(:V_B), '{}')
  ->> 'status' = 'applied', 'Rahul is removed from Village');
select public.prepare_account_deletion();
reset role;
select pg_temp.ok((select owner_id = :C from public.family_hisabs where id = :V),
  'Village passes to the remaining account holder');
select pg_temp.ok((select role = 'owner' from public.family_members where id = :V_C), 'who becomes its owner');
select pg_temp.ok((select user_id is null and role = 'member' from public.family_members where id = :V_ME),
  'the deleted user becomes a plain person');
select pg_temp.ok((select deleted_at is not null from public.family_hisabs where id = :F),
  'Home, with nobody else who has the app, is deleted');
select pg_temp.ok((select count(*) from public.family_invitations
                   where created_by = :A and status = 'pending') = 0,
  'the deleted user''s pending invitations are cancelled');

\echo 'ALL FAMILY SHARING TESTS PASSED'
