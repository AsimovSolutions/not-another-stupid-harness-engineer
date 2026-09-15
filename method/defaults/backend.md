---
nashe_guidelines_version: 1
scope: repository
organization: example
repository: example
profile: backend
---

# Engineering guidelines — backend defaults

## 1. Profile
- Backend — HTTP service exposing a JSON API. [default: backend]

## 2. Languages and runtimes
- Go — the module manifest declares the language version. [default: backend]

## 3. Frameworks and libraries
- Gin — HTTP routing, request binding and validation. [default: backend]

## 4. Architecture and layering
- Controller-service-repository — one package per layer under an internal directory, with a thin entrypoint that builds the router and runs it. [default: backend]

## 5. Code patterns and conventions
- Constructor injection — dependencies are built once where routes are mapped and passed to constructors; no package-level mutable state. [default: backend]
- Domain errors — driver-specific errors are translated into errors declared in the shared constants package, so callers depend on the domain rather than the driver. [default: backend]
- Exported interfaces — each layer exports an interface and keeps its implementation struct unexported behind a constructor returning that interface. [default: backend]
- Query builders — repositories separate query construction from execution, and return a concrete type and an error. [default: backend]

## 6. Data and persistence
- [none detected]

## 7. External integrations
- [none detected]

## 8. Testing
### 8.1 Unit
- Table-driven tests — one case table per exported function. [default: backend]
- Testify — assertions and suites. [default: backend]

### 8.2 Integration and E2E
- Smocker — external APIs are stubbed through a mock server run in a container. [default: backend]

### 8.3 Mocks and fixtures
- Mockery — one generated mock per exported interface. [default: backend]

## 9. Observability
### 9.1 Logging
- [none detected]

### 9.2 Metrics
- [none detected]

### 9.3 Tracing
- [none detected]

## 10. Build, packaging and runtime
- Docker — multi-stage build ending on a minimal base image, running as a non-root user. [default: backend]

## 11. Infrastructure
- [none detected]

## 12. CI/CD and quality gates
- [none detected]

## 13. Documentation
- OpenAPI — the API specification is checked into the repository. [default: backend]

## 14. Security and configuration
- Environment variables — configuration is read through named constants rather than string literals at the point of use. [default: backend]

## 15. Deterministic checks
- Build — `go build ./...`. [default: backend]
- Mocks — `mockery --all`. [default: backend]
- Test — `go test ./...`. [default: backend]

## 16. Open questions
- [none detected]
