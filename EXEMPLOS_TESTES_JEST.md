# 🧪 Exemplos de Testes Jest - API Client

Exemplos de testes unitários para cada parte do `@repo/api-client`.

---

## 📦 Setup de Testes

### `packages/api-client/jest.config.js`

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/src', '<rootDir>/__tests__'],
  testMatch: ['**/__tests__/**/*.test.ts', '**/__tests__/**/*.test.tsx'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/index.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
}
```

### `packages/api-client/jest.setup.js`

```javascript
import '@testing-library/jest-dom'

// Mock localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
}

global.localStorage = localStorageMock

// Mock fetch
global.fetch = jest.fn()
```

---

## 1️⃣ Testes do Cliente HTTP

### `__tests__/client/index.test.ts`

```typescript
import { ApiClient, FetchError } from '../../src/client'

describe('ApiClient', () => {
  let client: ApiClient
  
  beforeEach(() => {
    client = new ApiClient('http://localhost:3001')
    localStorage.clear()
    ;(global.fetch as jest.Mock).mockClear()
  })

  describe('Token Management', () => {
    it('should save token to localStorage', () => {
      client.setToken('test-token')
      
      expect(localStorage.setItem).toHaveBeenCalledWith(
        'auth_token',
        'test-token'
      )
    })

    it('should retrieve token from localStorage', async () => {
      localStorage.getItem = jest.fn().mockReturnValue('stored-token')
      
      const token = await client.getToken()
      
      expect(token).toBe('stored-token')
      expect(localStorage.getItem).toHaveBeenCalledWith('auth_token')
    })

    it('should clear token from localStorage', async () => {
      await client.clearToken()
      
      expect(localStorage.removeItem).toHaveBeenCalledWith('auth_token')
    })
  })

  describe('HTTP Requests', () => {
    it('should add Authorization header when token exists', async () => {
      client.setToken('my-token')
      ;(global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ data: 'test' }),
      })

      await client.fetch('/api/test')

      expect(global.fetch).toHaveBeenCalledWith(
        expect.any(String),
        expect.objectContaining({
          headers: expect.objectContaining({
            Authorization: 'Bearer my-token',
          }),
        })
      )
    })

    it('should serialize query params', async () => {
      ;(global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ data: 'test' }),
      })

      await client.fetch('/api/test', {
        query: { limit: 10, offset: 0, search: 'test' },
      })

      expect(global.fetch).toHaveBeenCalledWith(
        expect.stringContaining('limit=10'),
        expect.any(Object)
      )
    })

    it('should stringify request body', async () => {
      ;(global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({ data: 'test' }),
      })

      const payload = { name: 'Test Drone' }
      await client.fetch('/api/drones', {
        method: 'POST',
        body: payload,
      })

      expect(global.fetch).toHaveBeenCalledWith(
        expect.any(String),
        expect.objectContaining({
          body: JSON.stringify(payload),
        })
      )
    })

    it('should throw FetchError on error response', async () => {
      ;(global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: false,
        status: 401,
        statusText: 'Unauthorized',
        json: async () => ({ message: 'Invalid token' }),
      })

      await expect(client.fetch('/api/test')).rejects.toThrow(FetchError)
    })
  })

  describe('FetchError', () => {
    it('should contain status and message', () => {
      const error = new FetchError('Test error', 'Bad Request', 400)
      
      expect(error.message).toBe('Test error')
      expect(error.status).toBe(400)
      expect(error.statusText).toBe('Bad Request')
    })
  })
})
```

---

## 2️⃣ Testes do SDK

### `__tests__/sdk/drones.test.ts`

```typescript
import { DronesApi } from '../../src/sdk/drones'
import { ApiClient } from '../../src/client'

