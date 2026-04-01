# Build no servidor (Jelastic / FTP)

O projeto **precisa usar Next.js 15** no servidor. Se o servidor estiver com Next.js 16, o build falha no prerender de `/_global-error`.

## Arquivos obrigatórios no servidor

- **`package.json`** (com `"next": "15.1.6"` e `"overrides"`)
- **`next.config.mjs`** – **não** pode ter a chave `turbopack` (Next 15 não usa). Se no servidor aparecer aviso "Unrecognized key(s): 'turbopack'", apague essa chave do `next.config.mjs`.
- **Pasta `pages/`** com estes 3 arquivos (o 404 fica no App Router em `app/404/page.tsx`):
  - `pages/_app.js`
  - `pages/_document.js`
  - `pages/_error.js`

- **`app/404/page.tsx`** – rota /404 no App Router (evita conflito com Pages Router).

## Passos obrigatórios no servidor

```bash
cd /home/jelastic/ROOT

# 1. Remover dependências e lock antigos (evita Next 16)
rm -rf node_modules .next package-lock.json

# 2. Instalar de novo (vai usar Next 15 do package.json + overrides)
npm install --legacy-peer-deps

# 3. Build
npm run build

# 4. Reiniciar
pm2 restart whatsapp-api
```

## Conferir versão do Next

Antes do build, confira se o Next é 15:

```bash
npm list next
# Deve mostrar next@15.1.6 (ou 15.x)
```

Se aparecer **16.x**, o `package.json` no servidor está desatualizado. Envie de novo o `package.json` do projeto (com `"next": "15.1.6"` e a seção `"overrides"`) e repita os passos acima.
