# Repository structure

How this repository is organised, and the reasoning behind it. Nothing below is built
yet — this is the target layout that the first implementation should grow into.

## The central split

The organising decision is stated in the [vision](vision.md) as principle 5: the
method is agnostic, the packaging is specific.

- **`method/`** holds the substance — what a gate checks, what makes an `expected`
  falsifiable, how ambiguity gets researched, what counts as evidence. Plain Markdown,
  no vocabulary belonging to any one harness.
- **`skills/`, `agents/`, `commands/`, `hooks/`** hold the Claude Code packaging: thin
  wrappers that make the method invocable in that harness.
- **`tools/`** holds the deterministic part — the scripts that actually decide pass or
  fail.

The test for whether the split is being respected: reading a file under `method/`
should never reveal which harness it is going to run in, and reading a file under
`skills/` should reveal almost nothing about the method that is not a pointer into
`method/`.

## Layout

```
.
├── README.md               Pitch, thesis, index
├── docs/                   Project documentation (this directory)
│   ├── vision.md           Problem, thesis, principles, non-goals
│   ├── prior-art.md        What exists, what it misses, the gap
│   ├── outcomes.md         Expected results and how they are measured
│   └── repo-structure.md   This file
│
├── method/                 Harness-agnostic content — the actual method
│   ├── gates/              One file per gate: purpose, inputs, pass/fail mechanism
│   ├── criteria/           What makes an `expected` valid; evidence taxonomy
│   ├── research/           Source ordering, when to escalate to a human
│   └── templates/          Task contract, evidence block, escalation formats
│
├── skills/                 Claude Code skills — thin wrappers over method/
├── agents/                 Subagent definitions
├── commands/               Slash commands
├── hooks/                  Enforcement points that make gates non-optional
│
├── tools/                  Deterministic checkers and scripts
│   └── tests/              Tests for those checkers
│
└── .claude-plugin/         Claude Code plugin manifest
```

The Claude Code directories sit at the repository root rather than nested under a
`packaging/` directory, so the repository is directly installable as a plugin without
a build step. The cost is that the root mixes method and packaging; the separation is
maintained by the rule above rather than by directory depth. If a second harness is
added and this becomes untenable, the packaging directories move and the plugin
manifest points at the new location.

## Conventions

**Everything is in English.** All documentation, comments, commit messages, pull
requests, code, and definitions. This repository is public and meant to be read and
used by anyone.

**No personal or organisation-specific information.** No company names, internal URLs,
project codenames, employee names, or details of any particular team's setup.
Integrations are described generically — "a monitoring platform", "an issue tracker" —
with vendor-specific details confined to adapters. Where a concrete example helps, it
is invented.

**Every gate declares what decides it.** A gate definition under `method/gates/` states
its pass/fail mechanism explicitly and names the tool that runs it. If a gate cannot
name one, it says so in plain terms and is labelled as advisory rather than
presented as a control. This is principle 6 made structural: the format does not allow
a gate to hide the fact that nothing enforces it.

**Deterministic checkers are code, and code gets tested.** Anything under `tools/`
carries its own tests. A checker that is trusted to decide pass or fail, and is itself
unverified, moves the problem rather than solving it.

**Skills stay thin.** A skill file establishes when it applies and points into
`method/`. Method content duplicated into a skill will drift from its source, and the
copy under `method/` is the one that is meant to be portable.

**Right-sized process.** Gates scale with the work. A one-line copy change and a
payment flow do not carry the same ceremony. A uniformly heavy process gets bypassed,
and a bypassed gate is worse than an absent one because it looks like a control.

## Documentation flow

The four documents in `docs/` are meant to be read in order and serve different
questions:

- **`vision.md`** — why this exists and what rules it obeys. Changes rarely; a change
  here is a change of direction.
- **`prior-art.md`** — what the rest of the world does. A snapshot with a date,
  expected to age and to be revised.
- **`outcomes.md`** — what success would look like and what would disprove the whole
  premise. Updated as real measurements replace intentions.
- **`repo-structure.md`** — this file. Updated when the layout actually changes, not
  in advance of it.

Design documents for specific pieces of work belong under `docs/specs/`, dated and
named after their topic, and are added as that work is designed.
