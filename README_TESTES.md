# 🧪 Guia de Testes - API Client

**Framework:** Jest + Testing Library  
**Coverage Alvo:** 70%+

---

## 🚀 Quick Start

### 1. Rodar Testes
```bash
# Pacote específico
pnpm --filter api-client test

# Todos os pacotes (via Turbo)
turbo test

# Com coverage
pnpm --filter api-client test:coverage

# Watch mode
pnpm --filter api-client test:watch
```

### 2. Estrutura de Testes
```
packages/api-client/
├── src/
│   ├── client/
│   ├── sdk/
│   ├── hooks/
│   └── types/
└── __tests__/
    ├── client/
    │   └── index.test.ts       ✅
    ├── sdk/
    │   ├── drones.test.ts      ✅
    │   ├── plots.test.ts       ✅
    │   └── pilots.test.ts      ✅
    ├── hooks/
    │   ├── query-keys.test.ts  ✅
    │   ├── use-drones.test.tsx ✅
    │   ├── use-plots.test.tsx  ✅
    │   ├── use-pilots.test.tsx ✅
    │   └── use-auth.test.tsx   ✅
    └── types/
        └── index.test.ts       ✅
```

---

## 📋 Checklist de Testes por Componente

### ✅ Cliente HTTP (`client/index.test.ts`)
- [ ] Inicialização do ApiClient
- [ ] setToken() salva no localStorage
- [ ] getToken() recupera token
- [ ] clearToken() remove token
- [ ] fetch() adiciona Authorization header
- [ ] Query params serializados corretamente
- [ ] Body stringified em POST/PATCH
- [ ] FetchError captura erros

### ✅ SDK (`sdk/*.test.ts`)
Para cada recurso (drones, plots, pilots):
- [ ] list() chama endpoint correto com params
- [ ] get(id) chama endpoint com id
- [ ] create(data) faz POST com body
- [ ] update(id, data) faz PATCH
- [ ] delete(id) faz DELETE
- [ ] Usa client.fetch() internamente

### ✅ Query Keys (`hooks/query-keys.test.ts`)
- [ ] all retorna array correto
- [ ] lists() retorna key de lista
- [ ] list(params) inclui params
- [ ] details() retorna key base
- [ ] detail(id) inclui id
- [ ] Filtra valores undefined

### ✅ Hooks (`hooks/use-*.test.tsx`)
Para cada recurso:
- [ ] useResource() chama SDK.list()
- [ ] useResource(id) chama SDK.get()
- [ ] useResource(id) desabilitado se id vazio
- [ ] useCreateResource() chama SDK.create()
- [ ] Mutations invalidam cache correto
- [ ] onSuccess callbacks funcionam

### ✅ Auth (`hooks/use-auth.test.tsx`)
- [ ] useLogin() chama /api/auth/login
- [ ] Token salvo após login
- [ ] User data salva no cache
- [ ] useLogout() limpa token
- [ ] useLogout() limpa cache

---

## 🎯 Exemplo Rápido

### Teste de SDK
```typescript
import { DronesApi } from '../../src/sdk/drones'
import { ApiClient } from '../../src/client'

describe('DronesApi', () => {
  let api: DronesApi
  let mockClient: jest.Mocked<ApiClient>

  beforeEach(() => {
    mockClient = { fetch: jest.fn() } as any
    api = new DronesApi(mockClient)
  })

  it('should list drones', async () => {
    mockClient.fetch.mockResolvedValueOnce({ data: [] })
    
    await api.list({ limit: 10 })
    
    expect(mockClient.fetch).toHaveBeenCalledWith('/api/drones', {
      query: { limit: 10 }
    })
  })
})
```

### Teste de Hook
```typescript
import { renderHook, waitFor } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useDrones } from '../../src/hooks/use-drones'
import { sdk } from '../../src/sdk'

jest.mock('../../src/sdk')

describe('useDrones', () => {
  let queryClient: QueryClient
  
  beforeEach(() => {
    queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false } }
    })
  })

  const wrapper = ({ children }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  )

  it('should fetch drones', async () => {
    (sdk.drones.list as jest.Mock).mockResolvedValueOnce({ data: [] })
    
    const { result } = renderHook(() => useDrones(), { wrapper })
    
    await waitFor(() => expect(result.current.isSuccess).toBe(true))
    
    expect(sdk.drones.list).toHaveBeenCalled()
  })
})
```

---

## 📊 Interpretar Coverage

### Comando:
```bash
pnpm test:coverage
```

