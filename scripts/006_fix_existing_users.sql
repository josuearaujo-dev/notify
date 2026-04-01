-- Create profiles for existing users that don't have one
INSERT INTO public.profiles (id, full_name, role, is_super_admin)
SELECT 
  u.id,
  COALESCE(u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1)),
  'user',
  false
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.id = u.id
);

-- Now promote the first user to super admin
UPDATE public.profiles
SET 
  is_super_admin = true,
  role = 'admin'
WHERE id = (
  SELECT id FROM public.profiles ORDER BY created_at ASC LIMIT 1
);

-- Show all profiles to confirm
SELECT 
  p.id,
  p.full_name,
  u.email,
  p.role,
  p.is_super_admin
FROM public.profiles p
JOIN auth.users u ON p.id = u.id
ORDER BY p.created_at ASC;
