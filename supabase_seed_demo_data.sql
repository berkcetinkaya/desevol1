-- ============================================================
-- Dese Tour Operations Center — Demo Seed Data
-- Run this in Supabase SQL Editor to populate demo records
-- WARNING: Only run on a development/demo project, not production
-- ============================================================

-- Clear existing data (optional)
-- TRUNCATE public.activity_logs, public.payments, public.reservations,
--          public.quote_items, public.quotes, public.tasks, public.reminders,
--          public.leads, public.customers CASCADE;

-- ── Sources ──────────────────────────────────────────────────────
INSERT INTO public.sources (name, slug, is_active) VALUES
  ('Website',     'website',     true),
  ('WhatsApp',    'whatsapp',    true),
  ('Instagram',   'instagram',   true),
  ('Booking.com', 'booking',     true),
  ('Tripadvisor', 'tripadvisor', true),
  ('Telefon',     'telefon',     true),
  ('Manuel',      'manuel',      true)
ON CONFLICT (slug) DO NOTHING;

-- ── Demo Customers ───────────────────────────────────────────────
WITH src AS (SELECT id FROM public.sources WHERE slug='website' LIMIT 1)
INSERT INTO public.customers (full_name, email, phone, nationality, language, source_id, is_active, import_type)
SELECT * FROM (VALUES
  ('Luca Rossi',    'luca@example.com',    '+39 333 1234567', 'Italian',   'English', (SELECT id FROM src), true, 'manual'),
  ('Emma Brown',    'emma@example.com',    '+44 77 12345678', 'British',   'English', (SELECT id FROM src), true, 'manual'),
  ('Sarah Johnson', 'sarah@example.com',   '+1 555 0123456',  'American',  'English', (SELECT id FROM src), true, 'manual'),
  ('Hans Mueller',  'hans@example.de',     '+49 176 1234567', 'German',    'German',  (SELECT id FROM src), true, 'manual'),
  ('Yuki Tanaka',   'yuki@example.jp',     '+81 90 12345678', 'Japanese',  'English', (SELECT id FROM src), true, 'manual')
) AS v(full_name, email, phone, nationality, language, source_id, is_active, import_type)
ON CONFLICT DO NOTHING;

-- ── Demo Tours ───────────────────────────────────────────────────
INSERT INTO public.tours (name, category, flat_price, currency, duration_days, status) VALUES
  ('Istanbul Old City Highlights',    'City Tour',    350, 'EUR', 1, 'active'),
  ('Bosphorus Sunset Cruise',         'Boat Tour',    120, 'EUR', 1, 'active'),
  ('Cappadocia Hot Air Balloon',      'Adventure',    280, 'EUR', 1, 'active'),
  ('Ephesus & Pamukkale Day Trip',    'Historical',   220, 'EUR', 1, 'active'),
  ('Turkish Cooking Class',           'Cultural',      85, 'EUR', 1, 'active')
ON CONFLICT DO NOTHING;

-- ── Demo Leads ───────────────────────────────────────────────────
WITH cust AS (
  SELECT id, full_name FROM public.customers WHERE email IN ('luca@example.com','emma@example.com','sarah@example.com')
),
src AS (SELECT id FROM public.sources WHERE slug='instagram' LIMIT 1)
INSERT INTO public.leads (customer_id, lead_number, destination, status, pax_adult, currency, source_id)
SELECT 
  c.id,
  'LEAD-' || LPAD(ROW_NUMBER() OVER ()::text, 3, '0'),
  CASE c.full_name
    WHEN 'Luca Rossi'    THEN 'Istanbul Old City Highlights'
    WHEN 'Emma Brown'    THEN 'Cappadocia Hot Air Balloon'
    WHEN 'Sarah Johnson' THEN 'Bosphorus Sunset Cruise'
  END,
  CASE c.full_name
    WHEN 'Luca Rossi'    THEN 'new'
    WHEN 'Emma Brown'    THEN 'contacted'
    WHEN 'Sarah Johnson' THEN 'quote_sent'
  END,
  CASE c.full_name WHEN 'Luca Rossi' THEN 3 WHEN 'Emma Brown' THEN 2 ELSE 4 END,
  'EUR',
  (SELECT id FROM src)
FROM cust c
ON CONFLICT DO NOTHING;

-- ── Settings ─────────────────────────────────────────────────────
INSERT INTO public.settings (key, value, value_type, label, is_public) VALUES
  ('company_name',     '"Dese Tour"',   'string', 'Sirket Adi',    true),
  ('default_currency', '"EUR"',         'string', 'Varsayilan Para', true),
  ('tax_rate',         '20',            'number', 'KDV Orani (%)', true),
  ('deposit_pct',      '25',            'number', 'Kapora Orani',  true)
ON CONFLICT (key) DO NOTHING;

-- ============================================================
-- After running: visit the app, Dashboard should show demo data
-- ============================================================
