import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureFlagsService extends ChangeNotifier {
  FeatureFlagsService({required this.prefs}) {
    _loadFlags();
  }

  final SharedPreferences prefs;

  final Map<String, bool> _flags = {};

  static const Map<String, bool> _defaults = {
    'ai_assistant': true,
    'instant_booking': true,
    'video_inspection': true,
    'smart_pricing': true,
    'price_lock': true,
    'diy_suggestions': true,
    'voice_input': true,
    'image_analysis': true,
    'auto_solve_engine': true,
    'user_memory': true,
    'hyperlocal_intelligence': true,
    'safety_features': true,
    'dark_mode': true,
    'push_notifications': true,
    'live_tracking': true,
    'in_app_payments': true,
  };

  void _loadFlags() {
    for (final entry in _defaults.entries) {
      _flags[entry.key] = prefs.getBool('ff_${entry.key}') ?? entry.value;
    }
  }

  bool isEnabled(String flag) => _flags[flag] ?? false;

  Future<void> setFlag(String flag, bool value) async {
    _flags[flag] = value;
    await prefs.setBool('ff_$flag', value);
    notifyListeners();
  }

  Future<void> resetFlags() async {
    for (final entry in _defaults.entries) {
      _flags[entry.key] = entry.value;
      await prefs.remove('ff_${entry.key}');
    }
    notifyListeners();
  }

  Map<String, bool> get allFlags => Map.unmodifiable(_flags);

  // Convenience getters
  bool get isAiAssistantEnabled => isEnabled('ai_assistant');
  bool get isInstantBookingEnabled => isEnabled('instant_booking');
  bool get isVideoInspectionEnabled => isEnabled('video_inspection');
  bool get isSmartPricingEnabled => isEnabled('smart_pricing');
  bool get isPriceLockEnabled => isEnabled('price_lock');
  bool get isDiySuggestionsEnabled => isEnabled('diy_suggestions');
  bool get isVoiceInputEnabled => isEnabled('voice_input');
  bool get isImageAnalysisEnabled => isEnabled('image_analysis');
  bool get isAutoSolveEnabled => isEnabled('auto_solve_engine');
  bool get isUserMemoryEnabled => isEnabled('user_memory');
  bool get isHyperlocalEnabled => isEnabled('hyperlocal_intelligence');
  bool get isSafetyEnabled => isEnabled('safety_features');
  bool get isDarkModeEnabled => isEnabled('dark_mode');
  bool get isLiveTrackingEnabled => isEnabled('live_tracking');
}
