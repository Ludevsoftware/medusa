# 🚀 COMECE AQUI - Guia Rápido

**Tempo estimado:** 6-8 horas  
**Resultado:** API Client completo para 3 apps Next.js

---

## 📌 Checklist de 10 Passos

### ✅ PASSO 1: Criar Estrutura (5 min)

```bash
# Na raiz do monorepo
mkdir -p packages/api-client/src/{client,sdk,hooks,types}
cd packages/api-client
```

---

### ✅ PASSO 2: Setup Pacote (10 min)

Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `package.json` (#2)
- ✅ `tsconfig.json` (#3)

```bash
npm install
```

---

### ✅ PASSO 3: Cliente HTTP (30 min)

Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `src/client/index.ts` (#4) - Cliente com Auth JWT

**Teste:**
```typescript
// Teste rápido no console
const client = new ApiClient('http://localhost:3001')
client.fetch('/api/test').then(console.log)
```

---

### ✅ PASSO 4: Types (15 min)

Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `src/types/index.ts` (#5) - Drones, Plots, Pilots

---

### ✅ PASSO 5: SDK (45 min)

Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `src/sdk/drones.ts` (#6)
- ✅ `src/sdk/plots.ts` (#7)
- ✅ `src/sdk/pilots.ts` (#8)
- ✅ `src/sdk/index.ts` (#9)

**Teste:**
```typescript
import { sdk } from './src/sdk'
sdk.drones.list().then(console.log)
```

---

### ✅ PASSO 6: Query Keys (10 min)

Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `src/hooks/query-keys.ts` (#10)

---

### ✅ PASSO 7: Hooks (1h 30min)

Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `src/hooks/use-drones.ts` (#11)
- ✅ `src/hooks/use-plots.ts` (#12)
- ✅ `src/hooks/use-pilots.ts` (#13)
- ✅ `src/hooks/use-auth.ts` (#14)
- ✅ `src/hooks/index.ts` (#15)

---

### ✅ PASSO 8: Export Principal (5 min)

Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `src/index.ts` (#16)

---

### ✅ PASSO 9: Setup nos Apps (30 min por app)

Para cada app (`web-admin`, `web-pilot`, `web-field`):

**1. Instalar dependências:**
```bash
cd apps/web-admin
npm install @tanstack/react-query@^5.59.0
npm install @tanstack/react-query-devtools@^5.59.0
```

**2. Adicionar ao `package.json`:**
```json
{
  "dependencies": {
    "@repo/api-client": "*"
  }
}
```

**3. Criar Provider:**
Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `providers/query-provider.tsx` (#18)

**4. Atualizar Layout:**
Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `app/layout.tsx` (#19)

**5. Criar `.env.local`:**
```bash
NEXT_PUBLIC_API_URL=http://localhost:3001
```

---

### ✅ PASSO 10: Testar Tudo (1h)

**1. Página de Login:**
Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `apps/web-admin/app/login/page.tsx` (#22)

**2. Página de Drones:**
Copie do arquivo `CODIGO_PRONTO_COPIAR.md`:
- ✅ `apps/web-admin/app/drones/page.tsx` (#21)

**3. Rodar tudo:**
```bash
# Na raiz do monorepo
turbo dev
```

**4. Testar fluxo:**
- [ ] Login em `http://localhost:3000/login`
- [ ] Ver drones em `http://localhost:3000/drones`
- [ ] Criar novo drone
- [ ] Deletar drone
- [ ] Verificar cache (React Query DevTools)

---

## 🎯 Progresso Visual

```
[████████████████████] 100% - Setup Pacote
[████████████████████] 100% - Cliente HTTP
[████████████████████] 100% - Types
[████████████████████] 100% - SDK
[████████████████████] 100% - Query Keys
[████████████████████] 100% - Hooks
[████████████████████] 100% - Exports
[████████░░░░░░░░░░░] 45% - Setup App 1
[░░░░░░░░░░░░░░░░░░░] 0% - Setup App 2
[░░░░░░░░░░░░░░░░░░░] 0% - Setup App 3
[░░░░░░░░░░░░░░░░░░░] 0% - Testes
```

---

## 🔥 Atalhos

### Criar Tudo de Uma Vez
```bash
# Executar na raiz
./setup-api-client.sh  # Criar este script depois
```

### Verificar Tipos
```bash
cd packages/api-client
npx tsc --noEmit
```

### Ver Estrutura Final
```bash
tree packages/api-client/src -I node_modules
```

---

## 📊 Tempo por Etapa

| Etapa | Tempo | Acumulado |
|-------|-------|-----------|
| 1-2: Setup | 15min | 15min |
| 3: Cliente | 30min | 45min |
| 4: Types | 15min | 1h |
| 5: SDK | 45min | 1h45min |
| 6: Keys | 10min | 1h55min |
| 7: Hooks | 1h30min | 3h25min |
| 8: Export | 5min | 3h30min |
| 9: Apps (x3) | 1h30min | 5h |
| 10: Testes | 1h | 6h |

**Total:** ~6 horas

---

## 🎓 Conceitos Principais

### Cliente HTTP
```typescript
const client = new ApiClient(baseUrl)
client.setToken(token)  // JWT
client.fetch('/api/drones')  // Fetch com auth
```

### SDK
```typescript
sdk.drones.list()    // GET /api/drones
sdk.drones.get(id)   // GET /api/drones/:id
sdk.drones.create()  // POST /api/drones
```

### Hooks
```typescript
const { data } = useDrones()           // Query
const create = useCreateDrone()         // Mutation
create.mutate({ name: 'Drone 1' })
```

### Cache
```typescript
// Invalidação automática após mutations
queryClient.invalidateQueries({ 
  queryKey: dronesKeys.lists() 
})
```

---

## ⚠️ Problemas Comuns

### 1. Erro de módulo não encontrado
```bash
# Na raiz
npm install
turbo build
```

### 2. Token não persiste
Verificar se `localStorage` está disponível (cliente only).

### 3. CORS errors
Adicionar no backend:
```typescript
app.use(cors({
  origin: 'http://localhost:3000',
  credentials: true
}))
```

### 4. Types não aparecem
```bash
cd packages/api-client
npm run type-check
```

---

## 🚀 Próximos Passos

Depois de tudo funcionando:

1. **Adicionar mais recursos:**
   - Flights (voos)
   - Missions (missões)
   - Analytics

2. **Melhorar hooks:**
   - Infinite scroll
   - Optimistic updates
   - Prefetching

3. **Adicionar features:**
   - Error handling global
   - Toast notifications
   - Loading states

4. **Performance:**
   - Cache persistence
   - Request deduplication

---

## 📚 Arquivos de Referência

1. **CODIGO_PRONTO_COPIAR.md** - Todo o código para copiar
2. **PLANO_MONOREPO_TURBOREPO.md** - Explicações detalhadas
3. **PLANO_ARQUITETURA_API.md** - Arquitetura completa (original)

---

## ✅ Checklist Final

Antes de considerar pronto:

- [ ] `npm run type-check` sem erros
- [ ] Login funcionando
- [ ] CRUD de drones funcionando
- [ ] Lista de plots funcionando
- [ ] Lista de pilots funcionando
- [ ] React Query DevTools visível
- [ ] Cache invalidando corretamente
- [ ] Token JWT persistindo
- [ ] Funciona nos 3 apps
- [ ] Variáveis de ambiente configuradas

---

## 🎉 Você Conseguiu!

Agora você tem:
- ✅ SDK compartilhado
- ✅ Hooks prontos
- ✅ Auth JWT
- ✅ Cache inteligente
- ✅ TypeScript completo
- ✅ Padrão Medusa.js

**Próximo:** Adicione novos recursos seguindo o mesmo padrão! 🚀

---

**Dúvidas?** Revise os arquivos:
- `CODIGO_PRONTO_COPIAR.md` - Código completo
- `PLANO_MONOREPO_TURBOREPO.md` - Issues detalhadas
