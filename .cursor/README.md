# 🤖 Cursor Skill: Backend Code Review

Olá, time! 👋

Este documento explica como funciona a skill **`backend-code-review`** configurada no nosso ambiente do Cursor. Ela atua como um "parceiro de pair programming" focado em revisar seus Merge Requests (MRs) de backend.

O objetivo desta ferramenta **não** é substituir a revisão humana, mas sim adiantar o trabalho braçal, apontar possíveis esquecimentos e garantir que o básico (e às vezes o avançado!) esteja bem coberto antes mesmo de outro engenheiro olhar o seu código.

---

## 🎯 O que essa skill faz?

Ela realiza um code review automatizado de aplicações **Node.js/TypeScript** do nosso ecossistema.
Durante a análise, a IA foca em garantir:

- 🏛️ **Arquitetura:** Padrões de Clean Architecture.
- 🔒 **Segurança e Persistência:** Boas práticas com TypeORM e banco de dados MySQL.
- 🧪 **Qualidade e Testes:** Cobertura de testes com Jest, nomenclatura e injeção de dependências (tsyringe/Express).

---

## ⚙️ Como funciona o passo a passo?

A skill segue um fluxo de trabalho (workflow) padronizado e transparente. Veja o que acontece nos bastidores quando você pede para ela revisar um MR:

### 1. Leitura do Merge Request (GitLab)
A skill usa integrações locais para se conectar ao nosso GitLab. Ela lê o título, a descrição, as branches envolvidas, as conversas já existentes e, claro, o código que foi alterado (diff).

### 2. Entendimento do Contexto (Jira)
Ela identifica automaticamente qual é o ticket do Jira (ex: `LABS-123`) a partir do nome da branch ou descrição do MR. Em seguida, ela consulta o Jira para ler a descrição da tarefa e os **Critérios de Aceite**.

### 3. Validação de Requisitos
Antes de olhar o código em si, ela cruza o que foi pedido no Jira com o que foi entregue no código e gera uma tabela de status bem visual para você:
- ✅ Requisito atendido.
- ⚠️ Requisito parcialmente atendido ou com dúvidas.
- ❌ Requisito não encontrado no código.

### 4. Revisão Profunda do Código
Aqui é onde a mágica acontece. A IA analisa linha por linha da sua diff e classifica os apontamentos em três níveis de prioridade:

- 🔴 **Críticos:** Falhas de segurança, problemas que podem corromper dados ou bugs evidentes. *(Atenção máxima aqui!)*
- 🟡 **Importantes:** Sugestões de melhoria na arquitetura, performance do código ou testes faltantes.
- 🟢 **Melhorias:** Dicas de boas práticas, padronização de nomenclatura e organização de pastas.

### 5. Preview (Você no Controle!)
A IA **nunca** fará nada sem a sua permissão. Ela primeiro gera um "Preview" estruturado na tela do Cursor, mostrando exatamente o arquivo, a linha e o comentário que ela sugere fazer.

### 6. Confirmação
Ela vai te perguntar: *"Posso postar estes comentários no MR? Deseja alterar ou remover algum?"*.
Você pode editar, apagar os comentários que não concordar ou simplesmente aprovar tudo.

### 7. Postagem Automática
Com o seu "ok", a skill assume o trabalho chato: ela se comunica com o GitLab (via CLI do `glab`) e posta todos os comentários aprovados diretamente nas linhas exatas do seu Merge Request, além de adicionar um comentário geral caso falte algum requisito do Jira.

---

## 🛠️ Configuração Inicial (Pré-requisitos)

Para que a skill consiga ler o seu MR e postar os comentários magicamente, ela precisa da **ferramenta de linha de comando do GitLab (`glab`)** instalada e autenticada na sua máquina.

**1. Instalar o `glab`**
Se você usa macOS (com Homebrew):
```bash
brew install glab
```
*(Para outros sistemas, confira a documentação oficial do GitLab CLI)*

**2. Autenticar sua conta**
No seu terminal, rode o comando abaixo e siga os passos interativos:
```bash
glab auth login
```
- Escolha o endereço do nosso GitLab (`gitlab.com.br` ou host interno).
- Você pode usar a autenticação pelo navegador (Web) ou colar um *Personal Access Token* gerado no seu perfil do GitLab.

Pronto! A partir de agora, o Cursor usará as suas credenciais locais para interagir com os Merge Requests de forma segura.

---

## �🚀 Como utilizar?

No chat do Cursor, basta mencionar a skill e passar o link do seu Merge Request.

**Exemplo de prompt:**
> "/backend-code-review revise o MR: https://gitlab.com/seu-projeto/-/merge_requests/123"

---

## 🚑 Resolução de Problemas (Troubleshooting)

Caso a skill não consiga ler o MR ou postar os comentários, aqui estão os problemas mais comuns e como resolvê-los:

**1. O Token (PAT) expirou ou perdeu permissão**
- **Sintoma:** A IA avisa que não conseguiu acessar o GitLab ou que não tem permissão (`401 Unauthorized`).
- **Solução:** O seu Personal Access Token pode ter expirado. Vá até o GitLab, gere um novo token (lembre-se de marcar o escopo `api`), abra o terminal e rode `glab auth login` novamente para atualizar a credencial na sua máquina.

**2. O comando `glab` não foi encontrado**
- **Sintoma:** A IA informa que não consegue executar o comando ou retorna `command not found: glab`.
- **Solução:** Certifique-se de que o CLI foi instalado corretamente. Se você acabou de instalar, reinicie o Cursor completamente para que ele recarregue as suas variáveis de ambiente (PATH).

**3. A IA pula a etapa de leitura do Jira**
- **Sintoma:** A tabela de requisitos não é gerada.
- **Solução:** A skill utiliza a integração MCP do Atlassian. Verifique nas configurações do seu Cursor se o servidor MCP do Jira está rodando sem erros e autenticado.

---

## 💡 Dicas para o Time

- **Para os Juniores:** Usem essa skill como uma ferramenta de aprendizado contínuo. Ela vai te ajudar a entender os padrões da empresa antes da revisão de um Sênior.
- **Para os Plenos e Seniores:** Usem para poupar tempo. Deixem a IA caçar variáveis não utilizadas, falta de tratamento de erros no TypeORM e furos nos critérios de aceite, enquanto vocês focam na regra de negócio e no design do sistema.

Em caso de dúvidas ou sugestões de novas regras de review, sinta-se à vontade para propor melhorias no arquivo `references/review-rules.md`!
