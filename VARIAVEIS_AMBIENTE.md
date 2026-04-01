# 🔐 Variáveis de Ambiente - SaveInCloud

## ✅ Variáveis Obrigatórias (4)

Você **DEVE** cadastrar estas 4 variáveis no SaveInCloud:

### 1. `NEXT_PUBLIC_SUPABASE_URL`
**Tipo**: Pública (pode ser acessada no navegador)  
**Descrição**: URL do seu projeto Supabase  
**Onde obter**: 
- Acesse [supabase.com](https://supabase.com)
- Vá em **Settings > API**
- Copie o **Project URL**

**Exemplo**:
```
https://abcdefghijklmnop.supabase.co
```

---

### 2. `NEXT_PUBLIC_SUPABASE_ANON_KEY`
**Tipo**: Pública (pode ser acessada no navegador)  
**Descrição**: Chave pública anônima do Supabase (segura para uso no frontend)  
**Onde obter**:
- Acesse [supabase.com](https://supabase.com)
- Vá em **Settings > API**
- Copie a chave **anon public**

**Exemplo**:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYxNjIzOTAyMiwiZXhwIjoxOTMxODE1MDIyfQ.abcdefghijklmnopqrstuvwxyz1234567890
```

---

### 3. `SUPABASE_SERVICE_ROLE_KEY`
**Tipo**: 🔒 **PRIVADA** (NÃO use `NEXT_PUBLIC_` aqui!)  
**Descrição**: Chave de service role do Supabase (acesso total ao banco)  
**Onde obter**:
- Acesse [supabase.com](https://supabase.com)
- Vá em **Settings > API**
- Copie a chave **service_role** (⚠️ MANTENHA SECRETA!)

**Exemplo**:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNjE2MjM5MDIyLCJleHAiOjE5MzE4MTUwMjJ9.abcdefghijklmnopqrstuvwxyz1234567890
```

⚠️ **IMPORTANTE**: Esta chave tem acesso total ao banco de dados. Nunca a exponha no frontend!

---

### 4. `WEBHOOK_VERIFY_TOKEN`
**Tipo**: 🔒 Privada  
**Descrição**: Token usado para verificar o webhook do WhatsApp  
**Valor padrão**: `wo01Maker@1` (se não configurar, usa este)  
**Recomendação**: Altere para um token mais seguro

**Exemplo**:
```
wo01Maker@1
```

**Ou crie um token mais seguro**:
```
MeuTokenSeguro2024!@#WhatsApp
```

---

## 📋 Variável Recomendada (1)

### 5. `NODE_ENV`
**Tipo**: Privada  
**Descrição**: Define o ambiente de execução  
**Valor**: `production`  
**Por quê**: Otimiza a aplicação para produção

**Exemplo**:
```
production
```

---

## 📝 Como Cadastrar no SaveInCloud

1. **Na interface do SaveInCloud**, clique na aba **"{...} Variáveis"**
2. Clique em **"Adicionar"** ou **"+"**
3. Para cada variável:
   - **Nome**: Digite o nome exatamente como mostrado acima
   - **Valor**: Cole o valor correspondente
   - **Tipo**: 
     - Variáveis com `NEXT_PUBLIC_` → Marque como **Pública** (se houver opção)
     - Outras → Marque como **Privada** ou deixe padrão

---

## ✅ Checklist de Variáveis

Marque conforme for cadastrando:

- [ ] `NEXT_PUBLIC_SUPABASE_URL` - URL do Supabase
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Chave anon do Supabase
- [ ] `SUPABASE_SERVICE_ROLE_KEY` - Chave service_role do Supabase
- [ ] `WEBHOOK_VERIFY_TOKEN` - Token do webhook (ou use o padrão)
- [ ] `NODE_ENV` - Definido como `production`

---

## 🔍 Onde Cada Variável é Usada

### `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- ✅ Autenticação de usuários
- ✅ Consultas ao banco de dados (com RLS)
- ✅ Usado no frontend e backend

**Arquivos que usam**:
- `lib/supabase/client.ts`
- `lib/supabase/server.ts`
- `lib/supabase/middleware.ts`
- `components/dashboard/messages-monitor.tsx`

### `SUPABASE_SERVICE_ROLE_KEY`
- ✅ Webhook do WhatsApp (sem contexto de usuário)
- ✅ Criação de usuários pelo admin
- ✅ Logs de erro
- ✅ Operações administrativas

**Arquivos que usam**:
- `app/api/webhook/whatsapp/route.ts`
- `app/api/admin/create-user/route.ts`
- `lib/error-logger.ts`

### `WEBHOOK_VERIFY_TOKEN`
- ✅ Verificação do webhook do WhatsApp
- ✅ Segurança do endpoint `/api/webhook/whatsapp`

**Arquivo que usa**:
- `app/api/webhook/whatsapp/route.ts`

---

## 🚨 Erros Comuns

### "NEXT_PUBLIC_SUPABASE_URL is not defined"
- ✅ Verifique se a variável está cadastrada
- ✅ Verifique se o nome está exatamente como mostrado (case-sensitive)
- ✅ Verifique se não há espaços extras

### "Cannot connect to Supabase"
- ✅ Verifique se a URL está correta (começa com `https://`)
- ✅ Verifique se o projeto Supabase está ativo
- ✅ Verifique se as chaves estão corretas

### "Unauthorized" ou "Permission denied"
- ✅ Verifique se `SUPABASE_SERVICE_ROLE_KEY` está correta
- ✅ Verifique se as políticas RLS estão configuradas no Supabase

---

## 📋 Resumo Rápido

Copie e cole no SaveInCloud (substitua pelos seus valores):

```
NEXT_PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua-chave-anon-key
SUPABASE_SERVICE_ROLE_KEY=sua-service-role-key
WEBHOOK_VERIFY_TOKEN=wo01Maker@1
NODE_ENV=production
```

---

## 🔗 Links Úteis

- [Documentação Supabase - API Keys](https://supabase.com/docs/guides/api/api-keys)
- [Next.js - Environment Variables](https://nextjs.org/docs/basic-features/environment-variables)
- [CONFIGURACAO_SAVEINCLOUD.md](./CONFIGURACAO_SAVEINCLOUD.md) - Guia completo de configuração

