// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ShopHub';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appLegalese => '© 2024 ShopHub. All rights reserved.';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicyContent => 'Your privacy is important to us.';

  @override
  String get settingsTerms => 'Terms and Conditions';

  @override
  String get settingsTermsContent => 'Please read our terms and conditions.';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsHelpContent => 'How can we help you?';

  @override
  String get ordersTitle => 'My Orders';

  @override
  String get productEditTitle => 'Edit Product';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get insertProductMenu => 'Add Product';

  @override
  String get productItemName => 'Product Name';

  @override
  String get productItemNameHint => 'Enter product name';

  @override
  String get productDescriptionLabel => 'Description';

  @override
  String get productDescriptionHint => 'Enter product description';

  @override
  String get productCategory => 'Category';

  @override
  String get productUsername => 'Seller';

  @override
  String get productIsActive => 'Active';

  @override
  String get productInsertAction => 'Add Product';

  @override
  String get productRequiredField => 'This field is required';

  @override
  String get productInvalidValue => 'Please enter a valid value';

  @override
  String get productSelectCategoryValidation => 'Please select a category';

  @override
  String get productAddImageValidation => 'Please add at least one image';

  @override
  String get productAccountUnavailable =>
      'Account information is not available';

  @override
  String get productInsertSuccess => 'Product added successfully';

  @override
  String get productInsertFailed => 'Failed to add product';

  @override
  String get productColor => 'Color';

  @override
  String get productSize => 'Size';

  @override
  String get productPriceLabel => 'Price';

  @override
  String get productPriceHint => 'Enter price';

  @override
  String get productQuantityLabel => 'Quantity';

  @override
  String get productQuantityHint => 'Enter quantity';

  @override
  String get otpVerificationTitle => 'Verify OTP';

  @override
  String get otpVerificationSubtitle => 'Enter the OTP sent to your email';

  @override
  String get otpVerificationVerify => 'Verify';

  @override
  String get otpResendQuestion => 'Didn\'t receive the code?';

  @override
  String get otpResend => 'Resend';

  @override
  String otpResendCountdown(Object seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email to reset your password';

  @override
  String get forgotPasswordSendOtp => 'Send OTP';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerFullNameLabel => 'Full Name';

  @override
  String get registerFullNameHint => 'Enter your full name';

  @override
  String get validationNameRequired => 'Name is required';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailHint => 'Enter your email';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Please enter a valid email';

  @override
  String get homeSearchHint => 'Search products';

  @override
  String get categoryAll => 'All';

  @override
  String get errorLoadingProducts => 'Error loading products';

  @override
  String get retry => 'Retry';

  @override
  String get noProductsInCategory => 'No products in this category';

  @override
  String get validationPhoneRequired => 'Phone number is required';

  @override
  String get validationPhoneInvalid => 'Please enter a valid phone number';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => 'Enter your password';

  @override
  String get validationPasswordRequired => 'Password is required';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get registerConfirmPasswordLabel => 'Confirm Password';

  @override
  String get registerConfirmPasswordHint => 'Confirm your password';

  @override
  String get validationConfirmPasswordRequired =>
      'Confirm password is required';

  @override
  String get validationConfirmPasswordMismatch => 'Passwords do not match';

  @override
  String get registerAgreeTerms => 'I agree to the Terms and Conditions';

  @override
  String get registerCreateAccount => 'Create Account';

  @override
  String get registerHaveAccount => 'Already have an account?';

  @override
  String get otpSentTitle => 'OTP Sent';

  @override
  String get otpSentSubtitle => 'We\'ve sent an OTP to your email';

  @override
  String get commonContinue => 'Continue';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginSignIn => 'Sign In';

  @override
  String get loginContinueAsGuest => 'Continue as Guest';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginCreateAccount => 'Create Account';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordSubtitle => 'Enter your new password';

  @override
  String get resetPasswordNewLabel => 'New Password';

  @override
  String get resetPasswordConfirmLabel => 'Confirm Password';

  @override
  String get resetPasswordUpdateButton => 'Update Password';

  @override
  String get passwordUpdatedTitle => 'Password Updated';

  @override
  String get passwordUpdatedSubtitle =>
      'Your password has been successfully updated';

  @override
  String get passwordUpdatedBackToLogin => 'Back to Login';

  @override
  String passwordUpdatedAutoRedirect(Object seconds) {
    return 'Redirecting to login in $seconds seconds';
  }

  @override
  String get otpTitle => 'Verify OTP';

  @override
  String get otpEnterCode => 'Enter the OTP code';

  @override
  String get otpSubtitle => 'Enter the 6-digit code sent to your email';

  @override
  String get validationOtpRequired => 'OTP is required';

  @override
  String get validationOtpInvalid => 'Please enter a valid OTP';

  @override
  String otpResendIn(Object seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String get otpVerify => 'Verify';

  @override
  String get validationOtpInvalidLength => 'OTP must be 6 digits';

  @override
  String get onboardingWelcomeTitle => 'Welcome to ShopHub';

  @override
  String get onboardingWelcomeSubtitle => 'Your favorite shopping destination';

  @override
  String get onboardingDeliveryTitle => 'Fast Delivery';

  @override
  String get onboardingDeliverySubtitle => 'Get your orders delivered quickly';

  @override
  String get onboardingSecureTitle => 'Secure Shopping';

  @override
  String get onboardingSecureSubtitle => 'Your transactions are protected';

  @override
  String get onboardingDealsTitle => 'Exclusive Deals';

  @override
  String get onboardingDealsSubtitle =>
      'Get amazing discounts on your favorite products';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingNext => 'Next';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountShoppingSection => 'Shopping';

  @override
  String get accountMyOrders => 'My Orders';

  @override
  String get accountMyOrdersSubtitle => 'View your orders';

  @override
  String get accountWishlist => 'Wishlist';

  @override
  String get accountWishlistSubtitle => 'Your saved items';

  @override
  String get accountReviews => 'My Reviews';

  @override
  String get accountReviewsSubtitle => 'Rate products';

  @override
  String get accountReviewsComingSoon => 'Coming soon';

  @override
  String get accountSettingsSection => 'Settings';

  @override
  String get accountDeliveryAddresses => 'Delivery Addresses';

  @override
  String get accountDeliveryAddressesSubtitle => 'Manage addresses';

  @override
  String get accountPaymentMethods => 'Payment Methods';

  @override
  String get accountPaymentMethodsSubtitle => 'Add payment methods';

  @override
  String get accountPaymentMethodsComingSoon => 'Coming soon';

  @override
  String get accountSettings => 'Settings';

  @override
  String get accountSettingsSubtitle => 'Account settings';

  @override
  String get accountSupportSection => 'Support';

  @override
  String get accountHelp => 'Help';

  @override
  String get accountHelpSubtitle => 'Get help';

  @override
  String get accountAbout => 'About';

  @override
  String get accountAboutSubtitle => 'About ShopHub';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get accountUserName => 'Name';

  @override
  String get accountUserEmail => 'Email';

  @override
  String get accountUserPhone => 'Phone';

  @override
  String get settingsLogoutConfirmTitle => 'Logout';

  @override
  String get accountLogoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get commonLogout => 'Logout';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDisplay => 'Display';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguageRegion => 'Language & Region';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsEmailNotifications => 'Email Notifications';

  @override
  String get settingsEmailNotificationsSubtitle => 'Receive email updates';

  @override
  String get settingsPushNotifications => 'Push Notifications';

  @override
  String get settingsPushNotificationsSubtitle => 'Receive push notifications';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutApp => 'About App';

  @override
  String get settingsLogoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Delete Account';

  @override
  String get settingsDeleteAccountConfirmMessage =>
      'Are you sure? This action cannot be undone.';

  @override
  String get commonDelete => 'Delete';

  @override
  String get settingsAccountDeleted => 'Account deleted successfully';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get searchFilterTitle => 'Search & Filter';

  @override
  String get searchFilterHint => 'Search products';

  @override
  String get searchFilterCategory => 'Category';

  @override
  String get searchFilterPrice => 'Price';

  @override
  String get searchFilterRating => 'Rating';

  @override
  String get searchFilterSort => 'Sort';

  @override
  String get searchFilterNoResults => 'No results found';

  @override
  String get searchFilterSelectCategory => 'Select Category';

  @override
  String get searchFilterPriceRange => 'Price Range';

  @override
  String get commonApply => 'Apply';

  @override
  String get searchFilterMinimumRating => 'Minimum Rating';

  @override
  String get searchFilterAnyRating => 'Any';

  @override
  String get searchFilterSortBy => 'Sort By';

  @override
  String get categorySneakers => 'Sneakers';

  @override
  String get categoryJackets => 'Jackets';

  @override
  String get categoryWatches => 'Watches';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryClothing => 'Clothing';

  @override
  String get searchFilterSortBestSelling => 'Best Selling';

  @override
  String get searchFilterSortPriceLowHigh => 'Price: Low to High';

  @override
  String get searchFilterSortPriceHighLow => 'Price: High to Low';

  @override
  String get searchFilterSortBestRating => 'Best Rating';

  @override
  String get searchFilterSortNewest => 'Newest';

  @override
  String get addressesSaved => 'Address saved successfully';

  @override
  String get addressesDeleted => 'Address deleted successfully';

  @override
  String get addressesTitle => 'Addresses';

  @override
  String get addressesDefault => 'Default';

  @override
  String get commonEdit => 'Edit';

  @override
  String get addressesSetDefault => 'Set as Default';

  @override
  String get addressesEditTitle => 'Edit Address';

  @override
  String get addressesAddTitle => 'Add New Address';

  @override
  String get addressesNameLabel => 'Name';

  @override
  String get addressesStreetLabel => 'Street Address';

  @override
  String get addressesCityLabel => 'City';

  @override
  String get addressesStateLabel => 'State';

  @override
  String get addressesCountryLabel => 'Country';

  @override
  String get addressesZipLabel => 'ZIP Code';

  @override
  String get addressesPhoneLabel => 'Phone';

  @override
  String get commonSave => 'Save';

  @override
  String get checkoutPaymentCard => 'Credit Card';

  @override
  String get checkoutPaymentCash => 'Cash on Delivery';

  @override
  String get checkoutPaymentWallet => 'Wallet';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutOrderSummary => 'Order Summary';

  @override
  String get cartEmptyMessage => 'Your cart is empty';

  @override
  String get checkoutDeliveryAddress => 'Delivery Address';

  @override
  String get checkoutPaymentMethod => 'Payment Method';

  @override
  String get checkoutTotal => 'Total';

  @override
  String checkoutQuantity(Object quantity) {
    return 'Qty: $quantity';
  }

  @override
  String get accountMyProducts => 'My Products';

  @override
  String get myProductsEmptyMessage => 'No products yet';

  @override
  String get stockIn => 'In Stock';

  @override
  String get stockOut => 'Out of Stock';

  @override
  String get orderSuccessTitle => 'Order Confirmed';

  @override
  String get orderSuccessSubtitle => 'Thank you for your order';

  @override
  String get orderSuccessOrderId => 'Order ID';

  @override
  String get orderSuccessTotalAmount => 'Total Amount';

  @override
  String get orderSuccessThanks => 'Thank you for shopping with us';

  @override
  String get orderSuccessContinueShopping => 'Continue Shopping';

  @override
  String get orderSuccessViewOrders => 'View Orders';

  @override
  String get splashTitle => 'ShopHub';

  @override
  String get splashSubtitle => 'Your shopping destination';

  @override
  String get profileOrders => 'Orders';

  @override
  String get profileAddresses => 'Addresses';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileHelpMessage => 'How can we help you?';

  @override
  String get commonClose => 'Close';

  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navCart => 'Cart';

  @override
  String get navAccount => 'Account';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get cartQuantity => 'Quantity';

  @override
  String get productAddToCart => 'Add to Cart';

  @override
  String get cartRemoveItemTitle => 'Remove Item';

  @override
  String get cartRemoveItemMessage =>
      'Are you sure you want to remove this item?';

  @override
  String get commonRemove => 'Remove';

  @override
  String get cartItemRemoved => 'Item removed from cart';

  @override
  String cartAvailableStock(Object stock) {
    return 'Available: $stock';
  }

  @override
  String get cartItemTotal => 'Total';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartStartShopping => 'Start Shopping';

  @override
  String get cartTitle => 'Shopping Cart';

  @override
  String get cartShipping => 'Shipping';

  @override
  String get cartShippingFree => 'Free';

  @override
  String get cartCheckout => 'Proceed to Checkout';

  @override
  String productReviews(Object count) {
    return '$count Reviews';
  }

  @override
  String productSold(Object count) {
    return '$count Sold';
  }

  @override
  String get productDescription => 'Description';

  @override
  String get productShowLess => 'Show Less';

  @override
  String get productShowMore => 'Show More';

  @override
  String productAddedToCart(Object name) {
    return '$name added to cart';
  }
}
