-- ID MKTZAP por usuário (profiles) - integração MKTZAP
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS id_mktzap TEXT;

COMMENT ON COLUMN profiles.id_mktzap IS 'Identifier for this user in the MKTZAP platform';
