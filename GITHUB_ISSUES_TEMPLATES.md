# Templates de Issues do GitHub

Cole cada issue abaixo diretamente no GitHub. Cada uma já está formatada com markdown do GitHub.

---

## 🔴 Issue #1: Core - Setup do Cliente HTTP (SDK)

```markdown
## 📋 Descrição

Criar a base do cliente HTTP que será usado para todas as comunicações com a API. Este cliente deve encapsular a lógica de fetch, gerenciamento de headers, autenticação e tratamento de erros.

## 🎯 Objetivos

- [ ] Criar classe `Client` em `/lib/api/client.ts`
- [ ] Implementar método `fetch` customizado
- [ ] Criar classe `FetchError` customizada
- [ ] Implementar suporte a diferentes tipos de autenticação (Session e JWT)
- [ ] Adicionar storage management para tokens
- [ ] Implementar interceptors para request/response
- [ ] Adicionar sistema de logging (debug mode)

## 📝 Tarefas Detalhadas

### 1. Estrutura Base
- Criar classe `Client` com configuração (`Config` interface)
- Implementar normalização de base URL
- Setup de headers padrão

### 2. Método Fetch Customizado
- Gerenciamento automático de headers
- Suporte a query parameters (usar biblioteca `qs`)
- Normalização de request body (JSON stringify)
- Tratamento de erros com status codes
- Parse automático de responses JSON

### 3. Sistema de Autenticação
- Suporte a Session (cookies com credentials: 'include')
- Suporte a JWT (Bearer token em headers)
- Storage de tokens:
  - localStorage
  - sessionStorage
  - memory (fallback)
- Métodos: `setToken()`, `getToken()`, `clearToken()`

### 4. Error Handling
- Classe `FetchError` estendendo `Error`
- Captura de status code e statusText
- Parse de mensagens de erro do servidor

### 5. Debug & Logging
- Sistema de logging opcional
- Logs de requests (URL, method, headers)
- Logs de responses (status)
- Sanitização de tokens em logs

## 📦 Arquivos a Criar

- `/lib/api/client.ts` - Classe Client principal
- `/lib/api/types.ts` - Interfaces e tipos
- `/lib/api/errors.ts` - Classe FetchError
- `/lib/api/index.ts` - Export e instância singleton

## 🔗 Referências

- Medusa.js Client: `packages/core/js-sdk/src/client.ts`
- Padrões de fetch API
- Biblioteca `qs` para query strings

## ✅ Critérios de Aceitação

- [ ] Cliente inicializa corretamente com configuração
- [ ] Requests HTTP funcionam com diferentes métodos (GET, POST, PUT, DELETE)
- [ ] Query parameters são corretamente serializados
- [ ] Erros da API são capturados e formatados
- [ ] Tokens JWT são persistidos e enviados corretamente
- [ ] Session cookies funcionam com credentials
- [ ] Logs aparecem apenas em modo debug

## 🏷️ Labels

`core`, `priority: high`, `infrastructure`

## ⏱️ Estimativa

3-5 horas
```

---

## 🔴 Issue #2: Core - Query Client Configuration

