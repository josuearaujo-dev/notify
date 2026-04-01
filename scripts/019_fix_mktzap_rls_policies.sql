-- Fix RLS policies for mktzap_credentials
DROP POLICY IF EXISTS "Users can view own tenant mktzap_credentials" ON mktzap_credentials;
DROP POLICY IF EXISTS "Admins can manage own tenant mktzap_credentials" ON mktzap_credentials;

-- SELECT: qualquer usuário do tenant pode ver
CREATE POLICY "mktzap_credentials_select"
  ON mktzap_credentials FOR SELECT
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid()));

-- INSERT: admins/managers do tenant podem inserir
CREATE POLICY "mktzap_credentials_insert"
  ON mktzap_credentials FOR INSERT
  WITH CHECK (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')));

-- UPDATE: admins/managers do tenant podem atualizar
CREATE POLICY "mktzap_credentials_update"
  ON mktzap_credentials FOR UPDATE
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')))
  WITH CHECK (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')));

-- DELETE: admins/managers do tenant podem deletar
CREATE POLICY "mktzap_credentials_delete"
  ON mktzap_credentials FOR DELETE
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')));


-- Fix RLS policies for mktzap_templates
DROP POLICY IF EXISTS "Users can view own tenant mktzap_templates" ON mktzap_templates;
DROP POLICY IF EXISTS "Admins can manage own tenant mktzap_templates" ON mktzap_templates;

-- SELECT: qualquer usuário do tenant pode ver
CREATE POLICY "mktzap_templates_select"
  ON mktzap_templates FOR SELECT
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid()));

-- INSERT: admins/managers do tenant podem inserir
CREATE POLICY "mktzap_templates_insert"
  ON mktzap_templates FOR INSERT
  WITH CHECK (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')));

-- UPDATE: admins/managers do tenant podem atualizar
CREATE POLICY "mktzap_templates_update"
  ON mktzap_templates FOR UPDATE
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')))
  WITH CHECK (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')));

-- DELETE: admins/managers do tenant podem deletar
CREATE POLICY "mktzap_templates_delete"
  ON mktzap_templates FOR DELETE
  USING (tenant_id IN (SELECT tenant_id FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'manager')));
