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

### Método 1: Instalação em um Projeto (Recomendado)

Use o instalador curl-to-bash para adicionar configurações OpenCode a qualquer projeto:

```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash
```

Isso cria uma pasta `.opencode/` no diretório atual com regras, comandos e skills.

Pasta customizada:

```bash
PASTAS="commands rules" curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash
```

Forçar reinstalação:

```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash -s -- --force
```

> **Detalhes completos:** consulte [INSTALLER.md](INSTALLER.md) para documentação do instalador.

### Método 2: Configuração Global (OpenCode)

Clone este repositório em `~/.config/opencode/` para usar como config global:

```bash
git clone git@github.com:rodrigocnascimento/bot-configs.git ~/.config/opencode
```

Isso faz com que todas as regras, comandos e tools definidos aqui sejam carregados automaticamente em **todos os projetos** que você usar com OpenCode.

### Método 3: Atualizar via Comando `/update`

Dentro de um projeto com OpenCode instalado, use o comando `/update` para verificar e atualizar as configurações sem sair do terminal.

---

## 🔄 Atualizar

### Verificar versão instalada

```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash -s -- --check
```

### Atualizar (apenas se versão mais recente disponível)

```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash -s -- --update
```

Antes de atualizar, o instalador salva um backup em `.opencode.bak/`. Se algo der errado:

```bash
rm -rf .opencode
mv .opencode.bak .opencode
```

### Flags do Instalador

| Flag | Descrição |
|------|-----------|
| `--update` | Atualiza apenas se versão mais recente disponível |
| `--check` | Compara versão local vs GitHub sem baixar |
| `--force` | Força reinstalação sem confirmação |

---

## 📦 Versionamento

A versão das configurações é rastreada pelo arquivo `.opencode/opencode.version`. O instalador:

1. Compara a versão local com a versão mais recente do GitHub (via Releases API)
2. Faz fallback para `package.json` e `opencode.version` no repositório
3. Usa comparação semver (major.minor.patch)

Para verificar a versão instalada:

```bash
cat .opencode/opencode.version
```

---

## 🔧 Configuração por Projeto

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
- Configs do projeto (`.opencode/`) → adiciona ou sobrescreve
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
├── .opencode/                  # Configurações do OpenCode
│   ├── rules/                  # Regras operacionais (anti-patterns, security, staff-engineer)
│   ├── commands/               # Comandos personalizados (tdp, release, update, code-review)
│   ├── skills/                  # Skills especializadas (backend-code-review)
│   └── agents/                  # Agents adicionais
├── .cursor/                    # Configurações do Cursor
│   ├── rules/                   # Regras de review
│   ├── skills/                  # Skills especializadas
│   └── mcp.json                 # Configurações MCP (Jira, GitLab)
├── commands/                   # Comandos OpenCode (fonte, compilados em AGENTS.md)
├── rules/                       # Regras OpenCode (fonte, compiladas em AGENTS.md)
├── skills/                      # Skills OpenCode (fonte, compiladas em AGENTS.md)
├── dist/                        # Instalador gerado
│   └── install-opencode.sh     # Curl-to-bash installer
├── specs/                       # Technical Design Documents (TDDs)
├── docs/                        # 📚 Documentação completa
│
├── opencode.version             # Versão atual das configurações
├── installer.config             # Configuração do instalador (pastas, URLs)
├── generate-installer.sh       # Script gerador do instalador
├── INSTALLER.md                 # 📖 Documentação do instalador
└── AGENTS.md                    # Guia compilado para agentes de IA
```

---

## 📖 Documentação

| Guia | Descrição |
|------|-----------|
| **[OpenCode Config](docs/opencode-config.md)** | Regras, comandos, fluxo de trabalho, segurança, arquitetura, conventional commits |
| **[Cursor Config](docs/cursor-config.md)** | Skill de code review, regras, integrações MCP, troubleshooting |
| **[Instalador](INSTALLER.md)** | Documentação completa do instalador, flags, versionamento, backup |

---

## 📝 Licença

Este repositório está licenciado sob a [MIT License](LICENSE).