```markdown
## 📋 Descrição

Configurar o React Query Client com opções otimizadas e criar o provider para a aplicação Next.js.

## 🎯 Objetivos

- [ ] Criar configuração do QueryClient
- [ ] Configurar opções padrão otimizadas
- [ ] Criar QueryClientProvider wrapper para Next.js
- [ ] Adicionar suporte a Server Components (Next.js 13+)
- [ ] Configurar hydration entre server e client
- [ ] Adicionar DevTools do React Query

## 📝 Tarefas Detalhadas

### 1. Query Client Setup
```typescript
new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      staleTime: 90000, // 90 segundos
      retry: 1,
    },
  },
})
```

### 2. Provider para Next.js
- Criar `QueryProvider` como Client Component
- Wrapper do `QueryClientProvider`
- Adicionar React Query DevTools (apenas em dev)
- Integrar com outros providers da aplicação

### 3. Hydration (Server/Client)
- Suporte a `HydrationBoundary`
- Setup de `dehydrate/hydrate`
- Configuração no layout principal

### 4. DevTools
- Adicionar `@tanstack/react-query-devtools`
- Configurar apenas para ambiente de desenvolvimento
- `initialIsOpen: false`

## 📦 Arquivos a Criar

- `/lib/api/query-client.ts` - QueryClient instance
- `/providers/query-provider.tsx` - Provider wrapper
- `/app/providers.tsx` - Aggregador de providers
- Atualizar `/app/layout.tsx` - Incluir Providers

## 🔗 Referências

- Medusa.js: `packages/admin/dashboard/src/lib/query-client.ts`
- [React Query Docs](https://tanstack.com/query/latest)
- [Next.js App Router + React Query](https://tanstack.com/query/latest/docs/framework/react/guides/advanced-ssr)

## ✅ Critérios de Aceitação

- [ ] QueryClient configurado e funcionando
- [ ] Provider envolvendo toda a aplicação
- [ ] DevTools visíveis apenas em development
- [ ] Hydration funcionando entre server e client
- [ ] Sem warnings no console

## 🏷️ Labels

`core`, `priority: high`, `react-query`

## ⏱️ Estimativa

1-2 horas
```

---

## 🔴 Issue #3: Core - Query Key Factory

```markdown
## 📋 Descrição

Implementar o sistema de Query Key Factory que gera chaves consistentes e hierárquicas para o React Query, facilitando invalidação de cache e organização.

## 🎯 Objetivos

- [ ] Criar factory `queryKeysFactory`
- [ ] Implementar tipos TypeScript genéricos
- [ ] Criar estrutura hierárquica de keys
- [ ] Adicionar suporte a keys customizadas
- [ ] Documentar padrões de uso

## 📝 Tarefas Detalhadas

### 1. Estrutura Hierárquica
```typescript
{
  all: ['resource'],
  lists: () => ['resource', 'list'],
  list: (query) => ['resource', 'list', { query }],
  details: () => ['resource', 'detail'],
  detail: (id, query) => ['resource', 'detail', id, { query }]
}
```

### 2. Tipos Genéricos
- `TQueryKey<TKey, TListQuery, TDetailQuery>`
- Suporte a tipos customizados para queries
- Inferência de tipos automática

### 3. Extensibilidade
- Função `extendQueryKeys` para adicionar keys customizadas
- Exemplo: `preview`, `changes`, `lineItems` para orders

### 4. Filtro de Undefined
- Remover valores `undefined` das keys
- Manter consistência de cache

## 📦 Arquivos a Criar

- `/lib/api/query-key-factory.ts` - Factory principal

## 🔗 Referências

- Medusa.js: `packages/admin/dashboard/src/lib/query-key-factory.ts`
- [React Query Key Management](https://tkdodo.eu/blog/effective-react-query-keys)

## ✅ Critérios de Aceitação

- [ ] Factory cria keys consistentes
- [ ] Tipos TypeScript funcionando corretamente
- [ ] Fácil extensão para keys customizadas
- [ ] Documentação clara com exemplos
- [ ] Testes unitários passando

## 🏷️ Labels

`core`, `priority: high`, `typescript`, `react-query`

## ⏱️ Estimativa

2-3 horas
```

---

## 🔴 Issue #4: Core - SDK Base Classes

```markdown
## 📋 Descrição

Criar as classes base do SDK que encapsulam endpoints da API organizados por domínio (Products, Orders, Users, etc).

## 🎯 Objetivos

- [ ] Criar estrutura base em `/lib/api/sdk/`
- [ ] Implementar classe base `BaseResource`
- [ ] Criar classe principal `SDK`
- [ ] Implementar exemplos (Products, Orders)
- [ ] Adicionar tipagem TypeScript forte

## 📝 Tarefas Detalhadas

### 1. BaseResource Class
```typescript
class BaseResource {
  protected client: Client
  protected basePath: string
  
