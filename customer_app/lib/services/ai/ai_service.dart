import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../data/models/ai_analysis_model.dart';

class AiService {
  AiService({required this.apiClient});

  final ApiClient apiClient;

  Future<Result<AiAnalysisModel>> analyzeIssue({
    required String description,
    List<String>? imageUrls,
    String? userId,
    double? latitude,
    double? longitude,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await apiClient.invokeFunction(
        'analyze-issue',
        body: {
          'description': description,
          'image_urls': imageUrls ?? [],
          'user_id': userId,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response['error'] != null) {
        throw AIServiceException(
          response['error'] as String,
          code: 'AI_ERROR',
        );
      }

      return AiAnalysisModel.fromJson(response);
    });
  }

  Future<Result<Map<String, dynamic>>> chatWithAI({
    required String message,
    required String conversationId,
    String? context,
    String? userId,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await apiClient.invokeFunction(
        'chat-with-ai',
        body: {
          'message': message,
          'conversation_id': conversationId,
          'context': context,
          'user_id': userId,
        },
      );

      if (response['error'] != null) {
        throw AIServiceException(
          response['error'] as String,
          code: 'AI_CHAT_ERROR',
        );
      }

      return response;
    });
  }

  Future<Result<Map<String, dynamic>>> getSmartPricing({
    required String serviceCategory,
    required String problemDescription,
    double? latitude,
    double? longitude,
    String? urgencyLevel,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await apiClient.invokeFunction(
        'calculate-price',
        body: {
          'service_category': serviceCategory,
          'problem_description': problemDescription,
          'latitude': latitude,
          'longitude': longitude,
          'urgency_level': urgencyLevel,
        },
      );

      return response;
    });
  }

  Future<Result<List<Map<String, dynamic>>>> getDiySuggestions({
    required String problem,
    required String category,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await apiClient.invokeFunction(
        'diy-suggestions',
        body: {
          'problem': problem,
          'category': category,
        },
      );

      final steps = response['steps'] as List?;
      return steps?.cast<Map<String, dynamic>>() ?? [];
    });
  }

  static Map<String, dynamic>? tryParseStructuredResponse(String raw) {
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      debugPrint('Failed to parse AI response as JSON');
    }
    return null;
  }
}
