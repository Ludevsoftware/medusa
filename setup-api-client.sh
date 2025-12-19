#!/bin/bash

# Script de Setup Automático - API Client Package
# Execute na raiz do monorepo: ./setup-api-client.sh

set -e  # Para em caso de erro

echo "🚀 Iniciando setup do @repo/api-client..."
echo ""

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Criar estrutura de pastas
echo -e "${BLUE}📁 Criando estrutura de pastas...${NC}"
mkdir -p packages/api-client/src/client
mkdir -p packages/api-client/src/sdk
mkdir -p packages/api-client/src/hooks
mkdir -p packages/api-client/src/types
echo -e "${GREEN}✓ Estrutura criada${NC}"
echo ""

# 2. Criar package.json
echo -e "${BLUE}📦 Criando package.json...${NC}"
cat > packages/api-client/package.json << 'EOF'
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
EOF
echo -e "${GREEN}✓ package.json criado${NC}"
echo ""

# 3. Criar tsconfig.json
echo -e "${BLUE}⚙️  Criando tsconfig.json...${NC}"
cat > packages/api-client/tsconfig.json << 'EOF'
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
EOF
echo -e "${GREEN}✓ tsconfig.json criado${NC}"
echo ""

# 4. Criar README
echo -e "${BLUE}📝 Criando README...${NC}"
cat > packages/api-client/README.md << 'EOF'
# @repo/api-client

SDK compartilhado para consumir a API de Drones Agrícolas.

## Instalação

Este pacote já está configurado para uso interno no monorepo.

## Uso

### Setup no App

```typescript
// app/layout.tsx
import { QueryProvider } from '@/providers/query-provider'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <QueryProvider>{children}</QueryProvider>
      </body>
    </html>
  )
}
```

### Usar Hooks

```typescript
import { useDrones, useCreateDrone } from '@repo/api-client/hooks'

export default function DronesPage() {
  const { data, isLoading } = useDrones()
  const createDrone = useCreateDrone()

  return (
    <div>
      {data?.data.map(drone => (
        <div key={drone.id}>{drone.name}</div>
      ))}
    </div>
  )
}
```

## Recursos Disponíveis

- **Drones**: `useDrones`, `useDrone`, `useCreateDrone`, `useUpdateDrone`, `useDeleteDrone`
- **Plots**: `usePlots`, `usePlot`, `useCreatePlot`, `useUpdatePlot`, `useDeletePlot`
- **Pilots**: `usePilots`, `usePilot`, `useCreatePilot`, `useUpdatePilot`, `useDeletePilot`
- **Auth**: `useLogin`, `useLogout`

## Variáveis de Ambiente

Adicione em `.env.local`:

```bash
NEXT_PUBLIC_API_URL=http://localhost:3001
```
EOF
echo -e "${GREEN}✓ README criado${NC}"
echo ""

# 5. Criar arquivos vazios (placeholders)
echo -e "${BLUE}📄 Criando arquivos placeholder...${NC}"
touch packages/api-client/src/client/index.ts
touch packages/api-client/src/types/index.ts
touch packages/api-client/src/sdk/index.ts
touch packages/api-client/src/sdk/drones.ts
touch packages/api-client/src/sdk/plots.ts
touch packages/api-client/src/sdk/pilots.ts
touch packages/api-client/src/hooks/index.ts
touch packages/api-client/src/hooks/query-keys.ts
touch packages/api-client/src/hooks/use-drones.ts
touch packages/api-client/src/hooks/use-plots.ts
touch packages/api-client/src/hooks/use-pilots.ts
touch packages/api-client/src/hooks/use-auth.ts
touch packages/api-client/src/index.ts
echo -e "${GREEN}✓ Arquivos criados${NC}"
echo ""

# 6. Instalar dependências
echo -e "${BLUE}📥 Instalando dependências...${NC}"
cd packages/api-client
npm install
cd ../..
echo -e "${GREEN}✓ Dependências instaladas${NC}"
echo ""

# 7. Criar .gitignore
echo -e "${BLUE}🚫 Criando .gitignore...${NC}"
cat > packages/api-client/.gitignore << 'EOF'
node_modules
dist
.turbo
*.log
EOF
echo -e "${GREEN}✓ .gitignore criado${NC}"
echo ""

# 8. Mensagem final
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Setup concluído com sucesso!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📂 Estrutura criada em: packages/api-client/"
echo ""
echo "📝 Próximos passos:"
echo "   1. Copiar código do arquivo CODIGO_PRONTO_COPIAR.md"
echo "   2. Adicionar @repo/api-client aos apps:"
echo "      cd apps/web-admin && npm install"
echo "   3. Seguir o guia START_HERE.md"
echo ""
echo "📚 Arquivos de referência:"
echo "   - START_HERE.md            (guia rápido)"
echo "   - CODIGO_PRONTO_COPIAR.md  (código completo)"
echo "   - PLANO_MONOREPO_TURBOREPO.md (detalhes)"
echo ""
echo "🚀 Boa codificação!"
echo ""
