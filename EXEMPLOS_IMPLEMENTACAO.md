# Exemplos de Implementação - Arquitetura API Next.js

Este documento contém exemplos práticos de código para cada issue do plano de arquitetura.

---

## Issue #1: Cliente HTTP (SDK)

### `/lib/api/client.ts`

```typescript
import { stringify } from 'qs'

export interface Config {
  baseUrl: string
  apiKey?: string
  auth?: {
    type: 'session' | 'jwt'
    jwtTokenStorageKey?: string
    jwtTokenStorageMethod?: 'local' | 'session' | 'memory'
  }
  globalHeaders?: Record<string, string>
  debug?: boolean
}

export interface FetchArgs extends RequestInit {
  query?: Record<string, any>
  body?: any
}

export class FetchError extends Error {
  status?: number
  statusText?: string

  constructor(message: string, statusText?: string, status?: number) {
    super(message)
    this.statusText = statusText
    this.status = status
    this.name = 'FetchError'
  }
}

export class Client {
  private config: Config
  private token: string = ''
  private DEFAULT_JWT_STORAGE_KEY = 'api_auth_token'

  constructor(config: Config) {
    this.config = {
      ...config,
      baseUrl: this.normalizeBaseUrl(config.baseUrl)
    }
  }

  private normalizeBaseUrl(url: string): string {
    if (typeof window === 'undefined') {
      return url
    }
    if (url === '' || url === '/') {
      return window.location.origin
    }
    return url
  }

  async fetch<T>(input: string, init?: FetchArgs): Promise<T> {
    const headers = new Headers({
      'content-type': 'application/json',
      'accept': 'application/json',
      ...this.config.globalHeaders,
      ...(await this.getAuthHeaders()),
      ...init?.headers,
    })

    // Construir URL com query params
    const url = new URL(input, this.config.baseUrl)
    if (init?.query) {
      const params = stringify(init.query, { skipNulls: true })
      url.search = params
    }

    // Preparar body
    let body = init?.body
    if (body && headers.get('content-type')?.includes('application/json')) {
      body = JSON.stringify(body)
    }

    if (this.config.debug) {
      console.log('API Request:', {
        url: url.toString(),
        method: init?.method || 'GET',
        headers: Object.fromEntries(headers.entries())
      })
    }

    // Fazer request
    const response = await fetch(url.toString(), {
      ...init,
      headers,
      body: body as BodyInit,
      credentials: this.config.auth?.type === 'session' ? 'include' : 'omit',
    })

    // Tratar erros
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new FetchError(
        errorData.message || response.statusText,
        response.statusText,
        response.status
      )
    }

    // Parse response
    const isJson = headers.get('accept')?.includes('application/json')
    return isJson ? await response.json() : response as any
  }

  private async getAuthHeaders(): Promise<Record<string, string>> {
    if (this.config.apiKey) {
      return {
        'Authorization': `Bearer ${this.config.apiKey}`
      }
    }

    if (this.config.auth?.type === 'jwt') {
      const token = await this.getToken()
      return token ? { 'Authorization': `Bearer ${token}` } : {}
    }

    return {}
  }

  async setToken(token: string) {
    const method = this.config.auth?.jwtTokenStorageMethod || 'local'
    const key = this.config.auth?.jwtTokenStorageKey || this.DEFAULT_JWT_STORAGE_KEY

    if (typeof window === 'undefined') {
      this.token = token
      return
    }

    switch (method) {
      case 'local':
        window.localStorage.setItem(key, token)
        break
      case 'session':
        window.sessionStorage.setItem(key, token)
        break
      case 'memory':
        this.token = token
        break
    }
  }

  async getToken(): Promise<string | null> {
    const method = this.config.auth?.jwtTokenStorageMethod || 'local'
    const key = this.config.auth?.jwtTokenStorageKey || this.DEFAULT_JWT_STORAGE_KEY

    if (typeof window === 'undefined') {
      return this.token || null
    }

    switch (method) {
      case 'local':
        return window.localStorage.getItem(key)
      case 'session':
        return window.sessionStorage.getItem(key)
      case 'memory':
        return this.token || null
    }
    return null
  }

  async clearToken() {
    const method = this.config.auth?.jwtTokenStorageMethod || 'local'
    const key = this.config.auth?.jwtTokenStorageKey || this.DEFAULT_JWT_STORAGE_KEY

    if (typeof window === 'undefined') {
      this.token = ''
      return
    }

    switch (method) {
      case 'local':
        window.localStorage.removeItem(key)
        break
      case 'session':
        window.sessionStorage.removeItem(key)
        break
      case 'memory':
        this.token = ''
        break
    }
  }
}
```

