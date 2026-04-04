# OpenCode

**OpenCode** é um agente de IA que opera diretamente no repositório, seguindo regras definidas em `rules/`.

---

## Regras OpenCode

| Arquivo | Descrição |
|---------|-----------|
| `10-no-pull-main.md` | Proteger branches principais (`main`, `master`) |
| `20-new-branch-feature.md` | Protocolo de criação de branches a partir da base estável |
| `30-no-push-forcce.md` | Bloquear force-push e operações destrutivas |
| `40-no-root-aliasses-backend.md` | Proibir uso de aliases (`@/`, `~/*`) |
| `50-plan-before-work.md` | Technical Design Phase (TDP) obrigatório |
| `60-migration-entity.md` | Completude Entity + Migration |
| `70-vbca.md` | Version Bump & Changelog após aprovação |
| `80-release-governance.md` | Governança de release com aprovação explícita |
| `90-mermaid-only-diagrams.md` | Apenas diagramas Mermaid |

---

## Comandos OpenCode

| Comando | Descrição |
|---------|-----------|
| `/tdp` | Iniciar Technical Design Phase |
| `/finish-task` | Finalizar tarefa e solicitar aprovação |
| `/release` | Executar release update após aprovação |

---

## Fluxo de Trabalho

```
1. Criar branch a partir da base estável
   → git checkout -b feat/LABS-123-minha-feature

2. Criar TDD em specs/tdd-labs-123-minha-feature.md
   → /tdp

3. Implementar código

4. Solicitar aprovação
   → /finish-task

5. Executar release (se aprovado)
   → /release
```

---

## Regras de Segurança (Block Merge)

Os seguintes problemas **bloqueiam o merge**:

- **SQL Injection**: Queries construídas dinamicamente
- **Mass Assignment**: Salvando `req.body` diretamente
- **Autenticação ausente**: Endpoints sensíveis sem proteção
- **Secrets hardcoded**: Credenciais no código

### Como Detectar

```typescript
// ❌ SQL Injection
await repo.query(`SELECT * FROM users WHERE id = ${userId}`)

// ✅ Correto
await repo.query('SELECT * FROM users WHERE id = ?', [userId])
```

---

## Arquitetura Esperada

```
controller → usecase/service → repository → database
```

**Violações críticas:**
- Controller acessando repository diretamente
- Use case conhecendo Express/HTTP
- Domínio dependendo de ORM/infraestrutura

---

## Conventional Commits

Todos os commits devem seguir:

```
<tipo>(<escopo>): <descrição>
```

**Tipos permitidos:**
- `feat` — Nova funcionalidade
- `fix` — Correção de bug
- `docs` — Documentação
- `refactor` — Refatoração
- `test` — Testes
- `chore` — Tarefas de manutenção

**Exemplos:**
```
feat(api): adicionar endpoint de autenticação
fix(ui): corrigir formatação de data no dashboard
docs(tdd): adicionar design da feature
```
