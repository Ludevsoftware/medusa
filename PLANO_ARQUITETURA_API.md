# Plano de Arquitetura: Adaptação Medusa.js para Next.js

## 📋 Visão Geral

Este documento apresenta um plano estruturado para adaptar a excelente arquitetura de comunicação com API do Medusa.js para um projeto Next.js. O Medusa.js utiliza React Query de forma muito organizada, com padrões claros de:

- SDK client centralizado
- Query keys factories
- Hooks customizados por domínio
- Gerenciamento de cache inteligente
- Utilitários de URL e paginação

---

## 🎯 Issues / Tarefas

### **Issue #1: Core - Setup do Cliente HTTP (SDK)**

**Prioridade:** 🔴 Alta  
**Categoria:** Core  
**Estimativa:** 3-5 horas

#### Descrição
Criar a base do cliente HTTP que será usado para todas as comunicações com a API. Este cliente deve encapsular a lógica de fetch, gerenciamento de headers, autenticação e tratamento de erros.

#### Tarefas
- [ ] Criar classe `Client` em `/lib/api/client.ts`
- [ ] Implementar método `fetch` customizado com:
  - Gerenciamento de base URL
  - Injeção automática de headers (Authorization, Content-Type, etc)
  - Suporte a query parameters (usar biblioteca `qs`)
  - Tratamento de erros padronizado
- [ ] Criar classe `FetchError` customizada com status code
- [ ] Implementar suporte a diferentes tipos de autenticação:
  - Session (cookies)
  - JWT (Bearer token)
- [ ] Adicionar storage management para tokens:
  - localStorage
  - sessionStorage
  - custom storage
- [ ] Implementar interceptors para request/response
- [ ] Adicionar sistema de logging (debug mode)

#### Referências do Medusa
```typescript
// packages/core/js-sdk/src/client.ts
- Classe Client com fetch customizado
- Gerenciamento de storage de tokens
- Headers dinâmicos
- Normalização de requests/responses
```

#### Arquivos a criar
- `/lib/api/client.ts`
- `/lib/api/types.ts`
- `/lib/api/errors.ts`

---

### **Issue #2: Core - Query Client Configuration**

**Prioridade:** 🔴 Alta  
**Categoria:** Core  
**Estimativa:** 1-2 horas

#### Descrição
Configurar o React Query Client com opções otimizadas e criar o provider para a aplicação Next.js.

#### Tarefas
- [ ] Criar configuração do QueryClient em `/lib/api/query-client.ts`
- [ ] Configurar opções padrão:
  - `refetchOnWindowFocus: false`
  - `staleTime: 90000` (90 segundos)
  - `retry: 1`
- [ ] Criar QueryClientProvider wrapper para Next.js
- [ ] Adicionar suporte a Server Components (Next.js 13+)
- [ ] Configurar hydration entre server e client
- [ ] Adicionar DevTools do React Query (apenas em development)

#### Referências do Medusa
```typescript
// packages/admin/dashboard/src/lib/query-client.ts
- Configuração do QueryClient com opções otimizadas
```

#### Arquivos a criar
- `/lib/api/query-client.ts`
- `/providers/query-provider.tsx`
- `/app/providers.tsx` (para App Router)

---

### **Issue #3: Core - Query Key Factory**

**Prioridade:** 🔴 Alta  
**Categoria:** Core  
**Estimativa:** 2-3 horas

#### Descrição
Implementar o sistema de Query Key Factory que gera chaves consistentes e hierárquicas para o React Query, facilitando invalidação de cache e organização.

#### Tarefas
- [ ] Criar factory `queryKeysFactory` em `/lib/api/query-key-factory.ts`
- [ ] Implementar tipos TypeScript genéricos:
  - `TQueryKey<TKey, TListQuery, TDetailQuery>`
  - Suporte a queries customizadas
- [ ] Criar estrutura hierárquica de keys:
  - `all`: `[key]`
  - `lists()`: `[key, "list"]`
  - `list(query)`: `[key, "list", { query }]`
  - `details()`: `[key, "detail"]`
  - `detail(id, query)`: `[key, "detail", id, { query }]`
- [ ] Adicionar suporte a keys customizadas (preview, changes, etc)
- [ ] Documentar padrões de uso

