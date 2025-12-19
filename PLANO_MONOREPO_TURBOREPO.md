# Plano Arquitetura API - Monorepo Turborepo
## Drones Agrícolas

---

## 📁 Estrutura do Monorepo

```
/
├── apps/
│   ├── web-admin/          # App 1: Admin dashboard
│   ├── web-pilot/          # App 2: Portal do piloto
│   └── web-field/          # App 3: Campo/Operações
│
├── packages/
│   ├── api-client/         # 🎯 SDK + Hooks (NOVO)
│   │   ├── src/
│   │   │   ├── client/     # Cliente HTTP
│   │   │   ├── sdk/        # SDK de recursos
│   │   │   ├── hooks/      # React Query hooks
│   │   │   └── types/      # TypeScript types
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── ui/                 # Componentes compartilhados
│   └── config/             # Configs compartilhadas
│
└── turbo.json
```

---

## 🎯 Issues Priorizadas (Monorepo)

### **Issue #1: Setup Pacote `api-client`** ⚡
**Tempo:** 1h  
**Prioridade:** 🔴 Crítica

#### Tarefas
```bash
cd packages
mkdir -p api-client/src/{client,sdk,hooks,types}
cd api-client
npm init -y
```

#### `package.json`
```json
{
  "name": "@repo/api-client",
  "version": "0.0.1",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": "./src/index.ts",
    "./hooks": "./src/hooks/index.ts"
  },
  "scripts": {
    "build": "tsc"
  },
  "dependencies": {
    "@tanstack/react-query": "^5.0.0",
    "qs": "^6.11.0"
  },
  "devDependencies": {
    "@types/qs": "^6.9.10",
    "typescript": "^5.0.0"
  }
}
```

#### Adicionar nos apps
```json
// apps/web-admin/package.json
{
  "dependencies": {
    "@repo/api-client": "*"
  }
}
```

---

### **Issue #2: Cliente HTTP + Auth JWT** ⚡
**Tempo:** 2h  
**Prioridade:** 🔴 Crítica

#### `packages/api-client/src/client/index.ts`
```typescript
import { stringify } from 'qs'

export class FetchError extends Error {
  status?: number
  constructor(message: string, status?: number) {
    super(message)
    this.status = status
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

### **Issue #3: SDK de Recursos** ⚡
**Tempo:** 2h  
**Prioridade:** 🔴 Crítica

#### `packages/api-client/src/sdk/drones.ts`
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

#### `packages/api-client/src/sdk/plots.ts`
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

#### `packages/api-client/src/sdk/pilots.ts`
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

#### `packages/api-client/src/sdk/index.ts`
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

// Instância singleton
const baseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
export const apiClient = new ApiClient(baseUrl)
export const sdk = new ApiSDK(apiClient)
```

---

### **Issue #4: TypeScript Types** ⚡
**Tempo:** 1h  
**Prioridade:** 🔴 Crítica

#### `packages/api-client/src/types/index.ts`
```typescript
// Base types
export interface PaginatedResponse<T> {
  data: T[]
  count: number
  offset: number
  limit: number
}

// Drone types
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

// Plot types
export interface Plot {
  id: string
  name: string
  area: number // hectares
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

// Pilot types
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

### **Issue #5: Query Keys Factory** ⚡
**Tempo:** 30min  
**Prioridade:** 🔴 Crítica

#### `packages/api-client/src/hooks/query-keys.ts`
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

### **Issue #6: React Query Hooks** ⚡
**Tempo:** 2h  
**Prioridade:** 🟡 Alta

#### `packages/api-client/src/hooks/use-drones.ts`
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

#### `packages/api-client/src/hooks/use-plots.ts`
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

#### `packages/api-client/src/hooks/use-pilots.ts`
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

#### `packages/api-client/src/hooks/index.ts`
```typescript
export * from './use-drones'
export * from './use-plots'
export * from './use-pilots'
export * from './query-keys'
```

---

### **Issue #7: Hook de Auth** ⚡
**Tempo:** 1h  
**Prioridade:** 🟡 Alta

#### `packages/api-client/src/hooks/use-auth.ts`
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

### **Issue #8: Exports Principais** ⚡
**Tempo:** 15min  
**Prioridade:** 🔴 Crítica

#### `packages/api-client/src/index.ts`
```typescript
// Client & SDK
export { ApiClient, FetchError } from './client'
export { sdk, apiClient } from './sdk'

