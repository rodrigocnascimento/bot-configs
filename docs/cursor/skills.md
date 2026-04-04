# Cursor - Skills

## backend-code-review

Skill especializada em revisar código backend Node.js/TypeScript. Atua como "parceiro de pair programming" para revisar Merge Requests.

---

## Como Funciona

### 1. Leitura do Merge Request
A skill conecta ao GitLab via `glab` CLI e lê:
- Título e descrição do MR
- Branches envolvidas
- Conversas existentes
- Diff do código alterado

### 2. Entendimento do Contexto (Jira)
Identifica o ticket Jira (ex: `LABS-123`) e consulta:
- Descrição da task
- Critérios de Aceite
- Status e prioridade

### 3. Validação de Requisitos
Cruza o que foi pedido no Jira com o código implementado:

| Status | Significado |
|--------|-------------|
| ✅ | Requisito atendido |
| ⚠️ | Parcialmente atendido ou com dúvidas |
| ❌ | Requisito não encontrado |

### 4. Revisão Profunda do Código
Analisa a diff e classifica achados:

| Severidade | Significado |
|------------|-------------|
| 🔴 Crítico | Segurança, dados, bugs |
| 🟡 Importante | Arquitetura, performance |
| 💡 Sugestão | Boas práticas |

### 5. Preview
Gera preview estruturado mostrando:
- Arquivo e linha
- Comentário sugerido
- Severidade

### 6. Confirmação
```
Posso postar estes comentários no MR?
Deseja alterar ou remover algum?
```

### 7. Postagem Automática
Com aprovação, posta comentários via `glab`.

---

## Uso

### Prompt
```
/backend-code-review revise o MR: https://gitlab.com.br/projeto/-/merge_requests/123
```

### Exemplos de Prompts

```markdown
/backend-code-review revise o MR: [LINK DO MR]
```

```markdown
revise o MR https://gitlab.com.br/api/-/merge_requests/456
foco em segurança e performance
```

---

## Pré-requisitos

### GitLab CLI (glab)

**Instalação (macOS):**
```bash
brew install glab
```

**Autenticação:**
```bash
glab auth login
```

Escolhas:
- Host: `gitlab.com.br`
- Autenticação: Navegador (Web) ou PAT

**Verificar autenticação:**
```bash
glab auth status
```

### MCP do Jira

O Cursor deve ter MCP do Atlassian configurado:
```json
// .cursor/mcp.json
{
  "mcpServers": {
    "Atlassian": {
      "command": "npx",
      "args": ["mcp-remote", "https://mcp.atlassian.com/v1/mcp"]
    }
  }
}
```

---

## O que é Revisado

### ✅ Validação de Requisitos
- Cada critério de aceite do Jira
- Funcionalidade descrita
- Comportamento esperado

### ✅ Código e Arquitetura
- Respeito à Clean Architecture
- Separação de camadas
- Acoplamento

### ✅ Segurança
- SQL Injection
- Mass Assignment
- Input Validation
- Secrets hardcoded

### ✅ Performance
- N+1 Queries
- Filtros em memória
- Falta de paginação

### ✅ Testes
- Cobertura de use cases
- Testes unitários
- Mocks adequados

---

## Troubleshooting

### Erro: Token expirado
```
Sintoma: 401 Unauthorized
Solução: glab auth login novamente
```

### Erro: glab não encontrado
```
Sintoma: command not found: glab
Solução: Reiniciar Cursor após instalar
```

### Jira não é lido
```
Sintoma: Tabela de requisitos vazia
Solução: Verificar conexão MCP do Atlassian
```

---

## Referências

- [Comment Templates](../cursor/referencias/comment-templates.md)
- [Review Rules](../cursor/referencias/review-rules.md)