#### Referências do Medusa
```typescript
// packages/admin/dashboard/src/lib/query-key-factory.ts
- queryKeysFactory com estrutura hierárquica
- Tipos TQueryKey genéricos
- Extensibilidade para keys customizadas
```

#### Arquivos a criar
- `/lib/api/query-key-factory.ts`

---

### **Issue #4: Core - SDK Base Classes**

**Prioridade:** 🔴 Alta  
**Categoria:** Core  
**Estimativa:** 3-4 horas

#### Descrição
Criar as classes base do SDK que encapsulam endpoints da API organizados por domínio (Products, Orders, Users, etc).

#### Tarefas
- [ ] Criar estrutura base em `/lib/api/sdk/`
- [ ] Implementar classe base `Resource` com métodos CRUD genéricos:
  - `list(query, headers)`
  - `retrieve(id, query, headers)`
  - `create(body, query, headers)`
  - `update(id, body, query, headers)`
  - `delete(id, headers)`
- [ ] Criar classe principal `SDK` que agrupa todos os recursos
- [ ] Implementar injeção do Client em cada Resource
- [ ] Adicionar tipagem TypeScript forte para requests/responses
- [ ] Criar exemplos de uso (Products, Orders)

#### Referências do Medusa
```typescript
// packages/core/js-sdk/src/admin/product.ts
- Classe Product com todos os métodos
- Uso do client.fetch
- Tipagem forte com HttpTypes
```

#### Arquivos a criar
- `/lib/api/sdk/base-resource.ts`
- `/lib/api/sdk/index.ts`
- `/lib/api/sdk/products.ts` (exemplo)
- `/lib/api/sdk/orders.ts` (exemplo)

---

### **Issue #5: Hooks - Base Hooks (useQuery & useMutation)**

**Prioridade:** 🟡 Média  
**Categoria:** Hooks  
**Estimativa:** 4-6 horas

#### Descrição
Criar hooks customizados que encapsulam React Query para queries (GET) e mutations (POST/PUT/DELETE), com lógica de invalidação de cache inteligente.

#### Tarefas
- [ ] Criar estrutura em `/hooks/api/`
- [ ] Implementar hooks de query por recurso:
  - `useResource(id, query, options)` - GET detail
  - `useResources(query, options)` - GET list
- [ ] Implementar hooks de mutation:
  - `useCreateResource(options)` - POST
  - `useUpdateResource(id, options)` - PUT/PATCH
  - `useDeleteResource(id, options)` - DELETE
- [ ] Adicionar invalidação automática de cache em mutations:
  - Invalidar listas após create/update/delete
  - Invalidar detail após update
- [ ] Implementar spread de data no retorno (`{ ...data, ...rest }`)
- [ ] Adicionar tipagem TypeScript completa
- [ ] Suporte a callbacks (onSuccess, onError)

#### Referências do Medusa
```typescript
// packages/admin/dashboard/src/hooks/api/products.tsx
- useProduct, useProducts - queries
- useCreateProduct, useUpdateProduct, useDeleteProduct - mutations
- Invalidação de cache inteligente
- Spread de data no retorno
```

#### Arquivos a criar
- `/hooks/api/use-base-query.ts`
- `/hooks/api/use-base-mutation.ts`
- `/hooks/api/products.tsx` (exemplo completo)

---

### **Issue #6: Hooks - Infinite Query Hook**

**Prioridade:** 🟡 Média  
**Categoria:** Hooks  
**Estimativa:** 2-3 horas

#### Descrição
Implementar hook genérico para infinite scroll/pagination usando `useInfiniteQuery` do React Query.

#### Tarefas
- [ ] Criar `useInfiniteList` em `/hooks/api/use-infinite-list.tsx`
- [ ] Implementar lógica genérica de paginação:
  - Suporte a offset/limit
  - Cálculo automático de `getNextPageParam`
  - Query key com sufixo `__infinite`
- [ ] Adicionar tipagem genérica para responses paginadas:
  - `PaginatedResponse<T>`
- [ ] Garantir separação de cache entre queries normais e infinite
- [ ] Adicionar exemplos de uso

