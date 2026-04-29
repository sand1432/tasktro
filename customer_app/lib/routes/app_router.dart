import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/ai_assistant/screens/ai_analysis_screen.dart';
import '../features/ai_assistant/screens/ai_result_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/booking/screens/booking_detail_screen.dart';
import '../features/booking/screens/booking_list_screen.dart';
import '../features/booking/screens/create_booking_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/reports/screens/report_screen.dart';
import '../features/reviews/screens/create_review_screen.dart';
import '../features/safety/screens/emergency_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import 'shell_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup';

        if (!isAuthenticated && !isAuthRoute) return '/login';
        if (isAuthenticated && isAuthRoute) return '/';
        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // Main shell
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => ShellScreen(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/bookings',
              builder: (context, state) => const BookingListScreen(),
            ),
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),

        // AI Analysis
        GoRoute(
          path: '/ai-analyze',
          builder: (context, state) => const AiAnalysisScreen(),
        ),
        GoRoute(
          path: '/ai-result',
          builder: (context, state) => const AiResultScreen(),
        ),

        // Booking
        GoRoute(
          path: '/booking/:id',
          builder: (context, state) => BookingDetailScreen(
            bookingId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/create-booking',
          builder: (context, state) => const CreateBookingScreen(),
        ),

        // Chat with booking
        GoRoute(
          path: '/chat/:bookingId',
          builder: (context, state) => ChatScreen(
            bookingId: state.pathParameters['bookingId'],
          ),
        ),

        // Report
        GoRoute(
          path: '/report/:bookingId',
          builder: (context, state) => ReportScreen(
            bookingId: state.pathParameters['bookingId']!,
          ),
        ),

        // Review
        GoRoute(
          path: '/review/:bookingId',
          builder: (context, state) => CreateReviewScreen(
            bookingId: state.pathParameters['bookingId']!,
          ),
        ),

        // Safety
        GoRoute(
          path: '/emergency',
          builder: (context, state) => const EmergencyScreen(),
        ),

        // Settings
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}
