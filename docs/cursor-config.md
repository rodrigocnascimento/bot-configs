# 🐄 Cursor

**Cursor** é um IDE com capacidades de IA para code review automatizado e pair programming.

## 🎯 O que a skill faz?

A skill **`backend-code-review`** realiza code review automatizado de aplicações **Node.js/TypeScript**, focando em:

- 🏛️ **Arquitetura:** Padrões de Clean Architecture
- 🔒 **Segurança e Persistência:** Boas práticas com TypeORM e MySQL
- 🧪 **Qualidade e Testes:** Cobertura com Jest, tsyringe/Express

## 📋 Como funciona

1. **Leitura do MR** — Conecta ao GitLab e lê o diff
2. **Contexto do Jira** — Identifica o ticket e lê critérios de aceite
3. **Validação de requisitos** — Cruza Jira com código entregue
4. **Revisão profunda** — Classifica apontamentos em:
   - 🔴 Críticos (segurança, bugs)
   - 🟡 Importantes (arquitetura, performance)
   - 🟢 Melhorias (boas práticas, nomenclatura)
5. **Preview** — Mostra sugestões antes de postar
6. **Confirmação** — Você aprova, edita ou remove comentários
7. **Postagem automática** — Posta no MR via `glab`

## 🛠️ Pré-requisitos

### Instalar o `glab`

```bash
brew install glab  # macOS
# Outros sistemas: ver docs do GitLab CLI
```

### Autenticar

```bash
glab auth login
```

Escolha o host do GitLab e autentique via navegador ou Personal Access Token (escopo `api`).

## 🚀 Como usar

No chat do Cursor:

```
/backend-code-review revise o MR: https://gitlab.com/projeto/-/merge_requests/123
```

## 📁 Estrutura

```
.cursor/
├── rules/              # Regras de review
│   ├── backend-review-mode.md
│   ├── backend-security-review.md
│   ├── backend-anti-patterns.md
│   └── staff-engineer-review.md
├── skills/
│   └── backend-code-review/
│       └── references/
│           └── review-rules.md
└── mcp.json            # Configurações MCP (Jira, GitLab)
```

## 🔗 Integrações MCP

| Serviço | Descrição |
|---------|-----------|
| **Atlassian (Jira)** | Ler tickets e critérios de aceite |
| **GitLab** | Acessar MRs e postar comentários |

Configuração em `.cursor/mcp.json`.

## 🚑 Troubleshooting

| Problema | Solução |
|----------|---------|
| `401 Unauthorized` | Token expirado — rode `glab auth login` novamente |
| `command not found: glab` | Instale o `glab` e reinicie o Cursor |
| Pula etapa do Jira | Verifique se o servidor MCP do Atlassian está rodando |

## 💡 Dicas

- **Juniores:** Use como ferramenta de aprendizado dos padrões da empresa
- **Plenos/Seniores:** Use pra poupar tempo — deixe a IA caçar bugs e furos nos critérios
