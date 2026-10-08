// ignore_for_file: use_null_aware_elements
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/student_profile_model.dart';
import '../models/company_profile_model.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign In with Email and Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Register as Student
  Future<AuthResponse> registerStudent({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? university,
    String? major,
    int? semester,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'role': 'student',
        'university': university,
        'major': major,
        'semester': semester ?? 1,
      },
    );

    // Fallback if trigger is not set on remote database:
    if (response.user != null) {
      final userId = response.user!.id;
      // Ensure profile row exists
      await _client.from('profiles').upsert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'role': 'student',
      });

      // Ensure student profile exists
      await _client.from('student_profiles').upsert({
        'user_id': userId,
        'university': university,
        'major': major,
        'semester': semester ?? 1,
      });
    }

    return response;
  }

  /// Register as Company
  Future<AuthResponse> registerCompany({
    required String email,
    required String password,
    required String companyName,
    String? phone,
    String? picName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': picName ?? companyName,
        'company_name': companyName,
        'phone': phone,
        'role': 'company',
      },
    );

    if (response.user != null) {
      final userId = response.user!.id;
      await _client.from('profiles').upsert({
        'id': userId,
        'email': email,
        'full_name': picName ?? companyName,
        'phone': phone,
        'role': 'company',
      });

      await _client.from('company_profiles').upsert({
        'user_id': userId,
        'company_name': companyName,
        'phone': phone,
      });
    }

    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Reset Password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Get current user profile
  Future<ProfileModel?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  /// Get student profile for current or given user ID
  Future<StudentProfileModel?> getStudentProfile([String? userId]) async {
    final targetUserId = userId ?? currentUser?.id;
    if (targetUserId == null) return null;

    final data = await _client
        .from('student_profiles')
        .select()
        .eq('user_id', targetUserId)
        .maybeSingle();

    if (data == null) return null;
    return StudentProfileModel.fromJson(data);
  }

  /// Update student profile
  Future<StudentProfileModel> updateStudentProfile({
    String? university,
    String? major,
    int? semester,
    String? location,
    String? bio,
    List<String>? skills,
    String? cvUrl,
    String? portfolioUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');

    final updates = <String, dynamic>{
      if (university != null) 'university': university,
      if (major != null) 'major': major,
      if (semester != null) 'semester': semester,
      if (location != null) 'location': location,
      if (bio != null) 'bio': bio,
      if (skills != null) 'skills': skills,
      if (cvUrl != null) 'cv_url': cvUrl,
      if (portfolioUrl != null) 'portfolio_url': portfolioUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final data = await _client
        .from('student_profiles')
        .update(updates)
        .eq('user_id', user.id)
        .select()
        .single();

    return StudentProfileModel.fromJson(data);
  }

  /// Get company profile for current or given user ID
  Future<CompanyProfileModel?> getCompanyProfile([String? userId]) async {
    final targetUserId = userId ?? currentUser?.id;
    if (targetUserId == null) return null;

    final data = await _client
        .from('company_profiles')
        .select()
        .eq('user_id', targetUserId)
        .maybeSingle();

    if (data == null) return null;
    return CompanyProfileModel.fromJson(data);
  }

  /// Update company profile
  Future<CompanyProfileModel> updateCompanyProfile({
    String? companyName,
    String? description,
    String? industry,
    String? location,
    String? website,
    String? logoUrl,
    String? phone,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');

    final updates = <String, dynamic>{
      if (companyName != null) 'company_name': companyName,
      if (description != null) 'description': description,
      if (industry != null) 'industry': industry,
      if (location != null) 'location': location,
      if (website != null) 'website': website,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (phone != null) 'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final data = await _client
        .from('company_profiles')
        .update(updates)
        .eq('user_id', user.id)
        .select()
        .single();

    return CompanyProfileModel.fromJson(data);
  }
}