### `/lib/api/index.ts`

```typescript
import { Client } from './client'
import { SDK } from './sdk'

const backendUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

export const client = new Client({
  baseUrl: backendUrl,
  auth: {
    type: 'jwt',
    jwtTokenStorageKey: 'app_token',
    jwtTokenStorageMethod: 'local'
  },
  debug: process.env.NODE_ENV === 'development'
})

export const sdk = new SDK(client)

// Disponibilizar no console para debug
if (typeof window !== 'undefined') {
  ;(window as any).__sdk = sdk
  ;(window as any).__client = client
}
```

---

## Issue #2: Query Client Configuration

### `/lib/api/query-client.ts`

```typescript
import { QueryClient } from '@tanstack/react-query'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      staleTime: 90000, // 90 segundos
      retry: 1,
      refetchOnMount: false,
    },
    mutations: {
      retry: 0,
    },
  },
})
```

### `/providers/query-provider.tsx`

```typescript
'use client'

import { QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { queryClient } from '@/lib/api/query-client'
import { ReactNode } from 'react'

export function QueryProvider({ children }: { children: ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
      {process.env.NODE_ENV === 'development' && (
        <ReactQueryDevtools initialIsOpen={false} />
      )}
    </QueryClientProvider>
  )
}
```

### `/app/providers.tsx`

```typescript
'use client'

import { QueryProvider } from '@/providers/query-provider'
import { ReactNode } from 'react'

export function Providers({ children }: { children: ReactNode }) {
  return (
    <QueryProvider>
      {/* Adicione outros providers aqui */}
      {children}
    </QueryProvider>
  )
}
```

### `/app/layout.tsx`

```typescript
import { Providers } from './providers'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR">
      <body>
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  )
}
```

---

## Issue #3: Query Key Factory

### `/lib/api/query-key-factory.ts`

```typescript
import { QueryKey } from '@tanstack/react-query'

export type TQueryKey<TKey, TListQuery = any, TDetailQuery = string> = {
  all: readonly [TKey]
  lists: () => readonly [...TQueryKey<TKey>['all'], 'list']
  list: (
    query?: TListQuery
  ) => readonly [...ReturnType<TQueryKey<TKey>['lists']>, { query: TListQuery }]
  details: () => readonly [...TQueryKey<TKey>['all'], 'detail']
  detail: (
    id: TDetailQuery,
    query?: TListQuery
  ) => readonly [
    ...ReturnType<TQueryKey<TKey>['details']>,
    TDetailQuery,
    { query: TListQuery }
  ]
}

export const queryKeysFactory = <
  T,
  TListQueryType = any,
  TDetailQueryType = string
>(
  globalKey: T
) => {
  const queryKeyFactory: TQueryKey<T, TListQueryType, TDetailQueryType> = {
    all: [globalKey],
    lists: () => [...queryKeyFactory.all, 'list'],
    list: (query?: TListQueryType) =>
      [...queryKeyFactory.lists(), query ? { query } : undefined].filter(
        (k) => !!k
      ) as any,
    details: () => [...queryKeyFactory.all, 'detail'],
    detail: (id: TDetailQueryType, query?: TListQueryType) =>
      [...queryKeyFactory.details(), id, query ? { query } : undefined].filter(
        (k) => !!k
      ) as any,
  }
  return queryKeyFactory
}

// Exemplo de extensão para queries customizadas
export const extendQueryKeys = <T extends TQueryKey<any>>(
  baseKeys: T,
  extensions: Record<string, (...args: any[]) => QueryKey>
) => {
  return {
    ...baseKeys,
    ...extensions,
  }
}
```

