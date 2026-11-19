# Backup and Restore

Code: `lib/features/backup/`. Tests: `test/features/backup/`
(unit) and `integration_test/device_backup_test.dart` (on a device).

## Where files live

| Item | Location |
|---|---|
| Live database | app-private `hisabmitra.sqlite` |
| Attachments | app-private `attachments/` |
| Backups | app-private `backups/hisabmitra-<date>.zip` |

App-private storage is not visible to other apps and is removed when the
app is uninstalled. To keep a backup elsewhere (Drive, PC, another phone)
use **Export / share** on a backup — the user chooses where it goes. The app
never uploads backups by itself.

## Backup file

ZIP containing:

- `database.sqlite` — a consistent snapshot made with `VACUUM INTO`;
- `attachments/*` — every stored bill and receipt;
- `manifest.json` — app version, schema version, creation time, counts and
  the SHA-256 of every file.

Settings are inside the database (`app_settings`), so they are included.
Secrets (Supabase session, AI key) are not.

**Optional encryption:** AES-256-GCM with a key derived from the password
by PBKDF2-HMAC-SHA256 (210 000 iterations, random salt; iterations and salt
stored in the file header). The password is never stored; a lost password
means the backup cannot be opened.

## Kinds

| Kind | When | Kept |
|---|---|---|
| Manual | Backup screen → "Back up now" | until deleted |
| Automatic | daily or weekly (Settings → Backup); checked when the app starts or returns to the foreground | newest 7 |
| Safety | automatically before every restore | until deleted |

Limitation: Android does not run the app in the background for this, so an
automatic backup happens on the first app open after it is due.

## Restore steps

1. User picks a backup from history or a `.zip` file (and enters its
   password if encrypted).
2. **Validate before touching anything:** ZIP structure, manifest present,
   SHA-256 of every file, schema version not newer than the app, attachment
   references, SQLite `integrity_check` of the backup database.
3. Show what the backup contains (date, transactions, people, groups) and
   ask for confirmation.
4. Create a **safety backup** of the current data.
5. Close the database, swap in the backup database and attachments, keep
   the old files aside.
6. Re-open and run `integrity_check`. On any failure the old files are put
   back — the current data is never lost.
7. Show the result, including where the safety backup is.

A backup from an older schema version is migrated on open by the normal
Drift migrations.

## Tested

Round trip with attachments; tampered file rejected (checksum); non-backup
file rejected; wrong password rejected; restore after changes brings back
the old data and lists the safety backup; automatic pruning; on a device,
an encrypted round trip at full PBKDF2 strength in app-private storage.
