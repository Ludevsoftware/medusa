# 🚀 Guia Turbo CLI - Comandos Úteis

**Turborepo CLI** para gerenciar seu monorepo.

---

## 📦 Criar Workspace/Pacote

### Criar novo pacote
```bash
turbo gen workspace --name api-client --type package --destination packages
```

**Parâmetros:**
- `--name` - Nome do workspace (@repo/api-client)
- `--type` - Tipo: `package` ou `app`
- `--destination` - Pasta: `packages` ou `apps`

**Exemplos:**
```bash
# Criar pacote compartilhado
turbo gen workspace --name ui --type package --destination packages

# Criar novo app
turbo gen workspace --name web-pilot --type app --destination apps

# Criar com template específico
turbo gen workspace --name api-client --type package --example custom
```

---

## 🏗️ Build e Dev

### Rodar builds
```bash
# Build tudo
turbo build

# Build pacote específico
turbo build --filter=api-client

# Build com dependências
turbo build --filter=web-admin...

# Ver o que seria executado (dry-run)
turbo build --dry-run
```

### Rodar dev
```bash
# Dev em todos os apps
turbo dev

# Dev em app específico
turbo dev --filter=web-admin

# Dev em múltiplos apps
turbo dev --filter=web-admin --filter=web-pilot
```

---

## 🧪 Testes

### Rodar testes
```bash
# Todos os testes
turbo test

# Testes de um pacote
turbo test --filter=api-client

# Com coverage
turbo test --filter=api-client -- --coverage

# Watch mode
turbo test --filter=api-client -- --watch
```

---

## 🔍 Filtros Avançados

### Por workspace
```bash
# Um workspace
turbo build --filter=api-client

# Múltiplos workspaces
turbo build --filter=api-client --filter=ui

# Excluir workspace
turbo build --filter=!api-client
```

### Por dependências
```bash
# Workspace + suas dependências
turbo build --filter=web-admin...

# Apenas dependências (sem o próprio)
turbo build --filter=...api-client

# Workspace + dependentes (quem depende dele)
turbo build --filter=...web-admin
```

### Por diretório
```bash
# Tudo em apps/
turbo build --filter='./apps/*'

# Tudo em packages/
turbo build --filter='./packages/*'
```

### Por mudanças Git
```bash
# Apenas o que mudou desde main
turbo build --filter='[main]'

# O que mudou + dependentes
turbo build --filter='[main]...'

# Mudanças desde último commit
turbo build --filter='[HEAD^1]'
```

---

## 📊 Graph e Análise

### Ver grafo de dependências
```bash
# Gerar grafo
turbo run build --graph

# Salvar em arquivo
turbo run build --graph=graph.html

# Ver apenas análise
turbo run build --dry-run
```

### Ver ordem de execução
```bash
turbo run build --dry-run --filter=web-admin

# Output:
# Tasks to Run
# web-admin#build
#   Task            = build
#   Package         = web-admin
#   Hash            = abc123def456
#   Cached (Local)  = false
#   Directory       = apps/web-admin
#   Command         = next build
#   Dependencies    = api-client, ui
```

---

## 🗑️ Cache

### Limpar cache
```bash
# Limpar todo cache
turbo run build --force

# Limpar cache específico
rm -rf .turbo
```

### Ver cache hits
```bash
turbo run build --summarize

# Ver JSON detalhado
turbo run build --summarize=true > summary.json
```

---

## 📝 Lint e Type Check

### Lint
```bash
# Lint tudo
turbo lint

# Lint específico
turbo lint --filter=api-client

# Lint o que mudou
turbo lint --filter='[main]'
```

### Type Check
```bash
# Type check tudo
turbo type-check

# Específico
turbo type-check --filter=api-client
```

---

## 🔧 Configuração (turbo.json)

### Pipeline básico
```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"],
      "cache": true
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "outputs": []
    },
    "type-check": {
      "dependsOn": ["^build"],
      "outputs": []
    }
  }
}
```

### Explicação:
- **dependsOn**: Dependências da task
  - `^build` = build das dependências primeiro
  - `build` = build do próprio workspace
