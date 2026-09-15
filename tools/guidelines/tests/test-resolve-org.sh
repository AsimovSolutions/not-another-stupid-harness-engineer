#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TOOL="$REPO_ROOT/tools/guidelines/resolve-org"

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
    echo "    in: $haystack"
  fi
}

make_repo() {
  local name="$1" remote="${2:-}"
  local dir="$TEST_ROOT/work/$name"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.name "Test Bot"
  git -C "$dir" config user.email "test@example.com"
  if [[ -n "$remote" ]]; then
    git -C "$dir" remote add origin "$remote"
  fi
  printf '%s' "$dir"
}

echo "resolve-org"

# Stored answer wins over every signal.
export NASHE_HOME="$TEST_ROOT/home"
mkdir -p "$NASHE_HOME"
repo="$(make_repo checkout "git@github.com:acme/checkout.git")"
cat >"$NASHE_HOME/repos.json" <<JSON
{"repositories": {"$repo": "globex"}}
JSON
output="$("$TOOL" --repo "$repo")"
assert_contains "$output" "org=globex" "stored answer wins over remote signal"
assert_contains "$output" "source=stored" "stored answer reports its source"

# Remote owner and parent directory agree: resolve without asking.
export NASHE_HOME="$TEST_ROOT/home2"
mkdir -p "$NASHE_HOME/../work/acme"
agree_dir="$TEST_ROOT/work/acme"
mkdir -p "$agree_dir"
repo2="$agree_dir/payments"
mkdir -p "$repo2"
git -C "$repo2" init -q
git -C "$repo2" remote add origin "git@github.com:acme/payments.git"
output="$("$TOOL" --repo "$repo2")"
assert_contains "$output" "org=acme" "agreeing signals resolve to the organisation"
assert_contains "$output" "source=signals" "agreeing signals report their source"

# Signals disagree: refuse to guess, exit 3, report both signals.
export NASHE_HOME="$TEST_ROOT/home3"
mkdir -p "$TEST_ROOT/work/globex"
repo3="$TEST_ROOT/work/globex/checkout"
mkdir -p "$repo3"
git -C "$repo3" init -q
git -C "$repo3" remote add origin "git@github.com:acme/checkout.git"
set +e
output="$("$TOOL" --repo "$repo3")"
status=$?
set -e
if [[ "$status" -eq 3 ]]; then
  pass "conflicting signals exit 3"
else
  fail "conflicting signals exit 3 (got $status)"
fi
assert_contains "$output" "status=undecided" "conflict reports undecided"
assert_contains "$output" "remote_org=acme" "conflict reports the remote signal"
assert_contains "$output" "path_org=globex" "conflict reports the path signal"

# --set persists the answer and later runs read it back.
output="$("$TOOL" --repo "$repo3" --set "Acme Corp")"
assert_contains "$output" "org=acme-corp" "--set slugifies the organisation"
assert_contains "$output" "source=set" "--set reports its source"
output="$("$TOOL" --repo "$repo3")"
assert_contains "$output" "org=acme-corp" "the answer is read back on the next run"
assert_contains "$output" "source=stored" "the read-back reports the stored source"

if [[ "$FAILURES" -gt 0 ]]; then
  echo "resolve-org: $FAILURES failure(s)"
  exit 1
fi
echo "resolve-org: all checks passed"
