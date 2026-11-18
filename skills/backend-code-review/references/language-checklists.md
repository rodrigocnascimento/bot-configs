# Language-Specific Idiomatic Checklists — Backend Code Review

When conducting a backend review, inspect the file extensions and dependencies in the diff or source files and apply the corresponding language checklists below.

> [!IMPORTANT]
> **Non-Exhaustive Deep Inspection Principle:**
> These checklists represent the **mandatory baseline floor (hard minimum)**, not a ceiling. As a Staff Backend Engineer, you MUST go beyond these enumerated items and actively evaluate language-specific runtime mechanics, framework lifecycles (e.g. Tokio/Actix/Axum, Gin/Echo/GORM, FastAPI/SQLAlchemy/Celery, Spring Boot/Ktor/Exposed, NestJS/Express/TypeORM), memory models, thread pools, and ecosystem security advisories.

---

# 1. Rust (`.rs`)

Rust guarantees memory safety without garbage collection, but runtime panics, concurrency deadlocks, integer truncation, cancel-safety, and async runtime thread starvation remain critical review targets.

## 🔴 Critical

### 1.1 `.unwrap()` / `.expect()` in Production Fallible Paths
- **Rule:** Never use `.unwrap()` or `.expect()` on runtime-fallible operations (network I/O, database queries, JSON parsing, external input validation).
- **Risk:** Uncaught panics crash the thread or worker process, causing denial of service.
- **Correction:** Propagate errors using `?` with a typed error (`thiserror` / `anyhow`) or explicitly handle `Result`/`Option`.

```rust
// ❌ WRONG
let user: User = serde_json::from_str(&payload).unwrap();
let record = db.query_one("SELECT * FROM users WHERE id = $1", &[&id]).await.expect("query failed");

// ✅ CORRECT
let user: User = serde_json::from_str(&payload)
    .map_err(|e| AppError::BadRequest(format!("invalid payload: {e}")))?;
let record = db.query_one("SELECT * FROM users WHERE id = $1", &[&id])
    .await
    .map_err(AppError::Database)?;
```

### 1.2 `MutexGuard` / `RwLock` Held Across `.await`
- **Rule:** Never hold a standard `std::sync::MutexGuard` or `RwLockReadGuard`/`RwLockWriteGuard` across an `.await` boundary in async code (e.g., Tokio).
- **Risk:** Tokio worker threads can deadlock or fail to compile because `std::sync::MutexGuard` does not implement `Send`.
- **Correction:** Use `tokio::sync::Mutex` if lock across await is strictly necessary, or limit lock scope to a synchronous block before `.await`.

```rust
// ❌ WRONG
let mut guard = my_std_mutex.lock().unwrap();
let response = client.post(url).json(&*guard).send().await?; // Deadlock / Send violation
guard.update(&response);

// ✅ CORRECT (Scoped synchronous lock)
let payload = {
    let guard = my_std_mutex.lock().map_err(|_| AppError::LockPoisoned)?;
    guard.to_payload()
};
let response = client.post(url).json(&payload).send().await?;
{
    let mut guard = my_std_mutex.lock().map_err(|_| AppError::LockPoisoned)?;
    guard.update(&response);
}
```

### 1.3 Unsound `unsafe` Blocks
- **Rule:** Every `unsafe` block MUST have a preceding `// SAFETY:` comment documenting the exact invariants guaranteed by the caller. Flag any unverified pointer dereference or transmutations.

### 1.4 Blocking Syscalls / Heavy CPU in Async Runtime
- **Rule:** Never call blocking operations (`std::fs`, `std::thread::sleep`, sync database drivers, heavy hashing) directly inside Tokio tasks.
- **Risk:** Starves Tokio worker threads, degrading server throughput globally.
- **Correction:** Use `tokio::task::spawn_blocking` or asynchronous equivalents (`tokio::fs`, `tokio::time::sleep`).

```rust
// ❌ WRONG
async fn read_config(path: &str) -> Result<String, AppError> {
    std::thread::sleep(std::time::Duration::from_millis(50));
    std::fs::read_to_string(path).map_err(Into::into)
}

// ✅ CORRECT
async fn read_config(path: &str) -> Result<String, AppError> {
    tokio::fs::read_to_string(path).await.map_err(Into::into)
}
```

