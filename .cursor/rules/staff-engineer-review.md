# Staff Engineer Review Mode

Quando o usuário solicitar **code review**, **review de PR/MR**, ou **análise de diff**, o agente deve também executar uma **revisão de nível Staff Engineer**.

Este modo avalia não apenas qualidade de código, mas também **design, arquitetura, escalabilidade e riscos operacionais**.

Projetos alvo:

* Node.js
* TypeScript
* Express
* TypeORM
* MySQL
* Clean Architecture
* tsyringe
* Jest

---

# Objetivo

Garantir que o código:

* seja **correto**
* seja **manutenível**
* **escale em produção**
* seja **seguro**
* respeite **limites arquiteturais**

---

# Dimensões de análise

Durante o review, avaliar as seguintes dimensões.

---

# 1️⃣ Arquitetura

Verificar se o código respeita as camadas do sistema.

Arquitetura esperada:

```
controller → usecase/service → repository → database
```

Problemas arquiteturais incluem:

* controller acessando repository
* domínio dependendo de ORM
* serviços com múltiplas responsabilidades
* dependências circulares
* lógica de negócio em controllers

Pergunta fundamental:

> Esta implementação mantém a separação clara entre camadas?

---

# 2️⃣ Design de domínio

Avaliar se as regras de negócio estão corretamente modeladas.

Verificar:

* regras de negócio espalhadas
* lógica duplicada
* entidades anêmicas
* invariantes não protegidas

Pergunta fundamental:

> A regra de negócio está no lugar correto?

---

# 3️⃣ Escalabilidade

Avaliar impacto da implementação em produção.

Verificar:

* N+1 queries
* queries sem índice
* consultas carregando dados desnecessários
* processamento síncrono pesado
* loops async sequenciais

Pergunta fundamental:

> Este código funcionará bem com 10x mais dados?

---

# 4️⃣ Confiabilidade

Avaliar resiliência do sistema.

Verificar:

* tratamento de erros
* retry em chamadas externas
* timeouts ausentes
* inconsistência de dados
* ausência de transações

Pergunta fundamental:

> O que acontece se algo falhar aqui?

---

# 5️⃣ Observabilidade

Avaliar se o sistema é operável em produção.

Verificar:

* logs estruturados
* ausência de logs em fluxos críticos
* mensagens de erro genéricas
* dificuldade de diagnóstico

Pergunta fundamental:

> Conseguiremos debugar isso em produção?

---

# 6️⃣ Testabilidade

Verificar facilidade de testar o código.

Problemas comuns:

* dependências concretas
* lógica em controllers
* ausência de interfaces
* falta de mocks

Pergunta fundamental:

> Conseguimos testar este módulo isoladamente?

---

# Classificação dos achados

Durante o review, classificar achados em três categorias:

| Severidade    | Critério                               |
| ------------- | -------------------------------------- |
| 🔴 Crítico    | risco de bug, falha ou vulnerabilidade |
| 🟡 Importante | impacto em arquitetura ou manutenção   |
| 💡 Sugestão   | melhoria estrutural                    |

---

# Heurísticas avançadas

Sempre procurar:

### Acoplamento excessivo

Exemplo:

```
service dependendo de múltiplos repositories
```

---

### Baixa coesão

Exemplo:

```
função executando múltiplas responsabilidades
```

---

### Violação de boundaries

Exemplo:

```
infra acessando regras de domínio
```

---

### Complexidade desnecessária

Exemplo:

```
uso de abstrações sem necessidade
```

---

# Perguntas que devem guiar o review

Durante a revisão, o agente deve mentalmente avaliar:

1. Esta implementação é a **mais simples possível**?
2. O código será **fácil de manter daqui a 1 ano**?
3. Existem **edge cases não tratados**?
4. O código **escala com mais dados ou tráfego**?
5. A arquitetura continua **coerente** após essa mudança?

---

# Resultado esperado

Além dos comentários inline, gerar também um **comentário geral de arquitetura** quando necessário.

Exemplo:

```
Arquitetura: esta mudança introduz acoplamento entre controller e repository.
Considere mover a lógica para um use case para preservar os limites da arquitetura.
```

---

# Integração com outras regras

Este modo deve operar junto com:

```
.cursor/rules/backend-review-mode.md
.cursor/rules/backend-anti-patterns.md
```

E usar os templates de comentário definidos em:

```
.cursor/skills/backend-code-review/references/comment-templates.md
```
