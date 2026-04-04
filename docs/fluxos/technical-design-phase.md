# Technical Design Phase (TDP)

## Visão Geral

Processo obrigatório de design técnico **antes** de qualquer implementação de código.

---

## Quando Executar

Execute TDP para:
- ✅ Novas features
- ✅ Refatorações significativas
- ✅ Mudanças de arquitetura
- ✅ Integrações complexas

Execute **sem** TDP:
- ⚠️ Correções triviais (typos, formatação)
- ⚠️ Hotfixes de emergência
- ⚠️ Updates de dependências

---

## Fluxo do TDP

```mermaid
flowchart TD
    A[Receber Task] --> B{Criar TDD?}
    B -->|Sim| C[/tdp]
    C --> D[Criar specs/tdd-<slug>.md]
    D --> E{Developer Aprova?}
    E -->|Ajustes| F[Revisar TDD]
    F --> D
    E -->|Aprovado| G[Implementar]
    G --> H[/finish-task]
    B -->|Trivial| I[Implementar direto]
```

---

## 1. Criar TDD

### Localização
```
specs/tdd-<feature-slug>.md
```

### Estrutura Obrigatória

```markdown
# TDD: [Feature Name]

## Objective & Scope
- What: ...
- Why: ...
- File Target: specs/tdd-<feature-slug>.md

## Proposed Technical Strategy
- Logic Flow
- Impacted Files
- Language-Specific Guardrails

## Implementation Plan
- Pseudocode/method signatures
- Path Resolution
- Naming Standards
```

---

## 2. Objective & Scope

### What
Descrição concisa do que será feito.

```markdown
**What:** Adicionar autenticação JWT com refresh tokens no endpoint de login.

**What:** Refatorar UserRepository para usar QueryBuilder.

**What:** Adicionar paginação no endpoint GET /users.
```

### Why
Justificativa técnica.

```markdown
**Why:** 
- Padronizar autenticação seguindo best practices
- Melhorar segurança com refresh tokens
- Suportar múltiplas sessões por usuário
```

### File Target
Indicar explicitamente onde o TDD será salvo.

```markdown
**File Target:** specs/tdd-labs-123-jwt-auth.md
```

---

## 3. Proposed Technical Strategy

### Logic Flow
Passo a passo da lógica.

```markdown
### Logic Flow

1. Receber POST /api/auth/login com email e password
2. Validar DTO (email válido, password não vazio)
3. Buscar usuário por email
4. Verificar hash da senha
5. Se válido:
   - Gerar access token (JWT, 15min)
   - Gerar refresh token (JWT, 7dias)
   - Salvar refresh token no banco
   - Retornar tokens
6. Se inválido:
   - Retornar 401 Unauthorized
```

### Impacted Files
Lista de arquivos a modificar/criar.

```markdown
### Impacted Files

**Modificados:**
- src/auth/auth.controller.ts
- src/auth/auth.service.ts
- src/auth/jwt.strategy.ts

**Criados:**
- src/auth/dto/login.dto.ts
- src/auth/dto/token.dto.ts
- src/auth/repositories/refresh-token.repository.ts

**Não modificar:**
- User entity (evitar rebase com MRs existentes)
```

### Language-Specific Guardrails
Regras específicas para a tecnologia.

```markdown
### TypeScript Guardrails

- Usar DTO explícito (não `any`)
- Retornar `Promise<User>` ou `Promise<null>`
- Usar `class-validator` para validação
- Interfaces para repositories

### TypeORM Guardrails

- Queries parametrizadas
- Transações para refresh tokens
- Índices para email lookup
```

---

## 4. Implementation Plan

### Pseudocode / Method Signatures

```markdown
### Method Signatures

```typescript
// DTO
interface LoginDTO {
  email: string;
  password: string;
}

