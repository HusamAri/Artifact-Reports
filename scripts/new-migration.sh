#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <migration-name>"
  echo "Example: $0 rls_policies"
  exit 1
fi

NAME="$1"
cd "$(dirname "$0")/.."

# Find next index by scanning existing files.
LAST=$(ls supabase/migrations/ | grep -E '^[0-9]{4}_' | sort | tail -n 1 | head -c 4 || echo "0000")
NEXT=$(printf "%04d" $((10#$LAST + 1)))
FILE="supabase/migrations/${NEXT}_${NAME}.sql"

cat > "$FILE" <<EOF
-- ${NEXT}_${NAME}.sql
-- TODO: describe what this migration does and why.
EOF

echo "Created $FILE"