#### Referências do Medusa
```typescript
// packages/admin/dashboard/src/hooks/use-infinite-list.tsx
- Hook genérico useInfiniteList
- Lógica de paginação automática
- Separação de query keys
```

#### Arquivos a criar
- `/hooks/api/use-infinite-list.tsx`
- `/types/pagination.ts`

---

### **Issue #7: Utils - Query Params Hook**

**Prioridade:** 🟡 Média  
**Categoria:** Utils  
**Estimativa:** 1-2 horas

#### Descrição
Criar hook para gerenciar query parameters da URL de forma tipada e com suporte a prefixos.

#### Tarefas
- [ ] Criar `useQueryParams` em `/hooks/use-query-params.tsx`
- [ ] Implementar leitura de múltiplos query params
- [ ] Adicionar suporte a prefixos (para evitar conflitos)
- [ ] Tipagem TypeScript forte
- [ ] Integração com Next.js Router
- [ ] Documentar padrões de uso

#### Referências do Medusa
```typescript
// packages/admin/dashboard/src/hooks/use-query-params.tsx
- Hook useQueryParams com tipagem
- Suporte a prefixos
```

#### Arquivos a criar
- `/hooks/use-query-params.tsx`

---

### **Issue #8: Utils - Data Table Hook**

**Prioridade:** 🟢 Baixa  
**Categoria:** Utils  
**Estimativa:** 3-4 horas

#### Descrição
Criar hook para gerenciar tabelas de dados com paginação, ordenação e seleção de linhas, integrado com query params da URL.

#### Tarefas
- [ ] Criar `useDataTable` em `/hooks/use-data-table.tsx`
- [ ] Integrar com TanStack Table
- [ ] Implementar paginação sincronizada com URL:
  - Parâmetro `offset` na URL
  - Sincronização bidirecional
- [ ] Adicionar suporte a:
  - Row selection
  - Expandable rows
  - Prefixos para múltiplas tabelas
- [ ] Calcular pageCount baseado em count total
- [ ] Adicionar tipagem genérica

#### Referências do Medusa
```typescript
// packages/admin/dashboard/src/hooks/use-data-table.tsx
- Hook useDataTable completo
- Integração com URL params
- Suporte a múltiplas features
```

#### Arquivos a criar
- `/hooks/use-data-table.tsx`

---

### **Issue #9: Organização - Estrutura de Pastas**

**Prioridade:** 🔴 Alta  
**Categoria:** Organização  
**Estimativa:** 1 hora

#### Descrição
Definir e criar a estrutura de pastas completa seguindo os padrões do Medusa.js adaptados para Next.js.

#### Tarefas
- [ ] Criar estrutura base:
```
/lib
  /api
    /sdk          # Classes do SDK por recurso
    client.ts     # Cliente HTTP
    errors.ts     # Error classes
    types.ts      # Tipos base
    query-client.ts
    query-key-factory.ts
/hooks
  /api            # Hooks de API por domínio
    products.tsx
    orders.tsx
    index.ts
  use-query-params.tsx
  use-data-table.tsx
  use-infinite-list.tsx
/types
  /api            # Types de API responses
/providers
  query-provider.tsx
```
- [ ] Criar arquivos `index.ts` para exports
- [ ] Documentar convenções de nomenclatura
- [ ] Adicionar READMEs em cada pasta principal

#### Arquivos a criar
- Estrutura completa de pastas
- READMEs de documentação

---

### **Issue #10: Hooks - Hooks por Domínio (Products)**

**Prioridade:** 🟡 Média  
**Categoria:** Hooks  
**Estimativa:** 3-4 horas

#### Descrição
Implementar hooks completos para o domínio de Products como exemplo de referência.

#### Tarefas
- [ ] Criar `/hooks/api/products.tsx`
- [ ] Implementar query keys:
  - `productsQueryKeys` com factory
- [ ] Implementar queries:
  - `useProduct(id, query, options)`
  - `useProducts(query, options)`
  - `useInfiniteProducts(query, options)`
- [ ] Implementar mutations:
  - `useCreateProduct(options)`
  - `useUpdateProduct(id, options)`
  - `useDeleteProduct(id, options)`
- [ ] Adicionar invalidação de cache inteligente
- [ ] Documentar com JSDoc
- [ ] Criar testes unitários