// Types
export type * from './types'

// Hooks
export * from './hooks'
```

---

### **Issue #9: Setup React Query nos Apps** ⚡
**Tempo:** 30min por app  
**Prioridade:** 🟡 Alta

#### `apps/web-admin/providers/query-provider.tsx`
```typescript
'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { useState } from 'react'

export function QueryProvider({ children }: { children: React.ReactNode }) {
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

#### `apps/web-admin/app/layout.tsx`
```typescript
import { QueryProvider } from '@/providers/query-provider'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <QueryProvider>{children}</QueryProvider>
      </body>
    </html>
  )
}
```

---

## 🚀 Exemplo de Uso nos Apps

### `apps/web-admin/app/drones/page.tsx`
```typescript
'use client'

import { useDrones, useCreateDrone, useDeleteDrone } from '@repo/api-client/hooks'

export default function DronesPage() {
  const { data, isLoading } = useDrones({ limit: 20, offset: 0 })
  const createDrone = useCreateDrone()
  const deleteDrone = useDeleteDrone()

  if (isLoading) return <div>Carregando...</div>

  return (
    <div>
      <button onClick={() => createDrone.mutate({ 
        name: 'Drone XYZ',
        model: 'DJI Mavic 3',
        serialNumber: '123456',
        status: 'available'
      })}>
        Criar Drone
      </button>

      {data?.data.map((drone) => (
        <div key={drone.id}>
          <h3>{drone.name}</h3>
          <p>{drone.model} - {drone.status}</p>
          <button onClick={() => deleteDrone.mutate(drone.id)}>
            Deletar
          </button>
        </div>
      ))}
    </div>
  )
}
```

### `apps/web-pilot/app/my-flights/page.tsx`
```typescript
'use client'

import { usePlots, useDrones } from '@repo/api-client/hooks'

export default function MyFlightsPage() {
  const { data: plots } = usePlots()
  const { data: drones } = useDrones()

  return (
    <div>
      <h1>Minhas Missões</h1>
      <div>
        <h2>Talhões</h2>
        {plots?.data.map((plot) => (
          <div key={plot.id}>
            {plot.name} - {plot.area}ha
          </div>
        ))}
      </div>
      <div>
        <h2>Drones Disponíveis</h2>
        {drones?.data.filter(d => d.status === 'available').map((drone) => (
          <div key={drone.id}>{drone.name}</div>
        ))}
      </div>
    </div>
  )
}
```

---

## 📋 Checklist de Implementação

### Fase 1: Setup (2-3h)
- [ ] Issue #1: Criar pacote `api-client`
- [ ] Issue #2: Cliente HTTP + Auth
- [ ] Issue #3: SDK (Drones, Plots, Pilots)
- [ ] Issue #4: TypeScript Types
- [ ] Issue #5: Query Keys

### Fase 2: Hooks (3-4h)
- [ ] Issue #6: Hooks de recursos
- [ ] Issue #7: Hook de auth
- [ ] Issue #8: Exports principais

### Fase 3: Integração (1-2h por app)
- [ ] Issue #9: Setup React Query em cada app
- [ ] Testar login/logout
- [ ] Testar CRUD de drones
- [ ] Testar listagem de plots
- [ ] Testar listagem de pilots

### Total: ~8-12h

---

## 🔧 Comandos Rápidos

```bash
# 1. Criar pacote
mkdir -p packages/api-client/src/{client,sdk,hooks,types}
cd packages/api-client
npm init -y

# 2. Instalar dependências
npm install @tanstack/react-query qs
npm install -D @types/qs typescript

# 3. Adicionar aos apps
cd ../../apps/web-admin
npm install @repo/api-client@*

# 4. Build e dev
turbo build
turbo dev
```

---

## 🎯 Variáveis de Ambiente

#### `.env.local` (em cada app)
```bash
NEXT_PUBLIC_API_URL=http://localhost:3001
```

---

Isso cobre todo o setup! Comece pela **Issue #1** e siga a ordem. Código conciso e direto ao ponto! 🚀
