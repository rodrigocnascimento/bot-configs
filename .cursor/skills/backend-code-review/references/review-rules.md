# Regras de Code Review — Backend

Projetos alvo:

* Node.js
* TypeScript
* Express
* TypeORM
* MySQL
* Clean Architecture
* tsyringe (DI)
* Jest

---

# Arquitetura Esperada

Fluxo de dependências:

```
controller → usecase/service → repository → database
```

Regras:

* Controllers não acessam banco diretamente
* Use cases não conhecem Express
* Repositories não contêm regra de negócio

---

# 🔴 Problemas Críticos

## Segurança

* SQL concatenado manualmente
* dados sensíveis em logs
* falta de validação de input
* autenticação bypassável

---

## Consistência de dados

* múltiplas operações sem transação
* race conditions

---

## Bugs

* promise sem await
* tratamento de erro inexistente
* regras de negócio incorretas

---

## Arquitetura

* controller chamando repository
* domínio importando infra
* dependência circular

---

# 🟡 Problemas Importantes

## Performance

* N+1 queries
* filtros em memória
* falta de paginação

---

## Código

* funções grandes
* duplicação de lógica
* DTO ausente

---

## Testes

* use case sem teste
* testes dependentes de banco real
* mocks inexistentes

---

# 🟢 Melhorias

* logs estruturados
* padronização de erro (`AppError`)
* nomenclatura consistente
