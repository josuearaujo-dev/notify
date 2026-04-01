import { createClient } from "@/lib/supabase/server"
import { NextResponse } from "next/server"

export async function POST(request: Request) {
  try {
    const supabase = await createClient()

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: "Não autorizado" }, { status: 401 })
    }

    const body = await request.json()
    const { apiCredentialId, startDate, endDate } = body

    if (!apiCredentialId || !startDate || !endDate) {
      return NextResponse.json({ error: "Parâmetros obrigatórios não fornecidos" }, { status: 400 })
    }

    // Get API credentials
    const { data: credentials, error: credError } = await supabase
      .from("api_credentials")
      .select("*")
      .eq("id", apiCredentialId)
      .single()

    if (credError || !credentials) {
      const reason = credError
        ? `Supabase: ${credError.message} (code: ${credError.code})`
        : "nenhum registro de api_credentials com o id informado"
      console.log("[fetch-data] Credenciais não encontradas:", reason, { apiCredentialId })
      return NextResponse.json({ error: "Credenciais não encontradas" }, { status: 404 })
    }

    // Make request to external API with Basic Auth
    const authHeader = Buffer.from(`${credentials.username}:${credentials.password}`).toString("base64")

    const apiUrl = new URL(credentials.base_url)
    // Format dates as YYYY-MM-DD for the API
    apiUrl.searchParams.set("dataInicio", startDate)
    apiUrl.searchParams.set("dataFim", endDate)

    console.log("[v0] Fetching from URL:", apiUrl.toString())

    const response = await fetch(apiUrl.toString(), {
      method: "GET",
      headers: {
        Authorization: `Basic ${authHeader}`,
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    })

    console.log("[v0] API Response status:", response.status)

    if (!response.ok) {
      const errorText = await response.text()
      const isHtml = errorText.trim().toLowerCase().startsWith("<!") || errorText.includes("<html")
      const shortMessage = isHtml
        ? `A API externa retornou erro ${response.status} (resposta em HTML). Verifique a URL, credenciais e o período.`
        : errorText.length > 300
          ? `A API externa retornou erro ${response.status}: ${errorText.slice(0, 300)}...`
          : `Erro na API externa: ${response.status} - ${errorText}`
      console.log("[fetch-data] API externa falhou:", response.status, isHtml ? "(resposta HTML)" : errorText.slice(0, 500))
      return NextResponse.json({ error: shortMessage }, { status: 502 })
    }

    const contentType = response.headers.get("content-type") || ""
    const isJson = contentType.includes("application/json")
    let data: unknown
    if (isJson) {
      data = await response.json()
    } else {
      const text = await response.text()
      console.log("[fetch-data] Resposta não é JSON:", text.slice(0, 200))
      return NextResponse.json(
        { error: "A API externa não retornou JSON. Verifique a URL da API." },
        { status: 502 },
      )
    }
    console.log("[v0] API Data received:", JSON.stringify(data).slice(0, 500))

    // Ensure data is an array and has required fields
    const obj = data as Record<string, unknown>
    const records = Array.isArray(data) ? data : obj?.records || obj?.data || obj?.result || []

    // Add unique IDs if not present and ensure phone field exists
    const processedRecords = records.map((record: Record<string, unknown>, index: number) => ({
      id: record.id || record.ID || record.codigo || `record-${index}`,
      phone: record.phone || record.telefone || record.celular || record.whatsapp || record.fone || record.cel || "",
      ...record,
    }))

    return NextResponse.json({ data: processedRecords })
  } catch (error) {
    console.error("[v0] Error fetching data:", error)
    return NextResponse.json({ error: error instanceof Error ? error.message : "Erro interno" }, { status: 500 })
  }
}