interface TokenResponseDTO {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

// Controller
async login(@Body() dto: LoginDTO): Promise<TokenResponseDTO>

// Service
async login(dto: LoginDTO): Promise<TokenResponseDTO>
async refreshToken(token: string): Promise<TokenResponseDTO>
async logout(userId: string): Promise<void>
```

### Path Resolution
Caminhos dos arquivos.

```markdown
### Path Resolution

```
src/
└── auth/
    ├── auth.controller.ts      (existente, modificar)
    ├── auth.service.ts         (existente, modificar)
    ├── dto/
    │   ├── login.dto.ts        (novo)
    │   └── token.dto.ts        (novo)
    └── repositories/
        └── refresh-token.repository.ts  (novo)
```

### Naming Standards
Convenção de nomes.

```markdown
### Naming Standards

- Arquivos: kebab-case (login.dto.ts)
- Classes: PascalCase (LoginDTO)
- Métodos: camelCase (login)
- Constantes: UPPER_SNAKE (TOKEN_EXPIRY)
```

---

## 5. Aguardar Aprovação

### Output do Agente

```
Mestre, criei o TDD em specs/tdd-labs-123-jwt-auth.md.

## TDD: JWT Authentication

### Objective
Adicionar autenticação JWT com refresh tokens.

### Strategy
1. Validar credenciais
2. Gerar access token (15min)
3. Gerar refresh token (7 dias)
4. Retornar tokens ao cliente

### Impacted Files
- auth.controller.ts (modificar)
- auth.service.ts (modificar)
- login.dto.ts (novo)
- refresh-token.repository.ts (novo)

---

Aprova esta abordagem técnica, Developer?

[Sim] ou [Não, ajustar: ...]
```

### Respostas Válidas

**Aprovação:**
- "sim"
- "approved"
- "ok"
- "proceed"

**Rejeição:**
- "não, ajustar o item X"
- "falta cobrir o caso de token expirado"

---

## 6. Hard Stop

```
🔴 IMPAR: TDD não aprovado.

Não prossiga para implementação até aprovação explícita do Developer.
```

---

## Exemplo Completo

### TDD Criado

```markdown
# TDD: Email Validation Feature

## Objective & Scope

**What:** Adicionar validação de email no endpoint de cadastro de usuários.

**Why:** Garantir integridade dos dados e melhorar UX com feedback imediato.

**File Target:** specs/tdd-labs-456-email-validation.md

## Proposed Technical Strategy

### Logic Flow

1. Receber POST /users com email no body
2. Validar formato do email com regex
3. Se inválido: retornar 400 Bad Request
4. Se válido: prosseguir com criação
5. Logar tentativa (sem dados sensíveis)

### Impacted Files

**Modificados:**
- src/controllers/user.controller.ts
- src/dto/create-user.dto.ts

**Criados:**
- src/validators/email.validator.ts

**Não modificar:**
- User entity (evitar conflitos)

### TypeScript Guardrails

- Usar `class-validator` com `@IsEmail()`
- DTO explícito (não `any`)
- Retornar erros estruturados
- Não logar email completo

## Implementation Plan

### Pseudocode

```typescript
// email.validator.ts
import { IsEmail } from 'class-validator';

export class EmailValidator {
  isValid(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }
}

// controller
async create(@Body() dto: CreateUserDTO) {
  const emailValidator = new EmailValidator();
  
  if (!emailValidator.isValid(dto.email)) {
    throw new BadRequestException('Invalid email format');
  }
  
  return this.userService.create(dto);
}
```

### Path Resolution

```
src/
├── validators/
│   └── email.validator.ts    (novo)
├── dto/
│   └── create-user.dto.ts    (modificar)
└── controllers/
    └── user.controller.ts    (modificar)
```

### Naming Standards

- Arquivo: `email.validator.ts`
- Classe: `EmailValidator`
- Método: `isValid()`
- DTO: `CreateUserDTO` (existente)
```

### Diálogo

```
Agent: Mestre, TDD criado em specs/tdd-labs-456-email-validation.md.

Aprova esta abordagem técnica?

User: sim, approved

Agent: ✅ Aprovado. Prosseguindo com implementação.
```

---

## Checklist do TDP

- [ ] Arquivo criado em `specs/tdd-<slug>.md`
- [ ] `Objective & Scope` preenchido
- [ ] `Proposed Technical Strategy` detalhado
- [ ] `Implementation Plan` com pseudocódigo
- [ ] Aprovação explícita obtida
