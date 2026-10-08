import 'internship_model.dart';
import 'student_profile_model.dart';
import 'user_model.dart';

class ApplicationModel {
  final String id;
  final String internshipId;
  final String studentId;
  final String cvUrl;
  final String? coverLetter;
  final String status; // 'submitted', 'reviewing', 'interview', 'accepted', 'rejected', 'withdrawn'
  final DateTime appliedAt;
  final DateTime updatedAt;
  final InternshipModel? internship;
  final StudentProfileModel? studentProfile;
  final ProfileModel? profile;

  ApplicationModel({
    required this.id,
    required this.internshipId,
    required this.studentId,
    required this.cvUrl,
    this.coverLetter,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.internship,
    this.studentProfile,
    this.profile,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    InternshipModel? parsedInternship;
    if (json['internships'] != null && json['internships'] is Map) {
      parsedInternship = InternshipModel.fromJson(
        Map<String, dynamic>.from(json['internships'] as Map),
      );
    }

    StudentProfileModel? parsedStudent;
    if (json['student_profiles'] != null && json['student_profiles'] is Map) {
      parsedStudent = StudentProfileModel.fromJson(
        Map<String, dynamic>.from(json['student_profiles'] as Map),
      );
    }

    ProfileModel? parsedProfile;
    if (json['profiles'] != null && json['profiles'] is Map) {
      parsedProfile = ProfileModel.fromJson(
        Map<String, dynamic>.from(json['profiles'] as Map),
      );
    }

    return ApplicationModel(
      id: json['id'] as String,
      internshipId: json['internship_id'] as String,
      studentId: json['student_id'] as String,
      cvUrl: json['cv_url'] as String? ?? '',
      coverLetter: json['cover_letter'] as String?,
      status: json['status'] as String? ?? 'submitted',
      appliedAt: json['applied_at'] != null
          ? DateTime.parse(json['applied_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      internship: parsedInternship,
      studentProfile: parsedStudent,
      profile: parsedProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'internship_id': internshipId,
      'student_id': studentId,
      'cv_url': cvUrl,
      'cover_letter': coverLetter,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
