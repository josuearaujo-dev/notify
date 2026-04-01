CREATE TABLE IF NOT EXISTS mktzap_transfer_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  mktzap_message_log_id UUID REFERENCES mktzap_messages(id) ON DELETE SET NULL,
  sent_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  protocol TEXT,
  transfered_by_user TEXT,
  transfered_to_user TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed', 'skipped')),
  payload JSONB NOT NULL,
  response JSONB,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mktzap_transfer_logs_tenant ON mktzap_transfer_logs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_mktzap_transfer_logs_protocol ON mktzap_transfer_logs(protocol);
CREATE INDEX IF NOT EXISTS idx_mktzap_transfer_logs_status ON mktzap_transfer_logs(status);

ALTER TABLE mktzap_transfer_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Super admins can do everything on mktzap_transfer_logs" ON mktzap_transfer_logs;
DROP POLICY IF EXISTS "Users can view their tenant mktzap_transfer_logs" ON mktzap_transfer_logs;
DROP POLICY IF EXISTS "Users can insert their tenant mktzap_transfer_logs" ON mktzap_transfer_logs;

CREATE POLICY "Super admins can do everything on mktzap_transfer_logs" ON mktzap_transfer_logs
  FOR ALL USING (is_super_admin());

CREATE POLICY "Users can view their tenant mktzap_transfer_logs" ON mktzap_transfer_logs
  FOR SELECT USING (tenant_id = get_user_tenant_id());

CREATE POLICY "Users can insert their tenant mktzap_transfer_logs" ON mktzap_transfer_logs
  FOR INSERT WITH CHECK (tenant_id = get_user_tenant_id());
