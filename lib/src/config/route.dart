import 'package:flutter/cupertino.dart';
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
    };
  }
}
