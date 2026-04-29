import 'package:flutter/material.dart';

import '../../../../core/app/app_theme.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/addresses/address_model.dart';
import '../../../../widgets/empty_state_widget.dart';

class AddressSelectionBottomSheet extends StatelessWidget {
  const AddressSelectionBottomSheet({
    super.key,
    required this.savedAddresses,
    required this.selectedAddressId,
    required this.onAddressSelected,
    required this.onAddNewAddress,
  });

  final List<AddressModel> savedAddresses;
  final int? selectedAddressId;
  final ValueChanged<AddressModel> onAddressSelected;
  final VoidCallback onAddNewAddress;

  Future<void> _handleAddNewAddress(BuildContext context) async {
    // Close bottom sheet FIRST
    Navigator.of(context).pop();

    // Wait one frame to avoid route transition conflicts
    await Future<void>.delayed(Duration.zero);

    onAddNewAddress();
  }

  void _handleAddressSelection(
      BuildContext context,
      AddressModel address,
      ) {
    onAddressSelected(address);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(
                    bottom: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // Title
              Text(
                'Select Delivery Address',
                style: AppTextStyles.titleMedium,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Empty state
              if (savedAddresses.isEmpty)
                EmptyStateWidget(
                  icon: Icons.location_off_outlined,
                  title: 'No saved addresses',
                  subtitle:
                  'Add a new address to continue with checkout.',
                  action: ElevatedButton.icon(
                    onPressed: () => _handleAddNewAddress(context),
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

                          onTap: () => _handleAddressSelection(
                            context,
                            address,
                          ),

                          leading: Radio<int>(
                            value: address.addressId ?? -1,
                            groupValue: selectedAddressId,
                            onChanged: (_) => _handleAddressSelection(
                              context,
                              address,
                            ),
                          ),

                          title: Text(address.label),

                          subtitle: Text(
                            [
                              address.streetAddress,
                              address.city,
                              address.country,
                            ]
                                .where(
                                  (value) => value.trim().isNotEmpty,
                            )
                                .join(', '),
                          ),
                        ),
                      ),

                      const Divider(height: AppSpacing.xl),

                      // Add new address
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => _handleAddNewAddress(context),
                        leading: const Icon(
                          Icons.add_circle_outline,
                        ),
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