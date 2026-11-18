# OpenCode - Visão Geral

## O que é?

**OpenCode** é um agente de IA que opera diretamente no repositório, executando tarefas de código seguindo regras definidas em `.opencode/rules/`.

## Características Principais

- **Execução direta**: Opera no filesystem sem necessidade de interface visual
- **Regras codificadas**: Comportamento ditado por arquivos Markdown em `.opencode/`
- **Comandos customizados**: Fluxos automatizados via `/comando`
- **Governança Git**: Protege branches e força boas práticas

## Estrutura do OpenCode (v2)

```
.opencode/
├── agents/         # Agentes especializados (ex: code-reviewer.md)
├── commands/       # Comandos customizados
├── rules/          # Regras operacionais (carregadas via instructions no opencode.json)
├── skills/         # Skills reutilizáveis (ex: backend-code-review)
└── opencode.json   # Schema v2, instructions e permissions
```

## Lista de Regras

| Prioridade | Regra | Descrição |
|------------|-------|-----------|
| 10 | Protected Branch Guard | Proteger `main`/`master` |
| 20 | Stable-Base Branching | Criar branches da base estável |
| 30 | Git Governance | Force-push bloqueado, Conventional Commits |
| 40 | No Root Aliases | Proibir `@/` imports |
| 50 | Plan Before Work | TDP obrigatório |
| 55 | Mermaid Diagrams | Apenas diagramas Mermaid |
| 60 | Entity+Migration | Completude no banco |
| 70 | Version Bump | Changelog após aprovação |
| 80 | Release Governance | Aprovação explícita para release |
| 90 | Mandatory Tests | Testes unitários obrigatórios |
| 95 | Compile on Change | Sincronizar `AGENTS.md` ao alterar configs |
| 99 | No Unsafe Types | Proibir `any` e tipos inseguros |

## Comandos Disponíveis

| Comando | Função |
|---------|--------|
| `/tdp` | Iniciar Technical Design Phase |
| `/code-review` | Revisão de código backend (subagent `code-reviewer`) |
| `/finish-task` | Finalizar tarefa e pedir aprovação |
| `/release` | Executar release (após aprovação) |
| `/update-opencode` | Atualizar configurações OpenCode do projeto/global |

## Fluxo Básico

```mermaid
graph LR
    A[git fetch] --> B[Criar branch]
    B --> C[/tdp - Criar TDD]
    C --> D{Aprovado?}
    D -->|Sim| E[Implementar]
    D -->|Não| C
    E --> F[/finish-task]
    F --> G{Aprovado?}
    G -->|Sim| H[/release]
    G -->|Não| E
    H --> I[Version bump]
    I --> J[Update CHANGELOG]
```

## Próximos Passos

- [Regras Operacionais](regras-operacionais.md)
- [Comandos](comandos.md)
- [Fluxo de Trabalho](fluxo-de-trabalho.md)
- [Telegram Bot (Controle Remoto v2)](telegram-bot.md)