#### Referências do Medusa
```typescript
// packages/admin/dashboard/src/hooks/api/products.tsx
- Implementação completa de todos os hooks
- Padrão de invalidação de cache
```

#### Arquivos a criar
- `/hooks/api/products.tsx`
- `/hooks/api/products.test.tsx`

---

### **Issue #11: Hooks - Hooks por Domínio (Orders)**

**Prioridade:** 🟡 Média  
**Categoria:** Hooks  
**Estimativa:** 3-4 horas

#### Descrição
Implementar hooks completos para o domínio de Orders, incluindo queries customizadas (preview, changes, etc).

#### Tarefas
- [ ] Criar `/hooks/api/orders.tsx`
- [ ] Implementar query keys com extensões customizadas:
  - `ordersQueryKeys.preview(id)`
  - `ordersQueryKeys.changes(id)`
  - `ordersQueryKeys.lineItems(id)`
- [ ] Implementar queries:
  - `useOrder(id, query, options)`
  - `useOrders(query, options)`
  - `useOrderPreview(id, query, options)`
  - `useOrderChanges(id, query, options)`
- [ ] Implementar mutations:
  - `useUpdateOrder(id, options)`
  - `useCancelOrder(id, options)`
- [ ] Adicionar invalidação cruzada (orders → inventory)
- [ ] Documentar padrão de queries customizadas

#### Referências do Medusa
```typescript
// packages/admin/dashboard/src/hooks/api/orders.tsx
- Query keys customizadas
- Invalidação cruzada entre recursos
```

#### Arquivos a criar
- `/hooks/api/orders.tsx`

---

### **Issue #12: Utils - Error Handling & Toast**

**Prioridade:** 🟡 Média  
**Categoria:** Utils  
**Estimativa:** 2-3 horas

#### Descrição
Implementar sistema centralizado de tratamento de erros com feedback visual (toasts).

#### Tarefas
- [ ] Criar `/lib/api/error-handler.ts`
- [ ] Implementar parser de erros da API:
  - Status codes
  - Mensagens customizadas
  - Validação de campos
- [ ] Integrar com sistema de toasts (ex: sonner, react-hot-toast)
- [ ] Criar hook `useApiError()`
- [ ] Adicionar tratamento padrão em mutations
- [ ] Criar componente ErrorBoundary para React Query

#### Arquivos a criar
- `/lib/api/error-handler.ts`
- `/hooks/use-api-error.tsx`
- `/components/error-boundary.tsx`

---

### **Issue #13: Utils - URL Helpers**

**Prioridade:** 🟢 Baixa  
**Categoria:** Utils  
**Estimativa:** 1-2 horas

#### Descrição
Criar utilitários para manipulação de URLs, query strings e construção de endpoints.

#### Tarefas
- [ ] Criar `/lib/api/url-utils.ts`
- [ ] Implementar funções helper:
  - `buildUrl(base, path, params)`
  - `parseQueryString(search)`
  - `stringifyQueryParams(obj)`
- [ ] Integrar biblioteca `qs` para queries complexas
- [ ] Adicionar testes unitários

#### Arquivos a criar
- `/lib/api/url-utils.ts`
- `/lib/api/url-utils.test.ts`

---

### **Issue #14: Types - API Response Types**

**Prioridade:** 🔴 Alta  
**Categoria:** Types  
**Estimativa:** 2-3 horas

#### Descrição
Criar sistema de tipagem TypeScript para todas as responses da API.

#### Tarefas
- [ ] Criar estrutura em `/types/api/`
- [ ] Implementar tipos base:
  - `ApiResponse<T>`
  - `PaginatedResponse<T>`
  - `ErrorResponse`
- [ ] Criar tipos por domínio:
  - `Product`, `ProductListResponse`
  - `Order`, `OrderListResponse`
- [ ] Adicionar utility types:
  - `ApiParams<T>`
  - `MutationPayload<T>`
- [ ] Documentar convenções

#### Arquivos a criar
- `/types/api/base.ts`
- `/types/api/products.ts`
- `/types/api/orders.ts`
- `/types/api/index.ts`

---

### **Issue #15: Integration - Next.js App Router**