### Exemplo de uso:

```typescript
import { queryKeysFactory, extendQueryKeys } from '@/lib/api/query-key-factory'

const ORDERS_QUERY_KEY = 'orders' as const
const _orderKeys = queryKeysFactory(ORDERS_QUERY_KEY)

// Extender com queries customizadas
export const ordersQueryKeys = extendQueryKeys(_orderKeys, {
  preview: (id: string) => [_orderKeys.detail(id), 'preview'],
  changes: (id: string) => [_orderKeys.detail(id), 'changes'],
  lineItems: (id: string) => [_orderKeys.detail(id), 'lineItems'],
})
```

---

## Issue #4: SDK Base Classes

### `/lib/api/sdk/base-resource.ts`

```typescript
import { Client } from '../client'

export class BaseResource {
  protected client: Client
  protected basePath: string

  constructor(client: Client, basePath: string) {
    this.client = client
    this.basePath = basePath
  }

  protected buildPath(...segments: string[]): string {
    return [this.basePath, ...segments].filter(Boolean).join('/')
  }
}
```

### `/lib/api/sdk/products.ts`

```typescript
import { BaseResource } from './base-resource'
import type {
  Product,
  ProductListResponse,
  ProductResponse,
  CreateProductPayload,
  UpdateProductPayload,
  ProductListParams,
} from '@/types/api/products'

export class ProductsResource extends BaseResource {
  constructor(client: Client) {
    super(client, '/api/products')
  }

  async list(params?: ProductListParams) {
    return this.client.fetch<ProductListResponse>(this.basePath, {
      query: params,
    })
  }

  async retrieve(id: string, params?: { fields?: string }) {
    return this.client.fetch<ProductResponse>(
      this.buildPath(id),
      { query: params }
    )
  }

  async create(payload: CreateProductPayload) {
    return this.client.fetch<ProductResponse>(this.basePath, {
      method: 'POST',
      body: payload,
    })
  }

  async update(id: string, payload: UpdateProductPayload) {
    return this.client.fetch<ProductResponse>(this.buildPath(id), {
      method: 'PATCH',
      body: payload,
    })
  }

  async delete(id: string) {
    return this.client.fetch<{ success: boolean }>(this.buildPath(id), {
      method: 'DELETE',
    })
  }
}
```

### `/lib/api/sdk/index.ts`

```typescript
import { Client } from '../client'
import { ProductsResource } from './products'
import { OrdersResource } from './orders'

export class SDK {
  public products: ProductsResource
  public orders: OrdersResource

  constructor(client: Client) {
    this.products = new ProductsResource(client)
    this.orders = new OrdersResource(client)
  }
}
```

---

## Issue #5: Base Hooks (useQuery & useMutation)

### `/hooks/api/products.tsx`

