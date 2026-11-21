-- Live updates (Part C): phones listen for new rows in the two change feeds
-- and answer each one with their normal sync. Supabase Realtime applies each
-- table's RLS to every listener, so a phone only hears about its own groups
-- (sync_events: group members) and its own records (personal_sync_events:
-- owner). The data tables themselves are NOT published.
alter publication supabase_realtime add table public.sync_events, public.personal_sync_events;
