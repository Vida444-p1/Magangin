-- ==============================================================================
-- SEED DATA: APLIKASI MAGANGIN
-- Initial data for development & testing
-- Note: Replace UUIDs or use this after users are created in auth.users
-- ==============================================================================

-- Sample mock companies and internships data
-- This is useful for manual insertion or testing via Supabase dashboard / SQL editor.

-- Insert sample company profile (demo)
-- Note: In Supabase production, user_id points to an actual auth.users(id).
-- For local testing with Supabase CLI, you can create a test user first.

/*
EXAMPLE SEED SCRIPT (Run after creating a test auth user):

-- 1. Create company profile
INSERT INTO public.company_profiles (id, user_id, company_name, description, industry, location, website, logo_url, phone)
VALUES (
  'c0000000-0000-0000-0000-000000000001',
  'YOUR_AUTH_USER_UUID_FOR_COMPANY',
  'PT Teknologi Indonesia',
  'Perusahaan teknologi yang berfokus pada pengembangan solusi digital enterprise dan mobile.',
  'Information Technology',
  'Yogyakarta',
  'https://teknologi-indonesia.example.com',
  'https://images.unsplash.com/photo-1549923746-c502d488b3ea?w=150',
  '081234567890'
);

-- 2. Create sample internships
INSERT INTO public.internships (
  company_id, title, description, requirements, category, location, work_type, duration, salary_min, salary_max, quota, deadline, status
) VALUES 
(
  'c0000000-0000-0000-0000-000000000001',
  'Flutter Developer Intern',
  'Kami mencari mahasiswa yang memiliki kemampuan Flutter untuk bergabung dengan tim pengembangan aplikasi mobile.',
  ARRAY['Mahasiswa jurusan Informatika/Sistem Informasi semester 5+', 'Memahami Flutter & Dart', 'Memahami REST API dan state management', 'Mampu bekerja sama dalam tim'],
  'IT',
  'Yogyakarta',
  'Hybrid',
  '3 bulan',
  1500000,
  2500000,
  2,
  NOW() + interval '30 days',
  'published'
),
(
  'c0000000-0000-0000-0000-000000000001',
  'UI/UX Designer Intern',
  'Membantu mendesain interface aplikasi web dan mobile dengan Figma dan berkolaborasi bersama tim engineering.',
  ARRAY['Menguasai Figma', 'Memahami Design System dan Wireframing', 'Memiliki portofolio desain UI/UX'],
  'Design',
  'Jakarta',
  'Remote',
  '6 bulan',
  2000000,
  3000000,
  3,
  NOW() + interval '45 days',
  'published'
),
(
  'c0000000-0000-0000-0000-000000000001',
  'Backend Developer Intern',
  'Mengembangkan REST API, mengelola database PostgreSQL, dan integrasi cloud services.',
  ARRAY['Memahami Node.js / Go / Python', 'Memahami Relational Database SQL', 'Familiar dengan Git'],
  'IT',
  'Bandung',
  'On-site',
  '4 bulan',
  1800000,
  2800000,
  2,
  NOW() + interval '20 days',
  'published'
),
(
  'c0000000-0000-0000-0000-000000000001',
  'Digital Marketing Intern',
  'Mengelola kampanye media sosial, konten marketing, dan analisis SEO dasar.',
  ARRAY['Kreatif dan aktif di media sosial', 'Memahami dasar Copywriting & SEO', 'Mampu menganalisis metrik media sosial'],
  'Marketing',
  'Surabaya',
  'Remote',
  '3 bulan',
  1000000,
  1800000,
  1,
  NOW() + interval '25 days',
  'published'
);
*/
