# 📋 Tarefas - Implementação API Client

**Monorepo Turborepo + Drones Agrícolas + Jest**  
**Tempo Total:** 8-10 horas

---

## ✅ FASE 1: Setup Inicial (1h 30min)

### [ ] Tarefa #1: Criar Workspace api-client (20min)
**Prioridade:** 🔴 Crítica

**Opção 1: Usar Turbo CLI (Recomendado)** ⚡
```bash
cd seu-monorepo

# Criar workspace com Turbo
turbo gen workspace --name api-client --type package --destination packages

# Criar estrutura de pastas
mkdir -p packages/api-client/src/{client,sdk,hooks,types}
mkdir -p packages/api-client/__tests__/{client,sdk,hooks,types}
```

**Opção 2: Script Automático** 🚀
```bash
chmod +x setup-api-client.sh
./setup-api-client.sh
```

**Configurar package.json:**
```json
{
  "name": "@repo/api-client",
  "version": "0.0.1",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "type-check": "tsc --noEmit"
  }
}
```

**Instalar dependências (na raiz):**
```bash
cd packages/api-client

# Adicionar ao package.json
pnpm add @tanstack/react-query@^5.59.0 qs@^6.13.0
pnpm add -D @types/qs@^6.9.16 typescript@^5.6.3
pnpm add -D jest@^29.7.0 @types/jest@^29.5.0 ts-jest@^29.1.0
pnpm add -D @testing-library/react@^14.0.0
pnpm add -D @testing-library/jest-dom@^6.1.0
pnpm add -D @testing-library/react-hooks@^8.0.1

# Voltar para raiz e instalar tudo
cd ../..
pnpm install
```

**Criar arquivos:**
- [ ] `jest.config.js` com preset ts-jest
- [ ] `jest.setup.js` com mocks
- [ ] `tsconfig.json`
- [ ] `.gitignore`

**Verificar:**
```bash
# Ver workspace criado
turbo run build --dry-run

# Deve aparecer api-client na lista
```

**Resultado:** Workspace criado e configurado no Turborepo.

---

### [ ] Tarefa #2: Cliente HTTP com Auth JWT (45min)
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

**Criar testes:** `packages/api-client/__tests__/client/index.test.ts`

**Testar:**
- [ ] `ApiClient` inicializa corretamente
- [ ] `setToken()` salva token no localStorage
- [ ] `getToken()` recupera token
- [ ] `clearToken()` remove token
- [ ] `fetch()` adiciona Authorization header quando tem token
- [ ] `fetch()` serializa query params corretamente
- [ ] `FetchError` captura erros da API
- [ ] Requests com body são stringified

**Rodar testes:**
```bash
pnpm test client/index.test.ts
```

**Resultado:** Cliente HTTP funcionando com JWT + testes passando.

---

### [ ] Tarefa #3: TypeScript Types (20min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/types/index.ts`

**Definir interfaces:**
- [ ] `PaginatedResponse<T>`
- [ ] `Drone` + `DroneList` + `CreateDrone`
- [ ] `Plot` + `PlotList` + `CreatePlot`
- [ ] `Pilot` + `PilotList` + `CreatePilot`

**Criar testes:** `packages/api-client/__tests__/types/index.test.ts`

**Testar:**
- [ ] Types exportam corretamente
- [ ] Interfaces têm propriedades corretas
- [ ] Omit<> funciona em CreateDrone/CreatePlot/CreatePilot
- [ ] PaginatedResponse é genérico

**Rodar testes:**
```bash
pnpm test types/index.test.ts
```

**Verificar tipos:**
```bash
pnpm tsc --noEmit
```

**Resultado:** Tipos TypeScript completos + validados.

---

## ✅ FASE 2: SDK (2h 30min)

### [ ] Tarefa #4: SDK de Drones (45min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/sdk/drones.ts`

**Implementar classe `DronesApi`:**
- [ ] `list(params?)` → GET /api/drones
- [ ] `get(id)` → GET /api/drones/:id
- [ ] `create(data)` → POST /api/drones
- [ ] `update(id, data)` → PATCH /api/drones/:id
- [ ] `delete(id)` → DELETE /api/drones/:id

**Criar testes:** `packages/api-client/__tests__/sdk/drones.test.ts`

**Testar:**
- [ ] `list()` chama `/api/drones` com query params
- [ ] `get(id)` chama `/api/drones/:id`
- [ ] `create(data)` faz POST com body correto
- [ ] `update(id, data)` faz PATCH com body correto
- [ ] `delete(id)` faz DELETE no endpoint correto
- [ ] Todos os métodos usam `client.fetch()`

