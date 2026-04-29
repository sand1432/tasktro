class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.iconName,
    this.basePriceMin,
    this.basePriceMax,
    this.estimatedDurationMinutes,
    this.isPopular = false,
    this.isActive = true,
    this.tags = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final String? description;
  final String? iconName;
  final double? basePriceMin;
  final double? basePriceMax;
  final int? estimatedDurationMinutes;
  final bool isPopular;
  final bool isActive;
  final List<String> tags;
  final DateTime? createdAt;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      basePriceMin: (json['base_price_min'] as num?)?.toDouble(),
      basePriceMax: (json['base_price_max'] as num?)?.toDouble(),
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      isPopular: json['is_popular'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'icon_name': iconName,
      'base_price_min': basePriceMin,
      'base_price_max': basePriceMax,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'is_popular': isPopular,
      'is_active': isActive,
      'tags': tags,
    };
  }
}
