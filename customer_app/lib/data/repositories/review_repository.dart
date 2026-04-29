import '../../core/errors/error_handler.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../models/review_model.dart';

class ReviewRepository {
  ReviewRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<Result<List<ReviewModel>>> getProviderReviews(
    String providerId, {
    int? limit,
    int? offset,
  }) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.query(
        'reviews',
        filters: {'provider_id': providerId},
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
        offset: offset,
      );
      return data.map((json) => ReviewModel.fromJson(json)).toList();
    });
  }

  Future<Result<ReviewModel>> createReview(ReviewModel review) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.insert('reviews', review.toJson());
      return ReviewModel.fromJson(data);
    });
  }

  Future<Result<double>> getProviderAverageRating(String providerId) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.query(
        'reviews',
        select: 'rating',
        filters: {'provider_id': providerId},
      );
      if (data.isEmpty) return 0.0;
      final total = data.fold<double>(
        0.0,
        (sum, json) => sum + (json['rating'] as num).toDouble(),
      );
      return total / data.length;
    });
  }
}