  // Métodos helper
  protected buildPath(...segments: string[]): string
}
```

### 2. Resource Classes
- ProductsResource com CRUD completo
- OrdersResource como exemplo
- Métodos: `list`, `retrieve`, `create`, `update`, `delete`

### 3. SDK Aggregator
```typescript
class SDK {
  public products: ProductsResource
  public orders: OrdersResource
  
  constructor(client: Client) {}
}
```

### 4. Tipagem
- Interfaces para request/response de cada método
- Genéricos para reutilização
- Type safety end-to-end

## 📦 Arquivos a Criar

- `/lib/api/sdk/base-resource.ts` - Classe base
- `/lib/api/sdk/products.ts` - Resource de produtos
- `/lib/api/sdk/orders.ts` - Resource de orders
- `/lib/api/sdk/index.ts` - SDK principal

## 🔗 Referências

- Medusa.js: `packages/core/js-sdk/src/admin/product.ts`
- Padrão Resource/Repository

## ✅ Critérios de Aceitação

- [ ] SDK instancia corretamente
- [ ] Todos os métodos CRUD funcionando
- [ ] Tipagem TypeScript completa
- [ ] Paths de API construídos corretamente
- [ ] Integração com Client funcionando

## 🏷️ Labels

`core`, `priority: high`, `sdk`, `typescript`

## ⏱️ Estimativa

3-4 horas
```

---

## 🟡 Issue #5: Hooks - Base Hooks (useQuery & useMutation)

```markdown
## 📋 Descrição

Criar hooks customizados que encapsulam React Query para queries (GET) e mutations (POST/PUT/DELETE), com lógica de invalidação de cache inteligente.

## 🎯 Objetivos

- [ ] Criar estrutura em `/hooks/api/`
- [ ] Implementar hooks de query por recurso
- [ ] Implementar hooks de mutation
- [ ] Adicionar invalidação automática de cache
- [ ] Implementar spread de data no retorno

## 📝 Tarefas Detalhadas

### 1. Query Hooks
```typescript
useResource(id, query, options)     // GET detail
useResources(query, options)         // GET list
useInfiniteResources(query, options) // Infinite scroll
```

### 2. Mutation Hooks
```typescript
useCreateResource(options)  // POST
useUpdateResource(id, options) // PUT/PATCH
useDeleteResource(id, options) // DELETE
```

### 3. Cache Invalidation
- **Create**: Invalidar `lists()`
- **Update**: Invalidar `lists()` e `detail(id)`
- **Delete**: Invalidar `lists()` e `detail(id)`

### 4. Data Spreading
```typescript
const { data, ...rest } = useQuery(...)
return { ...data, ...rest }
```

### 5. Implementar para Products (Exemplo Completo)
- Todos os hooks de produto
- Documentação com JSDoc
- Exemplos de uso

## 📦 Arquivos a Criar

- `/hooks/api/products.tsx` - Hooks completos de produtos
- `/hooks/api/index.ts` - Exports

## 🔗 Referências

- Medusa.js: `packages/admin/dashboard/src/hooks/api/products.tsx`
- [React Query Mutations](https://tanstack.com/query/latest/docs/framework/react/guides/mutations)

## ✅ Critérios de Aceitação

- [ ] Hooks retornam dados corretamente
- [ ] Cache é invalidado após mutations
- [ ] Tipos TypeScript corretos
- [ ] Loading e error states funcionando
- [ ] Callbacks (onSuccess, onError) funcionando

## 🏷️ Labels

`hooks`, `priority: medium`, `react-query`

## ⏱️ Estimativa

4-6 horas
```

---

## 🟡 Issue #6: Hooks - Infinite Query Hook

