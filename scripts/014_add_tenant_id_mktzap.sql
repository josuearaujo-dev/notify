-- Add MKTZAP integration identifier to tenants (for future MKTZAP credentials/templates separation)
ALTER TABLE tenants
ADD COLUMN IF NOT EXISTS id_mktzap TEXT;

COMMENT ON COLUMN tenants.id_mktzap IS 'Identifier for this tenant in the MKTZAP platform (used for MKTZAP integration)';
