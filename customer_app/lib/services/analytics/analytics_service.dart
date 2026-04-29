import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;

  bool _initialized = false;

  Future<void> initialize() async {
    _initialized = true;
    debugPrint('Analytics initialized');
  }

  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (!_initialized) return;
    debugPrint('Analytics Event: $name | $parameters');
  }

  void logScreenView(String screenName) {
    logEvent('screen_view', parameters: {'screen_name': screenName});
  }

  void logAiAnalysis({
    required String category,
    required double confidenceScore,
    required String urgencyLevel,
  }) {
    logEvent('ai_analysis', parameters: {
      'category': category,
      'confidence_score': confidenceScore,
      'urgency_level': urgencyLevel,
    });
  }

  void logBookingCreated({
    required String serviceCategory,
    required String bookingType,
    required double estimatedCost,
  }) {
    logEvent('booking_created', parameters: {
      'service_category': serviceCategory,
      'booking_type': bookingType,
      'estimated_cost': estimatedCost,
    });
  }

  void logPaymentCompleted({
    required double amount,
    required String paymentMethod,
  }) {
    logEvent('payment_completed', parameters: {
      'amount': amount,
      'payment_method': paymentMethod,
    });
  }

  void logSearchPerformed(String query) {
    logEvent('search', parameters: {'query': query});
  }

  void setUserId(String userId) {
    debugPrint('Analytics: User ID set to $userId');
  }

  void setUserProperty(String name, String value) {
    debugPrint('Analytics: User property $name = $value');
  }
}
