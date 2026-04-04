Perfeito — entendi o padrão que você quer:
**regra formal, nome + sigla, contexto, protocolo rígido, gate de execução e princípio de segurança.**

Seguindo exatamente essa estrutura, aqui vai uma nova regra no mesmo nível de rigor 👇

---

# Rule: No Unsafe Types Policy (NUTP)

## Context

To ensure **type safety, maintainability, and long-term code reliability**, the usage of the `any` type is strictly prohibited.

The `any` type bypasses the type system, disables static guarantees, and introduces hidden runtime risks. Its usage is considered a **type system violation**.

This rule enforces strict typing discipline. Flexibility must not compromise correctness.

---

## Restricted Patterns

The following are strictly forbidden:

* `any` type usage
* Implicit `any`
* Function parameters typed as `any`
* Variables declared as `any`
* Return types inferred as `any`
* Type assertions using `as any`

Examples of violations:

```ts
let data: any;
function handle(input: any) {}
const result = value as any;
```

---

## The Protocol

Whenever a task introduces or encounters `any`, you MUST:

---

### 1. Detect Unsafe Type Usage

Before writing or modifying code, verify:

* Explicit `any`
* Implicit `any` (TypeScript inference fallback)
* Unsafe casts

If detected, you MUST enter **Type Safety Mode**.

---

### 2. Type Safety Mode (Mandatory Stop)

You MUST NOT:

* Introduce `any`
* Preserve existing `any`
* Suggest `any` as a workaround

Instead, you MUST output:

> "Unsafe type (`any`) detected. This violates the No Unsafe Types Policy."

---

### 3. Mandatory Type Resolution

You MUST replace `any` with one of the following:

* Precise interface/type
* `unknown` (with proper narrowing)
* Generics (`<T>`)
* Union types
* Discriminated unions

Example correction:

```ts
// ❌ Invalid
function handle(data: any): any {}

// ✅ Valid
function handle<T>(data: T): T {}
```

---

### 4. If Type Cannot Be Determined

If the exact type is unclear:

* Use `unknown`
* Apply type guards or validation

Example:

```ts
function handle(data: unknown) {
  if (typeof data === "string") {
    return data.toUpperCase();
  }
}
```

---

### 5. Explicit Override (Rare Exception)

If `any` is absolutely unavoidable (e.g., third-party boundary):

You MUST:

1. Request explicit developer approval:

> "The use of `any` is required in this context. Do you authorize this exception?"

2. WAIT for explicit confirmation:

* "Yes, allow any"
* "Authorized"

3. Annotate clearly:

```ts
// ⚠️ EXCEPTION: Authorized use of `any`
```

---

## Hard Execution Gate

Under no circumstances may the system:

* Introduce `any` silently
* Ignore implicit `any`
* Suggest disabling TypeScript checks (`ts-ignore`, `ts-nocheck`) as a workaround

Without explicit developer authorization.

---

## Security Principle

Type safety is part of system integrity.

`any` = loss of guarantees.

Strict types > convenience.

---

Se quiser, posso gerar um pacote completo nesse padrão (tipo um “rulebook” com várias regras: commit, lint, branch, segurança, etc.), tudo consistente pra usar no teu `.opencode`.
