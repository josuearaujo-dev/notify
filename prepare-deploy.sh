#!/bin/bash

# Script para preparar arquivos para deploy via SFTP
# Uso: ./prepare-deploy.sh

set -e

echo "🚀 Preparando arquivos para deploy via SFTP..."

# Nome da pasta de deploy
DEPLOY_DIR="deploy-temp"

# Remove pasta antiga se existir
if [ -d "$DEPLOY_DIR" ]; then
    echo "📁 Removendo pasta antiga..."
    rm -rf "$DEPLOY_DIR"
fi

# Cria nova pasta
echo "📁 Criando pasta de deploy..."
mkdir -p "$DEPLOY_DIR"

# Copia arquivos e pastas necessários
echo "📦 Copiando arquivos..."

# Pastas principais
cp -r app "$DEPLOY_DIR/"
cp -r components "$DEPLOY_DIR/"
cp -r hooks "$DEPLOY_DIR/"
cp -r lib "$DEPLOY_DIR/"
cp -r public "$DEPLOY_DIR/"
cp -r scripts "$DEPLOY_DIR/"

# Pasta styles se existir
if [ -d "styles" ]; then
    cp -r styles "$DEPLOY_DIR/"
fi

# Arquivos de configuração na raiz
cp middleware.ts "$DEPLOY_DIR/" 2>/dev/null || echo "⚠️  middleware.ts não encontrado"
cp next.config.mjs "$DEPLOY_DIR/" 2>/dev/null || echo "⚠️  next.config.mjs não encontrado"
cp postcss.config.mjs "$DEPLOY_DIR/" 2>/dev/null || echo "⚠️  postcss.config.mjs não encontrado"
cp tsconfig.json "$DEPLOY_DIR/" 2>/dev/null || echo "⚠️  tsconfig.json não encontrado"
cp components.json "$DEPLOY_DIR/" 2>/dev/null || echo "⚠️  components.json não encontrado"
cp package.json "$DEPLOY_DIR/" 2>/dev/null || echo "⚠️  package.json não encontrado"

# Lock files
if [ -f "pnpm-lock.yaml" ]; then
    cp pnpm-lock.yaml "$DEPLOY_DIR/"
    echo "✅ pnpm-lock.yaml copiado"
elif [ -f "package-lock.json" ]; then
    cp package-lock.json "$DEPLOY_DIR/"
    echo "✅ package-lock.json copiado"
elif [ -f "yarn.lock" ]; then
    cp yarn.lock "$DEPLOY_DIR/"
    echo "✅ yarn.lock copiado"
else
    echo "⚠️  Nenhum lock file encontrado"
fi

# Remove arquivos que não devem ser enviados
echo "🧹 Limpando arquivos desnecessários..."

find "$DEPLOY_DIR" -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
find "$DEPLOY_DIR" -name ".next" -type d -exec rm -rf {} + 2>/dev/null || true
find "$DEPLOY_DIR" -name ".env*" -type f -delete 2>/dev/null || true
find "$DEPLOY_DIR" -name ".git" -type d -exec rm -rf {} + 2>/dev/null || true
find "$DEPLOY_DIR" -name ".vercel" -type d -exec rm -rf {} + 2>/dev/null || true
find "$DEPLOY_DIR" -name "*.tsbuildinfo" -type f -delete 2>/dev/null || true
find "$DEPLOY_DIR" -name "next-env.d.ts" -type f -delete 2>/dev/null || true
find "$DEPLOY_DIR" -name "*.log" -type f -delete 2>/dev/null || true

# Cria arquivo .gitignore para a pasta de deploy
echo "📝 Criando .gitignore..."
cat > "$DEPLOY_DIR/.gitignore" << EOF
# Arquivos que não devem ser enviados
node_modules/
.next/
.env*
*.log
EOF

# Cria arquivo README com instruções
echo "📝 Criando README com instruções..."
cat > "$DEPLOY_DIR/README-DEPLOY.txt" << 'EOF'
INSTRUÇÕES DE DEPLOY VIA SFTP
=============================

1. Faça upload de TODA esta pasta para o servidor SaveInCloud via SFTP

2. Conecte-se ao servidor via SSH e execute:

   cd /caminho/para/seu/projeto
   
   # Instale Node.js 18+ se necessário
   node --version
   
   # Instale pnpm (ou use npm)
   npm install -g pnpm
   
   # Instale dependências
   pnpm install
   # ou: npm install
   
   # Crie arquivo .env.local
   nano .env.local
   # Cole as variáveis de ambiente (veja DEPLOY_SFTP.md)
   
   # Faça o build
   pnpm build
   # ou: npm run build
   
   # Inicie com PM2
   npm install -g pm2
   pm2 start npm --name "whatsapp-api" -- start
   pm2 startup
   pm2 save

3. Configure Nginx como proxy reverso (veja DEPLOY_SFTP.md)

4. Acesse: http://seu-dominio.com

Para mais detalhes, consulte: DEPLOY_SFTP.md
EOF

# Mostra resumo
echo ""
echo "✅ Preparação concluída!"
echo ""
echo "📊 Resumo:"
echo "   Pasta criada: $DEPLOY_DIR"
echo "   Tamanho: $(du -sh "$DEPLOY_DIR" | cut -f1)"
echo ""
echo "📁 Estrutura:"
ls -la "$DEPLOY_DIR" | head -20
echo ""
echo "🚀 Próximos passos:"
echo "   1. Revise os arquivos em: $DEPLOY_DIR"
echo "   2. Faça upload via SFTP para o servidor"
echo "   3. Siga as instruções em: DEPLOY_SFTP.md"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   - NÃO envie arquivos .env via SFTP"
echo "   - Configure as variáveis de ambiente no servidor"
echo "   - Execute os scripts SQL no Supabase antes do deploy"
echo ""

