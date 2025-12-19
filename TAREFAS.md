# 📋 Tarefas - Implementação API Client

**Monorepo Turborepo + Drones Agrícolas**  
**Tempo Total:** 6-8 horas

---

## ✅ FASE 1: Setup Inicial (1h)

### [ ] Tarefa #1: Criar Pacote api-client (15min)
**Prioridade:** 🔴 Crítica

**Ações:**
```bash
cd seu-monorepo
mkdir -p packages/api-client/src/{client,sdk,hooks,types}
cd packages/api-client
```

**Criar:**
- [ ] `package.json`
- [ ] `tsconfig.json`
- [ ] `README.md`
- [ ] `.gitignore`

**Instalar:**
```bash
npm install @tanstack/react-query@^5.59.0 qs@^6.13.0
npm install -D @types/qs@^6.9.16 typescript@^5.6.3
```

**Resultado:** Estrutura base criada e dependências instaladas.

---

### [ ] Tarefa #2: Cliente HTTP com Auth JWT (30min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/client/index.ts`

**Implementar:**
- [ ] Classe `ApiClient`
- [ ] Método `fetch<T>(path, init)`
- [ ] Classe `FetchError`
- [ ] Métodos de token:
  - [ ] `setToken(token)`
  - [ ] `getToken()`
  - [ ] `clearToken()`
- [ ] Gerenciamento de headers (Authorization, Content-Type)
- [ ] Parse de query params com `qs`

**Testar:**
```typescript
const client = new ApiClient('http://localhost:3001')
client.fetch('/api/test').then(console.log)
```

**Resultado:** Cliente HTTP funcionando com JWT.

---

### [ ] Tarefa #3: TypeScript Types (15min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/types/index.ts`

**Definir interfaces:**
- [ ] `PaginatedResponse<T>`
- [ ] `Drone` + `DroneList` + `CreateDrone`
- [ ] `Plot` + `PlotList` + `CreatePlot`
- [ ] `Pilot` + `PilotList` + `CreatePilot`

**Resultado:** Tipos TypeScript completos.

---

## ✅ FASE 2: SDK (1h 30min)

### [ ] Tarefa #4: SDK de Drones (30min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/sdk/drones.ts`

**Implementar classe `DronesApi`:**
- [ ] `list(params?)` → GET /api/drones
- [ ] `get(id)` → GET /api/drones/:id
- [ ] `create(data)` → POST /api/drones
- [ ] `update(id, data)` → PATCH /api/drones/:id
- [ ] `delete(id)` → DELETE /api/drones/:id

**Testar:**
```typescript
import { sdk } from '../sdk'
sdk.drones.list().then(console.log)
```

**Resultado:** CRUD de drones funcionando.

---

### [ ] Tarefa #5: SDK de Plots (Talhões) (30min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/sdk/plots.ts`

**Implementar classe `PlotsApi`:**
- [ ] `list(params?)`
- [ ] `get(id)`
- [ ] `create(data)`
- [ ] `update(id, data)`
- [ ] `delete(id)`

**Resultado:** CRUD de plots funcionando.

---

### [ ] Tarefa #6: SDK de Pilots (Pilotos) (30min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/sdk/pilots.ts`

**Implementar classe `PilotsApi`:**
- [ ] `list(params?)`
- [ ] `get(id)`
- [ ] `create(data)`
- [ ] `update(id, data)`
- [ ] `delete(id)`

**Resultado:** CRUD de pilots funcionando.

---

### [ ] Tarefa #7: SDK Principal (15min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/sdk/index.ts`

**Implementar:**
- [ ] Classe `ApiSDK`
- [ ] Integrar `DronesApi`, `PlotsApi`, `PilotsApi`
- [ ] Exportar instância singleton `sdk`
- [ ] Exportar `apiClient`

**Testar:**
```typescript
import { sdk } from '@repo/api-client'
sdk.drones.list()
sdk.plots.get('123')
```

**Resultado:** SDK completo e funcional.

---

## ✅ FASE 3: React Query Hooks (2h)

### [ ] Tarefa #8: Query Keys (15min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/hooks/query-keys.ts`

**Implementar:**
- [ ] Factory `createQueryKeys<T>`
- [ ] `dronesKeys` → all, lists(), list(params), details(), detail(id)
- [ ] `plotsKeys`
- [ ] `pilotsKeys`

**Resultado:** Sistema de query keys hierárquico.

---

### [ ] Tarefa #9: Hooks de Drones (30min)
**Prioridade:** 🟡 Alta

**Criar:** `packages/api-client/src/hooks/use-drones.ts`

**Implementar hooks:**
- [ ] `useDrones(params?)` → useQuery
- [ ] `useDrone(id)` → useQuery
- [ ] `useCreateDrone()` → useMutation
- [ ] `useUpdateDrone(id)` → useMutation
- [ ] `useDeleteDrone()` → useMutation

