# NASHE — Not Another Stupid Harness Engineer

**We verify code. We do not verify tasks.**

Every serious codebase has unit and integration tests to prove the implementation is
correct, linters and static analysis to enforce syntax and good practice, dependency
and vulnerability scanning to catch known risks, and end-to-end and smoke tests to
prove the application behaves correctly from the user's point of view. That is a lot
of verification, and all of it points at the same target: the code.

Nothing points at the task.

Coding agents take the prompt — or the ticket description — at face value. They do not
check that the bug is real. They do not check that the feature has holes. They
implement. When the input is wrong, the output is confidently, thoroughly, and
testably wrong. Some harnesses add a layer of clarifying questions, but most of what
they ask could have been answered by research: internal standards, product
documentation, how comparable products solve the same problem, public specifications.

NASHE is a set of skills, agents, tools and scripts that adds the missing verification
layer — around the task, not around the code.

## The two gates

**Entry gate — prove the task before building it.**
Establish that the bug reproduces and that the feature has no holes. Resolve ambiguity
by research first and by asking the user last. The output is an explicit, falsifiable
`expected`: a statement of what will be true after the change that can be checked
without anyone's opinion.

**Exit gate — prove the outcome before merging it.**
A pull request carries hard evidence: a screenshot, a log line in a monitoring
platform, a trace, a failing-then-passing check. Never the model's own assertion that
it works. That evidence is compared against the `expected` fixed at the entry gate.

Between those two gates, the existing spec → plan → implement sequence works fine.
NASHE does not try to replace it.

## The one rule that shapes everything

**Deterministic verification. No model grading another model.**

The moment a gate is decided by an LLM reading output and declaring it good, the gate
reproduces the exact failure mode NASHE exists to fix: a plausible assertion with
nothing behind it. Models are good at *shaping* a criterion. Something mechanical has
to *decide* it.

Think of it as TDD for tasks. The acceptance criterion is written before the work,
it is falsifiable, it fails before the change, and it passes after.

## Status

Early. The design is being written down before any of it is built. Nothing here is
stable yet.

## Documentation

| Document | What it covers |
|---|---|
| [Vision](docs/vision.md) | The problem, the thesis, design principles, and non-goals |
| [Prior art](docs/prior-art.md) | What already exists, what it does not do, and where the gap is |
| [Outcomes](docs/outcomes.md) | What success looks like and how it would be measured |
| [Repo structure](docs/repo-structure.md) | How this repository is organised and why |

## Scope

NASHE targets Claude Code first. The content — process, gates, templates, criteria —
is written harness-agnostic in Markdown; only the packaging layer is Claude Code
specific. Supporting another harness should mean adding an adapter, not rewriting the
method.
