---
description: Revisa código para qualidade e melhores práticas
agent: code-reviewer
model: opencode/big-pickle
subagent: true
---

Carregue a skill `backend-code-review` e execute o workflow completo de revisão.

Aplique todas as regras definidas em (busque em `.opencode/rules/`, `~/.config/opencode/rules/` ou `rules/`):

- `rules/backend-anti-patterns.md`
- `rules/backend-security-review.md`
- `rules/staff-engineer-review.md`
- `skills/backend-code-review/references/review-rules.md`

Use os templates de comentário definidos em:

- `skills/backend-code-review/references/comment-templates.md`

Forneça feedback construtivo sem fazer alterações diretas.

## Tarefa Solicitada

$ARGUMENTS