# Guidelines document format

A guidelines document describes how software is built in one repository, or across one
organisation. Its value depends on being the same shape every time it is produced, so that
two runs can be compared, and so that two repositories of the same organisation can be
compared to each other.

Nothing in this file is optional. `validate-document` rejects a document that departs
from it.

## Frontmatter

```yaml
---
nashe_guidelines_version: 1
scope: repository        # or: organization
organization: acme
repository: checkout     # repository scope only
profile: backend         # repository scope only: backend | frontend | unknown
---
```

There is no generation timestamp. A date would make two otherwise identical runs differ,
and the document is generated rather than authored, so its age is not meaningful.

## Sections

All sixteen headings are present in every document, in this order, whether or not anything
was found for them. Sections 8 and 9 carry the subsections shown.

```
## 1. Profile
## 2. Languages and runtimes
## 3. Frameworks and libraries
## 4. Architecture and layering
## 5. Code patterns and conventions
## 6. Data and persistence
## 7. External integrations
## 8. Testing
### 8.1 Unit
### 8.2 Integration and E2E
### 8.3 Mocks and fixtures
## 9. Observability
### 9.1 Logging
### 9.2 Metrics
### 9.3 Tracing
## 10. Build, packaging and runtime
## 11. Infrastructure
## 12. CI/CD and quality gates
## 13. Documentation
## 14. Security and configuration
## 15. Deterministic checks
## 16. Open questions
```

A section with nothing to report holds the single entry `- [none detected]`. It is never
omitted. Sections that came and went with what was found would give two runs documents with
different headings, which is the instability this format exists to remove — and the absence
of a convention is itself worth stating, because it distinguishes "checked, found nothing"
from "not checked".

## Entries

Every line of body content is a bullet. Four parts:

```
- Testify — assertions and suites. [observed: go.mod:12, 14 test files]
  ^term     ^description                ^marker
```

The canonical term comes first because it is the key promotion compares. The separator is an
em dash with a single space on each side. The description is one sentence ending in a full
stop. The marker closes the line.

Entries are sorted alphabetically by canonical term, case-insensitively, within their
section. Sorting by importance is a judgement, and a judgement is not stable between runs.

No free prose anywhere in the body — not an introduction, not a closing note, not a
parenthetical between bullets. Prose is where wording drifts between runs, and it is where a
claim can arrive without evidence attached.

## Markers

Exactly one per entry.

| Marker | Meaning |
|--------|---------|
| `[observed: <evidence>]` | Found in the repository. Evidence is a path, a path and line, or a count over a population. |
| `[default: backend]` / `[default: frontend]` | Not found; supplied by the profile defaults. |
| `[none detected]` | Nothing found and no default applies. |
| `[observed in: <repositories> (<n>/<m>)]` | Organisation scope only. The repositories the term was seen in. |

`[observed:]` must carry evidence. "Observed" with nothing after it is the failure mode the
markers exist to prevent, and the checker rejects it.

A `[none detected]` entry stands alone in its section: it means nothing was found, so it
cannot sit beside an entry that was.

## Section 15

The one section with executable content — the commands the repository actually uses:

```markdown
## 15. Deterministic checks
- Build — `go build ./...`. [observed: Dockerfile:18]
- Lint — `golangci-lint run`. [observed: .golangci.yml]
- Test — `go test ./...`. [observed: .github/workflows/ci.yml:24]
```

This is what makes the document runnable rather than only readable.
