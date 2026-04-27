import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary
  static const Color primary = Color(0xFF2B3EFF);
  static const Color primaryLight = Color(0xFF697AFF);
  static const Color primaryDark = Color(0xFF0018CC);

  // Accent
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF9A70);

  // Status
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4D4F);

  // Surfaces
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2FF);

  // Text
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFE8ECF4);
  static const Color divider = Color(0xFFF0F2F5);

  // Cards and shadows
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x1A2B3EFF);

  // Special
  static const Color star = Color(0xFFFFB800);
  static const Color saleBadge = Color(0xFFFF4D4F);
  static const Color saleBadgeText = Color(0xFFFFFFFF);

  // Compatibility aliases
  static const Color secondary = primaryLight;
  static const Color white = textOnPrimary;
  static const Color black = textPrimary;
  static const Color transparent = Colors.transparent;

  static const Color backgroundLight = background;
  static const Color surfaceLight = surfaceVariant;
  static const Color cardLight = cardBackground;
  static const Color dividerLight = divider;
  static const Color iconLight = textHint;

  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryLight = textSecondary;
  static const Color textMutedLight = textHint;

  static const Color backgroundDark = Color(0xFF10111A);
  static const Color surfaceDark = Color(0xFF191C28);
  static const Color cardDark = Color(0xFF212537);
  static const Color dividerDark = Color(0xFF303651);
  static const Color iconDark = Color(0xFFD4DBEC);

  static const Color textPrimaryDark = Color(0xFFF5F7FF);
  static const Color textSecondaryDark = Color(0xFFC0C7DD);
  static const Color textMutedDark = Color(0xFF8D96B0);

  static const Color accentOrange = accent;
  static const Color accentYellow = warning;

  static const Color neutral100 = Color(0xFFF6F8FC);
  static const Color neutral200 = Color(0xFFEFF2F8);
  static const Color neutral300 = Color(0xFFDCE3F0);
  static const Color neutral400 = Color(0xFFB6C0D4);
  static const Color neutral500 = Color(0xFF8A96AE);
  static const Color neutral600 = Color(0xFF65718A);

  static const Color chipBlack = textPrimary;
  static const Color chipWhite = textOnPrimary;
  static const Color chipRed = saleBadge;
  static const Color chipBlue = primary;
  static const Color chipGreen = success;
  static const Color chipYellow = warning;
  static const Color chipGray = neutral500;
  static const Color chipNavy = primaryDark;
  static const Color chipBrown = Color(0xFF8B5E3C);

  static const Color successSurface = Color(0xFFE9FFF7);
  static const Color highlightSoft = Color(0xFFFFF3EE);
}

class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = 'Poppins';

  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle priceMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle priceOriginal = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  // Compatibility aliases
  static const TextStyle displaySmall = headingLarge;
  static const TextStyle headlineLarge = headingLarge;
  static const TextStyle headlineMedium = headingMedium;
  static const TextStyle headlineSmall = headingSmall;
  static const TextStyle titleLarge = headingMedium;
  static const TextStyle titleMedium = headingSmall;
  static const TextStyle titleSmall = bodyLarge;
  static const TextStyle labelSmall = caption;

  static TextStyle emphasized(TextStyle base) =>
      base.copyWith(fontWeight: FontWeight.w600);
  static TextStyle strong(TextStyle base) =>
      base.copyWith(fontWeight: FontWeight.w700);
  static TextStyle subtle(TextStyle base) =>
      base.copyWith(letterSpacing: AppSpacing.xs);
}

class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Compatibility scale
  static const double xxxl = 56;
  static const double jumbo = 40;
  static const double giant = 48;
  static const double massive = 64;
  static const double hero = 80;

  // Radius compatibility
  static const double radiusSm = AppRadius.sm;
  static const double radiusMd = AppRadius.md;
  static const double radiusLg = AppRadius.lg;
  static const double radiusXl = AppRadius.xl;
  static const double radiusPill = AppRadius.full;

  // Borders
  static const double borderThin = 1;
  static const double borderThick = 2;
  static const double borderHeavy = 3;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconHero = 80;

  // Buttons
  static const double buttonSm = 44;
  static const double buttonMd = 54;
  static const double buttonLg = 60;

  // Other sizes
  static const double imageSm = 48;
  static const double imageMd = 80;
  static const double imageLg = 120;
  static const double imageHero = 300;

  static const double navHeight = 72;
  static const double navMaxWidth = 460;

  static const EdgeInsets insetsXs = EdgeInsets.all(xs);
  static const EdgeInsets insetsSm = EdgeInsets.all(sm);
  static const EdgeInsets insetsMd = EdgeInsets.all(md);
  static const EdgeInsets insetsLg = EdgeInsets.all(lg);
  static const EdgeInsets insetsXl = EdgeInsets.all(xl);
  static const EdgeInsets insetsXxl = EdgeInsets.all(xxl);

  static EdgeInsets all(double value) => EdgeInsets.all(value);

  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);

  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
}

class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 100;
}

class AppShadows {
  const AppShadows._();

  static const BoxShadow cardShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 20,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x402B3EFF),
    blurRadius: 16,
    offset: Offset(0, 6),
    spreadRadius: 0,
  );

  static const BoxShadow subtleShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 8,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  static const BoxShadow topBarShadow = BoxShadow(
    color: Color(0x142B3EFF),
    blurRadius: 12,
    offset: Offset(0, -2),
    spreadRadius: 0,
  );
}

class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textOnPrimary,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.headingLarge,
      iconTheme: const IconThemeData(color: AppColors.primary),
      actionsIconTheme: const IconThemeData(color: AppColors.primary),
      shape: const Border(bottom: BorderSide(color: AppColors.divider)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: EdgeInsets.zero,
      shadowColor: AppColors.transparent,
    ),
    dividerColor: AppColors.divider,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      labelStyle: AppTextStyles.labelMedium,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSpacing.buttonMd),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        textStyle: AppTextStyles.buttonLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        elevation: 0,
        shadowColor: AppColors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSpacing.buttonMd),
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.buttonLarge.copyWith(color: AppColors.primary),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textHint),
  );

  static ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      secondary: AppColors.accent,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnPrimary,
      onSurface: AppColors.textPrimaryDark,
      onError: AppColors.textOnPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: AppColors.transparent,
    ),
    dividerColor: AppColors.dividerDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.textPrimaryDark,
      iconTheme: IconThemeData(color: AppColors.primaryLight),
      actionsIconTheme: IconThemeData(color: AppColors.primaryLight),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textMutedDark,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.dividerDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.dividerDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    textTheme:
        const TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          displaySmall: AppTextStyles.displaySmall,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          titleSmall: AppTextStyles.titleSmall,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ).apply(
          bodyColor: AppColors.textPrimaryDark,
          displayColor: AppColors.textPrimaryDark,
        ),
  );

  static List<BoxShadow> shadow = const <BoxShadow>[AppShadows.cardShadow];

  static EdgeInsets padding = AppSpacing.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm,
  );

  static EdgeInsets hPadding = AppSpacing.horizontal(AppSpacing.sm);

  static double fullWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double fullHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
}