### 1.5 Integer Truncation via `as` Casts
- **Rule:** Avoid raw numeric casting (`value as u32` from `u64` or `usize`) on untrusted or dynamic values.
- **Risk:** Silent truncation causes buffer underflows, logic corruption, or incorrect financial calculations.
- **Correction:** Use `TryFrom` / `try_into()` and handle conversion errors explicitly.

```rust
// ❌ WRONG
let limit = user_input as u32; // Silent wrap/truncation if user_input > u32::MAX

// ✅ CORRECT
let limit: u32 = user_input.try_into().map_err(|_| AppError::Validation("limit out of range"))?;
```

### 1.6 Non-Cancel-Safe Operations in `tokio::select!`
- **Rule:** In `tokio::select!`, branches that are canceled midway must not leave shared state or channels in a half-written or corrupted state.
- **Risk:** Futures dropped on cancellation (when another branch completes) drop partial state or lose queued messages.

### 1.7 Database Transactions Held Across Outbound Network Calls
- **Rule:** Never execute external HTTP or gRPC calls while holding an open database transaction lock (`sqlx::Transaction` / Diesel).
- **Risk:** External latency holds database locks, causing connection pool exhaustion and transaction timeouts.

## 🟡 Important

- **Unnecessary `.clone()` in Hot Paths:** Flag repeated `.clone()` on large structs or vectors where references (`&T`), `Arc<T>`, or `Cow<T>` should be used.
- **Unbounded Futures Concurrency:** Flag `futures::future::join_all` on unbounded user input collections. Suggest `futures::stream::iter(items).map(...).buffer_unordered(CONCURRENCY_LIMIT)`.
- **Missing Timeouts on External Futures:** Outbound network calls must be wrapped with `tokio::time::timeout`.
- **Stringly-Typed Errors:** Flag functions returning `Result<T, String>`. Require custom error enums using `thiserror` (for domain/libraries) or `anyhow::Result` (for applications).
- **Unbounded Channels:** Flag `tokio::sync::mpsc::unbounded_channel()` without queue-size limits or backpressure mechanisms.
- **Sensitive Data in Memory:** Use `zeroize::Zeroize` or secret types (e.g. `secrecy::SecretString`) for sensitive tokens and encryption keys to prevent them from remaining in memory dumps.

## 💡 Suggestions
- Use `clippy` suggestions and idiomatic pattern matching over nested `if let`.
- Implement `From`/`TryFrom` or `AsRef` for zero-cost conversions.
- Annotate public DTOs with `#[serde(deny_unknown_fields)]` where strict schema compliance is required.

---

# 2. Go (`.go`)

Go emphasizes simplicity, explicit error handling, and goroutine concurrency. Common pitfalls involve swallowed errors, goroutine leaks, unclosed resources, and data races.

## 🔴 Critical

### 2.1 Ignored Errors
- **Rule:** Every returned `error` MUST be checked. Disallow `_ = fn()` or calling error-returning functions without assignment on fallible I/O, database, or encoding calls.
- **Risk:** Silent failures cascade into corrupted state or panics down the call stack.

```go
// ❌ WRONG
_ = json.Unmarshal(body, &req)
db.Exec("UPDATE accounts SET balance = balance - 100 WHERE id = ?", accountID)

// ✅ CORRECT
if err := json.Unmarshal(body, &req); err != nil {
    return fmt.Errorf("unmarshal request payload: %w", err)
}
if _, err := db.ExecContext(ctx, "UPDATE accounts SET balance = balance - 100 WHERE id = ?", accountID); err != nil {
    return fmt.Errorf("debit account %s: %w", accountID, err)
}
```

### 2.2 Goroutine Leaks
- **Rule:** Every goroutine launched via `go fn()` must have a bounded lifecycle tied to a `context.Context` cancellation, a termination channel, or a `sync.WaitGroup`.
- **Risk:** Blocked goroutines accumulate in memory, causing OOM and performance collapse.

```go
// ❌ WRONG (Leaked goroutine if receiver stops reading)
func StreamData() <-chan Event {
    ch := make(chan Event)
    go func() {
        for {
            ch <- fetchNext() // Blocks forever if channel is abandoned
        }
    }()
    return ch
}

// ✅ CORRECT
func StreamData(ctx context.Context) <-chan Event {
    ch := make(chan Event)
    go func() {
        defer close(ch)
        for {
            select {
            case <-ctx.Done():
                return
            case ch <- fetchNext():
            }
        }
    }()
    return ch
}
```

