-- Logs de envio MKTZAP
CREATE TABLE IF NOT EXISTS mktzap_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  sent_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  mktzap_template_id UUID REFERENCES mktzap_templates(id) ON DELETE SET NULL,
  broker_phone TEXT NOT NULL,
  phone_ddi TEXT,
  phone_number TEXT NOT NULL,
  recipient_phone TEXT NOT NULL,
  id_pax_servico TEXT,
  recipient_name TEXT,
  lead_id BIGINT,
  mktzap_message_id TEXT,
  payload JSONB NOT NULL,
  response JSONB,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed')),
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mktzap_messages_tenant ON mktzap_messages(tenant_id);
CREATE INDEX IF NOT EXISTS idx_mktzap_messages_template ON mktzap_messages(mktzap_template_id);
CREATE INDEX IF NOT EXISTS idx_mktzap_messages_status ON mktzap_messages(status);

-- RLS
ALTER TABLE mktzap_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Super admins can do everything on mktzap_messages" ON mktzap_messages;
DROP POLICY IF EXISTS "Users can view their tenant mktzap_messages" ON mktzap_messages;
DROP POLICY IF EXISTS "Users can insert their tenant mktzap_messages" ON mktzap_messages;
DROP POLICY IF EXISTS "Users can update their tenant mktzap_messages" ON mktzap_messages;

CREATE POLICY "Super admins can do everything on mktzap_messages" ON mktzap_messages
  FOR ALL USING (is_super_admin());

CREATE POLICY "Users can view their tenant mktzap_messages" ON mktzap_messages
  FOR SELECT USING (tenant_id = get_user_tenant_id());

CREATE POLICY "Users can insert their tenant mktzap_messages" ON mktzap_messages
  FOR INSERT WITH CHECK (tenant_id = get_user_tenant_id());

CREATE POLICY "Users can update their tenant mktzap_messages" ON mktzap_messages
  FOR UPDATE USING (tenant_id = get_user_tenant_id());
