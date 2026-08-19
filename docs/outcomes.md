# Outcomes

What NASHE is supposed to produce, and how anyone would know whether it worked.

## What "done" looks like

NASHE is finished, in its first useful form, when a developer working on an ordinary
task gets three things they do not get today.

**A task that has been checked before it is built.** The reported bug has been shown
to reproduce, or the report has been sent back with what was actually observed. The
feature has been examined for the cases its description omits — empty states,
permissions, failures, concurrency, limits — and the omissions have been closed by
research or raised as explicit questions. The result is a short, written `expected`.

**An `expected` that can be falsified.** Not "the export works", but a statement whose
truth can be established without discussion: a named check that fails now and will
pass later, a measurement with a threshold and a source, an observable state change.
If nobody can say how it would be proven wrong, it is not finished being written.

**A pull request that carries its own proof.** The evidence is an artefact — a
screenshot, a monitoring query and its result, a log line, a trace, a check that went
from failing to passing — and it is presented next to the `expected` it corresponds
to. A reviewer can see whether they match without reading the diff and without
trusting the author's summary.

## What we expect to change

**Fewer confidently wrong implementations.** The failure this project targets is not
broken code; it is working code that solves a problem nobody had, or solves the right
problem in a way the requester never meant. That failure is invisible to the existing
verification stack, which is why it survives all the way to review.

**Less review friction.** Today a reviewer reconstructs intent from the diff and the
PR description, then decides whether it looks right. With an `expected` fixed
beforehand and evidence attached, the reviewer's question narrows from "is this a good
change?" to "does this evidence show what was agreed?" — a much smaller question, and
one that does not require holding the whole feature in their head.

**Fewer interruptions, better ones.** Questions whose answers exist in the codebase,
the standards or the product documentation get researched. What reaches the user is
what only the user can decide. The expected effect is a lower volume of questions and
a higher hit rate on the ones that remain.

**Rework caught early rather than late.** A task rejected at the entry gate costs a
conversation. The same task caught at review costs an implementation, a review cycle,
and a rewrite. Moving that discovery earlier is the main economic argument for the
whole system.

## How it would be measured

An honest caveat first: **there is no baseline yet**. These are the measurements we
intend to be able to make, not results we can quote. Any of them may turn out to be
impractical or to measure the wrong thing, and this section should be revised when
that happens.

Measurements are grouped by which gate they exercise.

### Entry gate

- **Rejection rate** — the proportion of tasks that come back from the entry gate
  changed: sent back as non-reproducible, expanded with missing cases, split, or
  rejected outright. Both extremes are informative. Near zero suggests the gate is
  decorative. Very high suggests the problem is upstream in how work is written, which
  is worth knowing on its own.
- **Falsifiability rate** — the proportion of `expected` statements that name a
  concrete verification method rather than a description of intent. This is the
  measurement most at risk of being gamed, and it is the one to watch most closely.
- **Research-to-escalation ratio** — how many ambiguities were closed by investigation
  versus handed to the user. The target is not zero escalations; it is that the ones
  that remain are genuine decisions.

### Exit gate

- **Evidence coverage** — the proportion of pull requests arriving with an artefact
  attached rather than a description of the outcome.
- **Evidence-to-expectation match** — of those, the proportion where the artefact
  actually corresponds to the stated `expected`, rather than being an unrelated
  screenshot attached to satisfy the requirement.
- **Post-merge reversals for misunderstanding** — changes reverted or reworked because
  they did the wrong thing, kept separate from those reverted because of a defect. The
  first category is what NASHE targets; the second is what tests already cover. If
  only the second moves, NASHE is not working.

### The system itself

- **Time to first commit** — the entry gate adds work up front, and that cost is real.
  It has to be visible next to the savings it claims.
- **Bypass rate** — how often the gates are skipped. A control that is routinely
  worked around is not a control, and the correct response is to fix the gate, not to
  scold the user.

## What would falsify this project

Applying the project's own principle to itself: these are the results that would mean
NASHE is not worth building.

- Entry-gate rejections are consistently near zero across varied work — the tasks were
  fine all along, and the gate is ceremony.
- `expected` statements are written but nothing mechanical ever checks them, so the
  entry gate degrades into a documentation exercise.
- Evidence is attached routinely but never actually corresponds to the expectation,
  making it a compliance ritual rather than a verification.
- The added up-front cost exceeds the rework it prevents on the kind of work the team
  actually does.
- The gates cannot be enforced mechanically in practice, and the only way to make them
  stick is a model checking the model — the one thing this project refuses to do.

Any of these should be reported here, in this document, rather than quietly worked
around.

## Explicitly out of scope for the first version

- Automatic writing or rewriting of tickets in a tracking platform.
- Integration with any specific monitoring or ticketing vendor as a hard dependency.
  Adapters, yes; requirements, no.
- Metrics dashboards. Measurement here means being able to answer the questions above
  from the artefacts, not building a reporting product.
- Multi-harness support. Claude Code first; adapters once the method is proven.
