import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'app_locale';

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );
  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(
    const Locale('en'),
  );

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString(_themeKey);
    themeMode.value = _parseThemeMode(themeValue);
    final localeValue = prefs.getString(_localeKey);
    locale.value = _parseLocale(localeValue);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _serializeThemeMode(mode));
  }

  static Future<void> setLocale(Locale? newLocale) async {
    locale.value = newLocale ?? const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.value!.languageCode);
  }

  static ThemeMode _parseThemeMode(String? value) {
    if (value == 'light') return ThemeMode.light;
    if (value == 'dark') return ThemeMode.dark;
    return ThemeMode.light;
  }

  static String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'light';
    }
  }

  static Locale? _parseLocale(String? value) {
    if (value == 'ar') return const Locale('ar');
    return const Locale('en');
  }
}
