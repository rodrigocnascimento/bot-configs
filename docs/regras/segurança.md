# Segurança - Vulnerabilidades Críticas

## Visão Geral

Regras de segurança que **bloqueiam merge** se violadas. Inspirado em OWASP.

---

## 1. SQL Injection

### O que é
Construção de queries SQL dinâmicas permitindo ataque.

### Como Detectar

```typescript
// ❌ Vulnerável - template string
await repo.query(`SELECT * FROM users WHERE email = '${email}'`);

// ❌ Vulnerável - concatenação
await repo.query('SELECT * FROM users WHERE id = ' + userId);

// ❌ Vulnerável - string.format
await repo.query('SELECT * FROM users WHERE name = "%s"' % name);
```

### Como Corrigir

```typescript
// ✅ Parameterized query
await repo.query(
  'SELECT * FROM users WHERE email = ?',
  [email]
);

// ✅ TypeORM QueryBuilder
await repo.createQueryBuilder('user')
  .where('user.email = :email', { email })
  .getOne();
```

### Impacto
- Exposição de dados
- Autenticação bypass
- Dados corrompidos/deletados

---

## 2. Mass Assignment

### O que é
Salvar campos não esperados de `req.body` diretamente.

### Como Detectar

```typescript
// ❌ Vulnerável
await userRepository.save(req.body);

// ❌ Vulnerável
const user = new User();
Object.assign(user, req.body);
```

### Como Corrigir

```typescript
// ✅ DTO explícito
const dto: CreateUserDTO = {
  name: req.body.name,
  email: req.body.email,
  password: req.body.password,
};
await userRepository.save(dto);

// ✅ Mapeamento manual
const user = new User();
user.name = req.body.name;
user.email = req.body.email;
// isAdmin, role, etc NÃO são copiados
```

### Impacto
- Usuário comum vira admin
- Escalação de privilégios
- Dados corrompidos

---

## 3. Autenticação Ausente

### O que é
Endpoints sensíveis sem proteção de autenticação.

### Como Detectar

```typescript
// ❌ Sem auth
app.post('/admin/users', async (req, res) => { ... });
app.get('/api/orders', async (req, res) => { ... });
app.delete('/users/:id', async (req, res) => { ... });
```

### Como Corrigir

```typescript
// ✅ Com middleware de auth
app.post('/admin/users', authenticate, async (req, res) => { ... });
app.get('/api/orders', authenticate, async (req, res) => { ... });

// ✅ Com verificação de role
app.delete('/users/:id', authenticate, authorize('admin'), async (req, res) => { ... });
```

### Endpoints que Sempre Precisam de Auth

- `/admin/*`
- `/api/*` (interno)
- DELETE/PUT endpoints
- Endpoints com dados pessoais

---

## 4. Secrets Hardcoded

### O que é
Credenciais, API keys ou tokens no código.

### Como Detectar

```typescript
// ❌ Vulnerável
const apiKey = 'chave_secreta_123';
const password = 'chave_secreta_123';
const token = 'chave_secreta_123...';

// ❌ Vulnerável - em variáveis de ambiente mas exposto
console.log('API_KEY:', process.env.API_KEY);
```

### Como Corrigir

```typescript
// ✅ Variável de ambiente
const apiKey = process.env.API_KEY;
if (!apiKey) {
  throw new Error('API_KEY not configured');
}

// ✅ Validação no startup
// config.ts
export const config = {
  apiKey: required('API_KEY'),
  dbPassword: required('DB_PASSWORD'),
};
```

### Checklist de Secrets

- [ ] API Keys
- [ ] Tokens de acesso
- [ ] Senhas de banco
- [ ] JWT Secrets
- [ ] URLs de serviços internos
- [ ] Credenciais em comentários

---

## 5. Input Validation Ausente

### O que é
Dados de entrada não validados antes de usar.

### Como Detectar

```typescript
// ❌ Sem validação
app.post('/users', async (req, res) => {
  const user = await service.create(req.body);
  // req.body pode ter QUALQUER coisa!
});
```

### Como Corrigir

```typescript
// ✅ Schema validation (Zod)
import { z } from 'zod';

const CreateUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  password: z.string().min(8),
});

app.post('/users', async (req, res) => {
  const result = CreateUserSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json(result.error);
  }
  const user = await service.create(result.data);
});

// ✅ Middleware de validação
app.post('/users', validate(CreateUserSchema), async (req, res) => {
  const user = await service.create(req.body);
});
```

