-- Minimal stand-in for the parts of Supabase the migration depends on, so the
-- schema, RLS policies and RPCs can be tested on plain PostgreSQL.
-- NOT for production: the real project provides these.
create schema if not exists auth;
create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

create table if not exists auth.users (
  id uuid primary key,
  phone text
);

-- Supabase reads the JWT `sub` claim; tests set it with set_config().
create or replace function auth.uid() returns uuid
language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

do $$ begin create role anon nologin; exception when duplicate_object then null; end $$;
do $$ begin create role authenticated nologin; exception when duplicate_object then null; end $$;
do $$ begin create role service_role nologin bypassrls; exception when duplicate_object then null; end $$;

grant usage on schema public, auth, extensions to anon, authenticated, service_role;
grant execute on function auth.uid() to anon, authenticated, service_role;
grant select on auth.users to service_role;

-- Supabase's default privileges: everything created in `public` is granted
-- to the API roles unless a migration revokes it. Mirroring this keeps the
-- tests honest about what the migrations must lock down.
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
