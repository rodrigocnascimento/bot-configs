# Rule: Backend Anti-Patterns Detection (BAPD)

## Context

During code review or code generation, common anti-patterns must be detected, classified, and corrected. This rule defines the universal anti-patterns catalogue for backend projects across multiple languages (Rust, Go, TypeScript, Python, Kotlin) and architectures (Clean Architecture, Hexagonal, Go packages, Rust modules, Vertical Slice).

For detailed language-specific checklists and rules, refer to `skills/backend-code-review/references/language-checklists.md`.

Whenever an anti-pattern is identified, it MUST be classified by severity and a concrete alternative MUST be suggested in the target language.

---

# Severity Classification

| Severity     | Criteria                                          |
| ------------ | ------------------------------------------------- |
| 🔴 Critical  | May cause bug, vulnerability, crash, or data corruption |
| 🟡 Important | Impacts architecture, scalability, or maintainability   |
| 💡 Suggestion| Non-blocking idiomatic or structural improvement  |

---

# 🔴 Critical Anti-Patterns

## 1. Transport / Entrypoint Accessing Persistence Directly

Wrong:
Controllers, gRPC handlers, or event consumers querying the database directly:

```
Transport Handler ──(direct query)──> Database
```

Reason: Violates separation of concerns. Makes logic untestable without a database and couples transport to storage schema.

Correct:
Route requests through domain/application use cases or services:

```
Transport Handler ──> Application / Use Case ──> Repository / Storage Port ──> Database
```

---

## 2. Dynamic Unsanitized SQL / Command Construction

Wrong:
Interpolating variables directly into queries or shell commands:

```
query = "SELECT * FROM users WHERE id = " + user_id
```

Risk: SQL Injection or Command Injection.

Correct:
Always use parameterized queries, prepared statements, or ORM parameter binding:

```
// Parameterized query:
SELECT * FROM users WHERE id = $1   // (PostgreSQL / Rust)
SELECT * FROM users WHERE id = ?    // (MySQL / Go / TypeScript)
```

---

## 3. Unhandled Asynchronous Failures & Task Leaks

Wrong:
- TypeScript: Promises executed without `await` or `.catch()`.
- Go: Spawning goroutines without `context.Context` cancellation or channel exit conditions.
- Rust: Calling blocking I/O or `std::thread::sleep` directly inside Tokio worker threads.
- Python: Blocking synchronous calls (`requests.get`, `time.sleep`) inside `async def` endpoints.
- Kotlin: Catching `Exception` inside coroutines without rethrowing `CancellationException`, breaking Structured Concurrency.

Problem: Silent data loss, thread starvation, goroutine/memory leaks, or server lockup.

Correct:
Always handle async completions explicitly, propagate cancellation contexts, and dispatch blocking work to dedicated thread pools.

---

## 4. Multi-Operation Mutation Without Transaction

Wrong:
Executing multiple database mutations that depend on each other without an atomic transaction:

```
saveOrder(order)
savePayment(payment) // If this fails, order is orphaned!
```

Risk: Inconsistent database state, phantom records, and financial/data discrepancies.

Correct:
Wrap multi-table or multi-entity mutations in an atomic transaction or Unit-of-Work:

```
Begin Transaction
  saveOrder(tx, order)
  savePayment(tx, payment)
Commit Transaction
```

---

## 5. Domain Depending on Infrastructure Details

Wrong:
Domain entities or core business logic importing concrete database drivers, HTTP frameworks, or cloud SDKs.

Correct:
Invert dependencies. Domain defines interfaces/ports; infrastructure implements them.

---

## 6. Swallowed Errors & Production Panics

Wrong:
- Go: Ignoring returned errors (`_ = fn()`).
- Rust: Calling `.unwrap()` or `.expect()` on fallible runtime inputs.
- Python: Bare `except:` or `except Exception: pass`.
- Kotlin: Using the `!!` assertion operator on nullable inputs.

Risk: Uncaught panics crash worker processes; swallowed errors lead to silent corruption.

Correct:
Propagate typed errors with contextual information or handle fallbacks explicitly.

---

# 🟡 Important Anti-Patterns

## 7. In-Memory Filtering After Full Table Load

Wrong:
Loading full tables or large result sets into memory and filtering with language array methods:

```
records = db.findAll()
return records.filter(r => r.active)
```

Problem: High memory footprint, network saturation, and quadratic performance degradation as data grows.

Correct:
Push filtering, sorting, and pagination down to the database query level (`WHERE active = true LIMIT 50`).

---

## 8. N+1 Queries in Loops

Wrong:
Querying associated records iteratively inside a loop:

```
for item in items:
    details = db.fetchDetails(item.id)
```

Correct:
Use batch queries (`WHERE id IN (...)`), joins, or eager loading relations.

---

## 9. Sequential Processing of Independent Async Operations

Wrong:
Awaiting independent network or database calls one by one sequentially when they could run concurrently.

Correct:
Use concurrent execution with bounded concurrency (`Promise.all`, Go `sync.WaitGroup`/errgroup, Python `asyncio.gather`, Kotlin `async/awaitAll`).

---

## 10. Lack of Input DTOs / Schema Validation

Wrong:
Accepting untrusted input payloads directly into domain or database layers without schema validation or whitelisting.

Correct:
Define typed DTOs and validate payloads at the boundary using schema validators (Zod, Pydantic, class-validator, Go struct tags).

---

## 11. Overly Complex Functions (Low Cohesion)

Heuristic:
- Functions exceeding 50 lines with multiple responsibilities.
- Deeply nested control flow (more than 3 levels of nesting).

Suggestion: Extract cohesive subroutines, use guard clauses, or extract dedicated use cases.

---

# 💡 Suggestion Anti-Patterns

## 12. Unstructured String Logging

Wrong:
Printing plain text or unstructured strings:

```
log("User created: " + user.id)
```

Correct:
Emit structured key-value logs without logging sensitive data (passwords, tokens, PII):

```
logger.info("user_created", { user_id: user.id })
```

---

# Detection Protocol

During review or code generation, verify:

### Architectural Boundaries
- Transport entrypoints must not invoke database drivers directly.
- Domain must not import transport or database infrastructure packages.

### Database Operations
- Check for dynamic string interpolation in queries.
- Check for mutations without transactions.
- Check for `.filter()` / in-memory operations after fetching collections.
- Check for queries executed inside iteration loops.

### Concurrency & Async
- Check for missing awaits, unhandled task promises, or leaked goroutines.
- Check for blocking calls inside async event loops/runtimes.
- Check for synchronization locks held across await points.

### Error Handling & Typing
- Check for swallowed errors, bare `except:`, or `.unwrap()`.
- Check for unsafe type bypasses (`any`, unchecked casts).

---

# Hard Execution Gate

When detecting an anti-pattern, the system MUST:

1. Classify severity (🔴 Critical, 🟡 Important, 💡 Suggestion).
2. Generate comment using templates from `skills/backend-code-review/references/comment-templates.md`.
3. Provide a concrete code correction in the language under review.
4. Count the finding in the review summary.

The system MUST NOT:
- Ignore Critical anti-patterns.
- Approve code with SQL injection, mass assignment, unhandled panics, or transaction omission without flagging.

---

## Security Principle

Anti-patterns are symptoms of deeper architectural or safety issues.

Detection > silence.
Correction > tolerance.