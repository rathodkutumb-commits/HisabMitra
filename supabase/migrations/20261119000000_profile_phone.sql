-- Compulsory mobile number on the user's own profile (2026-11-19).
--
-- Sign-up requires name, email and mobile number. The email is verified by
-- Supabase Auth (auth.users.email); the mobile number is collected but not
-- SMS-verified, so it is deliberately not unique (an unverified number must
-- not block another account). RLS is unchanged: a profile, including its
-- phone, is readable and writable only by its owner.
--
-- Fails safely (nothing changes) if a profile without a phone already exists.

alter table public.user_profiles add column phone text;
alter table public.user_profiles alter column phone set not null;
alter table public.user_profiles
  add constraint user_profiles_phone_e164 check (phone ~ '^\+[1-9][0-9]{7,14}$');

comment on column public.user_profiles.phone is
  'Mobile number in E.164, entered at sign-up (not SMS-verified). Owner-only (RLS).';
