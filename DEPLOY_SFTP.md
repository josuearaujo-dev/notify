# Guia de Deploy Manual via SFTP - SaveInCloud

## 📦 Preparação Local (Antes do Upload)

### 1. Instalar Dependências Localmente

```bash
# Instale as dependências (para gerar o package-lock.json se usar npm)
pnpm install
# ou
npm install
```

### 2. Criar Arquivo .env.local (para referência)

Crie um arquivo `.env.local` com as variáveis (não envie este arquivo!):

```bash
NEXT_PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua-chave-anon-key
SUPABASE_SERVICE_ROLE_KEY=sua-service-role-key
WEBHOOK_VERIFY_TOKEN=wo01Maker@1
```

---

## 📁 Estrutura de Arquivos para Upload

### ✅ ARQUIVOS QUE DEVEM SER ENVIADOS:

```
projeto/
├── app/                    # ✅ Toda a pasta app/
│   ├── admin/
│   ├── api/
│   ├── auth/
│   ├── dashboard/
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
│
├── components/             # ✅ Toda a pasta components/
│   ├── admin/
│   ├── backgrounds/
│   ├── dashboard/
│   ├── ui/
│   └── theme-provider.tsx
│
├── hooks/                  # ✅ Toda a pasta hooks/
│   ├── use-mobile.ts
│   └── use-toast.ts
│
├── lib/                    # ✅ Toda a pasta lib/
│   ├── supabase/
│   ├── error-logger.ts
│   ├── supabase.ts
│   ├── types.ts
│   ├── utils.ts
│   └── whatsapp.ts
│
├── public/                 # ✅ Toda a pasta public/
│   ├── *.png
│   ├── *.jpg
│   ├── *.svg
│   └── *.ico
│
├── scripts/                # ✅ Toda a pasta scripts/ (SQL)
│   ├── 001_create_tables.sql
│   ├── 002_enable_rls.sql
│   └── ...
│
├── styles/                 # ✅ Se existir
│   └── globals.css
│
├── middleware.ts           # ✅ Arquivo raiz
├── next.config.mjs         # ✅ Arquivo raiz
├── postcss.config.mjs      # ✅ Arquivo raiz
├── tsconfig.json           # ✅ Arquivo raiz
├── components.json         # ✅ Arquivo raiz
├── package.json            # ✅ Arquivo raiz
└── pnpm-lock.yaml          # ✅ Se usar pnpm (ou package-lock.json se usar npm)
```

### ❌ ARQUIVOS QUE NÃO DEVEM SER ENVIADOS:

```
❌ node_modules/           # Instale no servidor
❌ .next/                 # Será gerado no servidor
❌ .env*                  # Configure no servidor
❌ .git/                  # Não necessário
❌ .vercel/               # Não necessário
❌ *.tsbuildinfo          # Arquivos temporários
❌ next-env.d.ts         # Será gerado automaticamente
❌ npm-debug.log*         # Logs
❌ yarn-debug.log*        # Logs
❌ pnpm-debug.log*        # Logs
```

---

## 🚀 Passo a Passo do Deploy

### PASSO 1: Preparar Arquivos Localmente

1. **Crie uma pasta temporária** para upload:
```bash
mkdir deploy-temp
cd deploy-temp
```

2. **Copie apenas os arquivos necessários**:
```bash
# No Linux/Mac
cp -r ../app .
cp -r ../components .
cp -r ../hooks .
cp -r ../lib .
cp -r ../public .
cp -r ../scripts .
cp ../middleware.ts .
cp ../next.config.mjs .
cp ../postcss.config.mjs .
cp ../tsconfig.json .
cp ../components.json .
cp ../package.json .
cp ../pnpm-lock.yaml .  # ou package-lock.json
```

3. **Verifique se não copiou arquivos desnecessários**:
```bash
# Não deve ter:
ls node_modules  # ❌ Não deve existir
ls .next        # ❌ Não deve existir
ls .env*        # ❌ Não deve existir
```

### PASSO 2: Upload via SFTP

1. **Conecte-se ao servidor SaveInCloud via SFTP**:
   - Host: fornecido pelo SaveInCloud
   - Porta: geralmente 22
   - Usuário: seu usuário SFTP
   - Senha: sua senha SFTP
   - Diretório: geralmente `/home/usuario/public_html` ou `/var/www/html`

