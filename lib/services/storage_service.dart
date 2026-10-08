import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import 'supabase_service.dart';

class StorageService {
  final SupabaseClient _client = SupabaseService.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  /// Upload Avatar image
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final ext = fileName.split('.').last;
    final path = '$userId/avatar.$ext';

    await _client.storage.from(AppConstants.bucketAvatars).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = _client.storage
        .from(AppConstants.bucketAvatars)
        .getPublicUrl(path);

    // Also update profiles avatar_url
    await _client.from('profiles').update({'avatar_url': publicUrl}).eq('id', userId);

    return publicUrl;
  }

  /// Upload CV (PDF)
  Future<String> uploadCv({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final path = '$userId/$fileName';

    await _client.storage.from(AppConstants.bucketCv).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'application/pdf',
          ),
        );

    // Get signed URL (since CV bucket is private) or publicUrl
    final cvUrl = _client.storage.from(AppConstants.bucketCv).getPublicUrl(path);

    // Update student_profiles cv_url
    await _client
        .from('student_profiles')
        .update({'cv_url': cvUrl})
        .eq('user_id', userId);

    return cvUrl;
  }

  /// Upload Company Logo
  Future<String> uploadCompanyLogo({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final ext = fileName.split('.').last;
    final path = '$userId/logo.$ext';

    await _client.storage.from(AppConstants.bucketCompanyLogos).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = _client.storage
        .from(AppConstants.bucketCompanyLogos)
        .getPublicUrl(path);

    await _client
        .from('company_profiles')
        .update({'logo_url': publicUrl})
        .eq('user_id', userId);

    return publicUrl;
  }

  /// Upload Portfolio Image
  Future<String> uploadPortfolioImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = fileName.split('.').last;
    final path = '$userId/$timestamp.$ext';

    await _client.storage.from(AppConstants.bucketPortfolio).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(AppConstants.bucketPortfolio).getPublicUrl(path);
  }
}
