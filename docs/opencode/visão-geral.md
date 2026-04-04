# OpenCode - Visão Geral

## O que é?

**OpenCode** é um agente de IA que opera diretamente no repositório, executando tarefas de código seguindo regras definidas em `.opencode/rules/`.

## Características Principais

- **Execução direta**: Opera no filesystem sem necessidade de interface visual
- **Regras codificadas**: Comportamento ditado por arquivos Markdown em `.opencode/`
- **Comandos customizados**: Fluxos automatizados via `/comando`
- **Governança Git**: Protege branches e força boas práticas

## Estrutura do OpenCode

```
.opencode/
├── rules/          # Regras operacionais (10-90)
├── commands/       # Comandos customizados
└── agents/        # Agentes especializados
```

## Lista de Regras

| Prioridade | Regra | Descrição |
|------------|-------|-----------|
| 10 | Protected Branch Guard | Proteger `main`/`master` |
| 20 | Stable-Base Branching | Criar branches da base estável |
| 30 | Git Governance | Force-push bloqueado, Conventional Commits |
| 40 | No Root Aliases | Proibir `@/` imports |
| 50 | Plan Before Work | TDP obrigatório |
| 60 | Entity+Migration | Completude no banco |
| 70 | Version Bump | Changelog após aprovação |
| 80 | Release Governance | Aprovação explícita para release |
| 90 | Mermaid Diagrams | Apenas diagramas Mermaid |

## Comandos Disponíveis

| Comando | Função |
|---------|--------|
| `/tdp` | Iniciar Technical Design Phase |
| `/finish-task` | Finalizar tarefa e pedir aprovação |
| `/release` | Executar release (após aprovação) |

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
