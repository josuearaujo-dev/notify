ALTER TABLE mktzap_messages
  ADD COLUMN IF NOT EXISTS id_pax_servico TEXT;

CREATE INDEX IF NOT EXISTS idx_mktzap_messages_id_pax_servico
  ON mktzap_messages (tenant_id, mktzap_template_id, id_pax_servico, status);
