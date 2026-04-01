/**
 * Document mínimo do Pages Router.
 * Necessário para que 404 e _error sejam renderizados corretamente no build
 * (o Html deve ser usado apenas aqui).
 */
import { Html, Head, Main, NextScript } from "next/document"

export default function Document() {
  return (
    <Html lang="pt-BR">
      <Head />
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  )
}
