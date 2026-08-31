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

## The plugin

This repository is also a Claude Code plugin. It ships the skill set NASHE works
through — a rewritten, Claude-Code-only descendant of the `superpowers` skills library
(MIT, see `LICENSE-upstream`), with the workflow bent to this project's
rules.

### Install

```bash
claude plugin marketplace add /path/to/not-another-stupid-harness-engineer
claude plugin install nashe@nashe
```

Or, from inside a Claude Code session: `/plugin marketplace add <path>` then
`/plugin install nashe@nashe`. A `SessionStart` hook injects `using-nashe` into every
session, so the ground rules are live from the first message.

### Skills

| Skill | Use it when |
|---|---|
| `using-nashe` | Injected at session start — how skills get invoked, plus the ground rules |
| `brainstorming` | Before any creative work: intent, requirements, design, spec document |
| `writing-plans` | A spec exists and the work needs a task-by-task implementation plan |
| `starting-a-development-branch` | Before the first code edit: fresh `feat/` branch off an up-to-date main, in a worktree |
| `test-driven-development` | Implementing any feature or bugfix |
| `systematic-debugging` | Any bug, test failure, or unexpected behaviour |
| `executing-plans` | Running a written plan inline, with review checkpoints |
| `subagent-driven-development` | Running a written plan with a fresh subagent per task |
| `dispatching-parallel-agents` | Two or more independent tasks with no shared state |
| `requesting-code-review` / `receiving-code-review` | Before merging; and when handling the feedback |
| `verification-before-completion` | About to claim something works — evidence before assertions |
| `finishing-a-development-branch` | Implementation done, tests green: PR, or leave it alone |
| `writing-skills` | Creating or editing skills |

### House rules baked into the skills

- **Branches.** Work starts with a fetch of the main branch and a `feat/<something>`
  branch inside a `.worktrees/` worktree. The main checkout is never touched.
- **Commits.** No `Co-Authored-By`, no "Generated with", no emoji signature, no mention
  of the tooling anywhere in a commit, branch name, or PR body.
- **Documents.** Specs go to `docs/specs/`, plans to `docs/plans/`. Whether they are
  tracked in git is asked once per repository through the selection UI; "keep them
  local" is enforced through `.git/info/exclude`, so the choice leaves no trace in the
  repository itself.
- **Finishing.** Two outcomes only: open a pull request, or leave the branch alone.
  NASHE never merges into main.

### Tests

```bash
bash tests/claude-code/test-nashe-policies.sh     # the house rules above
bash tests/hooks/test-session-start.sh            # context injection
bash tests/claude-code/test-sdd-workspace.sh      # subagent workspace isolation
(cd tests/brainstorm-server && npm install && npm test)
```

## Scope

NASHE targets Claude Code first. The content — process, gates, templates, criteria —
is written harness-agnostic in Markdown; only the packaging layer is Claude Code
specific. Supporting another harness should mean adding an adapter, not rewriting the
method.