**Prioridade:** 🔴 Alta  
**Categoria:** Integration  
**Estimativa:** 2-3 horas

#### Descrição
Integrar toda a arquitetura com Next.js App Router, incluindo Server Components e Server Actions.

#### Tarefas
- [ ] Configurar Providers em `app/providers.tsx`
- [ ] Implementar hydration de queries do servidor:
  - `prefetchQuery` em Server Components
  - `dehydrate/hydrate` para cliente
- [ ] Criar exemplos de uso em Server Components
- [ ] Configurar Server Actions para mutations
- [ ] Adicionar tratamento de loading states
- [ ] Documentar padrões de uso

#### Arquivos a criar
- `/app/providers.tsx`
- `/app/layout.tsx` (configuração)
- `/lib/api/server-utils.ts`

---

### **Issue #16: Documentation - Guia de Uso**

**Prioridade:** 🟢 Baixa  
**Categoria:** Documentation  
**Estimativa:** 3-4 horas

#### Descrição
Criar documentação completa da arquitetura implementada.

#### Tarefas
- [ ] Criar `/docs/API_ARCHITECTURE.md`:
  - Visão geral da arquitetura
  - Fluxo de dados
  - Padrões e convenções
- [ ] Documentar cada hook com exemplos
- [ ] Criar guia de criação de novos recursos:
  - Como adicionar novo domínio
  - Como criar hooks customizados
- [ ] Adicionar diagramas (opcional)
- [ ] Criar cheatsheet de uso comum
- [ ] Exemplos de casos de uso complexos

#### Arquivos a criar
- `/docs/API_ARCHITECTURE.md`
- `/docs/USAGE_GUIDE.md`
- `/docs/EXAMPLES.md`

---

### **Issue #17: Testing - Setup de Testes**

**Prioridade:** 🟢 Baixa  
**Categoria:** Testing  
**Estimativa:** 3-4 horas

#### Descrição
Configurar ambiente de testes para hooks e SDK.

#### Tarefas
- [ ] Configurar Testing Library
- [ ] Criar wrappers para testes de hooks com React Query
- [ ] Implementar mocks do SDK/Client
- [ ] Criar testes para:
  - Client HTTP
  - Query Key Factory
  - Hooks principais
- [ ] Adicionar coverage reports
- [ ] Documentar padrões de teste

#### Arquivos a criar
- `/tests/setup.ts`
- `/tests/wrappers.tsx`
- `/tests/mocks/`

---

### **Issue #18: Performance - Otimizações**

**Prioridade:** 🟢 Baixa  
**Categoria:** Performance  
**Estimativa:** 2-3 horas

#### Descrição
Implementar otimizações de performance e cache.

#### Tarefas
- [ ] Configurar cache persistence (localStorage/sessionStorage)
- [ ] Implementar prefetching inteligente:
  - Hover prefetch
  - Route prefetch
- [ ] Adicionar debounce em searches
- [ ] Otimizar re-renders com `useCallback`/`useMemo`
- [ ] Implementar request deduplication
- [ ] Adicionar métricas de performance

#### Arquivos a criar
- `/lib/api/cache-persist.ts`
- `/hooks/use-prefetch.tsx`

---

## 📊 Resumo de Prioridades

### 🔴 Alta (Fazer Primeiro)
1. Issue #1 - Setup do Cliente HTTP (SDK)
2. Issue #2 - Query Client Configuration
3. Issue #3 - Query Key Factory
4. Issue #4 - SDK Base Classes
5. Issue #9 - Estrutura de Pastas
6. Issue #14 - API Response Types
7. Issue #15 - Next.js App Router Integration

### 🟡 Média (Fazer em Seguida)
8. Issue #5 - Base Hooks (useQuery & useMutation)
9. Issue #6 - Infinite Query Hook
10. Issue #7 - Query Params Hook
11. Issue #10 - Hooks de Products
12. Issue #11 - Hooks de Orders
13. Issue #12 - Error Handling & Toast

### 🟢 Baixa (Melhorias)
14. Issue #8 - Data Table Hook
15. Issue #13 - URL Helpers
16. Issue #16 - Documentation
17. Issue #17 - Testing Setup
18. Issue #18 - Performance Optimizations

---

## 🔄 Ordem de Implementação Sugerida

