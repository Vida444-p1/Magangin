class StudentProfileModel {
  final String id;
  final String userId;
  final String? university;
  final String? major;
  final int? semester;
  final String? location;
  final String? bio;
  final List<String> skills;
  final String? cvUrl;
  final String? portfolioUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentProfileModel({
    required this.id,
    required this.userId,
    this.university,
    this.major,
    this.semester,
    this.location,
    this.bio,
    this.skills = const [],
    this.cvUrl,
    this.portfolioUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    List<String> parseSkills(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    return StudentProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      university: json['university'] as String?,
      major: json['major'] as String?,
      semester: json['semester'] as int?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      skills: parseSkills(json['skills']),
      cvUrl: json['cv_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'university': university,
      'major': major,
      'semester': semester,
      'location': location,
      'bio': bio,
      'skills': skills,
      'cv_url': cvUrl,
      'portfolio_url': portfolioUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
