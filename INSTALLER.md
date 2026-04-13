# OpenCode Installer

Sistema de instalação curl-to-bash para distribuição das configurações OpenCode.

## Como funciona

### Opção B (Configuração centralizada)
O arquivo `installer.config` define as pastas padrão. Edite-o para adicionar/remover pastas sem precisar regerar o instalador.

### Opção C (Override via variável de ambiente)
Usuários podem sobrescrever as pastas via variável `PASTAS`.

## Uso

### Instalação padrão (usa config do GitHub)
```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash
```

### Instalação customizada
```bash
PASTAS="commands docs" curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash
```

## Para Mantenedores

### Gerar Instalador via GitHub Actions (Recomendado)

Você pode gerar o instalador diretamente pelo GitHub, sem rodar nada local:

1. Acesse **Actions** → **Generate OpenCode Installer**
2. Clique em **Run workflow**
3. Opcionalmente, informe pastas customizadas no campo `folders`
4. Clique em **Run workflow**
5. O workflow vai:
   - Gerar o instalador
   - Commitar em `dist/install-opencode.sh`
   - Atualizar `installer.config` (se você informou pastas)
   - Mostrar a URL de distribuição no summary

### Gerar Localmente (Alternativo)

```bash
./generate-installer.sh
```

Isso cria/atualiza `dist/install-opencode.sh` localmente.

### Estrutura

- `installer.config` - Configuração das pastas padrão
- `generate-installer.sh` - Script gerador
- `dist/install-opencode.sh` - Instalador final (gerado)
- `.github/workflows/generate-installer.yml` - Workflow do GitHub Actions

## Configuração

Edite `installer.config`:

```bash
# Pastas padrão (espaço separado)
DEFAULT_FOLDERS="commands rules skills docs .cursor"

# Informações do repositório
GITHUB_USER="rodrigocnascimento"
GITHUB_REPO="bot-configs"
GITHUB_BRANCH="main"
```

As mudanças são automaticamente aplicadas - não precisa regerar o instalador!
