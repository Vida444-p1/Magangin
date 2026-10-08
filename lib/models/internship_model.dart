import 'company_profile_model.dart';

class InternshipModel {
  final String id;
  final String companyId;
  final String title;
  final String description;
  final List<String> requirements;
  final String category;
  final String location;
  final String workType; // 'On-site', 'Hybrid', 'Remote'
  final String duration;
  final num salaryMin;
  final num salaryMax;
  final int quota;
  final DateTime deadline;
  final String status; // 'draft', 'published', 'closed'
  final DateTime createdAt;
  final DateTime updatedAt;
  final CompanyProfileModel? company;
  final bool isSaved;

  InternshipModel({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    this.requirements = const [],
    required this.category,
    required this.location,
    required this.workType,
    required this.duration,
    required this.salaryMin,
    required this.salaryMax,
    required this.quota,
    required this.deadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.company,
    this.isSaved = false,
  });

  bool get isPublished => status == 'published';
  bool get isClosed => status == 'closed';
  bool get isDraft => status == 'draft';
  bool get isExpired => DateTime.now().isAfter(deadline);

  InternshipModel copyWith({
    String? id,
    String? companyId,
    String? title,
    String? description,
    List<String>? requirements,
    String? category,
    String? location,
    String? workType,
    String? duration,
    num? salaryMin,
    num? salaryMax,
    int? quota,
    DateTime? deadline,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    CompanyProfileModel? company,
    bool? isSaved,
  }) {
    return InternshipModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      category: category ?? this.category,
      location: location ?? this.location,
      workType: workType ?? this.workType,
      duration: duration ?? this.duration,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      quota: quota ?? this.quota,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      company: company ?? this.company,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  factory InternshipModel.fromJson(Map<String, dynamic> json) {
    List<String> parseReqs(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    CompanyProfileModel? parsedCompany;
    if (json['company_profiles'] != null && json['company_profiles'] is Map) {
      parsedCompany = CompanyProfileModel.fromJson(
        Map<String, dynamic>.from(json['company_profiles'] as Map),
      );
    }

    return InternshipModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requirements: parseReqs(json['requirements']),
      category: json['category'] as String? ?? 'General',
      location: json['location'] as String? ?? '',
      workType: json['work_type'] as String? ?? 'On-site',
      duration: json['duration'] as String? ?? '',
      salaryMin: json['salary_min'] != null ? (json['salary_min'] as num) : 0,
      salaryMax: json['salary_max'] != null ? (json['salary_max'] as num) : 0,
      quota: json['quota'] != null ? (json['quota'] as int) : 1,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      status: json['status'] as String? ?? 'draft',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      company: parsedCompany,
      isSaved: json['is_saved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'title': title,
      'description': description,
      'requirements': requirements,
      'category': category,
      'location': location,
      'work_type': workType,
      'duration': duration,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'quota': quota,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
