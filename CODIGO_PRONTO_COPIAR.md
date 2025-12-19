# 📦 Código Pronto para Copiar - API Client

Copie e cole cada arquivo diretamente. Ordem de criação abaixo.

---

## 1️⃣ Setup Inicial

```bash
# Na raiz do monorepo
mkdir -p packages/api-client/src/{client,sdk,hooks,types}
cd packages/api-client
```

---

## 2️⃣ `packages/api-client/package.json`

```json
{
  "name": "@repo/api-client",
  "version": "0.0.1",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts",
    "./hooks": "./src/hooks/index.ts"
  },
  "scripts": {
    "lint": "eslint src/",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@tanstack/react-query": "^5.59.0",
    "qs": "^6.13.0"
  },
  "devDependencies": {
    "@types/qs": "^6.9.16",
    "typescript": "^5.6.3"
  }
}
```

---

## 3️⃣ `packages/api-client/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM"],
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

---

## 4️⃣ `packages/api-client/src/client/index.ts`

```typescript
import { stringify } from 'qs'

export class FetchError extends Error {
  status?: number
  constructor(message: string, status?: number) {
    super(message)
    this.status = status
    this.name = 'FetchError'
  }
}

export class ApiClient {
  private baseUrl: string
  private token: string | null = null

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl
    this.loadToken()
  }

  private loadToken() {
    if (typeof window !== 'undefined') {
      this.token = localStorage.getItem('auth_token')
    }
  }

  setToken(token: string) {
    this.token = token
    if (typeof window !== 'undefined') {
      localStorage.setItem('auth_token', token)
    }
  }

  clearToken() {
    this.token = null
    if (typeof window !== 'undefined') {
      localStorage.removeItem('auth_token')
    }
  }

  async fetch<T>(path: string, init?: RequestInit & { query?: any }): Promise<T> {
    const url = new URL(path, this.baseUrl)
    
    if (init?.query) {
      url.search = stringify(init.query, { skipNulls: true })
    }

    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...init?.headers,
    }

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`
    }

    const res = await fetch(url.toString(), {
      ...init,
      headers,
      body: init?.body ? JSON.stringify(init.body) : undefined,
    })

    if (!res.ok) {
      const error = await res.json().catch(() => ({}))
      throw new FetchError(error.message || res.statusText, res.status)
    }

    return res.json()
  }
}
```

---

## 5️⃣ `packages/api-client/src/types/index.ts`

```typescript
export interface PaginatedResponse<T> {
  data: T[]
  count: number
  offset: number
  limit: number
}

// ========== DRONES ==========
export interface Drone {
  id: string
  name: string
  model: string
  serialNumber: string
  status: 'available' | 'in_use' | 'maintenance'
  batteryLevel?: number
  lastMaintenance?: string
  createdAt: string
  updatedAt: string
}

export type DroneList = PaginatedResponse<Drone>
export type CreateDrone = Omit<Drone, 'id' | 'createdAt' | 'updatedAt'>

// ========== PLOTS ==========
export interface Plot {
  id: string
  name: string
  area: number
  location: {
    latitude: number
    longitude: number
  }
  cropType?: string
  ownerId?: string
  createdAt: string
  updatedAt: string
}

export type PlotList = PaginatedResponse<Plot>
export type CreatePlot = Omit<Plot, 'id' | 'createdAt' | 'updatedAt'>

// ========== PILOTS ==========
export interface Pilot {
  id: string
  name: string
  email: string
  phone?: string
  licenseNumber?: string
  status: 'active' | 'inactive'
  totalFlightHours?: number
  createdAt: string
  updatedAt: string
}

export type PilotList = PaginatedResponse<Pilot>
export type CreatePilot = Omit<Pilot, 'id' | 'createdAt' | 'updatedAt'>
```

---

## 6️⃣ `packages/api-client/src/sdk/drones.ts`

```typescript
import { ApiClient } from '../client'
import type { Drone, DroneList, CreateDrone } from '../types'

export class DronesApi {
  constructor(private client: ApiClient) {}

  list = (params?: { limit?: number; offset?: number; search?: string }) =>
    this.client.fetch<DroneList>('/api/drones', { query: params })

  get = (id: string) =>
    this.client.fetch<{ data: Drone }>(`/api/drones/${id}`)

  create = (data: CreateDrone) =>
    this.client.fetch<{ data: Drone }>('/api/drones', { method: 'POST', body: data })