### 2.3 Data Races on Shared State
- **Rule:** Concurrent access to shared maps, slices, or structs across goroutines MUST be guarded by `sync.Mutex`, `sync.RWMutex`, or atomic operations. Maps are not thread-safe in Go and panic on concurrent writes.

### 2.4 Missing Resource Closure (`Close()`)
- **Rule:** HTTP response bodies (`resp.Body`), SQL query results (`rows`), and file handles must be closed, typically via `defer`.
- **Risk:** Socket exhaustion and file descriptor leaks under production load.

```go
// ❌ WRONG
resp, err := http.Get(targetURL)
if err != nil {
    return err
}
// resp.Body never closed!

// ✅ CORRECT
resp, err := http.Get(targetURL)
if err != nil {
    return err
}
defer resp.Body.Close()
```

### 2.5 Using `http.DefaultClient` Without Timeout
- **Rule:** Disallow using `http.DefaultClient` or `http.Get()` / `http.Post()` directly without configuring explicit client timeouts.
- **Risk:** `http.DefaultClient` has no timeout; slow or hanging external servers permanently tie up goroutines and sockets.
- **Correction:** Create an `&http.Client{Timeout: 10 * time.Second}` or use `http.NewRequestWithContext`.

### 2.6 Panic on Sending to Closed Channel
- **Rule:** Never send values to a channel that might be closed by another goroutine.
- **Risk:** Causes immediate, unrecoverable runtime panic.

### 2.7 Slice Capacity Memory Leaks
- **Rule:** When taking a small sub-slice of a large slice (`small := huge[0:2]`), the large underlying array is pinned in memory.
- **Risk:** Prevents garbage collection of large payloads.
- **Correction:** Allocate a new slice and use `copy()`.

## 🟡 Important

- **Missing `context.Context` Propagation:** Always pass `ctx context.Context` as the first argument in functions performing I/O, database, or external calls. Avoid using `context.Background()` or `context.TODO()` in inner layers.
- **`defer` Inside Loops:** Flag `defer file.Close()` inside loops. `defer` only runs when the outer function exits, causing resource exhaustion during loop execution. Extract loop body into a helper function.
- **Error Wrapping (`%w`):** Use `fmt.Errorf("...: %w", err)` to wrap errors so callers can inspect root causes via `errors.Is` and `errors.As`.
- **`sync.WaitGroup.Add()` Location:** Call `wg.Add(1)` *before* launching the goroutine (`go fn()`), never inside it, to prevent race conditions before `wg.Wait()`.
- **Passing Mutex / WaitGroup by Value:** Never pass `sync.Mutex`, `sync.RWMutex`, or `sync.WaitGroup` by value; always pass pointers (`*sync.Mutex`). Passing by value creates a copy of the lock state.
- **Missing `rows.Err()` Check:** In `database/sql`, always check `if err := rows.Err(); err != nil` after `rows.Next()` loop finishes to catch network drops midway.
- **Missing `defer tx.Rollback()`:** Always `defer tx.Rollback()` immediately after `db.BeginTx()`. If `tx.Commit()` succeeds, rollback is a no-op; if an error occurs before commit, rollback is guaranteed.
- **`time.After` Inside Loops:** Flag `time.After(...)` inside long-running `select` loops. The underlying timer memory is not released until it fires. Use `time.NewTimer` and `Reset()`.
- **Missing `http.MaxBytesReader`:** Limit the maximum size read from `r.Body` to prevent denial-of-service via huge payloads.

## 💡 Suggestions
- Use `golang.org/x/sync/errgroup` for managing groups of goroutines with error propagation and context cancellation.
- Accept interfaces, return concrete structs where appropriate.
- Keep interfaces small (1-2 methods, e.g., `Reader`, `Writer`, `Closer`).
- Use table-driven unit tests.

---

# 3. TypeScript / Node.js (`.ts`, `.js`)

TypeScript provides compile-time type safety, but Node.js relies on an asynchronous, single-threaded event loop. Type bypasses and asynchronous mismanagement cause production failures.

## 🔴 Critical

### 3.1 Floating Promises (Missing `await`)
- **Rule:** Every Promise-returning function call MUST be awaited or returned.
- **Risk:** Silent failures, unhandled promise rejections, race conditions, and response sent before mutation completes.

