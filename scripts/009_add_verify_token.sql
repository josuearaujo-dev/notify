-- Add verify_token column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'whatsapp_credentials' 
    AND column_name = 'verify_token'
  ) THEN
    ALTER TABLE whatsapp_credentials ADD COLUMN verify_token text;
  END IF;
END $$;

-- Show result
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'whatsapp_credentials';