**Rodar testes:**
```bash
pnpm test sdk/drones.test.ts
```

**Resultado:** CRUD de drones funcionando + testes passando.

---

### [ ] Tarefa #5: SDK de Plots (Talhões) (45min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/sdk/plots.ts`

**Implementar classe `PlotsApi`:**
- [ ] `list(params?)`
- [ ] `get(id)`
- [ ] `create(data)`
- [ ] `update(id, data)`
- [ ] `delete(id)`

**Criar testes:** `packages/api-client/__tests__/sdk/plots.test.ts`

**Testar:**
- [ ] Todos os métodos CRUD funcionando
- [ ] Endpoints corretos chamados
- [ ] Query params serializados

**Rodar testes:**
```bash
pnpm test sdk/plots.test.ts
```

**Resultado:** CRUD de plots funcionando + testes passando.

---

### [ ] Tarefa #6: SDK de Pilots (Pilotos) (45min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/sdk/pilots.ts`

**Implementar classe `PilotsApi`:**
- [ ] `list(params?)`
- [ ] `get(id)`
- [ ] `create(data)`
- [ ] `update(id, data)`
- [ ] `delete(id)`

**Criar testes:** `packages/api-client/__tests__/sdk/pilots.test.ts`

**Testar:**
- [ ] Todos os métodos CRUD funcionando
- [ ] Endpoints corretos chamados
- [ ] Body serializado corretamente

**Rodar testes:**
```bash
pnpm test sdk/pilots.test.ts
```

**Resultado:** CRUD de pilots funcionando + testes passando.

---

### [ ] Tarefa #7: SDK Principal (30min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/sdk/index.ts`

**Implementar:**
- [ ] Classe `ApiSDK`
- [ ] Integrar `DronesApi`, `PlotsApi`, `PilotsApi`
- [ ] Exportar instância singleton `sdk`
- [ ] Exportar `apiClient`

**Criar testes:** `packages/api-client/__tests__/sdk/index.test.ts`

**Testar:**
- [ ] `ApiSDK` inicializa com todas as APIs
- [ ] `sdk.drones` é instância de `DronesApi`
- [ ] `sdk.plots` é instância de `PlotsApi`
- [ ] `sdk.pilots` é instância de `PilotsApi`
- [ ] Singleton funciona corretamente

**Rodar testes:**
```bash
pnpm test sdk/index.test.ts
```

**Resultado:** SDK completo e funcional + testes passando.

---

## ✅ FASE 3: React Query Hooks (3h)

### [ ] Tarefa #8: Query Keys (25min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/hooks/query-keys.ts`

**Implementar:**
- [ ] Factory `createQueryKeys<T>`
- [ ] `dronesKeys` → all, lists(), list(params), details(), detail(id)
- [ ] `plotsKeys`
- [ ] `pilotsKeys`

**Criar testes:** `packages/api-client/__tests__/hooks/query-keys.test.ts`

**Testar:**
- [ ] `createQueryKeys()` gera estrutura correta
- [ ] `dronesKeys.all` retorna `['drones']`
- [ ] `dronesKeys.lists()` retorna `['drones', 'list']`
- [ ] `dronesKeys.list(params)` inclui params no array
- [ ] `dronesKeys.detail(id)` retorna `['drones', 'detail', id]`
- [ ] Keys são readonly e const

**Rodar testes:**
```bash
pnpm test hooks/query-keys.test.ts
```

**Resultado:** Sistema de query keys hierárquico + testes passando.

---

### [ ] Tarefa #9: Hooks de Drones (50min)
**Prioridade:** 🟡 Alta

**Criar:** `packages/api-client/src/hooks/use-drones.ts`

**Implementar hooks:**
- [ ] `useDrones(params?)` → useQuery
- [ ] `useDrone(id)` → useQuery (enabled: !!id)
- [ ] `useCreateDrone()` → useMutation
- [ ] `useUpdateDrone(id)` → useMutation
- [ ] `useDeleteDrone()` → useMutation

**Adicionar invalidação de cache:**
- [ ] Create → invalidar `lists()`
- [ ] Update → invalidar `lists()` + `detail(id)`
- [ ] Delete → invalidar `lists()` + `detail(id)`

**Criar testes:** `packages/api-client/__tests__/hooks/use-drones.test.tsx`

