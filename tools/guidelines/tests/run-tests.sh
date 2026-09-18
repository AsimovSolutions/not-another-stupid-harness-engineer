#!/usr/bin/env bash
# Run every guidelines tool test file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FAILURES=0

for test_file in "$SCRIPT_DIR"/test-*.sh; do
  echo "== $(basename "$test_file")"
  if bash "$test_file"; then
    :
  else
    FAILURES=$((FAILURES + 1))
  fi
  echo ""
done

if [[ "$FAILURES" -gt 0 ]]; then
  echo "$FAILURES test file(s) failed"
  exit 1
fi
echo "All guidelines tool tests passed"
