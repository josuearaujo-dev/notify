-- Script to create the first super admin
-- Run this after a user has signed up to make them super admin

-- First, create a tenant for the admin
INSERT INTO tenants (name, slug, is_active)
VALUES ('Administração', 'admin', true)
ON CONFLICT (slug) DO NOTHING;

-- Auto-promote first registered user to super admin
-- This automatically finds the first user and makes them super admin
UPDATE profiles 
SET 
  is_super_admin = true, 
  role = 'admin',
  tenant_id = (SELECT id FROM tenants WHERE slug = 'admin')
WHERE id = (
  SELECT id FROM profiles ORDER BY created_at ASC LIMIT 1
);

-- Show the result
SELECT p.id, p.full_name, u.email, p.role, p.is_super_admin 
FROM profiles p
JOIN auth.users u ON u.id = p.id
WHERE p.is_super_admin = true;
