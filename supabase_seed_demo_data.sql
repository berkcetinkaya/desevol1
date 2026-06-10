-- ============================================================
-- Dese Tour CRM — Kapsamlı Demo Veri (v2)
-- Supabase SQL Editor'da çalıştırın
-- ============================================================

-- ── 1. Kaynaklar (Sources) ───────────────────────────────────
INSERT INTO public.sources (name, slug, is_active) VALUES
  ('Website',     'website',     true),
  ('WhatsApp',    'whatsapp',    true),
  ('Instagram',   'instagram',   true),
  ('Booking.com', 'booking',     true),
  ('Tripadvisor', 'tripadvisor', true),
  ('Telefon',     'telefon',     true),
  ('Manuel',      'manuel',      true)
ON CONFLICT (slug) DO NOTHING;

-- ── 2. Turlar ────────────────────────────────────────────────
INSERT INTO public.tours (name, category, flat_price, currency, duration_days, status, description) VALUES
  ('Private Istanbul Experience',    'City Tour',    350, 'EUR', 1, 'active', 'Sultanahmet, Kapalıçarşı, Boğaz turu'),
  ('Bosphorus & Asian Side Tour',    'Boat Tour',    120, 'EUR', 1, 'active', 'Boğaz tekne turu, Kadıköy gezisi'),
  ('Old City Highlights Tour',       'Historical',   220, 'EUR', 1, 'active', 'Topkapı Sarayı, Ayasofya, Arkeoloji Müzesi'),
  ('Cappadocia Full Experience',     'Adventure',    580, 'EUR', 2, 'active', 'Balon turu, Yeraltı şehri, Vadiler'),
  ('Istanbul Food & Culture Tour',   'Cultural',      95, 'EUR', 1, 'active', 'Mısır Çarşısı, sokak lezzetleri, çay bahçesi'),
  ('Classic Half Day Tour',          'City Tour',    150, 'EUR', 1, 'active', 'Yarım günlük Sultanahmet turu'),
  ('Private Istanbul Experience',    'City Tour',    350, 'EUR', 1, 'active', 'VIP özel tur')
ON CONFLICT DO NOTHING;

-- ── 3. Müşteriler ─────────────────────────────────────────────
WITH src AS (SELECT id FROM public.sources WHERE slug='website' LIMIT 1),
     wha AS (SELECT id FROM public.sources WHERE slug='whatsapp' LIMIT 1),
     ins AS (SELECT id FROM public.sources WHERE slug='instagram' LIMIT 1),
     tri AS (SELECT id FROM public.sources WHERE slug='tripadvisor' LIMIT 1)
INSERT INTO public.customers (full_name, email, phone, nationality, language, source_id, is_active, import_type, notes) VALUES
  ('Luca Rossi',      'luca.rossi@email.it',      '+39 333 123 4567', 'Italian',    'English', (SELECT id FROM src), true, 'manual', 'VIP müşteri, tekrar gelen'),
  ('Emma Brown',      'emma.brown@gmail.com',     '+44 77 1234 5678', 'British',    'English', (SELECT id FROM wha), true, 'manual', 'Instagram üzerinden geldi'),
  ('Sarah Johnson',   'sarah.j@hotmail.com',      '+1 555 012 3456',  'American',   'English', (SELECT id FROM ins), true, 'manual', NULL),
  ('Hans Mueller',    'hans.mueller@web.de',      '+49 176 1234567',  'German',     'German',  (SELECT id FROM src), true, 'manual', 'Almanca rehber talep etti'),
  ('Yuki Tanaka',     'yuki.tanaka@mail.jp',      '+81 90 1234 5678', 'Japanese',   'English', (SELECT id FROM tri), true, 'manual', NULL),
  ('Marie Dubois',    'marie.dubois@orange.fr',   '+33 6 12 34 56 78','French',     'French',  (SELECT id FROM src), true, 'manual', NULL),
  ('Marco Rossi',     'marco.rossi@gmail.com',    '+39 347 1234567',  'Italian',    'English', (SELECT id FROM wha), true, 'manual', NULL),
  ('Ayşe Demir',      'ayse.demir@gmail.com',     '+90 532 123 4567', 'Turkish',    'Turkish', (SELECT id FROM ins), true, 'manual', 'Yurt içi müşteri'),
  ('John Smith',      'john.smith@email.co.uk',   '+44 7911 123456',  'British',    'English', (SELECT id FROM src), true, 'manual', NULL),
  ('Sophie Laurent',  'sophie.l@gmail.com',       '+33 7 23 45 67 89','French',     'French',  (SELECT id FROM tri), true, 'manual', NULL)
