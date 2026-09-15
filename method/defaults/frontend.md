---
nashe_guidelines_version: 1
scope: repository
organization: example
repository: example
profile: frontend
---

# Engineering guidelines — frontend defaults

## 1. Profile
- Frontend — single-page application served as static assets. [default: frontend]

## 2. Languages and runtimes
- TypeScript — strict mode enabled. [default: frontend]

## 3. Frameworks and libraries
- React — component model and rendering. [default: frontend]
- React Router — client-side routing. [default: frontend]
- Tailwind — styling through utility classes. [default: frontend]
- TanStack Query — server state, caching and revalidation. [default: frontend]
- Vite — development server and production build. [default: frontend]

## 4. Architecture and layering
- Feature folders — source is organised by feature, each owning its data hooks, components and types; shared presentational components live apart from any feature. [default: frontend]

## 5. Code patterns and conventions
- Colocated data hooks — network access lives in hooks under a feature's api directory, so components do not know about HTTP. [default: frontend]
- One component per file — named after the file, with its own props type. [default: frontend]

## 6. Data and persistence
- [none detected]

## 7. External integrations
- [none detected]

## 8. Testing
### 8.1 Unit
- React Testing Library — components are exercised through the accessible tree rather than through internals. [default: frontend]
- Vitest — unit and component test runner. [default: frontend]

### 8.2 Integration and E2E
- Playwright — end-to-end tests against a built application. [default: frontend]

### 8.3 Mocks and fixtures
- MSW — network responses are stubbed at the request layer, shared between tests and local development. [default: frontend]

## 9. Observability
### 9.1 Logging
- [none detected]

### 9.2 Metrics
- [none detected]

### 9.3 Tracing
- [none detected]

## 10. Build, packaging and runtime
- Vite — production build emitting static assets. [default: frontend]

## 11. Infrastructure
- [none detected]

## 12. CI/CD and quality gates
- [none detected]

## 13. Documentation
- [none detected]

## 14. Security and configuration
- Environment variables — configuration is exposed to the client through the build tool's public prefix, and nothing secret is read in client code. [default: frontend]

## 15. Deterministic checks
- Build — `npm run build`. [default: frontend]
- Lint — `npm run lint`. [default: frontend]
- Test — `npm run test`. [default: frontend]

## 16. Open questions
- [none detected]
