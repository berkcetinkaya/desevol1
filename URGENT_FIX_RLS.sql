-- ============================================================
-- URGENT: Run this in Supabase SQL Editor FIRST
-- This fixes "Talep oluşturulurken hata" error
-- ============================================================

-- Step 1: Check your auth.uid()
SELECT auth.uid();

-- Step 2: Check if you exist in staff_users
SELECT * FROM public.staff_users WHERE id = auth.uid();

-- Step 3: If Step 2 returns empty, insert yourself as admin:
-- (Replace the values with your actual info)
INSERT INTO public.staff_users (id, full_name, email, role, is_active)
VALUES (
  auth.uid(),           -- your Supabase auth user ID
  'Admin',              -- your name
  (SELECT email FROM auth.users WHERE id = auth.uid()),
  'admin',              -- role: admin | sales | operations | guide
  true
)
ON CONFLICT (id) DO UPDATE SET role = 'admin', is_active = true;

-- Step 4: Verify
SELECT id, full_name, role FROM public.staff_users WHERE id = auth.uid();

-- ============================================================
-- ALTERNATIVE: If you want ALL authenticated users to insert
-- (less secure, only for development)
-- ============================================================
-- CREATE POLICY "leads: any auth insert" ON public.leads
--   FOR INSERT TO authenticated WITH CHECK (true);
-- CREATE POLICY "customers: any auth insert" ON public.customers
--   FOR INSERT TO authenticated WITH CHECK (true);
