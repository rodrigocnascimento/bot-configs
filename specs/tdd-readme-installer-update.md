# TDD: Update README to Reflect Installer-Based Workflow

## Objective & Scope

- **What:** Atualizar o README.md para refletir as três formas de instalação disponíveis (curl-to-bash, git clone global, `/update` command), remover a sugestão de `git clone` como único método, e documentar versionamento e flags do instalador.
- **Why:** O README atual sugere apenas `git clone` em `~/.config/opencode/`, mas agora o projeto tem um instalador curl-to-bash com versionamento, `--update`, `--check`, `--force`, e um comando `/update` dentro do OpenCode.
- **File Target:** `specs/tdd-readme-installer-update.md`

## Proposed Technical Strategy

### Changes to README.md

1. **Seção "Como usar"** — Substituir o fluxo atual por três métodos:
   - **Método 1 (Recomendado): Instalador curl-to-bash** — instala em qualquer projeto, com versionamento e auto-atualização
   - **Método 2: Git clone global** — ainda válido para config global em `~/.config/opencode/`
   - **Método 3: Comando `/update`** — atualizar de dentro do OpenCode

2. **Nova seção "Atualizar"** — Documentar `--update`, `--check`, `--force` e o mecanismo de backup

3. **Nova seção "Versionamento"** — Explicar `opencode.version` e como funciona a comparação de versões

4. **Seção "Estrutura"** — Adicionar `opencode.version`, `dist/`, `INSTALLER.md`

5. **Referência ao INSTALLER.md** — Link para documentação detalhada

### Impacted Files

| File | Action |
|------|--------|
| `README.md` | Editar — reescrever seção "Como usar", adicionar seções |
| `specs/tdd-readme-installer-update.md` | Criar — este TDD |

### Language-Specific Guardrails

- **Markdown:** Manter formatação consistente com o estilo existente (emoji headings, tabelas, code blocks)
- **Idioma:** O README atual está em pt-BR — manter no mesmo idioma

## Implementation Plan

### Seção "Como usar" — 3 métodos

```markdown
## Instalação em um Projeto (Recomendado)
curl -fsSL https://raw.githubusercontent.com/.../install-opencode.sh | bash

## Configuração Global (OpenCode)
git clone ... ~/.config/opencode

## Atualizar
curl ... | bash -s -- --update
/opencode update
```

### Seção "Atualizar"

Documentar flags: `--update`, `--check`, `--force`, backup em `.opencode.bak/`

### Seção "Versionamento"

Explicar `opencode.version`, comparação semver, fallback para GitHub Releases API / package.json / Raw

### Seção "Estrutura"

Adicionar `opencode.version`, `dist/`, `INSTALLER.md`