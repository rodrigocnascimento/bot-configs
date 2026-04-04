---

name: backend-code-review
description: Realiza code review de Merge Requests de backend Node.js/TypeScript aplicando regras de arquitetura Clean Architecture, segurança, persistência TypeORM, qualidade de código e cobertura de testes.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Backend Code Review

Guia de revisão para projetos backend usando:

* Node.js
* TypeScript
* Express
* TypeORM
* MySQL
* Clean Architecture
* tsyringe
* Jest

Use os templates em `references/comment-templates.md` para formatar comentários.

---

# Workflow

Siga os passos **em ordem**.

---

# Passo 1 — Obter informações do MR

Se o usuário não fornecer o link do MR, solicite.

Usar preferencialmente **MCP GitLab** para ler dados do MR (detalhes, commits, diff) e o CLI oficial **`glab`** para postar comentários no GitLab (teste atual).

Buscar:

* título
* descrição
* autor
* branches
* diff completa
* comentários existentes

---

# Passo 2 — Identificar Issue Jira

Extrair ticket da branch ou descrição.

Exemplos:

```
feature/LABS-123
fix/LABS-456
```

Buscar via MCP Atlassian:

* título
* descrição
* critérios de aceite
* subtasks

Se não for possível acessar o Jira, continuar o review sem validação de requisitos.

---

# Passo 3 — Validar requisitos

Comparar critérios de aceite com a diff.

Gerar tabela:

| Requisito | Status |
| --------- | ------ |
| Req 1     | ✅      |
| Req 2     | ⚠️     |
| Req 3     | ❌      |

---

# Passo 4 — Revisar a diff

Aplicar regras do arquivo:

```
references/review-rules.md
```

Priorizar:

## 🔴 Críticos

* segurança
* consistência de dados
* bugs

## 🟡 Importantes

* arquitetura
* performance
* testes

## 🟢 Melhorias

* padrões
* nomenclatura
* organização

---

# Passo 5 — Montar preview

Gerar preview estruturado:

```
## Preview dos Comentários

### [ARQUIVO: src/controllers/user-controller.ts]

Linha 32 | 🔴 Bug

Descrição do problema.

Sugestão.

---

### [ARQUIVO: src/usecases/create-user.ts]

Linha 14 | 🟡 Qualidade

Descrição.

---

## Resumo

Críticos: N
Importantes: N
Sugestões: N
```

---

# Passo 6 — Confirmar

Antes de postar comentários perguntar:

```
Posso postar estes comentários no MR?
Deseja alterar ou remover algum?
```

---

# Passo 7 — Postar comentários

Após confirmação do usuário:

1. Obter `project_id` (ex.: `<user>/<repo>`) e `merge_request_iid` do MR (via MCP GitLab `get_merge_request` ou a partir da URL).
2. Para **cada comentário do preview**:
   - Extrair:
     - `file`: caminho em `[ARQUIVO: ...]`
     - `line`: número em `Linha N`
     - `comment`: texto formatado usando `references/comment-templates.md`
   - Montar a mensagem incluindo arquivo e linha na própria descrição, por exemplo:

     ```markdown
     [ARQUIVO: src/controllers/user-controller.ts] • Linha 32

     🔴 **Bug**: ...
     ```

   - Executar o CLI `glab` para criar uma nota no MR (teste atual):

     ```bash
     glab mr note <merge_request_iid> \
       --repo <project_id> \
       --message "<comment>"
     ```

3. Requisitos ausentes devem virar **comentário geral no MR** usando também `glab mr note` (sem referência a arquivo/linha, apenas com o texto de resumo de requisitos).


