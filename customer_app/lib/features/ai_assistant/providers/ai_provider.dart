import 'package:flutter/foundation.dart';

import '../../../data/models/ai_analysis_model.dart';
import '../../../services/ai/ai_service.dart';
import '../../../services/analytics/analytics_service.dart';

enum AiStatus { idle, analyzing, complete, error }

class AiProvider extends ChangeNotifier {
  AiProvider({required this.aiService});

  final AiService aiService;

  AiStatus _status = AiStatus.idle;
  AiAnalysisModel? _currentAnalysis;
  List<AiAnalysisModel> _history = [];
  String? _errorMessage;

  AiStatus get status => _status;
  AiAnalysisModel? get currentAnalysis => _currentAnalysis;
  List<AiAnalysisModel> get history => _history;
  String? get errorMessage => _errorMessage;
  bool get isAnalyzing => _status == AiStatus.analyzing;

  Future<AiAnalysisModel?> analyzeIssue({
    required String description,
    List<String>? imageUrls,
    String? userId,
    double? latitude,
    double? longitude,
  }) async {
    _status = AiStatus.analyzing;
    _errorMessage = null;
    notifyListeners();

    final result = await aiService.analyzeIssue(
      description: description,
      imageUrls: imageUrls,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
    );

    return result.when(
      success: (analysis) {
        _currentAnalysis = analysis;
        _history = [analysis, ..._history];
        _status = AiStatus.complete;

        AnalyticsService.instance.logAiAnalysis(
          category: analysis.suggestedServiceCategory ?? 'unknown',
          confidenceScore: analysis.confidenceScore,
          urgencyLevel: analysis.urgencyLevel,
        );

        notifyListeners();
        return analysis;
      },
      failure: (e) {
        _errorMessage = e.message;
        _status = AiStatus.error;
        notifyListeners();
        return null;
      },
    );
  }

  Future<Map<String, dynamic>?> getSmartPricing({
    required String serviceCategory,
    required String problemDescription,
    double? latitude,
    double? longitude,
    String? urgencyLevel,
  }) async {
    final result = await aiService.getSmartPricing(
      serviceCategory: serviceCategory,
      problemDescription: problemDescription,
      latitude: latitude,
      longitude: longitude,
      urgencyLevel: urgencyLevel,
    );

    return result.data;
  }

  void clearAnalysis() {
    _currentAnalysis = null;
    _status = AiStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AiStatus.error) {
      _status = AiStatus.idle;
    }
    notifyListeners();
  }
}