```typescript
// ❌ WRONG
async function handleUserRegistration(dto: RegisterDTO) {
  auditService.logRegistration(dto); // Floating promise! Silent crash if fails
  await userRepository.save(dto);
}

// ✅ CORRECT
async function handleUserRegistration(dto: RegisterDTO): Promise<void> {
  await auditService.logRegistration(dto);
  await userRepository.save(dto);
}
```

### 3.2 Unsafe `any` or Unchecked Type Assertions
- **Rule:** Disallow `any` or forced downcasts (`as unknown as T`) that bypass schema validation.
- **Risk:** Runtime crashes (`TypeError: Cannot read property of undefined`) despite TypeScript compilation success.
- **Correction:** Use explicit DTOs, `unknown` with runtime type guards, or schema parsers (Zod, Valibot).

```typescript
// ❌ WRONG
function processPayment(data: any): any {
  return paymentGateway.charge(data.amount);
}

// ✅ CORRECT
function processPayment(data: ProcessPaymentDTO): Promise<PaymentResult> {
  return paymentGateway.charge(data.amount);
}
```

### 3.3 Mass Assignment
- **Rule:** Never pass raw `req.body` directly to database models or ORM save/create methods.
- **Risk:** Privilege escalation (e.g., client injecting `isAdmin: true` or `role: "superuser"`).
- **Correction:** Whitelist attributes through typed DTOs or schema parsers.

### 3.4 Blocking the Event Loop
- **Rule:** Disallow synchronous I/O (`fs.readFileSync`, `child_process.execSync`), heavy regular expressions vulnerable to ReDoS, or parsing multi-megabyte JSON synchronously in request handlers.
- **Risk:** Freezes the single Node.js main thread, causing all concurrent requests to time out.

### 3.5 `forEach` with Async Callbacks
- **Rule:** Never pass an `async` callback to `Array.prototype.forEach`.
- **Risk:** `forEach` does not await promises; iterations execute unmonitored in parallel without error handling or sequencing.
- **Correction:** Use `for ... of` with `await` or `Promise.all(array.map(async ...))`.

```typescript
// ❌ WRONG (Promises are never awaited!)
items.forEach(async (item) => {
  await processItem(item);
});

// ✅ CORRECT
for (const item of items) {
  await processItem(item);
}
// or concurrent:
await Promise.all(items.map(item => processItem(item)));
```

### 3.6 Unhandled Stream / EventEmitter Errors
- **Rule:** Every Node.js Stream or EventEmitter must have an `'error'` listener or be piped using `stream.promises.pipeline`.
- **Risk:** An unhandled `'error'` event in Node.js throws an uncaught exception, immediately crashing the process.

## 🟡 Important

- **Prototype Pollution:** Never use unbounded `Object.assign()` or deep recursive object merging with untrusted user input without checking for `__proto__`, `constructor`, or `prototype`.
- **Sequential `await` in Loops:** Flag `for (const id of ids) { await fetch(id); }`. Suggest `Promise.all` or a concurrency limiter (such as `p-limit`) when iterations are independent.
- **Leaking Sensitive Attributes in Serialization:** Ensure passwords, tokens, and hashes are stripped before serialization (`class-transformer` `@Exclude()`, custom `.toJSON()`, or selective DTO mapping).
- **Missing Explicit Return Types:** Exported functions and public service methods should have explicit return types for maintainability and compiler performance.
- **Missing Input/Schema Validation:** All incoming HTTP payloads must be validated at the entrypoint using Zod, Joi, or class-validator.

## 💡 Suggestions
- Use `readonly` properties on domain entities and value objects.
- Prefer `const` assertions (`as const`) for enums and literal tables.
- Use `unknown` instead of `any` when handling unstructured data.

---

# 4. Python (`.py`)

Python's dynamic nature and mix of synchronous and asynchronous paradigms require vigilance against mutable default traps, unhandled exceptions, async event loop starvation, and ORM session pitfalls.

## 🔴 Critical

### 4.1 Mutable Default Arguments
- **Rule:** Never use mutable objects (`list`, `dict`, `set`, class instances) as default parameter values.
- **Risk:** Default value is evaluated once at function definition time; mutations persist across all invocations.

