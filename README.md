<<<<<<< HEAD
# 🎓 Magangin - Platform Magang Mahasiswa & Perusahaan

Aplikasi mobile modern untuk mempertemukan mahasiswa dengan lowongan magang yang relevan dari berbagai perusahaan, dibangun menggunakan **Flutter** dan **Supabase**.

---

## 🚀 Fitur Utama

### 👨‍🎓 Mahasiswa
- **Autentikasi**: Registrasi (data akademik) & Login dengan Supabase Auth.
- **Eksplorasi Lowongan**: Rekomendasi terpersonalisasi (skoring berbasis skill, jurusan, dan preferensi), kategori, dan lowongan terbaru.
- **Pencarian & Filter Multi-Kriteria**: Posisi, keahlian, industri, lokasi, sistem kerja (On-site / Hybrid / Remote), dan durasi magang.
- **Bookmark / Favorit**: Simpan lowongan impian untuk ditinjau nanti.
- **Curriculum Vitae (CV) & Portofolio**: Upload dan kelola berkas CV (PDF) ke Supabase Storage.
- **Pelamaran Magang**: Kirim lamaran langsung dengan CV dan surat pengantar (cover letter).
- **Pelacakan Status Lamaran**: Pantau tahapan (*Submitted*, *Reviewing*, *Interview*, *Accepted*, *Rejected*, *Withdrawn*).

### 🏢 Perusahaan
- **Dashboard Rekrutmen**: Metrik total lowongan aktif, total pelamar, dan lamaran baru.
- **Manajemen Lowongan**: Buat, publikasikan, atau simpan draft lowongan baru dengan detail gaji, kuota, persyaratan, dan tenggat waktu.
- **Review Pelamar**: Lihat profil akademik, riwayat keahlian, dan unduh CV pelamar.
- **Pembaruan Status Seleksi**: Ubah status pelamar secara instan dengan notifikasi otomatis.

---

## 🛠️ Arsitektur & Teknologi

- **Frontend**: Flutter (Dart 3.x), Riverpod State Management, GoRouter.
- **Backend & Database**: PostgreSQL via Supabase, Row Level Security (RLS).
- **File Storage**: Supabase Storage (`avatars`, `cv`, `company-logos`, `portfolio`).
- **Backend Logic / Edge Functions**: Deno TypeScript (`apply-internship`, `update-application-status`, `recommend-internships`, `send-notification`).

---

## 📁 Struktur Direktori

```
lib/
├── main.dart
├── core/
│   ├── constants/       # AppConstants & Color palette (#2563EB)
│   ├── theme/           # Google Fonts (Inter) & Material3 theme
│   └── utils/           # Formatters (Rupiah & Tanggal)
├── models/              # Profile, Student, Company, Internship, Application
├── services/            # SupabaseService, AuthService, InternshipService, ApplicationService, StorageService
├── providers/           # Riverpod state management
├── screens/
│   ├── auth/            # Login, Register Mahasiswa & Perusahaan
│   ├── home/            # Dashboard Mahasiswa & Bottom Navigation Shell
│   ├── internship/      # Search, Filter, Saved, Detail & Apply Modal
│   ├── application/     # Lamaran Saya & Riwayat Status
│   ├── profile/         # Profil Mahasiswa & Upload CV
│   └── company/         # Dashboard, Buat Lowongan, Review Pelamar, Profil Perusahaan
├── widgets/             # InternshipCard, StatusBadge, CustomButton, FilterBottomSheet, EmptyState
└── routes/              # GoRouter AppRouter
supabase/
├── schema.sql           # Skema lengkap PostgreSQL, RLS policies, & Auth Trigger
├── seed.sql             # Data awal untuk pengujian
└── functions/           # Supabase Edge Functions TypeScript
```

---

## ⚙️ Cara Menjalankan

### 1. Setup Supabase
1. Buka dashboard proyek di [Supabase](https://supabase.com).
2. Salin isi file `supabase/schema.sql` dan jalankan di **SQL Editor**.
3. Di file `lib/core/constants/app_constants.dart`, masukkan URL proyek dan Anon Key Anda:
   ```dart
   static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

### 2. Menjalankan Aplikasi Flutter
```bash
flutter pub get
flutter run
```
=======
# Magangin
>>>>>>> 8840ed9b1d3630468450fe199a3d557b25be2a77
