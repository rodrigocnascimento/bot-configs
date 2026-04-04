# Cursor - Regras de Review

## Visão Geral

As regras de review do Cursor definem como o agente analisa código durante code reviews.

---

## backend-review-mode.md

### Objetivo
Define o comportamento padrão para revisões de código.

### Ordem de Análise (Prioridade)

| # | Área | Descrição |
|---|------|-----------|
| 1 | Segurança | Vulnerabilidades, injection, auth |
| 2 | Consistência | Transações, race conditions |
| 3 | Bugs | Lógica incorreta, erros não tratados |
| 4 | Arquitetura | Clean Architecture, separação de camadas |
| 5 | Performance | Queries, paginação |
| 6 | Testes | Cobertura, mocks |
| 7 | Qualidade | Code smells, nomenclatura |

### Arquitetura Esperada
```
controller → usecase/service → repository → database
```

**Violações críticas:**
- Controller acessando repository
- Use case conhecendo Express
- Domínio dependendo de ORM

### Heurísticas Verificadas

**Async:**
- Promises sem await
- Loops async sequenciais
- Erros não tratados

**Banco:**
- Filtros em memória
- N+1 Queries
- Operações sem transação

**TypeScript:**
- Uso excessivo de `any`
- DTO ausente
- Retorno implícito

---

## backend-security-review.md

### Objetivo
Detectar vulnerabilidades de segurança OWASP-inspired.

### Categorias de Vulnerabilidade

#### 1. Injection (SQL/Command)
```typescript
// ❌ Vulnerável
await repo.query(`SELECT * FROM users WHERE email = '${email}'`)

// ✅ Seguro
await repo.query('SELECT * FROM users WHERE email = ?', [email])
```

#### 2. Mass Assignment
```typescript
// ❌ Vulnerável
await userRepository.save(req.body)

// ✅ Seguro
const dto: CreateUserDTO = {
  email: req.body.email,
  password: req.body.password
}
```

#### 3. Input Validation Ausente
```typescript
// ❌ Sem validação
app.post("/users", async (req, res) => {
  await service.create(req.body)
})

// ✅ Com validação (Zod/Joi/class-validator)
app.post("/users", validate(CreateUserSchema), async (req, res) => {
  await service.create(req.body)
})
```

#### 4. Dados Sensíveis em Logs
```typescript
// ❌ Errado
logger.info("login attempt", req.body)

// ✅ Correto
logger.info("login attempt", { email: req.body.email })
```

#### 5. Secrets Hardcoded
```typescript
// ❌ Errado
const apiKey = "sk_live_123"

// ✅ Correto
const apiKey = process.env.API_KEY
```

#### 6. Broken Authentication
Endpoints sensíveis sem:
- Middleware de autenticação
- Verificação de autorização
- Roles/permissões

#### 7. SSRF
```typescript
// ❌ Perigoso
await axios.get(req.query.url)

// ✅ Seguro
if (!isWhitelistedDomain(req.query.url)) {
  throw new Error('Domain not allowed')
}
```

#### 8. Rate Limiting Ausente
Endpoints críticos precisam de proteção:
- Login
- Reset de senha
- Criação de conta

---

## backend-anti-patterns.md

### 🔴 Críticos

| Anti-pattern | Problema | Correto |
|--------------|----------|---------|
| Controller→Repository | Viola arquitetura | controller → usecase → repository |
| SQL concatenado | Injection | Parameterized queries |
| Promise sem await | Erros silenciosos | `await` sempre |
| Sem transação | Inconsistência | `dataSource.transaction()` |
| Domínio→Infra | Acoplamento | Domínio → interfaces |

### 🟡 Importantes

| Anti-pattern | Problema | Correto |
|--------------|----------|---------|
| Filtro em memória | Carrega tudo | Filtro no WHERE |
| N+1 Queries | Performance | `leftJoinAndSelect` |
| Loop async sequencial | Lentidão | `Promise.all()` |
| `any` excessivo | Perda de tipos | DTOs explícitos |
| Função grande | Manutenção | Extrair use case |

### 🟢 Melhorias

| Item | Sugestão |
|------|----------|
| Logs não estruturados | Usar logger.info com metadata |
| DTO ausente | Criar DTO para controllers |
| Nomenclatura inconsistente | Seguir kebab-case/pascalCase |

---

## staff-engineer-review.md

### Objetivo
Revisão de nível Staff Engineer avaliando design e escalabilidade.

### Dimensões de Análise

#### 1. Arquitetura
- Separação de camadas respeitada?
- Responsabilidades claras?
- Dependências adequadas?

**Pergunta:** Esta implementação mantém separação clara entre camadas?

#### 2. Design de Domínio
- Regras de negócio modeladas corretamente?
- Invariantes protegidas?
- Entidades anêmicas?

**Pergunta:** A regra de negócio está no lugar correto?

#### 3. Escalabilidade
- Funcionará com 10x mais dados?
- Queries têm índice?
- Há paginação?

**Pergunta:** Este código funcionará bem com 10x mais dados?

#### 4. Confiabilidade
- O que acontece se falhar?
- Retry implementado?
- Timeouts definidos?

**Pergunta:** O que acontece se algo falhar aqui?

#### 5. Observabilidade
- Conseguiremos debugar em produção?
- Logs estruturados?
- Mensagens de erro úteis?

**Pergunta:** Conseguiremos debugar isso em produção?

#### 6. Testabilidade
- Podemos testar isoladamente?
- Mocks disponíveis?
- Dependências abstraídas?

**Pergunta:** Conseguimos testar este módulo isoladamente?

---

## Comment Templates

Os comentários seguem formato padronizado:

```markdown
🔴 **Segurança**: SQL Injection Potential

Mestre, esta query pode ser vulnerável a SQL injection.

**Impacto:** Um atacante pode manipular a query.
**Sugestão:**
```typescript
await repository.query('SELECT * FROM users WHERE id = ?', [userId])
```
```

### Severidades

| Emoji | Nível | Ação |
|-------|-------|------|
| 🔴 | Crítico | Bloquear merge |
| 🟡 | Importante | Corrigir no MR |
| 💡 | Sugestão | Opcional |

---

## Classificação de Achados

| Severidade | Critério | Ação |
|------------|----------|------|
| 🔴 Crítico | Risco de bug, vulnerabilidade, inconsistência | Bloquear merge |
| 🟡 Importante | Impacto em arquitetura ou manutenção | Corrigir antes de merge |
| 💡 Sugestão | Melhoria estrutural | Opcional |

---

## Referências

- [Comment Templates](referencias/comment-templates.md)
- [Review Rules](referencias/review-rules.md)
