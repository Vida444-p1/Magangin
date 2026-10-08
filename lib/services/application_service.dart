import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import 'supabase_service.dart';

class ApplicationService {
  final SupabaseClient _client = SupabaseService.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  /// Apply to an internship (invokes Edge Function with direct insert fallback)
  Future<ApplicationModel> applyInternship({
    required String internshipId,
    required String cvUrl,
    String? coverLetter,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Must be logged in to apply');

    try {
      // 1. Try invoking Edge Function
      final res = await _client.functions.invoke(
        'apply-internship',
        body: {
          'internship_id': internshipId,
          'cv_url': cvUrl,
          'cover_letter': coverLetter,
        },
      );

      if (res.status == 200 && res.data != null && res.data['application'] != null) {
        return ApplicationModel.fromJson(res.data['application']);
      }
    } catch (_) {
      // Fallback: direct database insertion
    }

    // Direct database insertion fallback
    final student = await _client
        .from('student_profiles')
        .select('id')
        .eq('user_id', userId)
        .single();
    final studentId = student['id'] as String;

    final result = await _client
        .from('applications')
        .insert({
          'internship_id': internshipId,
          'student_id': studentId,
          'cv_url': cvUrl,
          'cover_letter': coverLetter,
          'status': 'submitted',
        })
        .select('*, internships(*, company_profiles(*))')
        .single();

    // Trigger notification manually if edge function wasn't available
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': '🎉 Lamaran Berhasil Dikirim',
        'message': 'Lamaran kamu telah berhasil dikirim.',
        'type': 'application_submitted',
      });
    } catch (_) {}

    return ApplicationModel.fromJson(result);
  }

  /// Update application status (by company or withdraw by student)
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'update-application-status',
        body: {
          'application_id': applicationId,
          'status': status,
        },
      );

      if (res.status == 200) return;
    } catch (_) {
      // Fallback: direct update
    }

    await _client
        .from('applications')
        .update({'status': status})
        .eq('id', applicationId);
  }

  /// Get applications submitted by current student
  Future<List<ApplicationModel>> getStudentApplications() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final student = await _client
        .from('student_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (student == null) return [];
    final studentId = student['id'] as String;

    final data = await _client
        .from('applications')
        .select('*, internships(*, company_profiles(*))')
        .eq('student_id', studentId)
        .order('applied_at', ascending: false);

    return (data as List).map((json) => ApplicationModel.fromJson(json)).toList();
  }

  /// Get applicants for a company's internships
  Future<List<ApplicationModel>> getCompanyApplicants({String? internshipId}) async {
    var query = _client.from('applications').select('''
      *,
      internships(*),
      student_profiles(*, profiles(*))
    ''');

    if (internshipId != null) {
      query = query.eq('internship_id', internshipId);
    }

    final data = await query.order('applied_at', ascending: false);
    return (data as List).map((json) => ApplicationModel.fromJson(json)).toList();
  }
}
