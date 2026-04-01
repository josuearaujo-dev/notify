# Script de Deploy Automático via FTP/SFTP

Este script automatiza o processo de deploy da aplicação para um servidor via FTP ou SFTP.

## 📋 Pré-requisitos

### macOS
```bash
brew install lftp
```

### Ubuntu/Debian
```bash
sudo apt-get install lftp
```

### Windows (WSL ou Git Bash)
```bash
# No WSL ou Git Bash
sudo apt-get install lftp
```

## 🚀 Configuração Inicial

1. **Copie o arquivo de exemplo de configuração:**
   ```bash
   cp deploy-ftp.conf.example deploy-ftp.conf
   ```

2. **Edite o arquivo `deploy-ftp.conf`** com suas credenciais:
   ```bash
   nano deploy-ftp.conf
   # ou
   code deploy-ftp.conf
   ```

3. **Preencha as informações obrigatórias:**
   - `FTP_HOST`: Endereço do servidor
   - `FTP_USER`: Usuário FTP
   - `FTP_PASS`: Senha FTP
   - `FTP_REMOTE_DIR`: Diretório remoto onde os arquivos serão enviados

## 📖 Uso

### Deploy básico
```bash
./scripts/deploy-ftp.sh
```

### Deploy com arquivo de configuração customizado
```bash
./scripts/deploy-ftp.sh --config=minha-config.conf
```

### Teste (dry-run) - não faz upload real
```bash
./scripts/deploy-ftp.sh --dry-run
```

## 🔧 Configurações Disponíveis

### FTP/SFTP (Obrigatórias)
- `FTP_TYPE`: Tipo de conexão (`ftp` ou `sftp`)
- `FTP_HOST`: Host do servidor
- `FTP_PORT`: Porta (padrão: 21 para FTP, 22 para SFTP)
- `FTP_USER`: Usuário
- `FTP_PASS`: Senha
- `FTP_REMOTE_DIR`: Diretório remoto

### SSH (Opcionais - para executar comandos após upload)
- `SSH_HOST`: Host SSH
- `SSH_USER`: Usuário SSH
- `SSH_PORT`: Porta SSH (padrão: 22)
- `SSH_KEY`: Caminho para chave privada SSH (opcional)
- `SSH_COMMANDS`: Comandos a executar (separados por `;`)

### Outras Opções
- `CLEANUP_AFTER_DEPLOY`: Limpar diretório temporário após deploy (`true`/`false`)

## 📝 Exemplo de Configuração Completa

```bash
# deploy-ftp.conf
FTP_TYPE="sftp"
FTP_HOST="meuservidor.com"
FTP_PORT="22"
FTP_USER="usuario"
FTP_PASS="senha123"
FTP_REMOTE_DIR="/home/usuario/public_html"

# Executar comandos após upload
SSH_HOST="meuservidor.com"
SSH_USER="usuario"
SSH_PORT="22"
SSH_COMMANDS="cd /home/usuario/public_html && pnpm install && pnpm build && pm2 restart whatsapp-api"

CLEANUP_AFTER_DEPLOY="true"
```

## 🔒 Segurança

⚠️ **IMPORTANTE**: 
- O arquivo `deploy-ftp.conf` contém credenciais sensíveis
- **NUNCA** commite este arquivo no git
- Ele já está no `.gitignore` para sua proteção
- Mantenha as permissões restritas: `chmod 600 deploy-ftp.conf`

## 🐛 Troubleshooting

### Erro: "lftp não encontrado"
Instale o lftp conforme as instruções acima.

### Erro: "Permission denied"
Verifique as permissões do diretório remoto no servidor.

### Erro: "Connection refused"
Verifique se o host, porta e credenciais estão corretos.

### Upload funciona mas comandos SSH falham
- Verifique se o SSH está configurado corretamente
- Teste a conexão SSH manualmente: `ssh usuario@servidor`
- Verifique se os comandos estão corretos

## 📚 O que o script faz?

1. **Prepara arquivos localmente:**
   - Cria diretório temporário `deploy-temp`
   - Copia apenas arquivos necessários (app, components, lib, etc.)
   - Exclui node_modules, .next, .env, etc.

2. **Faz upload via FTP/SFTP:**
   - Usa lftp para upload recursivo
   - Sincroniza arquivos com o servidor

3. **Executa comandos no servidor (opcional):**
   - Conecta via SSH
   - Executa comandos configurados (ex: instalar dependências, build, restart)

4. **Limpa arquivos temporários:**
   - Remove diretório temporário local

## 💡 Dicas

- Use `--dry-run` primeiro para verificar o que será enviado
- Configure `SSH_COMMANDS` para automatizar instalação e build no servidor
- Mantenha backups antes de fazer deploy em produção
- Teste em ambiente de staging primeiro
