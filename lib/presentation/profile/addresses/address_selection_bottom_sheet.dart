import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../models/address_model.dart';
import '../../../core/app/app_theme.dart';


class AddressSelectionBottomSheet extends StatelessWidget {
  final List<AddressModel> savedAddresses;
  final int? selectedAddressId;
  final ValueChanged<AddressModel> onAddressSelected;
  final VoidCallback onAddNewAddress;

  const AddressSelectionBottomSheet({
    super.key,
    required this.savedAddresses,
    required this.selectedAddressId,
    required this.onAddressSelected,
    required this.onAddNewAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppTheme.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text('Select Delivery Address', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.lg),
              if (savedAddresses.isEmpty)
                EmptyStateWidget(
                  icon: Icons.location_off_outlined,
                  title: 'No saved addresses',
                  subtitle: 'Add a new address to continue with checkout.',
                  action: ElevatedButton.icon(
                    onPressed: onAddNewAddress,
                    icon: const Icon(Icons.add),
                    label: const Text('Add new address'),
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...savedAddresses.map(
                        (address) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            onAddressSelected(address);
                            Navigator.of(context).pop();
                          },
                          leading: Radio<int>(
                            value: address.addressId ?? -1,
                            groupValue: selectedAddressId,
                            onChanged: (_) {
                              onAddressSelected(address);
                              Navigator.of(context).pop();
                            },
                          ),
                          title: Text(address.label),
                          subtitle: Text(
                            [
                                  address.streetAddress,
                                  address.city,
                                  address.country,
                                ]
                                .where((value) => value.trim().isNotEmpty)
                                .join(', '),
                          ),
                        ),
                      ),
                      const Divider(height: AppSpacing.xl),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: onAddNewAddress,
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text('Add new address'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
