import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../repositories/user_repository.dart';
import '../../../../widgets/custom_button/custom_button.dart';
import '../../../../widgets/custom_text_field/custom_text_field.dart';
import 'verify_new_email_screen.dart';

/// Step 1 of the change-email flow.
///
/// Collects the new email address, then calls [UserRepository.sendOtp]
/// — the same endpoint used by the forgot-password flow — passing the
/// current [username] and the [newEmail] as the destination address.
///
/// On success the user is pushed to [VerifyNewEmailScreen].
class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newEmailController = TextEditingController();

  late final UserRepository _userRepository;

  bool _isSendingOtp = false;
  String? _requestError;

  @override
  void initState() {
    super.initState();
    _userRepository = Get.find<UserRepository>();
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    if (_isSendingOtp) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthState>();
    final username  = authState.user?.username.trim() ?? '';
    final newEmail  = _newEmailController.text.trim();

    setState(() {
      _isSendingOtp = true;
      _requestError = null;
    });

    try {
      // Reuses the same OTP endpoint as the forgot-password flow.
      await _userRepository.sendOtp(username: username, email: newEmail);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => VerifyNewEmailScreen(newEmail: newEmail),
          settings: const RouteSettings(name: '/verify-new-email'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _requestError = error.toString());
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _onRefresh() async => setState(() => _requestError = null);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentEmail = context.watch<AuthState>().user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Change Email')),
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
                  // ── Current email (read-only) ──────────────────────────────
                  Text('Current Email', style: AppTextStyles.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    currentEmail,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── New email input ────────────────────────────────────────
                  CustomTextField(
                    controller: _newEmailController,
                    label: 'New Email',
                    hintText: 'Enter your new email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return 'Email is required';
                      if (!trimmed.contains('@') || !trimmed.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      if (trimmed == currentEmail) {
                        return 'New email must be different from your current one';
                      }
                      return null;
                    },
                  ),

                  // ── Error ──────────────────────────────────────────────────
                  if (_requestError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _requestError!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  // ── CTA ────────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Send Verification Code',
                      leading: _isSendingOtp
                          ? const SizedBox(
                        width: AppSpacing.iconSm,
                        height: AppSpacing.iconSm,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : null,
                      onPressed: _isSendingOtp ? null : _sendOtp,
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