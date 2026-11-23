-- Live updates: only the change feeds are published to Realtime.
-- Run with: tool/run_supabase_tests.sh. Every check raises on failure.
\set ON_ERROR_STOP 1
set client_min_messages = notice;

create or replace function pg_temp.ok(p_cond boolean, p_msg text) returns void language plpgsql as $$
begin
  if p_cond is distinct from true then raise exception 'ASSERTION FAILED: %', p_msg; end if;
  raise notice 'ok - %', p_msg;
end $$;

select pg_temp.ok(
  (select count(*) from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public'
      and tablename in ('sync_events', 'personal_sync_events', 'family_sync_events')) = 3,
  'the three change feeds are published to Realtime');

select pg_temp.ok(
  not exists (select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and tablename not in ('sync_events', 'personal_sync_events', 'family_sync_events')),
  'no data table is published');
