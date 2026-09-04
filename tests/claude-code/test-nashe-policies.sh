#!/usr/bin/env bash
# Deterministic checks on the NASHE policies that customize this plugin:
# branch discipline, commit attribution, document publishing, and finishing options.
# No model calls — these read the skill files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

STARTING="$REPO_ROOT/skills/starting-a-development-branch/SKILL.md"
FINISHING="$REPO_ROOT/skills/finishing-a-development-branch/SKILL.md"
USING="$REPO_ROOT/skills/using-nashe/SKILL.md"
PUBLISHING="$REPO_ROOT/skills/using-nashe/references/document-publishing.md"

failures=0

assert_contains() {
    if grep -Fq "$2" "$1"; then
        echo "  [PASS] $3"
    else
        echo "  [FAIL] $3"
        echo "    Expected to find: $2"
        echo "    In file: $1"
        failures=$((failures + 1))
    fi
}

assert_not_contains() {
    if grep -Fq "$2" "$1"; then
        echo "  [FAIL] $3"
        echo "    Did not expect to find: $2"
        echo "    In file: $1"
        failures=$((failures + 1))
    else
        echo "  [PASS] $3"
    fi
}

assert_file() {
    if [ -f "$1" ]; then
        echo "  [PASS] $2"
    else
        echo "  [FAIL] $2 (missing: $1)"
        failures=$((failures + 1))
    fi
}

echo "=== NASHE Policy Tests ==="
echo ""

echo "-- No upstream branding survives --"
# The needle is split so this checker never matches itself.
# README.md and LICENSE-upstream carry the required attribution to the upstream
# project; everything else must be free of its name.
NEEDLE='super''power'
if grep -rniIl "$NEEDLE" "$REPO_ROOT" --exclude-dir=.git --exclude-dir=node_modules \
        --exclude=README.md --exclude=LICENSE-upstream >/dev/null 2>&1; then
    echo "  [FAIL] repository still mentions the upstream plugin name"
    grep -rniIl "$NEEDLE" "$REPO_ROOT" --exclude-dir=.git --exclude-dir=node_modules \
        --exclude=README.md --exclude=LICENSE-upstream
    failures=$((failures + 1))
else
    echo "  [PASS] no upstream-name references remain"
fi

echo ""
echo "-- Branch discipline --"
assert_file "$STARTING" "starting-a-development-branch skill exists"
assert_contains "$STARTING" 'feat/<something>' "branch format is feat/<something>"
assert_contains "$STARTING" 'git fetch origin "$MAIN"' "main branch is fetched before branching"
assert_contains "$STARTING" '.git/info/exclude' "worktree directory is excluded locally"
assert_not_contains "$STARTING" 'Add to .gitignore' "worktree directory is not added to .gitignore"
assert_contains "$STARTING" 'git worktree add ".worktrees/<something>"' "worktree is created under .worktrees/"

echo ""
echo "-- Finishing options --"
assert_contains "$FINISHING" 'Open a pull request' "PR option is offered"
assert_contains "$FINISHING" 'Leave it as is' "leave-as-is option is offered"
assert_contains "$FINISHING" 'AskUserQuestion' "the choice uses the selection UI"
assert_not_contains "$FINISHING" 'Merge back to' "local merge is not offered"
assert_not_contains "$FINISHING" 'git merge' "the skill never runs git merge"

echo ""
echo "-- Commit attribution --"
for f in "$USING" "$FINISHING" "$REPO_ROOT/skills/writing-plans/SKILL.md" \
         "$REPO_ROOT/skills/subagent-driven-development/implementer-prompt.md"; do
    assert_contains "$f" 'Co-Authored-By' "$(basename "$(dirname "$f")")/$(basename "$f") forbids attribution trailers"
done

echo ""
echo "-- Document publishing --"
assert_file "$PUBLISHING" "document-publishing reference exists"
assert_contains "$PUBLISHING" 'AskUserQuestion' "publishing choice uses the selection UI"
assert_contains "$PUBLISHING" '.git/info/exclude' "local policy uses .git/info/exclude"
assert_contains "$PUBLISHING" 'nashe-docs-policy' "the answer is stored per repository"
assert_contains "$REPO_ROOT/skills/brainstorming/SKILL.md" 'docs/specs/YYYY-MM-DD' "specs go to docs/specs/"
assert_contains "$REPO_ROOT/skills/writing-plans/SKILL.md" 'docs/plans/YYYY-MM-DD' "plans go to docs/plans/"
assert_contains "$REPO_ROOT/skills/brainstorming/SKILL.md" 'document-publishing.md' "brainstorming applies the publishing policy"
assert_contains "$REPO_ROOT/skills/writing-plans/SKILL.md" 'document-publishing.md' "writing-plans applies the publishing policy"

echo ""
echo "-- Skill naming --"
assert_file "$USING" "using-nashe skill exists"
assert_contains "$USING" 'name: using-nashe' "skill is named using-nashe"
assert_contains "$REPO_ROOT/hooks/session-start" 'skills/using-nashe/SKILL.md' "session-start injects using-nashe"

echo ""
if [ "$failures" -gt 0 ]; then
    echo "STATUS: FAILED ($failures failures)"
    exit 1
fi
echo "STATUS: PASSED"
