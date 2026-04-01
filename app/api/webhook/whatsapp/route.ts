import { createClient } from "@supabase/supabase-js"
import { NextResponse } from "next/server"
import { logError, getErrorContext } from "@/lib/error-logger"

// Use service role for webhook (no user context)
function getSupabaseAdmin() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!url || !serviceRoleKey) {
    throw new Error("Supabase admin credentials not configured")
  }

  return createClient(url, serviceRoleKey)
}

const WEBHOOK_VERIFY_TOKEN = process.env.WEBHOOK_VERIFY_TOKEN || "wo01Maker@1"

export async function GET(request: Request) {
  const url = new URL(request.url)
  const mode = url.searchParams.get("hub.mode")
  const token = url.searchParams.get("hub.verify_token")
  const challenge = url.searchParams.get("hub.challenge")

  if (mode === "subscribe" && challenge) {
    // Accept if token matches the environment variable or hardcoded default
    if (token === WEBHOOK_VERIFY_TOKEN) {
      return new Response(challenge, {
        status: 200,
        headers: { "Content-Type": "text/plain" },
      })
    }
  }

  return new Response("Forbidden", { status: 403 })
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    console.log("[v0] Webhook received:", JSON.stringify(body, null, 2))

    // Process webhook payload
    const entries = body.entry || []

    for (const entry of entries) {
      const changes = entry.changes || []

      for (const change of changes) {
        if (change.field !== "messages") continue

        const value = change.value

        const statuses = value.statuses || []
        for (const status of statuses) {
          await processStatusUpdate(status)
        }

        const messages = value.messages || []
        for (const message of messages) {
          console.log("[v0] Incoming message:", message)
          // Could be used for replies/conversations in the future
        }
      }
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    await logError(error instanceof Error ? error : new Error(String(error)), "WEBHOOK_ERROR", {
      ...getErrorContext(request),
      statusCode: 500,
    })
    return NextResponse.json({ error: "Internal error" }, { status: 500 })
  }
}

async function processStatusUpdate(status: {
  id: string
  status: string
  timestamp?: string
  recipient_id?: string
  errors?: Array<{ code: number; title: string }>
}) {
  try {
    const supabase = getSupabaseAdmin()
    const messageId = status.id
    const newStatus = mapWebhookStatus(status.status)
    const timestamp = status.timestamp
      ? new Date(Number.parseInt(status.timestamp) * 1000).toISOString()
      : new Date().toISOString()

    const { data: message, error: findError } = await supabase
      .from("messages")
      .select("id, status, tenant_id")
      .eq("whatsapp_message_id", messageId)
      .single()

    if (findError || !message) {
      console.log("[v0] Message not found for ID:", messageId)
      return
    }

    const statusOrder = ["pending", "sent", "delivered", "read", "failed"]
    const currentIndex = statusOrder.indexOf(message.status)
    const newIndex = statusOrder.indexOf(newStatus)

    if (newStatus !== "failed" && newIndex <= currentIndex) {
      console.log("[v0] Skipping status update - current status is already ahead")
      return
    }

    const { error: updateError } = await supabase
      .from("messages")
      .update({
        status: newStatus,
        status_updated_at: timestamp,
      })
      .eq("id", message.id)

    if (updateError) {
      await logError(updateError, "WEBHOOK_STATUS_UPDATE_ERROR", {
        endpoint: "/api/webhook/whatsapp",
        method: "POST",
        tenantId: message.tenant_id,
        additionalData: {
          messageId: message.id,
          whatsappMessageId: messageId,
          newStatus,
        },
      })
      return
    }

    const { error: historyError } = await supabase.from("message_status_history").insert({
      message_id: message.id,
      status: newStatus,
      timestamp,
      raw_payload: status,
    })

    if (historyError) {
      await logError(historyError, "WEBHOOK_HISTORY_INSERT_ERROR", {
        endpoint: "/api/webhook/whatsapp",
        method: "POST",
        tenantId: message.tenant_id,
        additionalData: { messageId: message.id },
      })
    }

    console.log("[v0] Status updated successfully:", { messageId: message.id, newStatus })
  } catch (error) {
    await logError(error instanceof Error ? error : new Error(String(error)), "WEBHOOK_PROCESS_STATUS_ERROR", {
      endpoint: "/api/webhook/whatsapp",
      method: "POST",
      additionalData: { statusPayload: status },
    })
  }
}

function mapWebhookStatus(webhookStatus: string): string {
  const statusMap: Record<string, string> = {
    sent: "sent",
    delivered: "delivered",
    read: "read",
    failed: "failed",
  }
  return statusMap[webhookStatus] || "sent"
}
