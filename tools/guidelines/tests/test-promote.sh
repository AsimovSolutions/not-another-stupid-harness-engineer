#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TOOL="$REPO_ROOT/tools/guidelines/promote"
VALIDATOR="$REPO_ROOT/tools/guidelines/validate-document"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

pass() { echo "  [PASS] $1"; }
fail() {
  echo "  [FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

assert_contains() {
  local haystack="$1" needle="$2" description="$3"
  if printf '%s' "$haystack" | grep -Fq -- "$needle"; then
    pass "$description"
  else
    fail "$description"
    echo "    expected to find: $needle"
    echo "    in:"
    printf '%s\n' "$haystack" | sed 's/^/      /'
  fi
}

assert_not_contains() {
  local haystack="$1" needle="$2" description="$3"
  if printf '%s' "$haystack" | grep -Fq -- "$needle"; then
    fail "$description"
    echo "    did not expect: $needle"
  else
    pass "$description"
  fi
}

export NASHE_HOME="$TEST_ROOT/home"
REPOS="$NASHE_HOME/orgs/acme/repos"
mkdir -p "$REPOS"

# A repository document carrying only the sections the test cares about is
# enough for promote: promote reads entries under headings and does not
# validate. Conformance is validate-document's job, asserted separately below.
write_repo_doc() {
  local name="$1"
  shift
  {
    echo "---"
    echo "nashe_guidelines_version: 1"
    echo "scope: repository"
    echo "organization: acme"
    echo "repository: $name"
    echo "profile: backend"
    echo "---"
    echo ""
    echo "## 3. Frameworks and libraries"
    printf '%s\n' "$@"
  } >"$REPOS/$name.md"
}

write_repo_doc billing \
  "- Gin — HTTP routing. [observed: go.mod:6]" \
  "- Testify — assertions. [observed: go.mod:12]"
write_repo_doc checkout \
  "- Gin — HTTP routing and binding. [observed: go.mod:6]" \
  "- Mockery — generated mocks. [default: backend]"
write_repo_doc payments \
  "- Echo — HTTP routing. [observed: go.mod:5]" \
  "- Testify — assertions and suites. [observed: go.mod:11]"

echo "promote"

"$TOOL" --org acme
output="$(cat "$NASHE_HOME/orgs/acme/org.md")"

assert_contains "$output" "scope: organization" "org.md declares organisation scope"
assert_contains "$output" "- Gin — HTTP routing. [observed in: billing, checkout (2/3)]" \
  "a term in two repositories is promoted with the alphabetically first description"
assert_contains "$output" "- Testify — assertions. [observed in: billing, payments (2/3)]" \
  "a second shared term is promoted"
assert_not_contains "$output" "Echo" "a term in one repository is not promoted"
assert_not_contains "$output" "Mockery" "a defaulted entry is never promoted"
assert_contains "$output" "## 16. Open questions" "org.md carries the full section list"

# Idempotence: promote is entirely code, so two runs must be byte-identical.
cp "$NASHE_HOME/orgs/acme/org.md" "$TEST_ROOT/first.md"
"$TOOL" --org acme
if diff -q "$TEST_ROOT/first.md" "$NASHE_HOME/orgs/acme/org.md" >/dev/null; then
  pass "two runs produce byte-identical output"
else
  fail "two runs produce byte-identical output"
  diff "$TEST_ROOT/first.md" "$NASHE_HOME/orgs/acme/org.md" | sed 's/^/    /'
fi

# The output of promote is itself a conforming document.
if "$VALIDATOR" "$NASHE_HOME/orgs/acme/org.md" >/dev/null 2>&1; then
  pass "the generated org.md passes validate-document"
else
  fail "the generated org.md passes validate-document"
  "$VALIDATOR" "$NASHE_HOME/orgs/acme/org.md" 2>&1 | sed 's/^/    /'
fi

# --org names a directory. resolve-org slugifies before it stores an answer,
# so anything that is not already a slug reached promote some other way and
# must be refused rather than followed out of the organisation's directory.
mkdir -p "$NASHE_HOME/orgs/globex/repos"
cp "$REPOS/billing.md" "$NASHE_HOME/orgs/globex/repos/billing.md"
cp "$REPOS/checkout.md" "$NASHE_HOME/orgs/globex/repos/checkout.md"
"$TOOL" --org globex
cp "$NASHE_HOME/orgs/globex/org.md" "$TEST_ROOT/globex-before.md"

assert_rejected_org() {
  local value="$1" description="$2"
  local output="" status=0
  set +e
  output="$("$TOOL" --org "$value" 2>&1)"
  status=$?
  set -e
  if [[ "$status" -eq 1 ]] && printf '%s' "$output" | grep -q '^error: '; then
    pass "$description"
  else
    fail "$description"
    echo "    expected exit 1 and an error: line, got $status with: $output"
  fi
}

assert_rejected_org "acme/../globex" "a traversing organisation name is rejected"
if diff -q "$TEST_ROOT/globex-before.md" "$NASHE_HOME/orgs/globex/org.md" >/dev/null; then
  pass "a traversing organisation name does not rewrite another organisation's org.md"
else
  fail "a traversing organisation name does not rewrite another organisation's org.md"
fi
assert_rejected_org "../acme" "a relative organisation name is rejected"
assert_rejected_org "/etc" "an absolute organisation name is rejected"
assert_rejected_org "Acme" "an unslugified organisation name is rejected"

if [[ "$FAILURES" -gt 0 ]]; then
  echo "promote: $FAILURES failure(s)"
  exit 1
fi
echo "promote: all checks passed"
