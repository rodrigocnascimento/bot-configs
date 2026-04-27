# Rule: Backend Anti-Patterns Detection (BAPD)

## Context

During code review or code generation, common anti-patterns must be detected, classified, and corrected. This rule defines the anti-patterns catalogue for backend projects using Node.js, TypeScript, Express, TypeORM, MySQL, Clean Architecture, tsyringe, and Jest.

Whenever an anti-pattern is identified, it MUST be classified by severity and a concrete alternative MUST be suggested.

---

# Severity Classification

| Severity     | Criteria                                          |
| ------------ | ------------------------------------------------- |
| 🔴 Critical  | May cause bug, vulnerability, or data corruption  |
| 🟡 Important | Impacts architecture or maintainability           |
| 💡 Suggestion| Optional improvement                              |

---

# 🔴 Critical Anti-Patterns

## 1. Controller accessing repository directly

Wrong:

```ts
const user = await userRepository.findOne(id)
```

Reason: Controllers must not access persistence directly.

Correct:

```ts
controller → usecase → repository
```

---

## 2. Manually concatenated SQL

Wrong:

```ts
await repository.query(
  `SELECT * FROM users WHERE id = ${userId}`
)
```

Risk: SQL Injection.

Correct:

```ts
await repository.query(
  "SELECT * FROM users WHERE id = ?",
  [userId]
)
```

---

## 3. Promise without await

Wrong:

```ts
service.execute(data)
```

Problem: silent errors, execution outside expected flow.

Correct:

```ts
await service.execute(data)
```

---

## 4. Multiple operations without transaction

Wrong:

```ts
await orderRepository.save(order)
await paymentRepository.save(payment)
```

Risk: inconsistent state.

Correct:

```ts
await dataSource.transaction(async manager => {
  await manager.save(order)
  await manager.save(payment)
})
```

---

## 5. Domain depending on infrastructure

Wrong:

```ts
domain → repository
domain → orm
```

Correct:

```ts
domain → interfaces
infra → implementation
```

---

# 🟡 Important Anti-Patterns

## 6. In-memory filter after full load

Wrong:

```ts
const users = await repository.find()
return users.filter(u => u.active)
```

Problem: loads all records into memory.

Correct:

```ts
repository.find({
  where: { active: true }
})
```

---

## 7. N+1 Queries

Wrong:

```ts
for (const order of orders) {
  await repository.findItems(order.id)
}
```

Correct:

```ts
leftJoinAndSelect("order.items", "items")
```

---

## 8. Sequential async loop

Wrong:

```ts
for (const item of items) {
  await process(item)
}
```

Correct:

```ts
await Promise.all(items.map(process))
```

---

## 9. Excessive use of `any`

Wrong:

```ts
function create(data: any)
```

Problem: loss of type safety.

Correct:

```ts
function create(data: CreateUserDTO)
```

---

## 10. Functions too large

Heuristic:

- more than 50 lines
- multiple responsibilities

Suggestion: split into smaller functions or extract use case.

---

# 💡 Suggestion Anti-Patterns

## 11. Unstructured logs

Wrong:

```ts
console.log("user created", user)
```

Correct:

```ts
logger.info("user_created", { userId: user.id })
```

---

## 12. Missing DTO

Controllers must not work directly with entities.

Wrong:

```ts
createUser(user: User)
```

Correct:

```ts
createUser(dto: CreateUserDTO)
```

---

# Detection Heuristics

During review or code generation, automatically check:

### Architecture

- controller importing repository
- usecase importing express
- domain importing orm

### Database

- `.find()` followed by `.filter()`
- `.save()` inside loops
- SQL query with template string

### Async

- async function without await
- sequential loop with await

### Typing

- use of `any`
- implicit return

---

# Hard Execution Gate

When detecting an anti-pattern, the system MUST:

1. Classify severity
2. Generate comment using templates from `skills/backend-code-review/references/comment-templates.md`
3. Suggest concrete correction
4. Count in review score

The system MUST NOT:

- Ignore Critical anti-patterns
- Suggest `any` as a workaround
- Approve code with SQL injection or mass assignment without flagging

---

## Security Principle

Anti-patterns are symptoms of deeper architectural or safety issues.

Detection > silence.
Correction > tolerance.