# Backend Review Mode

Quando o usuário solicitar **code review**, **review de PR**, **review de MR** ou **análise de diff**, o agente deve operar em **modo de revisão técnica profunda**.

Projetos alvo:

* Node.js
* TypeScript
* Express
* TypeORM
* MySQL
* Clean Architecture
* tsyringe
* Jest

---

# Comportamento esperado

Durante o review o agente deve:

1. Ler a diff completa antes de comentar
2. Detectar anti-patterns definidos em `backend-anti-patterns.md`
3. Verificar violações de arquitetura
4. Identificar riscos de segurança
5. Analisar performance e queries
6. Verificar presença de testes

---

# Prioridade de análise

Ordem obrigatória:

1️⃣ Segurança
2️⃣ Consistência de dados
3️⃣ Bugs de lógica
4️⃣ Arquitetura
5️⃣ Performance
6️⃣ Testes
7️⃣ Qualidade de código

---

# Regras arquiteturais

Arquitetura esperada:

```
controller → usecase/service → repository → database
```

Violação crítica se:

* controller acessa repository
* usecase acessa ORM diretamente
* domínio depende de infraestrutura

---

# Heurísticas importantes

Sempre verificar:

### Async

* Promise sem await
* loops async sequenciais
* erros não tratados

---

### Banco

* filtros em memória
* N+1 queries
* queries sem limite
* múltiplas operações sem transação

---

### TypeScript

* uso excessivo de `any`
* DTO ausente
* retorno implícito

---

# Detecção de problemas

Sempre classificar achados em:

| Severidade    | Critério                                           |
| ------------- | -------------------------------------------------- |
| 🔴 Crítico    | pode causar bug, vulnerabilidade ou inconsistência |
| 🟡 Importante | impacta arquitetura ou manutenção                  |
| 💡 Sugestão   | melhoria opcional                                  |

---

# Formato dos comentários

Usar sempre os templates definidos em:

```
.cursor/skills/backend-code-review/references/comment-templates.md
```

---

# Fluxo esperado de review

1. Ler MR/diff
2. Detectar anti-patterns
3. Validar arquitetura
4. Gerar comentários estruturados
5. Gerar resumo do review
