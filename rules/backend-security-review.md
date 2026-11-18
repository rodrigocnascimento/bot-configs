# Rule: Backend Security Review (BSR)

## Context

During code review or code generation, security vulnerabilities must be identified and blocked before reaching production. This rule follows OWASP-inspired security practices for backend projects across multiple languages (Rust, Go, TypeScript, Python, Kotlin) and frameworks.

Security is the highest priority dimension. Any finding classified as 🔴 Critical MUST be flagged and corrected before the code is considered acceptable.

---

# Vulnerability Categories

## 1. Injection (SQL / Command / NoSQL)

Detect any dynamic query construction or command execution with untrusted input.

❌ Wrong:
Interpolating variables into database queries or shell execution strings:

```
// SQL Injection risk across languages:
query = f"SELECT * FROM users WHERE email = '{email}'"
query = "SELECT * FROM users WHERE email = '" + email + "'"
cmd = f"ping -c 1 {user_ip}"
```

✅ Correct:
Use parameterized queries, prepared statements, or ORM parameter binding:

```
// Safe parameterized query:
db.query("SELECT * FROM users WHERE email = ?", [email])
db.query("SELECT * FROM users WHERE email = $1", &[&email])
```

---

## 2. Mass Assignment / Untrusted Payload Binding

When incoming request payloads are bound or saved directly to persistence models without an explicit whitelist.

❌ Wrong:
Passing the entire client request payload into the database:

```
// Vulnerable to privilege escalation (e.g. injecting role: "admin"):
db.save(request.body)
user.update(request_data)
```

✅ Correct:
Explicitly bind through validated Data Transfer Objects (DTOs) or whitelist schemas:

```
// Whitelist fields explicitly:
dto = CreateUserDTO(email=payload.email, name=payload.name)
```

---

## 3. Missing Input & Schema Validation

Verify absence of schema validation on:
- Request body
- Query parameters
- Path parameters / Headers

❌ Wrong:
Accepting incoming requests without format, type, and range validation.

✅ Correct:
Enforce schema validation at the transport boundary (e.g., Zod / Joi in TypeScript, Pydantic in Python, Go struct validator tags, Serde in Rust, Bean Validation / kotlinx.serialization in Kotlin).

---

## 4. Sensitive Data Exposure in Logs

Detect logs containing:
- Passwords or passphrases
- Auth tokens, session cookies, or API keys
- Personally Identifiable Information (PII) like credit cards, SSNs, or tax IDs

❌ Wrong:
```
logger.info("login attempt", request.payload)
```

✅ Correct:
Sanitize logs to include only non-sensitive identifiers:
```
logger.info("login_attempt", { email: request.payload.email })
```

---

## 5. Hardcoded Secrets & Credentials

Detect hardcoded secrets:
- API keys, service tokens
- Passwords, database credentials
- Private encryption keys or certificates

❌ Wrong:
```
const apiKey = "sk_live_123456789"
```

✅ Correct:
Read secrets from environment variables, secret managers (e.g. AWS Secrets Manager, Vault), or secure injected configurations.

---

## 6. Broken Authentication & Authorization

Verify that sensitive endpoints:
- Require authentication
- Verify authorization (RBAC / ABAC) against the requesting identity
- Disallow access to administrative or tenant-scoped resources without explicit role verification

Common problems:
- Public administrative routes
- Missing auth middleware on new endpoints
- Broken Object-Level Authorization (BOLA / IDOR): fetching resources by ID without verifying tenant or ownership

---

## 7. SSRF (Server-Side Request Forgery)

Detect HTTP client calls where destination URLs or hostnames are supplied by users.

❌ Wrong:
```
httpClient.get(user_provided_url)
```

Risk: The server can be coerced into accessing internal cloud metadata endpoints (`169.254.169.254`), internal databases, or private microservices.

✅ Correct:
Validate URLs against an explicit domain whitelist and disallow private/loopback IP ranges.

---

## 8. Missing Rate Limiting / Abuse Protection

Critical endpoints must have abuse and brute-force protection:
- Login / authentication endpoints
- Password reset / MFA verification
- Expensive reporting or webhook dispatch endpoints

---

## 9. Insecure File Upload & Path Traversal

Verify:
- Strict file extension and MIME type validation
- Maximum file size limits
- Sanitization of filenames to prevent directory traversal (`../../etc/passwd`)
- Storage outside public web roots or in object storage (S3, GCS)

---

# Detection Protocol

Whenever reviewing or generating code, the system MUST:

### 1. Scan for Vulnerability Patterns
- String interpolation or concatenation in SQL, shell, or NoSQL queries
- Direct persistence of untrusted input objects
- Missing schema validation on incoming transport handlers
- Hardcoded credentials or tokens
- User-controlled URLs in HTTP client requests
- Missing authentication / authorization guards on routes
- Unsanitized paths in file system operations

### 2. Classify Findings

| Severity     | Criteria                                           |
| ------------ | -------------------------------------------------- |
| 🔴 Critical  | Injection, broken auth, hardcoded secrets, SSRF, BOLA |
| 🟡 Important | Missing input validation, missing rate limiting    |
| 💡 Suggestion| Defensive hardening, security headers, log scrubbing |

### 3. Generate Corrective Comments
Use the templates from `skills/backend-code-review/references/comment-templates.md`.

---

# Hard Execution Gate

The system MUST NOT:
- Ignore 🔴 Critical security findings.
- Approve code with SQL injection, mass assignment, or hardcoded credentials without flagging.
- Suggest disabling security checks or validation as a workaround.

The system MUST:
- Flag every detected security vulnerability.
- Suggest a concrete, parameterized, and validated correction in the target language.
- Prioritize security over all other review dimensions.

---

## Security Principle

Security findings are never optional.

Injection > convenience.
Validation > trust.
Explicit > implicit.