```markdown
## 📋 Descrição

Implementar hook genérico para infinite scroll/pagination usando `useInfiniteQuery` do React Query.

## 🎯 Objetivos

- [ ] Criar `useInfiniteList` genérico
- [ ] Implementar lógica de paginação automática
- [ ] Adicionar tipagem para responses paginadas
- [ ] Garantir separação de cache
- [ ] Adicionar exemplos de uso

## 📝 Tarefas Detalhadas

### 1. Hook Genérico
```typescript
useInfiniteList<TResponse, TParams>({
  queryKey,
  queryFn,
  query,
  options
})
```

### 2. Lógica de Paginação
- `initialPageParam: 0`
- `getNextPageParam`: Calcular baseado em count/offset/limit
- Suporte a offset/limit
- Gerenciamento de `hasMore`

### 3. Query Key Separation
- Adicionar sufixo `__infinite` nas keys
- Prevenir conflito com queries normais
- Caches independentes

### 4. Tipos
```typescript
interface PaginatedResponse<T> {
  data: T[]
  count: number
  offset: number
  limit: number
}
```

## 📦 Arquivos a Criar

- `/hooks/api/use-infinite-list.tsx` - Hook principal
- `/types/pagination.ts` - Tipos de paginação

## 🔗 Referências

- Medusa.js: `packages/admin/dashboard/src/hooks/use-infinite-list.tsx`
- [React Query Infinite Queries](https://tanstack.com/query/latest/docs/framework/react/guides/infinite-queries)

## ✅ Critérios de Aceitação

- [ ] Hook funciona com infinite scroll
- [ ] Paginação automática correta
- [ ] Cache separado de queries normais
- [ ] Tipos genéricos funcionando
- [ ] Exemplo com produtos funcionando

## 🏷️ Labels

`hooks`, `priority: medium`, `react-query`, `pagination`

## ⏱️ Estimativa

2-3 horas
```

---

## 🟡 Issue #7: Utils - Query Params Hook

```markdown
## 📋 Descrição

Criar hook para gerenciar query parameters da URL de forma tipada e com suporte a prefixos.

## 🎯 Objetivos

- [ ] Criar `useQueryParams` tipado
- [ ] Implementar leitura de múltiplos params
- [ ] Adicionar suporte a prefixos
- [ ] Integração com Next.js Router
- [ ] Documentar padrões de uso

## 📝 Tarefas Detalhadas

### 1. Hook Base
```typescript
useQueryParams<T extends string>(
  keys: T[],
  prefix?: string
): QueryParams<T>
```

### 2. Funcionalidades
- Leitura tipada de query params
- Prefixos para evitar conflitos entre tabelas
- Retorno de objeto tipado
- Integração com `useSearchParams` do Next.js

### 3. Helper Adicional
```typescript
useQueryParam(key: string, prefix?: string): string | undefined
```

## 📦 Arquivos a Criar

- `/hooks/use-query-params.tsx` - Hook principal

## 🔗 Referências

- Medusa.js: `packages/admin/dashboard/src/hooks/use-query-params.tsx`
- [Next.js useSearchParams](https://nextjs.org/docs/app/api-reference/functions/use-search-params)

## ✅ Critérios de Aceitação

- [ ] Lê query params corretamente
- [ ] Prefixos funcionando
- [ ] Tipos TypeScript corretos
- [ ] Funciona com Next.js Router

## 🏷️ Labels

`utils`, `priority: medium`, `hooks`

## ⏱️ Estimativa

1-2 horas
```

---

## 🟢 Issue #8: Utils - Data Table Hook

```markdown
## 📋 Descrição

Criar hook para gerenciar tabelas de dados com paginação, ordenação e seleção de linhas, integrado com query params da URL.

## 🎯 Objetivos

- [ ] Criar `useDataTable` com TanStack Table
- [ ] Implementar paginação sincronizada com URL
- [ ] Adicionar suporte a row selection
- [ ] Suporte a expandable rows
- [ ] Prefixos para múltiplas tabelas

## 📝 Tarefas Detalhadas

### 1. Hook Base
```typescript
useDataTable<TData>({
  data,
  columns,
  count,
  pageSize,
  enablePagination,
  enableRowSelection,
  prefix
})
```

### 2. Paginação com URL
- Sincronização bidirecional
- Parâmetro `offset` na URL
- Cálculo de `pageIndex` e `pageCount`
- Navegação com router do Next.js

### 3. Features
- Row selection state
- Expandable rows (opcional)
- Sorting (futuro)
- Filtering (futuro)

### 4. Integração
- TanStack Table
- Next.js Router
- Query params com prefixo

## 📦 Arquivos a Criar

- `/hooks/use-data-table.tsx` - Hook principal

## 🔗 Referências

- Medusa.js: `packages/admin/dashboard/src/hooks/use-data-table.tsx`
- [TanStack Table](https://tanstack.com/table/latest)

## ✅ Critérios de Aceitação

- [ ] Tabela renderiza corretamente
- [ ] Paginação sincronizada com URL
- [ ] Navegação entre páginas funciona
- [ ] Row selection funciona (se habilitado)
- [ ] Suporte a múltiplas tabelas com prefixos

## 🏷️ Labels

`utils`, `priority: low`, `data-table`, `ui`

## ⏱️ Estimativa

3-4 horas
```

