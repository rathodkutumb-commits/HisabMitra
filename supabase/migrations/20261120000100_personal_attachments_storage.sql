-- Private storage for each user's own bills and receipts (Part B).
-- Object path: <owner_id>/<attachment_id>.<ext> — the metadata row is
-- personal_attachments.storage_path, set by apply_personal_op.
-- (Requires the Supabase Storage schema, so it is skipped by the local
-- PostgreSQL test harness; the policies are checked on the live project.)

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('personal-attachments', 'personal-attachments', false, 10485760,
        array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'])
on conflict (id) do nothing;

-- Each user can only reach objects in their own folder.
create policy "personal attachments: owner can read"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'personal-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "personal attachments: owner can upload"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'personal-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "personal attachments: owner can delete"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'personal-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