```python
# ❌ WRONG
def append_event(event: dict, history: list = []):
    history.append(event)
    return history

# ✅ CORRECT
from typing import Optional, List

def append_event(event: dict, history: Optional[List[dict]] = None) -> List[dict]:
    if history is None:
        history = []
    history.append(event)
    return history
```

### 4.2 Bare `except:` or Silent `except Exception: pass`
- **Rule:** Disallow bare `except:` or catching `Exception` with `pass` without logging or re-raising.
- **Risk:** Masks system crashes, KeyboardInterrupt, memory errors, and subtle runtime bugs.

```python
# ❌ WRONG
try:
    process_order(order_id)
except:
    pass

# ✅ CORRECT
try:
    process_order(order_id)
except OrderProcessingError as exc:
    logger.error("order_processing_failed", order_id=order_id, error=str(exc))
    raise
```

### 4.3 Blocking Synchronous Calls Inside `async def`
- **Rule:** In async frameworks (FastAPI, asyncio), never call blocking I/O (`requests.get`, `time.sleep`, sync database queries, `open()`) inside `async def` coroutines.
- **Risk:** Blocks the single asyncio event loop thread, freezing all concurrent requests.
- **Correction:** Use async equivalents (`httpx.AsyncClient`, `asyncio.sleep`, async ORM drivers) or run sync calls via `asyncio.to_thread()`.

```python
# ❌ WRONG (Blocks entire asyncio event loop)
@app.get("/users/{user_id}")
async def get_user(user_id: str):
    time.sleep(1) # Blocking!
    resp = requests.get(f"https://api.internal/users/{user_id}") # Blocking!
    return resp.json()

# ✅ CORRECT
@app.get("/users/{user_id}")
async def get_user(user_id: str):
    async with httpx.AsyncClient() as client:
        resp = await client.get(f"https://api.internal/users/{user_id}")
        return resp.json()
```

### 4.4 Unreferenced `asyncio.create_task`
- **Rule:** When spawning background tasks with `asyncio.create_task(coro)`, always save a reference to the task in a set or collection until it finishes.
- **Risk:** The Python Garbage Collector can collect and cancel running tasks if no reference is kept.

### 4.5 Unsafe Deserialization
- **Rule:** Never use `pickle.loads()`, `yaml.load(data)` (without `Loader=SafeLoader`), or `eval()` on untrusted input.
- **Risk:** Arbitrary code execution (RCE).

### 4.6 Using `assert` for Business Validation
- **Rule:** Never rely on `assert condition, "error message"` for authorization or business rule validation.
- **Risk:** When Python is executed with optimization flags (`python -O`), all `assert` statements are completely removed at compile time.

## 🟡 Important

- **N+1 Query in ORM:** In SQLAlchemy or Django ORM, flag accessing relationships inside loops without eager loading (`selectinload()`, `joinedload()`, or `select_related()`).
- **Sharing SQLAlchemy Session Across Tasks:** Never share a single `Session` or `AsyncSession` instance across concurrent asyncio tasks or threads.
- **Holding DB Transactions Across External Calls:** Never leave an active database session/transaction open during external HTTP calls (`httpx` / `requests`).
- **Naive Datetime Objects:** Disallow `datetime.now()` without timezone info. Always use timezone-aware timestamps (`datetime.now(timezone.utc)`).
- **Timing Attacks on Secret Comparisons:** Use `hmac.compare_digest()` instead of `==` when comparing API keys, webhook signatures, or password hashes.
- **Missing Type Hints:** Require type annotations on function parameters, return types, and Pydantic models for business entities.
- **Resource Management (`with` blocks):** Ensure files, database sessions, and connections use context managers (`with` / `async with`).

## 💡 Suggestions
- Use Pydantic V2 or dataclasses for domain transfer objects and settings.
- Use `pathlib.Path` instead of raw `os.path` operations.
- Use structured logging (`structlog`).

---

# 5. Kotlin (`.kt`, `.kts`)

Kotlin provides null safety and coroutines, but improper use of the null assertion operator, breaking structured concurrency, or misconfiguring coroutine dispatchers can cause severe runtime instability.

## 🔴 Critical

### 5.1 Not-Null Assertion Operator (`!!`)
- **Rule:** Avoid the `!!` operator in production backend code.
- **Risk:** Throws `NullPointerException` at runtime, defeating Kotlin's null-safety guarantees.
- **Correction:** Use safe calls (`?.`), Elvis operator (`?:`), `let`, or throw a domain-specific exception.

