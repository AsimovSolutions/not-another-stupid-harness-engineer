#!/usr/bin/env bash
# The sixteen-section list exists in three places: validate-document's awk,
# promote's SECTIONS and SUBSECTIONS_* arrays, and the fenced block in
# method/guidelines/document-format.md. The first two are covered by
# test-promote.sh, which validates the org.md promote generates. The Markdown
# is not, and it is the text the model reads while filling a document, so a
# rename in the tools would leave the prose stale with nothing failing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
FORMAT_DOC="${FORMAT_DOC:-$REPO_ROOT/method/guidelines/document-format.md}"
PROMOTE="${PROMOTE:-$REPO_ROOT/tools/guidelines/promote}"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

pass() { echo "  [PASS] $1"; }
fail() {
  echo "  [FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

echo "section list"

# The headings listed in the fenced block of the format document, in order.
# The document holds several fenced blocks; the section list is the one that
# opens on section 1.
awk '
  /^```/ {
    if (fence && block != "" && first == "## 1. Profile") printf "%s", block
    fence = !fence; block = ""; first = ""
    next
  }
  fence && /^#{2,3} / {
    if (first == "") first = $0
    block = block $0 "\n"
  }
' "$FORMAT_DOC" >"$TEST_ROOT/from-markdown"

# The same list, rebuilt from the arrays promote actually emits from. The
# arrays are read out of the script rather than run, so this compares the
# declarations themselves.
eval "$(sed -n '/^SECTIONS=(/,/^)$/p' "$PROMOTE")"
eval "$(sed -n '/^SUBSECTIONS_8=(/p' "$PROMOTE")"
eval "$(sed -n '/^SUBSECTIONS_9=(/p' "$PROMOTE")"

{
  for section in "${SECTIONS[@]}"; do
    echo "## $section"
    case "$section" in
      "8. Testing") printf '### %s\n' "${SUBSECTIONS_8[@]}" ;;
      "9. Observability") printf '### %s\n' "${SUBSECTIONS_9[@]}" ;;
      *) ;;
    esac
  done
} >"$TEST_ROOT/from-promote"

if diff -u "$TEST_ROOT/from-markdown" "$TEST_ROOT/from-promote" >"$TEST_ROOT/diff"; then
  pass "the format document and promote agree on the section list"
else
  fail "the format document and promote agree on the section list"
  echo "    -: $FORMAT_DOC   +: $PROMOTE"
  sed 's/^/    /' "$TEST_ROOT/diff"
fi

if [[ "$(wc -l <"$TEST_ROOT/from-markdown" | tr -d ' ')" -eq 22 ]]; then
  pass "the fenced list was found and holds sixteen sections and six subsections"
else
  fail "the fenced list was found and holds sixteen sections and six subsections"
  sed 's/^/    /' "$TEST_ROOT/from-markdown"
fi

if [[ "$FAILURES" -gt 0 ]]; then
  echo "section list: $FAILURES failure(s)"
  exit 1
fi
echo "section list: all checks passed"
