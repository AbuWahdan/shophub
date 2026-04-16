import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/app_text_styles.dart';
import '../../l10n/l10n.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../themes/theme.dart';
import '../../config/route.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String username;
  final String email;

  const OtpVerificationScreen({
    required this.username,
    required this.email,
    super.key,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpControllers = List<TextEditingController>.generate(
    6,
    (index) => TextEditingController(),
  );
  final _otpFocusNodes = List<FocusNode>.generate(6, (index) => FocusNode());
  bool _isVerifying = false;
  int _resendCountdownSeconds = 60;
  late Timer _resendTimer;
  bool _canResend = false;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    _resendTimer.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdownSeconds = 60;
    _canResend = false;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _resendCountdownSeconds--;
        if (_resendCountdownSeconds <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field if a digit is entered
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        // Last field - unfocus
        _otpFocusNodes[index].unfocus();
      }
    }
  }

  String _getOtp() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _getOtp();

    if (otp.length != 6) {
      AppSnackBar.show(
        context,
        message: 'Please enter all 6 digits',
        type: AppSnackBarType.error,
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      await _authService.verifyOtp(
        username: widget.username,
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.resetPassword,
        arguments: {
          'username': widget.username,
        },
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      _clearOtpFields();

      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      _clearOtpFields();

      AppSnackBar.show(
        context,
        message: 'OTP verification failed. Please try again.',
        type: AppSnackBarType.error,
      );
    }
  }

  void _clearOtpFields() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    _resendTimer.cancel();

    setState(() {
      _isVerifying = true;
    });

    try {
      await _authService.sendOtp(
        username: widget.username,
        email: widget.email,
      );

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      _clearOtpFields();
      _startResendTimer();

      AppSnackBar.show(
        context,
        message: 'OTP resent successfully',
        type: AppSnackBarType.success,
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );

      _startResendTimer();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      AppSnackBar.show(
        context,
        message: 'Failed to resend OTP. Please try again.',
        type: AppSnackBarType.error,
      );

      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.otpVerificationTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.otpVerificationTitle,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.otpVerificationSubtitle,
                style: AppTextStyles.bodyMedium,
              ),
              if (widget.email.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.email,
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: AppSpacing.imageSm,
                    height: AppSpacing.imageSm,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      enabled: !_isVerifying,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      onChanged: (value) => _onOtpDigitChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.otpVerificationVerify,
                  onPressed: _isVerifying ? null : _handleVerifyOtp,
                  leading: _isVerifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Resend Section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.otpResendQuestion,
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_canResend)
                    TextButton(
                      onPressed: _isVerifying ? null : _handleResendOtp,
                      child: Text(
                        l10n.otpResend,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    Text(
                      l10n.otpResendCountdown(
                        'Resend in 0:${_resendCountdownSeconds.toString().padLeft(2, '0')}',
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
