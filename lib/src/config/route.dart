import 'package:flutter/material.dart';
import 'package:sinwar_shoping/src/pages/about_page.dart';
import 'package:sinwar_shoping/src/pages/addresses/addresses_page.dart';
import 'package:sinwar_shoping/src/pages/auth/login_screen.dart';
import 'package:sinwar_shoping/src/pages/auth/otp_screen.dart';
import 'package:sinwar_shoping/src/pages/auth/register_screen.dart';
import 'package:sinwar_shoping/src/pages/auth/forgot_password_email_screen.dart';
import 'package:sinwar_shoping/src/pages/auth/otp_sent_notice_screen.dart';
import 'package:sinwar_shoping/src/pages/auth/otp_verification_screen.dart';
import 'package:sinwar_shoping/src/pages/auth/reset_password_screen.dart';
import 'package:sinwar_shoping/src/pages/auth/password_updated_screen.dart';
import 'package:sinwar_shoping/src/pages/categories_page.dart';
import 'package:sinwar_shoping/src/pages/info_page.dart';
import 'package:sinwar_shoping/src/pages/main_page.dart';
import 'package:sinwar_shoping/src/pages/my_products_page.dart';
import 'package:sinwar_shoping/src/pages/onboarding_screen.dart';
import 'package:sinwar_shoping/src/pages/order_confirmation_screen.dart';
import 'package:sinwar_shoping/src/pages/orders_page.dart';
import 'package:sinwar_shoping/src/pages/products/insert_product_page.dart';
import 'package:sinwar_shoping/src/pages/product_comments_page.dart';
import 'package:sinwar_shoping/src/pages/product_details_new.dart';
import 'package:sinwar_shoping/src/pages/profile/change_password_screen.dart';
import 'package:sinwar_shoping/src/pages/profile_settings_page.dart';
import 'package:sinwar_shoping/src/pages/search_filter_page.dart';
import 'package:sinwar_shoping/src/pages/splash_screen.dart';
import 'package:sinwar_shoping/src/pages/edit_profile_screen.dart';
import 'package:sinwar_shoping/src/pages/wishlist/wishlist_page.dart';
import 'package:sinwar_shoping/src/pages/rate_product_screen.dart';
import 'package:sinwar_shoping/src/model/product_api.dart';
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
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String wishlist = '/wishlist';
  static const String productComments = '/product-comments';
  static const String productDetails = '/product-details';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String help = '/help';
  static const String about = '/about';
  static const String licenses = '/licenses';
  static const String scheduleService = '/schedule-service';
  static const String serviceDetails = '/service-details';
  static const String categoryList = '/category-list';
  static const String insertProduct = '/products/insert';
  static const String myProducts = '/products/my';
  static const String forgotPassword = '/forgot-password';
  static const String otpSent = '/otp-sent';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String passwordUpdated = '/password-updated';
  static const String deliveryLocation = '/delivery-location';
  static const String rateProduct = '/rate-product';
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

      case forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordEmailScreen(),
        );

      case otpSent:
        final username = args?['username'] as String? ?? '';
        final email = args?['email'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OtpSentNoticeScreen(username: username, email: email),
        );

      case otpVerification:
        final username = args?['username'] as String? ?? '';
        final email = args?['email'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              OtpVerificationScreen(username: username, email: email),
        );

      case resetPassword:
        final username = args?['username'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetPasswordScreen(username: username),
        );

      case passwordUpdated:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PasswordUpdatedScreen(),
        );

      case main:
        final initialTabIndex = args?['initialTabIndex'] as int?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MainPage(initialTabIndex: initialTabIndex),
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

      // case checkout:
      //   final cartItems =
      //       (args?['cartItems'] as List<CartItem>?) ?? AppData.cartItems;
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => CheckoutScreen(cartItems: cartItems),
      //   );

      case orderConfirmation:
        final receipt = (args?['receipt'] as Map<String, dynamic>?) ?? const {};
        final total = (args?['total'] as num?)?.toDouble() ?? 0;
        final onContinue = args?['onContinue'] as VoidCallback?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OrderConfirmationScreen(
            receipt: receipt,
            total: total,
            onContinue: onContinue,
          ),
        );

      case wishlist:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WishlistPage(),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileSettingsPage(),
        );

      case editProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EditProfileScreen(),
        );

      case changePassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChangePasswordScreen(),
        );

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

      case insertProduct:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const InsertProductPage(),
        );

      case myProducts:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyProductsPage(),
        );

      case productComments:
        final productId = args?['productId'] as int? ?? 0;
        final productName = args?['productName'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductCommentsPage(
            productId: productId,
            productName: productName,
          ),
        );

      case productDetails:
        final product = args?['product'] as ApiProduct?;
        if (product == null) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Text('Product not found. Please go back and try again.'),
              ),
            ),
          );
        }
        final selectedSize = args?['selectedSize'] as String?;
        final selectedColor = args?['selectedColor'] as String?;
        final selectedDetId = args?['selectedDetId'] as int?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductDetailsPage(
            product: product,
            initialSize: selectedSize,
            initialColor: selectedColor,
            initialDetId: selectedDetId,
          ),
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

      // case deliveryLocation:
      //   final savedAddresses =
      //       (args?['savedAddresses'] as List<DeliveryLocation>?) ?? const [];
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) =>
      //         DeliveryLocationScreen(savedAddresses: savedAddresses),
      //   );

      case rateProduct:
        final product = args?['product'] as ApiProduct?;
        if (product == null) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Product not found. Please go back and try again.'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RateProductScreen(product: product),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
