---
description: Iniciar Technical Design Phase (TDP)
agent: plan
---

Siga o protocolo TDP (Mandatory Technical Design Phase):

## 1. Identificar Stable Base
Determine qual é a branch estável (stable > main > master) usando:
```
git fetch --all --prune
git branch
```

## 2. Exigir Issue ID e Criar Branch de Trabalho (HARD GATE)

Antes de qualquer trabalho, você DEVE obter um Issue ID do Developer e criar a branch de trabalho.

### 2.1 Solicitar Issue ID
Pergunte ao Developer:
"Qual é o Issue ID para esta tarefa? (ex: GH-123, PROJ-42, ISSUE-7)"

Se o Developer não fornecer um Issue ID, PARE e informe:
"Issue ID é obrigatório para criar a branch de trabalho. O trabalho não pode prosseguir sem ele."

### 2.2 Criar a Branch
Com o Issue ID e o tipo de tarefa, crie a branch no formato:
`<type>/<issueId>-<slug>`

Onde `<type>` é um de:
- `feat/` para novas funcionalidades
- `fix/` para correções de bugs
- `hotfix/` para correções emergenciais
- `chore/` para manutenção
- `refactor/` para refatoração

E `<slug>` é kebab-case descritivo, ex: `user-authentication`.

Execute:
```
git checkout <stable-branch>
git pull --ff-only
git checkout -b <type>/<issueId>-<slug>
```

### 2.3 Hard Gate
Se a branch NÃO foi criada com sucesso, PARE imediatamente.
O trabalho NÃO pode ser iniciado sem uma branch de trabalho válida.
Não crie o TDD, não gere código, não prossiga sem a branch.

## 3. Regras do Protocolo (do AGENTS.md)
- Não gere código antes de criar o TDD
- Crie o documento em `specs/tdd-<feature-slug>.md`
- Inclua: Objective & Scope, Proposed Technical Strategy, Implementation Plan

## 4. Output Obrigatório
Após criar o TDD, você deve PARAR e perguntar:
"Do you approve this technical approach, Developer?"

Aguarde aprovação explícita antes de qualquer implementação.

## Tarefa Solicitada
$ARGUMENTS