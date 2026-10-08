import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

final applicationServiceProvider = Provider<ApplicationService>((ref) => ApplicationService());

// Student's submitted applications
final studentApplicationsProvider = FutureProvider<List<ApplicationModel>>((ref) async {
  final service = ref.watch(applicationServiceProvider);
  return await service.getStudentApplications();
});

// Company's received applications
final companyApplicantsProvider = FutureProvider.family<List<ApplicationModel>, String?>((ref, internshipId) async {
  final service = ref.watch(applicationServiceProvider);
  return await service.getCompanyApplicants(internshipId: internshipId);
});
