import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/address.dart';
import '../model/data.dart';
import '../shared/dialogs/app_dialogs.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_text_field.dart';
import '../themes/theme.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  late List<Address> addresses;

  @override
  void initState() {
    super.initState();
    addresses = List.from(AppData.addressList);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addressesTitle)),
      body: ListView.builder(
        padding: AppTheme.padding,
        itemCount: addresses.length + 1,
        itemBuilder: (context, index) {
          if (index == addresses.length) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: AppButton(
                onPressed: () => _showAddressForm(context),
                label: l10n.addressesAddNew,
                leading: const Icon(Icons.add),
              ),
            );
          }

          final address = addresses[index];
          return _buildAddressCard(context, address, index);
        },
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: AppSpacing.insetsLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.name,
                        style: AppTextStyles.titleSmall(context),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        address.street,
                        style: AppTextStyles.bodySmall(context),
                      ),
                      Text(
                        '${address.city}, ${address.state} ${address.zipCode}',
                        style: AppTextStyles.bodySmall(context),
                      ),
                    ],
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: AppSpacing.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      context.l10n.addressesDefault,
                      style: AppTextStyles.labelSmall(context)
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              address.phone,
              style: AppTextStyles.bodySmall(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: () => _setDefault(index),
                    child: Text(context.l10n.addressesSetDefault),
                  ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: () => _editAddress(context, index),
                  child: Text(context.l10n.commonEdit),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: () => _deleteAddress(index),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  child: Text(context.l10n.commonDelete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setDefault(int index) {
    setState(() {
      for (var addr in addresses) {
        addr.isDefault = false;
      }
      addresses[index].isDefault = true;
    });
  }

  void _deleteAddress(int index) {
    final l10n = context.l10n;
    AppDialogs.showConfirmation(
      context: context,
      title: l10n.addressesDeleteTitle,
      message: l10n.addressesDeleteMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      onConfirm: () {
        setState(() {
          addresses.removeAt(index);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addressesDeleted)));
      },
    );
  }

  void _editAddress(BuildContext context, int index) {
    _showAddressForm(context, address: addresses[index], index: index);
  }

  void _showAddressForm(BuildContext context, {Address? address, int? index}) {
    AppDialogs.showCustom(
      context: context,
      builder: (context) => AddressFormDialog(
        address: address,
        onSave: (newAddress) {
          setState(() {
            if (index != null) {
              addresses[index] = newAddress;
            } else {
              addresses.add(newAddress);
            }
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(content: Text(context.l10n.addressesSaved)),
          );
        },
      ),
    );
  }
}

class AddressFormDialog extends StatefulWidget {
  final Address? address;
  final Function(Address) onSave;

  const AddressFormDialog({super.key, this.address, required this.onSave});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipController;
  late TextEditingController countryController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.address?.name ?? '');
    phoneController = TextEditingController(text: widget.address?.phone ?? '');
    streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    cityController = TextEditingController(text: widget.address?.city ?? '');
    stateController = TextEditingController(text: widget.address?.state ?? '');
    zipController = TextEditingController(text: widget.address?.zipCode ?? '');
    countryController = TextEditingController(
      text: widget.address?.country ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(
        widget.address == null ? l10n.addressesAddTitle : l10n.addressesEditTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameController,
              label: l10n.addressesNameLabel,
              hintText: l10n.addressesNameHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: phoneController,
              label: l10n.addressesPhoneLabel,
              hintText: l10n.addressesPhoneHint,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: streetController,
              label: l10n.addressesStreetLabel,
              hintText: l10n.addressesStreetHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: cityController,
              label: l10n.addressesCityLabel,
              hintText: l10n.addressesCityHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: stateController,
              label: l10n.addressesStateLabel,
              hintText: l10n.addressesStateHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: zipController,
              label: l10n.addressesZipLabel,
              hintText: l10n.addressesZipHint,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: countryController,
              label: l10n.addressesCountryLabel,
              hintText: l10n.addressesCountryHint,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        AppButton(
          label: l10n.commonSave,
          onPressed: _saveAddress,
          fullWidth: false,
        ),
      ],
    );
  }

  void _saveAddress() {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        streetController.text.isEmpty ||
        cityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.addressesFillAll)));
      return;
    }

    final newAddress = Address(
      id: widget.address?.id ?? DateTime.now().toString(),
      name: nameController.text,
      phone: phoneController.text,
      street: streetController.text,
      city: cityController.text,
      state: stateController.text,
      zipCode: zipController.text,
      country: countryController.text,
      isDefault: widget.address?.isDefault ?? false,
    );

    widget.onSave(newAddress);
  }
}
