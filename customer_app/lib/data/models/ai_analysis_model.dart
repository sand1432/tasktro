class AiAnalysisModel {
  const AiAnalysisModel({
    required this.id,
    required this.userId,
    required this.inputText,
    this.inputImageUrls = const [],
    required this.problem,
    required this.causes,
    required this.estimatedCostMin,
    required this.estimatedCostMax,
    required this.urgencyLevel,
    required this.confidenceScore,
    this.safetyDisclaimer,
    this.diySteps = const [],
    this.preventiveTips = const [],
    this.suggestedServiceCategory,
    this.isRepeatIssue = false,
    this.relatedRequestIds = const [],
    this.createdAt,
  });

  final String id;
  final String userId;
  final String inputText;
  final List<String> inputImageUrls;
  final String problem;
  final List<AiCause> causes;
  final double estimatedCostMin;
  final double estimatedCostMax;
  final String urgencyLevel;
  final double confidenceScore;
  final String? safetyDisclaimer;
  final List<String> diySteps;
  final List<String> preventiveTips;
  final String? suggestedServiceCategory;
  final bool isRepeatIssue;
  final List<String> relatedRequestIds;
  final DateTime? createdAt;

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      inputText: json['input_text'] as String? ?? '',
      inputImageUrls:
          List<String>.from(json['input_image_urls'] as List? ?? []),
      problem: json['problem'] as String? ?? '',
      causes: (json['causes'] as List?)
              ?.map((c) => AiCause.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      estimatedCostMin:
          (json['estimated_cost_min'] as num?)?.toDouble() ?? 0.0,
      estimatedCostMax:
          (json['estimated_cost_max'] as num?)?.toDouble() ?? 0.0,
      urgencyLevel: json['urgency_level'] as String? ?? 'medium',
      confidenceScore:
          (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      safetyDisclaimer: json['safety_disclaimer'] as String?,
      diySteps: List<String>.from(json['diy_steps'] as List? ?? []),
      preventiveTips:
          List<String>.from(json['preventive_tips'] as List? ?? []),
      suggestedServiceCategory:
          json['suggested_service_category'] as String?,
      isRepeatIssue: json['is_repeat_issue'] as bool? ?? false,
      relatedRequestIds:
          List<String>.from(json['related_request_ids'] as List? ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'input_text': inputText,
      'input_image_urls': inputImageUrls,
      'problem': problem,
      'causes': causes.map((c) => c.toJson()).toList(),
      'estimated_cost_min': estimatedCostMin,
      'estimated_cost_max': estimatedCostMax,
      'urgency_level': urgencyLevel,
      'confidence_score': confidenceScore,
      'safety_disclaimer': safetyDisclaimer,
      'diy_steps': diySteps,
      'preventive_tips': preventiveTips,
      'suggested_service_category': suggestedServiceCategory,
      'is_repeat_issue': isRepeatIssue,
      'related_request_ids': relatedRequestIds,
    };
  }
}

class AiCause {
  const AiCause({
    required this.cause,
    required this.probability,
    this.explanation,
  });

  final String cause;
  final double probability;
  final String? explanation;

  factory AiCause.fromJson(Map<String, dynamic> json) {
    return AiCause(
      cause: json['cause'] as String,
      probability: (json['probability'] as num).toDouble(),
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cause': cause,
      'probability': probability,
      'explanation': explanation,
    };
  }
}
