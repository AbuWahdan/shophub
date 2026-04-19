import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/codes_repository.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/l10n.dart';
import '../../model/api_code_option.dart';
import '../../model/user.dart';
import '../../state/auth_state.dart';
import '../../shared/validation/auth_validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../themes/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryController = TextEditingController(text: 'Jordan');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final CodesRepository _codesRepository;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  int? _selectedGender;
  String? _genderError;
  String? _genderLoadError;
  bool _isLoadingGenderOptions = false;
  String _passwordStrength = 'Weak';
  Color _passwordStrengthColor = AppColors.error;
  List<ApiCodeOption> _genderOptions = const <ApiCodeOption>[];

  @override
  void initState() {
    super.initState();
    _codesRepository = Get.find<CodesRepository>();
    _passwordController.addListener(_updatePasswordStrength);
    _updatePasswordStrength();
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
    _countryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final value = _passwordController.text;
    final trimmed = value.trim();
    String label = 'Weak';
    Color color = AppColors.error;
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
        _passwordStrength = label;
        _passwordStrengthColor = color;
      });
    }
  }

  Future<void> _loadGenderOptions({bool forceRefresh = false}) async {
    setState(() {
      _isLoadingGenderOptions = true;
      _genderLoadError = null;
    });

    try {
      final options = await _codesRepository.getCodes(
        majorCode: ApiCodeOption.genderMajorCode,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _genderOptions = options;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _genderLoadError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGenderOptions = false;
        });
      }
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
            child: Text(
              _genderLoadError!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () => _loadGenderOptions(forceRefresh: true),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return Column(
      children: _genderOptions
          .map(
            (option) => RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              title: Text(option.label),
              value: option.minorCode,
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                  _genderError = null;
                });
              },
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = context.watch<AuthState>();
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
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Username is required';
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
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return l10n.validationNameRequired;
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
                  Text(
                    _genderError!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  label: l10n.registerEmailLabel,
                  hintText: l10n.registerEmailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) => AuthValidators.email(
                    value,
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
                  validator: (value) => AuthValidators.phone(
                    value,
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
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Address is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _countryController,
                  label: 'Country',
                  hintText: 'Enter your country',
                  prefixIcon: const Icon(Icons.flag_outlined),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Country is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  label: l10n.registerPasswordLabel,
                  hintText: l10n.registerPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) => AuthValidators.password(
                    value,
                    emptyMessage: l10n.validationPasswordRequired,
                    tooShortMessage: l10n.validationPasswordTooShort,
                    minLength: 6,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Password strength: $_passwordStrength',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _passwordStrengthColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  label: l10n.registerConfirmPasswordLabel,
                  hintText: l10n.registerConfirmPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) => AuthValidators.confirmPassword(
                    value,
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
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          l10n.registerAgreeTerms,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.registerCreateAccount,
                  leading: authState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onPressed: !_agreeToTerms || authState.isLoading
                      ? null
                      : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          if (_selectedGender == null) {
                            setState(() {
                              _genderError = 'Please select your gender';
                            });
                            return;
                          }
                          final user = User(
                            userId: 0,
                            username: _usernameController.text.trim(),
                            passwordHash: _passwordController.text.trim(),
                            fullname: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            phone: _phoneController.text.trim(),
                            address: _addressController.text.trim(),
                            role: 'customer',
                            country: _countryController.text.trim(),
                            gender: _selectedGender,
                            createdAt: '',
                            updatedAt: '',
                            isActive: 1,
                          );
                          final success = await context
                              .read<AuthState>()
                              .register(user);
                          if (!mounted) return;
                          if (success) {
                            AppSnackBar.show(
                              context,
                              message: 'Registration successful.',
                              type: AppSnackBarType.success,
                            );
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                            return;
                          }
                          final message =
                              authState.errorMessage ??
                              'Registration failed. Please try again.';
                          AppSnackBar.show(
                            context,
                            message: message,
                            type: AppSnackBarType.error,
                          );
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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
