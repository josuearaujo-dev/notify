#!/bin/bash

# Script de Deploy Automático via FTP/SFTP
# Uso: ./scripts/deploy-ftp.sh [--config=arquivo.conf] [--dry-run]

set -e  # Para na primeira erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis padrão
CONFIG_FILE="deploy-ftp.conf"
DRY_RUN=false
DEPLOY_DIR="deploy-temp"

# Parse argumentos
for arg in "$@"; do
  case $arg in
    --config=*)
      CONFIG_FILE="${arg#*=}"
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo -e "${RED}Argumento desconhecido: $arg${NC}"
      exit 1
      ;;
  esac
done

# Função para log
log() {
  echo -e "${GREEN}[DEPLOY]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Verifica se o arquivo de configuração existe
if [ ! -f "$CONFIG_FILE" ]; then
  error "Arquivo de configuração não encontrado: $CONFIG_FILE"
  error "Crie um arquivo $CONFIG_FILE baseado em deploy-ftp.conf.example"
  exit 1
fi

# Carrega configurações
source "$CONFIG_FILE"

# Valida configurações obrigatórias
if [ -z "$FTP_HOST" ] || [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ] || [ -z "$FTP_REMOTE_DIR" ]; then
  error "Configurações obrigatórias faltando no arquivo $CONFIG_FILE"
  error "Verifique: FTP_HOST, FTP_USER, FTP_PASS, FTP_REMOTE_DIR"
  exit 1
fi

# Define porta padrão se não especificada
FTP_PORT=${FTP_PORT:-21}
FTP_TYPE=${FTP_TYPE:-ftp}  # ftp ou sftp

log "Iniciando deploy via $FTP_TYPE..."
log "Host: $FTP_HOST"
log "Porta: $FTP_PORT"
log "Usuário: $FTP_USER"
log "Diretório remoto: $FTP_REMOTE_DIR"

if [ "$DRY_RUN" = true ]; then
  warn "MODO DRY-RUN: Nenhuma alteração será feita"
fi

# PASSO 1: Preparar arquivos localmente
log "Preparando arquivos para deploy..."

# Remove diretório temporário anterior se existir
if [ -d "$DEPLOY_DIR" ]; then
  log "Removendo diretório temporário anterior..."
  rm -rf "$DEPLOY_DIR"
fi

# Cria diretório temporário
mkdir -p "$DEPLOY_DIR"
log "Diretório temporário criado: $DEPLOY_DIR"

# Copia arquivos necessários
log "Copiando arquivos..."

# Pastas obrigatórias
cp -r app "$DEPLOY_DIR/"
cp -r components "$DEPLOY_DIR/"
cp -r hooks "$DEPLOY_DIR/"
cp -r lib "$DEPLOY_DIR/"
cp -r public "$DEPLOY_DIR/"

# Pasta scripts (se existir)
if [ -d "scripts" ]; then
  cp -r scripts "$DEPLOY_DIR/"
fi

# Arquivos de configuração raiz
cp middleware.ts "$DEPLOY_DIR/" 2>/dev/null || warn "middleware.ts não encontrado"
cp next.config.mjs "$DEPLOY_DIR/" 2>/dev/null || warn "next.config.mjs não encontrado"
cp postcss.config.mjs "$DEPLOY_DIR/" 2>/dev/null || warn "postcss.config.mjs não encontrado"
cp tsconfig.json "$DEPLOY_DIR/" 2>/dev/null || warn "tsconfig.json não encontrado"
cp components.json "$DEPLOY_DIR/" 2>/dev/null || warn "components.json não encontrado"
cp package.json "$DEPLOY_DIR/"

# Lock file (pnpm ou npm)
if [ -f "pnpm-lock.yaml" ]; then
  cp pnpm-lock.yaml "$DEPLOY_DIR/"
elif [ -f "package-lock.json" ]; then
  cp package-lock.json "$DEPLOY_DIR/"
fi

# Verifica se não copiou arquivos desnecessários
if [ -d "$DEPLOY_DIR/node_modules" ]; then
  error "ERRO: node_modules foi copiado! Removendo..."
  rm -rf "$DEPLOY_DIR/node_modules"
fi

if [ -d "$DEPLOY_DIR/.next" ]; then
  warn ".next foi copiado, removendo..."
  rm -rf "$DEPLOY_DIR/.next"
fi

if [ -f "$DEPLOY_DIR/.env" ] || [ -f "$DEPLOY_DIR/.env.local" ]; then
  error "ERRO: Arquivos .env foram copiados! Removendo..."
  rm -f "$DEPLOY_DIR/.env" "$DEPLOY_DIR/.env.local" "$DEPLOY_DIR/.env.*"
fi

log "Arquivos preparados com sucesso!"

# Lista tamanho do diretório
DEPLOY_SIZE=$(du -sh "$DEPLOY_DIR" | cut -f1)
log "Tamanho do deploy: $DEPLOY_SIZE"

if [ "$DRY_RUN" = true ]; then
  log "DRY-RUN: Deploy preparado, mas não enviado."
  log "Para fazer o deploy real, execute sem --dry-run"
  exit 0
fi

# PASSO 2: Upload via FTP/SFTP
log "Iniciando upload via $FTP_TYPE..."

if [ "$FTP_TYPE" = "sftp" ]; then
  # Upload via SFTP usando lftp ou sftp
  if command -v lftp &> /dev/null; then
    log "Usando lftp para SFTP..."
    lftp -u "$FTP_USER,$FTP_PASS" -p "$FTP_PORT" sftp://"$FTP_HOST" <<EOF
set sftp:auto-confirm yes
cd $FTP_REMOTE_DIR
mirror -R -X node_modules -X .next -X .git -X .env* --delete --verbose $DEPLOY_DIR .
bye
EOF
  elif command -v sftp &> /dev/null; then
    log "Usando sftp (upload manual)..."
    # Cria script temporário para sftp
    SFTP_SCRIPT=$(mktemp)
    echo "cd $FTP_REMOTE_DIR" > "$SFTP_SCRIPT"
    echo "put -r $DEPLOY_DIR/* ." >> "$SFTP_SCRIPT"
    echo "bye" >> "$SFTP_SCRIPT"
    
    sftp -P "$FTP_PORT" -b "$SFTP_SCRIPT" "$FTP_USER@$FTP_HOST"
    rm "$SFTP_SCRIPT"
  else
    error "lftp ou sftp não encontrado. Instale um deles:"
    error "  macOS: brew install lftp"
    error "  Ubuntu: sudo apt-get install lftp"
    exit 1
  fi
else
  # Upload via FTP usando lftp ou curl
  if command -v lftp &> /dev/null; then
    log "Usando lftp para FTP..."
    lftp -u "$FTP_USER,$FTP_PASS" -p "$FTP_PORT" ftp://"$FTP_HOST" <<EOF
cd $FTP_REMOTE_DIR
mirror -R -X node_modules -X .next -X .git -X .env* --delete --verbose $DEPLOY_DIR .
bye
EOF
  elif command -v curl &> /dev/null; then
    log "Usando curl para FTP..."
    warn "curl não suporta upload recursivo completo. Use lftp para melhor resultado."
    # Upload básico com curl (limitado)
    cd "$DEPLOY_DIR"
    find . -type f -exec curl -u "$FTP_USER:$FTP_PASS" --ftp-create-dirs -T {} "ftp://$FTP_HOST:$FTP_PORT$FTP_REMOTE_DIR/{}" \;
    cd ..
  else
    error "lftp ou curl não encontrado. Instale lftp:"
    error "  macOS: brew install lftp"
    error "  Ubuntu: sudo apt-get install lftp"
    exit 1
  fi
fi

log "Upload concluído!"

# PASSO 3: Executar comandos no servidor (se configurado)
if [ -n "$SSH_HOST" ] && [ -n "$SSH_USER" ] && [ -n "$SSH_COMMANDS" ]; then
  log "Executando comandos no servidor via SSH..."
  
  if [ -n "$SSH_KEY" ]; then
    SSH_CMD="ssh -i $SSH_KEY -p ${SSH_PORT:-22} $SSH_USER@$SSH_HOST"
  else
    SSH_CMD="ssh -p ${SSH_PORT:-22} $SSH_USER@$SSH_HOST"
  fi
  
  # Executa cada comando
  IFS=';' read -ra COMMANDS <<< "$SSH_COMMANDS"
  for cmd in "${COMMANDS[@]}"; do
    log "Executando: $cmd"
    $SSH_CMD "$cmd"
  done
  
  log "Comandos SSH executados!"
fi

# Limpa diretório temporário (opcional)
if [ "$CLEANUP_AFTER_DEPLOY" = "true" ]; then
  log "Limpando diretório temporário..."
  rm -rf "$DEPLOY_DIR"
  log "Limpeza concluída!"
fi

log "Deploy concluído com sucesso! 🚀"
