import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../src/config/route.dart';
import '../../src/core/theme/app_theme.dart';
import '../../src/shared/widgets/app_button.dart';

class OtpSentNoticeScreen extends StatefulWidget {
  final String username;
  final String email;
  final String flow; // 'forgot_password' | 'signup'

  const OtpSentNoticeScreen({
    required this.username,
    required this.email,
    this.flow = 'forgot_password',
    super.key,
  });

  @override
  State<OtpSentNoticeScreen> createState() => _OtpSentNoticeScreenState();
}

class _OtpSentNoticeScreenState extends State<OtpSentNoticeScreen> {
  int _countdownSeconds = 3;

  @override
  void initState() {
    super.initState();
    _startAutoNavigate();
  }

  Future<void> _startAutoNavigate() async {
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _countdownSeconds = i - 1);
    }
    if (mounted) _goToVerification();
  }

  void _goToVerification() {
    Navigator.pushNamed(
      context,
      AppRoutes.otpVerification,
      arguments: {
        'username': widget.username,
        'email':    widget.email,
        'flow':     widget.flow,
      },
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
                  Icons.mark_email_read_outlined,
                  size: AppSpacing.iconXl * 1.5,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.otpSentTitle,
                    style: AppTextStyles.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.otpSentSubtitle,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xxxl),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: _countdownSeconds > 0
                        ? '${l10n.commonContinue} (${_countdownSeconds}s)'
                        : l10n.commonContinue,
                    onPressed: _goToVerification,
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