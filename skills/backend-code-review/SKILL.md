---

name: backend-code-review
description: Realiza code review de código backend Node.js/TypeScript aplicando regras de arquitetura Clean Architecture, segurança, persistência TypeORM, qualidade de código e cobertura de testes.

---

# Backend Code Review

Review guide for backend projects using:

- Node.js
- TypeScript
- Express
- TypeORM
- MySQL
- Clean Architecture
- tsyringe
- Jest

Use templates in `references/comment-templates.md` to format comments.

---

# Workflow

Follow the steps **in order**.

---

# Step 1 — Collect code for review

The user must provide the code to review. This can be:

- A diff (git diff, PR diff)
- Specific files
- A code snippet
- A branch name (the agent will read the diff)

If the user does not provide code, ask:

> "Which code would you like me to review? You can provide a diff, file paths, a branch name, or paste a snippet."

---

# Step 2 — Apply review rules

Apply the rules defined in:

```
references/review-rules.md
```

Also apply rules from:

- `rules/backend-anti-patterns.md` — anti-pattern detection
- `rules/backend-security-review.md` — security vulnerability detection
- `rules/staff-engineer-review.md` — Staff Engineer-level review dimensions

Prioritize:

## 🔴 Critical

- security
- data consistency
- bugs

## 🟡 Important

- architecture
- performance
- tests

## 🟢 Improvements

- patterns
- naming
- organization

---

# Step 3 — Analyze critical dimensions

For each finding, evaluate across all review dimensions:

1. **Architecture** — layer violations, coupling, boundary breaches
2. **Domain Design** — misplaced business logic, anemic entities
3. **Scalability** — N+1, in-memory filters, unbounded queries
4. **Reliability** — missing error handling, missing transactions
5. **Observability** — missing logs, generic errors
6. **Testability** — untestable code, missing mocks

---

# Step 4 — Generate structured preview

Generate a preview using templates from `references/comment-templates.md`:

```
## Review Preview

### [FILE: src/controllers/user-controller.ts]

Line 32 | 🔴 Bug

Problem description.

Suggestion.

---

### [FILE: src/usecases/create-user.ts]

Line 14 | 🟡 Architecture

Description.

---

## Summary

Critical: N
Important: N
Suggestions: N
```

---

# Step 5 — Issue summary

At the end, generate a structured summary:

```
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

- Always read the full code/diff before commenting
- Never comment without understanding the context
- Classify every finding by severity
- Provide concrete suggestions, not just criticism
- Distinguish between "must fix" (🔴) and "nice to have" (💡)
- If no critical issues are found, state that clearly
- Focus on the code — do not speculate about Jira tickets or external requirements