---

## 🔴 Issue #9: Organização - Estrutura de Pastas

```markdown
## 📋 Descrição

Definir e criar a estrutura de pastas completa seguindo os padrões do Medusa.js adaptados para Next.js.

## 🎯 Objetivos

- [ ] Criar estrutura base de pastas
- [ ] Criar arquivos `index.ts` para exports
- [ ] Documentar convenções de nomenclatura
- [ ] Adicionar READMEs em cada pasta principal

## 📝 Estrutura Completa

```
/app
  /products
    /[id]
      page.tsx
    page.tsx
  layout.tsx
  providers.tsx

/lib
  /api
    /sdk
      base-resource.ts
      products.ts
      orders.ts
      index.ts
    client.ts
    errors.ts
    types.ts
    query-client.ts
    query-key-factory.ts
    index.ts

/hooks
  /api
    products.tsx
    orders.tsx
    use-infinite-list.tsx
    index.ts
  use-query-params.tsx
  use-data-table.tsx
  index.ts

/types
  /api
    base.ts
    products.ts
    orders.ts
    index.ts

/providers
  query-provider.tsx
  index.ts

/components
  /ui
    ...
```

## 📝 Tarefas

- [ ] Criar todas as pastas
- [ ] Criar `index.ts` em cada pasta de módulo
- [ ] Adicionar `/docs/README.md` em pastas principais
- [ ] Definir convenções de nomenclatura
- [ ] Adicionar `.gitkeep` em pastas vazias

## 📦 Arquivos a Criar

- Estrutura completa de pastas
- Arquivos `index.ts`
- READMEs de documentação

## ✅ Critérios de Aceitação

- [ ] Todas as pastas criadas
- [ ] Estrutura segue padrões definidos
- [ ] READMEs documentando cada pasta
- [ ] Exports organizados

## 🏷️ Labels

`infrastructure`, `priority: high`, `organization`

## ⏱️ Estimativa

1 hora
```

---

## 🔴 Issue #14: Types - API Response Types

```markdown
## 📋 Descrição

Criar sistema de tipagem TypeScript para todas as responses da API.

## 🎯 Objetivos

- [ ] Criar estrutura em `/types/api/`
- [ ] Implementar tipos base
- [ ] Criar tipos por domínio
- [ ] Adicionar utility types
- [ ] Documentar convenções

## 📝 Tarefas Detalhadas

### 1. Tipos Base
```typescript
interface ApiResponse<T>
interface PaginatedResponse<T>
interface ErrorResponse
interface MutationResponse<T>
```

### 2. Tipos por Domínio

**Products:**
```typescript
interface Product
type ProductListResponse
type ProductResponse
interface CreateProductPayload
interface UpdateProductPayload
interface ProductListParams
```

**Orders:**
```typescript
interface Order
type OrderListResponse
type OrderResponse
// ... etc
```

### 3. Utility Types
```typescript
type ApiParams<T>
type MutationPayload<T>
type QueryOptions<T>
```

## 📦 Arquivos a Criar

- `/types/api/base.ts` - Tipos base
- `/types/api/products.ts` - Tipos de produtos
- `/types/api/orders.ts` - Tipos de orders
- `/types/api/index.ts` - Exports

## 🔗 Referências

- Medusa.js: `packages/core/types/`

## ✅ Critérios de Aceitação

- [ ] Tipos base definidos
- [ ] Tipos de produtos completos
- [ ] Tipos de orders completos
- [ ] Exports organizados
- [ ] Documentação com JSDoc

## 🏷️ Labels

`types`, `priority: high`, `typescript`

## ⏱️ Estimativa

2-3 horas
```

