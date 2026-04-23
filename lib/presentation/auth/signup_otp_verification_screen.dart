import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../src/core/theme/app_theme.dart';
import '../../src/services/auth_service.dart';
import '../../src/shared/widgets/app_button.dart';
import '../../src/shared/widgets/app_snackbar.dart';

/// OTP verification screen for the sign-up flow.
///
/// By the time the user reaches this screen, their account already exists
/// in the DB (register() was called and succeeded in RegisterScreen).
/// This screen only needs to verify the OTP — no registration data needed.
class SignupOtpVerificationScreen extends StatefulWidget {
  const SignupOtpVerificationScreen({super.key});

  @override
  State<SignupOtpVerificationScreen> createState() =>
      _SignupOtpVerificationScreenState();
}

class _SignupOtpVerificationScreenState
    extends State<SignupOtpVerificationScreen> {
  final List<TextEditingController> _digitControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendCooldown = 0;

  late final String _email;
  late final String _username;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = (args is Map<String, dynamic>) ? args : <String, dynamic>{};
    _email    = (map['email']    as String? ?? '').trim();
    _username = (map['username'] as String? ?? '').trim();
  }

  @override
  void dispose() {
    for (final c in _digitControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpValue => _digitControllers.map((c) => c.text.trim()).join();
  bool   get _otpComplete => _otpValue.length == 6;

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verifyOtp() async {
    if (!_otpComplete) return;
    setState(() => _isVerifying = true);

    try {
      final authService = AuthService();
      await authService.verifyOtp(
        username: _username,
        email:    _email,
        otp:      _otpValue,
      );

      if (!mounted) return;

      AppSnackBar.show(
        context,
        message: 'Email verified! You can now log in.',
        type: AppSnackBarType.success,
      );

      // Clear entire signup stack and go to login.
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context, message: error.message, type: AppSnackBarType.error);
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

  Future<void> _resendOtp() async {
    if (_isResending || _resendCooldown > 0) return;
    setState(() => _isResending = true);

    try {
      final authService = AuthService();
      // User exists at this point — standard sendOtp works fine.
      await authService.sendOtp(username: _username, email: _email);

      if (!mounted) return;

      AppSnackBar.show(
        context,
        message: 'A new code has been sent to $_email',
        type: AppSnackBarType.success,
      );

      setState(() => _resendCooldown = 60);
      _tickCooldown();
    } on AuthException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context, message: error.message, type: AppSnackBarType.error);
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

  void _tickCooldown() async {
    while (_resendCooldown > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _resendCooldown--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    size: 40, color: AppColors.primary),
              ),

              const SizedBox(height: AppSpacing.xl),
              Text('Check your email',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text('We sent a 6-digit verification code to',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xs),
              Text(_email,
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center),

              const SizedBox(height: AppSpacing.xxl),

              // ── 6 digit boxes ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs),
                    child: SizedBox(
                      width: 48,
                      child: TextField(
                        controller: _digitControllers[index],
                        focusNode: _focusNodes[index],
                        enabled: !_isVerifying,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: AppTextStyles.headlineSmall,
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.border, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        onChanged: (v) => _onDigitChanged(index, v),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Verify button ─────────────────────────────────────────────
              AppButton(
                label: _isVerifying ? 'Verifying...' : 'Verify Email',
                leading: _isVerifying
                    ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                onPressed:
                (!_otpComplete || _isVerifying) ? null : _verifyOtp,
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Resend ────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn't receive the code? ",
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                  if (_resendCooldown > 0)
                    Text('Resend in ${_resendCooldown}s',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint))
                  else
                    TextButton(
                      onPressed: _isResending ? null : _resendOtp,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _isResending ? 'Sending...' : 'Resend',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
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