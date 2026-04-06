import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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

  /// No description provided for @resetPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get resetPasswordConfirmLabel;

  /// No description provided for @resetPasswordUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get resetPasswordUpdateButton;

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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
