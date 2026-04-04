# Backend Security Review Mode (AppSec)

Quando o usuário solicitar **code review**, **review de MR/PR** ou **análise de diff**, o agente deve também executar uma **análise de segurança de backend**.

Este modo busca identificar vulnerabilidades comuns em aplicações:

* Node.js
* TypeScript
* Express
* TypeORM
* MySQL

Inspirado em práticas OWASP.

---

# Objetivo

Detectar riscos de segurança antes que cheguem à produção.

Durante o review o agente deve procurar:

* injeções
* falhas de autenticação
* exposição de dados sensíveis
* validação insuficiente de input
* uso inseguro de bibliotecas

---

# Categorias de vulnerabilidade

---

# 1️⃣ Injection (SQL / Command)

Detectar qualquer construção dinâmica de query.

❌ Errado

```ts
await repository.query(
  `SELECT * FROM users WHERE email = '${email}'`
)
```

Risco:

SQL Injection.

✔ Correto

```ts
await repository.query(
  "SELECT * FROM users WHERE email = ?",
  [email]
)
```

---

# 2️⃣ Mass Assignment

Quando objetos de request são persistidos diretamente.

❌ Errado

```ts
await userRepository.save(req.body)
```

Problema:

Um atacante pode enviar campos extras:

```
{
  "email": "user@mail.com",
  "isAdmin": true
}
```

✔ Correto

Usar DTO explícito.

```ts
const dto: CreateUserDTO = {
  email: req.body.email,
  password: req.body.password
}
```

---

# 3️⃣ Falta de validação de input

Verificar ausência de validação em:

* body
* query
* params

❌ Errado

```ts
app.post("/users", async (req, res) => {
  await service.create(req.body)
})
```

✔ Correto

Usar schema validation:

* Zod
* Joi
* class-validator

---

# 4️⃣ Exposição de dados sensíveis

Detectar logs contendo:

* senhas
* tokens
* headers de autenticação

❌ Errado

```ts
logger.info("login attempt", req.body)
```

✔ Correto

```ts
logger.info("login attempt", { email: req.body.email })
```

---

# 5️⃣ Secrets no código

Detectar valores hardcoded:

* API keys
* tokens
* credenciais

❌ Errado

```ts
const apiKey = "sk_live_123"
```

✔ Correto

```ts
process.env.API_KEY
```

---

# 6️⃣ Broken Authentication

Verificar se endpoints sensíveis:

* exigem autenticação
* verificam autorização

Problemas comuns:

* endpoints administrativos públicos
* middleware de auth ausente
* verificação apenas no frontend

---

# 7️⃣ SSRF (Server-Side Request Forgery)

Detectar chamadas HTTP com URL controlada pelo usuário.

❌ Errado

```ts
await axios.get(req.query.url)
```

Risco:

O servidor pode acessar recursos internos.

✔ Correto

Validar whitelist de domínios.

---

# 8️⃣ Falta de rate limiting

Endpoints críticos devem ter proteção contra abuso.

Exemplos:

* login
* reset de senha
* criação de conta

Soluções comuns:

* express-rate-limit
* gateway rate limit

---

# 9️⃣ Upload inseguro de arquivos

Verificar:

* tipo de arquivo
* tamanho máximo
* diretório seguro

Problemas comuns:

* upload de executáveis
* path traversal

---

# 🔟 Falta de sanitização de dados

Especialmente em campos que podem ser renderizados depois.
