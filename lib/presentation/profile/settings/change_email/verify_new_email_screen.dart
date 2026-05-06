import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../repositories/profile_repository.dart';
import '../../../../repositories/user_repository.dart';
import '../../../../widgets/custom_button/custom_button.dart';

/// Step 2 of the change-email flow.
///
/// Receives [newEmail] from [ChangeEmailScreen]. The user enters the OTP
/// sent to that address.
///
/// On correct OTP:
///   1. [UserRepository.verifyOtp]         — validates the code server-side
///   2. [ProfileRepository.updateUser]     — persists the new email
///   3. [AuthState.updateCurrentUser]      — updates local state + storage
///
/// On success the user is popped back past both change-email screens.
class VerifyNewEmailScreen extends StatefulWidget {
  const VerifyNewEmailScreen({super.key, required this.newEmail});

  final String newEmail;

  @override
  State<VerifyNewEmailScreen> createState() => _VerifyNewEmailScreenState();
}

class _VerifyNewEmailScreenState extends State<VerifyNewEmailScreen> {
  static const int _otpLength = 6;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  late final UserRepository    _userRepository;
  late final ProfileRepository _profileRepository;

  bool _isVerifying = false;
  bool _isResending = false;
  String? _verificationError;

  @override
  void initState() {
    super.initState();
    _userRepository    = Get.find<UserRepository>();
    _profileRepository = Get.find<ProfileRepository>();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _verifyAndUpdate() async {
    if (_isVerifying) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthState>();
    final username  = authState.user?.username.trim() ?? '';
    final otp       = _otpController.text.trim();

    setState(() {
      _isVerifying       = true;
      _verificationError = null;
    });

    try {
      // 1. Verify the OTP — same endpoint as forgot-password.
      await _userRepository.verifyOtp(
        username: username,
        email:    widget.newEmail,
        otp:      otp,
      );

      // 2. Persist the new email via the existing updateUser endpoint.
      final currentUser = authState.user!;
      final updatedUser = currentUser.copyWith(email: widget.newEmail);
      await _profileRepository.updateUser(updatedUser);

      // 3. Reflect the change in local state + shared-preferences.
      await authState.updateCurrentUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated successfully')),
      );

      // Pop this screen AND ChangeEmailScreen in one go.
      Navigator.popUntil(
        context,
            (route) =>
        route.settings.name != '/verify-new-email' &&
            route.settings.name != '/change-email',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _verificationError = error.toString());
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending) return;

    final authState = context.read<AuthState>();
    final username  = authState.user?.username.trim() ?? '';

    setState(() {
      _isResending       = true;
      _verificationError = null;
    });

    try {
      await _userRepository.sendOtp(
        username: username,
        email:    widget.newEmail,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code has been sent')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _verificationError = error.toString());
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _onRefresh() async => setState(() => _verificationError = null);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify New Email')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.insetsMd,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Instruction ────────────────────────────────────────────
                  Text(
                    'Enter the $_otpLength-digit code sent to',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.newEmail,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── OTP input ──────────────────────────────────────────────
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: _otpLength,
                    style: AppTextStyles.bodyLarge,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: '• • • • • •',
                      counterText: '',
                    ),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return 'Verification code is required';
                      if (trimmed.length < _otpLength) {
                        return 'Please enter the full $_otpLength-digit code';
                      }
                      return null;
                    },
                  ),

                  // ── Error ──────────────────────────────────────────────────
                  if (_verificationError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _verificationError!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  // ── Verify CTA ─────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Verify & Update Email',
                      leading: _isVerifying
                          ? const SizedBox(
                        width: AppSpacing.iconSm,
                        height: AppSpacing.iconSm,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : null,
                      onPressed: _isVerifying ? null : _verifyAndUpdate,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Resend ─────────────────────────────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: _isResending ? null : _resendOtp,
                      child: _isResending
                          ? const SizedBox(
                        width: AppSpacing.iconSm,
                        height: AppSpacing.iconSm,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Resend Code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}