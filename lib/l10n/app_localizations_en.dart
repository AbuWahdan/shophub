// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get promoCodeLabel => 'Promo Code';

  @override
  String get viewDetails => 'View Details';

  @override
  String get orderDetailsTitle => 'Order Details';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get orderNet => 'Net Order';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get commonRetry => 'Retry';

  @override
  String get providerSectionViewAll => 'View All';

  @override
  String get providerSectionLabel => 'Providers';

  @override
  String get loadingProducts => 'Loading products...';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get refresh => 'Refresh';

  @override
  String productsByProvider(Object providerUsername) {
    return 'Products by $providerUsername';
  }

  @override
  String get viewStore => 'View Store';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get viewAll => 'View All';

  @override
  String get productVariantError => 'Please select a product variant';

  @override
  String get productOutOfStock => 'Product is out of stock';

  @override
  String get productDetails => 'Product Details';

  @override
  String get stockOutOfStock => 'Out of stock';

  @override
  String stockLowCount(Object stock) {
    return 'Only $stock left in stock';
  }

  @override
  String stockAvailableCount(Object stock) {
    return '$stock items available';
  }

  @override
  String get userName => 'Username';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get country => 'Country';

  @override
  String get jordan => 'Jordan';

  @override
  String get gender => 'Gender';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get notificationLoginRequired => 'Please log in to continue';

  @override
  String get notificationServerError => 'Server error. Please try again later';

  @override
  String get notificationNetworkError =>
      'Network error. Please check your connection';

  @override
  String get notificationProfileUpdateSuccess => 'Profile updated successfully';

  @override
  String get notificationImageProcessError => 'Failed to process image';

  @override
  String get notificationUnknownError => 'An unexpected error occurred';

  @override
  String get notificationEmailChangeSuccess => 'Email changed successfully';

  @override
  String get notificationCartAddError => 'Failed to add item to cart';

  @override
  String notificationProductAddedToCart(String productName) {
    return '$productName added to cart';
  }

  @override
  String get tax => 'Tax';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get promoDiscount => 'Promo Discount';

  @override
  String get wishlistLoginRequired => 'Please log in to manage your wishlist';

  @override
  String get wishlistEmptyTitle => 'No saved items';

  @override
  String get wishlistEmptySubtitle =>
      'Tap the heart icon on a product to save it here';

  @override
  String get productVariants => 'Product Variants';

  @override
  String get productAddVariant => 'Add Variant';

  @override
  String get productNoVariantsYet => 'No variants yet';

  @override
  String get productBasicInfo => 'Basic Product Information';

  @override
  String get productImagePickFailed => 'Failed to pick image';

  @override
  String get productImageUploadSuccess => 'Image uploaded successfully';

  @override
  String get productImageProcessFailed => 'Failed to process image';

  @override
  String get productDefaultImageUpdateFailed =>
      'Failed to update default image';

  @override
  String get productDefaultImageUpdated => 'Default image updated successfully';

  @override
  String get productUpdateSuccess => 'Product updated successfully';

  @override
  String get productVariantPriceMustBePositive =>
      'Variant price must be greater than zero';

  @override
  String get variantWillBeRemovedOnSave =>
      'This variant will be removed after saving';

  @override
  String get productUploading => 'Uploading product...';

  @override
  String get productAddImage => 'Add Image';

  @override
  String get productNoImagesYet => 'No images yet';

  @override
  String get productImages => 'Product Images';

  @override
  String get totalLabel => 'Total';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get errorLoadingOrders => 'Error loading orders';

  @override
  String get productUpdateAction => 'Update action';

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
  String get resetPasswordNewHint => 'Enter new password';

  @override
  String get resetPasswordConfirmLabel => 'Confirm Password';

  @override
  String get resetPasswordConfirmHint => 'Confirm new password';

  @override
  String get resetPasswordUpdateButton => 'Update Password';

  @override
  String get resetPasswordFailed =>
      'Failed to reset password. Please try again.';

  @override
  String get passwordUpdateSuccess => 'Password updated successfully';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordCurrentLabel => 'Current Password';

  @override
  String get changePasswordCurrentHint => 'Enter current password';

  @override
  String get changePasswordNewHint => 'Enter new password';

  @override
  String get changePasswordConfirmLabel => 'Confirm New Password';

  @override
  String get changePasswordConfirmHint => 'Confirm new password';

  @override
  String get changePasswordCurrentRequired => 'Current password is required';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsChangePasswordSubtitle => 'Update your account password';

  @override
  String get validationPasswordPolicy =>
      'Password must be at least 8 characters and include 1 uppercase letter, 1 number, and 1 special character';

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
  String get commonSelect => 'Select';

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
  String get savedAddressesTitle => 'Saved Addresses';

  @override
  String get searchSavedAddressesHint => 'Search saved addresses';

  @override
  String get addNewAddress => 'Add New Address';

  @override
  String get noSavedAddresses => 'No saved addresses yet';

  @override
  String get addressesLoginRequired => 'Please log in to manage addresses';

  @override
  String get addressesSettingsLabel => 'Address settings';

  @override
  String get addressesAdded => 'Address added successfully';

  @override
  String get addressesDeleteTitle => 'Delete address';

  @override
  String addressesDeleteMessage(String label) {
    return 'Delete \"$label\"?';
  }

  @override
  String get addressesFallbackCountry => 'Jordan';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get changeLocation => 'Change location';

  @override
  String get orEnterManually => 'OR ENTER MANUALLY';

  @override
  String get savingLabel => 'Saving...';

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
  String get productBrand => 'Brand';

  @override
  String get productBrandHint => 'Enter brand';

  @override
  String get productSizeGroup => 'Size Group';

  @override
  String get productSizeGroupOptional => 'Optional';

  @override
  String get productSelectGroupFirst => 'Select group first';

  @override
  String get productSelectGroupOptional => 'Select group (optional)';

  @override
  String get productSelectSizeOptional => 'Select size (optional)';

  @override
  String get productDiscountLabel => 'Discount (%)';

  @override
  String get productDiscountHint => 'Optional, defaults to 0';

  @override
  String get productDiscountInvalidRange =>
      'Discount must be between 0 and 100';

  @override
  String get productVariantRequired =>
      'Please add at least one valid product variant.';

  @override
  String get colorPickerHexHint => 'RRGGBB';

  @override
  String get colorPickerInvalidHex => 'Enter a valid 6-digit hex color';

  @override
  String get itemReviewYourReview => 'Your Review';

  @override
  String get itemReviewSubmitButton => 'Submit Review';

  @override
  String get itemReviewCommentLabel => 'Comment';

  @override
  String get itemReviewCommentHint => 'Share your experience with this item';

  @override
  String get itemReviewAlreadyRated => 'You have already rated this item.';

  @override
  String get itemReviewRatingRequired =>
      'Please select a rating between 1 and 5.';

  @override
  String get itemReviewCommentRequired => 'Please enter a comment.';

  @override
  String get itemReviewSubmittedSuccess => 'Review submitted successfully.';

  @override
  String get itemReviewLoginRequired => 'Please sign in to review this item.';

  @override
  String get itemReviewLoadFailed => 'Unable to load reviews right now.';

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

  @override
  String get addToCartLoginRequired =>
      'Please log in to add items to your cart';

  @override
  String get addToCartVariantError => 'Unable to determine product variant';

  @override
  String addToCartSuccess(Object productName) {
    return '$productName added to cart';
  }

  @override
  String get addToCartFailure => 'Failed to add to cart. Please try again.';

  @override
  String get variantDefaultSize => 'Default';

  @override
  String get variantDefaultColor => 'Default';

  @override
  String orderPromoApplied(Object code) {
    return 'Promo applied: $code';
  }

  @override
  String get orderSubtotal => 'Subtotal';

  @override
  String get orderTax => 'Tax';

  @override
  String get orderDiscount => 'Discount';

  @override
  String get orderPromoDiscount => 'Promo discount';

  @override
  String get orderTotal => 'Total';

  @override
  String get orderSummaryTitle => 'Order Summary';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get myCardsTitle => 'My Cards';

  @override
  String get addCard => 'Add Card';

  @override
  String get saveCard => 'Save Card';

  @override
  String get cardholderNameLabel => 'Cardholder Name';

  @override
  String get cardNumberLabel => 'Card Number';

  @override
  String get expiryMonthLabel => 'Month';

  @override
  String get expiryYearLabel => 'Year';

  @override
  String get cardTypeLabel => 'Card Type';

  @override
  String get setAsDefaultLabel => 'Set as default card';

  @override
  String get deleteCardTitle => 'Delete Card';

  @override
  String get deleteCardConfirm => 'Are you sure you want to remove this card?';

  @override
  String get deleteCardCancel => 'Cancel';

  @override
  String get deleteCardConfirmButton => 'Delete';

  @override
  String get cardExpiredBadge => 'EXPIRED';

  @override
  String get cardDefaultBadge => 'DEFAULT';

  @override
  String get noCardsTitle => 'No cards saved';

  @override
  String get noCardsSubtitle => 'Add a card to pay faster at checkout';

  @override
  String get cardAddedSuccess => 'Card added successfully';

  @override
  String get cardDeletedSuccess => 'Card removed';

  @override
  String get cardActionSetDefault => 'Set as default';

  @override
  String get cardActionDelete => 'Delete';

  @override
  String get selectCardTitle => 'Select a Card';

  @override
  String get addNewCard => 'Add new card';

  @override
  String get orderItemsSection => 'Items';

  @override
  String get deliveryAddressSection => 'Delivery address';

  @override
  String get amountBreakdownSection => 'Amount breakdown';

  @override
  String selectedPaymentLabel(Object method) {
    return 'Selected payment: $method';
  }

  @override
  String get placeOrder => 'Place Order';

  @override
  String get promoCodeOptional => 'Promo Code (Optional)';

  @override
  String get promoCodeHint => 'ENTER CODE';

  @override
  String get promoApplied => 'Promo applied';

  @override
  String get invalidPromoCode => 'Invalid promo code';

  @override
  String get checkoutLoginRequired =>
      'Please log in to continue with checkout.';

  @override
  String get checkoutLoginRequiredShort => 'Please log in to continue.';

  @override
  String get checkoutSelectAddress => 'Please select a delivery address.';

  @override
  String get checkoutSelectPayment => 'Please select a payment method.';

  @override
  String get checkoutSelectDeliveryAddress => 'Select delivery address';

  @override
  String get checkoutCartEmptyWarning => 'Your cart is empty.';

  @override
  String get cardNumberInvalid => 'Enter a valid 16-digit card number';

  @override
  String get cardExpiryInvalid => 'Select a future expiry date';

  @override
  String get orderIdLabel => 'Order ID';

  @override
  String get orderDateLabel => 'Order Date';

  @override
  String get orderCreatedDateLabel => 'Created Date';

  @override
  String orderItemsCount(Object count) {
    return 'Items ($count)';
  }

  @override
  String get unknownProduct => 'Unknown Product';

  @override
  String get brandLabel => 'Brand';

  @override
  String get sizeLabel => 'Size';

  @override
  String get quantityShortLabel => 'Qty';

  @override
  String get colorLabel => 'Color';

  @override
  String get orderDetailsLoadError => 'Unable to load order details';

  @override
  String get orderItemsEmptyTitle => 'No order items found';

  @override
  String get orderItemsEmptySubtitle =>
      'There are no line items available for this order yet.';

  @override
  String get changeEmailTitle => 'Change Email';

  @override
  String get changeEmailSubtitle => 'Update your email address';

  @override
  String stockOnlyLeft(Object stock) {
    return 'Only $stock left';
  }

  @override
  String orderMoreItems(Object count) {
    return '+$count more items';
  }

  @override
  String get notificationCartAddSuccess => 'Item added to cart';

  @override
  String get notificationCartRemoveSuccess => 'Item removed from cart';

  @override
  String get notificationCartRemoveError => 'Failed to remove item from cart';

  @override
  String get notificationCartUpdateSuccess => 'Cart updated';

  @override
  String get notificationCartUpdateError => 'Failed to update cart';

  @override
  String get notificationCartLoadError =>
      'Failed to load cart. Please try again.';

  @override
  String get notificationTimeoutError => 'Request timed out. Please try again';

  @override
  String get notificationOperationSuccess => 'Operation completed successfully';

  @override
  String get notificationAddressSelected => 'Address selected successfully';

  @override
  String get notificationAddressUpdateSuccess => 'Address updated successfully';

  @override
  String get notificationAddressUpdateError => 'Failed to update address';

  @override
  String get notificationAddressDeleteSuccess => 'Address deleted successfully';

  @override
  String get notificationAddressDeleteError => 'Failed to delete address';

  @override
  String get notificationCodeApplySuccess => 'Promo code applied successfully';

  @override
  String get notificationCodeApplyError => 'Invalid or expired promo code';

  @override
  String get notificationCheckoutError => 'Checkout failed. Please try again';

  @override
  String get notificationOrderPlacedSuccess => 'Order placed successfully';

  @override
  String get notificationOrderPlacedError => 'Failed to place order';

  @override
  String get notificationImageUploadError =>
      'Failed to upload image. Please try again';

  @override
  String get notificationProductSaveSuccess => 'Product saved successfully';

  @override
  String get notificationProductSaveError => 'Failed to save product';

  @override
  String get notificationProductDeleteSuccess => 'Product deleted successfully';

  @override
  String get notificationProductDeleteError => 'Failed to delete product';

  @override
  String get notificationProfileUpdateError => 'Failed to update profile';

  @override
  String get notificationPasswordChangeSuccess =>
      'Password changed successfully';

  @override
  String get notificationPasswordChangeError => 'Failed to change password';

  @override
  String get notificationEmailChangeError => 'Failed to change email';

  @override
  String get notificationWishlistAddSuccess => 'Added to wishlist';

  @override
  String get notificationWishlistAddError => 'Failed to add to wishlist';

  @override
  String get notificationWishlistRemoveSuccess => 'Removed from wishlist';

  @override
  String get notificationWishlistRemoveError =>
      'Failed to remove from wishlist';

  @override
  String get notificationReviewSubmitSuccess => 'Review submitted successfully';

  @override
  String get notificationReviewSubmitError => 'Failed to submit review';

  @override
  String get notificationPaymentProcessing => 'Processing payment...';

  @override
  String get notificationPaymentSuccess => 'Payment successful';

  @override
  String get notificationPaymentError => 'Payment failed. Please try again';

  @override
  String get notificationCopyToClipboard => 'Copied to clipboard';

  @override
  String get notificationNoAction => 'Please try again';

  @override
  String get notificationFieldRequired => 'This field is required';

  @override
  String get notificationInvalidInput => 'Invalid input';

  @override
  String get notificationLinkExpired => 'Link expired. Please try again';
}
