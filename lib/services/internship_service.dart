import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/internship_model.dart';
import 'supabase_service.dart';

class InternshipService {
  final SupabaseClient _client = SupabaseService.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  /// Fetch published internships with optional filters
  Future<List<InternshipModel>> getPublishedInternships({
    String? category,
    String? location,
    String? workType,
    String? duration,
    String? searchQuery,
    int limit = 50,
  }) async {
    var query = _client
        .from('internships')
        .select('*, company_profiles(*)')
        .eq('status', 'published');

    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.eq('category', category);
    }

    if (location != null && location.isNotEmpty && location != 'All') {
      query = query.ilike('location', '%$location%');
    }

    if (workType != null && workType.isNotEmpty && workType != 'All') {
      query = query.eq('work_type', workType);
    }

    if (duration != null && duration.isNotEmpty) {
      query = query.eq('duration', duration);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = searchQuery.trim();
      query = query.or('title.ilike.%$term%,description.ilike.%$term%,category.ilike.%$term%');
    }

    final data = await query.order('created_at', ascending: false).limit(limit);

    // Get user's saved internships to annotate `isSaved`
    final savedIds = await _getSavedInternshipIds();

    return (data as List).map((json) {
      final model = InternshipModel.fromJson(json);
      return model.copyWith(isSaved: savedIds.contains(model.id));
    }).toList();
  }

  /// Get internship details by ID
  Future<InternshipModel?> getInternshipById(String id) async {
    final data = await _client
        .from('internships')
        .select('*, company_profiles(*)')
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;

    final savedIds = await _getSavedInternshipIds();
    final model = InternshipModel.fromJson(data);
    return model.copyWith(isSaved: savedIds.contains(model.id));
  }

  /// Get recommended internships (calling Edge Function or fallback query)
  Future<List<InternshipModel>> getRecommendedInternships() async {
    try {
      final res = await _client.functions.invoke('recommend-internships');
      if (res.status == 200 && res.data != null && res.data['recommendations'] != null) {
        final list = res.data['recommendations'] as List;
        final savedIds = await _getSavedInternshipIds();
        return list.map((json) {
          final model = InternshipModel.fromJson(json);
          return model.copyWith(isSaved: savedIds.contains(model.id));
        }).toList();
      }
    } catch (_) {
      // Fallback: return newest published internships
    }

    return getPublishedInternships(limit: 5);
  }

  /// Get internships created by a company
  Future<List<InternshipModel>> getCompanyInternships(String companyId) async {
    final data = await _client
        .from('internships')
        .select('*, company_profiles(*)')
        .eq('company_id', companyId)
        .order('created_at', ascending: false);

    return (data as List).map((json) => InternshipModel.fromJson(json)).toList();
  }

  /// Create new internship
  Future<InternshipModel> createInternship(Map<String, dynamic> data) async {
    final result = await _client
        .from('internships')
        .insert(data)
        .select('*, company_profiles(*)')
        .single();

    return InternshipModel.fromJson(result);
  }

  /// Update internship
  Future<InternshipModel> updateInternship(String id, Map<String, dynamic> updates) async {
    final result = await _client
        .from('internships')
        .update(updates)
        .eq('id', id)
        .select('*, company_profiles(*)')
        .single();

    return InternshipModel.fromJson(result);
  }

  /// Delete internship
  Future<void> deleteInternship(String id) async {
    await _client.from('internships').delete().eq('id', id);
  }

  /// Toggle saved / bookmark
  Future<bool> toggleBookmark(String internshipId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Must be logged in');

    // Get student_profile id
    final student = await _client
        .from('student_profiles')
        .select('id')
        .eq('user_id', userId)
        .single();
    final studentId = student['id'] as String;

    final existing = await _client
        .from('saved_internships')
        .select('id')
        .eq('student_id', studentId)
        .eq('internship_id', internshipId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('saved_internships')
          .delete()
          .eq('student_id', studentId)
          .eq('internship_id', internshipId);
      return false; // unbookmarked
    } else {
      await _client.from('saved_internships').insert({
        'student_id': studentId,
        'internship_id': internshipId,
      });
      return true; // bookmarked
    }
  }

  /// Get student's saved internships
  Future<List<InternshipModel>> getSavedInternships() async {
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
        .from('saved_internships')
        .select('internship_id, internships(*, company_profiles(*))')
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    return (data as List)
        .where((item) => item['internships'] != null)
        .map((item) {
          final model = InternshipModel.fromJson(item['internships']);
          return model.copyWith(isSaved: true);
        })
        .toList();
  }

  Future<Set<String>> _getSavedInternshipIds() async {
    final userId = currentUserId;
    if (userId == null) return {};

    final student = await _client
        .from('student_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (student == null) return {};
    final studentId = student['id'] as String;

    final data = await _client
        .from('saved_internships')
        .select('internship_id')
        .eq('student_id', studentId);

    return (data as List)
        .map((e) => e['internship_id'] as String)
        .toSet();
  }
}
