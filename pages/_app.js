/**
 * App wrapper do Pages Router (necessário para 404 e _error usarem nosso _document).
 */
export default function App({ Component, pageProps }) {
  return <Component {...pageProps} />
}