```typescript
'use client'

import {
  useQuery,
  useMutation,
  UseQueryOptions,
  UseMutationOptions,
  QueryKey,
} from '@tanstack/react-query'
import { sdk } from '@/lib/api'
import { queryClient } from '@/lib/api/query-client'
import { queryKeysFactory } from '@/lib/api/query-key-factory'
import { FetchError } from '@/lib/api/client'
import type {
  Product,
  ProductListResponse,
  ProductResponse,
  CreateProductPayload,
  UpdateProductPayload,
  ProductListParams,
} from '@/types/api/products'

// Query Keys
const PRODUCTS_QUERY_KEY = 'products' as const
export const productsQueryKeys = queryKeysFactory(PRODUCTS_QUERY_KEY)

// ============================================
// QUERIES
// ============================================

/**
 * Hook para buscar um produto por ID
 */
export const useProduct = (
  id: string,
  params?: { fields?: string },
  options?: Omit<
    UseQueryOptions<ProductResponse, FetchError, ProductResponse, QueryKey>,
    'queryFn' | 'queryKey'
  >
) => {
  const { data, ...rest } = useQuery({
    queryFn: () => sdk.products.retrieve(id, params),
    queryKey: productsQueryKeys.detail(id, params),
    enabled: !!id,
    ...options,
  })

  return { ...data, ...rest }
}

/**
 * Hook para buscar lista de produtos
 */
export const useProducts = (
  params?: ProductListParams,
  options?: Omit<
    UseQueryOptions<
      ProductListResponse,
      FetchError,
      ProductListResponse,
      QueryKey
    >,
    'queryFn' | 'queryKey'
  >
) => {
  const { data, ...rest } = useQuery({
    queryFn: () => sdk.products.list(params),
    queryKey: productsQueryKeys.list(params),
    ...options,
  })

  return { ...data, ...rest }
}

// ============================================
// MUTATIONS
// ============================================

/**
 * Hook para criar produto
 */
export const useCreateProduct = (
  options?: UseMutationOptions<
    ProductResponse,
    FetchError,
    CreateProductPayload
  >
) => {
  return useMutation({
    mutationFn: (payload: CreateProductPayload) =>
      sdk.products.create(payload),
    onSuccess: (data, variables, context) => {
      // Invalidar lista de produtos
      queryClient.invalidateQueries({
        queryKey: productsQueryKeys.lists(),
      })
      options?.onSuccess?.(data, variables, context)
    },
    ...options,
  })
}

/**
 * Hook para atualizar produto
 */
export const useUpdateProduct = (
  id: string,
  options?: UseMutationOptions<
    ProductResponse,
    FetchError,
    UpdateProductPayload
  >
) => {
  return useMutation({
    mutationFn: (payload: UpdateProductPayload) =>
      sdk.products.update(id, payload),
    onSuccess: (data, variables, context) => {
      // Invalidar lista e detalhe
      queryClient.invalidateQueries({
        queryKey: productsQueryKeys.lists(),
      })
      queryClient.invalidateQueries({
        queryKey: productsQueryKeys.detail(id),
      })
      options?.onSuccess?.(data, variables, context)
    },
    ...options,
  })
}

/**
 * Hook para deletar produto
 */
export const useDeleteProduct = (
  id: string,
  options?: UseMutationOptions<{ success: boolean }, FetchError, void>
) => {
  return useMutation({
    mutationFn: () => sdk.products.delete(id),
    onSuccess: (data, variables, context) => {
      queryClient.invalidateQueries({
        queryKey: productsQueryKeys.lists(),
      })
      queryClient.invalidateQueries({
        queryKey: productsQueryKeys.detail(id),
      })
      options?.onSuccess?.(data, variables, context)
    },
    ...options,
  })
}
```

---

## Issue #6: Infinite Query Hook

### `/hooks/api/use-infinite-list.tsx`

```typescript
'use client'

import {
  useInfiniteQuery,
  UseInfiniteQueryOptions,
  InfiniteData,
  QueryKey,
} from '@tanstack/react-query'
import { FetchError } from '@/lib/api/client'

export interface PaginatedResponse<T> {
  data: T[]
  count: number
  offset: number
  limit: number
}

interface UseInfiniteListParams<TParams> {
  queryKey: ((params: Omit<TParams, 'limit'>) => QueryKey) | QueryKey
  queryFn: (params: TParams) => Promise<PaginatedResponse<any>>
  query?: TParams
  options?: Omit<
    UseInfiniteQueryOptions<
      PaginatedResponse<any>,
      FetchError,
      InfiniteData<PaginatedResponse<any>, number>,
      PaginatedResponse<any>,
      QueryKey,
      number
    >,
    'queryKey' | 'queryFn' | 'initialPageParam' | 'getNextPageParam'
  >
}

export const useInfiniteList = <
  TResponse extends PaginatedResponse<unknown>,
  TParams extends { offset?: number; limit?: number } = {
    offset?: number
    limit?: number
  }
>({
  queryKey,
  queryFn,
  query,
  options,
}: UseInfiniteListParams<TParams>) => {
  const { limit = 50, offset: _, ...restQuery } = (query ?? {}) as any

  // Gerar query key
  const resolvedQueryKey =
    typeof queryKey === 'function'
      ? queryKey(restQuery as Omit<TParams, 'limit'>)
      : queryKey

  // Adicionar sufixo __infinite para separar do cache normal
  const infiniteQueryKey =
    resolvedQueryKey[resolvedQueryKey.length - 1] === '__infinite'
      ? resolvedQueryKey
      : ([...resolvedQueryKey, '__infinite'] as unknown as QueryKey)

  return useInfiniteQuery<
    TResponse,
    FetchError,
    InfiniteData<TResponse, number>,
    QueryKey,
    number
  >({
    queryKey: infiniteQueryKey,
    queryFn: ({ pageParam = 0 }) => {
      return queryFn({
        ...restQuery,
        limit,
        offset: pageParam,
      } as TParams)
    },
    initialPageParam: 0,
    getNextPageParam: (lastPage) => {
      const hasMore = lastPage.count > lastPage.offset + lastPage.limit
      return hasMore ? lastPage.offset + lastPage.limit : undefined
    },
    ...options,
  })
}
```

