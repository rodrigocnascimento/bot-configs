Aqui está o conteúdo formatado em **Markdown puro**, pronto pra colar em README, docs internas ou wiki:

---

````markdown
# 🐧 Setup Profissional – GitHub + GitLab CLI (Linux)

Este guia cobre a configuração no Linux para:

- GitHub CLI (`gh`)
- GitLab CLI (`glab`)

Incluindo SSH, múltiplas contas e produtividade.

---

# 🔧 1. Instalação

## Ubuntu / Debian

```bash
# GitHub CLI
sudo apt update
sudo apt install gh

# GitLab CLI
curl -s https://raw.githubusercontent.com/profclems/glab/trunk/scripts/install.sh | sudo bash
````

## Arch Linux

```bash
sudo pacman -S github-cli glab
```

## Fedora

```bash
sudo dnf install gh
sudo dnf install glab
```

---

# 🔐 2. Configuração de SSH (OBRIGATÓRIO)

## Gerar chave

```bash
ssh-keygen -t ed25519 -C "seu-email@exemplo.com"
```

## Iniciar agente SSH

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## Copiar chave pública

```bash
cat ~/.ssh/id_ed25519.pub
```

Adicione a chave em:

* GitHub → Settings → SSH Keys
* GitLab → Preferences → SSH Keys

---

# 🧠 3. Múltiplas contas

Editar:

```bash
nvim ~/.ssh/config
```

Exemplo:

```bash
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519

Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_work

Host gitlab-work
  HostName gitlab.seudominio.com
  User git
  IdentityFile ~/.ssh/id_ed25519_gitlab
```

Uso:

```bash
git clone git@github-work:empresa/repo.git
git clone git@gitlab-work:grupo/repo.git
```

---

# 🔑 4. Autenticação

## GitHub

```bash
gh auth login
```

* Escolha SSH
* Login via browser

## GitLab

```bash
glab auth login
```

Self-hosted:

```bash
glab auth login --hostname gitlab.seudominio.com
```

Token com permissões:

* api
* read_repository
* write_repository

---

# ⚙️ 5. Git config

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

Por projeto:

```bash
git config user.name "Nome Trabalho"
git config user.email "email@empresa.com"
```

---

# ⚡ 6. Aliases

Adicionar ao `.bashrc` ou `.zshrc`:

```bash
alias gs="git status"
alias gp="git push"
alias gl="git pull"
alias gc="git commit -m"
alias gco="git checkout"

alias pr="gh pr create"
alias mr="glab mr create"
```

Recarregar:

```bash
source ~/.bashrc
```

---

# 🧪 7. Testes

```bash
gh repo list
glab repo list
```

SSH:

```bash
ssh -T git@github.com
ssh -T git@gitlab.com
```

---

# 🧩 8. Extras

## LazyGit

```bash
sudo apt install lazygit
```

## Auto start do SSH agent

Adicionar ao `.bashrc`:

```bash
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  eval "$(ssh-agent -s)"
fi
```

## Git hook (proteger main)

```bash
nvim .git/hooks/pre-commit
```

```bash
branch=$(git branch --show-current)
if [ "$branch" = "main" ]; then
  echo "❌ Não commite direto na main"
  exit 1
fi
```

---

# 🧠 Boas práticas

* Use SSH sempre
* Separe contas (pessoal vs trabalho)
* Automatize tarefas repetitivas
* Use CLI (`gh`, `glab`) para PR/MR
* Integre com seu editor (nvim, etc)

---

# ✅ Resultado

* Setup Linux sólido
* Multi-conta funcional
* Fluxo otimizado via CLI
* Pronto para escalar

```
