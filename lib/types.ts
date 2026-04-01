export interface Tenant {
  id: string
  name: string
  slug: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Profile {
  id: string
  tenant_id: string | null
  full_name: string | null
  id_mktzap?: string | null
  role: "admin" | "manager" | "user"
  is_super_admin: boolean
  created_at: string
  updated_at: string
  tenant?: Tenant
}

export interface ApiCredential {
  id: string
  tenant_id: string
  name: string
  base_url: string
  username: string
  password: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface WhatsAppCredential {
  id: string
  tenant_id: string
  phone_number_id: string
  access_token: string
  business_account_id: string | null
  webhook_verify_token: string | null
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface MessageTemplate {
  id: string
  tenant_id: string
  name: string
  language_code: string
  description: string | null
  parameter_mapping: Record<string, string>
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Message {
  id: string
  tenant_id: string
  template_id: string | null
  whatsapp_message_id: string | null
  recipient_phone: string
  recipient_wa_id: string | null
  template_name: string
  payload: Record<string, unknown>
  status: "pending" | "sent" | "delivered" | "read" | "failed"
  status_updated_at: string | null
  error_message: string | null
  sent_by: string | null
  created_at: string
  updated_at: string
}

export interface MessageStatusHistory {
  id: string
  message_id: string
  status: string
  timestamp: string
  raw_payload: Record<string, unknown> | null
}

export interface MktzapCredential {
  id: string
  tenant_id: string
  company_id: string
  client_key: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface MktzapTemplate {
  id: string
  tenant_id: string
  mktzap_id: number
  name: string
  language: string
  template: string
  header_template: string | null
  broker_phone: string | null
  updated_at_mktzap: string | null
  parameter_mapping: Record<string, string>
  dynamic_parameter_flags: Record<string, boolean>
  is_passeio: boolean
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface MktzapMessage {
  id: string
  tenant_id: string
  sent_by: string | null
  mktzap_template_id: string | null
  id_pax_servico: string | null
  id_file: string | null
  service_date: string | null
  broker_phone: string
  phone_ddi: string | null
  phone_number: string
  recipient_phone: string
  recipient_name: string | null
  lead_id: number | null
  mktzap_message_id: string | null
  payload: Record<string, unknown>
  response: Record<string, unknown> | null
  status: "pending" | "sent" | "failed"
  error_message: string | null
  created_at: string
  updated_at: string
}

export interface WhatsAppTemplatePayload {
  messaging_product: "whatsapp"
  recipient_type: "individual"
  to: string
  type: "template"
  template: {
    name: string
    language: { code: string }
    components: Array<{
      type: "body"
      parameters: Array<{
        type: "text"
        parameter_name: string
        text: string
      }>
    }>
  }
}