### Output esperado:
```
----------------------------|---------|----------|---------|---------|
File                        | % Stmts | % Branch | % Funcs | % Lines |
----------------------------|---------|----------|---------|---------|
All files                   |   85.00 |    80.00 |   90.00 |   85.00 |
 client/                    |   90.00 |    85.00 |   95.00 |   90.00 |
 sdk/                       |   85.00 |    80.00 |   90.00 |   85.00 |
 hooks/                     |   80.00 |    75.00 |   85.00 |   80.00 |
----------------------------|---------|----------|---------|---------|
```

### Meta:
- ✅ **70%+** em todas as categorias
- ✅ **80%+** para código crítico (client, sdk)
- ✅ **75%+** para hooks

---

## 🔧 Configuração Jest

### `jest.config.js`
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/src', '<rootDir>/__tests__'],
  testMatch: ['**/__tests__/**/*.test.ts', '**/__tests__/**/*.test.tsx'],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
}
```

### `jest.setup.js`
```javascript
require('@testing-library/jest-dom')

// Mock localStorage
global.localStorage = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
}

// Mock fetch
global.fetch = jest.fn()
```

---

## 🎨 Patterns de Teste

### Pattern 1: Mock do SDK
```typescript
jest.mock('../../src/sdk', () => ({
  sdk: {
    drones: {
      list: jest.fn(),
      get: jest.fn(),
      create: jest.fn(),
    },
  },
}))
```

### Pattern 2: Mock do Cliente
```typescript
const mockClient = {
  fetch: jest.fn(),
  setToken: jest.fn(),
  getToken: jest.fn(),
  clearToken: jest.fn(),
} as any
```

### Pattern 3: Wrapper para Hooks
```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: { retry: false },
    mutations: { retry: false },
  },
})

const wrapper = ({ children }: { children: ReactNode }) => (
  <QueryClientProvider client={queryClient}>
    {children}
  </QueryClientProvider>
)
```

### Pattern 4: Teste de Invalidação
```typescript
it('should invalidate cache', async () => {
  const spy = jest.spyOn(queryClient, 'invalidateQueries')
  
  const { result } = renderHook(() => useCreateDrone(), { wrapper })
  
  result.current.mutate({ name: 'Test' })
  
  await waitFor(() => expect(result.current.isSuccess).toBe(true))
  
  expect(spy).toHaveBeenCalledWith({
    queryKey: expect.arrayContaining(['drones', 'list'])
  })
})
```

---

## ⚡ Dicas de Performance

### 1. Reutilizar QueryClient
```typescript
describe('Suite', () => {
  let queryClient: QueryClient
  
  beforeEach(() => {
    queryClient = new QueryClient({ ... })
  })
  
  // Reutilizar em todos os testes
})
```

### 2. Desabilitar Retry
```typescript
new QueryClient({
  defaultOptions: {
    queries: { retry: false },    // ⚡ Mais rápido
    mutations: { retry: false },
  },
})
```

### 3. Mock Específicos
```typescript
// ❌ Lento - mocka tudo
jest.mock('../../src/sdk')

// ✅ Rápido - mocka só o necessário
const mockList = jest.fn()
jest.spyOn(sdk.drones, 'list').mockImplementation(mockList)
```

### 4. Rodar Testes em Paralelo
```bash
# Por padrão Jest já roda em paralelo
pnpm test

# Forçar sequencial (debug)
pnpm test --runInBand
```

---

## 🐛 Debugging

### Ver Output Detalhado
```bash
pnpm test --verbose
```

### Rodar Teste Específico
```bash
pnpm test drones.test.ts
```

### Watch Mode + Coverage
```bash
pnpm test:watch --coverage
```

### Debug no VS Code
```json
{
  "type": "node",
  "request": "launch",
  "name": "Jest Current File",
  "program": "${workspaceFolder}/node_modules/.bin/jest",
  "args": [
    "${fileBasenameNoExtension}",
    "--config",
    "jest.config.js"
  ],
  "console": "integratedTerminal",
  "internalConsoleOptions": "neverOpen"
}
```

---

## ✅ Checklist Antes de Commit

- [ ] `pnpm test` passando 100%
- [ ] `pnpm test:coverage` > 70%
- [ ] `pnpm type-check` sem erros
- [ ] Todos os mocks limpos
- [ ] Testes isolados (não dependem uns dos outros)
- [ ] Nomes descritivos (`it('should...')`)

---

## 📚 Recursos Adicionais

- **Jest Docs:** https://jestjs.io/docs/getting-started
- **Testing Library:** https://testing-library.com/docs/react-testing-library/intro
- **React Query Testing:** https://tanstack.com/query/latest/docs/framework/react/guides/testing

---

## 🎯 TL;DR

```bash
# 1. Rodar testes
pnpm test

# 2. Ver coverage
pnpm test:coverage

# 3. Verificar se passou 70%
# Se sim: ✅ Commit
# Se não: ⚠️ Adicionar mais testes
```

**Meta: 70%+ coverage em todas as categorias!** 🎯