---

## 6. Dados Sensíveis em Logs

### O que é
Registrar informações sensíveis em logs.

### Como Detectar

```typescript
// ❌ Vulnerável
logger.info('login', req.body);
logger.info('user_created', user);
console.log('password:', password);

// ❌ Vulnerável - erros com stack trace
catch (error) {
  logger.error(error);  // Pode conter dados sensíveis
}
```

### Como Corrigir

```typescript
// ✅ Logs estruturados sem dados sensíveis
logger.info('login_attempt', { 
  email: req.body.email,
  userId: user?.id,
});

logger.info('user_created', {
  userId: user.id,
  email: user.email,
});

// ✅ Sanitizar erros
catch (error) {
  logger.error('Login failed', {
    error: error.message,
    stack: error.stack,
    // NÃO log req.body completo
  });
}
```

### O que NUNCA logar

- Senhas
- Tokens de sessão
- Cartões de crédito
- CPF/RG
- `req.body` completo
- Headers de Authorization

---

## 7. SSRF (Server-Side Request Forgery)

### O que é
Requisições HTTP para URLs controladas pelo usuário.

### Como Detectar

```typescript
// ❌ Vulnerável
const response = await axios.get(req.query.url);
const webhook = req.body.webhookUrl;
await fetch(webhook);
```

### Como Corrigir

```typescript
// ✅ Whitelist de domínios
const ALLOWED_DOMAINS = ['api.example.com', 'cdn.example.com'];

if (!ALLOWED_DOMAINS.includes(new URL(url).hostname)) {
  throw new Error('URL not allowed');
}

// ✅ Validação rigorosa
function isValidUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ['http:', 'https:'].includes(parsed.protocol) &&
           !['localhost', '127.0.0.1', '0.0.0.0'].includes(parsed.hostname);
  } catch {
    return false;
  }
}
```

---

## 8. Rate Limiting Ausente

### O que é
Endpoints críticos sem proteção contra abuso.

### Como Detectar

```typescript
// ❌ Sem rate limit
app.post('/login', async (req, res) => { ... });
app.post('/reset-password', async (req, res) => { ... });
app.post('/register', async (req, res) => { ... });
```

### Como Corrigir

```typescript
import rateLimit from 'express-rate-limit';

// Para login
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutos
  max: 5,  // 5 tentativas
  message: 'Too many login attempts',
});

app.post('/login', loginLimiter, async (req, res) => { ... });

// Para API geral
const apiLimiter = rateLimit({
  windowMs: 60 * 1000,  // 1 minuto
  max: 100,  // 100 requests
});

app.use('/api', apiLimiter);
```

### Endpoints que Precisam de Rate Limit

- Login / Autenticação
- Reset de senha
- Criação de conta
- Envio de email
- APIs públicas

---

## 9. Upload Inseguro de Arquivos

### O que é
Aceitar arquivos sem validação de tipo e tamanho.

### Como Detectar

```typescript
// ❌ Vulnerável
app.post('/upload', async (req, res) => {
  const file = req.files.upload;
  file.mv('/uploads/' + file.name);  // Path traversal!
});
```

### Como Corrigir

```typescript
// ✅ Validação rigorosa
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'application/pdf'];
const MAX_SIZE = 5 * 1024 * 1024;  // 5MB

app.post('/upload', async (req, res) => {
  const file = req.files.upload;
  
  // Validar tipo
  if (!ALLOWED_TYPES.includes(file.mimetype)) {
    return res.status(400).json({ error: 'File type not allowed' });
  }
  
  // Validar tamanho
  if (file.size > MAX_SIZE) {
    return res.status(400).json({ error: 'File too large' });
  }
  
  // Nome seguro
  const safeName = crypto.randomUUID() + path.extname(file.name);
  await file.mv('/secure/uploads/' + safeName);
});
```

---

## Checklist de Segurança

### Antes de Commit/Merge

- [ ] Nenhuma query SQL dinâmica com concatenação
- [ ] DTOs explícitos (sem `req.body` direto)
- [ ] Endpoints sensíveis com auth
- [ ] Sem secrets hardcoded
- [ ] Input validation em todos os endpoints
- [ ] Sem dados sensíveis em logs
- [ ] URLs de usuário validadas (SSRF)
- [ ] Rate limiting em endpoints críticos
- [ ] Validação de arquivos em uploads