### Exemplo de uso com produtos:

```typescript
export const useInfiniteProducts = (
  params?: ProductListParams,
  options?: Omit<UseInfiniteQueryOptions<...>, 'queryKey' | 'queryFn' | ...>
) => {
  return useInfiniteList<ProductListResponse, ProductListParams>({
    queryKey: (params) => productsQueryKeys.list(params),
    queryFn: (params) => sdk.products.list(params),
    query: params,
    options,
  })
}
```

---

## Issue #7: Query Params Hook

### `/hooks/use-query-params.tsx`

```typescript
'use client'

import { useSearchParams } from 'next/navigation'

type QueryParams<T extends string> = {
  [key in T]: string | undefined
}

/**
 * Hook para ler query parameters da URL de forma tipada
 * 
 * @param keys - Array de chaves para extrair da URL
 * @param prefix - Prefixo opcional para as chaves (evita conflitos)
 * @returns Objeto com os valores dos query params
 * 
 * @example
 * ```tsx
 * const { search, page } = useQueryParams(['search', 'page'], 'products')
 * // URL: /products?products_search=test&products_page=2
 * // Result: { search: 'test', page: '2' }
 * ```
 */
export function useQueryParams<T extends string>(
  keys: T[],
  prefix?: string
): QueryParams<T> {
  const searchParams = useSearchParams()
  const result = {} as QueryParams<T>

  keys.forEach((key) => {
    const prefixedKey = prefix ? `${prefix}_${key}` : key
    const value = searchParams.get(prefixedKey) || undefined
    result[key] = value
  })

  return result
}

/**
 * Hook para ler um único query param
 */
export function useQueryParam(key: string, prefix?: string): string | undefined {
  const searchParams = useSearchParams()
  const prefixedKey = prefix ? `${prefix}_${key}` : key
  return searchParams.get(prefixedKey) || undefined
}
```

---

## Issue #8: Data Table Hook

### `/hooks/use-data-table.tsx`

