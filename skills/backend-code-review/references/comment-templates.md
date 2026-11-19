# Inline Comment Templates — Backend Code Review

Use these templates when formatting review comments.

## Structure of an inline comment

Every comment must have:

1. **Severity emoji** (🔴 Critical, 🟡 Important, 💡 Suggestion)
2. **Category** (Bug, Security, Data Consistency, Architecture, Performance, Concurrency, Error Handling, Missing Test)
3. **Objective description** with clear impact
4. **Concrete suggestion** with a code snippet in the target language (`<lang>`)

> Always address the developer as **"Developer"**.

---

# 🔴 Bug / Incorrect Logic

````markdown
🔴 **Bug**: [Short title]

Developer, the implemented logic does not correctly cover the expected scenario.

[Describe current behavior, edge case, and impact.]

**Suggestion:**
```<lang>
// corrected code in target language (Rust, Go, TypeScript, Python, Kotlin)
```
````

---

# 🔴 Security

````markdown
🔴 **Security**: [Title - e.g. SQL Injection / Mass Assignment / SSRF]

Developer, this implementation introduces a security vulnerability.

[Describe attack vector: SQL injection, mass assignment, unauthenticated access, SSRF.]

**Impact:** [unauthorized data access, privilege escalation, data leak]

**Suggestion:**
```<lang>
// secure implementation with parameterized queries / schema validation
```
````

---

# 🔴 Data Consistency

````markdown
🔴 **Data Consistency**: Operations without transaction

Developer, this flow executes multiple database mutations without an atomic transaction boundary.

If one operation fails midway, the database will be left in an inconsistent or orphaned state.

**Suggestion:**
```<lang>
// wrap related operations inside an atomic transaction / Unit of Work
```
````

---

# 🔴 Concurrency / Resource Leak

````markdown
🔴 **Concurrency**: [Goroutine leak / Lock across await / Unbounded task]

Developer, this concurrency flow can lead to deadlocks, memory leaks, or thread starvation.

[Describe specific issue: goroutine without cancellation context, mutex held across async await, or unclosed resource.]

**Suggestion:**
```<lang>
// bounded concurrency / explicit cancellation / scoped lock
```
````

---

# 🟡 Architecture — Boundary Violation

````markdown
🟡 **Architecture**: Boundary violation

Developer, this logic is placed in the wrong layer or module.

Transport and entrypoint handlers should only validate inputs, orchestrate requests, and delegate business rules to the application/domain layer.

**Impact:** Tight coupling between infrastructure and business logic, hindering testability and reuse.

**Suggestion:** Move business invariants to the domain/application layer and use interfaces/ports for persistence dependencies.
````

---

# 🟡 Persistence — Query Performance & N+1

````markdown
🟡 **Persistence**: [N+1 Query / In-Memory Filter / Unbounded Query]

Developer, this implementation causes performance degradation under production load.

[Describe issue: queries inside loops, loading full dataset into memory for filtering, or missing pagination limit.]

**Impact:** High latency, database connection pool exhaustion, and elevated memory consumption.

**Suggestion:**
```<lang>
// batch queries, eager load relations, or push filtering to the database query
```
````

---

# 🟡 Error Handling

````markdown
🟡 **Error Handling**: Missing explicit treatment / Swallowed error

Developer, this fallible operation lacks explicit error handling or swallows errors without context.

**Impact:** Failures will be silent or result in unexpected panics/crashes downstream.

**Suggestion:**
```<lang>
// propagate typed errors with context or handle explicitly
```
````

---

# 🟡 Missing Test

````markdown
🟡 **Missing Test**: [Module / Function name]

Developer, this module introduces or modifies core business logic but lacks automated tests.

**Suggestion:** Add unit/integration tests covering:
- Happy path
- Error scenarios & boundary conditions
- Core business invariants
````

---

# 💡 Suggestion / Improvement

````markdown
💡 **Suggestion**: [Title]

Developer, this implementation can be simplified to improve readability, performance, or idiomatic style.

**Alternative:**
```<lang>
// suggested idiomatic improvement
```
````

---

# Review Summary Template

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

# Severity Guide

| Emoji | Level      | Action          | Description |
| ----- | ---------- | --------------- | ----------- |
| 🔴    | Critical   | Block merge     | Vulnerabilities, data loss, crashes, severe concurrency bugs |
| 🟡    | Important  | Fix in this MR  | Architectural violations, N+1 queries, missing tests |
| 💡    | Suggestion | Optional        | Idiomatic style, readability, non-blocking improvements |