**Testar com @testing-library/react-hooks:**
- [ ] `useDrones()` chama `sdk.drones.list()`
- [ ] `useDrone(id)` chama `sdk.drones.get(id)`
- [ ] `useDrone()` desabilitado quando id é vazio
- [ ] `useCreateDrone().mutate()` chama `sdk.drones.create()`
- [ ] `useCreateDrone()` invalida cache após sucesso
- [ ] `useUpdateDrone(id).mutate()` invalida caches corretos
- [ ] `useDeleteDrone().mutate()` invalida caches

**Rodar testes:**
```bash
pnpm test hooks/use-drones.test.tsx
```

**Resultado:** Hooks de drones funcionando + testes passando.

---

### [ ] Tarefa #10: Hooks de Plots (50min)
**Prioridade:** 🟡 Alta

**Criar:** `packages/api-client/src/hooks/use-plots.ts`

**Implementar hooks:**
- [ ] `usePlots(params?)`
- [ ] `usePlot(id)`
- [ ] `useCreatePlot()`
- [ ] `useUpdatePlot(id)`
- [ ] `useDeletePlot()`
- [ ] Invalidação de cache

**Criar testes:** `packages/api-client/__tests__/hooks/use-plots.test.tsx`

**Testar:**
- [ ] Todos os hooks chamam SDK corretamente
- [ ] Cache invalidation funciona
- [ ] enabled: !!id em `usePlot()`

**Rodar testes:**
```bash
pnpm test hooks/use-plots.test.tsx
```

**Resultado:** Hooks de plots funcionando + testes passando.

---

### [ ] Tarefa #11: Hooks de Pilots (50min)
**Prioridade:** 🟡 Alta

**Criar:** `packages/api-client/src/hooks/use-pilots.ts`

**Implementar hooks:**
- [ ] `usePilots(params?)`
- [ ] `usePilot(id)`
- [ ] `useCreatePilot()`
- [ ] `useUpdatePilot(id)`
- [ ] `useDeletePilot()`
- [ ] Invalidação de cache

**Criar testes:** `packages/api-client/__tests__/hooks/use-pilots.test.tsx`

**Testar:**
- [ ] Todos os hooks chamam SDK corretamente
- [ ] Mutations invalidam cache apropriadamente

**Rodar testes:**
```bash
pnpm test hooks/use-pilots.test.tsx
```

**Resultado:** Hooks de pilots funcionando + testes passando.

---

### [ ] Tarefa #12: Hook de Auth (30min)
**Prioridade:** 🟡 Alta

**Criar:** `packages/api-client/src/hooks/use-auth.ts`

**Implementar:**
- [ ] `useLogin()` → POST /api/auth/login
  - [ ] Salvar token com `apiClient.setToken()`
  - [ ] Salvar user no cache
- [ ] `useLogout()`
  - [ ] Limpar token com `apiClient.clearToken()`
  - [ ] Limpar cache com `queryClient.clear()`

**Criar testes:** `packages/api-client/__tests__/hooks/use-auth.test.tsx`

**Testar:**
- [ ] `useLogin()` chama `/api/auth/login`
- [ ] Token é salvo após login bem-sucedido
- [ ] User data é salva no cache
- [ ] `useLogout()` limpa token
- [ ] `useLogout()` limpa todo o cache

**Rodar testes:**
```bash
pnpm test hooks/use-auth.test.tsx
```

**Resultado:** Sistema de autenticação funcionando + testes passando.

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

**Verificar:**
```bash
pnpm tsc --noEmit
```

**Resultado:** Hooks acessíveis via `@repo/api-client/hooks`.

---

### [ ] Tarefa #14: Export Principal (15min)
**Prioridade:** 🔴 Crítica

**Criar:** `packages/api-client/src/index.ts`

**Exportar:**
- [ ] `{ ApiClient, FetchError }` from './client'
- [ ] `{ sdk, apiClient }` from './sdk'
- [ ] `type * from './types'`
- [ ] `* from './hooks'`

**Rodar todos os testes:**
```bash
pnpm test
```

**Coverage:**
```bash
pnpm test --coverage
```

**Build do pacote:**
```bash
pnpm build
```

**Resultado:** API pública do pacote definida + todos os testes passando.

---

## ✅ FASE 4: Integração com Apps (1h 30min por app)

### [ ] Tarefa #15: Setup App web-admin (1h 30min)
**Prioridade:** 🟡 Alta

**1. Adicionar ao package.json:**
```json
{
  "dependencies": {
    "@repo/api-client": "workspace:*",
    "@tanstack/react-query": "^5.59.0",
    "@tanstack/react-query-devtools": "^5.59.0"
  }
}
```

