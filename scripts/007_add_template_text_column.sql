-- Add template_text column to message_templates table
ALTER TABLE message_templates
ADD COLUMN IF NOT EXISTS template_text TEXT;

-- Comment for documentation
COMMENT ON COLUMN message_templates.template_text IS 'Original template text from Meta with {{1}}, {{2}} variables';
