---

name: backend-code-review
description: Realiza code review aprofundado de código backend para múltiplas linguagens (Rust, Go, TypeScript, Python, Kotlin) com auto-detecção de arquitetura, aplicando regras universais de segurança OWASP, consistência de dados, concorrência e checklists idiomáticos por linguagem.

---

# Backend Code Review

Review guide for backend projects across multiple languages and architectural patterns:

- **Supported Languages:** Rust, Go, TypeScript / Node.js, Python, Kotlin, and general backend stacks.
- **Architectural Patterns:** Clean Architecture, Hexagonal / Ports & Adapters, Idiomatic Go packages, Rust crates/modules, Vertical Slice, Layered MVC.

Review findings use the structured templates in `references/comment-templates.md`.

---

# Workflow

Follow the steps **in order**.

---

# Step 1 — Collect code for review

The user must provide the code to review. This can be:

- A diff (git diff, PR diff)
- Specific files or directories
- A code snippet
- A branch name (the agent will inspect the branch diff against the stable base)

If the user does not provide code, ask:

> "Which code would you like me to review? You can provide a diff, file paths, a branch name, or paste a snippet."

---

# Step 2 — Detect project context & architecture

Before evaluating rules, discover the project's stack and architecture:

1. **Language & Ecosystem Detection:**
   - Inspect file extensions in the diff (`.rs`, `.go`, `.ts`/`.js`, `.py`, `.kt`/`.kts`).
   - Inspect project manifest files (`Cargo.toml`, `go.mod`, `package.json`, `pyproject.toml`, `build.gradle.kts`, `pom.xml`).
2. **Architecture Discovery:**
   - Inspect the target repository's `AGENTS.md` or architecture documentation if present.
   - Inspect the directory structure (e.g. `cmd/`, `internal/`, `pkg/` for Go; `crates/`, `src/` for Rust; `controllers/`, `usecases/`, `domain/`, `infra/` for Clean Architecture; `features/` for Vertical Slice).
   - Establish the boundary convention: Transport/Entrypoint → Domain/Application → Persistence/Infrastructure.

---

# Step 3 — Apply Layer 1: Universal Backend Review Rules

Apply universal backend rules defined in:

- `references/review-rules.md` — universal backend standards and architecture boundaries

Also apply organization backend rules (located in `.opencode/rules/`, `~/.config/opencode/rules/`, or `rules/`):

- `rules/backend-anti-patterns.md` — universal backend anti-patterns
- `rules/backend-security-review.md` — OWASP security vulnerabilities & input validation
- `rules/staff-engineer-review.md` — Staff Engineer review dimensions (Architecture, Domain, Scalability, Reliability, Observability, Testability)

Prioritize findings by severity:

## 🔴 Critical (Block Merge)
- Security vulnerabilities (SQL/Command injection, SSRF, broken AuthN/AuthZ, hardcoded credentials)
- Data corruption & lack of atomic transactions
- Concurrency bugs (race conditions, goroutine leaks, deadlocks, lock held across await)
- Critical runtime crashes (unhandled errors, unwrap/expect in production paths, floating promises)

## 🟡 Important (Fix in Current MR)
- Architectural boundary violations & leaky abstractions
- Performance bottlenecks (N+1 queries, in-memory filtering, blocking I/O in async runtimes)
- Missing unit tests for critical business logic
- Resource leaks (unclosed sockets, unmanaged connections)

## 💡 Suggestions (Optional Improvements)
- Code simplification, readability, naming, and idiomatic pattern enhancements

---

# Step 4 — Apply Layer 2: Language-Specific Idiomatic Checklist

Consult `references/language-checklists.md` for specific language checklists matching the files under review:

- **Rust (`.rs`):** `.unwrap()` / `.expect()` in production, locks across `.await`, `unsafe` safety invariants, blocking calls in Tokio, integer truncation via `as`, cancel-safety in `tokio::select!`, unnecessary `.clone()`, typed `Result` with `thiserror`/`anyhow`.
- **Go (`.go`):** Ignored errors (`_ = fn()`), goroutine leaks, data races, missing `resp.Body.Close()` / `rows.Close()`, `http.DefaultClient` without timeout, `context.Context` propagation, `defer` inside loops, error wrapping with `%w`, slice memory leaks.
- **TypeScript / Node.js (`.ts`, `.js`):** Floating Promises (missing `await`), `any` or unchecked assertions, mass assignment, Event Loop blocking, `forEach` with async callbacks, unhandled Stream/EventEmitter errors, sequential `await` in loops, DTO validation.
- **Python (`.py`):** Mutable default arguments, bare `except:` / silent `except Exception: pass`, blocking sync calls inside `async def`, unreferenced `asyncio.create_task`, unsafe deserialization (`pickle`/`yaml`), `assert` for business validation, ORM N+1 lazy loading, missing type hints, context manager `with` usage.
- **Kotlin (`.kt`, `.kts`):** `!!` operator, catching `Exception` without rethrowing `CancellationException`, `GlobalScope`, blocking I/O on `Dispatchers.Default`, `runBlocking` in reactive/coroutine threads, Spring `@Transactional` on private/self calls, data classes as JPA `@Entity`, exposing mutable collections.

> [!IMPORTANT]
> **Non-Exhaustive Deep Inspection:** The checklists above are the baseline floor (hard minimum), not a ceiling. As a Staff Backend Engineer, evaluate deeper runtime mechanics, framework lifecycles, concurrency models, and security advisories even if not explicitly enumerated in the checklist.

---

# Step 5 — Generate structured inline preview

Generate inline review comments using the templates in `references/comment-templates.md`:

```
## Review Preview

### [FILE: src/api/user_handler.go]

Line 45 | 🔴 Concurrency / Resource Leak

Problem description.

Suggestion with concrete code snippet.

---

### [FILE: src/domain/order.rs]

Line 88 | 🟡 Architecture / Boundary

Description.

---

## Summary

Critical: N
Important: N
Suggestions: N
```

---

# Step 6 — Generate executive review summary

At the end of the review, generate an executive summary:

```markdown
## Code Review — Summary

### Findings

- 🔴 Critical: N
- 🟡 Important: N
- 💡 Suggestions: N

### Top Issues

1. [Most critical finding]
2. [Second most critical]
3. [Third most critical]

### Recommended Actions

- [Action for most critical finding]
- [Action for second finding]
- [Action for third finding]
```

---

# Important Guidelines

- Always read the full code/diff before commenting.
- Never comment without understanding the context and project architecture.
- Classify every finding by severity (🔴 Critical, 🟡 Important, 💡 Suggestion).
- Provide concrete suggestions and runnable code snippets in the target language, not just criticism.
- Distinguish between "must fix" (🔴) and "nice to have" (💡).
- If no critical issues are found, state that clearly.
- Focus on the code — do not speculate about external tools or Jira tickets.