  update = (id: string, data: Partial<CreateDrone>) =>
    this.client.fetch<{ data: Drone }>(`/api/drones/${id}`, { method: 'PATCH', body: data })

  delete = (id: string) =>
    this.client.fetch<{ success: boolean }>(`/api/drones/${id}`, { method: 'DELETE' })
}
```

---

## 7️⃣ `packages/api-client/src/sdk/plots.ts`

```typescript
import { ApiClient } from '../client'
import type { Plot, PlotList, CreatePlot } from '../types'

export class PlotsApi {
  constructor(private client: ApiClient) {}

  list = (params?: { limit?: number; offset?: number }) =>
    this.client.fetch<PlotList>('/api/plots', { query: params })

  get = (id: string) =>
    this.client.fetch<{ data: Plot }>(`/api/plots/${id}`)

  create = (data: CreatePlot) =>
    this.client.fetch<{ data: Plot }>('/api/plots', { method: 'POST', body: data })

  update = (id: string, data: Partial<CreatePlot>) =>
    this.client.fetch<{ data: Plot }>(`/api/plots/${id}`, { method: 'PATCH', body: data })

  delete = (id: string) =>
    this.client.fetch<{ success: boolean }>(`/api/plots/${id}`, { method: 'DELETE' })
}
```

---

## 8️⃣ `packages/api-client/src/sdk/pilots.ts`

```typescript
import { ApiClient } from '../client'
import type { Pilot, PilotList, CreatePilot } from '../types'

export class PilotsApi {
  constructor(private client: ApiClient) {}

  list = (params?: { limit?: number; offset?: number }) =>
    this.client.fetch<PilotList>('/api/pilots', { query: params })

  get = (id: string) =>
    this.client.fetch<{ data: Pilot }>(`/api/pilots/${id}`)

  create = (data: CreatePilot) =>
    this.client.fetch<{ data: Pilot }>('/api/pilots', { method: 'POST', body: data })

  update = (id: string, data: Partial<CreatePilot>) =>
    this.client.fetch<{ data: Pilot }>(`/api/pilots/${id}`, { method: 'PATCH', body: data })

  delete = (id: string) =>
    this.client.fetch<{ success: boolean }>(`/api/pilots/${id}`, { method: 'DELETE' })
}
```

---

## 9️⃣ `packages/api-client/src/sdk/index.ts`

```typescript
import { ApiClient } from '../client'
import { DronesApi } from './drones'
import { PlotsApi } from './plots'
import { PilotsApi } from './pilots'

export class ApiSDK {
  public drones: DronesApi
  public plots: PlotsApi
  public pilots: PilotsApi

  constructor(private client: ApiClient) {
    this.drones = new DronesApi(client)
    this.plots = new PlotsApi(client)
    this.pilots = new PilotsApi(client)
  }
}

const baseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
export const apiClient = new ApiClient(baseUrl)
export const sdk = new ApiSDK(apiClient)
```

---

## 🔟 `packages/api-client/src/hooks/query-keys.ts`

```typescript
const createQueryKeys = <T extends string>(key: T) => ({
  all: [key] as const,
  lists: () => [key, 'list'] as const,
  list: (params?: any) => [key, 'list', params] as const,
  details: () => [key, 'detail'] as const,
  detail: (id: string) => [key, 'detail', id] as const,
})

export const dronesKeys = createQueryKeys('drones')
export const plotsKeys = createQueryKeys('plots')
export const pilotsKeys = createQueryKeys('pilots')
```

---

## 1️⃣1️⃣ `packages/api-client/src/hooks/use-drones.ts`

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { sdk } from '../sdk'
import { dronesKeys } from './query-keys'

export const useDrones = (params?: { limit?: number; offset?: number }) => {
  return useQuery({
    queryKey: dronesKeys.list(params),
    queryFn: () => sdk.drones.list(params),
  })
}

export const useDrone = (id: string) => {
  return useQuery({
    queryKey: dronesKeys.detail(id),
    queryFn: () => sdk.drones.get(id),
    enabled: !!id,
  })
}

export const useCreateDrone = () => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: sdk.drones.create,
    onSuccess: () => qc.invalidateQueries({ queryKey: dronesKeys.lists() }),
  })
}

export const useUpdateDrone = (id: string) => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: any) => sdk.drones.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: dronesKeys.lists() })
      qc.invalidateQueries({ queryKey: dronesKeys.detail(id) })
    },
  })
}

export const useDeleteDrone = () => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: sdk.drones.delete,
    onSuccess: () => qc.invalidateQueries({ queryKey: dronesKeys.lists() }),
  })
}
```