**2. Instalar dependências (na raiz do monorepo):**
```bash
pnpm install
```

**3. Criar Provider:** `apps/web-admin/providers/query-provider.tsx`
- [ ] Implementar `QueryProvider` com `QueryClient`
- [ ] Adicionar `ReactQueryDevtools`
- [ ] Configurar defaultOptions (staleTime, refetchOnWindowFocus)

**4. Atualizar Layout:** `apps/web-admin/app/layout.tsx`
- [ ] Envolver app com `<QueryProvider>`
- [ ] Marcar como 'use client' se necessário

**5. Variáveis de ambiente:** `apps/web-admin/.env.local`
```bash
NEXT_PUBLIC_API_URL=http://localhost:3001
```

**6. Testar:**
- [ ] Criar página de teste `app/test-api/page.tsx`
- [ ] Usar `useDrones()` hook
- [ ] Verificar React Query DevTools funcionando

**7. Rodar app:**
```bash
pnpm --filter web-admin dev
# ou na raiz
turbo dev --filter=web-admin
```

**Resultado:** App admin integrado e funcionando.

---

### [ ] Tarefa #16: Setup App web-pilot (1h 30min)
**Prioridade:** 🟡 Alta

**Repetir passos da Tarefa #15:**
- [ ] Adicionar dependências ao `package.json`
- [ ] Criar `QueryProvider`
- [ ] Atualizar `Layout`
- [ ] Configurar `.env.local`
- [ ] Criar página de teste
- [ ] Rodar: `turbo dev --filter=web-pilot`

**Resultado:** App pilot integrado e funcionando.

---

### [ ] Tarefa #17: Setup App web-field (1h 30min)
**Prioridade:** 🟡 Alta

**Repetir passos da Tarefa #15:**
- [ ] Adicionar dependências ao `package.json`
- [ ] Criar `QueryProvider`
- [ ] Atualizar `Layout`
- [ ] Configurar `.env.local`
- [ ] Criar página de teste
- [ ] Rodar: `turbo dev --filter=web-field`

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

## ✅ FASE 6: Testes e Validação (1h 30min)

### [ ] Tarefa #22: Configurar Turbo para Testes (15min)
**Prioridade:** 🟢 Média

**Atualizar:** `turbo.json` (na raiz)

**Adicionar pipeline de test:**
```json
{
  "pipeline": {
    "test": {
      "outputs": ["coverage/**"],
      "dependsOn": ["^build"]
    },
    "test:watch": {
      "cache": false
    }
  }
}
```

**Rodar testes com Turbo:**
```bash
turbo test
turbo test --filter=api-client
```

**Resultado:** Testes integrados no Turborepo.

---

### [ ] Tarefa #23: Testes Funcionais (1h 15min)
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
```bash
# Type check
pnpm tsc --noEmit

# Lint
turbo lint

# Tests
turbo test

# Build
turbo build
```

**Checklist final:**
- [ ] Console sem erros
- [ ] Network requests corretos
- [ ] Cache otimizado
- [ ] Coverage > 70% no api-client
- [ ] Todos os testes unitários passando
- [ ] Builds sem warnings

**Resultado:** Sistema validado e funcionando.

---

## 📊 Resumo de Progresso

### Fase 1: Setup Inicial (1h 30min)
- [ ] #1 Criar Pacote + Jest
- [ ] #2 Cliente HTTP + Testes
- [ ] #3 Types + Testes

### Fase 2: SDK (2h 30min)
- [ ] #4 SDK Drones + Testes
- [ ] #5 SDK Plots + Testes
- [ ] #6 SDK Pilots + Testes
- [ ] #7 SDK Principal + Testes

### Fase 3: Hooks (3h)
- [ ] #8 Query Keys + Testes
- [ ] #9 Hooks Drones + Testes
- [ ] #10 Hooks Plots + Testes
- [ ] #11 Hooks Pilots + Testes
- [ ] #12 Hook Auth + Testes
- [ ] #13 Exports Hooks
- [ ] #14 Export Principal + Coverage

### Fase 4: Integração (4h 30min)
- [ ] #15 Setup web-admin
- [ ] #16 Setup web-pilot
- [ ] #17 Setup web-field

### Fase 5: Páginas (2h)
- [ ] #18 Página Login
- [ ] #19 Página Drones
- [ ] #20 Página Plots
- [ ] #21 Página Pilots

### Fase 6: Validação (1h 30min)
- [ ] #22 Turbo Test Config
- [ ] #23 Testes Funcionais

---

## 🎯 Progresso Geral

