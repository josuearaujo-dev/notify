-- Remove todas as policies anteriores do mktzap_credentials
DROP POLICY IF EXISTS "Users can view own tenant mktzap_credentials" ON mktzap_credentials;
DROP POLICY IF EXISTS "Admins can manage own tenant mktzap_credentials" ON mktzap_credentials;
DROP POLICY IF EXISTS "mktzap_credentials_select" ON mktzap_credentials;
DROP POLICY IF EXISTS "mktzap_credentials_insert" ON mktzap_credentials;
DROP POLICY IF EXISTS "mktzap_credentials_update" ON mktzap_credentials;
DROP POLICY IF EXISTS "mktzap_credentials_delete" ON mktzap_credentials;

-- Super admin acesso total (mesmo padrão das outras tabelas)
CREATE POLICY "Super admins can do everything on mktzap_credentials" ON mktzap_credentials
  FOR ALL USING (is_super_admin());

-- SELECT: usuários do tenant podem ver
CREATE POLICY "Users can view their tenant mktzap_credentials" ON mktzap_credentials
  FOR SELECT USING (tenant_id = get_user_tenant_id());

-- ALL: admins/managers do tenant podem gerenciar
CREATE POLICY "Managers can manage their tenant mktzap_credentials" ON mktzap_credentials
  FOR ALL USING (
    tenant_id = get_user_tenant_id()
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'manager')
  );


-- Remove todas as policies anteriores do mktzap_templates
DROP POLICY IF EXISTS "Users can view own tenant mktzap_templates" ON mktzap_templates;
DROP POLICY IF EXISTS "Admins can manage own tenant mktzap_templates" ON mktzap_templates;
DROP POLICY IF EXISTS "mktzap_templates_select" ON mktzap_templates;
DROP POLICY IF EXISTS "mktzap_templates_insert" ON mktzap_templates;
DROP POLICY IF EXISTS "mktzap_templates_update" ON mktzap_templates;
DROP POLICY IF EXISTS "mktzap_templates_delete" ON mktzap_templates;

-- Super admin acesso total
CREATE POLICY "Super admins can do everything on mktzap_templates" ON mktzap_templates
  FOR ALL USING (is_super_admin());

-- SELECT: usuários do tenant podem ver
CREATE POLICY "Users can view their tenant mktzap_templates" ON mktzap_templates
  FOR SELECT USING (tenant_id = get_user_tenant_id());

-- ALL: admins/managers do tenant podem gerenciar
CREATE POLICY "Managers can manage their tenant mktzap_templates" ON mktzap_templates
  FOR ALL USING (
    tenant_id = get_user_tenant_id()
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'manager')
  );
