# Document Publishing Policy

Specs and plans always land in the same place — `docs/specs/YYYY-MM-DD-<topic>-design.md` and
`docs/plans/YYYY-MM-DD-<feature>.md`. What changes per repository is whether git tracks them.

Ask once per repository. Reuse the answer for every later document in that repository.

## Step 1: Read the stored answer

```bash
GIT_COMMON=$(git rev-parse --git-common-dir)
POLICY_FILE="$GIT_COMMON/nashe-docs-policy"
cat "$POLICY_FILE" 2>/dev/null
```

`tracked` or `local` means the question is already answered — skip to Step 3.
Empty or missing means ask.

The file lives inside `.git/`, so the answer never reaches the remote and never appears
in anyone else's clone.

## Step 2: Ask, using the selection UI

Ask with the `AskUserQuestion` tool — a plain prose question is the wrong instrument here,
your human partner should get pickable options.

- **Question:** "Should the spec and plan documents for this work be tracked in git and pushed to the remote?"
- **Header:** `Docs`
- **Option 1 — "Track in the repo":** "Written to `docs/specs/` and `docs/plans/`, committed, and pushed with the branch. Reviewers on the PR can read the spec and plan."
- **Option 2 — "Keep them local":** "Same paths, but excluded through `.git/info/exclude` so they are invisible to git. Nothing about them reaches the remote or other clones."

Record the answer:

```bash
printf 'tracked\n' > "$POLICY_FILE"   # or: printf 'local\n' > "$POLICY_FILE"
```

## Step 3: Apply the policy

### tracked

Write the document, `git add` it, and commit it with the rest of the work. Commit message
follows the repo's convention and mentions no tooling (see the Commits ground rule in
`nashe:using-nashe`).

### local

Make the exclusion idempotent before writing the document:

```bash
GIT_COMMON=$(git rev-parse --git-common-dir)
EXCLUDE="$GIT_COMMON/info/exclude"
mkdir -p "$(dirname "$EXCLUDE")"
for pattern in 'docs/specs/' 'docs/plans/'; do
  grep -qxF "$pattern" "$EXCLUDE" 2>/dev/null || printf '%s\n' "$pattern" >> "$EXCLUDE"
done
```

`.git/info/exclude` is per-clone and never versioned: the paths stay ignored locally
without a `.gitignore` change that would advertise the workflow in the repository.

Then write the document and never `git add` it. If `git status` ever shows those paths,
the exclusion did not apply — fix it before committing anything.

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'll just put it in `.gitignore`" | A `.gitignore` entry is committed, visible to everyone, and outlives the branch. Use `.git/info/exclude`. |
| "They said `local` last week, but this feels like a repo-worthy spec" | The answer is per-repository and stored. Honor it; ask again only if they bring it up. |
| "I'll ask in chat instead of the tool" | Use `AskUserQuestion`. The pickable options are the point. |
| "`git add -A` is faster" | Under `local`, a stray `git add -A` before the exclusion is applied publishes the document. Apply the exclusion first, then stage explicit paths. |
