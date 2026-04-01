ALTER TABLE mktzap_messages
  ADD COLUMN IF NOT EXISTS id_file TEXT,
  ADD COLUMN IF NOT EXISTS service_date DATE;

CREATE INDEX IF NOT EXISTS idx_mktzap_messages_lookup
  ON mktzap_messages (tenant_id, mktzap_template_id, id_file, service_date, status);
