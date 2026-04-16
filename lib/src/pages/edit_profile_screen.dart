import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/profile_repository.dart';
import '../design/app_text_styles.dart';
import '../state/auth_state.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_text_field.dart';
import '../themes/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  late final ProfileRepository _profileRepository;

  int? _selectedGender;
  bool _isSubmitting = false;
  String? _genderError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _profileRepository = Get.find<ProfileRepository>();
    final user = context.read<AuthState>().user;
    _fullNameController.text = user?.fullname ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
    _countryController.text = user?.country ?? '';
    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedGender == null) {
      setState(() {
        _genderError = 'Please select your gender';
      });
      return;
    }

    final authState = context.read<AuthState>();
    final currentUser = authState.user;
    final username = currentUser?.username.trim() ?? '';
    if (currentUser == null || username.isEmpty) {
      setState(() {
        _formError = 'Unable to resolve the current user.';
      });
      return;
    }
    final userId = currentUser.userId > 0
        ? currentUser.userId
        : authState.userId;
    if (userId <= 0) {
      setState(() {
        _formError = 'Unable to resolve the current user id.';
      });
      return;
    }
    final updatedUser = currentUser.copyWith(
      userId: userId,
      fullname: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _countryController.text.trim(),
      gender: _selectedGender,
    );

    setState(() {
      _isSubmitting = true;
      _formError = null;
      _genderError = null;
    });

    try {
      await _profileRepository.updateUser(
        updatedUser.copyWith(username: username, gender: _selectedGender!),
      );

      await authState.updateCurrentUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _formError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username', style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: AppSpacing.insetsMd,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    user?.username ?? '',
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Gender', style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          _genderError = null;
                        });
                      },
                    ),
                    const Text('Male'),
                    const SizedBox(width: 24),
                    Radio<int>(
                      value: 2,
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          _genderError = null;
                        });
                      },
                    ),
                    const Text('Female'),
                  ],
                ),
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
                  label: 'Email',
                  hintText: 'Enter your email',
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Email is required';
                    }
                    if (!trimmed.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  label: 'Phone',
                  hintText: 'Enter your phone number',
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _countryController,
                  label: 'Country',
                  hintText: 'Enter your country',
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Country is required';
                    }
                    return null;
                  },
                ),
                if (_formError != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _formError!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: 'Save Changes',
                    leading: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    onPressed: _isSubmitting ? null : _submit,
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
