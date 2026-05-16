#!/usr/bin/env bash
set -euo pipefail

# One-shot local setup. Run from repo root.

cd "$(dirname "$0")/.."

echo "==> Flutter deps"
( cd app && flutter pub get )

echo "==> Flutter localizations"
( cd app && flutter gen-l10n )

echo "==> Web-report deps"
( cd web-report && npm install )

if command -v supabase >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  echo "==> Supabase (docker)"
  ( cd supabase && supabase start )
else
  echo "skip: supabase CLI or docker not found"
fi

echo "Done."
