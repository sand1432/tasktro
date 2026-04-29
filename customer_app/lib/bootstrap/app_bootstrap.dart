import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/network/connectivity_service.dart';
import '../core/security/secure_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/booking_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/service_repository.dart';
import '../services/ai/ai_service.dart';
import '../services/analytics/analytics_service.dart';
import '../services/feature_flags/feature_flags_service.dart';
import '../services/stripe/stripe_service.dart';
import '../services/supabase/supabase_service.dart';

class AppBootstrap {
  AppBootstrap._();

  static late SharedPreferences sharedPreferences;
  static late ConnectivityService connectivityService;
  static late SecureStorageService secureStorage;
  static late ApiClient apiClient;
  static late AiService aiService;
  static late StripeService stripeService;
  static late FeatureFlagsService featureFlagsService;

  // Repositories
  static late AuthRepository authRepository;
  static late BookingRepository bookingRepository;
  static late ChatRepository chatRepository;
  static late ReviewRepository reviewRepository;
  static late ServiceRepository serviceRepository;

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize core services
    sharedPreferences = await SharedPreferences.getInstance();
    connectivityService = ConnectivityService();
    secureStorage = SecureStorageService();

    // Initialize Supabase
    await SupabaseService.initialize();

    // Initialize Stripe
    await StripeService.initialize();

    // Initialize Analytics
    await AnalyticsService.instance.initialize();

    // Create API client
    apiClient = ApiClient(
      supabase: SupabaseService.client,
      connectivityService: connectivityService,
    );

    // Create services
    aiService = AiService(apiClient: apiClient);
    stripeService = StripeService(apiClient: apiClient);
    featureFlagsService = FeatureFlagsService(prefs: sharedPreferences);

    // Create repositories
    authRepository = AuthRepository(apiClient: apiClient);
    bookingRepository = BookingRepository(apiClient: apiClient);
    chatRepository = ChatRepository(apiClient: apiClient);
    reviewRepository = ReviewRepository(apiClient: apiClient);
    serviceRepository = ServiceRepository(apiClient: apiClient);
  }
}
