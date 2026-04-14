# Inline Comment Templates — Backend Code Review

Use these templates when formatting review comments.

## Structure of an inline comment

Every comment must have:

1. **Severity emoji**
2. **Category**
3. **Objective description**
4. **Concrete suggestion**

> Always address the developer as **"Developer"**.

---

# 🔴 Bug / Incorrect Logic

````markdown
🔴 **Bug**: [Short title]

Developer, the implemented logic does not correctly cover the expected scenario.

[Describe current behavior and impact.]

**Suggestion:**
```ts
// corrected code
```
````

---

# 🔴 Security

```markdown
🔴 **Security**: [Title]

Developer, this implementation may introduce a vulnerability.

[Describe attack vector: SQL injection, data exposure, auth bypass.]

Impact: [unauthorized access, data leak, etc.]

**Suggestion:**
```ts
// secure implementation
```
```

---

# 🔴 Data Consistency

````markdown
🔴 **Data Consistency**: Operations without transaction

Developer, this flow executes multiple database operations without a transaction.

If one fails, the system may be left in an inconsistent state.

**Suggestion:**
```ts
await dataSource.transaction(async manager => {
  await manager.save(entity1)
  await manager.save(entity2)
})
```
````

---

# 🟡 Architecture — Clean Architecture

```markdown
🟡 **Architecture**: Layer violation

Developer, this logic is being executed in the wrong layer.

Controllers should only orchestrate HTTP requests and delegate business rules to use cases.

**Suggestion:** move the logic to `usecases/`.
```

---

# 🟡 Persistence — TypeORM

```markdown
🟡 **Persistence**: In-memory filter

Developer, this filter is being applied after loading data from the database.

This can cause high memory consumption and performance degradation.

**Suggestion:** move the filter to the SQL query or QueryBuilder.
```

---

# 🟡 Error Handling

````markdown
🟡 **Error Handling**: Missing explicit treatment

Developer, this async call may fail and has no error handling.

**Suggestion:**
```ts
try {
  await service.execute(data)
} catch (error) {
  logger.error(error)
  throw new AppError("Failed to process request")
}
```
````

---

# 🟡 Missing Test

```markdown
🟡 **Missing Test**: [Use case name]

Developer, this module contains relevant business logic and has no unit tests.

Suggestion: add tests covering:

- happy path
- error handling
- main business rules
```

---

# 🟡 Performance

```markdown
🟡 **Performance**: N+1 Query

Developer, this implementation may generate multiple queries when accessing relations.

Impact: performance degradation with large data volumes.

**Suggestion:** use `leftJoinAndSelect` or controlled eager loading.
```

---

# 💡 Suggestion / Improvement

````markdown
💡 **Suggestion**: [Title]

Developer, this implementation can be simplified to improve readability and maintenance.

**Alternative:**
```ts
// suggested code
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

| Emoji | Level      | Action          |
| ----- | ---------- | --------------- |
| 🔴    | Critical   | Block merge     |
| 🟡    | Important  | Fix in this MR   |
| 💡    | Suggestion | Optional        |