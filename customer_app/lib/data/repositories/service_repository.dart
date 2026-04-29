import '../../core/errors/error_handler.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../models/service_model.dart';

class ServiceRepository {
  ServiceRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<Result<List<ServiceModel>>> getServices({
    String? category,
    bool? popularOnly,
  }) async {
    return ErrorHandler.guard(() async {
      final filters = <String, dynamic>{
        'is_active': true,
      };
      if (category != null) filters['category'] = category;
      if (popularOnly == true) filters['is_popular'] = true;

      final data = await apiClient.query(
        'services',
        filters: filters,
        orderBy: 'name',
      );
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    });
  }

  Future<Result<ServiceModel>> getService(String serviceId) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.query(
        'services',
        filters: {'id': serviceId},
      );
      if (data.isEmpty) throw Exception('Service not found');
      return ServiceModel.fromJson(data.first);
    });
  }

  Future<Result<List<String>>> getCategories() async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.query('services', select: 'category');
      final categories = data
          .map((json) => json['category'] as String)
          .toSet()
          .toList()
        ..sort();
      return categories;
    });
  }

  Future<Result<List<ServiceModel>>> searchServices(String query) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.query('services');
      final lowerQuery = query.toLowerCase();
      return data
          .map((json) => ServiceModel.fromJson(json))
          .where((s) =>
              s.name.toLowerCase().contains(lowerQuery) ||
              s.category.toLowerCase().contains(lowerQuery) ||
              s.tags.any((t) => t.toLowerCase().contains(lowerQuery)))
          .toList();
    });
  }
}
