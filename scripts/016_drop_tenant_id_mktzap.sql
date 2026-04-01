-- Remove id_mktzap de tenants (campo ficou em profiles por usuário)
ALTER TABLE tenants
DROP COLUMN IF EXISTS id_mktzap;
