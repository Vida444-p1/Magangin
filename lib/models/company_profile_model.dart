class CompanyProfileModel {
  final String id;
  final String userId;
  final String companyName;
  final String? description;
  final String? industry;
  final String? location;
  final String? website;
  final String? logoUrl;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyProfileModel({
    required this.id,
    required this.userId,
    required this.companyName,
    this.description,
    this.industry,
    this.location,
    this.website,
    this.logoUrl,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      companyName: json['company_name'] as String? ?? 'Perusahaan',
      description: json['description'] as String?,
      industry: json['industry'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String?,
      phone: json['phone'] as String?,
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
      'company_name': companyName,
      'description': description,
      'industry': industry,
      'location': location,
      'website': website,
      'logo_url': logoUrl,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