- **outputs**: O que vai pro cache
- **cache**: Se deve cachear ou não
- **persistent**: Para tasks que ficam rodando (dev server)

---

## 🎯 Exemplos Práticos

### Cenário 1: Desenvolver web-admin
```bash
# Rodar dev do admin + suas dependências
turbo dev --filter=web-admin...
```

### Cenário 2: Testar api-client
```bash
# Testes com coverage
turbo test --filter=api-client -- --coverage

# Watch mode
turbo test --filter=api-client -- --watch
```

### Cenário 3: Build para produção
```bash
# Build tudo otimizado
turbo build

# Build apenas apps (não packages)
turbo build --filter='./apps/*'
```

### Cenário 4: CI/CD - testar mudanças
```bash
# Testar apenas o que mudou desde main
turbo test --filter='[main]...'

# Build apenas o que mudou
turbo build --filter='[main]...'
```

### Cenário 5: Adicionar nova feature
```bash
# 1. Criar branch
git checkout -b feature/new-api

# 2. Criar workspace se necessário
turbo gen workspace --name new-api --type package

# 3. Dev mode
turbo dev --filter=new-api

# 4. Testar
turbo test --filter=new-api

# 5. Build final
turbo build --filter=new-api
```

---

## 🔄 Workflows Comuns

### Workflow: Novo Desenvolvedor
```bash
# 1. Clone do repo
git clone <repo>
cd <repo>

# 2. Instalar deps
pnpm install

# 3. Ver estrutura
turbo run build --dry-run

# 4. Rodar dev
turbo dev
```

### Workflow: Feature Nova
```bash
# 1. Branch
git checkout -b feature/x

# 2. Fazer mudanças
# ... editar código ...

# 3. Testar
turbo test --filter='[main]'

# 4. Build
turbo build --filter='[main]'

# 5. Lint
turbo lint --filter='[main]'

# 6. Commit
git commit -m "feat: x"
```

### Workflow: CI/CD Pipeline
```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
      - run: pnpm install
      - run: turbo test --filter='[HEAD^1]'
      - run: turbo build --filter='[HEAD^1]'
```

---

## 📚 Comandos de Informação

### Ver versão
```bash
turbo --version
```

### Ver workspaces
```bash
pnpm list -r --depth=-1
```

### Ver dependências de um workspace
```bash
pnpm list --filter=api-client
```

### Ver quem depende de um pacote
```bash
pnpm why @repo/api-client
```

---

## 🚀 Performance

### Paralelização
```bash
# Controlar jobs paralelos
turbo build --concurrency=4

# Sem limite (padrão)
turbo build --concurrency=100

# Sequencial (debug)
turbo build --concurrency=1
```

### Remote Caching
```bash
# Configurar (uma vez)
turbo login
turbo link

# Usar
turbo build
# ^ Vai usar cache remoto automaticamente
```

---

## 🎓 Dicas Avançadas

### 1. Usar pnpm workspace protocol
```json
{
  "dependencies": {
    "@repo/api-client": "workspace:*",
    "@repo/ui": "workspace:^1.0.0"
  }
}
```

### 2. Environment Variables
```bash
# .env
TURBO_TEAM=my-team
TURBO_TOKEN=xxxxx

# Usar no turbo
turbo build --env-mode=loose  # Todas as env vars
turbo build --env-mode=strict # Apenas as declaradas
```

### 3. Scripts do package.json
```json
{
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "test": "turbo test",
    "test:changed": "turbo test --filter='[main]'"
  }
}
```

---

## 📖 Referências

- **Turbo Docs:** https://turbo.build/repo/docs
- **CLI Reference:** https://turbo.build/repo/docs/reference/command-line-reference
- **Filtering:** https://turbo.build/repo/docs/core-concepts/monorepos/filtering
- **Caching:** https://turbo.build/repo/docs/core-concepts/caching

---

## ✅ Checklist Turbo

Antes de fazer PR:
- [ ] `turbo lint --filter='[main]'` sem erros
- [ ] `turbo test --filter='[main]'` passando
- [ ] `turbo build --filter='[main]'` sem erros
- [ ] `turbo run build --dry-run` para ver impacto

---

**Agora você domina o Turbo CLI! 🚀**
