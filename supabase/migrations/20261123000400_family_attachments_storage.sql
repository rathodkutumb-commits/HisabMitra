-- Private storage for Family hisab bills (app 1.3.0, phase 4).
-- Object path: <family_id>/<entry_id>/<file>. Members read, add and delete;
-- nobody else sees them. Records are registered with
-- register_family_attachment (20261123000300_family_extras.sql).
-- (Requires the Supabase Storage schema, so it is skipped by the local
-- PostgreSQL test harness.)

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('family-attachments', 'family-attachments', false, 10485760,
        array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'])
on conflict (id) do nothing;

create policy "family attachments: members can read"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'family-attachments'
    and public.is_family_member(((storage.foldername(name))[1])::uuid)
  );

create policy "family attachments: members can upload"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'family-attachments'
    and public.is_family_member(((storage.foldername(name))[1])::uuid)
  );

-- Uploads overwrite (upsert), so a retry after a lost answer succeeds.
create policy "family attachments: members can replace"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'family-attachments'
    and public.is_family_member(((storage.foldername(name))[1])::uuid)
  )
  with check (
    bucket_id = 'family-attachments'
    and public.is_family_member(((storage.foldername(name))[1])::uuid)
  );

-- A deleted bill's file is removed too (delete_family_attachment first).
create policy "family attachments: members can delete"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'family-attachments'
    and public.is_family_member(((storage.foldername(name))[1])::uuid)
  );