ON CONFLICT (email) DO NOTHING;

-- ── 4. Talepler (Leads) ───────────────────────────────────────
WITH src AS (SELECT id FROM public.sources WHERE slug='instagram' LIMIT 1),
     wha AS (SELECT id FROM public.sources WHERE slug='whatsapp' LIMIT 1),
     web AS (SELECT id FROM public.sources WHERE slug='website' LIMIT 1),
     c1 AS (SELECT id FROM public.customers WHERE email='luca.rossi@email.it' LIMIT 1),
     c2 AS (SELECT id FROM public.customers WHERE email='emma.brown@gmail.com' LIMIT 1),
     c3 AS (SELECT id FROM public.customers WHERE email='sarah.j@hotmail.com' LIMIT 1),
     c4 AS (SELECT id FROM public.customers WHERE email='hans.mueller@web.de' LIMIT 1),
     c5 AS (SELECT id FROM public.customers WHERE email='yuki.tanaka@mail.jp' LIMIT 1)
INSERT INTO public.leads (lead_number, customer_id, contact_name, contact_email, contact_phone, destination, status, pax_adult, currency, source_id, notes)
SELECT lead_number, customer_id, contact_name, contact_email, contact_phone, destination, status, pax_adult, currency, source_id, notes
FROM (VALUES
  ('LEAD-001', (SELECT id FROM c1), 'Luca Rossi',   'luca.rossi@email.it',    '+39 333 123 4567', 'Private Istanbul Experience',  'new',            2, 'EUR', (SELECT id FROM src), 'Haziran için sordu'),
  ('LEAD-002', (SELECT id FROM c2), 'Emma Brown',   'emma.brown@gmail.com',   '+44 77 1234 5678', 'Bosphorus & Asian Side Tour',  'contacted',      4, 'EUR', (SELECT id FROM wha), 'WhatsApp ile iletişime geçildi'),
  ('LEAD-003', (SELECT id FROM c3), 'Sarah Johnson','sarah.j@hotmail.com',    '+1 555 012 3456',  'Cappadocia Full Experience',   'quote_sent',     2, 'EUR', (SELECT id FROM web), 'Teklif gönderildi'),
  ('LEAD-004', (SELECT id FROM c4), 'Hans Mueller', 'hans.mueller@web.de',    '+49 176 1234567',  'Old City Highlights Tour',     'new',            3, 'EUR', (SELECT id FROM src), 'Yeni talep'),
  ('LEAD-005', (SELECT id FROM c5), 'Yuki Tanaka',  'yuki.tanaka@mail.jp',    '+81 90 1234 5678', 'Istanbul Food & Culture Tour', 'won',            2, 'EUR', (SELECT id FROM wha), 'Rezervasyon oluşturuldu')
) AS v(lead_number, customer_id, contact_name, contact_email, contact_phone, destination, status, pax_adult, currency, source_id, notes)
ON CONFLICT DO NOTHING;

-- ── 5. Rezervasyonlar ─────────────────────────────────────────
WITH c1 AS (SELECT id FROM public.customers WHERE email='sarah.j@hotmail.com' LIMIT 1),
     c2 AS (SELECT id FROM public.customers WHERE email='john.smith@email.co.uk' LIMIT 1),
     c3 AS (SELECT id FROM public.customers WHERE email='emma.brown@gmail.com' LIMIT 1),
     c4 AS (SELECT id FROM public.customers WHERE email='luca.rossi@email.it' LIMIT 1),
     c5 AS (SELECT id FROM public.customers WHERE email='yuki.tanaka@mail.jp' LIMIT 1),
     c6 AS (SELECT id FROM public.customers WHERE email='marie.dubois@orange.fr' LIMIT 1),
     c7 AS (SELECT id FROM public.customers WHERE email='marco.rossi@gmail.com' LIMIT 1),
     c8 AS (SELECT id FROM public.customers WHERE email='ayse.demir@gmail.com' LIMIT 1)
