#!/usr/bin/env bash
# Runs the cloud schema + RLS tests on a throw-away PostgreSQL container.
# Requires Docker. Nothing is sent to any Supabase project.
set -euo pipefail
cd "$(dirname "$0")/.."

NAME=hisabmitra-pgtest-$$
IMAGE=${PG_IMAGE:-postgres:16-alpine}

docker run -d --rm --name "$NAME" -e POSTGRES_PASSWORD=test "$IMAGE" >/dev/null
trap 'docker rm -f "$NAME" >/dev/null 2>&1 || true' EXIT

for _ in $(seq 1 30); do
  if docker exec "$NAME" pg_isready -U postgres >/dev/null 2>&1; then break; fi
  sleep 1
done

run() { docker exec -i "$NAME" psql -q -o /dev/null -v ON_ERROR_STOP=1 -U postgres -d postgres "$@"; }

run < supabase/tests/00_supabase_shim.sql
for f in supabase/migrations/*.sql; do
  case "$f" in *storage*) continue ;; esac   # needs Supabase Storage schema
  run < "$f"
done
run < supabase/tests/10_rls_and_rpc_test.sql
run < supabase/tests/20_personal_data_test.sql
run < supabase/tests/30_realtime_test.sql
run < supabase/tests/40_family_hisab_test.sql
run < supabase/tests/50_family_sharing_test.sql
run < supabase/tests/60_family_extras_test.sql
