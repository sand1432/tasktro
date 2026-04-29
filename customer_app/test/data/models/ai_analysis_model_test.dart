import 'package:flutter_test/flutter_test.dart';
import 'package:fixly_ai/data/models/ai_analysis_model.dart';

void main() {
  group('AiAnalysisModel', () {
    final sampleJson = {
      'id': 'test-id-123',
      'user_id': 'user-456',
      'input_text': 'My faucet is leaking',
      'input_image_urls': ['url1.jpg', 'url2.jpg'],
      'problem': 'Leaking faucet due to worn washer',
      'causes': [
        {
          'cause': 'Worn out washer',
          'probability': 0.7,
          'explanation': 'Common cause of faucet leaks',
        },
        {
          'cause': 'Corroded valve seat',
          'probability': 0.3,
          'explanation': 'Can cause dripping',
        },
      ],
      'estimated_cost_min': 50.0,
      'estimated_cost_max': 150.0,
      'urgency_level': 'medium',
      'confidence_score': 0.85,
      'safety_disclaimer': 'Turn off water supply before attempting repair',
      'diy_steps': ['Turn off water', 'Remove handle', 'Replace washer'],
      'preventive_tips': ['Regular maintenance', 'Check for leaks monthly'],
      'suggested_service_category': 'plumbing',
      'is_repeat_issue': false,
      'related_request_ids': [],
      'created_at': '2024-01-01T00:00:00.000Z',
    };

    test('fromJson creates correct model', () {
      final model = AiAnalysisModel.fromJson(sampleJson);

      expect(model.id, 'test-id-123');
      expect(model.userId, 'user-456');
      expect(model.inputText, 'My faucet is leaking');
      expect(model.inputImageUrls, hasLength(2));
      expect(model.problem, 'Leaking faucet due to worn washer');
      expect(model.causes, hasLength(2));
      expect(model.causes.first.cause, 'Worn out washer');
      expect(model.causes.first.probability, 0.7);
      expect(model.estimatedCostMin, 50.0);
      expect(model.estimatedCostMax, 150.0);
      expect(model.urgencyLevel, 'medium');
      expect(model.confidenceScore, 0.85);
      expect(model.safetyDisclaimer, isNotNull);
      expect(model.diySteps, hasLength(3));
      expect(model.preventiveTips, hasLength(2));
      expect(model.suggestedServiceCategory, 'plumbing');
      expect(model.isRepeatIssue, false);
    });

    test('toJson produces correct map', () {
      final model = AiAnalysisModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['user_id'], 'user-456');
      expect(json['input_text'], 'My faucet is leaking');
      expect(json['problem'], 'Leaking faucet due to worn washer');
      expect(json['causes'], hasLength(2));
      expect(json['estimated_cost_min'], 50.0);
      expect(json['estimated_cost_max'], 150.0);
      expect(json['urgency_level'], 'medium');
      expect(json['confidence_score'], 0.85);
    });

    test('fromJson handles missing optional fields', () {
      final minimalJson = {
        'problem': 'Some problem',
        'causes': [],
        'estimated_cost_min': 0,
        'estimated_cost_max': 0,
        'urgency_level': 'low',
        'confidence_score': 0.5,
      };

      final model = AiAnalysisModel.fromJson(minimalJson);

      expect(model.id, '');
      expect(model.userId, '');
      expect(model.inputImageUrls, isEmpty);
      expect(model.safetyDisclaimer, isNull);
      expect(model.diySteps, isEmpty);
      expect(model.preventiveTips, isEmpty);
      expect(model.isRepeatIssue, false);
    });
  });

  group('AiCause', () {
    test('fromJson and toJson work correctly', () {
      final json = {
        'cause': 'Worn washer',
        'probability': 0.7,
        'explanation': 'Most common cause',
      };

      final cause = AiCause.fromJson(json);
      expect(cause.cause, 'Worn washer');
      expect(cause.probability, 0.7);
      expect(cause.explanation, 'Most common cause');

      final output = cause.toJson();
      expect(output['cause'], 'Worn washer');
      expect(output['probability'], 0.7);
      expect(output['explanation'], 'Most common cause');
    });
  });
}
