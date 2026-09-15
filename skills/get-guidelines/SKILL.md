---
name: get-guidelines
description: Use when starting work in a repository whose engineering conventions are not yet recorded, or when those conventions have changed - determines which organisation the repository belongs to and writes its engineering guidelines to a fixed-format document outside the repository
---

# Getting a repository's guidelines

NASHE resolves ambiguity by research before escalation, and the second source in that order
is the organisation's engineering standards. This skill is what makes that source readable:
it records how software is actually built in one repository, and what its organisation's
repositories have in common.

The documents live under `${NASHE_HOME:-$HOME/.claude/nashe}/orgs/<organisation>/`. Nothing
is ever written inside the repository being analysed.

## When it applies

Run on request. There is no automatic trigger, and no session-start check.

Run it when a repository has no document yet, or when its technologies have changed enough
that the recorded ones are wrong. Every run re-analyses and overwrites; nothing is cached.

## Steps

**1. Resolve the organisation.**

The tools live in the plugin, not in the repository being analysed, so they are invoked
through `${CLAUDE_PLUGIN_ROOT}`.

```bash
"${CLAUDE_PLUGIN_ROOT}/tools/guidelines/resolve-org" --repo "$PWD"
```

Exit 0 means it is resolved — use the printed `org=`. Exit 3 means the signals were absent or
in conflict, and the printed `remote_org=` and `path_org=` are what was seen. Ask your human
partner which organisation applies, then record the answer:

```bash
"${CLAUDE_PLUGIN_ROOT}/tools/guidelines/resolve-org" --repo "$PWD" --set "<organisation>"
```

Never pick one yourself. A repository filed under the wrong organisation contaminates that
organisation's guidelines, and promotion then spreads the contamination across every
repository in it.

**2. Determine the profile.**

`method/guidelines/extraction.md` states the signals, what to do when they are absent, and why
the profile is never taken from the task being discussed.

**3. Read the repository and fill the skeleton.**

Read `method/guidelines/document-format.md` for the skeleton and the entry rules, and
`method/guidelines/extraction.md` for what to look for per section and what may be written as
evidence. Where the repository is empty, start from `method/defaults/backend.md` or
`method/defaults/frontend.md` and keep the `[default: …]` markers.

Observation always wins. A default fills a gap; it never contradicts what is in the
repository.

Write the result to `<NASHE_HOME>/orgs/<organisation>/repos/<repository>.md`, then check it:

```bash
"${CLAUDE_PLUGIN_ROOT}/tools/guidelines/validate-document" "<path to the document>"
```

Fix what it reports. Do not edit the checker to accept the document.

**4. Promote.**

```bash
"${CLAUDE_PLUGIN_ROOT}/tools/guidelines/promote" --org "<organisation>"
```

`method/guidelines/promotion.md` states the rule this applies.

The promoted document is checked the same way the repository document was:

```bash
"${CLAUDE_PLUGIN_ROOT}/tools/guidelines/validate-document" "<NASHE_HOME>/orgs/<organisation>/org.md"
```

It is the file every repository of the organisation reads, so it is the last one that should
go unchecked.

## Red flags

| Thought | Reality |
|---------|---------|
| "It is probably a Go service, so it probably uses structured logging" | Nothing was observed. The entry is `[none detected]`. |
| "The signals conflict but the remote is usually right" | Exit 3 means ask. Guessing here is the one failure this skill cannot produce. |
| "This section has nothing, I will leave it out" | Every section is always present. An omitted section makes two runs differ. |
| "The checker is too strict about that entry" | The checker enforces the contract. Fix the entry. |
| "I will note the caveat in a sentence under the heading" | No prose in the body. Caveats go in section 16 as entries. |
| "The user asked me to build X, so this is a frontend repository" | The profile comes from the repository, or from asking. Never from the task. |
