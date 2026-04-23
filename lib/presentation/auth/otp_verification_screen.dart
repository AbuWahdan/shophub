import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';
import '../../models/user.dart';
import '../../src/config/route.dart';
import '../../src/core/theme/app_theme.dart';
import '../../src/services/auth_service.dart';
import '../../src/shared/widgets/app_button.dart';
import '../../src/shared/widgets/app_snackbar.dart';

/// Shared OTP verification screen for both flows:
///   - forgot_password → navigates to ResetPasswordScreen on success
///   - signup          → activates the inactive user, then navigates to /login
class OTPVerificationScreen extends StatefulWidget {
  final String username;
  final String email;
  final String flow;           // 'forgot_password' | 'signup'
  final User?  pendingUser;    // only set for signup flow

  const OTPVerificationScreen({
    required this.username,
    required this.email,
    this.flow = 'forgot_password',
    this.pendingUser,
    super.key,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  late AnimationController _timerController;
  int  _remainingSeconds = 60;
  bool _isVerifying      = false;
  bool _isResending      = false;

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timerController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..addListener(() {
      setState(() {
        _remainingSeconds = (60 * (1 - _timerController.value)).toInt();
      });
    });
    _timerController.forward();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timerController.dispose();
    super.dispose();
  }

  String get _otpValue    => _otpControllers.map((c) => c.text.trim()).join();
  bool   get _otpComplete => _otpValue.length == 6;

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _handleVerify() async {
    if (!_otpComplete) return;
    setState(() => _isVerifying = true);

    try {
      // 1 — Verify the OTP (same for both flows)
      await _authService.verifyOtp(
        username: widget.username,
        email:    widget.email,
        otp:      _otpValue,
      );

      if (!mounted) return;

      if (widget.flow == 'signup') {
        // 2 — OTP correct → activate the user account (IS_ACTIVE: 0 → 1)
        if (widget.pendingUser != null) {
          await _authService.activateUser(widget.pendingUser!);
        }

        if (!mounted) return;

        AppSnackBar.show(
          context,
          message: 'Email verified! You can now log in.',
          type: AppSnackBarType.success,
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
              (route) => false,
        );
      } else {
        // Forgot-password flow → go to reset password
        Navigator.pushNamed(
          context,
          AppRoutes.resetPassword,
          arguments: {'username': widget.username},
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: e.message, type: AppSnackBarType.error);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Verification failed. Please try again.',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _handleResend() async {
    if (_isResending || _remainingSeconds > 0) return;
    setState(() => _isResending = true);

    try {
      await _authService.sendOtp(username: widget.username, email: widget.email);
      if (!mounted) return;

      AppSnackBar.show(
        context,
        message: 'A new code has been sent to ${widget.email}',
        type: AppSnackBarType.success,
      );

      _timerController.reset();
      _timerController.forward();
      setState(() => _remainingSeconds = 60);
    } on AuthException catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: e.message, type: AppSnackBarType.error);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Failed to resend code. Please try again.',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(l10n.otpEnterCode,
                  style: AppTextStyles.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.otpSubtitle,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center),
              if (widget.email.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.jumbo),

              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.center,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: AppSpacing.buttonMd,
                    height: AppSpacing.buttonLg,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      enabled: !_isVerifying,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: AppSpacing.borderThick,
                          ),
                        ),
                      ),
                      onChanged: (v) => _onDigitChanged(index, v),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.xxl),

              if (_remainingSeconds > 0)
                Text(l10n.otpResendIn(_remainingSeconds),
                    style: AppTextStyles.bodySmall)
              else
                TextButton(
                  onPressed: _isResending ? null : _handleResend,
                  child: Text(_isResending ? 'Sending...' : l10n.otpResend),
                ),

              const SizedBox(height: AppSpacing.xxl),

              AppButton(
                label: _isVerifying ? 'Verifying...' : l10n.otpVerify,
                leading: _isVerifying
                    ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                onPressed: (!_otpComplete || _isVerifying) ? null : _handleVerify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}