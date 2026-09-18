#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TOOL="$REPO_ROOT/tools/guidelines/resolve-org"

FAILURES=0
# Physical, so the paths the test writes into repos.json match the canonical
# key the tool derives from them.
TEST_ROOT="$(cd "$(mktemp -d)" && pwd -P)"
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

# remote_org() must parse by shape, not by stripping to the last colon.
# A misparsed remote must never produce a confident wrong org: unrecognised
# or ambiguous forms must yield an empty signal, routing to undecided.
assert_remote_org() {
  local url="$1" expected="$2" description="$3"
  local dir="$TEST_ROOT/remote-org-cases/${#REMOTE_ORG_CASE[@]}"
  REMOTE_ORG_CASE+=("$url")
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" remote add origin "$url"
  set +e
  local out
  out="$("$TOOL" --repo "$dir")"
  set -e
  assert_contains "$out" "remote_org=$expected" "$description"
}
REMOTE_ORG_CASE=()
export NASHE_HOME="$TEST_ROOT/home4"
mkdir -p "$NASHE_HOME"

assert_remote_org "git@host:owner/name.git" "owner" \
  "scp-like remote yields the owner"
assert_remote_org "https://host/owner/name.git" "owner" \
  "https remote yields the owner"
assert_remote_org "https://host:8080/owner/name" "owner" \
  "https remote with a port yields the owner, not the port"
assert_remote_org "ssh://git@host/owner/name.git" "owner" \
  "ssh scheme remote yields the owner, not the host"
assert_remote_org "ssh://git@host:2222/owner/name.git" "owner" \
  "ssh scheme remote with a port yields the owner, not the port"
assert_remote_org "https://host/owner/name/" "owner" \
  "a trailing slash does not produce an empty or slash-laden slug"

# The stored map is keyed by the canonical physical path of the repository,
# never by the string the caller happened to type. Misfiling a repository into
# another organisation is the one failure this tool cannot produce, and keying
# on `.` produces exactly that for the second repository resolved from its own
# working directory.
export NASHE_HOME="$TEST_ROOT/home5"
mkdir -p "$NASHE_HOME"
mkdir -p "$TEST_ROOT/canon/acme/checkout" "$TEST_ROOT/canon/globex/billing"

(cd "$TEST_ROOT/canon/acme/checkout" && "$TOOL" --repo . --set acme >/dev/null)

set +e
output="$(cd "$TEST_ROOT/canon/globex/billing" && "$TOOL" --repo .)"
status=$?
set -e
if [[ "$status" -eq 3 ]]; then
  pass "a second repository resolved from its own directory is not misfiled"
else
  fail "a second repository resolved from its own directory is not misfiled"
  echo "    expected exit 3, got $status with: $output"
fi
assert_contains "$output" "path_org=globex" \
  "the second repository reports its own path signal"

output="$("$TOOL" --repo "$TEST_ROOT/canon/acme/checkout")"
assert_contains "$output" "org=acme" \
  "an absolute path reads back the answer stored through a relative one"
assert_contains "$output" "source=stored" \
  "the absolute path reads the same key as the relative one"

output="$("$TOOL" --repo "$TEST_ROOT/canon/acme/checkout/")"
assert_contains "$output" "source=stored" \
  "a trailing slash resolves to the same key"

ln -s "$TEST_ROOT/canon/acme/checkout" "$TEST_ROOT/canon/checkout-link"
output="$("$TOOL" --repo "$TEST_ROOT/canon/checkout-link")"
assert_contains "$output" "org=acme" \
  "a symlink resolves to the same key as its target"
assert_contains "$output" "source=stored" \
  "a symlink reads the stored answer of its target"

key_count="$(jq -r '.repositories | keys | length' "$NASHE_HOME/repos.json")"
if [[ "$key_count" -eq 1 ]]; then
  pass "the map holds one key for one repository, however it was named"
else
  fail "the map holds one key for one repository, however it was named"
  jq -r '.repositories' "$NASHE_HOME/repos.json" | sed 's/^/    /'
fi

if grep -Fq '"."' "$NASHE_HOME/repos.json"; then
  fail "no raw relative path is ever used as a key"
  sed 's/^/    /' "$NASHE_HOME/repos.json"
else
  pass "no raw relative path is ever used as a key"
fi

# A caller with CDPATH set must not change which directory is resolved. With a
# relative argument, `cd` consults CDPATH and jumps elsewhere, printing the path
# it landed on — which lands in the captured value and files the repository
# under the wrong organisation.
export NASHE_HOME="$TEST_ROOT/home-cdpath"
mkdir -p "$NASHE_HOME"
mkdir -p "$TEST_ROOT/trap/decoy" "$TEST_ROOT/real/decoy"
output="$(cd "$TEST_ROOT/real" && CDPATH="$TEST_ROOT/trap" "$TOOL" --repo decoy || true)"
assert_contains "$output" "path_org=real" \
  "CDPATH does not redirect a relative repository path"

# Two different directories must never share a key.
export NASHE_HOME="$TEST_ROOT/home6"
mkdir -p "$NASHE_HOME"
(cd "$TEST_ROOT/canon/acme/checkout" && "$TOOL" --repo . --set acme >/dev/null)
(cd "$TEST_ROOT/canon/globex/billing" && "$TOOL" --repo . --set globex >/dev/null)
output="$(cd "$TEST_ROOT/canon/acme/checkout" && "$TOOL" --repo .)"
assert_contains "$output" "org=acme" \
  "the first repository keeps its own organisation after a second is stored"
output="$(cd "$TEST_ROOT/canon/globex/billing" && "$TOOL" --repo .)"
assert_contains "$output" "org=globex" \
  "the second repository keeps its own organisation"

# A malformed map fails in the tool's own style, and leaves no temp file behind.
export NASHE_HOME="$TEST_ROOT/home7"
mkdir -p "$NASHE_HOME"
printf 'not json at all\n' >"$NASHE_HOME/repos.json"
set +e
output="$("$TOOL" --repo "$TEST_ROOT/canon/acme/checkout" 2>&1)"
status=$?
set -e
if [[ "$status" -eq 1 ]]; then
  pass "a malformed map exits 1"
else
  fail "a malformed map exits 1 (got $status)"
fi
assert_contains "$output" "error: " "a malformed map fails in the tool's error style"
if printf '%s' "$output" | grep -q 'jq: parse error'; then
  fail "a malformed map does not leak jq's own diagnostics"
  echo "    got: $output"
else
  pass "a malformed map does not leak jq's own diagnostics"
fi

set +e
"$TOOL" --repo "$TEST_ROOT/canon/acme/checkout" --set acme >/dev/null 2>&1
set -e
leftover="$(find "$NASHE_HOME" -maxdepth 1 -name '.repos.json.*' | wc -l | tr -d ' ')"
if [[ "$leftover" -eq 0 ]]; then
  pass "no temp file is left behind when writing against a malformed map"
else
  fail "no temp file is left behind when writing against a malformed map"
  find "$NASHE_HOME" -maxdepth 1 -name '.repos.json.*' | sed 's/^/    /'
fi

if [[ "$FAILURES" -gt 0 ]]; then
  echo "resolve-org: $FAILURES failure(s)"
  exit 1
fi
echo "resolve-org: all checks passed"
