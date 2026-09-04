---
name: starting-a-development-branch
description: Use before the first code edit of any task - cuts a fresh feat/ branch from an up-to-date main inside an isolated worktree, so the human partner's checkout is never touched
---

# Starting a Development Branch

## Overview

No code gets written on the branch your human partner is standing on, and no code gets
written on top of a stale main. Every task starts the same way: fetch the main branch,
cut `feat/<something>` from it, and work in an isolated worktree.

**Core principle:** Fresh base, new branch, isolated workspace — before the first edit.

**Announce at start:** "I'm using the starting-a-development-branch skill to set up the workspace."

## Step 0: Detect Existing Isolation

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside a git submodule. Verify:

```bash
# If this prints a path, you are in a submodule, not a worktree — treat as a normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**If `GIT_DIR != GIT_COMMON` (and not a submodule):** you are already in a linked worktree.
Do NOT create another one. Check the branch:

- On a `feat/…` branch → report "Already in isolated workspace at `<path>` on `<branch>`." and skip to Step 4.
- On some other named branch → report the branch and ask whether to keep it or cut a `feat/` branch here.
- Detached HEAD → externally managed workspace. Cut the branch in place:
  `git switch -c feat/<something>`, then skip to Step 4.

**If `GIT_DIR == GIT_COMMON`:** normal checkout. Continue.

## Step 1: Refresh the Main Branch

Find the main branch instead of assuming it:

```bash
MAIN=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
[ -n "$MAIN" ] || MAIN=$(git branch --list main master | head -1 | tr -d ' *')
git fetch origin "$MAIN"
```

`origin/$MAIN` is now the base. Branch from that ref — not from the local `$MAIN`, which
may be behind, and not from whatever branch happens to be checked out.

**If there is no `origin` remote:** the local `$MAIN` is the base. Say so, and continue.

## Step 2: Name the Branch

Format is `feat/<something>` — always, whatever the nature of the work.

- Derive `<something>` from the task: kebab-case, three or four words, describing the change
  (`feat/retry-webhook-delivery`), not the ticket process.
- A ticket id belongs in it when there is one: `feat/PAY-1423-retry-webhook-delivery`.
- Nothing about the tooling goes in the name — no `claude`, no `nashe`, no `ai`.

Check the name is free: `git rev-parse --verify "feat/<something>" 2>/dev/null` should fail.
If it exists, ask your human partner whether to reuse that branch or pick another name.

## Step 3: Create the Isolated Worktree

Worktrees live in `.worktrees/` at the repo root. Exclude that directory **locally** first —
through `.git/info/exclude`, never `.gitignore`, so nothing about this workflow is committed
to the repository:

```bash
GIT_COMMON=$(git rev-parse --git-common-dir)
EXCLUDE="$GIT_COMMON/info/exclude"
mkdir -p "$(dirname "$EXCLUDE")"
grep -qxF '.worktrees/' "$EXCLUDE" 2>/dev/null || printf '.worktrees/\n' >> "$EXCLUDE"
git check-ignore -q .worktrees   # must succeed before the next command runs
```

Then create it, branching from the freshly fetched base:

```bash
git worktree add ".worktrees/<something>" -b "feat/<something>" "origin/$MAIN"
cd ".worktrees/<something>"
```

**If a native worktree tool exists in your harness** (`EnterWorktree`, `/worktree`, a
`--worktree` flag): prefer it, and set the branch to `feat/<something>` afterwards if the
tool named it something else. Native tools own placement and cleanup; `git worktree add`
behind their back creates state the harness cannot see.

**Sandbox fallback:** if `git worktree add` fails with a permission error, say the sandbox
blocked worktree creation, then cut the branch in place instead —
`git switch -c "feat/<something>" "origin/$MAIN"` — and continue. Never start editing on the
branch your human partner had checked out.

## Step 4: Project Setup

```bash
if [ -f package.json ]; then npm install; fi
if [ -f Cargo.toml ]; then cargo build; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi
if [ -f go.mod ]; then go mod download; fi
```

## Step 5: Verify Clean Baseline

Run the project's test suite (`npm test` / `cargo test` / `pytest` / `go test ./...`).

**If tests fail:** report the failures and ask whether to proceed or investigate. A dirty
baseline makes every later failure ambiguous.

**If tests pass:** report.

```
Worktree ready at <full-path>
Branch feat/<something> from origin/<main> (<short-sha>)
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Quick Reference

| Situation | Action |
|-----------|--------|
| Already in a linked worktree on `feat/…` | Skip creation, go to setup |
| Already in a worktree on another branch | Ask: keep it, or cut `feat/…` here |
| Detached HEAD | `git switch -c feat/<something>` in place |
| In a submodule | Treat as a normal repo |
| Normal checkout | Fetch `origin/<main>`, worktree + `feat/…` branch |
| `.worktrees/` not ignored | Add to `.git/info/exclude` — never `.gitignore` |
| Branch name already taken | Ask before reusing |
| No `origin` remote | Base on local main, say so |
| Permission error on worktree add | Branch in place, report the fallback |
| Baseline tests fail | Report and ask |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "The current branch is clean, I can just work here" | Your human partner's checkout is theirs. Cut a branch in a worktree. |
| "Local main was pulled recently enough" | `git fetch` costs a second. Branching from a stale base costs a rebase. |
| "`git worktree add` is quicker than finding the native tool" | A native tool owns placement, branching, and cleanup. Bypassing it creates state the harness cannot see. |
| "`.gitignore` is the normal place for `.worktrees/`" | A `.gitignore` line is committed and visible to everyone. `.git/info/exclude` is local and leaves no trace. |
| "`fix/` fits this work better" | The format is `feat/<something>`, whatever the nature of the change. |
| "I'll name the branch after the tool that made it" | Nothing in the repository names the tooling. Not branches, not commits, not PRs. |
| "The workspace is fresh, baseline tests can wait" | Then the first red test is ambiguous. Run them now. |
