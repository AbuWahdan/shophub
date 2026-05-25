import 'package:flutter/material.dart';

import '../../../../../controllers/address_controller.dart';
import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../models/addresses/address_model.dart';
import '../../../../../models/addresses/map_picker_result_model.dart';
import 'address_form.dart';

class AddressModalSheet extends StatelessWidget {
  const AddressModalSheet({
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
            ),
            children: [
              Center(
                child: Container(
                  width: AppSpacing.xxl,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                initialAddress == null
                    ? l10n.addressesAddTitle
                    : l10n.addressesEditTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              AddressForm(
                controller: controller,
                username: username,
                initialAddress: initialAddress,
                initialMapResult: initialMapResult,
                fallbackPhone: fallbackPhone,
                fallbackCountry: fallbackCountry,
                onOpenMapPicker: onOpenMapPicker,
              ),
            ],
          ),
        );
      },
    );
  }
}
