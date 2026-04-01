-- Templates MKTZAP sincronizados da API (por tenant)
CREATE TABLE IF NOT EXISTS mktzap_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  mktzap_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  language TEXT NOT NULL DEFAULT 'pt_BR',
  template TEXT NOT NULL,
  header_template TEXT,
  updated_at_mktzap TIMESTAMPTZ,
  parameter_mapping JSONB NOT NULL DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(tenant_id, mktzap_id)
);

CREATE INDEX IF NOT EXISTS idx_mktzap_templates_tenant ON mktzap_templates(tenant_id);

-- RLS
ALTER TABLE mktzap_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tenant mktzap_templates"
  ON mktzap_templates FOR SELECT
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid()));

CREATE POLICY "Admins can manage own tenant mktzap_templates"
  ON mktzap_templates FOR ALL
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')));
