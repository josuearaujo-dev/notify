-- Add broker_phone to MKTZAP templates
ALTER TABLE mktzap_templates
ADD COLUMN IF NOT EXISTS broker_phone TEXT;

COMMENT ON COLUMN mktzap_templates.broker_phone IS 'Phone used by broker/sender for this template';
