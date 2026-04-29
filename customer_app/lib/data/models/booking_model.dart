enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  disputed;

  String get displayName => switch (this) {
    BookingStatus.pending => 'Pending',
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.inProgress => 'In Progress',
    BookingStatus.completed => 'Completed',
    BookingStatus.cancelled => 'Cancelled',
    BookingStatus.disputed => 'Disputed',
  };

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value || e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => BookingStatus.pending,
    );
  }
}

enum BookingType {
  instant,
  scheduled;
}

class BookingModel {
  const BookingModel({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.bookingType,
    this.description,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.address,
    this.latitude,
    this.longitude,
    this.estimatedCostMin,
    this.estimatedCostMax,
    this.finalCost,
    this.isLocked = false,
    this.lockedPrice,
    this.lockedAt,
    this.aiRequestId,
    this.notes,
    this.beforeImages = const [],
    this.afterImages = const [],
    this.createdAt,
    this.updatedAt,
    this.providerName,
    this.serviceName,
  });

  final String id;
  final String userId;
  final String providerId;
  final String serviceId;
  final BookingStatus status;
  final BookingType bookingType;
  final String? description;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? estimatedCostMin;
  final double? estimatedCostMax;
  final double? finalCost;
  final bool isLocked;
  final double? lockedPrice;
  final DateTime? lockedAt;
  final String? aiRequestId;
  final String? notes;
  final List<String> beforeImages;
  final List<String> afterImages;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? providerName;
  final String? serviceName;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      providerId: json['provider_id'] as String,
      serviceId: json['service_id'] as String,
      status: BookingStatus.fromString(json['status'] as String? ?? 'pending'),
      bookingType: json['booking_type'] == 'instant'
          ? BookingType.instant
          : BookingType.scheduled,
      description: json['description'] as String?,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      estimatedCostMin: (json['estimated_cost_min'] as num?)?.toDouble(),
      estimatedCostMax: (json['estimated_cost_max'] as num?)?.toDouble(),
      finalCost: (json['final_cost'] as num?)?.toDouble(),
      isLocked: json['is_locked'] as bool? ?? false,
      lockedPrice: (json['locked_price'] as num?)?.toDouble(),
      lockedAt: json['locked_at'] != null
          ? DateTime.parse(json['locked_at'] as String)
          : null,
      aiRequestId: json['ai_request_id'] as String?,
      notes: json['notes'] as String?,
      beforeImages: List<String>.from(json['before_images'] as List? ?? []),
      afterImages: List<String>.from(json['after_images'] as List? ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      providerName: json['provider_name'] as String?,
      serviceName: json['service_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'provider_id': providerId,
      'service_id': serviceId,
      'status': status.name,
      'booking_type': bookingType.name,
      'description': description,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'estimated_cost_min': estimatedCostMin,
      'estimated_cost_max': estimatedCostMax,
      'final_cost': finalCost,
      'is_locked': isLocked,
      'locked_price': lockedPrice,
      'locked_at': lockedAt?.toIso8601String(),
      'ai_request_id': aiRequestId,
      'notes': notes,
      'before_images': beforeImages,
      'after_images': afterImages,
    };
  }

  BookingModel copyWith({
    BookingStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    double? finalCost,
    String? notes,
    List<String>? beforeImages,
    List<String>? afterImages,
  }) {
    return BookingModel(
      id: id,
      userId: userId,
      providerId: providerId,
      serviceId: serviceId,
      status: status ?? this.status,
      bookingType: bookingType,
      description: description,
      scheduledAt: scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      address: address,
      latitude: latitude,
      longitude: longitude,
      estimatedCostMin: estimatedCostMin,
      estimatedCostMax: estimatedCostMax,
      finalCost: finalCost ?? this.finalCost,
      isLocked: isLocked,
      lockedPrice: lockedPrice,
      lockedAt: lockedAt,
      aiRequestId: aiRequestId,
      notes: notes ?? this.notes,
      beforeImages: beforeImages ?? this.beforeImages,
      afterImages: afterImages ?? this.afterImages,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      providerName: providerName,
      serviceName: serviceName,
    );
  }
}
