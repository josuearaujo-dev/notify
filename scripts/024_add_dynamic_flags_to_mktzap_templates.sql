ALTER TABLE mktzap_templates
  ADD COLUMN IF NOT EXISTS dynamic_parameter_flags JSONB NOT NULL DEFAULT '{}'::jsonb;
