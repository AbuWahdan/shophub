import 'package:flutter/material.dart';
import '../pages/splash_screen.dart';
import '../pages/onboarding_screen.dart';
import '../pages/auth/login_screen.dart';
import '../pages/auth/register_screen.dart';
import '../pages/auth/otp_screen.dart';
import '../pages/main_page.dart';
import '../pages/categories_page.dart';
import '../pages/search_filter_page.dart';
import '../pages/orders_page.dart';
import '../pages/addresses_page.dart';
import '../pages/profile_settings_page.dart';
import '../pages/info_page.dart';
import '../pages/about_page.dart';
import '../l10n/l10n.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoute() {
    return <String, WidgetBuilder>{
      '/': (_) => SplashScreen(),
      '/onboarding': (_) => OnboardingScreen(),
      '/login': (_) => LoginScreen(),
      '/register': (_) => RegisterScreen(),
      '/otp': (_) => OTPVerificationScreen(),
      '/main': (_) => MainPage(),
      '/categories': (_) => CategoriesPage(),
      '/search': (_) => SearchFilterPage(),
      '/orders': (_) => OrdersPage(),
      '/addresses': (_) => AddressesPage(),
      '/settings': (_) => ProfileSettingsPage(),
      '/privacy': (context) => InfoPage(
            title: context.l10n.settingsPrivacyPolicy,
            content: context.l10n.settingsPrivacyPolicyContent,
          ),
      '/terms': (context) => InfoPage(
            title: context.l10n.settingsTerms,
            content: context.l10n.settingsTermsContent,
          ),
      '/help': (context) => InfoPage(
            title: context.l10n.settingsHelp,
            content: context.l10n.settingsHelpContent,
          ),
      '/about': (_) => const AboutPage(),
      '/licenses': (context) => LicensePage(
            applicationName: context.l10n.appTitle,
            applicationVersion: context.l10n.appVersion,
            applicationLegalese: context.l10n.appLegalese,
          ),
    };
  }
}
