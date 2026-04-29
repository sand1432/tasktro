import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider({required this.prefs}) {
    _loadLocale();
  }

  final SharedPreferences prefs;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  void _loadLocale() {
    final code = prefs.getString('locale');
    if (code != null) {
      _locale = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }
}
