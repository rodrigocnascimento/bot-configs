# Code Style - Padrões de Código

## Visão Geral

Padrões de código para manter consistência e qualidade no codebase TypeScript/Node.js.

---

## Imports

### ❌ PROIBIDO: Root Aliases

```typescript
// ❌ ERRADO
import { AuthService } from '@/services/auth.service';
import { db } from '@/config/database';

// ❌ ERRADO
import { User } from '~models/user';

// ❌ ERRADO
import { Utils } from '#utils';
```

### ✅ OBRIGATÓRIO: Relative Paths

```typescript
// ✅ CORRETO
import { AuthService } from '../../services/auth.service';
import { db } from '../../../config/database';
import { User } from '../../models/user.model';
```

### Por quê?

- Aliases (`@/`, `~/*`, `#/*`) causam falhas em:
  - Builds (ts-node, esbuild)
  - Testes (Jest sem config extra)
  - TypeScript compilation
- Paths relativos são universais

---

## TypeScript

### Evitar `any`

```typescript
// ❌ ERRADO
function createUser(data: any): any {
  return db.save(data);
}

// ✅ CORRETO
function createUser(dto: CreateUserDTO): Promise<User> {
  return userRepository.save(dto);
}
```

### Usar `unknown` se necessário

```typescript
// ❌
function parse(input: any) { ... }

// ✅
function parse(input: unknown) {
  if (typeof input === 'string') {
    return JSON.parse(input);
  }
  throw new Error('Invalid input');
}
```

### Retornos Explícitos

```typescript
// ❌ ERRADO
function getUser(id: string) {
  return userRepository.findOne(id);
}

// ✅ CORRETO
async function getUser(id: string): Promise<User | null> {
  return userRepository.findOne(id);
}
```

### Interfaces vs Types

```typescript
// Preferir interface para objetos
interface UserDTO {
  name: string;
  email: string;
}

// Usar type para unions ou intersections
type Status = 'active' | 'inactive';
type UserWithRole = UserDTO & { role: string };
```

---

## DTOs (Data Transfer Objects)

### Obrigatório para Controllers

```typescript
// ❌ ERRADO
app.post('/users', async (req, res) => {
  await userService.create(req.body);  // req.body = any!
});

// ✅ CORRETO
app.post('/users', async (req, res) => {
  const dto: CreateUserDTO = {
    name: req.body.name,
    email: req.body.email,
    password: req.body.password,
  };
  await userService.create(dto);
});
```

### Estrutura de DTO

```typescript
// dto/create-user.dto.ts
export class CreateUserDTO {
  name: string;
  email: string;
  password: string;
}
```

### Validação de DTO

```typescript
// Com class-validator
export class CreateUserDTO {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;
}
```

---

## Error Handling

### Try/Catch Obrigatório

```typescript
// ❌ ERRADO
service.execute(data);  // Promise sem await!

// ✅ CORRETO
try {
  await service.execute(data);
} catch (error) {
  logger.error('Execution failed', { error, data });
  throw new AppError('Processing failed');
}
```

### Custom AppError

```typescript
// error/app-error.ts
export class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message);
  }
}

// Uso
throw new AppError('User not found', 404, 'USER_NOT_FOUND');
```

### Não Silenciar Erros

```typescript
// ❌ ERRADO
try {
  await service.execute(data);
} catch (error) {
  // Silenciado!
}

// ✅ CORRETO
try {
  await service.execute(data);
} catch (error) {
  logger.error('Failed to execute', { error, data });
  throw new AppError('Execution failed', 500, 'EXECUTION_ERROR');
}
```

---

## Naming Conventions

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Arquivos | kebab-case | `user-auth.service.ts` |
| Classes | PascalCase | `UserAuthService` |
| Interfaces | PascalCase | `CreateUserDTO`, `IUserRepository` |
| Funções | camelCase | `getUserById()` |
| Variáveis | camelCase | `userName`, `isActive` |
| Constantes | UPPER_SNAKE | `MAX_RETRIES`, `API_URL` |
| Enums | PascalCase (valores UPPER_SNAKE) | `UserStatus.ACTIVE` |

### Arquivos

```
✅ user-auth.service.ts
✅ create-user.dto.ts
✅ user-repository.interface.ts

❌ userAuth.service.ts
❌ UserAuthService.ts
❌ createUserDTO.ts
```

### Classes e Interfaces

```typescript
// ✅ Classe
class UserService { ... }

// ✅ Interface (opcional prefixo I)
interface IUserRepository { ... }
interface UserRepository { ... }

// ✅ DTO
class CreateUserDTO { ... }
```

---

## Database Operations

### Parameterized Queries

```typescript
// ❌ ERRADO - SQL Injection
await repository.query(`SELECT * FROM users WHERE email = '${email}'`);

// ✅ CORRETO
await repository.query(
  'SELECT * FROM users WHERE email = ?',
  [email]
);
```

### Transações

```typescript
// ❌ ERRADO
await orderRepository.save(order);
await paymentRepository.save(payment);
// Se payment falhar, order já foi salvo!

// ✅ CORRETO
await dataSource.transaction(async manager => {
  await manager.save(order);
  await manager.save(payment);
});
```

### Evitar N+1

```typescript
// ❌ ERRADO
const orders = await orderRepository.find();
for (const order of orders) {
  order.items = await itemRepository.findByOrder(order.id);
}

// ✅ CORRETO
const orders = await orderRepository.find({
  relations: ['items'],
});
```

### Filtros no Banco

```typescript
// ❌ ERRADO
const users = await repository.find();
return users.filter(u => u.active);

// ✅ CORRETO
return repository.find({ where: { active: true } });
```

---

## Async/Await

### Evitar Promises sem Await

```typescript
// ❌ ERRADO
function processAll(items: Item[]) {
  items.forEach(item => {
    processItem(item);  // Promise ignorada!
  });
}

// ✅ CORRETO
async function processAll(items: Item[]) {
  await Promise.all(items.map(item => processItem(item)));
}
```

### Async em Loops

```typescript
// ❌ LENTO - Sequencial
for (const user of users) {
  await sendEmail(user);
}

// ✅ RÁPIDO - Paralelo
await Promise.all(users.map(user => sendEmail(user)));
```

---

## Logs

### Logs Estruturados

```typescript
// ❌ ERRADO
console.log('User created', user);

// ✅ CORRETO
logger.info('user_created', { userId: user.id, email: user.email });
```

### Evitar Dados Sensíveis

```typescript
// ❌ ERRADO
logger.info('login', req.body);

// ✅ CORRETO
logger.info('login_attempt', { email: req.body.email });
```

---

## Clean Architecture

### Fluxo Correto

```
controller → usecase/service → repository → database
```

### Camadas

| Camada | Responsabilidade | Depende de |
|--------|------------------|------------|
| Controller | HTTP (req/res) | UseCase |
| UseCase | Regra de negócio | Repository (interface) |
| Repository | Persistência | Database/ORM |
| Entity/Domain | Modelo de dados | Nenhuma |

### Violações

```typescript
// ❌ VIOLAÇÃO: Controller acessa DB
app.post('/users', async (req, res) => {
  await userRepository.save(req.body);  // ❌
});

// ❌ VIOLAÇÃO: UseCase conhece Express
class CreateUserUseCase {
  execute(req: Request) {  // ❌ Express em UseCase!
    ...
  }
}

// ❌ VIOLAÇÃO: Domínio usa ORM
@Entity()
class User {  // ❌ TypeORM em Domain!
  ...
}
```
