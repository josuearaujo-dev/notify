-- Adiciona colunas para rastreamento eficiente de mensagens por IdPaxServico
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS id_pax_servico TEXT,
ADD COLUMN IF NOT EXISTS service_date DATE;

-- Cria índices compostos para busca otimizada por tenant + data + id_pax_servico
CREATE INDEX IF NOT EXISTS idx_messages_id_pax_servico 
ON messages(tenant_id, id_pax_servico) 
WHERE id_pax_servico IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_messages_service_date_id_pax 
ON messages(tenant_id, service_date, id_pax_servico) 
WHERE service_date IS NOT NULL AND id_pax_servico IS NOT NULL;

-- Adiciona comentários para documentação
COMMENT ON COLUMN messages.id_pax_servico IS 'ID único do passageiro/serviço da API externa para rastreamento de mensagens';
COMMENT ON COLUMN messages.service_date IS 'Data do serviço para filtrar mensagens por período';
