import 'package:flutter/material.dart';

import '../../../../../controllers/address_controller.dart';
import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../models/addresses/address_model.dart';
import '../../../../../models/addresses/map_picker_result_model.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({
    super.key,
    required this.controller,
    required this.username,
    required this.fallbackPhone,
    required this.fallbackCountry,
    required this.onOpenMapPicker,
    this.initialAddress,
    this.initialMapResult,
  });

  final AddressController controller;
  final String username;
  final String fallbackPhone;
  final String fallbackCountry;
  final Future<MapPickerResultModel?> Function() onOpenMapPicker;
  final AddressModel? initialAddress;
  final MapPickerResultModel? initialMapResult;

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _zipCtrl;
  late final TextEditingController _phoneCtrl;

  double? _latitude;
  double? _longitude;
  bool _isSaving = false;
  String? _formError;

  bool get _hasCoords => _latitude != null && _longitude != null;

  @override
  void initState() {
    super.initState();
    final address = widget.initialAddress;
    final mapResult = widget.initialMapResult;

    _labelCtrl = TextEditingController(text: address?.label ?? '');
    _streetCtrl = TextEditingController(
      text: mapResult?.address ?? address?.streetAddress ?? '',
    );
    _cityCtrl = TextEditingController(text: address?.city ?? '');
    _stateCtrl = TextEditingController(text: address?.state ?? '');
    _countryCtrl = TextEditingController(
      text: address?.country ?? widget.fallbackCountry,
    );
    _zipCtrl = TextEditingController(text: address?.zipCode ?? '');
    _phoneCtrl = TextEditingController(
      text: address?.phone ?? widget.fallbackPhone,
    );
    _latitude = mapResult?.latitude ?? address?.latitude;
    _longitude = mapResult?.longitude ?? address?.longitude;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _zipCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (_hasCoords) return null;
    return (value ?? '').trim().isEmpty
        ? AppLocalizations.of(context).notificationFieldRequired
        : null;
  }

  Future<void> _pickOnMap() async {
    final result = await widget.onOpenMapPicker();
    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _streetCtrl.text = result.address;
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSaving = true;
      _formError = null;
    });

    final address = AddressModel(
      addressId: widget.initialAddress?.addressId,
      username: widget.username,
      label: _labelCtrl.text.trim(),
      streetAddress: _streetCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      zipCode: _zipCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      isDefault: widget.initialAddress?.isDefault ?? 0,
    );

    try {
      if (widget.initialAddress != null) {
        await widget.controller.updateAddress(address);
      } else {
        await widget.controller.addAddress(address);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      setState(() {
        _isSaving = false;
        _formError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: _pickOnMap,
            icon: const Icon(Icons.my_location_outlined),
            label: Text(
              _hasCoords ? l10n.changeLocation : l10n.useCurrentLocation,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.buttonMd),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  l10n.orEnterManually,
                  style: AppTextStyles.labelSmall,
                ),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Field(
            controller: _labelCtrl,
            label: l10n.addressesNameLabel,
            validator: (value) => (value ?? '').trim().isEmpty
                ? l10n.notificationFieldRequired
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          _Field(
            controller: _streetCtrl,
            label: l10n.addressesStreetLabel,
            maxLines: 2,
            validator: _required,
          ),
          const SizedBox(height: AppSpacing.md),
          _TwoColumnFields(
            first: _Field(
              controller: _cityCtrl,
              label: l10n.addressesCityLabel,
              validator: _required,
            ),
            second: _Field(
              controller: _stateCtrl,
              label: l10n.addressesStateLabel,
              validator: _required,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _TwoColumnFields(
            first: _Field(
              controller: _countryCtrl,
              label: l10n.addressesCountryLabel,
              validator: _required,
            ),
            second: _Field(
              controller: _zipCtrl,
              label: l10n.addressesZipLabel,
              validator: _required,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Field(
            controller: _phoneCtrl,
            label: l10n.addressesPhoneLabel,
            keyboardType: TextInputType.phone,
          ),
          if (_formError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formError!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.buttonMd),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              textStyle: AppTextStyles.buttonLarge,
            ),
            child: Text(_isSaving ? l10n.savingLabel : l10n.commonSave),
          ),
        ],
      ),
    );
  }
}

class _TwoColumnFields extends StatelessWidget {
  const _TwoColumnFields({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              first,
              const SizedBox(height: AppSpacing.md),
              second,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.neutral100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