INSERT INTO public.reservations (reservation_number, customer_id, destination, check_in, check_out, pax_adult, status, payment_status, total_amount, deposit_amount, currency, guide_name, notes)
SELECT rn, cid, dest, ci::date, co::date, pax, st, ps, total, deposit, cur, guide, notes
FROM (VALUES
  ('RES-001', (SELECT id FROM c1), 'Private Istanbul Experience',  '2026-06-03', '2026-06-03', 4, 'confirmed',    'deposit_paid',  1400, 350, 'EUR', 'Ahmet Yılmaz', 'Airport transfer dahil'),
  ('RES-002', (SELECT id FROM c2), 'Bosphorus & Asian Side Tour',  '2026-06-03', '2026-06-03', 2, 'confirmed',    'paid',           240,   0, 'EUR', 'Rehber Atanmadı', NULL),
  ('RES-003', (SELECT id FROM c3), 'Old City Highlights Tour',     '2026-06-03', '2026-06-03', 6, 'in_progress',  'partial',       1320, 330, 'EUR', 'Ayşe Kaya', NULL),
  ('RES-004', (SELECT id FROM c4), 'Old City Highlights Tour',     '2026-06-07', '2026-06-07', 2, 'confirmed',    'deposit_paid',   440, 110, 'EUR', 'Mehmet Çelik', 'VIP'),
  ('RES-005', (SELECT id FROM c5), 'Private Istanbul Experience',  '2026-06-05', '2026-06-05', 2, 'confirmed',    'pending',        700,   0, 'EUR', 'Rehber Atanmadı', NULL),
  ('RES-006', (SELECT id FROM c6), 'Private Istanbul Experience',  '2026-06-07', '2026-06-07', 2, 'pending_confirmation','pending', 700, 175, 'EUR', 'Rehber Atanmadı', NULL),
  ('RES-007', (SELECT id FROM c7), 'Old City Highlights Tour',     '2026-06-05', '2026-06-05', 2, 'confirmed',    'paid',           440,   0, 'EUR', 'Ayşe Kaya', NULL),
  ('RES-008', (SELECT id FROM c8), 'Cappadocia Full Experience',   '2026-06-10', '2026-06-11', 3, 'confirmed',    'deposit_paid',  1740, 435, 'EUR', 'Rehber Atanmadı', 'Balon turu istendi')
) AS v(rn, cid, dest, ci, co, pax, st, ps, total, deposit, cur, guide, notes)
ON CONFLICT DO NOTHING;

-- ── 6. Ödemeler ──────────────────────────────────────────────
WITH r1 AS (SELECT id FROM public.reservations WHERE reservation_number='RES-001' LIMIT 1),
     r2 AS (SELECT id FROM public.reservations WHERE reservation_number='RES-002' LIMIT 1),
     r3 AS (SELECT id FROM public.reservations WHERE reservation_number='RES-003' LIMIT 1),
     r7 AS (SELECT id FROM public.reservations WHERE reservation_number='RES-007' LIMIT 1)
INSERT INTO public.payments (payment_number, reservation_id, amount, currency, payment_type, method, status, paid_at, notes)
VALUES
  ('PAY-001', (SELECT id FROM r1), 350,  'EUR', 'deposit',  'bank_transfer', 'paid', NOW()-INTERVAL '5 days', 'Kapora alındı'),
  ('PAY-002', (SELECT id FROM r2), 240,  'EUR', 'full',     'credit_card',   'paid', NOW()-INTERVAL '3 days', 'Tam ödeme'),
  ('PAY-003', (SELECT id FROM r3), 330,  'EUR', 'deposit',  'cash',          'paid', NOW()-INTERVAL '2 days', 'Kapora nakit'),
  ('PAY-004', (SELECT id FROM r7), 440,  'EUR', 'full',     'bank_transfer', 'paid', NOW()-INTERVAL '1 day',  'Tam havale')
ON CONFLICT DO NOTHING;

