import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../src/core/theme/app_theme.dart';

/// Onboarding flow with page indicators
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  List<OnboardingPage> _pages(BuildContext context) => [
    OnboardingPage(
      title: context.l10n.onboardingWelcomeTitle,
      subtitle: context.l10n.onboardingWelcomeSubtitle,
      icon: Icons.shopping_bag,
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: context.l10n.onboardingDeliveryTitle,
      subtitle: context.l10n.onboardingDeliverySubtitle,
      icon: Icons.local_shipping,
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: context.l10n.onboardingSecureTitle,
      subtitle: context.l10n.onboardingSecureSubtitle,
      icon: Icons.lock,
      color: AppColors.accentOrange,
    ),
    OnboardingPage(
      title: context.l10n.onboardingDealsTitle,
      subtitle: context.l10n.onboardingDealsSubtitle,
      icon: Icons.local_offer,
      color: AppColors.primary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    final totalPages = _pages(context).length;
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return _buildPage(pages[index]);
            },
          ),
          Positioned(
            top: AppSpacing.xl,
            right: AppSpacing.xl,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text(
                context.l10n.onboardingSkip,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.jumbo,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                        (index) => Container(
                      width: _currentPage == index
                          ? AppSpacing.xxl
                          : AppSpacing.sm,
                      height: AppSpacing.sm,
                      margin: AppSpacing.symmetric(horizontal: AppSpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.neutral300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Padding(
                  padding: AppSpacing.horizontal(AppSpacing.xl),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonMd,
                    child: ElevatedButton(
                      onPressed: _goToNextPage,
                      child: Text(
                        _currentPage == pages.length - 1
                            ? context.l10n.onboardingGetStarted
                            : context.l10n.onboardingNext,
                        style: AppTextStyles.labelLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [page.color, page.color.withOpacity(0.7)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppSpacing.imageLg,
            height: AppSpacing.imageLg,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textOnPrimary.withOpacity(0.2),
            ),
            child: Icon(
              page.icon,
              size: AppSpacing.iconXl,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.giant),
          Text(
            page.title,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: AppSpacing.horizontal(AppSpacing.xxxl),
            child: Text(
              page.subtitle,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textOnPrimary.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}