# HisabMitra (હિસાબમિત્ર)

**Smart Hisab, Happy Family. — સ્માર્ટ હિસાબ, ખુશ પરિવાર.**

Offline-first personal and family finance for Android, in English and
Gujarati: income and expenses, money given and taken, family and trip
group expenses with splits and settlements, reports, bills, reminders,
backups and an optional AI assistant. Personal data stays on the phone;
only groups you choose to share are synced (Supabase, RLS-protected).

## Quick start

```bash
flutter pub get
cp dart_defines.example.json dart_defines.json   # optional: Supabase values
flutter run --dart-define-from-file=dart_defines.json
```

## Quality checks

```bash
flutter analyze
flutter test
flutter test integration_test -d <device> --concurrency=1
bash tool/run_supabase_tests.sh   # Docker
```

## Documentation

Start with [docs/PROGRESS.md](docs/PROGRESS.md), then
[ARCHITECTURE](docs/ARCHITECTURE.md),
[SCREEN_INVENTORY](docs/SCREEN_INVENTORY.md),
[FINANCIAL_BUSINESS_RULES](docs/FINANCIAL_BUSINESS_RULES.md),
[SUPABASE_SETUP](docs/SUPABASE_SETUP.md) and
[GITHUB_RELEASE_GUIDE](docs/GITHUB_RELEASE_GUIDE.md). All documents are in
[docs/](docs/).
