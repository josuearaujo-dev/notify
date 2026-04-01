# Guia de Deploy - SaveInCloud

> **💡 Para deploy manual via SFTP**, consulte o guia detalhado: [DEPLOY_SFTP.md](./DEPLOY_SFTP.md)

## 📋 Requisitos do Projeto

Este é um projeto **Next.js 16** com TypeScript que utiliza:
- **Supabase** para autenticação e banco de dados
- **WhatsApp Business API** para envio de mensagens
- **React 19** com App Router
- **Tailwind CSS 4** para estilização

---

## 🔧 Variáveis de Ambiente Necessárias

Crie um arquivo `.env.local` ou configure as variáveis no painel do SaveInCloud:

```bash
# Supabase - Obrigatórias
NEXT_PUBLIC_SUPABASE_URL=https://seu-projeto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua-chave-anon-key
SUPABASE_SERVICE_ROLE_KEY=sua-service-role-key

# Webhook WhatsApp - Opcional (tem valor padrão)
WEBHOOK_VERIFY_TOKEN=wo01Maker@1
```

### Como obter as credenciais do Supabase:

1. Acesse [supabase.com](https://supabase.com)
2. Crie um projeto ou use um existente
3. Vá em **Settings > API**
4. Copie:
   - **Project URL** → `NEXT_PUBLIC_SUPABASE_URL`
   - **anon public** key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - **service_role** key → `SUPABASE_SERVICE_ROLE_KEY` (mantenha secreta!)

---

## 🗄️ Configuração do Banco de Dados

### 1. Execute os scripts SQL na ordem:

Os scripts estão em `/scripts/` e devem ser executados nesta ordem:

1. `001_create_tables.sql` - Cria todas as tabelas
2. `002_enable_rls.sql` - Configura Row Level Security
3. `003_create_trigger.sql` - Triggers de atualização
4. `004_create_first_admin.sql` - Cria primeiro admin (ajuste o email!)
5. `005_create_profile_trigger.sql` - Trigger de perfil
6. `006_fix_existing_users.sql` - Correção de usuários existentes
7. `007_add_template_text_column.sql` - Coluna de texto do template
8. `008_add_metadata_column.sql` - Coluna de metadata
9. `009_add_verify_token.sql` - Token de verificação
10. `010_create_error_logs.sql` - Tabela de logs de erro
11. `012_add_id_pax_servico.sql` - Campo adicional

**Como executar:**
- No Supabase: vá em **SQL Editor** e execute cada script na ordem
- Ou use a CLI do Supabase: `supabase db push`

### 2. Ajuste o primeiro admin:

No script `004_create_first_admin.sql`, altere o email para o seu:
```sql
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at, ...)
VALUES ('seu-email@exemplo.com', ...);
```

---

## 🚀 Configuração no SaveInCloud

### 1. Build Settings

- **Framework**: Next.js
- **Node Version**: 18.x ou superior (recomendado: 20.x)
- **Build Command**: `pnpm build` ou `npm run build`
- **Start Command**: `pnpm start` ou `npm start`
- **Output Directory**: `.next` (padrão do Next.js)

### 2. Instalação de Dependências

O projeto usa **pnpm** (recomendado) ou **npm**:

```bash
# Se usar pnpm
pnpm install

# Se usar npm
npm install
```

### 3. Variáveis de Ambiente

Configure todas as variáveis listadas acima no painel do SaveInCloud:
- **Settings > Environment Variables**
- Adicione cada variável com seu valor correspondente

---

## 📦 Dependências do Sistema

O projeto requer:
- **Node.js**: 18.x ou superior
- **pnpm** ou **npm**: para gerenciamento de pacotes

### Principais dependências (já no package.json):
- `next`: 16.0.10
- `react`: 19.2.0
- `@supabase/ssr`: 0.8.0
- `@supabase/supabase-js`: 2.86.2
- `tailwindcss`: 4.1.9

---

## 🔐 Segurança

### Variáveis Sensíveis:
- ✅ `NEXT_PUBLIC_SUPABASE_URL` - Pode ser pública (precisa do prefixo NEXT_PUBLIC_)
- ✅ `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Pode ser pública (precisa do prefixo NEXT_PUBLIC_)
- 🔒 `SUPABASE_SERVICE_ROLE_KEY` - **MANTENHA SECRETA** (não use NEXT_PUBLIC_)
- 🔒 `WEBHOOK_VERIFY_TOKEN` - **MANTENHA SECRETA** (não use NEXT_PUBLIC_)

### RLS (Row Level Security):
O projeto usa Row Level Security do Supabase. Certifique-se de que o script `002_enable_rls.sql` foi executado corretamente.

---

## 🌐 Configuração de Webhook (WhatsApp)

### URL do Webhook:
```
https://seu-dominio.saveincloud.com/api/webhook/whatsapp
```

### Configuração no Meta/Facebook:
1. Acesse o [Meta for Developers](https://developers.facebook.com)
2. Vá em **WhatsApp > Configuration**
3. Configure o webhook com:
   - **Callback URL**: `https://seu-dominio.saveincloud.com/api/webhook/whatsapp`
   - **Verify Token**: O valor de `WEBHOOK_VERIFY_TOKEN` (padrão: `wo01Maker@1`)

---

## ✅ Checklist de Deploy

Antes de fazer o deploy, verifique:

- [ ] Todas as variáveis de ambiente configuradas no SaveInCloud
- [ ] Scripts SQL executados no Supabase (na ordem correta)
- [ ] Primeiro admin criado com email válido
- [ ] Build local funcionando (`pnpm build`)
- [ ] Teste local funcionando (`pnpm dev`)
- [ ] Webhook configurado no Meta (se usar WhatsApp)
- [ ] Domínio configurado no SaveInCloud (se necessário)

---

## 🐛 Troubleshooting

### Erro: "NEXT_PUBLIC_SUPABASE_URL is not defined"
- Verifique se a variável está configurada no SaveInCloud
- Certifique-se de que o nome está correto (com `NEXT_PUBLIC_`)

### Erro: "Cannot connect to Supabase"
- Verifique se a URL do Supabase está correta
- Verifique se o projeto Supabase está ativo
- Verifique as políticas RLS

### Erro: "Build failed"
- Verifique a versão do Node.js (deve ser 18+)
- Execute `pnpm install` localmente para verificar dependências
- Verifique os logs de build no SaveInCloud

### Webhook não funciona
- Verifique se a URL está acessível publicamente
- Verifique se o `WEBHOOK_VERIFY_TOKEN` está correto
- Verifique os logs do servidor no SaveInCloud

---

## 📝 Notas Adicionais

1. **Imagens**: O projeto tem `images: { unoptimized: true }` no `next.config.mjs`, então não precisa de otimização de imagens no servidor.

2. **TypeScript**: O build ignora erros de TypeScript (`ignoreBuildErrors: true`), mas é recomendado corrigir antes do deploy em produção.

3. **Analytics**: O projeto usa Vercel Analytics. Se não usar Vercel, pode remover o componente `<Analytics />` do `app/layout.tsx`.

4. **PWA**: O projeto parece ser um PWA (baseado na memória). Certifique-se de que o SaveInCloud suporta service workers se necessário.

---

## 🔗 Links Úteis

- [Documentação Next.js](https://nextjs.org/docs)
- [Documentação Supabase](https://supabase.com/docs)
- [WhatsApp Business API](https://developers.facebook.com/docs/whatsapp)
- [SaveInCloud Documentation](https://saveincloud.com/docs) (verifique a documentação oficial)

---

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs no painel do SaveInCloud
2. Verifique os logs do Supabase (Dashboard > Logs)
3. Teste localmente primeiro (`pnpm dev`)
4. Verifique se todas as variáveis de ambiente estão corretas