---

## 🟡 Issue #10: Hooks por Domínio - Products

```markdown
## 📋 Descrição

Implementar hooks completos para o domínio de Products como exemplo de referência.

## 🎯 Objetivos

- [ ] Criar query keys
- [ ] Implementar queries
- [ ] Implementar mutations
- [ ] Adicionar cache invalidation
- [ ] Documentar com JSDoc

## 📝 Hooks a Implementar

### Queries
- `useProduct(id, query, options)`
- `useProducts(query, options)`
- `useInfiniteProducts(query, options)`

### Mutations
- `useCreateProduct(options)`
- `useUpdateProduct(id, options)`
- `useDeleteProduct(id, options)`

### Query Keys
```typescript
export const productsQueryKeys = queryKeysFactory('products')
```

## 📦 Arquivos a Criar

- `/hooks/api/products.tsx` - Hooks completos
- `/hooks/api/products.test.tsx` - Testes (opcional)

## ✅ Critérios de Aceitação

- [ ] Todos os hooks funcionando
- [ ] Cache invalidation correta
- [ ] Tipos TypeScript completos
- [ ] Documentação clara
- [ ] Testes passando

## 🏷️ Labels

`hooks`, `priority: medium`, `products`

## ⏱️ Estimativa

3-4 horas
```

---

## 🟡 Issue #11: Hooks por Domínio - Orders

```markdown
## 📋 Descrição

Implementar hooks completos para o domínio de Orders, incluindo queries customizadas.

## 🎯 Objetivos

- [ ] Criar query keys com extensões
- [ ] Implementar queries padrão
- [ ] Implementar queries customizadas
- [ ] Implementar mutations
- [ ] Adicionar invalidação cruzada

## 📝 Hooks a Implementar

### Queries
- `useOrder(id, query, options)`
- `useOrders(query, options)`
- `useOrderPreview(id, query, options)`
- `useOrderChanges(id, query, options)`
- `useOrderLineItems(id, query, options)`

### Mutations
- `useUpdateOrder(id, options)`
- `useCancelOrder(id, options)`

### Query Keys Customizadas
```typescript
ordersQueryKeys.preview(id)
ordersQueryKeys.changes(id)
ordersQueryKeys.lineItems(id)
```

## 📦 Arquivos a Criar

- `/hooks/api/orders.tsx` - Hooks completos

## ✅ Critérios de Aceitação

- [ ] Queries customizadas funcionando
- [ ] Invalidação cruzada (orders → inventory)
- [ ] Documentação do padrão

## 🏷️ Labels

`hooks`, `priority: medium`, `orders`

## ⏱️ Estimativa

3-4 horas
```

---

## 🟡 Issue #12: Utils - Error Handling & Toast

```markdown
## 📋 Descrição

Implementar sistema centralizado de tratamento de erros com feedback visual.

## 🎯 Objetivos

- [ ] Criar error handler centralizado
- [ ] Integrar com sistema de toasts
- [ ] Criar hook `useApiError`
- [ ] Adicionar ErrorBoundary

## 📝 Tarefas Detalhadas

### 1. Error Parser
- Parse de status codes
- Mensagens customizadas por erro
- Validação de campos

### 2. Toast Integration
- Usar biblioteca: `sonner` ou `react-hot-toast`
- Toast automático em mutations
- Diferentes tipos: success, error, warning

### 3. Hook useApiError
```typescript
useApiError((error) => {
  toast.error(formatError(error))
})
```

### 4. ErrorBoundary
- Componente para React Query errors
- Fallback UI
- Retry logic

## 📦 Arquivos a Criar

- `/lib/api/error-handler.ts`
- `/hooks/use-api-error.tsx`
- `/components/error-boundary.tsx`

## ✅ Critérios de Aceitação

- [ ] Erros são formatados corretamente
- [ ] Toasts aparecem em mutations
- [ ] ErrorBoundary captura erros
- [ ] UX de erro adequada

## 🏷️ Labels

`utils`, `priority: medium`, `error-handling`, `ui`

## ⏱️ Estimativa

2-3 horas
```

