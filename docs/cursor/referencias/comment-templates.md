# Templates de Comentários Inline — Backend Code Review

Use estes templates ao formatar comentários no preview e ao postá-los no GitLab.

## Estrutura de um comentário inline

Todo comentário deve ter:

1. **Emoji de severidade**
2. **Categoria**
3. **Descrição objetiva**
4. **Sugestão concreta**

> Inicie cada descrição se referindo ao usuário como **"Mestre"**.

---

# 🔴 Bug / Lógica incorreta

````markdown
🔴 **Bug**: [Título curto]

Mestre, a lógica implementada não cobre corretamente o cenário esperado.

[Descrever o comportamento atual e o impacto.]

**Sugestão:**
```ts
// código corrigido
````

````

---

# 🔴 Segurança

```markdown
🔴 **Segurança**: [Título]

Mestre, esta implementação pode introduzir uma vulnerabilidade.

[Descrever vetor de ataque: SQL injection, exposição de dados, bypass de auth.]

Impacto: [acesso indevido, vazamento de dados etc.]

**Sugestão:**
```ts
// implementação segura
````

````

---

# 🔴 Consistência de dados

```markdown
🔴 **Consistência de dados**: Operações sem transação

Mestre, este fluxo executa múltiplas operações no banco sem transação.

Caso uma falhe, o sistema pode ficar em estado inconsistente.

**Sugestão:**
```ts
await dataSource.transaction(async manager => {
  await manager.save(entity1)
  await manager.save(entity2)
})
````

````

---

# 🟡 Arquitetura — Clean Architecture

```markdown
🟡 **Arquitetura**: Violação de camada

Mestre, esta lógica está sendo executada em uma camada incorreta.

Controllers devem apenas orquestrar requisições HTTP e delegar regras de negócio para use cases.

**Sugestão:** mover a lógica para `usecases/`.
````

---

# 🟡 Persistência — TypeORM

```markdown
🟡 **Persistência**: Filtro em memória

Mestre, este filtro está sendo aplicado após carregar os dados do banco.

Isso pode causar alto consumo de memória e degradação de performance.

**Sugestão:** mover o filtro para a query SQL ou QueryBuilder.
```

---

# 🟡 Tratamento de erro

````markdown
🟡 **Tratamento de erro**: Falta de tratamento explícito

Mestre, esta chamada assíncrona pode falhar e não possui tratamento de erro.

**Sugestão:**
```ts
try {
  await service.execute(data)
} catch (error) {
  logger.error(error)
  throw new AppError("Erro ao processar requisição")
}
````

````

---

# 🟡 Teste ausente

```markdown
🟡 **Teste ausente**: [Nome do use case]

Mestre, este módulo contém lógica de negócio relevante e não possui testes unitários.

Sugestão: adicionar testes cobrindo:

- caminho feliz
- tratamento de erro
- regras de negócio principais
````

---

# 🟡 Performance

```markdown
🟡 **Performance**: N+1 Query

Mestre, esta implementação pode gerar múltiplas queries ao acessar relações.

Impacto: degradação de performance em grandes volumes de dados.

**Sugestão:** usar `leftJoinAndSelect` ou eager loading controlado.
```

---

# 🟢 Sugestão / Melhoria

````markdown
💡 **Sugestão**: [Título]

Mestre, esta implementação pode ser simplificada para melhorar legibilidade e manutenção.

**Alternativa:**
```ts
// código sugerido
````

````

---

# Comentário geral no MR — Requisito não atendido

```markdown
⚠️ **Requisito não contemplado — [LABS-XXX]**

Com base na issue **[título da issue]**, o seguinte requisito não foi identificado na diff:

> [trecho do requisito]

**O que está faltando:** [descrição]

Se este requisito foi intencionalmente adiado ou está em outro MR, favor documentar.
````

---

# Comentário geral no MR — Resumo do review

```markdown
## Code Review — Resumo

**Issue:** [LABS-XXX — Título]
**Reviewer:** Cursor Backend Reviewer

### Validação de Requisitos

| Requisito | Status |
|-----------|--------|
| Req 1 | ✅ |
| Req 2 | ⚠️ |
| Req 3 | ❌ |

### Achados

- 🔴 Críticos: N
- 🟡 Importantes: N
- 💡 Sugestões: N

Score final: XX/100
```

---

# Guia de severidade

| Emoji | Nível      | Ação           |
| ----- | ---------- | -------------- |
| 🔴    | Crítico    | Bloquear merge |
| 🟡    | Importante | Corrigir no MR |
| 💡    | Sugestão   | Opcional       |
|       |            |                |
