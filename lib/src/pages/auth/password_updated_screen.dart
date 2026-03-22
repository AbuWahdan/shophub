import 'dart:async';

import 'package:flutter/material.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/app_button.dart';
import '../../themes/theme.dart';
import '../../config/route.dart';

class PasswordUpdatedScreen extends StatefulWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  State<PasswordUpdatedScreen> createState() => _PasswordUpdatedScreenState();
}

class _PasswordUpdatedScreenState extends State<PasswordUpdatedScreen> {
  late Timer _autoNavigateTimer;
  int _countdownSeconds = 3;

  @override
  void initState() {
    super.initState();
    _startAutoNavigate();
  }

  @override
  void dispose() {
    _autoNavigateTimer.cancel();
    super.dispose();
  }

  void _startAutoNavigate() {
    _autoNavigateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        timer.cancel();
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: AppTheme.padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: AppSpacing.iconXl * 1.5,
                  color: AppColors.success,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  l10n.passwordUpdatedTitle,
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.passwordUpdatedSubtitle,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: l10n.passwordUpdatedBackToLogin,
                    onPressed: _navigateToLogin,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.passwordUpdatedAutoRedirect(_countdownSeconds),
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
