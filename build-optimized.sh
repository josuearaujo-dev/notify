#!/bin/bash
# Script de build otimizado para servidores com poucos recursos

echo "🔧 Configurando variáveis de ambiente..."
export NODE_ENV=production
export NODE_OPTIONS="--max-old-space-size=512"

echo "🧹 Limpando cache anterior..."
rm -rf .next

echo "📦 Iniciando build otimizado..."
# Limita workers e usa menos memória
NODE_OPTIONS="--max-old-space-size=512" pnpm build

echo "✅ Build concluído!"