```kotlin
// ❌ WRONG
val account = accountRepository.findById(id)!!
val balance = account.balance!!

// ✅ CORRECT
val account = accountRepository.findById(id)
    ?: throw AccountNotFoundException("Account $id not found")
val balance = account.balance ?: BigDecimal.ZERO
```

### 5.2 Catching `Exception` Without Rethrowing `CancellationException`
- **Rule:** When catching `Exception` or `Throwable` inside a Kotlin coroutine, you MUST rethrow `CancellationException`.
- **Risk:** Swallowing `CancellationException` breaks Kotlin's Structured Concurrency: canceled coroutines fail to terminate, causing resource leaks and zombie tasks.

```kotlin
// ❌ WRONG (Breaks Coroutine Cancellation)
suspend fun fetchExternalData(): String? {
    return try {
        apiClient.getData()
    } catch (e: Exception) {
        logger.error("Failed to fetch data", e)
        null // Swallows CancellationException!
    }
}

// ✅ CORRECT
suspend fun fetchExternalData(): String? {
    return try {
        apiClient.getData()
    } catch (e: CancellationException) {
        throw e // Preserve cancellation
    } catch (e: Exception) {
        logger.error("Failed to fetch data", e)
        null
    }
}
```

### 5.3 Using `GlobalScope`
- **Rule:** Never launch coroutines using `GlobalScope.launch` or `GlobalScope.async`.
- **Risk:** Bypasses structured concurrency, creates unmanaged lifecycles, and causes memory leaks.
- **Correction:** Inject a dedicated `CoroutineScope` or use `coroutineScope {}` / `supervisorScope {}`.

### 5.4 Blocking I/O on `Dispatchers.Default` or `Dispatchers.Main`
- **Rule:** Never execute blocking I/O (JDBC, file reads, socket I/O) on `Dispatchers.Default`.
- **Risk:** Starves the CPU-bound thread pool, stalling compute tasks.
- **Correction:** Wrap blocking calls in `withContext(Dispatchers.IO)`.

```kotlin
// ❌ WRONG
suspend fun loadUserData(id: String): User = withContext(Dispatchers.Default) {
    jdbcTemplate.queryForObject("SELECT ...", id) // Blocking I/O on Default dispatcher!
}

// ✅ CORRECT
suspend fun loadUserData(id: String): User = withContext(Dispatchers.IO) {
    jdbcTemplate.queryForObject("SELECT ...", id)
}
```

### 5.5 `runBlocking` in Coroutine / Reactive Threads
- **Rule:** Disallow calling `runBlocking` inside an existing coroutine, WebFlux, or thread pool worker.
- **Risk:** Deadlocks thread pools and degrades concurrency.

### 5.6 Spring `@Transactional` on Private Methods or Self-Invocations
- **Rule:** In Spring Boot / Kotlin, never annotate `private` methods with `@Transactional` or call `@Transactional` methods directly within the same class (`this.method()`).
- **Risk:** Spring proxy bypasses the transaction interceptor completely; mutations execute with no transaction.

## 🟡 Important

- **Data Classes as JPA `@Entity`:** Avoid using `data class` for Hibernate/JPA entities. Auto-generated `equals()`, `hashCode()`, and `toString()` break with lazy-loaded proxies and circular relations. Use standard `class` with explicit identifier-based `equals`/`hashCode`.
- **Exposing Mutable Collections:** Flag public methods or properties returning `MutableList`, `MutableMap`, or `MutableSet`. Expose read-only `List`, `Map`, or `Set` views to prevent external state mutation.
- **Chained Collection Operations on Large Datasets:** Flag multiple chained operations (`list.map { ... }.filter { ... }`) on large collections. Suggest `asSequence()` to avoid creating intermediate list allocations.
- **Unclosed Resources:** Ensure `Closeable` / `AutoCloseable` resources (streams, connections) use `.use { ... }`.
- **Unhandled `lateinit var`:** Flag `lateinit var` properties accessed without verifying `::property.isInitialized` or where nullable types with explicit initialization should be used.

## 💡 Suggestions
- Use `sealed interface` or `sealed class` to represent exhaustive domain results and state machines.
- Use inline value classes (`@JvmInline value class UserId(val value: String)`) for type-safe identifiers without heap allocation overhead.
