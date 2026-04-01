-- Add message sending settings to tenants table
-- This allows each tenant to configure whether to skip or resend already sent messages

ALTER TABLE tenants 
ADD COLUMN IF NOT EXISTS message_resend_behavior TEXT NOT NULL DEFAULT 'skip' 
CHECK (message_resend_behavior IN ('skip', 'resend'));

COMMENT ON COLUMN tenants.message_resend_behavior IS 
'Behavior when sending messages: "skip" = skip already sent messages, "resend" = resend already sent messages';