2. **Faça upload de TODA a pasta `deploy-temp`** para o diretório do servidor

3. **Verifique as permissões** após o upload:
   - Arquivos: `644` ou `755`
   - Pastas: `755`

### PASSO 3: Configuração no Servidor (via SSH)

1. **Conecte-se via SSH** ao servidor SaveInCloud

2. **Navegue até o diretório do projeto**:
```bash
cd /caminho/para/seu/projeto
```

3. **Instale Node.js** (se não estiver instalado):
```bash
# Verifique a versão
node --version  # Precisa ser 18.x ou superior

# Se não tiver, instale (exemplo para Ubuntu/Debian):
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

4. **Instale pnpm** (se usar pnpm) ou use npm:
```bash
# Para pnpm:
npm install -g pnpm

# Ou use npm diretamente (já vem com Node.js)
```

5. **Instale as dependências**:
```bash
# Se usar pnpm:
pnpm install --production=false

# Se usar npm:
npm install
```

6. **Crie o arquivo .env.local** no servidor:
```bash
nano .env.local
# ou
vi .env.local
```

Cole o conteúdo:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua-chave-anon-key
SUPABASE_SERVICE_ROLE_KEY=sua-service-role-key
WEBHOOK_VERIFY_TOKEN=wo01Maker@1
```

Salve e saia (Ctrl+X, Y, Enter no nano ou :wq no vi)

7. **Faça o build da aplicação**:
```bash
# Se usar pnpm:
pnpm build

# Se usar npm:
npm run build
```

Isso criará a pasta `.next/` com os arquivos otimizados.

8. **Verifique se o build foi bem-sucedido**:
```bash
ls -la .next
# Deve mostrar várias pastas e arquivos
```

### PASSO 4: Configurar o Servidor Web

#### Opção A: Usando PM2 (Recomendado para produção)

1. **Instale o PM2**:
```bash
npm install -g pm2
```

2. **Inicie a aplicação com PM2**:
```bash
pm2 start npm --name "whatsapp-api" -- start
# ou se usar pnpm:
pm2 start pnpm --name "whatsapp-api" -- start
```

3. **Configure PM2 para iniciar automaticamente**:
```bash
pm2 startup
pm2 save
```

4. **Verifique o status**:
```bash
pm2 status
pm2 logs whatsapp-api
```

#### Opção B: Usando systemd (Alternativa)

Crie um arquivo de serviço:
```bash
sudo nano /etc/systemd/system/whatsapp-api.service
```

Cole o conteúdo:
```ini
[Unit]
Description=WhatsApp API Next.js App
After=network.target

[Service]
Type=simple
User=seu-usuario
WorkingDirectory=/caminho/para/seu/projeto
Environment=NODE_ENV=production
ExecStart=/usr/bin/node /caminho/para/seu/projeto/node_modules/.bin/next start
Restart=always

[Install]
WantedBy=multi-user.target
```

Ative o serviço:
```bash
sudo systemctl daemon-reload
sudo systemctl enable whatsapp-api
sudo systemctl start whatsapp-api
sudo systemctl status whatsapp-api
```

#### Opção C: Usando Nginx como Proxy Reverso

1. **Instale o Nginx** (se não tiver):
```bash
sudo apt update
sudo apt install nginx
```

2. **Configure o Nginx**:
```bash
sudo nano /etc/nginx/sites-available/whatsapp-api
```

Cole o conteúdo:
```nginx
server {
    listen 80;
    server_name seu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

3. **Ative o site**:
```bash
sudo ln -s /etc/nginx/sites-available/whatsapp-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

4. **Inicie a aplicação Next.js**:
```bash
# Com PM2 (recomendado):
pm2 start npm --name "whatsapp-api" -- start

# Ou manualmente (não recomendado para produção):
npm start
```

---

## 🔧 Configuração de Variáveis de Ambiente no Servidor

### Método 1: Arquivo .env.local (Recomendado)

```bash
cd /caminho/para/seu/projeto
nano .env.local
```

### Método 2: Variáveis de Sistema (PM2)

Edite o arquivo de configuração do PM2:
```bash
pm2 ecosystem
```

Ou defina diretamente:
```bash
pm2 start npm --name "whatsapp-api" -- start --update-env
```