describe('DronesApi', () => {
  let dronesApi: DronesApi
  let mockClient: jest.Mocked<ApiClient>

  beforeEach(() => {
    mockClient = {
      fetch: jest.fn(),
    } as any

    dronesApi = new DronesApi(mockClient)
  })

  describe('list', () => {
    it('should call /api/drones with query params', async () => {
      const mockResponse = { data: [], count: 0, offset: 0, limit: 20 }
      mockClient.fetch.mockResolvedValueOnce(mockResponse)

      const result = await dronesApi.list({ limit: 10, offset: 0 })

      expect(mockClient.fetch).toHaveBeenCalledWith('/api/drones', {
        query: { limit: 10, offset: 0 },
      })
      expect(result).toEqual(mockResponse)
    })
  })

  describe('get', () => {
    it('should call /api/drones/:id', async () => {
      const mockDrone = { data: { id: '123', name: 'Test' } }
      mockClient.fetch.mockResolvedValueOnce(mockDrone)

      const result = await dronesApi.get('123')

      expect(mockClient.fetch).toHaveBeenCalledWith('/api/drones/123')
      expect(result).toEqual(mockDrone)
    })
  })

  describe('create', () => {
    it('should POST to /api/drones', async () => {
      const payload = { name: 'New Drone', model: 'DJI' }
      const mockResponse = { data: { id: '123', ...payload } }
      mockClient.fetch.mockResolvedValueOnce(mockResponse)

      const result = await dronesApi.create(payload as any)

      expect(mockClient.fetch).toHaveBeenCalledWith('/api/drones', {
        method: 'POST',
        body: payload,
      })
      expect(result).toEqual(mockResponse)
    })
  })

  describe('update', () => {
    it('should PATCH /api/drones/:id', async () => {
      const payload = { name: 'Updated Drone' }
      const mockResponse = { data: { id: '123', ...payload } }
      mockClient.fetch.mockResolvedValueOnce(mockResponse)

      const result = await dronesApi.update('123', payload)

      expect(mockClient.fetch).toHaveBeenCalledWith('/api/drones/123', {
        method: 'PATCH',
        body: payload,
      })
      expect(result).toEqual(mockResponse)
    })
  })

  describe('delete', () => {
    it('should DELETE /api/drones/:id', async () => {
      const mockResponse = { success: true }
      mockClient.fetch.mockResolvedValueOnce(mockResponse)

      const result = await dronesApi.delete('123')

      expect(mockClient.fetch).toHaveBeenCalledWith('/api/drones/123', {
        method: 'DELETE',
      })
      expect(result).toEqual(mockResponse)
    })
  })
})
```

---

## 3️⃣ Testes de Query Keys

### `__tests__/hooks/query-keys.test.ts`

```typescript
import { dronesKeys, plotsKeys, pilotsKeys } from '../../src/hooks/query-keys'

describe('Query Keys', () => {
  describe('dronesKeys', () => {
    it('should generate all key', () => {
      expect(dronesKeys.all).toEqual(['drones'])
    })

    it('should generate lists key', () => {
      expect(dronesKeys.lists()).toEqual(['drones', 'list'])
    })

    it('should generate list key with params', () => {
      const params = { limit: 10, offset: 0 }
      expect(dronesKeys.list(params)).toEqual(['drones', 'list', params])
    })

    it('should generate details key', () => {
      expect(dronesKeys.details()).toEqual(['drones', 'detail'])
    })

    it('should generate detail key with id', () => {
      expect(dronesKeys.detail('123')).toEqual(['drones', 'detail', '123'])
    })

    it('should filter undefined values', () => {
      expect(dronesKeys.list()).toEqual(['drones', 'list'])
    })
  })

  describe('plotsKeys', () => {
    it('should work similarly to dronesKeys', () => {
      expect(plotsKeys.all).toEqual(['plots'])
      expect(plotsKeys.lists()).toEqual(['plots', 'list'])
    })
  })

  describe('pilotsKeys', () => {
    it('should work similarly to dronesKeys', () => {
      expect(pilotsKeys.all).toEqual(['pilots'])
      expect(pilotsKeys.lists()).toEqual(['pilots', 'list'])
    })
  })
})
```

---

## 4️⃣ Testes de Hooks React Query

### `__tests__/hooks/use-drones.test.tsx`

```typescript
import { renderHook, waitFor } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactNode } from 'react'
import { useDrones, useDrone, useCreateDrone } from '../../src/hooks/use-drones'
import { sdk } from '../../src/sdk'