---

## 1️⃣2️⃣ `packages/api-client/src/hooks/use-plots.ts`

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { sdk } from '../sdk'
import { plotsKeys } from './query-keys'

export const usePlots = (params?: { limit?: number; offset?: number }) => {
  return useQuery({
    queryKey: plotsKeys.list(params),
    queryFn: () => sdk.plots.list(params),
  })
}

export const usePlot = (id: string) => {
  return useQuery({
    queryKey: plotsKeys.detail(id),
    queryFn: () => sdk.plots.get(id),
    enabled: !!id,
  })
}

export const useCreatePlot = () => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: sdk.plots.create,
    onSuccess: () => qc.invalidateQueries({ queryKey: plotsKeys.lists() }),
  })
}

export const useUpdatePlot = (id: string) => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: any) => sdk.plots.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: plotsKeys.lists() })
      qc.invalidateQueries({ queryKey: plotsKeys.detail(id) })
    },
  })
}

export const useDeletePlot = () => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: sdk.plots.delete,
    onSuccess: () => qc.invalidateQueries({ queryKey: plotsKeys.lists() }),
  })
}
```

---

## 1️⃣3️⃣ `packages/api-client/src/hooks/use-pilots.ts`

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { sdk } from '../sdk'
import { pilotsKeys } from './query-keys'

export const usePilots = (params?: { limit?: number; offset?: number }) => {
  return useQuery({
    queryKey: pilotsKeys.list(params),
    queryFn: () => sdk.pilots.list(params),
  })
}

export const usePilot = (id: string) => {
  return useQuery({
    queryKey: pilotsKeys.detail(id),
    queryFn: () => sdk.pilots.get(id),
    enabled: !!id,
  })
}

export const useCreatePilot = () => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: sdk.pilots.create,
    onSuccess: () => qc.invalidateQueries({ queryKey: pilotsKeys.lists() }),
  })
}

export const useUpdatePilot = (id: string) => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: any) => sdk.pilots.update(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: pilotsKeys.lists() })
      qc.invalidateQueries({ queryKey: pilotsKeys.detail(id) })
    },
  })
}

export const useDeletePilot = () => {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: sdk.pilots.delete,
    onSuccess: () => qc.invalidateQueries({ queryKey: pilotsKeys.lists() }),
  })
}
```

---

## 1️⃣4️⃣ `packages/api-client/src/hooks/use-auth.ts`

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { apiClient } from '../sdk'

interface LoginPayload {
  email: string
  password: string
}

interface AuthResponse {
  token: string
  user: {
    id: string
    name: string
    email: string
  }
}

export const useLogin = () => {
  const qc = useQueryClient()
  
  return useMutation({
    mutationFn: async (payload: LoginPayload) => {
      const res = await apiClient.fetch<AuthResponse>('/api/auth/login', {
        method: 'POST',
        body: payload,
      })
      apiClient.setToken(res.token)
      return res
    },
    onSuccess: (data) => {
      qc.setQueryData(['auth', 'user'], data.user)
    },
  })
}

export const useLogout = () => {
  const qc = useQueryClient()
  
  return useMutation({
    mutationFn: async () => {
      apiClient.clearToken()
    },
    onSuccess: () => {
      qc.clear()
    },
  })
}
```

---

## 1️⃣5️⃣ `packages/api-client/src/hooks/index.ts`

```typescript
export * from './use-drones'
export * from './use-plots'
export * from './use-pilots'
export * from './use-auth'
export * from './query-keys'
```

---

## 1️⃣6️⃣ `packages/api-client/src/index.ts`

```typescript
export { ApiClient, FetchError } from './client'
export { sdk, apiClient } from './sdk'
export type * from './types'
export * from './hooks'
```

---

## 1️⃣7️⃣ Instalar nos Apps

```bash
# Na raiz do monorepo
cd apps/web-admin
npm install @tanstack/react-query@^5.59.0
# Repita para web-pilot e web-field
```

### Atualizar `apps/web-admin/package.json`

```json
{
  "dependencies": {
    "@repo/api-client": "*",
    "@tanstack/react-query": "^5.59.0",
    "@tanstack/react-query-devtools": "^5.59.0"
  }
}
```

---

## 1️⃣8️⃣ `apps/web-admin/providers/query-provider.tsx`

```typescript
'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { useState, type ReactNode } from 'react'

