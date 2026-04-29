class ApiEndpoints {
  ApiEndpoints._();

  // Supabase Tables
  static const String users = 'users';
  static const String providers = 'providers';
  static const String bookings = 'bookings';
  static const String services = 'services';
  static const String reviews = 'reviews';
  static const String messages = 'messages';
  static const String aiRequests = 'ai_requests';

  // Supabase Edge Functions
  static const String analyzeIssue = 'analyze-issue';
  static const String chatWithAI = 'chat-with-ai';
  static const String createPayment = 'create-payment-intent';
  static const String matchProvider = 'match-providers';
  static const String calculatePrice = 'calculate-price';
  static const String generateReport = 'generate-report';

  // Supabase Storage Buckets
  static const String profileImages = 'profile-images';
  static const String serviceImages = 'service-images';
  static const String beforeAfterImages = 'before-after-images';
  static const String chatAttachments = 'chat-attachments';
  static const String videoInspections = 'video-inspections';
}
