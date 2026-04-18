# TDD: Corrigir Estrutura de Diretório Global vs Local

## Objective & Scope

- **What:** Modificar o instalador para criar estrutura correta de diretórios e tornar `opencode.json` obrigatório
- **Why:**
  - Configuração global deve usar `opencode/` (sem ponto) em `~/.config/opencode/`
  - Configuração local deve usar `.opencode/` (com ponto) em projetos
  - `opencode.json` deve ser obrigatório em todas as instalações
- **File Target:** `specs/tdd-installer-directory-structure.md`

## Proposed Technical Strategy

### Detecção de Contexto Global

O instalador detecta o **diretório pai** onde será instalado:

```bash
# Se pai do TARGET_DIR é ~/.config → global
if [[ "$(dirname "$TARGET_DIR")" == "$HOME/.config" ]]; then
    INSTALL_DIR="$TARGET_DIR/opencode"    # sem ponto
else
    INSTALL_DIR="$TARGET_DIR/.opencode"   # com ponto
fi
```

| TARGET_DIR | INSTALL_DIR | Tipo |
|----------|-----------|----------|
| `~/.config/opencode` | `opencode/` | Global |
| `./projeto` | `.opencode/` | Local |

### Obrigatoriedade do opencode.json

Sempre criar `opencode.json` na raiz de `INSTALL_DIR`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "version": "1.0"
}
```

## Implementation Plan

1. Modificar `generate-installer.sh`:
   - Adicionar detecção de contexto global via `dirname`
   - Ajustar variável `INSTALL_DIR` baseada no contexto
   - Adicionar função para gerar `opencode.json`
   - Sempre executar geração do `opencode.json`

2. Regenerar `dist/install-opencode.sh`

3. Testar localmente

## Impacted Files

| File | Action |
|------|--------|
| `generate-installer.sh` | Editar |
| `dist/install-opencode.sh` | Regenerar |