-- ── 7. Görevler ───────────────────────────────────────────────
INSERT INTO public.tasks (title, category, priority, status, due_date, notes)
VALUES
  ('RES-003 için rehber ata',           'operations', 'high',   'pending',    CURRENT_DATE + 1, 'Ayşe Kaya müsait değil, alternatif bul'),
  ('RES-005 ödeme hatırlatması gönder', 'finance',    'medium', 'pending',    CURRENT_DATE + 2, 'WhatsApp ile iletişime geç'),
  ('Yeni tur kataloğu hazırla',         'marketing',  'low',    'pending',    CURRENT_DATE + 7, 'Temmuz-Ağustos için'),
  ('LEAD-003 teklif takibi',            'sales',      'high',   'in_progress',CURRENT_DATE,     'Sarah Johnson teklif onayı bekleniyor'),
  ('RES-001 airport transfer ayarla',   'operations', 'high',   'completed',  CURRENT_DATE - 1, 'Transfer ayarlandı ✓')
ON CONFLICT DO NOTHING;

-- ── 8. Hatırlatmalar ─────────────────────────────────────────
INSERT INTO public.reminders (title, type, priority, remind_at, is_done, notes)
VALUES
  ('Sarah Johnson teklif takibi',     'follow_up',  'high',   NOW() + INTERVAL '1 hour',   false, 'Teklif gönderildi, onay bekleniyor'),
  ('RES-005 ödeme hatırlatması',      'payment',    'medium', NOW() + INTERVAL '2 days',   false, 'Yuki Tanaka ödemesi bekliyor'),
  ('Haziran sonu müşteri raporu',     'general',    'low',    NOW() + INTERVAL '20 days',  false, 'Aylık performans raporu'),
  ('Hans Mueller ile görüşme',        'meeting',    'medium', NOW() + INTERVAL '3 days',   false, 'Tur detaylarını konuş')
ON CONFLICT DO NOTHING;

-- ── 9. Aktivite Logları ───────────────────────────────────────
WITH c1 AS (SELECT id FROM public.customers WHERE email='luca.rossi@email.it' LIMIT 1),
     c2 AS (SELECT id FROM public.customers WHERE email='sarah.j@hotmail.com' LIMIT 1)
INSERT INTO public.activity_logs (entity_type, entity_id, action, description, performed_by)
VALUES
  ('lead',        NULL, 'created',       'Yeni talep oluşturuldu: Luca Rossi', 'admin@desetour.com'),
  ('reservation', NULL, 'confirmed',     'RES-001 onaylandı',                  'admin@desetour.com'),
  ('payment',     NULL, 'received',      'PAY-001 kapora alındı: €350',        'admin@desetour.com'),
  ('lead',        NULL, 'status_change', 'LEAD-003 → Teklif Gönderildi',       'admin@desetour.com'),
  ('customer',    NULL, 'created',       'Yeni müşteri: Emma Brown',            'admin@desetour.com')
ON CONFLICT DO NOTHING;

-- ── 10. Ayarlar ───────────────────────────────────────────────
INSERT INTO public.settings (key, value, value_type, label, is_public) VALUES
  ('company_name',      '"Dese Tour"',      'string', 'Şirket Adı',        true),
  ('company_email',     '"hello@desetour.com"', 'string', 'Şirket E-posta', true),
  ('default_currency',  '"EUR"',            'string', 'Varsayılan Para',    true),
  ('tax_rate',          '20',               'number', 'KDV Oranı (%)',      true),
  ('deposit_pct',       '25',               'number', 'Kapora Oranı (%)',   true),
  ('company_phone',     '"+90 212 000 0000"','string','Telefon',            true)
ON CONFLICT (key) DO NOTHING;

-- ── Sonuç Özeti ──────────────────────────────────────────────
SELECT 'sources' as tablo,   COUNT(*) as kayit FROM public.sources    UNION ALL
SELECT 'customers',          COUNT(*) FROM public.customers           UNION ALL
SELECT 'tours',              COUNT(*) FROM public.tours               UNION ALL
SELECT 'leads',              COUNT(*) FROM public.leads               UNION ALL
SELECT 'reservations',       COUNT(*) FROM public.reservations        UNION ALL
SELECT 'payments',           COUNT(*) FROM public.payments            UNION ALL
SELECT 'tasks',              COUNT(*) FROM public.tasks               UNION ALL
SELECT 'reminders',          COUNT(*) FROM public.reminders           UNION ALL
SELECT 'activity_logs',      COUNT(*) FROM public.activity_logs;
