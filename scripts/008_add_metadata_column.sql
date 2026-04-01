-- Adiciona coluna metadata para armazenar informações extras (como modo de teste)
ALTER TABLE messages ADD COLUMN IF NOT EXISTS metadata jsonb;

-- Verifica o resultado
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'messages' AND column_name = 'metadata';