```typescript
'use client'

import {
  ColumnDef,
  OnChangeFn,
  PaginationState,
  Row,
  RowSelectionState,
  getCoreRowModel,
  getPaginationRowModel,
  useReactTable,
} from '@tanstack/react-table'
import { useEffect, useMemo, useState } from 'react'
import { useSearchParams, useRouter, usePathname } from 'next/navigation'

interface UseDataTableProps<TData> {
  data?: TData[]
  columns: ColumnDef<TData, any>[]
  count?: number
  pageSize?: number
  enableRowSelection?: boolean | ((row: Row<TData>) => boolean)
  rowSelection?: {
    state: RowSelectionState
    updater: OnChangeFn<RowSelectionState>
  }
  enablePagination?: boolean
  getRowId?: (original: TData, index: number) => string
  meta?: Record<string, unknown>
  prefix?: string
}

export const useDataTable = <TData,>({
  data = [],
  columns,
  count = 0,
  pageSize: _pageSize = 20,
  enablePagination = true,
  enableRowSelection = false,
  rowSelection: _rowSelection,
  getRowId,
  meta,
  prefix,
}: UseDataTableProps<TData>) => {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  
  const offsetKey = `${prefix ? `${prefix}_` : ''}offset`
  const offset = searchParams.get(offsetKey)

  const [{ pageIndex, pageSize }, setPagination] = useState<PaginationState>({
    pageIndex: offset ? Math.ceil(Number(offset) / _pageSize) : 0,
    pageSize: _pageSize,
  })

  const pagination = useMemo(
    () => ({
      pageIndex,
      pageSize,
    }),
    [pageIndex, pageSize]
  )

  const [localRowSelection, setLocalRowSelection] = useState({})
  const rowSelection = _rowSelection?.state ?? localRowSelection
  const setRowSelection = _rowSelection?.updater ?? setLocalRowSelection

  // Sincronizar com URL
  useEffect(() => {
    if (!enablePagination) return

    const index = offset ? Math.ceil(Number(offset) / _pageSize) : 0
    if (index === pageIndex) return

    setPagination((prev) => ({
      ...prev,
      pageIndex: index,
    }))
  }, [offset, enablePagination, _pageSize, pageIndex])

  const onPaginationChange: OnChangeFn<PaginationState> = (updater) => {
    const state = typeof updater === 'function' ? updater(pagination) : updater
    const { pageIndex, pageSize } = state

    // Atualizar URL
    const params = new URLSearchParams(searchParams)
    if (!pageIndex) {
      params.delete(offsetKey)
    } else {
      params.set(offsetKey, String(pageIndex * pageSize))
    }

    router.push(`${pathname}?${params.toString()}`)
    setPagination(state)
  }

  const table = useReactTable({
    data,
    columns,
    state: {
      rowSelection,
      pagination: enablePagination ? pagination : undefined,
    },
    pageCount: Math.ceil((count ?? 0) / pageSize),
    enableRowSelection,
    getRowId,
    onRowSelectionChange: enableRowSelection ? setRowSelection : undefined,
    onPaginationChange: enablePagination ? onPaginationChange : undefined,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: enablePagination ? getPaginationRowModel() : undefined,
    manualPagination: enablePagination,
    meta,
  })

  return { table }
}
```

---

## Issue #14: API Response Types

### `/types/api/base.ts`

```typescript
export interface ApiResponse<T> {
  data: T
  message?: string
}

export interface PaginatedResponse<T> {
  data: T[]
  count: number
  offset: number
  limit: number
}

export interface ErrorResponse {
  error: string
  message: string
  statusCode: number
}

export interface MutationResponse<T> {
  success: boolean
  data: T
}
```

### `/types/api/products.ts`

```typescript
import { PaginatedResponse, ApiResponse } from './base'

export interface Product {
  id: string
  title: string
  description?: string
  price: number
  images?: string[]
  stock?: number
  createdAt: string
  updatedAt: string
}

export type ProductListResponse = PaginatedResponse<Product>
export type ProductResponse = ApiResponse<Product>

export interface CreateProductPayload {
  title: string
  description?: string
  price: number
  stock?: number
  images?: string[]
}

export interface UpdateProductPayload extends Partial<CreateProductPayload> {}

export interface ProductListParams {
  limit?: number
  offset?: number
  search?: string
  sortBy?: 'title' | 'price' | 'createdAt'
  sortOrder?: 'asc' | 'desc'
  fields?: string
}
```

---

## Exemplo de Uso Completo em um Componente

### `/app/products/page.tsx`

