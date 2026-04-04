# OpenCode - Fluxo de Trabalho

## Visão Geral

Este documento descreve o fluxo completo de trabalho do OpenCode, desde o recebimento de uma task até o release.

---

## Fluxo Principal

```mermaid
flowchart TD
    A[Receber Task] --> B{È mudança simples?}
    B -->|Sim, ex: typo| F[Implementar]
    B -->|Não| C[Criar Branch Feature]
    C --> D[/tdp - Technical Design]
    D --> E{TDD Aprovado?}
    E -->|Não| D
    E -->|Sim| F[Implementar]
    F --> G[Testar Localmente]
    G --> H{Checks Passam?}
    H -->|Não| G
    H -->|Sim| I{/finish-task}
    I --> J{Developer Aprova?}
    J -->|Não| F
    J -->|Sim| K[/release]
    K --> L[Bump Version]
    L --> M[Update CHANGELOG]
    M --> N[Preparar Commit]
    N --> O[Finalizado]
```

---

## 1. Receber Task

O agente recebe uma task do Developer. Pode ser:
- Nova feature
- Bug fix
- Refatoração
- Documentação

### Exemplo
```
Developer: preciso adicionar validação de email no cadastro
```

---

## 2. Criar Branch (se necessário)

Para mudanças que não sejam triviais, criar branch feature:

### Passo a Passo

```bash
# 1. Identificar base estável
git fetch --all --prune
git branch

# Base estável: main

# 2. Atualizar base
git checkout main
git pull --ff-only

# 3. Criar feature branch
git checkout -b feat/LABS-123-email-validation
```

### Formato do Branch
```
<tipo>/<issue-id>-<slug>

feat/LABS-123-email-validation
fix/ISSUE-456-login-bug
chore/LABS-789-deps-update
```

---

## 3. Technical Design Phase (TDP)

Para features e refatorações, criar TDD em `specs/`.

### Criar TDD

```bash
# Arquivo: specs/tdd-labs-123-email-validation.md
```

### Estrutura do TDD

```markdown
# TDD: Email Validation Feature

## Objective & Scope

**What:** Adicionar validação de email no endpoint de cadastro de usuários.

**Why:** Garantir integridade dos dados e melhorar experiência do usuário com feedback imediato.

**File Target:** specs/tdd-labs-123-email-validation.md

## Proposed Technical Strategy

### Logic Flow
1. Receber request com email
2. Validar formato com regex
3. Verificar domínioMX (opcional)
4. Retornar erro amigável se inválido

### Impacted Files
- src/controllers/user.controller.ts
- src/dto/create-user.dto.ts
- src/validators/email.validator.ts

### Language-Specific Guardrails
- Usar DTO explícito (nunca `any`)
- Usar `class-validator` para validação
- Retornar erros estruturados

## Implementation Plan

### Pseudocode
```typescript
// email.validator.ts
function validateEmail(email: string): ValidationResult {
  if (!isValidFormat(email)) {
    return { valid: false, error: 'invalid_format' }
  }
  return { valid: true }
}

// controller
async create(@Body() dto: CreateUserDTO) {
  const validation = validateEmail(dto.email)
  if (!validation.valid) {
    throw new BadRequestException(validation.error)
  }
  return this.userService.create(dto)
}
```

### Path Resolution
- Validator: `src/validators/` (novo)
- DTO: `src/dto/create-user.dto.ts` (existente)

### Naming Standards
- Arquivo: `email.validator.ts`
- Função: `validateEmail()`
- DTO: `CreateUserDTO`
```

### Aguardar Aprovação

```
Mestre, criei o TDD em specs/tdd-labs-123-email-validation.md.

Aprova esta abordagem técnica?

Principais decisões:
1. Usar class-validator para validação
2. Validar formato com regex
3. Tratar erros com BadRequestException

[Sim/Aprovo] ou [Não, ajustar: ...]
```

---

## 4. Implementar

Após aprovação do TDD, implementar o código seguindo:
- TDD documentado
- Code Style do AGENTS.md
- Arquitetura Clean Architecture

### Checklist de Implementação
- [ ] Códigocompila
- [ ] Testes passando
- [ ] Lint passando
- [ ] DTOs criados
- [ ] Validações implementadas
- [ ] Erros tratados

---

## 5. Finalizar Task

Executar `/finish-task` para resumir entrega.

### Output

```markdown
## Task Completed: Email Validation

### Summary
- Adicionado validador de email em src/validators/email.validator.ts
- Criado DTO CreateUserDTO com validação
- Endpoint POST /users agora valida email antes de criar

### Files Changed
- src/validators/email.validator.ts (novo)
- src/dto/create-user.dto.ts (modificado)
- src/controllers/user.controller.ts (modificado)
- tests/unit/email.validator.spec.ts (novo)

### Change Classification
feat

### Current Version
1.2.3

### Recommended Bump
MINOR

### Next Version
1.2.4

---

❓ Aprova estas mudanças e o version bump proposto, Developer?
```

---

## 6. Release

Se aprovado, executar `/release`.

### Ações
1. Atualizar `package.json` (1.2.3 → 1.2.4)
2. Atualizar `CHANGELOG.md`

### Output Final

```markdown
## Release Prepared

| Item | Valor |
|------|-------|
| Versão Anterior | 1.2.3 |
| Nova Versão | 1.2.4 |
| Bump | MINOR |
| Arquivos | package.json, CHANGELOG.md |

### Commit Sugerido
chore(release): bump version to 1.2.4

### Tag Sugerida
v1.2.4

Deseja que eu execute o commit?
```

---

## Regras de Hard Stop

O fluxo **para** se:

| Situação | Ação |
|----------|------|
| Branch protected | Não permite modificação |
| TDD não aprovado | Não implementa |
| `/finish-task` não executado | `/release` bloqueado |
| Aprovação não obtida | Não faz version bump |
| Migration não executada | Não continua feature |

---

## Casos Especiais

### Bug Crítico em Produção
```
User: produção caindo, preciso corrigir agora

Agent:
1. git fetch
2. git checkout hotfix/EMERGENCY-123-urgent-fix
3. Implementar correção
4. /finish-task
5. /release
```

### Task Simples (typo, docs)
```
User: corrigir typo no README

Agent:
1. git checkout -b chore/LABS-456-fix-readme-typo
2. Corrigir typo
3. /finish-task
4. /release (se aplicável)
```

### Dependência de Outro MR
```
Agent: Esta feature depende do MR #45.
Aguarde até que #45 seja mergeado.
```
