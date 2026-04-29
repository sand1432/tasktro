class ServiceReportModel {
  const ServiceReportModel({
    required this.id,
    required this.bookingId,
    required this.providerId,
    required this.userId,
    required this.summary,
    required this.workPerformed,
    required this.costBreakdown,
    this.totalCost = 0.0,
    this.warrantyInfo,
    this.warrantyExpiresAt,
    this.beforeImages = const [],
    this.afterImages = const [],
    this.recommendations = const [],
    this.createdAt,
  });

  final String id;
  final String bookingId;
  final String providerId;
  final String userId;
  final String summary;
  final List<String> workPerformed;
  final List<CostItem> costBreakdown;
  final double totalCost;
  final String? warrantyInfo;
  final DateTime? warrantyExpiresAt;
  final List<String> beforeImages;
  final List<String> afterImages;
  final List<String> recommendations;
  final DateTime? createdAt;

  factory ServiceReportModel.fromJson(Map<String, dynamic> json) {
    return ServiceReportModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      providerId: json['provider_id'] as String,
      userId: json['user_id'] as String,
      summary: json['summary'] as String,
      workPerformed: List<String>.from(json['work_performed'] as List? ?? []),
      costBreakdown: (json['cost_breakdown'] as List?)
              ?.map((c) => CostItem.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      warrantyInfo: json['warranty_info'] as String?,
      warrantyExpiresAt: json['warranty_expires_at'] != null
          ? DateTime.parse(json['warranty_expires_at'] as String)
          : null,
      beforeImages: List<String>.from(json['before_images'] as List? ?? []),
      afterImages: List<String>.from(json['after_images'] as List? ?? []),
      recommendations:
          List<String>.from(json['recommendations'] as List? ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'provider_id': providerId,
      'user_id': userId,
      'summary': summary,
      'work_performed': workPerformed,
      'cost_breakdown': costBreakdown.map((c) => c.toJson()).toList(),
      'total_cost': totalCost,
      'warranty_info': warrantyInfo,
      'warranty_expires_at': warrantyExpiresAt?.toIso8601String(),
      'before_images': beforeImages,
      'after_images': afterImages,
      'recommendations': recommendations,
    };
  }
}

class CostItem {
  const CostItem({
    required this.description,
    required this.amount,
    this.category = 'service',
  });

  final String description;
  final double amount;
  final String category;

  factory CostItem.fromJson(Map<String, dynamic> json) {
    return CostItem(
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String? ?? 'service',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'category': category,
    };
  }
}
