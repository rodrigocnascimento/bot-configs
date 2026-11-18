---
description: Revisa código backend para qualidade, segurança e arquitetura em múltiplas linguagens
agent: code-reviewer
model: opencode/big-pickle
subagent: true
---

Carregue a skill `backend-code-review` e execute o workflow completo de revisão poliglota e sensível à arquitetura.

Aplique todas as regras definidas em (busque em `.opencode/rules/`, `~/.config/opencode/rules/` ou `rules/`):

- `rules/backend-anti-patterns.md`
- `rules/backend-security-review.md`
- `rules/staff-engineer-review.md`
- `skills/backend-code-review/references/review-rules.md`
- `skills/backend-code-review/references/language-checklists.md`

Use os templates de comentário definidos em:

- `skills/backend-code-review/references/comment-templates.md`

Forneça feedback construtivo com sugestões de código na linguagem sob revisão, sem fazer alterações diretas.

## Tarefa Solicitada

$ARGUMENTS