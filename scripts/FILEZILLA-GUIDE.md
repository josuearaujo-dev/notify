# Guia de Upload via FileZilla

Este guia mostra como fazer upload da aplicação usando FileZilla de forma eficiente.

## 🚀 Preparação Rápida

### 1. Execute o script de preparação:
```bash
./scripts/prepare-for-filezilla.sh
```

Isso criará uma pasta `deploy-ready` com todos os arquivos prontos para upload.

## 📤 Upload no FileZilla

### Método 1: Upload Simples (Arrastar e Soltar)

1. **Abra o FileZilla**
2. **Conecte-se ao servidor:**
   - Host: `seu-servidor.com`
   - Usuário: `seu-usuario`
   - Senha: `sua-senha`
   - Porta: `21` (FTP) ou `22` (SFTP)

3. **Navegue até o diretório remoto** no painel direito (servidor)
   - Exemplo: `/home/usuario/public_html`

4. **No painel esquerdo (local)**, navegue até a pasta `deploy-ready`

5. **Arraste a pasta `deploy-ready`** para o diretório remoto no painel direito

6. **Aguarde o upload concluir**

### Método 2: Sincronização (Recomendado - Mais Rápido)

A sincronização atualiza apenas os arquivos que mudaram, economizando tempo:

1. **Conecte-se ao servidor** no FileZilla

2. **Navegue até o diretório remoto** no servidor

3. **No menu superior**, clique em **"Servidor" → "Sincronizar diretórios"** (ou pressione `Ctrl+S`)

4. **Configure a sincronização:**
   - **Diretório local:** Selecione a pasta `deploy-ready` do seu computador
   - **Diretório remoto:** Selecione o diretório no servidor onde os arquivos devem estar
   - **Direção:** Escolha "Comparar diretórios" e depois "Upload" ou "Sincronizar"

5. **Revise as mudanças** na lista de arquivos que serão transferidos

6. **Clique em "OK"** para iniciar a sincronização

### Método 3: Upload Seletivo

Se você só modificou alguns arquivos específicos:

1. **Conecte-se ao servidor**

2. **Navegue até os diretórios correspondentes** em ambos os painéis

3. **Selecione apenas os arquivos/pastas modificados** no painel local

4. **Arraste para o servidor** ou clique com botão direito → "Upload"

## ⚙️ Configurações Recomendadas do FileZilla

### 1. Aumentar Conexões Simultâneas

Para uploads mais rápidos:

1. **Editar → Configurações → Transferências**
2. **Número máximo de transferências simultâneas:** `10` (ou mais, dependendo do servidor)
3. **Clique em "OK"**

### 2. Filtrar Arquivos Desnecessários

Para evitar uploads acidentais de arquivos que não devem ser enviados:

1. **Editar → Configurações → Transferências → Filtros de transferência**
2. **Adicione filtros de exclusão:**
   ```
   node_modules
   .next
   .env*
   .git
   *.log
   *.tsbuildinfo
   ```
3. **Clique em "OK"**

### 3. Salvar Conexão para Reutilização

1. **Arquivo → Gerenciador de Sites** (ou `Ctrl+S`)
2. **Clique em "Novo Site"**
3. **Preencha:**
   - Protocolo: `SFTP - SSH File Transfer Protocol` (recomendado) ou `FTP - File Transfer Protocol`
   - Host: `seu-servidor.com`
   - Porta: `22` (SFTP) ou `21` (FTP)
   - Tipo de login: `Normal`
   - Usuário: `seu-usuario`
   - Senha: `sua-senha`
4. **Clique em "Conectar"** ou **"OK"** para salvar

Na próxima vez, basta selecionar o site salvo e clicar em "Conectar".

## 🔄 Workflow Recomendado

### Primeira vez (Deploy completo):
```bash
# 1. Preparar arquivos
./scripts/prepare-for-filezilla.sh

# 2. No FileZilla:
#    - Conecte-se ao servidor
#    - Arraste a pasta deploy-ready inteira para o servidor
```

### Atualizações (Apenas arquivos modificados):
```bash
# 1. Preparar arquivos
./scripts/prepare-for-filezilla.sh

# 2. No FileZilla:
#    - Conecte-se ao servidor
#    - Use "Sincronizar diretórios" para atualizar apenas o que mudou
```

## 📋 Checklist Pós-Upload

Após fazer o upload, você precisa executar comandos no servidor via SSH:

1. **Conecte-se via SSH:**
   ```bash
   ssh usuario@servidor.com
   ```

2. **Navegue até o diretório:**
   ```bash
   cd /home/usuario/public_html
   ```

3. **Instale dependências** (se package.json mudou):
   ```bash
   pnpm install
   # ou
   npm install
   ```

4. **Faça o build:**
   ```bash
   pnpm build
   # ou
   npm run build
   ```

5. **Reinicie a aplicação** (se usar PM2):
   ```bash
   pm2 restart whatsapp-api
   ```

## 🐛 Troubleshooting

### Upload muito lento
- Use SFTP ao invés de FTP (mais seguro e geralmente mais rápido)
- Aumente o número de conexões simultâneas nas configurações
- Verifique sua conexão de internet

### Erro de permissão
- Verifique as permissões do diretório no servidor: `chmod 755 /caminho/do/diretorio`
- Certifique-se de que o usuário FTP tem permissão de escrita

### Arquivos não aparecem no servidor
- Verifique se o upload foi concluído (barra de progresso)
- Recarregue a visualização do diretório no FileZilla (F5)
- Verifique se você está no diretório correto

### Arquivos .env foram enviados acidentalmente
- Delete-os manualmente do servidor via FileZilla
- Configure filtros de exclusão no FileZilla (veja acima)
- O script de preparação já remove arquivos .env automaticamente

## 💡 Dicas

1. **Use SFTP ao invés de FTP** - Mais seguro e geralmente mais rápido
2. **Salve suas conexões** - Economiza tempo nas próximas vezes
3. **Use sincronização** - Atualiza apenas o que mudou, muito mais rápido
4. **Verifique antes de enviar** - Revise a lista de arquivos antes de confirmar o upload
5. **Faça backup** - Antes de atualizar em produção, faça backup dos arquivos antigos

## 🔐 Segurança

- ⚠️ **NUNCA** envie arquivos `.env` ou `.env.local`
- ⚠️ **NUNCA** envie a pasta `node_modules` (instale no servidor)
- ⚠️ **NUNCA** envie a pasta `.next` (faça build no servidor)
- ✅ Use SFTP ao invés de FTP quando possível
- ✅ Mantenha suas credenciais seguras
