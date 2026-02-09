import 'package:flutter/material.dart';
import 'package:sinwar_shoping/src/pages/about_page.dart';
import 'package:sinwar_shoping/src/pages/addresses_page.dart';
import 'package:sinwar_shoping/src/pages/auth/login_screen.dart';
import 'package:sinwar_shoping/src/pages/auth/otp_screen.dart';
import 'package:sinwar_shoping/src/pages/auth/register_screen.dart';
import 'package:sinwar_shoping/src/pages/categories_page.dart';
import 'package:sinwar_shoping/src/pages/info_page.dart';
import 'package:sinwar_shoping/src/pages/main_page.dart';
import 'package:sinwar_shoping/src/pages/onboarding_screen.dart';
import 'package:sinwar_shoping/src/pages/orders_page.dart';
import 'package:sinwar_shoping/src/pages/search_filter_page.dart';
import 'package:sinwar_shoping/src/pages/splash_screen.dart';
import '../l10n/app_localizations.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String main = '/main';
  static const String categories = '/categories';
  static const String search = '/search';
  static const String orders = '/orders';
  static const String addresses = '/addresses';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String help = '/help';
  static const String about = '/about';
  static const String licenses = '/licenses';
  static const String scheduleService = '/schedule-service';
  static const String serviceDetails = '/service-details';
  static const String categoryList = '/category-list';
  // ... add other route constants

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );

      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );

      case otp:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OTPVerificationScreen(),
        );

      case main:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainPage(),
        );

      case categories:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CategoriesPage(),
        );

      case search:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SearchFilterPage(),
        );

      case orders:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OrdersPage(),
        );

      case addresses:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddressesPage(),
        );

      // case settings:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => const ProfileSettingsPage(),
      //   );

      case privacy:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return InfoPage(
              title: l10n.settingsPrivacyPolicy,
              content: l10n.settingsPrivacyPolicyContent,
            );
          },
        );

      case terms:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return InfoPage(
              title: l10n.settingsTerms,
              content: l10n.settingsTermsContent,
            );
          },
        );

      case help:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return InfoPage(
              title: l10n.settingsHelp,
              content: l10n.settingsHelpContent,
            );
          },
        );

      case about:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AboutPage(),
        );

      case licenses:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return LicensePage(
              applicationName: l10n.appTitle,
              applicationVersion: l10n.appVersion,
              applicationLegalese: l10n.appLegalese,
            );
          },
        );

      // case scheduleService:
      //   final serviceName = args?['serviceName'] as String?;
      //   final service = args?['service'];
      //   final appointmentId = args?['appointmentId'] as String?;
        
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => ScheduleServiceScreen(
      //       serviceName: serviceName,
      //       service: service,
      //       appointmentId: appointmentId,
      //     ),
      //   );

      // case serviceDetails:
      //   final service = args?['service'];
        
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => ServiceDetailsScreen(service: service!),
      //   );

      // case categoryList:
      //   final categoryName = args?['categoryName'] as String? ?? 'All';
        
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => CategoryListScreen(categoryName: categoryName),
      //   );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}