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

if [[ "$FAILURES" -gt 0 ]]; then
  echo "method references: $FAILURES failure(s)"
  exit 1
fi
echo "method references: all checks passed"
