# Prior art

This document records what already exists, what each tool does well, what it does not
do, and where that leaves a gap for NASHE. It is a snapshot taken in August 2026;
this space moves quickly, and corrections are welcome.

The question asked of every tool below is narrow and specific:

1. Does it verify that the **task** is correct and complete before implementation, or
   does it only formalise what the user said?
2. Does it require **evidence** of the outcome, comparable against something agreed
   beforehand?
3. When it verifies, is the verdict **mechanical** or does a model decide?

## Spec-driven development frameworks

Spec-driven development (SDD) emerged in 2025 as the answer to unstructured "vibe
coding": treat a written specification, not the chat history, as the source of truth.
By 2026 the category counts more than thirty frameworks, with Spec Kit, BMAD and
OpenSpec dominating actual engineering conversation.

The category is mature, well-funded and genuinely useful. It is also, without
exception, built on one assumption: **the intent handed to it is correct**.

### GitHub Spec Kit

A CLI that drives a pipeline of slash commands — `constitution`, `specify`, `plan`,
`tasks`, `implement`, `converge` — supporting 30+ coding agents including Claude Code.
It is the most widely adopted open-source option in the category.

For ambiguity it offers `/clarify` ("clarify underspecified areas, recommended before
`/plan`") and `/checklist` (validate "requirements completeness, clarity, and
consistency"), plus `/analyze` for cross-artifact consistency.

**What it does not do:** it does not validate correctness — it formalises user intent,
making specifications executable from what the user specified rather than
independently verifying that what they specified is right. `/clarify` is optional and
user-initiated, so the default path implements an unexamined request. There is no
requirement for evidence of the outcome; the workflow assumes the agent followed the
tasks.

**What NASHE takes from it:** the phase decomposition and the idea of a project
constitution as persistent, injected context.

### Kiro

An AI IDE built on Code OSS that puts specs front and centre. A spec produces three
files: `requirements.md` (user stories with acceptance criteria), `design.md`
(architecture and sequence diagrams) and `tasks.md` (a tracked implementation plan).

**What it does not do:** acceptance criteria are derived from what the user described,
not contrasted against any external source. The workflow emphasises *tracking
progress* — tasks marked in-progress and complete, with real-time status — rather than
mechanical validation. There is no evidence collection at completion and no automated
verification that the acceptance criteria were actually met.

**What NASHE takes from it:** acceptance criteria as a first-class artefact of the
requirements phase, written before design.

### OpenSpec

Repo-resident living specs with delta tracking. `/opsx:propose` produces a change
directory with `proposal.md`, `specs/`, `design.md` and `tasks.md`; requirements are
written as plain Markdown scenarios in WHEN/THEN form. Specs must be reviewed before
code is written.

**What it does not do:** validation is model-based and human-reviewed — "your AI
writes these; you review the plan before any code is written". The WHEN/THEN scenarios
are structurally close to falsifiable criteria, but nothing mechanically checks that a
scenario failed before the change and passes after.

**What NASHE takes from it:** the scenario format, and the discipline of keeping the
contract in the repository where it is versioned alongside the diff. Its
`spec-as-source` variants that add file-ownership targets and test-verification
metadata are the closest thing in the category to a mechanical link between a
requirement and its proof.

### BMAD-METHOD

A multi-agent orchestration framework spanning the full lifecycle, with a delivery
loop of Clarify → Plan → Build and verify → Learn and adjust, and specialised agent
roles covering product, architecture, UX, development and testing. It explicitly
right-sizes process: clear changes go straight to build, complex initiatives get
deeper planning.

**What it does not do:** the Clarify phase is a conversation, not a gate. Verification
comes from "specialised perspectives" and "multiple-agent discussions" — that is, one
model's output assessed by another model's persona — with final judgement resting on
the human. There is no deterministic pass/fail and no evidence requirement.

**What NASHE takes from it:** right-sizing. A one-line copy fix should not carry the
same ceremony as a payment flow, and a gate that is uniformly heavy gets bypassed.

### Agent OS

Positioned for standards injection rather than durable specs: it discovers patterns
from an existing codebase, indexes them, and injects the relevant standards
contextually during development, then helps shape better specs.

**What it does not do:** there is no outcome verification and no evidence-based
validation. It improves the inputs an agent works from; it does not check the result.

**What NASHE takes from it:** the insight that most "clarifying questions" are
answerable from standards that already exist in the codebase — the mechanism behind
NASHE's *research before asking* principle.

### Tessl

Spec-as-source with living specs, pursuing the strongest form of the idea: the spec is
the artefact you edit, and code is derived or continuously reconciled from it.

**What it does not do:** the same blind spot in its purest form. If the spec is the
source of truth, the question of whether the spec is *true* becomes the entire risk,
and the framework does not address it.

## Task and ticket validation

This is the closest existing work to NASHE's entry gate.

### Qodo Merge — Jira ticket compliance

Surfaces ticket details — description, acceptance criteria, relevant comments,
dependencies — inside the pull request, so reviewers can check that the code meets the
requirements stated in the ticket.

**What it does not do:** it verifies that the code matches the ticket, never that the
ticket is well-formed. In practice it is a context-surfacing tool: it retrieves and
displays ticket information so a human can judge alignment, rather than making an
automated compliance determination.

### Tabnine agents for Jira

Implements and validates Jira issues from the tracker, with a validation agent that
checks the code accurately captures the requirements outlined in the issue and
suggests changes when it does not.

**What it does not do:** the reference point is again the issue as written. An issue
describing a bug that does not reproduce, or a feature missing its error cases, passes
validation as long as the code matches it.

### Jira-Tickets-AI

An agent skill that turns an LLM into a technical product owner: it pushes back on
vague requirements, tracks upstream blockers, and enforces Definition of Ready and
Definition of Done checks, flagging tickets as BLOCKED when prerequisites are unmet.

This is the nearest thing to an entry gate that exists today, and it validates the
right object — the ticket rather than the code.

**What it does not do:** validation is conversational and model-dependent. It
interviews the user to fill gaps rather than researching sources autonomously, and the
DoR/DoD checks are checklist items in the generated ticket, not enforced conditions.
Its notion of "ready" is structural (are the fields filled in?) rather than
substantive (is the described behaviour actually the right behaviour?).

## Evidence collection

Evidence of outcomes exists in the industry — but as an audit artefact, disconnected
from any expectation set beforehand.

### Compliance evidence tooling

Tools in the SOC 2 / SOX ITGC space capture timestamped, PII-redacted screenshots and
logs across the chain from ticket to pull request approval to deployment log, feeding
GRC platforms.

**What it does not do:** the evidence proves a *process* was followed — an approval
happened, a pipeline ran, a deployment occurred. It says nothing about whether the
change achieved what it was supposed to achieve. There is no expectation to compare
it against.

### Agent-captured screenshots

Several coding agents can now drive a browser, inspect what they built, iterate, and
attach screenshots to their output.

**What it does not do:** the capability exists, but it is ad hoc and self-directed.
The agent decides what to capture, when, and whether the result looks right — which
puts the model back in the judge's seat. Nothing requires the artefact, and nothing
binds it to a criterion agreed in advance.

## Academic work

### Process taxonomy for agent frameworks

*From Prompt to Process: a Process Taxonomy and Comparative Assessment of Frameworks
Supporting AI Software Development Agents* (arXiv:2606.04967) assesses six frameworks
— Spec Kit, OpenSpec, BMAD, Get Shit Done, Spec Kitty and Reversa — across six
dimensions: Specification, Context, Roles, Execution, **Validation** and Portability.

Two findings matter here. First, no framework comprehensively addresses all six
dimensions, and the field lacks benchmarks for the complete process. Second, the
convergent patterns that reduce ambiguity across successful frameworks are persistent
artefacts, **work contracts**, traceability and human review — with adoption still
incomplete. The paper also names a structural trade-off between process depth and
portability across agents, which is exactly the tension behind NASHE's
agnostic-content / specific-packaging split.

The "work contract" the paper identifies as a convergent pattern is close to what
NASHE calls the `expected`, with one difference: NASHE requires it to be falsifiable
and mechanically checkable, not merely written down.

### Requirements quality with LLMs

A body of work evaluates LLMs assessing requirements against quality criteria such as
INVEST (Independent, Negotiable, Valuable, Estimable, Small, Testable) and detecting
ambiguity, with models scoring highly at classifying whether requirements satisfy
given quality dimensions and proposing improved versions.

This supports one half of NASHE's approach — models are good at *shaping* a criterion
— while saying nothing about who should decide whether the criterion was met.

### Reproduction-first bug fixing

Work on agent validators establishes the pattern NASHE generalises: the validator
generates reproduction tests expected to fail on the buggy version and pass on the
patched one, and the bug is treated as reproduced only when at least one test fails on
the buggy version.

This is red-green applied to a bug report, and it is precisely the mechanism the entry
gate needs — a bug that cannot be made to fail is a bug whose existence is unproven.
NASHE's contribution is extending the same logic beyond bugs, to features, and beyond
tests, to any mechanically checkable artefact.

### LLM-as-a-judge reliability

Research through 2025 and 2026 documents systematic failures in using models to
evaluate models: self-preference bias, where models disproportionately favour their
own generated responses and where larger, more capable models often show *stronger*
self-preference; position bias; verbosity bias; and preference for well-formatted
responses. The summary that matters: if the judge is itself an imperfect system, the
entire evaluation stack rests on uncertain foundations.

Proposed mitigations — cross-family judges, panels of disjoint evaluators — reduce the
effect without removing it, and add cost and complexity. NASHE takes the stronger
position: where a mechanical check is possible, use it; where it is not, escalate to a
human rather than manufacture confidence with a second model.

## The gap

Laid out together, the pattern is consistent:

| Concern | State of the art |
|---|---|
| Turning intent into structured specs | Solved, many times over |
| Checking the intent is correct | Optional, conversational, user-initiated |
| Resolving ambiguity | By asking the user, not by researching |
| Proving the code is correct | Solved: tests, linters, scanners, CI |
| Proving the outcome matches the intent | A human reads the PR, or a model asserts it |
| Evidence of outcomes | Exists for compliance, unconnected to any expectation |
| Deterministic task-level gates | Absent |

Both halves of the loop exist in isolation. An entry gate exists as a checklist of
ticket fields. Evidence exists as an audit trail. Nothing connects them — no artefact
that is agreed before the work, falsifiable, and mechanically compared against
evidence after.

That connection is what NASHE is for.

## Sources

- GitHub Spec Kit — https://github.com/github/spec-kit
- BMAD-METHOD — https://github.com/bmad-code-org/BMAD-METHOD
- OpenSpec — https://github.com/Fission-AI/OpenSpec
- Agent OS — https://github.com/buildermethods/agent-os
- Kiro — https://kiro.dev
- Tessl — https://tessl.io
- Qodo Merge and Jira ticket compliance — https://www.qodo.ai/blog/qodo-merge-jira-ensuring-code-quality-through-ticket-compliance/
- Tabnine AI agents for Atlassian Jira — https://www.tabnine.com/blog/introducing-tabnines-ai-agents-for-atlassian-jira/
- Jira-Tickets-AI — https://github.com/datexland/Jira-Tickets-AI
- *From Prompt to Process* — https://arxiv.org/abs/2606.04967
- *Can LLMs Generate User Stories and Assess Their Quality?* — https://arxiv.org/pdf/2507.15157
- *Leveraging LLMs for the Quality Assurance of Software Requirements* — https://arxiv.org/pdf/2408.10886
- *Self-Preference Bias in LLM-as-a-Judge* — https://arxiv.org/pdf/2410.21819
- *Quantifying and Mitigating Self-Preference Bias of LLM Judges* — https://arxiv.org/html/2604.22891v2
