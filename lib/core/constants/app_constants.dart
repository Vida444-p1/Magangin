import 'package:flutter/material.dart';

class AppConstants {
  // Supabase Configuration
  // Note: Replace with your actual project URL and anon key from Supabase Dashboard
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Storage Buckets
  static const String bucketAvatars = 'avatars';
  static const String bucketCv = 'cv';
  static const String bucketCompanyLogos = 'company-logos';
  static const String bucketPortfolio = 'portfolio';

  // Categories
  static const List<String> categories = [
    'All',
    'IT',
    'Design',
    'Marketing',
    'Finance',
    'Accounting',
    'Engineering',
    'Human Resources',
  ];

  // Work Types
  static const List<String> workTypes = [
    'On-site',
    'Hybrid',
    'Remote',
  ];

  // Durations
  static const List<String> durations = [
    '1 bulan',
    '2 bulan',
    '3 bulan',
    '4 bulan',
    '6 bulan',
  ];

  // Locations
  static const List<String> locations = [
    'Yogyakarta',
    'Jakarta',
    'Bandung',
    'Surabaya',
    'Semarang',
    'Remote',
  ];

  // Colors as specified in PRD Section 51
  static const Color primaryColor = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF0F172A);
  static const Color secondaryColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  // Status Colors
  static const Color statusSubmitted = Color(0xFFEAB308); // Yellow
  static const Color statusReviewing = Color(0xFF3B82F6); // Blue
  static const Color statusInterview = Color(0xFF8B5CF6); // Purple
  static const Color statusAccepted = Color(0xFF10B981); // Green
  static const Color statusRejected = Color(0xFFEF4444); // Red
  static const Color statusWithdrawn = Color(0xFF94A3B8); // Slate
}