```
1. Estrutura de Pastas (#9)
2. Cliente HTTP (#1)
3. Query Client (#2)
4. Query Key Factory (#3)
5. API Types (#14)
6. SDK Base Classes (#4)
7. Base Hooks (#5)
8. Hooks de Products (#10) - Exemplo completo
9. Next.js Integration (#15)
10. Infinite Query (#6)
11. Query Params (#7)
12. Error Handling (#12)
13. Hooks de Orders (#11)
14. Data Table (#8)
15. URL Helpers (#13)
16. Testing (#17)
17. Documentation (#16)
18. Performance (#18)
```

---

## 🎨 Padrões e Convenções

### Nomenclatura de Hooks
- **Query**: `useResource`, `useResources`
- **Mutation**: `useCreateResource`, `useUpdateResource`, `useDeleteResource`
- **Infinite**: `useInfiniteResources`

### Estrutura de Query Keys
```typescript
resourceQueryKeys = {
  all: ['resource'],
  lists: () => ['resource', 'list'],
  list: (query) => ['resource', 'list', { query }],
  details: () => ['resource', 'detail'],
  detail: (id, query) => ['resource', 'detail', id, { query }]
}
```

### Invalidação de Cache
```typescript
// Após create
queryClient.invalidateQueries({ queryKey: resourceQueryKeys.lists() })

// Após update
queryClient.invalidateQueries({ queryKey: resourceQueryKeys.lists() })
queryClient.invalidateQueries({ queryKey: resourceQueryKeys.detail(id) })

// Após delete
queryClient.invalidateQueries({ queryKey: resourceQueryKeys.lists() })
queryClient.invalidateQueries({ queryKey: resourceQueryKeys.detail(id) })
```

---

## 📚 Referências do Medusa.js

### Arquivos Principais Analisados
1. `/packages/core/js-sdk/src/client.ts` - Cliente HTTP base
2. `/packages/core/js-sdk/src/admin/product.ts` - SDK de produtos
3. `/packages/admin/dashboard/src/lib/query-client.ts` - Configuração React Query
4. `/packages/admin/dashboard/src/lib/query-key-factory.ts` - Factory de keys
5. `/packages/admin/dashboard/src/hooks/api/products.tsx` - Hooks de produtos
6. `/packages/admin/dashboard/src/hooks/api/orders.tsx` - Hooks de orders
7. `/packages/admin/dashboard/src/hooks/use-infinite-list.tsx` - Infinite scroll
8. `/packages/admin/dashboard/src/hooks/use-data-table.tsx` - Data table
9. `/packages/admin/dashboard/src/hooks/use-query-params.tsx` - Query params

### Princípios da Arquitetura Medusa
1. **Separação de Responsabilidades**: SDK, Hooks e UI separados
2. **Tipagem Forte**: TypeScript em todo o código
3. **Cache Inteligente**: Invalidação estratégica de queries
4. **Extensibilidade**: Fácil adicionar novos recursos
5. **Developer Experience**: APIs intuitivas e consistentes

---

## 🚀 Próximos Passos

1. **Criar issues no GitHub** baseadas neste documento
2. **Atribuir labels**: `core`, `hooks`, `utils`, `documentation`
3. **Definir milestones**: MVP, Feature Complete, Production Ready
4. **Começar pela Issue #9** (Estrutura de Pastas)
5. **Implementar Issues Críticas** (#1-7, #14-15) primeiro
6. **Testar com domínio real** (Products ou Orders)
7. **Expandir para outros domínios**
8. **Adicionar testes e documentação**

---

## 💡 Benefícios desta Arquitetura

✅ **Organização**: Código limpo e fácil de navegar  
✅ **Manutenibilidade**: Padrões consistentes  
✅ **Performance**: Cache otimizado com React Query  
✅ **Type Safety**: TypeScript end-to-end  
✅ **Escalabilidade**: Fácil adicionar novos recursos  
✅ **DX**: Developer Experience excelente  
✅ **Testabilidade**: Código desacoplado e testável  
✅ **Produtividade**: Menos código boilerplate  

---

**Baseado na análise da arquitetura do Medusa.js v2**  
**Adaptado para Next.js 13+ (App Router)**  
**React Query v5**
