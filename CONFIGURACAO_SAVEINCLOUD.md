# 🚀 Configuração do Ambiente no SaveInCloud

## 📋 Configurações na Interface

### 1. **Versão do Node.js**
- ✅ **Node.js**: `25.2.1` (ou a versão mais recente disponível)
- ✅ **Process Manager**: `25.2.1-pm2` (PM2 já vem configurado!)

### 2. **Recursos (Cloudlets)**
- **Reservado**: 4 Cloudlets (512 MiB, 1.6 GHz) - Mínimo recomendado
- **Limite de Escala**: Até 8 Cloudlets (Até 1 GiB, 3.2 GHz) - Para picos de tráfego
- **Disco**: 30 GB (suficiente para o projeto)

### 3. **Escalonamento Horizontal**
- **Instâncias**: Comece com `1` (pode aumentar depois se necessário)
- **Stateful**: Deixe como está (geralmente "Stateless" para Next.js)

### 4. **Configurações de Rede**
- ✅ **Acesso via SLB**: `ON` (Load Balancer ativado)
- ⚠️ **IPv4 público**: `OFF` (use o SLB)
- ⚠️ **IPv6 público**: `OFF` (use o SLB)

---

## 🔧 Configuração das Variáveis de Ambiente

### Passo 1: Acesse a Aba "Variáveis"

Na interface do SaveInCloud, clique na aba **"{...} Variáveis"** na parte inferior do painel de configuração do servidor.

### Passo 2: Adicione as Variáveis

Clique em **"Adicionar"** ou **"+"** e adicione cada variável:

#### Variáveis Obrigatórias:

```bash
NEXT_PUBLIC_SUPABASE_URL
https://seu-projeto.supabase.co

NEXT_PUBLIC_SUPABASE_ANON_KEY
sua-chave-anon-key-aqui

SUPABASE_SERVICE_ROLE_KEY
sua-service-role-key-aqui

WEBHOOK_VERIFY_TOKEN
wo01Maker@1

NODE_ENV
production
```

### Passo 3: Verifique as Variáveis

Certifique-se de que:
- ✅ Todas as variáveis estão com os valores corretos
- ✅ Não há espaços extras antes/depois dos valores
- ✅ As variáveis `NEXT_PUBLIC_*` estão marcadas como públicas (se houver opção)

---

## 📤 Deploy dos Arquivos

### Opção 1: Via Interface do SaveInCloud (Git)

Se o SaveInCloud suportar integração com Git:

1. Faça push do seu código para um repositório Git (GitHub, GitLab, etc.)
2. Configure o repositório na interface do SaveInCloud
3. O SaveInCloud fará o build automaticamente

### Opção 2: Via SFTP (Manual)

1. **Conecte-se via SFTP** usando as credenciais fornecidas pelo SaveInCloud
2. **Faça upload da pasta `deploy-temp`** completa para o diretório do ambiente
3. **Estrutura esperada no servidor**:
   ```
   /caminho/do/ambiente/
   ├── app/
   ├── components/
   ├── lib/
   ├── public/
   ├── package.json
   ├── next.config.mjs
   └── ... (todos os arquivos)
   ```

---

## 🔨 Build e Inicialização Automática

O SaveInCloud com PM2 geralmente executa automaticamente:

1. **Instalação de dependências**: `npm install` ou `pnpm install`
2. **Build**: `npm run build` ou `pnpm build`
3. **Inicialização**: `npm start` ou `pm2 start`

### Se precisar configurar manualmente:

No SaveInCloud, procure por:
- **Build Command**: `pnpm build` ou `npm run build`
- **Start Command**: `pnpm start` ou `npm start`
- **Working Directory**: Deixe vazio ou `/` (raiz do ambiente)

---

## ✅ Checklist de Configuração

Antes de clicar em **"Criar"**:

