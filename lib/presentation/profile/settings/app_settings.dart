import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent app-wide settings: theme mode and locale.
///
/// Uses [ValueNotifier]s so [ValueListenableBuilder] in [MyApp] can react,
/// AND calls [Get.updateLocale] so [GetMaterialApp] also reacts immediately.
///
/// You must call [load] once before [runApp].
abstract final class AppSettings {
  static const _keyTheme    = 'theme_mode';
  static const _keyLanguage = 'language_code';

  // ── Notifiers ─────────────────────────────────────────────────────────────
  // Created once, never replaced — listeners registered at startup always fire.

  static final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier<ThemeMode>(ThemeMode.light);

  static final ValueNotifier<Locale?> locale =
  ValueNotifier<Locale?>(null);

  // ── Load ──────────────────────────────────────────────────────────────────

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themePref = prefs.getString(_keyTheme);
    themeMode.value = switch (themePref) {
      'dark'   => ThemeMode.dark,
      'system' => ThemeMode.system,
      _        => ThemeMode.light,
    };

    final langCode = prefs.getString(_keyLanguage);
    if (langCode != null) {
      locale.value = Locale(langCode);
      // No Get.updateLocale here — GetX isn't ready before runApp.
    }
  }

  // ── Setters ───────────────────────────────────────────────────────────────

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, switch (mode) {
      ThemeMode.dark   => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light  => 'light',
    });
  }

  static Future<void> setLocale(Locale newLocale) async {
    // FIX: GetMaterialApp owns locale state internally.
    // ValueListenableBuilder alone cannot update it — we must call
    // Get.updateLocale() so GetX rebuilds the widget tree immediately.
    Get.updateLocale(newLocale);

    // Also update the ValueNotifier so ProfileSettingsPage Switch stays
    // in sync (it reads locale.value to decide which way to render).
    if (locale.value != newLocale) {
      locale.value = newLocale;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, newLocale.languageCode);
  }
}