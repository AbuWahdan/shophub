import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @promoCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promoCodeLabel;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsTitle;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @orderNet.
  ///
  /// In en, this message translates to:
  /// **'Net Order'**
  String get orderNet;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @providerSectionViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get providerSectionViewAll;

  /// No description provided for @providerSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get providerSectionLabel;

  /// No description provided for @loadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Loading products...'**
  String get loadingProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @productsByProvider.
  ///
  /// In en, this message translates to:
  /// **'Products by {providerUsername}'**
  String productsByProvider(Object providerUsername);

  /// No description provided for @viewStore.
  ///
  /// In en, this message translates to:
  /// **'View Store'**
  String get viewStore;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @productVariantError.
  ///
  /// In en, this message translates to:
  /// **'Please select a product variant'**
  String get productVariantError;

  /// No description provided for @productOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Product is out of stock'**
  String get productOutOfStock;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @stockOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get stockOutOfStock;

  /// No description provided for @stockLowCount.
  ///
  /// In en, this message translates to:
  /// **'Only {stock} left in stock'**
  String stockLowCount(Object stock);

  /// No description provided for @stockAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{stock} items available'**
  String stockAvailableCount(Object stock);

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userName;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @jordan.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get jordan;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @notificationLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue'**
  String get notificationLoginRequired;

  /// No description provided for @notificationServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later'**
  String get notificationServerError;

  /// No description provided for @notificationNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get notificationNetworkError;

  /// No description provided for @notificationProfileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get notificationProfileUpdateSuccess;

  /// No description provided for @notificationImageProcessError.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image'**
  String get notificationImageProcessError;

  /// No description provided for @notificationUnknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get notificationUnknownError;

  /// No description provided for @notificationEmailChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email changed successfully'**
  String get notificationEmailChangeSuccess;

  /// No description provided for @notificationCartAddError.
  ///
  /// In en, this message translates to:
  /// **'Failed to add item to cart'**
  String get notificationCartAddError;

  /// No description provided for @notificationProductAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{productName} added to cart'**
  String notificationProductAddedToCart(String productName);

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @promoDiscount.
  ///
  /// In en, this message translates to:
  /// **'Promo Discount'**
  String get promoDiscount;

  /// No description provided for @wishlistLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to manage your wishlist'**
  String get wishlistLoginRequired;

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved items'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on a product to save it here'**
  String get wishlistEmptySubtitle;

  /// No description provided for @productVariants.
  ///
  /// In en, this message translates to:
  /// **'Product Variants'**
  String get productVariants;

  /// No description provided for @productAddVariant.
  ///
  /// In en, this message translates to:
  /// **'Add Variant'**
  String get productAddVariant;

  /// No description provided for @productNoVariantsYet.
  ///
  /// In en, this message translates to:
  /// **'No variants yet'**
  String get productNoVariantsYet;

  /// No description provided for @productBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Product Information'**
  String get productBasicInfo;

  /// No description provided for @productImagePickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get productImagePickFailed;

  /// No description provided for @productImageUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully'**
  String get productImageUploadSuccess;

  /// No description provided for @productImageProcessFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image'**
  String get productImageProcessFailed;

  /// No description provided for @productDefaultImageUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update default image'**
  String get productDefaultImageUpdateFailed;

  /// No description provided for @productDefaultImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default image updated successfully'**
  String get productDefaultImageUpdated;

  /// No description provided for @productUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdateSuccess;

  /// No description provided for @productVariantPriceMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Variant price must be greater than zero'**
  String get productVariantPriceMustBePositive;

  /// No description provided for @variantWillBeRemovedOnSave.
  ///
  /// In en, this message translates to:
  /// **'This variant will be removed after saving'**
  String get variantWillBeRemovedOnSave;

  /// No description provided for @productUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading product...'**
  String get productUploading;

  /// No description provided for @productAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get productAddImage;

  /// No description provided for @productNoImagesYet.
  ///
  /// In en, this message translates to:
  /// **'No images yet'**
  String get productNoImagesYet;

  /// No description provided for @productImages.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get productImages;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @errorLoadingOrders.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get errorLoadingOrders;

  /// No description provided for @productUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update action'**
  String get productUpdateAction;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ShopHub'**
  String get appTitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// No description provided for @appLegalese.
  ///
  /// In en, this message translates to:
  /// **'© 2024 ShopHub. All rights reserved.'**
  String get appLegalese;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us.'**
  String get settingsPrivacyPolicyContent;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get settingsTerms;

  /// No description provided for @settingsTermsContent.
  ///
  /// In en, this message translates to:
  /// **'Please read our terms and conditions.'**
  String get settingsTermsContent;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelp;

  /// No description provided for @settingsHelpContent.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get settingsHelpContent;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get ordersTitle;

  /// No description provided for @productEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get productEditTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @insertProductMenu.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get insertProductMenu;

  /// No description provided for @productItemName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productItemName;

  /// No description provided for @productItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get productItemNameHint;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescriptionLabel;

  /// No description provided for @productDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter product description'**
  String get productDescriptionHint;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productCategory;

  /// No description provided for @productUsername.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get productUsername;

  /// No description provided for @productIsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get productIsActive;

  /// No description provided for @productInsertAction.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get productInsertAction;

  /// No description provided for @productRequiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get productRequiredField;

  /// No description provided for @productInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid value'**
  String get productInvalidValue;

  /// No description provided for @productSelectCategoryValidation.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get productSelectCategoryValidation;

  /// No description provided for @productAddImageValidation.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one image'**
  String get productAddImageValidation;

  /// No description provided for @productAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account information is not available'**
  String get productAccountUnavailable;

  /// No description provided for @productInsertSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get productInsertSuccess;

  /// No description provided for @productInsertFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add product'**
  String get productInsertFailed;

  /// No description provided for @productColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get productColor;

  /// No description provided for @productSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get productSize;

  /// No description provided for @productPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPriceLabel;

  /// No description provided for @productPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get productPriceHint;

  /// No description provided for @productQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get productQuantityLabel;

  /// No description provided for @productQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get productQuantityHint;

  /// No description provided for @otpVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpVerificationTitle;

  /// No description provided for @otpVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your email'**
  String get otpVerificationSubtitle;

  /// No description provided for @otpVerificationVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerificationVerify;

  /// No description provided for @otpResendQuestion.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpResendQuestion;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get otpResend;

  /// No description provided for @otpResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} seconds'**
  String otpResendCountdown(Object seconds);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get forgotPasswordSendOtp;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerFullNameLabel;

  /// No description provided for @registerFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get registerFullNameHint;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validationNameRequired;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get registerEmailHint;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validationEmailInvalid;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get homeSearchHint;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @errorLoadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Error loading products'**
  String get errorLoadingProducts;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noProductsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No products in this category'**
  String get noProductsInCategory;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validationPhoneInvalid;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get registerPasswordHint;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get registerConfirmPasswordHint;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationConfirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationConfirmPasswordMismatch;

  /// No description provided for @registerAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions'**
  String get registerAgreeTerms;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerCreateAccount;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHaveAccount;

  /// No description provided for @otpSentTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP Sent'**
  String get otpSentTitle;

  /// No description provided for @otpSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent an OTP to your email'**
  String get otpSentSubtitle;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginSubtitle;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignIn;

  /// No description provided for @loginContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get loginContinueAsGuest;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginCreateAccount;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordNewLabel;

  /// No description provided for @resetPasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get resetPasswordNewHint;

  /// No description provided for @resetPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get resetPasswordConfirmLabel;

  /// No description provided for @resetPasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get resetPasswordConfirmHint;

  /// No description provided for @resetPasswordUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get resetPasswordUpdateButton;

  /// No description provided for @resetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password. Please try again.'**
  String get resetPasswordFailed;

  /// No description provided for @passwordUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdateSuccess;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordCurrentHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get changePasswordCurrentHint;

  /// No description provided for @changePasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get changePasswordNewHint;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordCurrentRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get changePasswordCurrentRequired;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get settingsChangePasswordSubtitle;

  /// No description provided for @validationPasswordPolicy.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters and include 1 uppercase letter, 1 number, and 1 special character'**
  String get validationPasswordPolicy;

  /// No description provided for @passwordUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Updated'**
  String get passwordUpdatedTitle;

  /// No description provided for @passwordUpdatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully updated'**
  String get passwordUpdatedSubtitle;

  /// No description provided for @passwordUpdatedBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get passwordUpdatedBackToLogin;

  /// No description provided for @passwordUpdatedAutoRedirect.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to login in {seconds} seconds'**
  String passwordUpdatedAutoRedirect(Object seconds);

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpTitle;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP code'**
  String get otpEnterCode;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your email'**
  String get otpSubtitle;

  /// No description provided for @validationOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'OTP is required'**
  String get validationOtpRequired;

  /// No description provided for @validationOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid OTP'**
  String get validationOtpInvalid;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} seconds'**
  String otpResendIn(Object seconds);

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @validationOtpInvalidLength.
  ///
  /// In en, this message translates to:
  /// **'OTP must be 6 digits'**
  String get validationOtpInvalidLength;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ShopHub'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your favorite shopping destination'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast Delivery'**
  String get onboardingDeliveryTitle;

  /// No description provided for @onboardingDeliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get your orders delivered quickly'**
  String get onboardingDeliverySubtitle;

  /// No description provided for @onboardingSecureTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Shopping'**
  String get onboardingSecureTitle;

  /// No description provided for @onboardingSecureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your transactions are protected'**
  String get onboardingSecureSubtitle;

  /// No description provided for @onboardingDealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Deals'**
  String get onboardingDealsTitle;

  /// No description provided for @onboardingDealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get amazing discounts on your favorite products'**
  String get onboardingDealsSubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountShoppingSection.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get accountShoppingSection;

  /// No description provided for @accountMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get accountMyOrders;

  /// No description provided for @accountMyOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your orders'**
  String get accountMyOrdersSubtitle;

  /// No description provided for @accountWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get accountWishlist;

  /// No description provided for @accountWishlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved items'**
  String get accountWishlistSubtitle;

  /// No description provided for @accountReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get accountReviews;

  /// No description provided for @accountReviewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rate products'**
  String get accountReviewsSubtitle;

  /// No description provided for @accountReviewsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get accountReviewsComingSoon;

  /// No description provided for @accountSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get accountSettingsSection;

  /// No description provided for @accountDeliveryAddresses.
  ///
  /// In en, this message translates to:
  /// **'Delivery Addresses'**
  String get accountDeliveryAddresses;

  /// No description provided for @accountDeliveryAddressesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage addresses'**
  String get accountDeliveryAddressesSubtitle;

  /// No description provided for @accountPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get accountPaymentMethods;

  /// No description provided for @accountPaymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add payment methods'**
  String get accountPaymentMethodsSubtitle;

  /// No description provided for @accountPaymentMethodsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get accountPaymentMethodsComingSoon;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get accountSettings;

  /// No description provided for @accountSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettingsSubtitle;

  /// No description provided for @accountSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get accountSupportSection;

  /// No description provided for @accountHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get accountHelp;

  /// No description provided for @accountHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get accountHelpSubtitle;

  /// No description provided for @accountAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get accountAbout;

  /// No description provided for @accountAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'About ShopHub'**
  String get accountAboutSubtitle;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @accountUserName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountUserName;

  /// No description provided for @accountUserEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountUserEmail;

  /// No description provided for @accountUserPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get accountUserPhone;

  /// No description provided for @settingsLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogoutConfirmTitle;

  /// No description provided for @accountLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get accountLogoutConfirmMessage;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get commonLogout;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplay;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguageRegion.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get settingsLanguageRegion;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsEmailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get settingsEmailNotifications;

  /// No description provided for @settingsEmailNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive email updates'**
  String get settingsEmailNotificationsSubtitle;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get settingsPushNotificationsSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get settingsAboutApp;

  /// No description provided for @settingsLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get settingsLogoutConfirmMessage;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccountConfirmTitle;

  /// No description provided for @settingsDeleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This action cannot be undone.'**
  String get settingsDeleteAccountConfirmMessage;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @settingsAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get settingsAccountDeleted;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @searchFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Search & Filter'**
  String get searchFilterTitle;

  /// No description provided for @searchFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchFilterHint;

  /// No description provided for @searchFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get searchFilterCategory;

  /// No description provided for @searchFilterPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get searchFilterPrice;

  /// No description provided for @searchFilterRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get searchFilterRating;

  /// No description provided for @searchFilterSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get searchFilterSort;

  /// No description provided for @searchFilterNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchFilterNoResults;

  /// No description provided for @searchFilterSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get searchFilterSelectCategory;

  /// No description provided for @searchFilterPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get searchFilterPriceRange;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @searchFilterMinimumRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get searchFilterMinimumRating;

  /// No description provided for @searchFilterAnyRating.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get searchFilterAnyRating;

  /// No description provided for @searchFilterSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get searchFilterSortBy;

  /// No description provided for @categorySneakers.
  ///
  /// In en, this message translates to:
  /// **'Sneakers'**
  String get categorySneakers;

  /// No description provided for @categoryJackets.
  ///
  /// In en, this message translates to:
  /// **'Jackets'**
  String get categoryJackets;

  /// No description provided for @categoryWatches.
  ///
  /// In en, this message translates to:
  /// **'Watches'**
  String get categoryWatches;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get categoryClothing;

  /// No description provided for @searchFilterSortBestSelling.
  ///
  /// In en, this message translates to:
  /// **'Best Selling'**
  String get searchFilterSortBestSelling;

  /// No description provided for @searchFilterSortPriceLowHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get searchFilterSortPriceLowHigh;

  /// No description provided for @searchFilterSortPriceHighLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get searchFilterSortPriceHighLow;

  /// No description provided for @searchFilterSortBestRating.
  ///
  /// In en, this message translates to:
  /// **'Best Rating'**
  String get searchFilterSortBestRating;

  /// No description provided for @searchFilterSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get searchFilterSortNewest;

  /// No description provided for @addressesSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully'**
  String get addressesSaved;

  /// No description provided for @addressesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted successfully'**
  String get addressesDeleted;

  /// No description provided for @addressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addressesTitle;

  /// No description provided for @savedAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get savedAddressesTitle;

  /// No description provided for @searchSavedAddressesHint.
  ///
  /// In en, this message translates to:
  /// **'Search saved addresses'**
  String get searchSavedAddressesHint;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @noSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet'**
  String get noSavedAddresses;

  /// No description provided for @addressesLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to manage addresses'**
  String get addressesLoginRequired;

  /// No description provided for @addressesSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Address settings'**
  String get addressesSettingsLabel;

  /// No description provided for @addressesAdded.
  ///
  /// In en, this message translates to:
  /// **'Address added successfully'**
  String get addressesAdded;

  /// No description provided for @addressesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete address'**
  String get addressesDeleteTitle;

  /// No description provided for @addressesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{label}\"?'**
  String addressesDeleteMessage(String label);

  /// No description provided for @addressesFallbackCountry.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get addressesFallbackCountry;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @changeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get changeLocation;

  /// No description provided for @orEnterManually.
  ///
  /// In en, this message translates to:
  /// **'OR ENTER MANUALLY'**
  String get orEnterManually;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingLabel;

  /// No description provided for @addressesDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get addressesDefault;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @addressesSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get addressesSetDefault;

  /// No description provided for @addressesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get addressesEditTitle;

  /// No description provided for @addressesAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addressesAddTitle;

  /// No description provided for @addressesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addressesNameLabel;

  /// No description provided for @addressesStreetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get addressesStreetLabel;

  /// No description provided for @addressesCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get addressesCityLabel;

  /// No description provided for @addressesStateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get addressesStateLabel;

  /// No description provided for @addressesCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get addressesCountryLabel;

  /// No description provided for @addressesZipLabel.
  ///
  /// In en, this message translates to:
  /// **'ZIP Code'**
  String get addressesZipLabel;

  /// No description provided for @addressesPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get addressesPhoneLabel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @checkoutPaymentCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get checkoutPaymentCard;

  /// No description provided for @checkoutPaymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get checkoutPaymentCash;

  /// No description provided for @checkoutPaymentWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get checkoutPaymentWallet;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get checkoutOrderSummary;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyMessage;

  /// No description provided for @checkoutDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get checkoutDeliveryAddress;

  /// No description provided for @checkoutPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get checkoutPaymentMethod;

  /// No description provided for @checkoutTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get checkoutTotal;

  /// No description provided for @checkoutQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity}'**
  String checkoutQuantity(Object quantity);

  /// No description provided for @accountMyProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get accountMyProducts;

  /// No description provided for @myProductsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get myProductsEmptyMessage;

  /// No description provided for @stockIn.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get stockIn;

  /// No description provided for @stockOut.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get stockOut;

  /// No description provided for @productBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get productBrand;

  /// No description provided for @productBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Enter brand'**
  String get productBrandHint;

  /// No description provided for @productSizeGroup.
  ///
  /// In en, this message translates to:
  /// **'Size Group'**
  String get productSizeGroup;

  /// No description provided for @productSizeGroupOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get productSizeGroupOptional;

  /// No description provided for @productSelectGroupFirst.
  ///
  /// In en, this message translates to:
  /// **'Select group first'**
  String get productSelectGroupFirst;

  /// No description provided for @productSelectGroupOptional.
  ///
  /// In en, this message translates to:
  /// **'Select group (optional)'**
  String get productSelectGroupOptional;

  /// No description provided for @productSelectSizeOptional.
  ///
  /// In en, this message translates to:
  /// **'Select size (optional)'**
  String get productSelectSizeOptional;

  /// No description provided for @productDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount (%)'**
  String get productDiscountLabel;

  /// No description provided for @productDiscountHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, defaults to 0'**
  String get productDiscountHint;

  /// No description provided for @productDiscountInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Discount must be between 0 and 100'**
  String get productDiscountInvalidRange;

  /// No description provided for @productVariantRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one valid product variant.'**
  String get productVariantRequired;

  /// No description provided for @colorPickerHexHint.
  ///
  /// In en, this message translates to:
  /// **'RRGGBB'**
  String get colorPickerHexHint;

  /// No description provided for @colorPickerInvalidHex.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit hex color'**
  String get colorPickerInvalidHex;

  /// No description provided for @itemReviewYourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get itemReviewYourReview;

  /// No description provided for @itemReviewSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get itemReviewSubmitButton;

  /// No description provided for @itemReviewCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get itemReviewCommentLabel;

  /// No description provided for @itemReviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this item'**
  String get itemReviewCommentHint;

  /// No description provided for @itemReviewAlreadyRated.
  ///
  /// In en, this message translates to:
  /// **'You have already rated this item.'**
  String get itemReviewAlreadyRated;

  /// No description provided for @itemReviewRatingRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating between 1 and 5.'**
  String get itemReviewRatingRequired;

  /// No description provided for @itemReviewCommentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a comment.'**
  String get itemReviewCommentRequired;

  /// No description provided for @itemReviewSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully.'**
  String get itemReviewSubmittedSuccess;

  /// No description provided for @itemReviewLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to review this item.'**
  String get itemReviewLoginRequired;

  /// No description provided for @itemReviewLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reviews right now.'**
  String get itemReviewLoadFailed;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed'**
  String get orderSuccessTitle;

  /// No description provided for @orderSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your order'**
  String get orderSuccessSubtitle;

  /// No description provided for @orderSuccessOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderSuccessOrderId;

  /// No description provided for @orderSuccessTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get orderSuccessTotalAmount;

  /// No description provided for @orderSuccessThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for shopping with us'**
  String get orderSuccessThanks;

  /// No description provided for @orderSuccessContinueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get orderSuccessContinueShopping;

  /// No description provided for @orderSuccessViewOrders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get orderSuccessViewOrders;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'ShopHub'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your shopping destination'**
  String get splashSubtitle;

  /// No description provided for @profileOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profileOrders;

  /// No description provided for @profileAddresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get profileAddresses;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get profileHelp;

  /// No description provided for @profileHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get profileHelpMessage;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @cartQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get cartQuantity;

  /// No description provided for @productAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get productAddToCart;

  /// No description provided for @cartRemoveItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get cartRemoveItemTitle;

  /// No description provided for @cartRemoveItemMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this item?'**
  String get cartRemoveItemMessage;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @cartItemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get cartItemRemoved;

  /// No description provided for @cartAvailableStock.
  ///
  /// In en, this message translates to:
  /// **'Available: {stock}'**
  String cartAvailableStock(Object stock);

  /// No description provided for @cartItemTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartItemTotal;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartStartShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get cartStartShopping;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get cartTitle;

  /// No description provided for @cartShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get cartShipping;

  /// No description provided for @cartShippingFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get cartShippingFree;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get cartCheckout;

  /// No description provided for @productReviews.
  ///
  /// In en, this message translates to:
  /// **'{count} Reviews'**
  String productReviews(Object count);

  /// No description provided for @productSold.
  ///
  /// In en, this message translates to:
  /// **'{count} Sold'**
  String productSold(Object count);

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription;

  /// No description provided for @productShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get productShowLess;

  /// No description provided for @productShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get productShowMore;

  /// No description provided for @productAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{name} added to cart'**
  String productAddedToCart(Object name);

  /// No description provided for @addToCartLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to add items to your cart'**
  String get addToCartLoginRequired;

  /// No description provided for @addToCartVariantError.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine product variant'**
  String get addToCartVariantError;

  /// No description provided for @addToCartSuccess.
  ///
  /// In en, this message translates to:
  /// **'{productName} added to cart'**
  String addToCartSuccess(Object productName);

  /// No description provided for @addToCartFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart. Please try again.'**
  String get addToCartFailure;

  /// No description provided for @variantDefaultSize.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get variantDefaultSize;

  /// No description provided for @variantDefaultColor.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get variantDefaultColor;

  /// No description provided for @orderPromoApplied.
  ///
  /// In en, this message translates to:
  /// **'Promo applied: {code}'**
  String orderPromoApplied(Object code);

  /// No description provided for @orderSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get orderSubtotal;

  /// No description provided for @orderTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get orderTax;

  /// No description provided for @orderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get orderDiscount;

  /// No description provided for @orderPromoDiscount.
  ///
  /// In en, this message translates to:
  /// **'Promo discount'**
  String get orderPromoDiscount;

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderTotal;

  /// No description provided for @orderSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummaryTitle;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @myCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Cards'**
  String get myCardsTitle;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @saveCard.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveCard;

  /// No description provided for @cardholderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderNameLabel;

  /// No description provided for @cardNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumberLabel;

  /// No description provided for @expiryMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get expiryMonthLabel;

  /// No description provided for @expiryYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get expiryYearLabel;

  /// No description provided for @cardTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Type'**
  String get cardTypeLabel;

  /// No description provided for @setAsDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Set as default card'**
  String get setAsDefaultLabel;

  /// No description provided for @deleteCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCardTitle;

  /// No description provided for @deleteCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this card?'**
  String get deleteCardConfirm;

  /// No description provided for @deleteCardCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteCardCancel;

  /// No description provided for @deleteCardConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteCardConfirmButton;

  /// No description provided for @cardExpiredBadge.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get cardExpiredBadge;

  /// No description provided for @cardDefaultBadge.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get cardDefaultBadge;

  /// No description provided for @noCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'No cards saved'**
  String get noCardsTitle;

  /// No description provided for @noCardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a card to pay faster at checkout'**
  String get noCardsSubtitle;

  /// No description provided for @cardAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get cardAddedSuccess;

  /// No description provided for @cardDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card removed'**
  String get cardDeletedSuccess;

  /// No description provided for @cardActionSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get cardActionSetDefault;

  /// No description provided for @cardActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cardActionDelete;

  /// No description provided for @selectCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Card'**
  String get selectCardTitle;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add new card'**
  String get addNewCard;

  /// No description provided for @orderItemsSection.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orderItemsSection;

  /// No description provided for @deliveryAddressSection.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddressSection;

  /// No description provided for @amountBreakdownSection.
  ///
  /// In en, this message translates to:
  /// **'Amount breakdown'**
  String get amountBreakdownSection;

  /// No description provided for @selectedPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected payment: {method}'**
  String selectedPaymentLabel(Object method);

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @promoCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Promo Code (Optional)'**
  String get promoCodeOptional;

  /// No description provided for @promoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'ENTER CODE'**
  String get promoCodeHint;

  /// No description provided for @promoApplied.
  ///
  /// In en, this message translates to:
  /// **'Promo applied'**
  String get promoApplied;

  /// No description provided for @invalidPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code'**
  String get invalidPromoCode;

  /// No description provided for @checkoutLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue with checkout.'**
  String get checkoutLoginRequired;

  /// No description provided for @checkoutLoginRequiredShort.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue.'**
  String get checkoutLoginRequiredShort;

  /// No description provided for @checkoutSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery address.'**
  String get checkoutSelectAddress;

  /// No description provided for @checkoutSelectPayment.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method.'**
  String get checkoutSelectPayment;

  /// No description provided for @checkoutSelectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Select delivery address'**
  String get checkoutSelectDeliveryAddress;

  /// No description provided for @checkoutCartEmptyWarning.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get checkoutCartEmptyWarning;

  /// No description provided for @cardNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 16-digit card number'**
  String get cardNumberInvalid;

  /// No description provided for @cardExpiryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Select a future expiry date'**
  String get cardExpiryInvalid;

  /// No description provided for @orderIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderIdLabel;

  /// No description provided for @orderDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDateLabel;

  /// No description provided for @orderCreatedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get orderCreatedDateLabel;

  /// No description provided for @orderItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Items ({count})'**
  String orderItemsCount(Object count);

  /// No description provided for @unknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown Product'**
  String get unknownProduct;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sizeLabel;

  /// No description provided for @quantityShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantityShortLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @orderDetailsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load order details'**
  String get orderDetailsLoadError;

  /// No description provided for @orderItemsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No order items found'**
  String get orderItemsEmptyTitle;

  /// No description provided for @orderItemsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'There are no line items available for this order yet.'**
  String get orderItemsEmptySubtitle;

  /// No description provided for @changeEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmailTitle;

  /// No description provided for @changeEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your email address'**
  String get changeEmailSubtitle;

  /// No description provided for @stockOnlyLeft.
  ///
  /// In en, this message translates to:
  /// **'Only {stock} left'**
  String stockOnlyLeft(Object stock);

  /// No description provided for @orderMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+{count} more items'**
  String orderMoreItems(Object count);

  /// No description provided for @notificationCartAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart'**
  String get notificationCartAddSuccess;

  /// No description provided for @notificationCartRemoveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get notificationCartRemoveSuccess;

  /// No description provided for @notificationCartRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove item from cart'**
  String get notificationCartRemoveError;

  /// No description provided for @notificationCartUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cart updated'**
  String get notificationCartUpdateSuccess;

  /// No description provided for @notificationCartUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update cart'**
  String get notificationCartUpdateError;

  /// No description provided for @notificationCartLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cart. Please try again.'**
  String get notificationCartLoadError;

  /// No description provided for @notificationTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again'**
  String get notificationTimeoutError;

  /// No description provided for @notificationOperationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get notificationOperationSuccess;

  /// No description provided for @notificationAddressSelected.
  ///
  /// In en, this message translates to:
  /// **'Address selected successfully'**
  String get notificationAddressSelected;

  /// No description provided for @notificationAddressUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address updated successfully'**
  String get notificationAddressUpdateSuccess;

  /// No description provided for @notificationAddressUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update address'**
  String get notificationAddressUpdateError;

  /// No description provided for @notificationAddressDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address deleted successfully'**
  String get notificationAddressDeleteSuccess;

  /// No description provided for @notificationAddressDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete address'**
  String get notificationAddressDeleteError;

  /// No description provided for @notificationCodeApplySuccess.
  ///
  /// In en, this message translates to:
  /// **'Promo code applied successfully'**
  String get notificationCodeApplySuccess;

  /// No description provided for @notificationCodeApplyError.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired promo code'**
  String get notificationCodeApplyError;

  /// No description provided for @notificationCheckoutError.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed. Please try again'**
  String get notificationCheckoutError;

  /// No description provided for @notificationOrderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully'**
  String get notificationOrderPlacedSuccess;

  /// No description provided for @notificationOrderPlacedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to place order'**
  String get notificationOrderPlacedError;

  /// No description provided for @notificationImageUploadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image. Please try again'**
  String get notificationImageUploadError;

  /// No description provided for @notificationProductSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product saved successfully'**
  String get notificationProductSaveSuccess;

  /// No description provided for @notificationProductSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save product'**
  String get notificationProductSaveError;

  /// No description provided for @notificationProductDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get notificationProductDeleteSuccess;

  /// No description provided for @notificationProductDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get notificationProductDeleteError;

  /// No description provided for @notificationProfileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get notificationProfileUpdateError;

  /// No description provided for @notificationPasswordChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get notificationPasswordChangeSuccess;

  /// No description provided for @notificationPasswordChangeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get notificationPasswordChangeError;

  /// No description provided for @notificationEmailChangeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to change email'**
  String get notificationEmailChangeError;

  /// No description provided for @notificationWishlistAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get notificationWishlistAddSuccess;

  /// No description provided for @notificationWishlistAddError.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to wishlist'**
  String get notificationWishlistAddError;

  /// No description provided for @notificationWishlistRemoveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get notificationWishlistRemoveSuccess;

  /// No description provided for @notificationWishlistRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove from wishlist'**
  String get notificationWishlistRemoveError;

  /// No description provided for @notificationReviewSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get notificationReviewSubmitSuccess;

  /// No description provided for @notificationReviewSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review'**
  String get notificationReviewSubmitError;

  /// No description provided for @notificationPaymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get notificationPaymentProcessing;

  /// No description provided for @notificationPaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get notificationPaymentSuccess;

  /// No description provided for @notificationPaymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again'**
  String get notificationPaymentError;

  /// No description provided for @notificationCopyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get notificationCopyToClipboard;

  /// No description provided for @notificationNoAction.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get notificationNoAction;

  /// No description provided for @notificationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get notificationFieldRequired;

  /// No description provided for @notificationInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get notificationInvalidInput;

  /// No description provided for @notificationLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'Link expired. Please try again'**
  String get notificationLinkExpired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