**Adicionar invalidação de cache:**
- [ ] Create → invalidar `lists()`
- [ ] Update → invalidar `lists()` + `detail(id)`
- [ ] Delete → invalidar `lists()` + `detail(id)`

**Resultado:** Hooks de drones funcionando.

---

### [ ] Tarefa #10: Hooks de Plots (30min)
**Prioridade:** 🟡 Alta

**Criar:** `packages/api-client/src/hooks/use-plots.ts`

**Implementar hooks:**
- [ ] `usePlots(params?)`
- [ ] `usePlot(id)`
- [ ] `useCreatePlot()`
- [ ] `useUpdatePlot(id)`
- [ ] `useDeletePlot()`
- [ ] Invalidação de cache

**Resultado:** Hooks de plots funcionando.

---

### [ ] Tarefa #11: Hooks de Pilots (30min)
**Prioridade:** 🟡 Alta

**Criar:** `packages/api-client/src/hooks/use-pilots.ts`

**Implementar hooks:**
- [ ] `usePilots(params?)`
- [ ] `usePilot(id)`
- [ ] `useCreatePilot()`
- [ ] `useUpdatePilot(id)`
- [ ] `useDeletePilot()`
- [ ] Invalidação de cache

**Resultado:** Hooks de pilots funcionando.

---

### [ ] Tarefa #12: Hook de Auth (15min)
**Prioridade:** 🟡 Alta

**Criar:** `packages/api-client/src/hooks/use-auth.ts`

**Implementar:**
- [ ] `useLogin()` → POST /api/auth/login
  - [ ] Salvar token com `apiClient.setToken()`
  - [ ] Salvar user no cache
- [ ] `useLogout()`
  - [ ] Limpar token com `apiClient.clearToken()`
  - [ ] Limpar cache com `queryClient.clear()`

**Resultado:** Sistema de autenticação funcionando.

---

### [ ] Tarefa #13: Exports de Hooks (10min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/hooks/index.ts`

**Exportar:**
- [ ] Todos os hooks de drones
- [ ] Todos os hooks de plots
- [ ] Todos os hooks de pilots
- [ ] Hooks de auth
- [ ] Query keys

**Resultado:** Hooks acessíveis via `@repo/api-client/hooks`.

---

### [ ] Tarefa #14: Export Principal (10min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/index.ts`

**Exportar:**
- [ ] `{ ApiClient, FetchError }` from './client'
- [ ] `{ sdk, apiClient }` from './sdk'
- [ ] `type * from './types'`
- [ ] `* from './hooks'`

**Resultado:** API pública do pacote definida.

---

## ✅ FASE 4: Integração com Apps (1h 30min por app)

### [ ] Tarefa #15: Setup App web-admin (1h 30min)
**Prioridade:** 🟡 Alta

**1. Instalar dependências:**
```bash
cd apps/web-admin
npm install @tanstack/react-query@^5.59.0
npm install @tanstack/react-query-devtools@^5.59.0
```

**2. Adicionar ao package.json:**
- [ ] Adicionar `"@repo/api-client": "*"` em dependencies

**3. Criar Provider:**
- [ ] Criar `providers/query-provider.tsx`
- [ ] Implementar `QueryProvider` com `QueryClient`
- [ ] Adicionar `ReactQueryDevtools`

**4. Atualizar Layout:**
- [ ] Envolver app com `<QueryProvider>`

**5. Variáveis de ambiente:**
- [ ] Criar `.env.local`
- [ ] Adicionar `NEXT_PUBLIC_API_URL=http://localhost:3001`

**6. Testar:**
- [ ] Criar página de teste `/drones`
- [ ] Usar `useDrones()` hook
- [ ] Verificar dados carregando

**Resultado:** App admin integrado e funcionando.

---

### [ ] Tarefa #16: Setup App web-pilot (1h 30min)
**Prioridade:** 🟡 Alta

**Repetir passos da Tarefa #15:**
- [ ] Instalar dependências
- [ ] Adicionar ao package.json
- [ ] Criar Provider
- [ ] Atualizar Layout
- [ ] Configurar .env.local
- [ ] Criar página de teste

**Resultado:** App pilot integrado e funcionando.

---

### [ ] Tarefa #17: Setup App web-field (1h 30min)
**Prioridade:** 🟡 Alta

**Repetir passos da Tarefa #15:**
- [ ] Instalar dependências
- [ ] Adicionar ao package.json
- [ ] Criar Provider
- [ ] Atualizar Layout
- [ ] Configurar .env.local
- [ ] Criar página de teste

**Resultado:** App field integrado e funcionando.

---

## ✅ FASE 5: Páginas e Funcionalidades (2h)

### [ ] Tarefa #18: Página de Login (30min)
**Prioridade:** 🟡 Alta

**Criar:** `apps/web-admin/app/login/page.tsx`

**Implementar:**
- [ ] Form de login (email + password)
- [ ] Usar hook `useLogin()`
- [ ] Redirect após sucesso
- [ ] Exibir erros

