# Vision

## The problem

Software teams have spent decades building verification around code, and it works.
Unit and integration tests prove the implementation matches its intent. Linters and
formatters enforce syntax and idiom. Static analysis and dependency scanners catch
known vulnerabilities. End-to-end and smoke tests prove the application behaves
correctly from the outside, which is also an indirect, high-level check on the code
underneath. Each of these is a gate, each has a clear pass/fail, and each runs without
anyone having to be persuaded.

None of them ask whether the task was worth doing, or whether it was understood.

A coding agent receives a prompt or a ticket and treats its content as ground truth.
It does not establish that the reported bug reproduces. It does not notice that the
feature description covers the happy path and nothing else. It does not ask what
should happen when the input is empty, when the user lacks permission, when the
upstream service times out. It implements what it was told, tests what it
implemented, and reports success. The verification stack downstream then confirms,
correctly and at length, that the wrong thing was built properly.

This is the origin of most of what gets called hallucination in day-to-day
engineering work. The model did not invent an API. It invented a requirement, or
inherited a bad one, and everything after that was faithful execution.

Some harnesses mitigate this with a round of clarifying questions. That helps, but it
misplaces the cost: a large share of those questions have answers that already exist
in the organisation's engineering standards, in the product documentation, in how
comparable products solve the same problem, or in a public specification. Asking a
person to retype knowledge that is already written down is not clarification. It is
an interruption.

At the other end, the same gap appears in reverse. A pull request describes what was
done in prose written by the same agent that did it. Review friction concentrates
here: the reviewer has no independent way to tell whether the change achieves what
the task was for. There is usually no screenshot, no log line, no trace, no
before-and-after — and, more importantly, nothing to compare any of it against,
because no one ever wrote down what "achieved" would look like.

## The thesis

The `spec → plan → implement` sequence already works. The gap is on either side of it.

NASHE adds two gates:

**Entry gate — prove the task before building it.** Establish that the bug reproduces
and that the feature has no holes. Resolve ambiguity by investigating sources, and
escalate to the user only for what genuinely cannot be researched: a product decision,
a trade-off, a priority. The output is an explicit `expected` — a falsifiable
statement of what will be true once the change lands.

**Exit gate — prove the outcome before merging it.** The pull request carries evidence
that exists outside the model: a screenshot, a log in a monitoring platform, a trace,
a check that failed before the change and passes after. That evidence is compared
against the `expected` fixed at the entry gate. If the two do not line up, the work is
not done, regardless of how green the test suite is.

Between the gates, nothing changes. NASHE is not a replacement for how code gets
written.

## Design principles

### 1. Deterministic verification over judgement

Every gate must answer one question: *what mechanically decides pass or fail?* If the
answer is "a model reads the output and says it looks right", the gate is not a gate.

This is not a stylistic preference. A model evaluating another model's work
reproduces the precise failure mode NASHE exists to eliminate — a confident assertion
with nothing behind it. The research literature on LLM-as-a-judge documents
self-preference bias (models systematically favour their own output, and the effect
grows with model capability), position bias, verbosity bias, and a preference for
well-formatted answers over correct ones. Stacking a judge on top of a generator does
not add certainty; it adds a second uncertain layer and hides the first.

Models are good at *shaping* criteria: turning a vague ticket into a specific,
checkable statement. That is where they belong in this system. Deciding whether the
criterion was met belongs to something that cannot be talked into a different answer.

### 2. TDD for tasks

Test-driven development works because the criterion is written before the
implementation, it is falsifiable, and it demonstrably fails first. Nothing equivalent
exists at the task level.

The same discipline applies:

- **Written first.** The `expected` is fixed before implementation, not reconstructed
  afterwards to match whatever was built.
- **Falsifiable.** "The dashboard loads faster" is not a criterion. "The p95 latency
  of the dashboard endpoint, as reported by the monitoring platform, drops below
  400ms" is.
- **Red before green.** A criterion that already passes before the change describes no
  change. For a bug, this means the reproduction must actually reproduce. If it does
  not, the task itself is in question — which is exactly the finding the entry gate
  exists to surface.

### 3. Research before asking

When something is unclear, the first move is to find the answer, not to request it.
Order of resort: the codebase and its history, the organisation's engineering
standards and internal documentation, the product's own documentation and existing
behaviour, comparable products and public specifications, and finally the user.

The user is reserved for what only they can supply: product decisions, priorities,
trade-offs between options that are all defensible. Escalating one of those is a
correct outcome, not a failure. Escalating a question whose answer was already
written down is a failure.

### 4. Evidence is an artefact, not a claim

The agent does not get to declare success. It attaches something a third party can
inspect independently: a screenshot, a log entry, a monitoring query result, a trace,
a diff of measurements. Prose describing the outcome is not evidence — it is the
thing evidence is supposed to replace.

### 5. Agnostic content, specific packaging

The method — gates, criteria, templates, escalation rules — is written as
harness-agnostic Markdown. Only the packaging layer knows about a specific harness.
Supporting a second one is a matter of adding an adapter, not rewriting the method.

### 6. A gate that cannot be enforced is documentation

A step that can be skipped without consequence will be skipped. Where a gate can be
made mechanical — a hook, a CI check, a required file, a required artefact — it
should be, and it should fail loudly. Where it genuinely cannot be, that is stated
plainly rather than dressed up as a control.

## Non-goals

**NASHE is not another spec-driven development framework.** That category is mature
and crowded — Spec Kit, Kiro, BMAD, OpenSpec, Tessl, Agent OS, and dozens more. They
solve the problem of turning intent into structured, executable specifications, and
they solve it well. NASHE assumes that layer exists and works. It targets the
question none of them ask: whether the intent was correct in the first place, and
whether the result can be proven.

**NASHE does not replace code verification.** Tests, linters, static analysis,
scanners, CI — all of it stays. NASHE sits around that stack, not inside it.

**NASHE is not a compliance or audit platform.** Evidence is collected to verify the
outcome against the stated expectation, not to satisfy an external framework. Any
audit value is a side effect.

**NASHE does not aim for full autonomy.** The goal is not an agent that never
escalates. It is an agent that escalates the *right* things — decisions only a human
can make — and stops escalating the things it could have looked up.

**NASHE is not a ticket-writing assistant.** Improving how tickets are phrased is
adjacent and useful, but the target here is the verification loop between the task
and its result, whether or not a ticketing system is involved at all.
