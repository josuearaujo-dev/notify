# ✅ Checklist Rápido - Deploy via SFTP

## 📋 Pré-Deploy

- [ ] **Variáveis de ambiente preparadas** (anotadas em local seguro)
  - [ ] `NEXT_PUBLIC_SUPABASE_URL`
  - [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  - [ ] `SUPABASE_SERVICE_ROLE_KEY`
  - [ ] `WEBHOOK_VERIFY_TOKEN`

- [ ] **Banco de dados Supabase configurado**
  - [ ] Scripts SQL executados (001 a 012, na ordem)
  - [ ] Primeiro admin criado (email ajustado)
  - [ ] RLS (Row Level Security) ativado

- [ ] **Arquivos preparados para upload**
  - [ ] Execute `./prepare-deploy.sh` (Linux/Mac) ou `.\prepare-deploy.ps1` (Windows)
  - [ ] Pasta `deploy-temp` criada
  - [ ] Verificado que não há `node_modules`, `.next`, `.env*` na pasta

## 📤 Upload via SFTP

- [ ] **Conectado ao servidor SaveInCloud via SFTP**
  - [ ] Host: ___________
  - [ ] Usuário: ___________
  - [ ] Diretório destino: ___________

- [ ] **Upload completo**
  - [ ] Toda a pasta `deploy-temp` enviada
  - [ ] Estrutura de pastas preservada
  - [ ] Permissões corretas (755 pastas, 644 arquivos)

## 🔧 Configuração no Servidor (SSH)

- [ ] **Node.js instalado**
  - [ ] Versão: _____ (deve ser 18+)
  - [ ] Comando: `node --version`

- [ ] **Gerenciador de pacotes instalado**
  - [ ] pnpm: `npm install -g pnpm` OU
  - [ ] npm (já vem com Node.js)

- [ ] **Dependências instaladas**
  - [ ] Comando: `cd /caminho/projeto && pnpm install` ou `npm install`
  - [ ] Sem erros na instalação

- [ ] **Variáveis de ambiente configuradas**
  - [ ] Arquivo `.env.local` criado no servidor
  - [ ] Todas as variáveis preenchidas
  - [ ] Permissões: `chmod 600 .env.local`

- [ ] **Build executado**
  - [ ] Comando: `pnpm build` ou `npm run build`
  - [ ] Build concluído com sucesso
  - [ ] Pasta `.next/` criada

## 🚀 Inicialização

- [ ] **PM2 instalado e configurado**
  - [ ] `npm install -g pm2`
  - [ ] `pm2 start npm --name "whatsapp-api" -- start`
  - [ ] `pm2 startup` e `pm2 save`

- [ ] **OU systemd configurado** (alternativa)
  - [ ] Arquivo de serviço criado
  - [ ] Serviço ativado e iniciado

- [ ] **OU Nginx configurado** (se usar proxy reverso)
  - [ ] Configuração criada
  - [ ] Site ativado
  - [ ] Nginx reiniciado

## ✅ Verificação

- [ ] **Aplicação rodando**
  - [ ] `curl http://localhost:3000` retorna HTML
  - [ ] Logs sem erros: `pm2 logs whatsapp-api`

- [ ] **Acesso externo funcionando**
  - [ ] URL: http://___________
  - [ ] Página carrega corretamente
  - [ ] Login funciona

- [ ] **Webhook testado** (se aplicável)
  - [ ] URL: https://___________/api/webhook/whatsapp
  - [ ] Verificação funcionando

## 🔄 Próximas Atualizações

Para atualizar no futuro:

1. [ ] Fazer upload dos arquivos atualizados via SFTP
2. [ ] No servidor: `cd /caminho/projeto`
3. [ ] `pnpm install` (se package.json mudou)
4. [ ] `pnpm build`
5. [ ] `pm2 restart whatsapp-api`

---

## 📞 Comandos Úteis

```bash
# Ver status da aplicação
pm2 status
pm2 logs whatsapp-api

# Reiniciar aplicação
pm2 restart whatsapp-api

# Ver processos Node.js
ps aux | grep node

# Ver logs do sistema
tail -f /var/log/syslog

# Verificar porta 3000
lsof -i :3000
```

---

## 🐛 Problemas Comuns

- **"Cannot find module"** → Execute `pnpm install` novamente
- **"Port 3000 in use"** → Verifique processos: `lsof -i :3000`
- **"Permission denied"** → Ajuste permissões: `chmod -R 755 /caminho`
- **Build falha** → Verifique variáveis de ambiente: `cat .env.local`

---

**📚 Documentação completa:**
- [DEPLOY_SFTP.md](./DEPLOY_SFTP.md) - Guia detalhado
- [DEPLOY_SAVEINCLOUD.md](./DEPLOY_SAVEINCLOUD.md) - Visão geral