```typescript
'use client'

import { useProducts, useCreateProduct, useDeleteProduct } from '@/hooks/api/products'
import { useDataTable } from '@/hooks/use-data-table'
import { ColumnDef } from '@tanstack/react-table'
import { Product } from '@/types/api/products'
import { toast } from 'sonner'

const columns: ColumnDef<Product>[] = [
  {
    accessorKey: 'title',
    header: 'Nome',
  },
  {
    accessorKey: 'price',
    header: 'Preço',
    cell: ({ getValue }) => {
      const price = getValue() as number
      return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
      }).format(price)
    },
  },
  {
    id: 'actions',
    cell: ({ row }) => <ProductActions product={row.original} />,
  },
]

export default function ProductsPage() {
  // Buscar produtos com paginação
  const { data, count, isLoading } = useProducts({
    limit: 20,
    offset: 0,
  })

  // Setup da tabela
  const { table } = useDataTable({
    data: data || [],
    columns,
    count,
    pageSize: 20,
    enablePagination: true,
  })

  // Mutation para criar
  const createProduct = useCreateProduct({
    onSuccess: () => {
      toast.success('Produto criado com sucesso!')
    },
    onError: (error) => {
      toast.error(error.message)
    },
  })

  if (isLoading) return <div>Carregando...</div>

  return (
    <div>
      <h1>Produtos</h1>
      
      <button
        onClick={() =>
          createProduct.mutate({
            title: 'Novo Produto',
            price: 99.9,
          })
        }
      >
        Criar Produto
      </button>

      {/* Renderizar tabela */}
      <table>
        <thead>
          {table.getHeaderGroups().map((headerGroup) => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <th key={header.id}>
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                        header.column.columnDef.header,
                        header.getContext()
                      )}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map((row) => (
            <tr key={row.id}>
              {row.getVisibleCells().map((cell) => (
                <td key={cell.id}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>

      {/* Paginação */}
      <div>
        <button
          onClick={() => table.previousPage()}
          disabled={!table.getCanPreviousPage()}
        >
          Anterior
        </button>
        <span>
          Página {table.getState().pagination.pageIndex + 1} de{' '}
          {table.getPageCount()}
        </span>
        <button
          onClick={() => table.nextPage()}
          disabled={!table.getCanNextPage()}
        >
          Próxima
        </button>
      </div>
    </div>
  )
}

function ProductActions({ product }: { product: Product }) {
  const deleteProduct = useDeleteProduct(product.id, {
    onSuccess: () => {
      toast.success('Produto deletado!')
    },
  })

  return (
    <button onClick={() => deleteProduct.mutate()}>
      Deletar
    </button>
  )
}
```

---

## Exemplo de Server Component com Prefetch

### `/app/products/[id]/page.tsx`

```typescript
import { HydrationBoundary, dehydrate } from '@tanstack/react-query'
import { queryClient } from '@/lib/api/query-client'
import { sdk } from '@/lib/api'
import { productsQueryKeys } from '@/hooks/api/products'
import { ProductDetail } from './product-detail'

export default async function ProductPage({
  params,
}: {
  params: { id: string }
}) {
  // Prefetch no servidor
  await queryClient.prefetchQuery({
    queryKey: productsQueryKeys.detail(params.id),
    queryFn: () => sdk.products.retrieve(params.id),
  })

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <ProductDetail productId={params.id} />
    </HydrationBoundary>
  )
}
```

### `/app/products/[id]/product-detail.tsx`

```typescript
'use client'

import { useProduct } from '@/hooks/api/products'

export function ProductDetail({ productId }: { productId: string }) {
  // Dados já virão do cache (prefetch no servidor)
  const { data: product, isLoading } = useProduct(productId)

  if (isLoading) return <div>Carregando...</div>
  if (!product) return <div>Produto não encontrado</div>

  return (
    <div>
      <h1>{product.data.title}</h1>
      <p>{product.data.description}</p>
      <p>R$ {product.data.price}</p>
    </div>
  )
}
```

---

## Estrutura Final de Pastas

```
/app
  /products
    /[id]
      page.tsx          # Server Component com prefetch
      product-detail.tsx # Client Component com hook
    page.tsx            # Lista de produtos
  layout.tsx            # Layout com Providers
  providers.tsx         # Query Provider

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

/types
  /api
    base.ts
    products.ts
    orders.ts
    index.ts

/providers
  query-provider.tsx

/components
  /ui
    data-table.tsx
    ...
```

---

Este guia contém todos os exemplos práticos necessários para implementar a arquitetura completa! 🚀
