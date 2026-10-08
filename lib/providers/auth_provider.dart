import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/student_profile_model.dart';
import '../models/company_profile_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges;
});

final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  // Re-fetch whenever auth state changes
  ref.watch(authStateProvider);
  final service = ref.watch(authServiceProvider);
  return await service.getCurrentProfile();
});

final studentProfileProvider = FutureProvider<StudentProfileModel?>((ref) async {
  ref.watch(authStateProvider);
  final service = ref.watch(authServiceProvider);
  return await service.getStudentProfile();
});

final companyProfileProvider = FutureProvider<CompanyProfileModel?>((ref) async {
  ref.watch(authStateProvider);
  final service = ref.watch(authServiceProvider);
  return await service.getCompanyProfile();
});
