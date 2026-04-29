import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA78BFA);

  // Accent
  static const Color accent = Color(0xFF06B6D4);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Urgency
  static const Color urgencyCritical = Color(0xFFDC2626);
  static const Color urgencyHigh = Color(0xFFF97316);
  static const Color urgencyMedium = Color(0xFFEAB308);
  static const Color urgencyLow = Color(0xFF22C55E);

  // Light Theme
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static Color borderLight = Colors.grey.shade200;
  static Color inputFillLight = Colors.grey.shade50;

  // Dark Theme
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static Color borderDark = Colors.grey.shade800;
  static Color inputFillDark = const Color(0xFF374151);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color confidenceColor(double confidence) {
    if (confidence >= 0.8) return success;
    if (confidence >= 0.6) return info;
    if (confidence >= 0.4) return warning;
    return error;
  }

  static Color urgencyColor(String urgency) {
    return switch (urgency.toLowerCase()) {
      'critical' => urgencyCritical,
      'high' => urgencyHigh,
      'medium' => urgencyMedium,
      'low' => urgencyLow,
      _ => urgencyMedium,
    };
  }
}
