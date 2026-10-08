class PortfolioModel {
  final String id;
  final String studentId;
  final String title;
  final String? description;
  final String? projectUrl;
  final String? imageUrl;
  final DateTime createdAt;

  PortfolioModel({
    required this.id,
    required this.studentId,
    required this.title,
    this.description,
    this.projectUrl,
    this.imageUrl,
    required this.createdAt,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      projectUrl: json['project_url'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'title': title,
      'description': description,
      'project_url': projectUrl,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
