# Script PowerShell para preparar arquivos para deploy via SFTP
# Uso: .\prepare-deploy.ps1

Write-Host "🚀 Preparando arquivos para deploy via SFTP..." -ForegroundColor Cyan

# Nome da pasta de deploy
$DEPLOY_DIR = "deploy-temp"

# Remove pasta antiga se existir
if (Test-Path $DEPLOY_DIR) {
    Write-Host "📁 Removendo pasta antiga..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $DEPLOY_DIR
}

# Cria nova pasta
Write-Host "📁 Criando pasta de deploy..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $DEPLOY_DIR | Out-Null

# Copia arquivos e pastas necessários
Write-Host "📦 Copiando arquivos..." -ForegroundColor Cyan

# Pastas principais
$folders = @("app", "components", "hooks", "lib", "public", "scripts")
foreach ($folder in $folders) {
    if (Test-Path $folder) {
        Copy-Item -Recurse $folder "$DEPLOY_DIR\$folder"
        Write-Host "  ✅ $folder copiado" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $folder não encontrado" -ForegroundColor Yellow
    }
}

# Pasta styles se existir
if (Test-Path "styles") {
    Copy-Item -Recurse styles "$DEPLOY_DIR\styles"
    Write-Host "  ✅ styles copiado" -ForegroundColor Green
}

# Arquivos de configuração na raiz
$files = @(
    "middleware.ts",
    "next.config.mjs",
    "postcss.config.mjs",
    "tsconfig.json",
    "components.json",
    "package.json"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Copy-Item $file "$DEPLOY_DIR\$file"
        Write-Host "  ✅ $file copiado" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $file não encontrado" -ForegroundColor Yellow
    }
}

# Lock files
if (Test-Path "pnpm-lock.yaml") {
    Copy-Item "pnpm-lock.yaml" "$DEPLOY_DIR\pnpm-lock.yaml"
    Write-Host "  ✅ pnpm-lock.yaml copiado" -ForegroundColor Green
} elseif (Test-Path "package-lock.json") {
    Copy-Item "package-lock.json" "$DEPLOY_DIR\package-lock.json"
    Write-Host "  ✅ package-lock.json copiado" -ForegroundColor Green
} elseif (Test-Path "yarn.lock") {
    Copy-Item "yarn.lock" "$DEPLOY_DIR\yarn.lock"
    Write-Host "  ✅ yarn.lock copiado" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Nenhum lock file encontrado" -ForegroundColor Yellow
}

# Remove arquivos que não devem ser enviados
Write-Host "🧹 Limpando arquivos desnecessários..." -ForegroundColor Cyan

$excludePatterns = @(
    "node_modules",
    ".next",
    ".env*",
    ".git",
    ".vercel",
    "*.tsbuildinfo",
    "next-env.d.ts",
    "*.log"
)

foreach ($pattern in $excludePatterns) {
    Get-ChildItem -Path $DEPLOY_DIR -Recurse -Force | Where-Object {
        $_.Name -like $pattern -or $_.FullName -like "*\$pattern"
    } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# Cria arquivo .gitignore para a pasta de deploy
Write-Host "📝 Criando .gitignore..." -ForegroundColor Cyan
@"
# Arquivos que não devem ser enviados
node_modules/
.next/
.env*
*.log
"@ | Out-File -FilePath "$DEPLOY_DIR\.gitignore" -Encoding UTF8

# Cria arquivo README com instruções
Write-Host "📝 Criando README com instruções..." -ForegroundColor Cyan
@"
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
"@ | Out-File -FilePath "$DEPLOY_DIR\README-DEPLOY.txt" -Encoding UTF8

# Mostra resumo
Write-Host ""
Write-Host "✅ Preparação concluída!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Resumo:" -ForegroundColor Cyan
$size = (Get-ChildItem -Path $DEPLOY_DIR -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "   Pasta criada: $DEPLOY_DIR" -ForegroundColor White
Write-Host "   Tamanho: $([math]::Round($size, 2)) MB" -ForegroundColor White
Write-Host ""
Write-Host "📁 Estrutura:" -ForegroundColor Cyan
Get-ChildItem -Path $DEPLOY_DIR | Select-Object -First 20 | Format-Table Name, Length, LastWriteTime
Write-Host ""
Write-Host "🚀 Próximos passos:" -ForegroundColor Cyan
Write-Host "   1. Revise os arquivos em: $DEPLOY_DIR" -ForegroundColor White
Write-Host "   2. Faça upload via SFTP para o servidor" -ForegroundColor White
Write-Host "   3. Siga as instruções em: DEPLOY_SFTP.md" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Yellow
Write-Host "   - NÃO envie arquivos .env via SFTP" -ForegroundColor Yellow
Write-Host "   - Configure as variáveis de ambiente no servidor" -ForegroundColor Yellow
Write-Host "   - Execute os scripts SQL no Supabase antes do deploy" -ForegroundColor Yellow
Write-Host ""