E configure as variáveis no arquivo `ecosystem.config.js`:
```javascript
module.exports = {
  apps: [{
    name: 'whatsapp-api',
    script: 'npm',
    args: 'start',
    env: {
      NODE_ENV: 'production',
      NEXT_PUBLIC_SUPABASE_URL: 'https://seu-projeto.supabase.co',
      NEXT_PUBLIC_SUPABASE_ANON_KEY: 'sua-chave-anon-key',
      SUPABASE_SERVICE_ROLE_KEY: 'sua-service-role-key',
      WEBHOOK_VERIFY_TOKEN: 'wo01Maker@1'
    }
  }]
}
```

---

## ✅ Verificação Pós-Deploy

1. **Teste se a aplicação está rodando**:
```bash
curl http://localhost:3000
# Deve retornar HTML da página
```

2. **Verifique os logs**:
```bash
# Se usar PM2:
pm2 logs whatsapp-api

# Se usar systemd:
sudo journalctl -u whatsapp-api -f
```

3. **Teste o acesso externo**:
   - Acesse `http://seu-dominio.com` ou `http://seu-ip:3000`
   - Verifique se a página carrega
   - Teste o login

4. **Verifique o webhook** (se configurado):
   - Acesse: `https://seu-dominio.com/api/webhook/whatsapp?hub.mode=subscribe&hub.verify_token=wo01Maker@1&hub.challenge=test`
   - Deve retornar "test"

---

## 🔄 Atualizações Futuras

Para atualizar a aplicação:

1. **Faça upload dos arquivos atualizados via SFTP** (substitua apenas os que mudaram)

2. **No servidor, via SSH**:
```bash
cd /caminho/para/seu/projeto

# Atualize dependências (se package.json mudou):
pnpm install  # ou npm install

# Rebuild:
pnpm build    # ou npm run build

# Reinicie a aplicação:
pm2 restart whatsapp-api
# ou
sudo systemctl restart whatsapp-api
```

---

## 🐛 Troubleshooting

### Erro: "Cannot find module"
```bash
# Reinstale as dependências:
rm -rf node_modules
pnpm install  # ou npm install
```

### Erro: "Port 3000 already in use"
```bash
# Encontre o processo:
lsof -i :3000
# ou
netstat -tulpn | grep 3000

# Mate o processo ou use outra porta:
PORT=3001 npm start
```

### Erro: "Permission denied"
```bash
# Ajuste as permissões:
chmod -R 755 /caminho/para/seu/projeto
chown -R seu-usuario:seu-usuario /caminho/para/seu/projeto
```

### Build falha
```bash
# Verifique os logs:
pnpm build 2>&1 | tee build.log
# ou
npm run build 2>&1 | tee build.log

# Verifique se todas as variáveis de ambiente estão configuradas
cat .env.local
```

### Aplicação não inicia
```bash
# Verifique os logs do PM2:
pm2 logs whatsapp-api --lines 100

# Verifique se o Node.js está instalado:
node --version
npm --version

# Teste manualmente:
npm start
```

---

## 📝 Checklist Final

- [ ] Todos os arquivos enviados via SFTP (exceto node_modules, .next, .env)
- [ ] Node.js 18+ instalado no servidor
- [ ] pnpm ou npm instalado
- [ ] Dependências instaladas (`pnpm install` ou `npm install`)
- [ ] Arquivo `.env.local` criado no servidor
- [ ] Build executado com sucesso (`pnpm build` ou `npm run build`)
- [ ] Aplicação iniciada (PM2, systemd ou manualmente)
- [ ] Nginx configurado (se necessário)
- [ ] Firewall configurado (porta 3000 ou 80/443)
- [ ] Teste de acesso funcionando
- [ ] Webhook testado (se aplicável)

---

## 🔐 Segurança

1. **Nunca envie arquivos .env via SFTP**
2. **Use permissões corretas** (755 para pastas, 644 para arquivos)
3. **Mantenha o Node.js atualizado**
4. **Use HTTPS** (configure SSL no Nginx)
5. **Proteja o arquivo .env.local**:
```bash
chmod 600 .env.local
```

---

## 📞 Comandos Úteis

```bash
# Ver processos Node.js:
ps aux | grep node

# Ver uso de memória:
free -h

# Ver espaço em disco:
df -h

# Ver logs do sistema:
tail -f /var/log/syslog

# Reiniciar Nginx:
sudo systemctl restart nginx

# Status do PM2:
pm2 status
pm2 monit
```

