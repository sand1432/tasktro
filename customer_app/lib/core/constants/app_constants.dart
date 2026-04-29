class AppConstants {
  AppConstants._();

  static const String appName = 'Fixly AI';
  static const String appVersion = '1.0.0';

  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Stripe
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  // API Endpoints (Edge Functions)
  static const String aiAnalyzeEndpoint = '/functions/v1/ai-analyze';
  static const String aiChatEndpoint = '/functions/v1/ai-chat';
  static const String createPaymentIntent = '/functions/v1/create-payment-intent';
  static const String matchProviders = '/functions/v1/match-providers';
  static const String smartPricing = '/functions/v1/smart-pricing';

  // Booking
  static const int instantBookingWindowMinutes = 60;
  static const int maxBookingAdvanceDays = 30;

  // AI
  static const double minConfidenceScore = 0.3;
  static const double highConfidenceThreshold = 0.8;

  // Pagination
  static const int defaultPageSize = 20;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);

  // Location
  static const double defaultSearchRadiusKm = 25.0;
  static const double maxSearchRadiusKm = 100.0;

  // Price Lock
  static const Duration priceLockDuration = Duration(hours: 24);
}
