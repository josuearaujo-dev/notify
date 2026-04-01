import type { WhatsAppTemplatePayload, MessageTemplate } from "./types"

const WHATSAPP_API_URL = "https://graph.facebook.com/v21.0"

interface SendMessageResult {
  success: boolean
  messageId?: string
  waId?: string
  error?: string
}

export async function sendWhatsAppMessage(
  phoneNumberId: string,
  accessToken: string,
  payload: WhatsAppTemplatePayload,
): Promise<SendMessageResult> {
  try {
    console.log("[v0] WhatsApp payload:", JSON.stringify(payload, null, 2))

    const response = await fetch(`${WHATSAPP_API_URL}/${phoneNumberId}/messages`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify(payload),
    })

    const data = await response.json()

    if (!response.ok) {
      console.log("[v0] WhatsApp API error:", JSON.stringify(data, null, 2))
      return {
        success: false,
        error: data.error?.message || "Erro ao enviar mensagem",
      }
    }

    return {
      success: true,
      messageId: data.messages?.[0]?.id,
      waId: data.contacts?.[0]?.wa_id,
    }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : "Erro desconhecido",
    }
  }
}

export function buildWhatsAppPayload(
  recipientPhone: string,
  template: MessageTemplate,
  data: Record<string, unknown>,
): WhatsAppTemplatePayload {
  console.log("[v0] Building payload with data:", JSON.stringify(data, null, 2))
  console.log("[v0] Template parameter_mapping:", JSON.stringify(template.parameter_mapping, null, 2))

  // Build parameters based on template mapping - ensure all values are non-empty strings
  const parameters = Object.entries(template.parameter_mapping).map(([paramName, dataField]) => {
    const rawValue = data[dataField]
    // Convert to string and trim, fallback to placeholder if empty
    const textValue = rawValue != null ? String(rawValue).trim() : ""

    if (!textValue) {
      console.warn(`[v0] Empty value for parameter ${paramName} (field: ${dataField}), using placeholder`)
    }

    // Explicitly return object with type field
    return {
      type: "text",
      text: textValue || "-",
    }
  })

  console.log("[v0] Built parameters:", JSON.stringify(parameters, null, 2))

  const templateName = template.name.trim()

  return {
    messaging_product: "whatsapp",
    recipient_type: "individual",
    to: formatPhoneNumber(recipientPhone),
    type: "template",
    template: {
      name: templateName,
      language: { code: template.language_code },
      components: [
        {
          type: "body",
          parameters,
        },
      ],
    },
  }
}

function formatPhoneNumber(phone: string): string {
  // Remove all non-numeric characters
  return phone.replace(/\D/g, "")
}
