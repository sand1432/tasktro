class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.providerId,
    required this.rating,
    this.comment,
    this.beforeImages = const [],
    this.afterImages = const [],
    this.providerResponse,
    this.createdAt,
    this.userName,
    this.userAvatarUrl,
  });

  final String id;
  final String bookingId;
  final String userId;
  final String providerId;
  final double rating;
  final String? comment;
  final List<String> beforeImages;
  final List<String> afterImages;
  final String? providerResponse;
  final DateTime? createdAt;
  final String? userName;
  final String? userAvatarUrl;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      userId: json['user_id'] as String,
      providerId: json['provider_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      beforeImages: List<String>.from(json['before_images'] as List? ?? []),
      afterImages: List<String>.from(json['after_images'] as List? ?? []),
      providerResponse: json['provider_response'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      userName: json['user_name'] as String?,
      userAvatarUrl: json['user_avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'user_id': userId,
      'provider_id': providerId,
      'rating': rating,
      'comment': comment,
      'before_images': beforeImages,
      'after_images': afterImages,
    };
  }
}
