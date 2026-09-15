# Extraction

What to look for per section, and what may be written as evidence.

## What counts as evidence

Evidence is something a reader can open. A path (`internal/router/router.go`), a path and a
line (`go.mod:12`), or a count over a stated population (`11/14 test files`). A count needs
its denominator: "most tests" is not evidence, "11/14 test files" is.

Evidence is never a restatement of the claim. "Testify is used for assertions
[observed: tests use Testify]" cites nothing.

Where nothing was found, the entry is `[none detected]` — not an inference, not a guess from
the ecosystem's conventions. "This is a Go service so it probably uses structured logging" is
exactly the invented requirement the entry gate exists to catch.

## Where to look, per section

| Section | Sources |
|---------|---------|
| 1. Profile | Dependency manifests, entrypoint files, presence of an HTTP server or a UI build. |
| 2. Languages and runtimes | Manifests, version files, container base images, CI runner versions. |
| 3. Frameworks and libraries | Direct dependencies only. A transitive dependency is not a choice the repository made. |
| 4. Architecture and layering | Top-level source directories, import direction between packages, where wiring happens. |
| 5. Code patterns and conventions | Repeated shapes across files: constructors, interface placement, error translation, naming. Cite the count. |
| 6. Data and persistence | Database drivers, migration directories, schema files, ORM or query-builder dependencies. |
| 7. External integrations | Clients for third-party APIs, message brokers, queues, caches. |
| 8. Testing | Test dependencies, test file naming and placement, helper packages, test commands in CI. |
| 9. Observability | Logging, metrics and tracing libraries, and their initialisation sites. |
| 10. Build, packaging and runtime | Build files, containerfiles, bundler configuration, release scripts. |
| 11. Infrastructure | Infrastructure-as-code directories, deployment manifests, environment definitions. |
| 12. CI/CD and quality gates | Pipeline definitions, required checks, coverage thresholds, lint configuration. |
| 13. Documentation | API specifications, architecture notes, README structure, docs directories. |
| 14. Security and configuration | Configuration loading, secret handling, authentication and authorisation middleware. |
| 15. Deterministic checks | The actual commands: build, test, lint, format, generate. Take them from CI or the build file rather than inventing them. |
| 16. Open questions | Contradictions found, conventions that appear half-migrated, anything a maintainer would need to settle. |

## Choosing the canonical term

The term is the name a practitioner would use, capitalised as its own project capitalises it:
`Testify`, `Gin`, `PostgreSQL`, `Mockery`. For a pattern rather than a tool, use the shortest
noun phrase that names it: `Constructor injection`, `Table-driven tests`,
`Controller-service-repository`.

The term must be stable across repositories — it is the key promotion compares. The same
library described as `Testify` in one document and `testify assertions` in another will not
be recognised as the same thing.

## Empty repositories

Where a repository has nothing to read, no section is guessed from the task at hand. The
profile is asked for, and the corresponding file under `method/defaults/` supplies the
entries, each carrying its `[default: <profile>]` marker so a reader can see it was assumed
rather than observed.