jest.mock('../../src/sdk', () => ({
  sdk: {
    drones: {
      list: jest.fn(),
      get: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
  },
}))

describe('Drones Hooks', () => {
  let queryClient: QueryClient

  beforeEach(() => {
    queryClient = new QueryClient({
      defaultOptions: {
        queries: { retry: false },
        mutations: { retry: false },
      },
    })
    jest.clearAllMocks()
  })

  const wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  )

  describe('useDrones', () => {
    it('should fetch drones list', async () => {
      const mockData = { data: [], count: 0, offset: 0, limit: 20 }
      ;(sdk.drones.list as jest.Mock).mockResolvedValueOnce(mockData)

      const { result } = renderHook(() => useDrones(), { wrapper })

      await waitFor(() => expect(result.current.isSuccess).toBe(true))

      expect(sdk.drones.list).toHaveBeenCalled()
      expect(result.current.data).toEqual(mockData)
    })

    it('should pass params to list', async () => {
      const params = { limit: 10, offset: 0 }
      ;(sdk.drones.list as jest.Mock).mockResolvedValueOnce({ data: [] })

      renderHook(() => useDrones(params), { wrapper })

      await waitFor(() => {
        expect(sdk.drones.list).toHaveBeenCalledWith(params)
      })
    })
  })

  describe('useDrone', () => {
    it('should fetch single drone', async () => {
      const mockDrone = { data: { id: '123', name: 'Test' } }
      ;(sdk.drones.get as jest.Mock).mockResolvedValueOnce(mockDrone)

      const { result } = renderHook(() => useDrone('123'), { wrapper })

      await waitFor(() => expect(result.current.isSuccess).toBe(true))

      expect(sdk.drones.get).toHaveBeenCalledWith('123')
      expect(result.current.data).toEqual(mockDrone)
    })

    it('should not fetch when id is empty', () => {
      const { result } = renderHook(() => useDrone(''), { wrapper })

      expect(result.current.isLoading).toBe(false)
      expect(sdk.drones.get).not.toHaveBeenCalled()
    })
  })

  describe('useCreateDrone', () => {
    it('should create drone', async () => {
      const newDrone = { name: 'New Drone', model: 'DJI' }
      const mockResponse = { data: { id: '123', ...newDrone } }
      ;(sdk.drones.create as jest.Mock).mockResolvedValueOnce(mockResponse)

      const { result } = renderHook(() => useCreateDrone(), { wrapper })

      result.current.mutate(newDrone as any)

      await waitFor(() => expect(result.current.isSuccess).toBe(true))

      expect(sdk.drones.create).toHaveBeenCalledWith(newDrone)
      expect(result.current.data).toEqual(mockResponse)
    })

    it('should invalidate queries on success', async () => {
      const invalidateSpy = jest.spyOn(queryClient, 'invalidateQueries')
      ;(sdk.drones.create as jest.Mock).mockResolvedValueOnce({ data: {} })

      const { result } = renderHook(() => useCreateDrone(), { wrapper })

      result.current.mutate({ name: 'Test' } as any)

      await waitFor(() => expect(result.current.isSuccess).toBe(true))

      expect(invalidateSpy).toHaveBeenCalledWith({
        queryKey: expect.arrayContaining(['drones', 'list']),
      })
    })
  })
})
```

---

## 5️⃣ Testes de Auth

### `__tests__/hooks/use-auth.test.tsx`

```typescript
import { renderHook, waitFor } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactNode } from 'react'
import { useLogin, useLogout } from '../../src/hooks/use-auth'
import { apiClient } from '../../src/sdk'

jest.mock('../../src/sdk', () => ({
  apiClient: {
    fetch: jest.fn(),
    setToken: jest.fn(),
    clearToken: jest.fn(),
  },
}))

