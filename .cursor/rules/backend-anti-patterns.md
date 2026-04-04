# Backend Anti-Patterns — Node.js / TypeScript

Este arquivo define **anti-patterns comuns** que devem ser detectados automaticamente durante code reviews.

Projetos alvo:

* Node.js
* TypeScript
* Express
* TypeORM
* MySQL
* Clean Architecture
* tsyringe
* Jest

Sempre que um destes padrões for identificado:

1. Classifique a severidade
2. Gere um comentário usando os templates da skill
3. Sugira uma alternativa

---

# 🔴 Anti-patterns Críticos

## 1. Controller acessando repository diretamente

Errado:

```ts
const user = await userRepository.findOne(id)
```

Motivo:

Controllers não devem acessar persistência diretamente.

Correto:

```
controller → usecase → repository
```

---

## 2. SQL concatenado manualmente

Errado:

```ts
await repository.query(
  `SELECT * FROM users WHERE id = ${userId}`
)
```

Risco:

SQL Injection.

Correto:

```ts
await repository.query(
  "SELECT * FROM users WHERE id = ?",
  [userId]
)
```

---

## 3. Promise sem await

Errado:

```ts
service.execute(data)
```

Problema:

* erros silenciosos
* execução fora do fluxo esperado

Correto:

```ts
await service.execute(data)
```

---

## 4. Múltiplas operações sem transação

Errado:

```ts
await orderRepository.save(order)
await paymentRepository.save(payment)
```

Risco:

estado inconsistente.

Correto:

```ts
await dataSource.transaction(async manager => {
  await manager.save(order)
  await manager.save(payment)
})
```

---

## 5. Domínio dependendo de infraestrutura

Errado:

```
domain → repository
domain → orm
```

Correto:

```
domain → interfaces
infra → implementação
```

---

# 🟡 Anti-patterns Importantes

## 6. Filtro aplicado em memória

Errado:

```ts
const users = await repository.find()
return users.filter(u => u.active)
```

Problema:

carrega todos os registros.

Correto:

```ts
repository.find({
  where: { active: true }
})
```

---

## 7. N+1 Queries

Errado:

```ts
for (const order of orders) {
  await repository.findItems(order.id)
}
```

Correto:

```ts
leftJoinAndSelect("order.items", "items")
```

---

## 8. Loop async sequencial

Errado:

```ts
for (const item of items) {
  await process(item)
}
```

Correto:

```ts
await Promise.all(items.map(process))
```

---

## 9. Uso excessivo de `any`

Errado:

```ts
function create(data: any)
```

Problema:

perda de segurança de tipos.

Correto:

```ts
function create(data: CreateUserDTO)
```

---

## 10. Funções muito grandes

Heurística:

* > 50 linhas
* múltiplas responsabilidades

Sugestão:

dividir em funções menores ou extrair use case.

---

# 🟢 Anti-patterns de melhoria

## 11. Logs não estruturados

Errado:

```ts
console.log("user created", user)
```

Correto:

```ts
logger.info("user_created", { userId: user.id })
```

---

## 12. Falta de DTO

Controllers não devem trabalhar diretamente com entidades.

Errado:

```ts
createUser(user: User)
```

Correto:

```ts
createUser(dto: CreateUserDTO)
```

---

# Heurísticas de detecção

Durante o review, verifique automaticamente:

### Arquitetura

* controller importando repository
* usecase importando express
* domínio importando orm

---

### Banco

* `.find()` seguido de `.filter()`
* `.save()` dentro de loops
* query SQL com template string

---

### Async

* função async sem await
* loop com await sequencial

---

### Tipagem

* uso de `any`
* retorno implícito

---

# Ação esperada

Quando detectar um anti-pattern:

1. Classificar severidade
2. Gerar comentário usando template
3. Sugerir correção
4. Contabilizar no score do MR
