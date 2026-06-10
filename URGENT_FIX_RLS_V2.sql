-- ============================================================
-- ADIM 1: Önce bu sorguyu çalıştırın — kullanıcı ID'nizi bulun
-- ============================================================
SELECT id, email, created_at 
FROM auth.users 
ORDER BY created_at DESC 
LIMIT 5;

-- ============================================================
-- ADIM 2: Üstteki sorgudan gelen UUID'yi aşağıya yapıştırın
-- 'BURAYA-UUID-YAPISTIRIN' yerine gerçek ID'yi yazın
-- Örnek: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
-- ============================================================
INSERT INTO public.staff_users (id, full_name, email, role, is_active)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'full_name', email, 'Admin') as full_name,
  email,
  'admin' as role,
  true as is_active
FROM auth.users
ORDER BY created_at DESC
LIMIT 1
ON CONFLICT (id) DO UPDATE 
SET role = 'admin', is_active = true;

-- ============================================================
-- ADIM 3: Kontrol edin
-- ============================================================
SELECT id, full_name, email, role FROM public.staff_users;
