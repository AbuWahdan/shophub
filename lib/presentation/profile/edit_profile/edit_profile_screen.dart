import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/presentation/profile/edit_profile/widgets/gender_selector_section.dart';
import 'package:sinwar_shoping/presentation/profile/edit_profile/widgets/read_only_profile_field.dart';
import '../../../../models/get_code_option_model.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../repositories/codes_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_text_field/custom_text_field.dart';
import '../../../core/state/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ── Form ────────────────────────────────────────────────────────────────────
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // ── Dependencies ────────────────────────────────────────────────────────────
  late final ProfileRepository _profileRepository;
  late final CodesRepository _codesRepository;

  // ── Gender ───────────────────────────────────────────────────────────────────
  int? _selectedGender;
  List<GetCodeOptionModel> _genderOptions = const [];
  bool _isLoadingGender = false;
  String? _genderLoadError;
  String? _genderValidationError;

  // ── Submission ───────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  String? _submissionError;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _profileRepository = Get.find<ProfileRepository>();
    _codesRepository = Get.find<CodesRepository>();
    _prefillFromCurrentUser();
    _loadGenderOptions();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  void _prefillFromCurrentUser() {
    final user = context.read<AuthState>().user;
    _fullNameController.text = user?.fullname ?? '';
    _phoneController.text = user?.phone ?? '';
    _selectedGender = user?.gender;
  }

  Future<void> _loadGenderOptions({bool forceRefresh = false}) async {
    setState(() {
      _isLoadingGender = true;
      _genderLoadError = null;
    });
    try {
      final options = await _codesRepository.getCodes(
        majorCode: GetCodeOptionModel.genderMajorCode,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() => _genderOptions = options);
    } catch (error) {
      if (!mounted) return;
      setState(() => _genderLoadError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingGender = false);
    }
  }

  Future<void> _onRefresh() => _loadGenderOptions(forceRefresh: true);

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    if (_selectedGender == null) {
      setState(() => _genderValidationError = 'Please select your gender');
      return;
    }

    final authState = context.read<AuthState>();
    final currentUser = authState.user;
    final username = currentUser?.username.trim() ?? '';

    if (currentUser == null || username.isEmpty) {
      setState(() => _submissionError = 'Unable to resolve the current user.');
      return;
    }

    final resolvedUserId =
    currentUser.userId > 0 ? currentUser.userId : authState.userId;
    if (resolvedUserId <= 0) {
      setState(() => _submissionError = 'Unable to resolve the current user id.');
      return;
    }

    final updatedUser = currentUser.copyWith(
      userId: resolvedUserId,
      fullname: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
    );

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
      _genderValidationError = null;
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
      setState(() => _submissionError = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
                  // ── Read-only: Username
                  ReadOnlyProfileField(
                    label: 'Username',
                    value: user?.username ?? '',
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Editable: Full Name
                  CustomTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    validator: (value) {
                      if ((value?.trim() ?? '').isEmpty) {
                        return 'Full name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Read-only: Email
                  ReadOnlyProfileField(
                    label: 'Email',
                    value: user?.email ?? '',
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Editable: Phone
                  CustomTextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    label: 'Phone',
                    hintText: 'Enter your phone number',
                    validator: (value) {
                      if ((value?.trim() ?? '').isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Read-only: Country (fixed to Jordan)
                  ReadOnlyProfileField(
                    label: 'Country',
                    value: 'Jordan',
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Gender selector
                  Text('Gender', style: AppTextStyles.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  GenderSelectorSection(
                    options: _genderOptions,
                    selectedGender: _selectedGender,
                    isLoading: _isLoadingGender,
                    loadError: _genderLoadError,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _genderValidationError = null;
                      });
                    },
                    onRetry: () => _loadGenderOptions(forceRefresh: true),
                  ),
                  if (_genderValidationError != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _genderValidationError!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ],

                  // ── Submission error
                  if (_submissionError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _submissionError!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),

                  // ── Save button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Save Changes',
                      leading: _isSubmitting
                          ? const SizedBox(
                        width: AppSpacing.iconSm,
                        height: AppSpacing.iconSm,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : null,
                      onPressed: _isSubmitting ? null : _submit,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}