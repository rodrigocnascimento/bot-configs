# AI Configs

![Bot Header](assets/bot-header.png)

> **📚 Documentação completa disponível em [docs/](docs/)**

Repositório de **configurações de agentes de IA** para padronização e melhoria do fluxo de desenvolvimento.

---

## 🎯 O que é este repositório?

Este é um repositório **meta** que centraliza configurações, regras e automações para agentes de IA como **OpenCode** e **Cursor**.

O objetivo é garantir que qualquer agente de IA trabalhando neste ecossistema siga:
- Padrões de código consistentes
- Fluxos de trabalho versionados (Git)
- Regras de segurança e arquitetura
- Processos de revisão automatizados

---

## 🚀 Como usar

### Configuração Global (OpenCode)

Clone este repositório em `~/.config/opencode/` para usar como config global:

```bash
git clone git@github.com:rodrigocnascimento/bot-configs.git ~/.config/opencode
```

Isso faz com que todas as regras, comandos e tools definidos aqui sejam carregados automaticamente em **todos os projetos** que você usar com OpenCode.

### Configuração por Projeto

Em cada projeto, você pode adicionar configs específicas que **se misturam** com as globais. O OpenCode mergeia as duas camadas:

```
meu-projeto/
├── .opencode/          # configs extras só deste projeto
│   ├── rules/          # regras adicionais
│   ├── commands/       # comandos adicionais
│   └── agents/         # agents adicionais
├── AGENTS.md           # contexto específico do projeto
└── opencode.json       # overrides (modelo, provider, etc)
```

**Como funciona o merge:**
- Configs globais (`~/.config/opencode/`) → base que vale pra tudo
- Configs do projeto (`.opencode/`) → adiciona ou sobrespecifica
- Se houver conflito, o projeto ganha. Se não, tudo se complementa.

### Exemplo prático

| Onde | O que colocar |
|---|---|
| `~/.config/opencode/rules/` | Regras que valem pra **todos** os projetos |
| `meu-projeto/.opencode/rules/` | Regras extras **só daquele projeto** |
| `~/.config/opencode/commands/` | Comandos globais (`/tdp`, `/release`, etc) |
| `meu-projeto/.opencode/commands/` | Comandos extras **só daquele projeto** |
| `meu-projeto/AGENTS.md` | Contexto da codebase (gerado por `/init`) |

---

## 🏗️ Estrutura do Repositório

```
├── rules/              # Regras operacionais do OpenCode
├── commands/           # Comandos personalizados do OpenCode
├── skills/             # Skills especializadas
├── tools/              # Ferramentas customizadas
├── .cursor/            # Configurações do Cursor
│   ├── rules/          # Regras de review
│   ├── skills/         # Skills especializadas
│   └── mcp.json        # Configurações MCP (Jira, GitLab)
│
├── specs/              # Technical Design Documents (TDDs)
├── docs/               # 📚 Documentação completa
│
└── AGENTS.md           # Guia para agentes de IA
```

---

## 📖 Documentação

| Guia | Descrição |
|------|-----------|
| **[OpenCode Config](docs/opencode-config.md)** | Regras, comandos, fluxo de trabalho, segurança, arquitetura, conventional commits |
| **[Cursor Config](docs/cursor-config.md)** | Skill de code review, regras, integrações MCP, troubleshooting |

---

## 📝 Licença

Este repositório está licenciado sob a [MIT License](LICENSE).
