// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get country => 'الدولة';

  @override
  String get jordan => 'الأردن';

  @override
  String get gender => 'الجنس';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get notificationLoginRequired => 'يرجى تسجيل الدخول للمتابعة';

  @override
  String get notificationServerError => 'خطأ في الخادم. يرجى المحاولة لاحقاً';

  @override
  String get notificationNetworkError =>
      'خطأ في الشبكة. يرجى التحقق من الاتصال';

  @override
  String get notificationProfileUpdateSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get notificationImageProcessError => 'فشل في معالجة الصورة';

  @override
  String get notificationUnknownError => 'حدث خطأ غير متوقع';

  @override
  String get notificationEmailChangeSuccess =>
      'تم تغيير البريد الإلكتروني بنجاح';

  @override
  String get notificationCartAddError => 'فشل في إضافة العنصر إلى السلة';

  @override
  String notificationProductAddedToCart(String productName) {
    return 'تمت إضافة $productName إلى السلة';
  }

  @override
  String get tax => 'الضريبة';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get promoDiscount => 'خصم الكوبون';

  @override
  String get wishlistLoginRequired => 'يرجى تسجيل الدخول لإدارة قائمة الأمنيات';

  @override
  String get wishlistEmptyTitle => 'لا توجد عناصر محفوظة';

  @override
  String get wishlistEmptySubtitle => 'اضغط على رمز القلب في المنتج لحفظه هنا';

  @override
  String get productVariants => 'خيارات المنتج';

  @override
  String get productAddVariant => 'إضافة خيار';

  @override
  String get productNoVariantsYet => 'لا توجد خيارات بعد';

  @override
  String get productBasicInfo => 'معلومات المنتج الأساسية';

  @override
  String get productImagePickFailed => 'فشل في اختيار الصورة';

  @override
  String get productImageUploadSuccess => 'تم رفع الصورة بنجاح';

  @override
  String get productImageProcessFailed => 'فشل في معالجة الصورة';

  @override
  String get productDefaultImageUpdateFailed =>
      'فشل في تحديث الصورة الافتراضية';

  @override
  String get productDefaultImageUpdated => 'تم تحديث الصورة الافتراضية بنجاح';

  @override
  String get productUpdateSuccess => 'تم تحديث المنتج بنجاح';

  @override
  String get productVariantPriceMustBePositive =>
      'يجب أن يكون سعر الخيار أكبر من صفر';

  @override
  String get variantWillBeRemovedOnSave => 'سيتم حذف هذا الخيار بعد الحفظ';

  @override
  String get productUploading => 'جارٍ رفع المنتج...';

  @override
  String get productAddImage => 'إضافة صورة';

  @override
  String get productNoImagesYet => 'لا توجد صور بعد';

  @override
  String get productImages => 'صور المنتج';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get noOrdersYet => 'لا توجد طلبات بعد';

  @override
  String get errorLoadingOrders => 'خطأ في تحميل الطلبات';

  @override
  String get productUpdateAction => 'إجراء التحديث';

  @override
  String get appTitle => 'ShopHub';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appLegalese => '© 2024 ShopHub. جميع الحقوق محفوظة.';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsPrivacyPolicyContent => 'خصوصيتك تهمنا.';

  @override
  String get settingsTerms => 'الشروط والأحكام';

  @override
  String get settingsTermsContent => 'يرجى قراءة الشروط والأحكام الخاصة بنا.';

  @override
  String get settingsHelp => 'المساعدة';

  @override
  String get settingsHelpContent => 'كيف يمكننا مساعدتك؟';

  @override
  String get ordersTitle => 'طلباتي';

  @override
  String get productEditTitle => 'تعديل المنتج';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get insertProductMenu => 'إضافة منتج';

  @override
  String get productItemName => 'اسم المنتج';

  @override
  String get productItemNameHint => 'أدخل اسم المنتج';

  @override
  String get productDescriptionLabel => 'الوصف';

  @override
  String get productDescriptionHint => 'أدخل وصف المنتج';

  @override
  String get productCategory => 'الفئة';

  @override
  String get productUsername => 'البائع';

  @override
  String get productIsActive => 'نشط';

  @override
  String get productInsertAction => 'إضافة منتج';

  @override
  String get productRequiredField => 'هذا الحقل مطلوب';

  @override
  String get productInvalidValue => 'يرجى إدخال قيمة صالحة';

  @override
  String get productSelectCategoryValidation => 'يرجى اختيار فئة';

  @override
  String get productAddImageValidation => 'يرجى إضافة صورة واحدة على الأقل';

  @override
  String get productAccountUnavailable => 'معلومات الحساب غير متوفرة';

  @override
  String get productInsertSuccess => 'تم إضافة المنتج بنجاح';

  @override
  String get productInsertFailed => 'فشل في إضافة المنتج';

  @override
  String get productColor => 'اللون';

  @override
  String get productSize => 'المقاس';

  @override
  String get productPriceLabel => 'السعر';

  @override
  String get productPriceHint => 'أدخل السعر';

  @override
  String get productQuantityLabel => 'الكمية';

  @override
  String get productQuantityHint => 'أدخل الكمية';

  @override
  String get otpVerificationTitle => 'التحقق من رمز OTP';

  @override
  String get otpVerificationSubtitle =>
      'أدخل الرمز المرسل إلى بريدك الإلكتروني';

  @override
  String get otpVerificationVerify => 'تحقق';

  @override
  String get otpResendQuestion => 'لم تستلم الرمز؟';

  @override
  String get otpResend => 'إعادة إرسال';

  @override
  String otpResendCountdown(Object seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSendOtp => 'إرسال الرمز';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerFullNameLabel => 'الاسم الكامل';

  @override
  String get registerFullNameHint => 'أدخل اسمك الكامل';

  @override
  String get validationNameRequired => 'الاسم مطلوب';

  @override
  String get registerEmailLabel => 'البريد الإلكتروني';

  @override
  String get registerEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get validationEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get validationEmailInvalid => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get homeSearchHint => 'البحث عن منتجات';

  @override
  String get categoryAll => 'الكل';

  @override
  String get errorLoadingProducts => 'خطأ في تحميل المنتجات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noProductsInCategory => 'لا توجد منتجات في هذه الفئة';

  @override
  String get validationPhoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get validationPhoneInvalid => 'يرجى إدخال رقم هاتف صحيح';

  @override
  String get registerPasswordLabel => 'كلمة المرور';

  @override
  String get registerPasswordHint => 'أدخل كلمة المرور';

  @override
  String get validationPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get validationPasswordTooShort =>
      'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get registerConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get registerConfirmPasswordHint => 'أكد كلمة المرور';

  @override
  String get validationConfirmPasswordRequired => 'تأكيد كلمة المرور مطلوب';

  @override
  String get validationConfirmPasswordMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get registerAgreeTerms => 'أوافق على الشروط والأحكام';

  @override
  String get registerCreateAccount => 'إنشاء حساب';

  @override
  String get registerHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get otpSentTitle => 'تم إرسال الرمز';

  @override
  String get otpSentSubtitle => 'لقد أرسلنا رمز التحقق إلى بريدك الإلكتروني';

  @override
  String get commonContinue => 'استمرار';

  @override
  String get loginSubtitle => 'تسجيل الدخول إلى حسابك';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginPasswordHint => 'أدخل كلمة المرور';

  @override
  String get loginForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginSignIn => 'تسجيل الدخول';

  @override
  String get loginContinueAsGuest => 'المتابعة كضيف';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟';

  @override
  String get loginCreateAccount => 'إنشاء حساب';

  @override
  String get resetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordSubtitle => 'أدخل كلمة المرور الجديدة';

  @override
  String get resetPasswordNewLabel => 'كلمة المرور الجديدة';

  @override
  String get resetPasswordNewHint => 'أدخل كلمة المرور الجديدة';

  @override
  String get resetPasswordConfirmLabel => 'تأكيد كلمة المرور';

  @override
  String get resetPasswordConfirmHint => 'أكد كلمة المرور الجديدة';

  @override
  String get resetPasswordUpdateButton => 'تحديث كلمة المرور';

  @override
  String get resetPasswordFailed =>
      'فشل إعادة تعيين كلمة المرور. حاول مرة أخرى.';

  @override
  String get passwordUpdateSuccess => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get changePasswordCurrentLabel => 'كلمة المرور الحالية';

  @override
  String get changePasswordCurrentHint => 'أدخل كلمة المرور الحالية';

  @override
  String get changePasswordNewHint => 'أدخل كلمة المرور الجديدة';

  @override
  String get changePasswordConfirmLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get changePasswordConfirmHint => 'أكد كلمة المرور الجديدة';

  @override
  String get changePasswordCurrentRequired => 'كلمة المرور الحالية مطلوبة';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsChangePasswordSubtitle => 'تحديث كلمة مرور حسابك';

  @override
  String get validationPasswordPolicy =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل وتشمل حرفًا كبيرًا ورقمًا ورمزًا خاصًا';

  @override
  String get passwordUpdatedTitle => 'تم تحديث كلمة المرور';

  @override
  String get passwordUpdatedSubtitle => 'تم تحديث كلمة المرور الخاصة بك بنجاح';

  @override
  String get passwordUpdatedBackToLogin => 'العودة لتسجيل الدخول';

  @override
  String passwordUpdatedAutoRedirect(Object seconds) {
    return 'سيتم توجيهك لتسجيل الدخول خلال $seconds ثانية';
  }

  @override
  String get otpTitle => 'التحقق من الرمز';

  @override
  String get otpEnterCode => 'أدخل رمز التحقق';

  @override
  String get otpSubtitle => 'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك';

  @override
  String get validationOtpRequired => 'الرمز مطلوب';

  @override
  String get validationOtpInvalid => 'يرجى إدخال رمز صحيح';

  @override
  String otpResendIn(Object seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get otpVerify => 'تحقق';

  @override
  String get validationOtpInvalidLength => 'يجب أن يتكون الرمز من 6 أرقام';

  @override
  String get onboardingWelcomeTitle => 'مرحباً بك في ShopHub';

  @override
  String get onboardingWelcomeSubtitle => 'وجهتك المفضلة للتسوق';

  @override
  String get onboardingDeliveryTitle => 'توصيل سريع';

  @override
  String get onboardingDeliverySubtitle => 'احصل على طلباتك بسرعة';

  @override
  String get onboardingSecureTitle => 'تسوق آمن';

  @override
  String get onboardingSecureSubtitle => 'معاملاتك محمية';

  @override
  String get onboardingDealsTitle => 'عروض حصرية';

  @override
  String get onboardingDealsSubtitle =>
      'احصل على خصومات رائعة على منتجاتك المفضلة';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get accountShoppingSection => 'التسوق';

  @override
  String get accountMyOrders => 'طلباتي';

  @override
  String get accountMyOrdersSubtitle => 'عرض طلباتك';

  @override
  String get accountWishlist => 'قائمة الأمنيات';

  @override
  String get accountWishlistSubtitle => 'العناصر المحفوظة';

  @override
  String get accountReviews => 'تقييماتي';

  @override
  String get accountReviewsSubtitle => 'تقييم المنتجات';

  @override
  String get accountReviewsComingSoon => 'قريباً';

  @override
  String get accountSettingsSection => 'الإعدادات';

  @override
  String get accountDeliveryAddresses => 'عناوين التوصيل';

  @override
  String get accountDeliveryAddressesSubtitle => 'إدارة العناوين';

  @override
  String get accountPaymentMethods => 'طرق الدفع';

  @override
  String get accountPaymentMethodsSubtitle => 'إضافة طرق دفع';

  @override
  String get accountPaymentMethodsComingSoon => 'قريباً';

  @override
  String get accountSettings => 'الإعدادات';

  @override
  String get accountSettingsSubtitle => 'إعدادات الحساب';

  @override
  String get accountSupportSection => 'الدعم';

  @override
  String get accountHelp => 'المساعدة';

  @override
  String get accountHelpSubtitle => 'احصل على المساعدة';

  @override
  String get accountAbout => 'حول';

  @override
  String get accountAboutSubtitle => 'حول ShopHub';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get accountUserName => 'الاسم';

  @override
  String get accountUserEmail => 'البريد الإلكتروني';

  @override
  String get accountUserPhone => 'الهاتف';

  @override
  String get settingsLogoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get accountLogoutConfirmMessage =>
      'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get commonLogout => 'خروج';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsDisplay => 'العرض';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsLanguageRegion => 'اللغة والمنطقة';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get settingsEmailNotifications => 'إشعارات البريد';

  @override
  String get settingsEmailNotificationsSubtitle => 'تلقي تحديثات البريد';

  @override
  String get settingsPushNotifications => 'إشعارات التطبيق';

  @override
  String get settingsPushNotificationsSubtitle => 'تلقي إشعارات التنبيه';

  @override
  String get settingsAbout => 'حول';

  @override
  String get settingsAboutApp => 'حول التطبيق';

  @override
  String get settingsLogoutConfirmMessage => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get settingsDeleteAccount => 'حذف الحساب';

  @override
  String get settingsDeleteAccountConfirmTitle => 'حذف الحساب';

  @override
  String get settingsDeleteAccountConfirmMessage =>
      'هل أنت متأكد؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonSelect => 'اختيار';

  @override
  String get settingsAccountDeleted => 'تم حذف الحساب بنجاح';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get searchFilterTitle => 'البحث والتصفية';

  @override
  String get searchFilterHint => 'البحث عن منتجات';

  @override
  String get searchFilterCategory => 'الفئة';

  @override
  String get searchFilterPrice => 'السعر';

  @override
  String get searchFilterRating => 'التقييم';

  @override
  String get searchFilterSort => 'فرز';

  @override
  String get searchFilterNoResults => 'لم يتم العثور على نتائج';

  @override
  String get searchFilterSelectCategory => 'اختر الفئة';

  @override
  String get searchFilterPriceRange => 'نطاق السعر';

  @override
  String get commonApply => 'تطبيق';

  @override
  String get searchFilterMinimumRating => 'الحد الأدنى للتقييم';

  @override
  String get searchFilterAnyRating => 'أي تقييم';

  @override
  String get searchFilterSortBy => 'فرز حسب';

  @override
  String get categorySneakers => 'أحذية رياضية';

  @override
  String get categoryJackets => 'جاكيتات';

  @override
  String get categoryWatches => 'ساعات';

  @override
  String get categoryElectronics => 'إلكترونيات';

  @override
  String get categoryClothing => 'ملابس';

  @override
  String get searchFilterSortBestSelling => 'الأكثر مبيعاً';

  @override
  String get searchFilterSortPriceLowHigh => 'السعر: من الأقل للأعلى';

  @override
  String get searchFilterSortPriceHighLow => 'السعر: من الأعلى للأقل';

  @override
  String get searchFilterSortBestRating => 'أفضل تقييم';

  @override
  String get searchFilterSortNewest => 'الأحدث';

  @override
  String get addressesSaved => 'تم حفظ العنوان بنجاح';

  @override
  String get addressesDeleted => 'تم حذف العنوان بنجاح';

  @override
  String get addressesTitle => 'العناوين';

  @override
  String get addressesDefault => 'افتراضي';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get addressesSetDefault => 'تعيين كافتراضي';

  @override
  String get addressesEditTitle => 'تعديل العنوان';

  @override
  String get addressesAddTitle => 'إضافة عنوان جديد';

  @override
  String get addressesNameLabel => 'الاسم';

  @override
  String get addressesStreetLabel => 'عنوان الشارع';

  @override
  String get addressesCityLabel => 'المدينة';

  @override
  String get addressesStateLabel => 'الولاية/المحافظة';

  @override
  String get addressesCountryLabel => 'البلد';

  @override
  String get addressesZipLabel => 'الرمز البريدي';

  @override
  String get addressesPhoneLabel => 'الهاتف';

  @override
  String get commonSave => 'حفظ';

  @override
  String get checkoutPaymentCard => 'بطاقة ائتمان';

  @override
  String get checkoutPaymentCash => 'الدفع عند الاستلام';

  @override
  String get checkoutPaymentWallet => 'المحفظة';

  @override
  String get checkoutTitle => 'الدفع';

  @override
  String get checkoutOrderSummary => 'ملخص الطلب';

  @override
  String get cartEmptyMessage => 'سلة التسوق فارغة';

  @override
  String get checkoutDeliveryAddress => 'عنوان التوصيل';

  @override
  String get checkoutPaymentMethod => 'طريقة الدفع';

  @override
  String get checkoutTotal => 'الإجمالي';

  @override
  String checkoutQuantity(Object quantity) {
    return 'الكمية: $quantity';
  }

  @override
  String get accountMyProducts => 'منتجاتي';

  @override
  String get myProductsEmptyMessage => 'لا توجد منتجات بعد';

  @override
  String get stockIn => 'متوفر';

  @override
  String get stockOut => 'غير متوفر';

  @override
  String get productBrand => 'العلامة التجارية';

  @override
  String get productBrandHint => 'أدخل العلامة التجارية';

  @override
  String get productSizeGroup => 'مجموعة المقاسات';

  @override
  String get productSizeGroupOptional => 'اختياري';

  @override
  String get productSelectGroupFirst => 'اختر المجموعة أولاً';

  @override
  String get productSelectGroupOptional => 'اختر المجموعة (اختياري)';

  @override
  String get productSelectSizeOptional => 'اختر المقاس (اختياري)';

  @override
  String get productDiscountLabel => 'الخصم (%)';

  @override
  String get productDiscountHint => 'اختياري، الافتراضي 0';

  @override
  String get productDiscountInvalidRange => 'الخصم يجب أن يكون بين 0 و 100';

  @override
  String get productVariantRequired =>
      'يرجى إضافة خيار منتج واحد صالح على الأقل.';

  @override
  String get colorPickerHexHint => 'RRGGBB';

  @override
  String get colorPickerInvalidHex => 'أدخل كود لون صحيح من 6 أرقام';

  @override
  String get itemReviewYourReview => 'تقييمك';

  @override
  String get itemReviewSubmitButton => 'إرسال التقييم';

  @override
  String get itemReviewCommentLabel => 'تعليق';

  @override
  String get itemReviewCommentHint => 'شارك تجربتك مع هذا العنصر';

  @override
  String get itemReviewAlreadyRated => 'لقد قمت بتقييم هذا العنصر بالفعل.';

  @override
  String get itemReviewRatingRequired => 'يرجى اختيار تقييم بين 1 و 5.';

  @override
  String get itemReviewCommentRequired => 'يرجى إدخال تعليق.';

  @override
  String get itemReviewSubmittedSuccess => 'تم إرسال التقييم بنجاح.';

  @override
  String get itemReviewLoginRequired => 'يرجى تسجيل الدخول لتقييم العنصر.';

  @override
  String get itemReviewLoadFailed => 'تعذر تحميل التقييمات حالياً.';

  @override
  String get orderSuccessTitle => 'تم تأكيد الطلب';

  @override
  String get orderSuccessSubtitle => 'شكراً لك على طلبك';

  @override
  String get orderSuccessOrderId => 'رقم الطلب';

  @override
  String get orderSuccessTotalAmount => 'المبلغ الإجمالي';

  @override
  String get orderSuccessThanks => 'شكراً لتسوقك معنا';

  @override
  String get orderSuccessContinueShopping => 'مواصلة التسوق';

  @override
  String get orderSuccessViewOrders => 'عرض الطلبات';

  @override
  String get splashTitle => 'ShopHub';

  @override
  String get splashSubtitle => 'وجهتك للتسوق';

  @override
  String get profileOrders => 'الطلبات';

  @override
  String get profileAddresses => 'العناوين';

  @override
  String get profileSettings => 'الإعدادات';

  @override
  String get profileHelp => 'المساعدة';

  @override
  String get profileHelpMessage => 'كيف يمكننا مساعدتك؟';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navCart => 'السلة';

  @override
  String get navAccount => 'الحساب';

  @override
  String get orderStatusPending => 'قيد الانتظار';

  @override
  String get orderStatusProcessing => 'قيد المعالجة';

  @override
  String get orderStatusShipped => 'تم الشحن';

  @override
  String get orderStatusDelivered => 'تم التوصيل';

  @override
  String get orderStatusCancelled => 'ملغي';

  @override
  String get cartQuantity => 'الكمية';

  @override
  String get productAddToCart => 'إضافة للسلة';

  @override
  String get cartRemoveItemTitle => 'حذف العنصر';

  @override
  String get cartRemoveItemMessage => 'هل أنت متأكد من حذف هذا العنصر؟';

  @override
  String get commonRemove => 'حذف';

  @override
  String get cartItemRemoved => 'تم حذف العنصر من السلة';

  @override
  String cartAvailableStock(Object stock) {
    return 'المتوفر: $stock';
  }

  @override
  String get cartItemTotal => 'الإجمالي';

  @override
  String get cartEmptyTitle => 'سلة التسوق فارغة';

  @override
  String get cartStartShopping => 'ابدأ التسوق';

  @override
  String get cartTitle => 'سلة التسوق';

  @override
  String get cartShipping => 'الشحن';

  @override
  String get cartShippingFree => 'مجاني';

  @override
  String get cartCheckout => 'إتمام الشراء';

  @override
  String productReviews(Object count) {
    return '$count تقييمات';
  }

  @override
  String productSold(Object count) {
    return 'تم بيع $count';
  }

  @override
  String get productDescription => 'الوصف';

  @override
  String get productShowLess => 'عرض أقل';

  @override
  String get productShowMore => 'عرض المزيد';

  @override
  String productAddedToCart(Object name) {
    return 'تم إضافة $name إلى السلة';
  }

  @override
  String get addToCartLoginRequired =>
      'يرجى تسجيل الدخول لإضافة العناصر إلى السلة';

  @override
  String get addToCartVariantError => 'تعذر تحديد خيار المنتج';

  @override
  String addToCartSuccess(Object productName) {
    return 'تمت إضافة $productName إلى السلة';
  }

  @override
  String get addToCartFailure => 'فشل في الإضافة إلى السلة. حاول مرة أخرى.';

  @override
  String get variantDefaultSize => 'افتراضي';

  @override
  String get variantDefaultColor => 'افتراضي';

  @override
  String orderPromoApplied(Object code) {
    return 'تم تطبيق العرض: $code';
  }

  @override
  String get orderSubtotal => 'المجموع الفرعي';

  @override
  String get orderTax => 'الضريبة';

  @override
  String get orderDiscount => 'الخصم';

  @override
  String get orderPromoDiscount => 'خصم العرض';

  @override
  String get orderTotal => 'الإجمالي';

  @override
  String get orderSummaryTitle => 'ملخص الطلب';

  @override
  String get confirmOrder => 'تأكيد الطلب';

  @override
  String get myCardsTitle => 'بطاقاتي';

  @override
  String get addCard => 'إضافة بطاقة';

  @override
  String get saveCard => 'حفظ البطاقة';

  @override
  String get cardholderNameLabel => 'اسم حامل البطاقة';

  @override
  String get cardNumberLabel => 'رقم البطاقة';

  @override
  String get expiryMonthLabel => 'الشهر';

  @override
  String get expiryYearLabel => 'السنة';

  @override
  String get cardTypeLabel => 'نوع البطاقة';

  @override
  String get setAsDefaultLabel => 'تعيين كبطاقة افتراضية';

  @override
  String get deleteCardTitle => 'حذف البطاقة';

  @override
  String get deleteCardConfirm => 'هل أنت متأكد من إزالة هذه البطاقة؟';

  @override
  String get deleteCardCancel => 'إلغاء';

  @override
  String get deleteCardConfirmButton => 'حذف';

  @override
  String get cardExpiredBadge => 'منتهية';

  @override
  String get cardDefaultBadge => 'افتراضية';

  @override
  String get noCardsTitle => 'لا توجد بطاقات محفوظة';

  @override
  String get noCardsSubtitle => 'أضف بطاقة للدفع بشكل أسرع';

  @override
  String get cardAddedSuccess => 'تمت إضافة البطاقة بنجاح';

  @override
  String get cardDeletedSuccess => 'تم حذف البطاقة';

  @override
  String get cardActionSetDefault => 'تعيين كافتراضي';

  @override
  String get cardActionDelete => 'حذف';

  @override
  String get selectCardTitle => 'اختر بطاقة';

  @override
  String get addNewCard => 'إضافة بطاقة جديدة';

  @override
  String get orderItemsSection => 'العناصر';

  @override
  String get deliveryAddressSection => 'عنوان التوصيل';

  @override
  String get amountBreakdownSection => 'تفاصيل المبلغ';

  @override
  String selectedPaymentLabel(Object method) {
    return 'الدفع المحدد: $method';
  }

  @override
  String get placeOrder => 'إرسال الطلب';

  @override
  String get promoCodeOptional => 'رمز العرض (اختياري)';

  @override
  String get promoCodeHint => 'أدخل الرمز';

  @override
  String get promoApplied => 'تم تطبيق العرض';

  @override
  String get invalidPromoCode => 'رمز العرض غير صالح';

  @override
  String get checkoutLoginRequired => 'يرجى تسجيل الدخول لمتابعة الدفع.';

  @override
  String get checkoutLoginRequiredShort => 'يرجى تسجيل الدخول للمتابعة.';

  @override
  String get checkoutSelectAddress => 'يرجى اختيار عنوان التوصيل.';

  @override
  String get checkoutSelectPayment => 'يرجى اختيار طريقة الدفع.';

  @override
  String get checkoutSelectDeliveryAddress => 'اختر عنوان التوصيل';

  @override
  String get checkoutCartEmptyWarning => 'سلة التسوق فارغة.';

  @override
  String get cardNumberInvalid => 'أدخل رقم بطاقة صحيحاً من 16 رقماً';

  @override
  String get cardExpiryInvalid => 'اختر تاريخ انتهاء مستقبلياً';

  @override
  String get orderIdLabel => 'رقم الطلب';

  @override
  String get orderDateLabel => 'تاريخ الطلب';

  @override
  String get orderCreatedDateLabel => 'تاريخ الإنشاء';

  @override
  String orderItemsCount(Object count) {
    return 'العناصر ($count)';
  }

  @override
  String get unknownProduct => 'منتج غير معروف';

  @override
  String get brandLabel => 'العلامة التجارية';

  @override
  String get sizeLabel => 'المقاس';

  @override
  String get quantityShortLabel => 'الكمية';

  @override
  String get colorLabel => 'اللون';

  @override
  String get orderDetailsLoadError => 'تعذر تحميل تفاصيل الطلب';

  @override
  String get orderItemsEmptyTitle => 'لا توجد عناصر في الطلب';

  @override
  String get orderItemsEmptySubtitle =>
      'لا توجد عناصر متاحة لهذا الطلب حالياً.';

  @override
  String get changeEmailTitle => 'تغيير البريد الإلكتروني';

  @override
  String get changeEmailSubtitle => 'تحديث عنوان بريدك الإلكتروني';

  @override
  String stockOnlyLeft(Object stock) {
    return 'بقي $stock فقط';
  }

  @override
  String orderMoreItems(Object count) {
    return '+$count عناصر أخرى';
  }

  @override
  String get notificationCartAddSuccess => 'تمت إضافة العنصر إلى السلة';

  @override
  String get notificationCartRemoveSuccess => 'تم حذف العنصر من السلة';

  @override
  String get notificationCartRemoveError => 'فشل في حذف العنصر من السلة';

  @override
  String get notificationCartUpdateSuccess => 'تم تحديث السلة';

  @override
  String get notificationCartUpdateError => 'فشل في تحديث السلة';

  @override
  String get notificationCartLoadError =>
      'فشل في تحميل السلة. يرجى المحاولة مرة أخرى';

  @override
  String get notificationTimeoutError =>
      'انتهت المهلة الزمنية. يرجى المحاولة مرة أخرى';

  @override
  String get notificationOperationSuccess => 'تمت العملية بنجاح';

  @override
  String get notificationAddressSelected => 'تم اختيار العنوان بنجاح';

  @override
  String get notificationAddressUpdateSuccess => 'تم تحديث العنوان بنجاح';

  @override
  String get notificationAddressUpdateError => 'فشل في تحديث العنوان';

  @override
  String get notificationAddressDeleteSuccess => 'تم حذف العنوان بنجاح';

  @override
  String get notificationAddressDeleteError => 'فشل في حذف العنوان';

  @override
  String get notificationCodeApplySuccess => 'تم تطبيق الكود الترويجي بنجاح';

  @override
  String get notificationCodeApplyError =>
      'كود ترويجي غير صحيح أو انتهت صلاحيته';

  @override
  String get notificationCheckoutError => 'فشل الدفع. يرجى المحاولة مرة أخرى';

  @override
  String get notificationOrderPlacedSuccess => 'تم تقديم الطلب بنجاح';

  @override
  String get notificationOrderPlacedError => 'فشل في تقديم الطلب';

  @override
  String get notificationImageUploadError =>
      'فشل في تحميل الصورة. يرجى المحاولة مرة أخرى';

  @override
  String get notificationProductSaveSuccess => 'تم حفظ المنتج بنجاح';

  @override
  String get notificationProductSaveError => 'فشل في حفظ المنتج';

  @override
  String get notificationProductDeleteSuccess => 'تم حذف المنتج بنجاح';

  @override
  String get notificationProductDeleteError => 'فشل في حذف المنتج';

  @override
  String get notificationProfileUpdateError => 'فشل في تحديث الملف الشخصي';

  @override
  String get notificationPasswordChangeSuccess => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get notificationPasswordChangeError => 'فشل في تغيير كلمة المرور';

  @override
  String get notificationEmailChangeError => 'فشل في تغيير البريد الإلكتروني';

  @override
  String get notificationWishlistAddSuccess => 'تمت الإضافة إلى المفضلة';

  @override
  String get notificationWishlistAddError => 'فشل في الإضافة إلى المفضلة';

  @override
  String get notificationWishlistRemoveSuccess => 'تم الحذف من المفضلة';

  @override
  String get notificationWishlistRemoveError => 'فشل في الحذف من المفضلة';

  @override
  String get notificationReviewSubmitSuccess => 'تم إرسال التقييم بنجاح';

  @override
  String get notificationReviewSubmitError => 'فشل في إرسال التقييم';

  @override
  String get notificationPaymentProcessing => 'جاري معالجة الدفع...';

  @override
  String get notificationPaymentSuccess => 'تم الدفع بنجاح';

  @override
  String get notificationPaymentError => 'فشل الدفع. يرجى المحاولة مرة أخرى';

  @override
  String get notificationCopyToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get notificationNoAction => 'يرجى المحاولة مرة أخرى';

  @override
  String get notificationFieldRequired => 'هذا الحقل مطلوب';

  @override
  String get notificationInvalidInput => 'إدخال غير صحيح';

  @override
  String get notificationLinkExpired =>
      'انتهت صلاحية الرابط. يرجى المحاولة مرة أخرى';
}
