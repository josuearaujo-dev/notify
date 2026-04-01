-- Credenciais MKTZAP por tenant
CREATE TABLE IF NOT EXISTS mktzap_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  company_id TEXT NOT NULL,
  client_key TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(tenant_id)
);

CREATE INDEX IF NOT EXISTS idx_mktzap_credentials_tenant ON mktzap_credentials(tenant_id);

-- RLS
ALTER TABLE mktzap_credentials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tenant mktzap_credentials"
  ON mktzap_credentials FOR SELECT
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid()));

CREATE POLICY "Admins can manage own tenant mktzap_credentials"
  ON mktzap_credentials FOR ALL
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')));

-- Super admin full access (via service role key, no policy needed)