describe('Auth Hooks', () => {
  let queryClient: QueryClient

  beforeEach(() => {
    queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
    })
    jest.clearAllMocks()
  })

  const wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  )

  describe('useLogin', () => {
    it('should login and save token', async () => {
      const mockResponse = {
        token: 'test-token',
        user: { id: '1', name: 'Test', email: 'test@test.com' },
      }
      ;(apiClient.fetch as jest.Mock).mockResolvedValueOnce(mockResponse)

      const { result } = renderHook(() => useLogin(), { wrapper })

      result.current.mutate({
        email: 'test@test.com',
        password: 'password',
      })

      await waitFor(() => expect(result.current.isSuccess).toBe(true))

      expect(apiClient.fetch).toHaveBeenCalledWith('/api/auth/login', {
        method: 'POST',
        body: { email: 'test@test.com', password: 'password' },
      })
      expect(apiClient.setToken).toHaveBeenCalledWith('test-token')
    })

    it('should save user data in cache', async () => {
      const mockResponse = {
        token: 'test-token',
        user: { id: '1', name: 'Test', email: 'test@test.com' },
      }
      ;(apiClient.fetch as jest.Mock).mockResolvedValueOnce(mockResponse)

      const { result } = renderHook(() => useLogin(), { wrapper })

      result.current.mutate({
        email: 'test@test.com',
        password: 'password',
      })

      await waitFor(() => expect(result.current.isSuccess).toBe(true))

      const userData = queryClient.getQueryData(['auth', 'user'])
      expect(userData).toEqual(mockResponse.user)
    })
  })

  describe('useLogout', () => {
    it('should clear token and cache', async () => {
      const clearSpy = jest.spyOn(queryClient, 'clear')
      
      const { result } = renderHook(() => useLogout(), { wrapper })

      result.current.mutate()

      await waitFor(() => expect(result.current.isSuccess).toBe(true))

      expect(apiClient.clearToken).toHaveBeenCalled()
      expect(clearSpy).toHaveBeenCalled()
    })
  })
})
```

---

## 6️⃣ Scripts do package.json

### `packages/api-client/package.json`

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:verbose": "jest --verbose",
    "type-check": "tsc --noEmit"
  },
  "jest": {
    "preset": "ts-jest",
    "testEnvironment": "jsdom"
  }
}
```

---

## 🎯 Rodar Testes

### Todos os testes:
```bash
pnpm test
```

### Com coverage:
```bash
pnpm test:coverage
```

### Watch mode:
```bash
pnpm test:watch
```

### Teste específico:
```bash
pnpm test client/index.test.ts
```

### Via Turbo (na raiz):
```bash
turbo test --filter=api-client
```

---

## 📊 Coverage Esperado

```
File                  | % Stmts | % Branch | % Funcs | % Lines |
----------------------|---------|----------|---------|---------|
All files             |   85.00 |    80.00 |   90.00 |   85.00 |
 client/              |   90.00 |    85.00 |   95.00 |   90.00 |
  index.ts            |   90.00 |    85.00 |   95.00 |   90.00 |
 sdk/                 |   85.00 |    80.00 |   90.00 |   85.00 |
  drones.ts           |   85.00 |    80.00 |   90.00 |   85.00 |
  plots.ts            |   85.00 |    80.00 |   90.00 |   85.00 |
  pilots.ts           |   85.00 |    80.00 |   90.00 |   85.00 |
 hooks/               |   80.00 |    75.00 |   85.00 |   80.00 |
  use-drones.ts       |   80.00 |    75.00 |   85.00 |   80.00 |
  use-plots.ts        |   80.00 |    75.00 |   85.00 |   80.00 |
  use-pilots.ts       |   80.00 |    75.00 |   85.00 |   80.00 |
```

**Meta:** 70%+ coverage em todas as categorias ✅

---

**Com estes testes você terá uma base sólida e confiável! 🧪**
