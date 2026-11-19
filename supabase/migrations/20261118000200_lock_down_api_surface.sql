-- Lock the API surface down to what the app actually calls.
--
-- Supabase grants EXECUTE on every new function in `public` directly to the
-- `anon` and `authenticated` roles (default privileges). The init migration
-- revoked it from `anon` but not from `authenticated`, which left the
-- internal SECURITY DEFINER helpers callable through PostgREST — `_emit`
-- could have been used to inject sync events into another user's group.
--
-- The helpers are only called from inside other SECURITY DEFINER functions,
-- which run as the owner, so no client role needs EXECUTE on them.

revoke execute on function
  public._emit(uuid, text, uuid, text, bigint, jsonb, uuid),
  public._member_json(uuid),
  public._group_json(uuid),
  public._expense_json(uuid),
  public._settlement_json(uuid)
  from public, anon, authenticated;

-- Tables: the defaults also left DELETE, TRUNCATE (which bypasses RLS),
-- REFERENCES and TRIGGER on tables. Reset to exactly what the app needs;
-- RLS policies still decide which rows are visible or writable.
revoke all on all tables in schema public from anon, authenticated;
grant select on all tables in schema public to authenticated;
grant insert, update on public.user_profiles to authenticated;
grant insert, update, delete on public.user_devices to authenticated;

-- Future functions and tables in `public` start with no client access; each
-- migration must grant what it intends to expose.
alter default privileges in schema public revoke execute on functions from public, anon, authenticated;
alter default privileges in schema public revoke all on tables from anon, authenticated;
alter default privileges in schema public revoke all on sequences from anon, authenticated;
