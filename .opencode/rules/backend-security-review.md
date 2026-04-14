# Rule: Backend Security Review (BSR)

## Context

During code review or code generation, security vulnerabilities must be identified and blocked before reaching production. This rule follows OWASP-inspired practices for backend projects using Node.js, TypeScript, Express, TypeORM, and MySQL.

Security is the highest priority dimension. Any finding classified as 🔴 Critical MUST be flagged and corrected before the code is considered acceptable.

---

# Vulnerability Categories

## 1. Injection (SQL / Command)

Detect any dynamic query construction.

❌ Wrong:

```ts
await repository.query(
  `SELECT * FROM users WHERE email = '${email}'`
)
```

Risk: SQL Injection.

✅ Correct:

```ts
await repository.query(
  "SELECT * FROM users WHERE email = ?",
  [email]
)
```

---

## 2. Mass Assignment

When request objects are persisted directly.

❌ Wrong:

```ts
await userRepository.save(req.body)
```

Problem: An attacker can send extra fields:

```json
{
  "email": "user@mail.com",
  "isAdmin": true
}
```

✅ Correct:

Use explicit DTO:

```ts
const dto: CreateUserDTO = {
  email: req.body.email,
  password: req.body.password
}
```

---

## 3. Missing Input Validation

Verify absence of validation on:

- body
- query
- params

❌ Wrong:

```ts
app.post("/users", async (req, res) => {
  await service.create(req.body)
})
```

✅ Correct:

Use schema validation:

- Zod
- Joi
- class-validator

---

## 4. Sensitive Data Exposure

Detect logs containing:

- passwords
- tokens
- authentication headers

❌ Wrong:

```ts
logger.info("login attempt", req.body)
```

✅ Correct:

```ts
logger.info("login attempt", { email: req.body.email })
```

---

## 5. Hardcoded Secrets

Detect hardcoded values:

- API keys
- tokens
- credentials

❌ Wrong:

```ts
const apiKey = "sk_live_123"
```

✅ Correct:

```ts
process.env.API_KEY
```

---

## 6. Broken Authentication

Verify that sensitive endpoints:

- require authentication
- verify authorization

Common problems:

- public administrative endpoints
- missing auth middleware
- authentication only on frontend

---

## 7. SSRF (Server-Side Request Forgery)

Detect HTTP calls with user-controlled URLs.

❌ Wrong:

```ts
await axios.get(req.query.url)
```

Risk: Server can access internal resources.

✅ Correct:

Validate domain whitelist.

---

## 8. Missing Rate Limiting

Critical endpoints must have abuse protection.

Examples:

- login
- password reset
- account creation

Common solutions:

- express-rate-limit
- gateway rate limit

---

## 9. Insecure File Upload

Verify:

- file type
- maximum size
- secure directory

Common problems:

- executable uploads
- path traversal

---

## 10. Missing Data Sanitization

Especially in fields that may be rendered later (XSS prevention).

---

# Detection Protocol

Whenever reviewing or generating code, the system MUST:

### 1. Scan for Vulnerability Patterns

Check for:

- Template strings in SQL queries
- Direct `req.body` persistence
- Missing input validation
- Hardcoded credentials
- User-controlled URLs in HTTP calls
- Missing auth middleware on sensitive routes

### 2. Classify Findings

| Severity   | Criteria                                           |
| ---------- | -------------------------------------------------- |
| 🔴 Critical| Can cause vulnerability or data breach             |
| 🟡 Important| Impacts security posture                          |
| 💡 Suggestion| Security hardening recommendation               |

### 3. Generate Corrective Comments

Use templates from `skills/backend-code-review/references/comment-templates.md`.

---

# Hard Execution Gate

The system MUST NOT:

- Ignore 🔴 Critical security findings
- Approve code with SQL injection or mass assignment without flagging
- Suggest skipping validation as a workaround
- Leave hardcoded credentials unflagged

The system MUST:

- Flag every security vulnerability found
- Suggest a concrete correction
- Prioritize security over all other review dimensions

---

## Security Principle

Security findings are never optional.

Injection > convenience.
Validation > trust.
Explicit > implicit.