#!/usr/bin/env bash
# Every repository-relative path named by the skill or the method files must
# exist. A pointer into method/ that rots turns a thin skill into a broken one.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

FAILURES=0

pass() { echo "  [PASS] $1"; }
fail() {
  echo "  [FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

echo "method references"

SOURCES=(
  "skills/get-guidelines/SKILL.md"
  "method/guidelines/document-format.md"
  "method/guidelines/extraction.md"
  "method/guidelines/promotion.md"
)

for source in "${SOURCES[@]}"; do
  if [[ -f "$REPO_ROOT/$source" ]]; then
    pass "$source exists"
  else
    fail "$source exists"
    continue
  fi

  # Repository-relative paths, with or without the plugin-root prefix the
  # skill uses to invoke the tools.
  while IFS= read -r referenced; do
    [[ -n "$referenced" ]] || continue
    if [[ -e "$REPO_ROOT/$referenced" ]]; then
      pass "$source -> $referenced"
    else
      fail "$source -> $referenced (does not exist)"
    fi
  done < <(grep -oE '(\$\{CLAUDE_PLUGIN_ROOT\}/)?(method|tools|skills)/[A-Za-z0-9._/-]+' \
    "$REPO_ROOT/$source" \
    | sed 's|^\${CLAUDE_PLUGIN_ROOT}/||' | sed 's|/$||' | sort -u)
done

# The skill must declare a name and a description in its frontmatter.
skill="$REPO_ROOT/skills/get-guidelines/SKILL.md"
if [[ -f "$skill" ]]; then
  if head -5 "$skill" | grep -q '^name: get-guidelines$'; then
    pass "the skill declares its name"
  else
    fail "the skill declares its name"
  fi
  if head -5 "$skill" | grep -q '^description: '; then
    pass "the skill declares a description"
  else
    fail "the skill declares a description"
  fi
fi

# The promoted org.md is generated the same way a repository document is, and
# is read the same way. Leaving it unchecked means the one file every
# repository of an organisation consults is the one nothing validates.
if [[ -f "$skill" ]]; then
  if grep -q 'validate-document" .*org\.md' "$skill"; then
    pass "the skill validates the promoted org.md"
  else
    fail "the skill validates the promoted org.md"
  fi
fi

# Portable content lives under method/. The profile-detection rule is method,
# not packaging, so the skill points at it rather than restating it.
extraction="$REPO_ROOT/method/guidelines/extraction.md"
if grep -q '^## Detecting the profile$' "$extraction"; then
  pass "extraction.md states how the profile is detected"
else
  fail "extraction.md states how the profile is detected"
fi
if [[ -f "$skill" ]] && grep -qi 'where a backend manifest is present' "$skill"; then
  fail "the skill does not restate the profile-detection rule"
else
  pass "the skill does not restate the profile-detection rule"
fi
# The rationale is method content too, and it is the half most likely to be
# copied back into the skill as a reminder. Guard the phrasing, not just the
# signals: a copy that drifts is worse than no copy, because two files then
# disagree about the same rule.
if [[ -f "$skill" ]] && grep -qi 'depending on how the conversation opened' "$skill"; then
  fail "the skill does not restate why the profile is not taken from the task"
else
  pass "the skill does not restate why the profile is not taken from the task"
fi

if [[ "$FAILURES" -gt 0 ]]; then
  echo "method references: $FAILURES failure(s)"
  exit 1
fi
echo "method references: all checks passed"
