#!/bin/bash

# Prepara uma pasta limpa para:
# 1) subir arquivos manualmente no Git
# 2) fazer deploy no Vercel

set -euo pipefail

OUTPUT_DIR="deploy-vercel-git"

log() {
  printf "[PREPARE] %s\n" "$1"
}

warn() {
  printf "[WARN] %s\n" "$1"
}

if [ ! -f "package.json" ]; then
  echo "Erro: execute este script na raiz do projeto (onde existe package.json)."
  exit 1
fi

log "Iniciando preparação para Git manual + Vercel..."

if [ -d "$OUTPUT_DIR" ]; then
  log "Removendo pasta anterior: $OUTPUT_DIR"
  rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"

# Usa rsync para copiar o projeto com exclusões.
rsync -a ./ "$OUTPUT_DIR/" \
  --exclude ".git/" \
  --exclude ".next/" \
  --exclude "node_modules/" \
  --exclude ".vercel/" \
  --exclude ".env*" \
  --exclude "deploy-temp/" \
  --exclude "deploy-ready/" \
  --exclude "deploy-vercel-git/" \
  --exclude "deploy-BKP/" \
  --exclude "*.log" \
  --exclude "*.tsbuildinfo"

# Remove arquivos que podem atrapalhar ou não são necessários no pacote final.
rm -f "$OUTPUT_DIR/next-env.d.ts" 2>/dev/null || true
rm -f "$OUTPUT_DIR/deploy-ftp.conf" 2>/dev/null || true

# Gera guia rápido de uso.
cat > "$OUTPUT_DIR/DEPLOY-VERCEL-GIT.txt" << 'EOF'
PASSO A PASSO - GIT MANUAL + VERCEL
===================================

1) Entre na pasta gerada:
   cd deploy-vercel-git

2) Revise os arquivos:
   ls -la

3) Suba manualmente para o seu repositório Git (web ou cliente Git).
   Importante: os arquivos .env NÃO vão juntos.

4) No painel da Vercel:
   - Conecte o repositório
   - Configure as variáveis de ambiente
   - Deploy

Se preferir Vercel CLI:
   npm i -g vercel
   vercel
   vercel --prod
EOF

TOTAL_FILES=$(find "$OUTPUT_DIR" -type f | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh "$OUTPUT_DIR" | cut -f1)

log "Concluído com sucesso."
log "Pasta: $OUTPUT_DIR"
log "Arquivos: $TOTAL_FILES"
log "Tamanho: $TOTAL_SIZE"
log "Arquivo de instruções: $OUTPUT_DIR/DEPLOY-VERCEL-GIT.txt"

if [ -f "$OUTPUT_DIR/.env.local" ] || [ -f "$OUTPUT_DIR/.env" ]; then
  warn "Encontrado arquivo .env na pasta final (não era esperado)."
else
  log "OK: nenhum arquivo .env foi incluído."
fi
