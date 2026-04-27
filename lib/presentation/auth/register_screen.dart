import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/codes_repository.dart';
import '../../../models/api_code_option.dart';
import '../../../models/user.dart';
import '../../src/config/app_constants.dart';
import '../../src/config/route.dart';
import '../../core/app/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../src/services/auth_service.dart';
import '../../src/shared/validation/auth_validators.dart';
import '../../src/shared/widgets/app_button.dart';
import '../../src/shared/widgets/app_snackbar.dart';
import '../../src/shared/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController        = TextEditingController();
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _phoneController           = TextEditingController();
  final _addressController         = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey                   = GlobalKey<FormState>();

  late final CodesRepository _codesRepository;
  final _authService = AuthService();

  bool   _obscurePassword        = true;
  bool   _obscureConfirmPassword = true;
  bool   _agreeToTerms           = false;
  bool   _isLoading              = false;
  int?   _selectedGender;
  String? _genderError;
  String? _genderLoadError;
  bool   _isLoadingGenderOptions = false;
  String _passwordStrength       = 'Weak';
  Color  _passwordStrengthColor  = AppColors.error;
  List<ApiCodeOption> _genderOptions = const [];

  @override
  void initState() {
    super.initState();
    _codesRepository = Get.find<CodesRepository>();
    _passwordController.addListener(_updatePasswordStrength);
    _loadGenderOptions();
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final trimmed = _passwordController.text.trim();
    String label = 'Weak';
    Color  color = AppColors.error;
    if (trimmed.length >= 10 &&
        RegExp(r'[A-Z]').hasMatch(trimmed) &&
        RegExp(r'[0-9]').hasMatch(trimmed)) {
      label = 'Strong';
      color = AppColors.success;
    } else if (trimmed.length >= 6) {
      label = 'Medium';
      color = AppColors.accent;
    }
    if (label != _passwordStrength) {
      setState(() {
        _passwordStrength      = label;
        _passwordStrengthColor = color;
      });
    }
  }

  Future<void> _loadGenderOptions({bool forceRefresh = false}) async {
    setState(() { _isLoadingGenderOptions = true; _genderLoadError = null; });
    try {
      final options = await _codesRepository.getCodes(
        majorCode:    ApiCodeOption.genderMajorCode,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() => _genderOptions = options);
    } catch (e) {
      if (!mounted) return;
      setState(() => _genderLoadError = e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingGenderOptions = false);
    }
  }

  Widget _buildGenderSection() {
    if (_isLoadingGenderOptions) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: LinearProgressIndicator(),
      );
    }
    if (_genderLoadError != null && _genderOptions.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: Text(_genderLoadError!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ),
          TextButton(
            onPressed: () => _loadGenderOptions(forceRefresh: true),
            child: const Text('Retry'),
          ),
        ],
      );
    }
    return Column(
      children: _genderOptions.map((option) => RadioListTile<int>(
        contentPadding: EdgeInsets.zero,
        title: Text(option.label),
        value: option.minorCode,
        groupValue: _selectedGender,
        onChanged: (value) => setState(() {
          _selectedGender = value;
          _genderError = null;
        }),
      )).toList(),
    );
  }

  Future<void> _handleContinue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedGender == null) {
      setState(() => _genderError = 'Please select your gender');
      return;
    }

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    final pendingUser = User(
      username: username,
      passwordHash: _passwordController.text.trim(),
      fullname: _nameController.text.trim(),
      email: email,
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      role: 'customer',
      country: AppConstants.defaultCountry,
      gender: _selectedGender,
      userId: 0,
      createdAt: '',
      updatedAt: '',
      isActive: 0,
    );

    try {
      // STEP 1 — Register
      await _authService.register(pendingUser);
      if (!mounted) return;

      // STEP 2 — Send OTP (retry for FK commit delay)
      AuthException? lastOtpError;
      bool otpSent = false;

      for (int attempt = 0; attempt < 5; attempt++) {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;

        try {
          await _authService.sendOtpByEmail(email: email);
          otpSent = true;
          break;
        } on AuthException catch (e) {
          lastOtpError = e;
          final msg = e.message.toLowerCase();
          if (msg.contains('network') || msg.contains('timeout')) rethrow;
        }
      }

      if (!otpSent) {
        throw lastOtpError ?? AuthException('Failed to send verification code.');
      }

      if (!mounted) return;

      // ✅ Fix #1 — navigate to the correct signup OTP screen
      Navigator.pushNamed(
        context,
        AppRoutes.signupOtpVerification,   // was: AppRoutes.otpSent ❌
        arguments: {
          'email': email,
          // username omitted — SignupOtpVerificationScreen doesn't need it
        },
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: e.message, type: AppSnackBarType.error);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: e.toString(), type: AppSnackBarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hintText: 'Enter your username',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) {
                    if ((v?.trim() ?? '').isEmpty) return 'Username is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  controller: _nameController,
                  label: l10n.registerFullNameLabel,
                  hintText: l10n.registerFullNameHint,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (v) {
                    if ((v?.trim() ?? '').isEmpty) return l10n.validationNameRequired;
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),

                Text('Gender', style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                _buildGenderSection(),
                if (_genderError != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(_genderError!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                ],
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  label: l10n.registerEmailLabel,
                  hintText: l10n.registerEmailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (v) => AuthValidators.email(
                    v,
                    emptyMessage: l10n.validationEmailRequired,
                    invalidMessage: l10n.validationEmailInvalid,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  label: 'Phone',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (v) => AuthValidators.phone(
                    v,
                    emptyMessage: l10n.validationPhoneRequired,
                    invalidMessage: l10n.validationPhoneInvalid,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  controller: _addressController,
                  label: 'Address',
                  hintText: 'Enter your address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  validator: (v) {
                    if ((v?.trim() ?? '').isEmpty) return 'Address is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: AppColors.textHint),
                      const SizedBox(width: AppSpacing.md),
                      Text(AppConstants.defaultCountry, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  label: l10n.registerPasswordLabel,
                  hintText: l10n.registerPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => AuthValidators.password(
                    v,
                    emptyMessage: l10n.validationPasswordRequired,
                    tooShortMessage: l10n.validationPasswordTooShort,
                    minLength: 6,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Password strength: $_passwordStrength',
                  style: AppTextStyles.bodySmall.copyWith(color: _passwordStrengthColor),
                ),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  label: l10n.registerConfirmPasswordLabel,
                  hintText: l10n.registerConfirmPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (v) => AuthValidators.confirmPassword(
                    v,
                    original: _passwordController.text,
                    emptyMessage: l10n.validationConfirmPasswordRequired,
                    mismatchMessage: l10n.validationConfirmPasswordMismatch,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(l10n.registerAgreeTerms,
                            style: AppTextStyles.bodySmall),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  label: _isLoading ? 'Sending code...' : 'Continue',
                  leading: _isLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : null,
                  onPressed: (!_agreeToTerms || _isLoading) ? null : _handleContinue,
                ),
                const SizedBox(height: AppSpacing.md),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.registerHaveAccount),
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