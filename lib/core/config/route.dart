import 'package:flutter/material.dart';
import 'package:sinwar_shoping/models/product/product_model.dart';
import '../../l10n/app_localizations.dart';
import '../../models/item_comment_model.dart';
import '../../models/user_model.dart';
import '../../presentation/auth/forgot_password_email_screen.dart';
import '../../presentation/auth/login/login_screen.dart';
import '../../presentation/auth/otp_verification_screen.dart';
import '../../presentation/auth/password_updated_screen.dart';
import '../../presentation/auth/signup/register_screen.dart';
import '../../presentation/auth/signup/signup_otp_verification_screen.dart';
import '../../presentation/categories_tab/categories_page.dart';
import '../../presentation/cards/add_card_page.dart';
import '../../presentation/cards/my_cards_page.dart';
import '../../presentation/home_tab/main_page.dart';
import '../../presentation/products/comments/comments_screen.dart';
import '../../presentation/profile/my_products/my_products_page.dart';
import '../../presentation/profile/notifications/notifications_screen.dart';
import '../../presentation/profile/settings/change_email/change_email_screen.dart';
import '../../presentation/profile/settings/change_email/verify_new_email_screen.dart';
import '../../presentation/profile/settings/widgets/info_page.dart';
import '../../presentation/products/product_details.dart';
import '../../presentation/products/provider_products_screen.dart';
import '../../presentation/profile/addresses/addresses_page.dart';
import '../../presentation/profile/edit_profile/edit_profile_screen.dart';
import '../../presentation/cart_tab/checkout/order_confirmation/order_confirmation_screen.dart';
import '../../presentation/profile/orders/orders_page.dart';
import '../../presentation/profile/settings/about/about_page.dart';
import '../../presentation/profile/settings/change_password/change_password_screen.dart';
import '../../presentation/profile/settings/profile_settings_page.dart';
import '../../presentation/profile/wishlist/wishlist_page.dart';
import '../../presentation/splash/onboarding_screen.dart';
import '../../presentation/splash/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String notifications = '/notifications';

  static const String verifyNewEmail = '/verify-new-email';
  static const String changeEmail = '/change-email';
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String main = '/main';
  static const String categories = '/categories';
  static const String orders = '/orders';
  static const String addresses = '/addresses';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String wishlist = '/wishlist';
  static const String myCards = '/my-cards';
  static const String addCard = '/add-card';
  static const String productComments = '/product-comments';
  static const String productDetails = '/product-details';
  static const String providerProducts = '/provider-products';
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
  static const String myProducts = '/my_products/my';
  static const String forgotPassword = '/forgot-password';
  static const String otpSent = '/otp-sent';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String passwordUpdated = '/password-updated';
  static const String deliveryLocation = '/delivery-location';
  static const String rateProduct = '/rate-product';

  static const String signupOtpVerification = '/signup-otp-verification';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
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
      case signupOtpVerification:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignupOtpVerificationScreen(),
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

      case forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordEmailScreen(),
        );

      case otpSent:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            username: args['username'] as String? ?? '',
            email: args['email'] as String? ?? '',
            flow: args['flow'] as String? ?? 'forgot_password',
            pendingUser: args['pendingUser'] as UserModel?, // <-- must be here
          ),
        );

      case notifications:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationsScreen(),
        );

      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        final username = args?['username'] as String? ?? '';
        final email = args?['email'] as String? ?? '';
        final flow = args?['flow'] as String? ?? 'forgot_password';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OTPVerificationScreen(
            username: username,
            email: email,
            flow: flow,
          ),
        );

      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final username = args?['username'] as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangePasswordScreen(
            flow: ChangePasswordFlow.resetFromOtp,
            usernameOverride: username,
          ),
        );

      case passwordUpdated:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PasswordUpdatedScreen(),
        );

      case main:
        final args = settings.arguments as Map<String, dynamic>?;
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

      case AppRoutes.productComments:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => CommentsScreen(
            productId: args['productId'],
            productName: args['productName'],
            comments: List<ItemCommentModel>.from(args['comments'] ?? []),
          ),
        );

      case providerProducts:
        final providerUsername = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProviderProductsScreen(
            providerUsername: providerUsername,
          ),
        );

      case orderConfirmation:
        final args = settings.arguments as Map<String, dynamic>?;
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

      case myCards:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyCardsPage(),
        );

      case addCard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddCardPage(),
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

      case changeEmail:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ChangeEmailScreen(),
        );

      case verifyNewEmail:
        final newEmail = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerifyNewEmailScreen(newEmail: newEmail),
        );
      case changePassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final flowName = args?['flow'] as String?;
        final flow = flowName == 'reset'
            ? ChangePasswordFlow.resetFromOtp
            : ChangePasswordFlow.changeWithCurrentPassword;
        final usernameOverride = args?['username'] as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangePasswordScreen(
            flow: flow,
            usernameOverride: usernameOverride,
          ),
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

      // case insertProduct:
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => const InsertProductPage(),
      //   );

      case myProducts:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MyProductsPage(),
        );

      case productDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final product = args?['product'] as ProductModel?;
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
          builder: (_) => ProductDetails(
            product: product,
            initialSize: selectedSize,
            initialColor: selectedColor,
            initialDetId: selectedDetId,
          ),
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
