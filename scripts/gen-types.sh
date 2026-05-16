#!/usr/bin/env bash
set -euo pipefail

# Generate TypeScript + Dart types from the local Supabase schema.
# Requires `supabase` CLI and a running local stack.

cd "$(dirname "$0")/.."

mkdir -p packages/shared-types

echo "==> TS types"
supabase gen types typescript --local > packages/shared-types/database.ts

echo "==> Dart types (placeholder — wire up supadart or codegen of choice in M2)"
# TODO(M2): generate Dart types from packages/shared-types/database.ts

echo "Done."
