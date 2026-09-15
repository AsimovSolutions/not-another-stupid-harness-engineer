#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TOOL="$REPO_ROOT/tools/guidelines/validate-document"

FAILURES=0
TEST_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

pass() { echo "  [PASS] $1"; }
fail() {
  echo "  [FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

# Writes a conforming repository-scope document to $1, then applies the sed
# expression in $2 (empty for none) to introduce a single defect.
make_document() {
  local target="$1" mutation="${2:-}"
  cat >"$target" <<'DOC'
---
nashe_guidelines_version: 1
scope: repository
organization: acme
repository: checkout
profile: backend
---

# Engineering guidelines — acme/checkout

## 1. Profile
- Backend — HTTP service with a relational store. [observed: go.mod:1]

## 2. Languages and runtimes
- Go — version 1.22. [observed: go.mod:3]

## 3. Frameworks and libraries
- Gin — HTTP routing and binding. [observed: go.mod:6]

## 4. Architecture and layering
- Controller-service-repository — one package per layer. [observed: internal/]

## 5. Code patterns and conventions
- Constructor injection — wiring confined to the router. [observed: internal/router/router.go]

## 6. Data and persistence
- PostgreSQL — primary store. [observed: go.mod:8]

## 7. External integrations
- [none detected]

## 8. Testing
### 8.1 Unit
- Testify — assertions and suites. [observed: go.mod:12]

### 8.2 Integration and E2E
- [none detected]

### 8.3 Mocks and fixtures
- Mockery — one mock per interface. [default: backend]

## 9. Observability
### 9.1 Logging
- [none detected]

### 9.2 Metrics
- [none detected]

### 9.3 Tracing
- [none detected]

## 10. Build, packaging and runtime
- Docker — multi-stage build on a minimal base. [observed: Dockerfile:1]

## 11. Infrastructure
- [none detected]

## 12. CI/CD and quality gates
- [none detected]

## 13. Documentation
- OpenAPI — specification checked into the repository. [observed: docs/swagger.yaml]

## 14. Security and configuration
- Environment variables — configuration read through named constants. [observed: internal/defines/envs.go]

## 15. Deterministic checks
- Build — `go build ./...`. [observed: Dockerfile:18]
- Test — `go test ./...`. [observed: Dockerfile:1]

## 16. Open questions
- [none detected]
DOC
  if [[ -n "$mutation" ]]; then
    sed -i.bak "$mutation" "$target"
    rm -f "$target.bak"
  fi
}

assert_valid() {
  local file="$1" description="$2"
  if "$TOOL" "$file" >/dev/null 2>&1; then
    pass "$description"
  else
    fail "$description"
    "$TOOL" "$file" 2>&1 | sed 's/^/    /'
  fi
}

assert_invalid() {
  local file="$1" needle="$2" description="$3"
  local output="" status=0
  set +e
  output="$("$TOOL" "$file" 2>&1)"
  status=$?
  set -e
  if [[ "$status" -eq 0 ]]; then
    fail "$description (accepted a bad document)"
    return
  fi
  if printf '%s' "$output" | grep -Fq -- "$needle"; then
    pass "$description"
  else
    fail "$description"
    echo "    expected a finding mentioning: $needle"
    echo "    got: $output"
  fi
}

echo "validate-document"

make_document "$TEST_ROOT/good.md"
assert_valid "$TEST_ROOT/good.md" "a conforming document is accepted"

make_document "$TEST_ROOT/missing-section.md" '/^## 11\. Infrastructure$/d'
assert_invalid "$TEST_ROOT/missing-section.md" "11. Infrastructure" \
  "a missing section is rejected"

make_document "$TEST_ROOT/bad-marker.md" 's/\[observed: go.mod:12\]/[guessed]/'
assert_invalid "$TEST_ROOT/bad-marker.md" "marker" \
  "an unrecognised marker is rejected"

make_document "$TEST_ROOT/empty-evidence.md" 's/\[observed: go.mod:12\]/[observed: ]/'
assert_invalid "$TEST_ROOT/empty-evidence.md" "evidence" \
  "an observed marker with no evidence is rejected"

make_document "$TEST_ROOT/no-marker.md" 's/- Gin — HTTP routing and binding\. \[observed: go.mod:6\]/- Gin — HTTP routing and binding./'
assert_invalid "$TEST_ROOT/no-marker.md" "marker" \
  "an entry with no marker is rejected"

make_document "$TEST_ROOT/prose.md" 's/^# Engineering guidelines — acme\/checkout$/&\n\nThis service handles checkout./'
assert_invalid "$TEST_ROOT/prose.md" "prose" \
  "free prose in the body is rejected"

make_document "$TEST_ROOT/org-marker.md" 's/\[observed: go.mod:12\]/[observed in: checkout, payments (2\/3)]/'
assert_invalid "$TEST_ROOT/org-marker.md" "organisation scope" \
  "an organisation-scope marker is rejected at repository scope"

cat >"$TEST_ROOT/unsorted.md" <<'DOC'
---
nashe_guidelines_version: 1
scope: repository
organization: acme
repository: checkout
profile: backend
---

## 1. Profile
- Zebra — last alphabetically. [observed: a]
- Alpha — first alphabetically. [observed: b]
DOC
assert_invalid "$TEST_ROOT/unsorted.md" "alphabetical" \
  "entries out of alphabetical order are rejected"

cat >"$TEST_ROOT/mixed-none.md" <<'DOC'
---
nashe_guidelines_version: 1
scope: repository
organization: acme
repository: checkout
profile: backend
---

## 1. Profile
- [none detected]
- Alpha — sits beside a none-detected entry. [observed: b]
DOC
assert_invalid "$TEST_ROOT/mixed-none.md" "none detected" \
  "a none-detected entry beside a real entry is rejected"

make_document "$TEST_ROOT/double-space-dash.md" \
  's/Gin — HTTP routing and binding\./Gin  —  HTTP routing and binding./'
assert_invalid "$TEST_ROOT/double-space-dash.md" "em dash" \
  "an em dash with more than one space on a side is rejected"

make_document "$TEST_ROOT/no-full-stop.md" \
  's/Gin — HTTP routing and binding\. \[observed: go.mod:6\]/Gin — HTTP routing and binding [observed: go.mod:6]/'
assert_invalid "$TEST_ROOT/no-full-stop.md" "full stop" \
  "a description with no closing full stop is rejected"

assert_valid "$TEST_ROOT/good.md" \
  "a lone [none detected] entry stays valid under the em dash and full stop checks"

make_document "$TEST_ROOT/missing-middle.md" \
  '/^## 8\. Testing$/,/^## 9\. Observability$/{/^## 9\. Observability$/!d;}'
missing_middle_output="$("$TOOL" "$TEST_ROOT/missing-middle.md" 2>&1)" || true
if printf '%s' "$missing_middle_output" | grep -Fq -- "missing section: 8. Testing"; then
  if printf '%s' "$missing_middle_output" | grep -Fq -- "missing section: 16. Open questions"; then
    fail "a deleted middle section is reported missing without a false claim about a present section"
    echo "    section 16 is present in the document but was reported missing"
    echo "    got: $missing_middle_output"
  else
    pass "a deleted middle section is reported missing without a false claim about a present section"
  fi
else
  fail "a deleted middle section is reported missing without a false claim about a present section"
  echo "    expected a finding mentioning: missing section: 8. Testing"
  echo "    got: $missing_middle_output"
fi

# An empty section is the checker's core claim: a section with nothing to
# report holds `- [none detected]`, so that two runs are comparable.
make_document "$TEST_ROOT/empty-section.md" \
  '/^## 11\. Infrastructure$/,/^## 12\./{/^- \[none detected\]$/d;}'
assert_invalid "$TEST_ROOT/empty-section.md" "no entries" \
  "a section with no entry at all is rejected"

make_document "$TEST_ROOT/empty-subsection.md" \
  '/^### 9\.2 Metrics$/,/^### 9\.3/{/^- \[none detected\]$/d;}'
assert_invalid "$TEST_ROOT/empty-subsection.md" "no entries" \
  "a subsection with no entry at all is rejected"

make_document "$TEST_ROOT/no-title.md" '/^# Engineering guidelines/d'
assert_invalid "$TEST_ROOT/no-title.md" "title" \
  "a document with no H1 title is rejected"

make_document "$TEST_ROOT/duplicate-term.md" \
  's/^- Test — `go test \.\/\.\.\.`\. \[observed: Dockerfile:1\]$/- Build — `go vet .\/...`. [observed: Dockerfile:2]/'
assert_invalid "$TEST_ROOT/duplicate-term.md" "duplicate" \
  "a canonical term repeated within a section is rejected"

make_document "$TEST_ROOT/double-space-marker.md" \
  's/binding\. \[observed: go.mod:6\]/binding.  [observed: go.mod:6]/'
assert_invalid "$TEST_ROOT/double-space-marker.md" "one space" \
  "two spaces before the marker are rejected"

# Sections 8 and 9 carry subsections. An entry under the parent heading is
# ambiguous about which subsection owns it, and promote drops it silently.
make_document "$TEST_ROOT/orphan-8.md" \
  's/^## 8\. Testing$/&\n- Orphan — sits under the parent heading. [observed: a]/'
assert_invalid "$TEST_ROOT/orphan-8.md" "subsection" \
  "an entry directly under section 8 is rejected"

make_document "$TEST_ROOT/orphan-9.md" \
  's/^## 9\. Observability$/&\n- Orphan — sits under the parent heading. [observed: a]/'
assert_invalid "$TEST_ROOT/orphan-9.md" "subsection" \
  "an entry directly under section 9 is rejected"

if [[ "$FAILURES" -gt 0 ]]; then
  echo "validate-document: $FAILURES failure(s)"
  exit 1
fi
echo "validate-document: all checks passed"
