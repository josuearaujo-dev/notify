#!/bin/bash

# Script para Preparar Arquivos para Upload via FileZilla
# Este script prepara os arquivos em uma pasta pronta para upload manual via FileZilla

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DEPLOY_DIR="deploy-ready"

log() {
  echo -e "${GREEN}[PREPARE]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log "Preparando arquivos para upload via FileZilla..."

# Remove diretório anterior se existir
if [ -d "$DEPLOY_DIR" ]; then
  log "Removendo diretório anterior..."
  rm -rf "$DEPLOY_DIR"
fi

# Cria diretório
mkdir -p "$DEPLOY_DIR"
log "Diretório criado: $DEPLOY_DIR"

# Copia arquivos necessários
log "Copiando arquivos..."

# Pastas obrigatórias
if [ -d "app" ]; then
  cp -r app "$DEPLOY_DIR/"
  log "✓ app/"
else
  warn "Pasta app/ não encontrada"
fi

if [ -d "components" ]; then
  cp -r components "$DEPLOY_DIR/"
  log "✓ components/"
else
  warn "Pasta components/ não encontrada"
fi

if [ -d "hooks" ]; then
  cp -r hooks "$DEPLOY_DIR/"
  log "✓ hooks/"
fi

if [ -d "lib" ]; then
  cp -r lib "$DEPLOY_DIR/"
  log "✓ lib/"
else
  warn "Pasta lib/ não encontrada"
fi

if [ -d "public" ]; then
  cp -r public "$DEPLOY_DIR/"
  log "✓ public/"
fi

# Pasta pages (obrigatória para o build Next 15 - 404 e _error)
if [ -d "pages" ]; then
  cp -r pages "$DEPLOY_DIR/"
  log "✓ pages/"
else
  warn "Pasta pages/ não encontrada (necessária para o build)"
fi

# Pasta scripts (se existir)
if [ -d "scripts" ]; then
  # Copia apenas scripts SQL, não os scripts de deploy
  mkdir -p "$DEPLOY_DIR/scripts"
  find scripts -maxdepth 1 -type f -name "*.sql" -exec cp {} "$DEPLOY_DIR/scripts/" \; 2>/dev/null || true
  if [ "$(ls -A $DEPLOY_DIR/scripts 2>/dev/null)" ]; then
    log "✓ scripts/*.sql"
  fi
fi

# Arquivos de configuração raiz
[ -f "middleware.ts" ] && cp middleware.ts "$DEPLOY_DIR/" && log "✓ middleware.ts"
[ -f "next.config.mjs" ] && cp next.config.mjs "$DEPLOY_DIR/" && log "✓ next.config.mjs"
[ -f "postcss.config.mjs" ] && cp postcss.config.mjs "$DEPLOY_DIR/" && log "✓ postcss.config.mjs"
[ -f "tsconfig.json" ] && cp tsconfig.json "$DEPLOY_DIR/" && log "✓ tsconfig.json"
[ -f "components.json" ] && cp components.json "$DEPLOY_DIR/" && log "✓ components.json"
[ -f "package.json" ] && cp package.json "$DEPLOY_DIR/" && log "✓ package.json"

# Lock file (pnpm ou npm)
if [ -f "pnpm-lock.yaml" ]; then
  cp pnpm-lock.yaml "$DEPLOY_DIR/"
  log "✓ pnpm-lock.yaml"
elif [ -f "package-lock.json" ]; then
  cp package-lock.json "$DEPLOY_DIR/"
  log "✓ package-lock.json"
fi

# Verifica e remove arquivos que NÃO devem ser enviados
log "Verificando arquivos desnecessários..."

if [ -d "$DEPLOY_DIR/node_modules" ]; then
  error "ERRO: node_modules foi copiado! Removendo..."
  rm -rf "$DEPLOY_DIR/node_modules"
fi

if [ -d "$DEPLOY_DIR/.next" ]; then
  warn ".next foi copiado, removendo..."
  rm -rf "$DEPLOY_DIR/.next"
fi

# Remove arquivos .env se existirem
find "$DEPLOY_DIR" -name ".env*" -type f -delete 2>/dev/null && warn "Arquivos .env removidos"

# Remove arquivos de git
find "$DEPLOY_DIR" -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true
find "$DEPLOY_DIR" -name ".gitignore" -type f -delete 2>/dev/null || true

# Remove arquivos temporários
find "$DEPLOY_DIR" -name "*.tsbuildinfo" -type f -delete 2>/dev/null || true
find "$DEPLOY_DIR" -name "next-env.d.ts" -type f -delete 2>/dev/null || true
find "$DEPLOY_DIR" -name "*.log" -type f -delete 2>/dev/null || true

# Remove scripts de deploy da pasta scripts (se copiou)
find "$DEPLOY_DIR/scripts" -name "*.sh" -type f -delete 2>/dev/null || true
find "$DEPLOY_DIR/scripts" -name "README-*.md" -type f -delete 2>/dev/null || true

log "Limpeza concluída!"

# Mostra estatísticas
TOTAL_FILES=$(find "$DEPLOY_DIR" -type f | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh "$DEPLOY_DIR" | cut -f1)

log ""
log "═══════════════════════════════════════"
log "✅ Preparação concluída!"
log "═══════════════════════════════════════"
log "Diretório: $DEPLOY_DIR"
log "Arquivos: $TOTAL_FILES"
log "Tamanho: $TOTAL_SIZE"
log ""
log "📤 Próximos passos:"
log "   1. Abra o FileZilla"
log "   2. Conecte-se ao seu servidor FTP"
log "   3. Navegue até o diretório remoto no servidor"
log "   4. Arraste a pasta '$DEPLOY_DIR' para o servidor"
log "   5. Aguarde o upload concluir"
log ""
log "💡 Dica: Use 'Sincronizar diretórios' no FileZilla para"
log "   atualizar apenas arquivos modificados!"
log "═══════════════════════════════════════"
