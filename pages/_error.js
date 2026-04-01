/**
 * Substitui o _error padrão do Next (que usa Html de next/document e quebra o build).
 * Usado apenas para o prerender de rotas como /404; não importa next/document.
 */
function Error({ statusCode }) {
  const message =
    statusCode === 404
      ? "Página não encontrada"
      : statusCode
        ? `Ocorreu um erro ${statusCode}`
        : "Ocorreu um erro no cliente"
  return (
    <div style={{ padding: 20, textAlign: "center", fontFamily: "system-ui" }}>
      <h1 style={{ fontSize: 24, marginBottom: 16 }}>{message}</h1>
      <a href="/" style={{ color: "#174873", textDecoration: "underline" }}>
        Voltar ao início
      </a>
    </div>
  )
}

Error.getInitialProps = ({ res, err }) => {
  const statusCode = res ? res.statusCode : err ? err.statusCode : 404
  return { statusCode }
}

export default Error
