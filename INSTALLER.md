# OpenCode Installer

Sistema de instalação curl-to-bash para distribuição das configurações OpenCode, com suporte a versionamento e auto-atualização.

## Como funciona

### Opção B (Configuração centralizada)
O arquivo `installer.config` define as pastas padrão. Edite-o para adicionar/remover pastas sem precisar regerar o instalador.

### Opção C (Override via variável de ambiente)
Usuários podem sobrescrever as pastas via variável `PASTAS`.

### Versionamento
O instalador rastreia versões via `opencode.version`, permitindo verificar e atualizar configurações sem reinstalação completa.

## Uso

### Instalação padrão (usa config do GitHub)
```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash
```

### Instalação customizada
```bash
PASTAS="commands docs" curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash
```

### Verificar versão instalada vs disponível
```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash -s -- --check
```

### Atualizar (apenas se versão mais recente disponível)
```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash -s -- --update
```

O modo `--update`:
1. Compara a versão local (`.opencode/opencode.version`) com a versão mais recente no GitHub
2. Se já está atualizado, encerra sem fazer nada
3. Se há atualização disponível, faz backup de `.opencode/` para `.opencode.bak/`
4. Baixa os arquivos atualizados
5. Grava a nova versão em `.opencode/opencode.version`

### Forçar reinstalação
```bash
curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash -s -- --force
```

### Comando /update dentro do OpenCode
Dentro de um projeto com OpenCode instalado, use o comando `/update` para verificar e atualizar as configurações sem sair do terminal.

## Comportamento de Backup

Ao atualizar (`--update`), o instalador salva o diretório `.opencode/` existente como `.opencode.bak/` antes de sobrescrever. Se a atualização falhar, restaure manualmente:

```bash
rm -rf .opencode
mv .opencode.bak .opencode
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

### Atualizar Versão

Ao fazer uma nova release:

1. Atualize `package.json` com a nova versão
2. Atualize `opencode.version` com a mesma versão
3. Execute `./generate-installer.sh` para regerar o instalador com a versão embedded
4. Commit, tag e push

### Estrutura

- `installer.config` - Configuração das pastas padrão e URLs
- `generate-installer.sh` - Script gerador
- `dist/install-opencode.sh` - Instalador final (gerado, com versão embedded)
- `opencode.version` - Arquivo de versão distribuído com o instalador
- `.opencode/commands/update.md` - Comando `/update` do OpenCode
- `.github/workflows/generate-installer.yml` - Workflow do GitHub Actions

## Configuração

Edite `installer.config`:

```bash
# Pastas padrão (espaço separado)
DEFAULT_FOLDERS="commands rules skills docs .cursor"

# Arquivo de versão
VERSION_FILE="opencode.version"

# Informações do repositório
GITHUB_USER="rodrigocnascimento"
GITHUB_REPO="bot-configs"
GITHUB_BRANCH="main"

# APIs
RELEASES_API_URL="https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/releases"
```

As mudanças no `DEFAULT_FOLDERS` são automaticamente aplicadas — não precisa regerar o instalador!