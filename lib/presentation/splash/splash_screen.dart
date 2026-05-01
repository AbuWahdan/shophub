import 'package:flutter/material.dart';

import '../../core/app/app_theme.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../services/storage_service.dart';


/// Splash Screen with fade animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      final isLoggedIn = await StorageService().isLoggedIn();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(isLoggedIn ? '/main' : '/onboarding');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Container(
                    width: AppSpacing.imageLg,
                    height: AppSpacing.imageLg,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      size: AppSpacing.iconLg,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  AppLocalizations.of(context).splashTitle,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppLocalizations.of(context).splashSubtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
