---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work
---

# Finishing a Development Branch

## Overview

**Core principle:** Verify tests → Present two options → Execute the choice.

NASHE never merges into the main branch. The work either becomes a pull request, or it
stays exactly where it is for your human partner to handle. Those are the only two
outcomes.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## Step 1: Verify Tests

Run the project's full test suite (`npm test` / `cargo test` / `pytest` / `go test ./...`).

**If tests fail**, report the failures and stop — the menu comes after a green suite:

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]
```

**If tests pass:** continue.

## Step 2: Confirm the Base Branch

The base branch is whatever this work forked from — normally the main branch the
`nashe:starting-a-development-branch` skill fetched. If it is not already known, ask:
"This branch split from <your best guess> — is that correct?" A PR against the wrong base
is noisy to fix.

## Step 3: Present the Options

Ask with the `AskUserQuestion` tool so the choice is pickable, not typed:

- **Question:** "Implementation is complete and tests pass. What should happen with `feat/<something>`?"
- **Header:** `Finish`
- **Option 1 — "Open a pull request":** "Push the branch to origin and open a PR against `<base>`. The worktree stays for review feedback."
- **Option 2 — "Leave it as is":** "Nothing is pushed. Branch and worktree stay put and you take it from here."

Present exactly these two. Merging locally is not on the menu — that decision belongs to
your human partner and the PR. Discarding the work happens only when they explicitly ask
for it (see below).

## Step 4: Execute the Choice

### Option 1: Open a Pull Request

Commit anything still outstanding first — with authorship that carries no tooling marks:
no `Co-Authored-By` trailer, no "Generated with" line, no emoji, no mention of Claude,
Claude Code, or NASHE, in the commit message or anywhere else.

Under the `local` document policy, verify the spec and plan are not staged before you
push (`git status --porcelain` should not list `docs/specs/` or `docs/plans/`). See
`skills/using-nashe/references/document-publishing.md`.

```bash
git push -u origin feat/<something>
# From a detached HEAD: git push origin HEAD:refs/heads/feat/<something>
```

Then open the pull request against the base branch with the forge's tooling — `gh pr
create` where available, or the creation URL the push prints — following the repo's PR
template and conventions if present.

**The PR title and body are your human partner's words, not a tool's signature.** Describe
the change, the reasoning, and how it was verified. No attribution footer, no generated-by
line, no emoji signature.

Report the PR URL. Keep the worktree — feedback gets addressed there.

### Option 2: Leave It As Is

Nothing is pushed and nothing is deleted. Report:

```
Branch feat/<something> left as is. Worktree preserved at <path>.
Nothing pushed to origin.
```

### If your human partner asks to discard the work

Only in response to an explicit request to throw the work away. Confirm first:

```
This will permanently delete:
- Branch feat/<something>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for that exact word. When it arrives:

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"   # only if it lives under .worktrees/ or worktrees/
git worktree prune
git branch -D feat/<something>
```

**If removal is refused** (`contains modified or untracked files`): the worktree holds
files that exist nowhere else. Never `--force` on your own initiative. Show
`git -C "$WORKTREE_PATH" status --porcelain -uall` and ask whether to commit them, move
them, or delete them.

**Worktrees outside `.worktrees/` or `worktrees/`** belong to the host environment — leave
them in place. If your platform provides a workspace-exit tool, use it.

## Quick Reference

| Option | Commit | Push | PR | Keep worktree | Delete branch |
|--------|--------|------|----|---------------|---------------|
| 1. Pull request | yes | yes | yes | yes | - |
| 2. Leave as is | - | - | - | yes | - |
| Discard (explicit request only) | - | - | - | - | yes (force) |

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "This is trivial, merging to main is faster" | Merging is not on the menu. PR or leave it. |
| "Tests passed earlier this session" | Run the suite on the tree you are about to push. A green run only proves the tree it ran on. |
| "A `Co-Authored-By` trailer is just honest credit" | The repository reads as your human partner's work. No trailer, no footer, no emoji, no tool name. |
| "They obviously want a PR" | Ask. The integration decision is theirs, through the selection UI. |
| "They seem done with this — I'll offer to discard it" | The menu is two options. Discard happens only when they ask for it in so many words. |
| "'Yeah, get rid of it' counts as confirmation" | Only the typed word `discard` authorizes deletion. |
| "The PR is up, the worktree is clutter now" | PR feedback gets fixed in that worktree. It stays until the work lands. |
| "The push was rejected — force-push will fix it" | A rejected push means the remote moved. Investigate; force-push only on explicit request. |
| "Removal refused — `--force` finishes the cleanup" | The refusal means files exist only there. Show your human partner and ask. |