- [ ] **Node.js**: Versão 25.2.1 (ou superior) selecionada
- [ ] **PM2**: Process manager selecionado
- [ ] **Recursos**: 4 Cloudlets reservados, até 8 no limite
- [ ] **Disco**: 30 GB configurado
- [ ] **Variáveis de ambiente**: Todas as 5 variáveis adicionadas
  - [ ] `NEXT_PUBLIC_SUPABASE_URL`
  - [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  - [ ] `SUPABASE_SERVICE_ROLE_KEY`
  - [ ] `WEBHOOK_VERIFY_TOKEN`
  - [ ] `NODE_ENV=production`
- [ ] **SLB**: Ativado (ON)
- [ ] **Arquivos**: Prontos para upload via SFTP ou Git configurado

---

## 🚀 Após Criar o Ambiente

### 1. Aguarde a Criação
- O SaveInCloud criará o ambiente (pode levar alguns minutos)
- Você receberá uma URL: `env-4937656.sp1.br.saveincloud.net.br`

### 2. Faça Upload dos Arquivos (se via SFTP)
- Conecte-se via SFTP
- Faça upload da pasta `deploy-temp` completa
- Aguarde o build automático

### 3. Verifique os Logs
- No painel do SaveInCloud, acesse **"Logs"** ou **"Console"**
- Verifique se:
  - ✅ Dependências foram instaladas
  - ✅ Build foi concluído com sucesso
  - ✅ Aplicação está rodando na porta correta

### 4. Teste a Aplicação
- Acesse a URL fornecida: `https://env-4937656.sp1.br.saveincloud.net.br`
- Verifique se a página carrega
- Teste o login

---

## 🔍 Troubleshooting

### Build Falha
- Verifique os logs no painel do SaveInCloud
- Certifique-se de que todas as variáveis de ambiente estão configuradas
- Verifique se o `package.json` está correto

### Aplicação Não Inicia
- Verifique os logs do PM2 no painel
- Certifique-se de que a porta está configurada corretamente
- Verifique se o build foi concluído com sucesso

### Variáveis de Ambiente Não Funcionam
- Certifique-se de que as variáveis `NEXT_PUBLIC_*` estão marcadas como públicas
- Reinicie o ambiente após adicionar variáveis
- Verifique se não há espaços extras nos valores

### Erro de Conexão com Supabase
- Verifique se as URLs e chaves do Supabase estão corretas
- Teste a conexão do Supabase localmente primeiro
- Verifique os logs de erro no painel

---

## 📝 Notas Importantes

1. **PM2 já está configurado**: O SaveInCloud já vem com PM2, então não precisa instalar manualmente

2. **Build Automático**: O SaveInCloud geralmente faz o build automaticamente após o upload dos arquivos

3. **Variáveis de Ambiente**: Configure ANTES de fazer o build, pois o Next.js precisa delas durante o build

4. **Domínio Personalizado**: Depois de criar o ambiente, você pode configurar um domínio personalizado no painel do SaveInCloud

5. **SSL/HTTPS**: O SaveInCloud geralmente fornece SSL automático via Let's Encrypt

---

## 🔗 Próximos Passos

Após o ambiente estar rodando:

1. ✅ Configure o domínio personalizado (se necessário)
2. ✅ Configure o webhook do WhatsApp com a URL do ambiente
3. ✅ Execute os scripts SQL no Supabase (se ainda não fez)
4. ✅ Teste todas as funcionalidades
5. ✅ Configure monitoramento e alertas (se disponível)

---

## 💡 Dicas

- **Comece com recursos mínimos** (4 Cloudlets) e aumente se necessário
- **Monitore o uso de recursos** no painel do SaveInCloud
- **Use os logs** para diagnosticar problemas
- **Faça backup** das variáveis de ambiente em local seguro
- **Teste localmente primeiro** antes de fazer deploy

---

**📚 Documentação Relacionada:**
- [DEPLOY_SFTP.md](./DEPLOY_SFTP.md) - Guia completo de deploy via SFTP
- [CHECKLIST-DEPLOY.md](./CHECKLIST-DEPLOY.md) - Checklist rápido

