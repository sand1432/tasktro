import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'bootstrap/app_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'features/ai_assistant/providers/ai_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/booking/providers/booking_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();
  runApp(const FixlyAIApp());
}

class FixlyAIApp extends StatelessWidget {
  const FixlyAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme & Locale
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs: AppBootstrap.sharedPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(prefs: AppBootstrap.sharedPreferences),
        ),

        // Core Services
        ChangeNotifierProvider.value(value: AppBootstrap.connectivityService),
        ChangeNotifierProvider.value(value: AppBootstrap.featureFlagsService),

        // Auth
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: AppBootstrap.authRepository,
          ),
        ),

        // AI
        ChangeNotifierProvider(
          create: (_) => AiProvider(aiService: AppBootstrap.aiService),
        ),

        // Booking
        ChangeNotifierProvider(
          create: (_) => BookingProvider(
            bookingRepository: AppBootstrap.bookingRepository,
          ),
        ),

        // Chat
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            chatRepository: AppBootstrap.chatRepository,
            aiService: AppBootstrap.aiService,
          ),
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          final router = AppRouter.router(context);

          return MaterialApp.router(
            title: 'Fixly AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          );
        },
      ),
    );
  }
}
