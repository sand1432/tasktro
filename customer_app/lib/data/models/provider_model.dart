class ProviderModel {
  const ProviderModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.services,
    this.description,
    this.avatarUrl,
    this.phone,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalJobs = 0,
    this.isVerified = false,
    this.isAvailable = true,
    this.responseTimeMinutes = 30,
    this.serviceRadiusKm = 25.0,
    this.hourlyRate,
    this.certifications = const [],
    this.workPhotos = const [],
    this.createdAt,
  });

  final String id;
  final String userId;
  final String businessName;
  final List<String> services;
  final String? description;
  final String? avatarUrl;
  final String? phone;
  final String? email;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int totalReviews;
  final int totalJobs;
  final bool isVerified;
  final bool isAvailable;
  final int responseTimeMinutes;
  final double serviceRadiusKm;
  final double? hourlyRate;
  final List<String> certifications;
  final List<String> workPhotos;
  final DateTime? createdAt;

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String,
      services: List<String>.from(json['services'] as List? ?? []),
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalJobs: json['total_jobs'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      responseTimeMinutes: json['response_time_minutes'] as int? ?? 30,
      serviceRadiusKm: (json['service_radius_km'] as num?)?.toDouble() ?? 25.0,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      certifications: List<String>.from(json['certifications'] as List? ?? []),
      workPhotos: List<String>.from(json['work_photos'] as List? ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'services': services,
      'description': description,
      'avatar_url': avatarUrl,
      'phone': phone,
      'email': email,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_jobs': totalJobs,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'response_time_minutes': responseTimeMinutes,
      'service_radius_km': serviceRadiusKm,
      'hourly_rate': hourlyRate,
      'certifications': certifications,
      'work_photos': workPhotos,
    };
  }
}