---

## 🔴 Issue #15: Integration - Next.js App Router

```markdown
## 📋 Descrição

Integrar toda a arquitetura com Next.js App Router, incluindo Server Components e Server Actions.

## 🎯 Objetivos

- [ ] Configurar Providers
- [ ] Implementar hydration de queries
- [ ] Criar exemplos com Server Components
- [ ] Configurar Server Actions
- [ ] Documentar padrões

## 📝 Tarefas Detalhadas

### 1. Providers Setup
```typescript
// app/providers.tsx
<QueryProvider>
  {children}
</QueryProvider>
```

### 2. Hydration
- `prefetchQuery` em Server Components
- `dehydrate/hydrate` para cliente
- `HydrationBoundary` wrapper

### 3. Server Components
```typescript
// Prefetch no servidor
await queryClient.prefetchQuery({
  queryKey: productsQueryKeys.detail(id),
  queryFn: () => sdk.products.retrieve(id),
})
```

### 4. Server Actions
- Mutations usando Server Actions
- Revalidation de cache
- Error handling

## 📦 Arquivos a Criar

- `/app/providers.tsx`
- Atualizar `/app/layout.tsx`
- `/lib/api/server-utils.ts`

## 🔗 Referências

- [Next.js + React Query](https://tanstack.com/query/latest/docs/framework/react/guides/advanced-ssr)

## ✅ Critérios de Aceitação

- [ ] Providers funcionando
- [ ] Hydration sem warnings
- [ ] Prefetch em Server Components
- [ ] Server Actions funcionando
- [ ] Exemplos documentados

## 🏷️ Labels

`integration`, `priority: high`, `nextjs`, `ssr`

## ⏱️ Estimativa

2-3 horas
```

---

## 🟢 Issue #16: Documentation - Guia de Uso

```markdown
## 📋 Descrição

Criar documentação completa da arquitetura implementada.

## 🎯 Objetivos

- [ ] Criar guia de arquitetura
- [ ] Documentar cada hook
- [ ] Guia de criação de novos recursos
- [ ] Adicionar diagramas
- [ ] Criar cheatsheet

## 📝 Documentos a Criar

### 1. API_ARCHITECTURE.md
- Visão geral da arquitetura
- Fluxo de dados
- Padrões e convenções
- Diagramas (opcional)

### 2. USAGE_GUIDE.md
- Como usar cada hook
- Exemplos práticos
- Padrões comuns
- Troubleshooting

### 3. EXAMPLES.md
- Casos de uso completos
- Server Components
- Client Components
- Mutations
- Infinite scroll

### 4. CONTRIBUTING.md
- Como adicionar novo domínio
- Como criar hooks customizados
- Padrões de código
- Review checklist

## 📦 Arquivos a Criar

- `/docs/API_ARCHITECTURE.md`
- `/docs/USAGE_GUIDE.md`
- `/docs/EXAMPLES.md`
- `/docs/CONTRIBUTING.md`
- `/docs/CHEATSHEET.md`

## ✅ Critérios de Aceitação

- [ ] Documentação completa e clara
- [ ] Exemplos funcionando
- [ ] Diagramas (se aplicável)
- [ ] Fácil de seguir

## 🏷️ Labels

`documentation`, `priority: low`

## ⏱️ Estimativa

3-4 horas
```

---

## Labels Sugeridas para o Repositório

```
core
hooks
utils
types
sdk
integration
documentation
testing
priority: high
priority: medium
priority: low
react-query
nextjs
typescript
infrastructure
ui
error-handling
```

---

## Milestones Sugeridos

1. **MVP - Core Functionality** (Issues #1-#4, #9, #14)
2. **Feature Complete - Hooks** (Issues #5-#7, #10-#11)
3. **Production Ready** (Issues #12, #15-#18)

---

Cada issue pode ser copiada e colada diretamente no GitHub! 🚀