export function QueryProvider({ children }: { children: ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
            refetchOnWindowFocus: false,
          },
        },
      })
  )

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

---

## 1️⃣9️⃣ `apps/web-admin/app/layout.tsx`

```typescript
import { QueryProvider } from '@/providers/query-provider'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR">
      <body>
        <QueryProvider>{children}</QueryProvider>
      </body>
    </html>
  )
}
```

---

## 2️⃣0️⃣ `apps/web-admin/.env.local`

```bash
NEXT_PUBLIC_API_URL=http://localhost:3001
```

---

## 2️⃣1️⃣ Exemplo de Página - `apps/web-admin/app/drones/page.tsx`

```typescript
'use client'

import { useDrones, useCreateDrone, useDeleteDrone } from '@repo/api-client/hooks'

export default function DronesPage() {
  const { data, isLoading } = useDrones({ limit: 20 })
  const createDrone = useCreateDrone()
  const deleteDrone = useDeleteDrone()

  if (isLoading) return <div>Carregando...</div>

  return (
    <div className="p-8">
      <div className="flex justify-between mb-6">
        <h1 className="text-2xl font-bold">Drones</h1>
        <button
          onClick={() =>
            createDrone.mutate({
              name: 'Drone Novo',
              model: 'DJI Mavic 3',
              serialNumber: Math.random().toString(36).substring(7),
              status: 'available',
            })
          }
          className="px-4 py-2 bg-blue-600 text-white rounded"
        >
          + Criar Drone
        </button>
      </div>

      <div className="grid gap-4">
        {data?.data.map((drone) => (
          <div
            key={drone.id}
            className="p-4 border rounded flex justify-between items-center"
          >
            <div>
              <h3 className="font-semibold">{drone.name}</h3>
              <p className="text-sm text-gray-600">
                {drone.model} - {drone.status}
              </p>
              <p className="text-xs text-gray-500">{drone.serialNumber}</p>
            </div>
            <button
              onClick={() => deleteDrone.mutate(drone.id)}
              className="px-3 py-1 bg-red-600 text-white rounded text-sm"
            >
              Deletar
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}
```

---

## 2️⃣2️⃣ Exemplo de Login - `apps/web-admin/app/login/page.tsx`

```typescript
'use client'

import { useLogin } from '@repo/api-client/hooks'
import { useRouter } from 'next/navigation'
import { FormEvent } from 'react'

export default function LoginPage() {
  const login = useLogin()
  const router = useRouter()

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    
    login.mutate(
      {
        email: formData.get('email') as string,
        password: formData.get('password') as string,
      },
      {
        onSuccess: () => {
          router.push('/drones')
        },
      }
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center">
      <form onSubmit={handleSubmit} className="w-96 p-8 bg-white rounded shadow">
        <h1 className="text-2xl font-bold mb-6">Login</h1>
        
        <input
          name="email"
          type="email"
          placeholder="Email"
          className="w-full p-2 border rounded mb-4"
          required
        />
        
        <input
          name="password"
          type="password"
          placeholder="Senha"
          className="w-full p-2 border rounded mb-4"
          required
        />
        
        <button
          type="submit"
          disabled={login.isPending}
          className="w-full py-2 bg-blue-600 text-white rounded"
        >
          {login.isPending ? 'Entrando...' : 'Entrar'}
        </button>
        
        {login.isError && (
          <p className="text-red-600 text-sm mt-2">
            {login.error.message}
          </p>
        )}
      </form>
    </div>
  )
}
```

---

## ✅ Comandos para Rodar

```bash
# 1. Instalar dependências do pacote
cd packages/api-client
npm install

# 2. Instalar dependências dos apps
cd ../../apps/web-admin
npm install

# 3. Voltar para raiz e rodar tudo
cd ../..
npm install  # ou pnpm install
turbo dev
```

---

## 🎯 Resultado Final

Agora você tem:

✅ SDK compartilhado entre 3 apps  
✅ Hooks de React Query prontos  
✅ Autenticação JWT  
✅ TypeScript completo  
✅ Cache inteligente  
✅ Código conciso e direto  

**Tempo total:** ~6-8 horas para implementar tudo! 🚀
