#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
VALIDATOR="$REPO_ROOT/tools/guidelines/validate-document"

FAILURES=0

pass() { echo "  [PASS] $1"; }
fail() {
  echo "  [FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

echo "profile defaults"

for profile in backend frontend; do
  doc="$REPO_ROOT/method/defaults/$profile.md"

  if [[ -f "$doc" ]]; then
    pass "$profile defaults exist"
  else
    fail "$profile defaults exist"
    continue
  fi

  if "$VALIDATOR" "$doc" >/dev/null 2>&1; then
    pass "$profile defaults conform to the document format"
  else
    fail "$profile defaults conform to the document format"
    "$VALIDATOR" "$doc" 2>&1 | sed 's/^/    /'
  fi

  # Every non-empty entry must be marked as a default. A default file
  # claiming an observation would put an unfounded claim into every
  # document generated from it.
  if grep -E '^- ' "$doc" | grep -vF '[none detected]' | grep -qvF "[default: $profile]"; then
    fail "$profile defaults mark every entry as a default"
    grep -E '^- ' "$doc" | grep -vF '[none detected]' | grep -vF "[default: $profile]" | sed 's/^/    /'
  else
    pass "$profile defaults mark every entry as a default"
  fi
done

if [[ "$FAILURES" -gt 0 ]]; then
  echo "profile defaults: $FAILURES failure(s)"
  exit 1
fi
echo "profile defaults: all checks passed"
