-- Enable Row Level Security on all tables

ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_status_history ENABLE ROW LEVEL SECURITY;

-- Helper function to get current user's tenant_id
CREATE OR REPLACE FUNCTION get_user_tenant_id()
RETURNS UUID AS $$
  SELECT tenant_id FROM profiles WHERE id = auth.uid()
$$ LANGUAGE SQL SECURITY DEFINER;

-- Helper function to check if user is super admin
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT COALESCE(
    (SELECT is_super_admin FROM profiles WHERE id = auth.uid()),
    false
  )
$$ LANGUAGE SQL SECURITY DEFINER;

-- Tenants policies
CREATE POLICY "Super admins can do everything on tenants" ON tenants
  FOR ALL USING (is_super_admin());

CREATE POLICY "Users can view their own tenant" ON tenants
  FOR SELECT USING (id = get_user_tenant_id());

-- Profiles policies
CREATE POLICY "Super admins can do everything on profiles" ON profiles
  FOR ALL USING (is_super_admin());

CREATE POLICY "Users can view profiles in their tenant" ON profiles
  FOR SELECT USING (tenant_id = get_user_tenant_id());

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (id = auth.uid());

-- API Credentials policies
CREATE POLICY "Super admins can do everything on api_credentials" ON api_credentials
  FOR ALL USING (is_super_admin());

CREATE POLICY "Users can view their tenant api_credentials" ON api_credentials
  FOR SELECT USING (tenant_id = get_user_tenant_id());

CREATE POLICY "Managers can manage their tenant api_credentials" ON api_credentials
  FOR ALL USING (
    tenant_id = get_user_tenant_id() 
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'manager')
  );

-- WhatsApp Credentials policies
CREATE POLICY "Super admins can do everything on whatsapp_credentials" ON whatsapp_credentials
  FOR ALL USING (is_super_admin());

CREATE POLICY "Users can view their tenant whatsapp_credentials" ON whatsapp_credentials
  FOR SELECT USING (tenant_id = get_user_tenant_id());

CREATE POLICY "Managers can manage their tenant whatsapp_credentials" ON whatsapp_credentials
  FOR ALL USING (
    tenant_id = get_user_tenant_id() 
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'manager')
  );

-- Message Templates policies
CREATE POLICY "Super admins can do everything on message_templates" ON message_templates
  FOR ALL USING (is_super_admin());

CREATE POLICY "Users can view their tenant templates" ON message_templates
  FOR SELECT USING (tenant_id = get_user_tenant_id());

CREATE POLICY "Managers can manage their tenant templates" ON message_templates
  FOR ALL USING (
    tenant_id = get_user_tenant_id() 
    AND (SELECT role FROM profiles WHERE id = auth.uid()) IN ('admin', 'manager')
  );

-- Messages policies
CREATE POLICY "Super admins can do everything on messages" ON messages
  FOR ALL USING (is_super_admin());

CREATE POLICY "Users can view their tenant messages" ON messages
  FOR SELECT USING (tenant_id = get_user_tenant_id());

CREATE POLICY "Users can insert messages for their tenant" ON messages
  FOR INSERT WITH CHECK (tenant_id = get_user_tenant_id());

CREATE POLICY "Users can update their tenant messages" ON messages
  FOR UPDATE USING (tenant_id = get_user_tenant_id());

-- Message Status History policies
CREATE POLICY "Super admins can do everything on message_status_history" ON message_status_history
  FOR ALL USING (is_super_admin());

CREATE POLICY "Users can view their tenant message history" ON message_status_history
  FOR SELECT USING (
    message_id IN (SELECT id FROM messages WHERE tenant_id = get_user_tenant_id())
  );

CREATE POLICY "System can insert message status history" ON message_status_history
  FOR INSERT WITH CHECK (true);