**Testar:**
- [ ] Login com credenciais válidas
- [ ] Token salvo no localStorage
- [ ] Redirect para /drones

**Resultado:** Sistema de login funcionando.

---

### [ ] Tarefa #19: Página de Drones (30min)
**Prioridade:** 🟡 Alta

**Criar:** `apps/web-admin/app/drones/page.tsx`

**Implementar:**
- [ ] Listar drones com `useDrones()`
- [ ] Botão "Criar Drone" com `useCreateDrone()`
- [ ] Botão "Deletar" com `useDeleteDrone()`
- [ ] Loading states
- [ ] Error states

**Testar:**
- [ ] Listagem carrega
- [ ] Criar drone funciona
- [ ] Cache atualiza automaticamente
- [ ] Deletar funciona

**Resultado:** CRUD de drones completo.

---

### [ ] Tarefa #20: Página de Talhões (30min)
**Prioridade:** 🟢 Média

**Criar:** `apps/web-admin/app/plots/page.tsx`

**Implementar:**
- [ ] Listar talhões com `usePlots()`
- [ ] Criar talhão
- [ ] Ver detalhes
- [ ] Editar talhão
- [ ] Deletar talhão

**Resultado:** CRUD de talhões completo.

---

### [ ] Tarefa #21: Página de Pilotos (30min)
**Prioridade:** 🟢 Média

**Criar:** `apps/web-admin/app/pilots/page.tsx`

**Implementar:**
- [ ] Listar pilotos com `usePilots()`
- [ ] Criar piloto
- [ ] Ver detalhes
- [ ] Editar piloto
- [ ] Deletar piloto

**Resultado:** CRUD de pilotos completo.

---

## ✅ FASE 6: Testes e Validação (1h)

### [ ] Tarefa #22: Testes Funcionais (1h)
**Prioridade:** 🟢 Média

**Testar fluxo completo:**
- [ ] Login em cada app
- [ ] CRUD de drones funcionando
- [ ] CRUD de plots funcionando
- [ ] CRUD de pilots funcionando
- [ ] Cache invalidando corretamente
- [ ] React Query DevTools funcionando
- [ ] Token persistindo entre refreshes
- [ ] Logout funcionando

**Verificar:**
- [ ] `npm run type-check` sem erros
- [ ] Console sem erros
- [ ] Network requests corretos
- [ ] Cache otimizado

**Resultado:** Sistema validado e funcionando.

---

## 📊 Resumo de Progresso

### Fase 1: Setup Inicial
- [ ] #1 Criar Pacote
- [ ] #2 Cliente HTTP
- [ ] #3 Types

### Fase 2: SDK
- [ ] #4 SDK Drones
- [ ] #5 SDK Plots
- [ ] #6 SDK Pilots
- [ ] #7 SDK Principal

### Fase 3: Hooks
- [ ] #8 Query Keys
- [ ] #9 Hooks Drones
- [ ] #10 Hooks Plots
- [ ] #11 Hooks Pilots
- [ ] #12 Hook Auth
- [ ] #13 Exports Hooks
- [ ] #14 Export Principal

### Fase 4: Integração
- [ ] #15 Setup web-admin
- [ ] #16 Setup web-pilot
- [ ] #17 Setup web-field

### Fase 5: Páginas
- [ ] #18 Página Login
- [ ] #19 Página Drones
- [ ] #20 Página Plots
- [ ] #21 Página Pilots

### Fase 6: Validação
- [ ] #22 Testes Funcionais

---

## 🎯 Progresso Geral

```
Total de Tarefas: 22
Concluídas: 0/22 (0%)

Fase 1: [░░░░░] 0/3
Fase 2: [░░░░░] 0/4
Fase 3: [░░░░░] 0/7
Fase 4: [░░░░░] 0/3
Fase 5: [░░░░░] 0/4
Fase 6: [░░░░░] 0/1
```

---

## ⏱️ Tempo por Fase

| Fase | Tarefas | Tempo |
|------|---------|-------|
| 1. Setup Inicial | 3 | 1h |
| 2. SDK | 4 | 1h 30min |
| 3. Hooks | 7 | 2h |
| 4. Integração Apps | 3 | 4h 30min |
| 5. Páginas | 4 | 2h |
| 6. Validação | 1 | 1h |
| **TOTAL** | **22** | **12h** |

*Tempo reduzido se usar script e código pronto: **6-8h***

---

## 🚀 Começar Agora

1. **Execute o script:**
```bash
chmod +x setup-api-client.sh
./setup-api-client.sh
```

2. **Copie o código:**
Abra `CODIGO_PRONTO_COPIAR.md` e copie arquivo por arquivo.

3. **Marque as tarefas:**
Use este arquivo para acompanhar seu progresso.

---

## 📚 Referências

- **Código pronto:** `CODIGO_PRONTO_COPIAR.md`
- **Guia passo a passo:** `START_HERE.md`
- **Arquitetura detalhada:** `PLANO_MONOREPO_TURBOREPO.md`

---

**Boa sorte! 🚀**