```
Total de Tarefas: 23
Concluídas: 0/23 (0%)

Fase 1: [░░░░░] 0/3 (1h 30min)
Fase 2: [░░░░░] 0/4 (2h 30min)
Fase 3: [░░░░░] 0/7 (3h)
Fase 4: [░░░░░] 0/3 (4h 30min)
Fase 5: [░░░░░] 0/4 (2h)
Fase 6: [░░░░░] 0/2 (1h 30min)
```

---

## ⏱️ Tempo por Fase

| Fase | Tarefas | Tempo | Com Testes |
|------|---------|-------|------------|
| 1. Setup Inicial | 3 | 1h 30min | ✅ Jest + Coverage |
| 2. SDK | 4 | 2h 30min | ✅ Unit Tests |
| 3. Hooks | 7 | 3h | ✅ React Hooks Testing |
| 4. Integração Apps | 3 | 4h 30min | - |
| 5. Páginas | 4 | 2h | - |
| 6. Validação | 2 | 1h 30min | ✅ E2E + Coverage |
| **TOTAL** | **23** | **15h** | **🎯 70%+ Coverage** |

*Tempo sem testes unitários: **10-12h***  
*Tempo com código pronto + sem testes: **6-8h***

---

## 🚀 Começar Agora

### 1. Execute o script de setup:
```bash
chmod +x setup-api-client.sh
./setup-api-client.sh
```

### 2. Instale dependências (na raiz):
```bash
pnpm install
```

### 3. Copie o código:
Abra `CODIGO_PRONTO_COPIAR.md` e copie arquivo por arquivo.

### 4. Configure Jest no pacote:
```bash
cd packages/api-client
pnpm add -D jest @types/jest ts-jest
pnpm add -D @testing-library/react @testing-library/jest-dom
pnpm add -D @testing-library/react-hooks
```

### 5. Adicione scripts no `package.json`:
```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "type-check": "tsc --noEmit"
  }
}
```

### 6. Marque as tarefas conforme avança:
Use este arquivo para acompanhar seu progresso.

---

## 🧪 Comandos Úteis

### Criar Workspace
```bash
# Criar novo pacote com Turbo CLI
turbo gen workspace --name api-client --type package --destination packages

# Criar novo app
turbo gen workspace --name web-admin --type app --destination apps
```

### Testes
```bash
# Rodar todos os testes
turbo test

# Rodar testes do api-client
turbo test --filter=api-client

# Com coverage
turbo test --filter=api-client -- --coverage

# Watch mode
pnpm --filter api-client test:watch

# Testar apenas mudanças
turbo test --filter='[main]'
```

### Desenvolvimento
```bash
# Rodar todos os apps
turbo dev

# Rodar app específico + deps
turbo dev --filter=web-admin...

# Múltiplos apps
turbo dev --filter=web-admin --filter=web-pilot

# Build tudo
turbo build

# Build específico
turbo build --filter=api-client

# Lint
turbo lint

# Type check em todos
turbo type-check
```

### Turborepo
```bash
# Ver estrutura e dependências
turbo run build --dry-run

# Ver grafo de dependências
turbo run build --graph

# Limpar cache
turbo run build --force

# Ver resumo de execução
turbo run build --summarize
```

### pnpm Workspace
```bash
# Adicionar dep em pacote específico
pnpm add react --filter=api-client

# Instalar tudo
pnpm install

# Ver workspaces
pnpm list -r --depth=-1

# Ver quem depende de X
pnpm why @repo/api-client
```

---

## 📚 Referências

- **Código pronto:** `CODIGO_PRONTO_COPIAR.md`
- **Guia passo a passo:** `START_HERE.md`
- **Arquitetura detalhada:** `PLANO_MONOREPO_TURBOREPO.md`
- **Testes:** Cada tarefa agora tem seção de testes unitários

---

## ✅ Checklist de Qualidade

Antes de considerar cada fase completa:

### Fase 1-3 (Pacote api-client):
- [ ] `pnpm test` passando com 70%+ coverage
- [ ] `pnpm type-check` sem erros
- [ ] `turbo build --filter=api-client` sem warnings

### Fase 4-5 (Apps):
- [ ] Apps rodando sem erros
- [ ] React Query DevTools visível
- [ ] Requests aparecendo no Network

### Fase 6 (Validação):
- [ ] `turbo test` todos passando
- [ ] `turbo build` sem erros
- [ ] `turbo lint` clean
- [ ] Coverage report gerado

---

**Boa sorte! 🚀 Com testes unitários você terá 70%+ de coverage!**
