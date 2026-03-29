import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/address_controller.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../data/domain_models/address_entity.dart';
import '../l10n/l10n.dart';
import '../model/delivery_location.dart';
import '../shared/widgets/app_snackbar.dart';
import '../state/auth_state.dart';
import '../themes/theme.dart';
import 'map_picker_screen.dart';

class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({super.key});

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  late final AddressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AddressController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoad();
    });
  }

  Future<void> _initializeAndLoad() async {
    final auth = context.read<AuthState>();
    await auth.ensureInitialized();
    if (!mounted) return;

    if (auth.isLoggedIn && auth.user != null) {
      _controller.username = auth.user!.username.trim();
      await _controller.loadAddresses();
    }
  }

  Future<void> _refreshAddresses() async {
    await _controller.loadAddresses(forceRefresh: true);
  }

  Future<void> _openAddAddressFlow() async {
    final pickedAddress = await Navigator.push<DeliveryLocation>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );

    if (pickedAddress == null || !mounted) {
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddressDetailsDialog(
        controller: _controller,
        username: _controller.username,
        pickedAddress: pickedAddress,
      ),
    );

    if (saved == true && mounted) {
      AppSnackBar.show(
        context,
        message: context.l10n.addressesSaved,
        type: AppSnackBarType.success,
      );
    }
  }

  Future<void> _openEditAddress(AddressEntity address) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddressDetailsDialog(
        controller: _controller,
        username: _controller.username,
        initialAddress: address,
        pickedAddress: DeliveryLocation(
          label: address.streetAddress,
          addressId: address.addressId?.toString(),
          lat: address.latitude,
          lng: address.longitude,
        ),
      ),
    );

    if (saved == true && mounted) {
      AppSnackBar.show(
        context,
        message: context.l10n.addressesSaved,
        type: AppSnackBarType.success,
      );
    }
  }

  Future<void> _deleteAddress(AddressEntity address) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.addressesDeleteTitle),
        content: Text(context.l10n.addressesDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );

    if (shouldDelete != true || address.addressId == null) {
      return;
    }

    try {
      await _controller.deleteAddress(address.addressId!);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: context.l10n.addressesDeleted,
        type: AppSnackBarType.success,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: error.toString(),
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _setDefaultAddress(AddressEntity address) async {
    if (address.addressId == null) {
      return;
    }

    try {
      await _controller.setDefaultAddress(address.addressId!);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Default address updated',
        type: AppSnackBarType.success,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: error.toString(),
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final isLoggedIn = auth.isLoggedIn && auth.user != null;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addressesTitle)),
      body: !isLoggedIn
          ? const Center(
              child: Text('Please log in to manage your delivery addresses'),
            )
          : Obx(() {
              final addresses = _controller.addresses;
              final errorMessage = _controller.error.value.trim();

              if (_controller.isLoading.value && addresses.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (errorMessage.isNotEmpty && addresses.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refreshAddresses,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 520,
                        child: EmptyStateWidget(
                          icon: Icons.error_outline,
                          title: 'Unable to load addresses',
                          subtitle: errorMessage,
                          action: ElevatedButton.icon(
                            onPressed: _refreshAddresses,
                            icon: const Icon(Icons.refresh),
                            label: Text(context.l10n.retry),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (addresses.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refreshAddresses,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 520,
                        child: EmptyStateWidget(
                          icon: Icons.location_off_outlined,
                          title: 'No saved addresses',
                          subtitle:
                              'Tap the + button to add your first delivery address',
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshAddresses,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppTheme.padding,
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return _AddressCard(
                      address: address,
                      onEdit: () => _openEditAddress(address),
                      onDelete: () => _deleteAddress(address),
                      onSetDefault: address.isDefault
                          ? null
                          : () => _setDefaultAddress(address),
                    );
                  },
                ),
              );
            }),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              onPressed: _openAddAddressFlow,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    this.onSetDefault,
  });

  final AddressEntity address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppTheme.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        address.streetAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${address.city}, ${address.state} ${address.zipCode}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        address.country,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        address.phone,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      context.l10n.addressesDefault,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'default':
                        onSetDefault?.call();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(context.l10n.commonEdit),
                    ),
                    if (onSetDefault != null)
                      PopupMenuItem(
                        value: 'default',
                        child: Text(context.l10n.addressesSetDefault),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(context.l10n.commonDelete),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressDetailsDialog extends StatefulWidget {
  const _AddressDetailsDialog({
    required this.controller,
    required this.username,
    this.initialAddress,
    this.pickedAddress,
  });

  final AddressController controller;
  final String username;
  final AddressEntity? initialAddress;
  final DeliveryLocation? pickedAddress;

  @override
  State<_AddressDetailsDialog> createState() => _AddressDetailsDialogState();
}

class _AddressDetailsDialogState extends State<_AddressDetailsDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _zipController;
  late final TextEditingController _phoneController;

  bool _isDefault = false;
  bool _isSaving = false;
  String? _errorMessage;

  double? get _latitude =>
      widget.initialAddress?.latitude ?? widget.pickedAddress?.lat;

  double? get _longitude =>
      widget.initialAddress?.longitude ?? widget.pickedAddress?.lng;

  @override
  void initState() {
    super.initState();
    final address = widget.initialAddress;
    _labelController = TextEditingController(text: address?.label ?? '');
    _streetController = TextEditingController(
      text: address?.streetAddress ?? widget.pickedAddress?.label ?? '',
    );
    _cityController = TextEditingController(text: address?.city ?? '');
    _stateController = TextEditingController(text: address?.state ?? '');
    _countryController = TextEditingController(text: address?.country ?? '');
    _zipController = TextEditingController(text: address?.zipCode ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (widget.username.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Account details are not available.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final address = AddressEntity(
      addressId: widget.initialAddress?.addressId,
      username: widget.username.trim(),
      label: _labelController.text.trim(),
      streetAddress: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      zipCode: _zipController.text.trim(),
      phone: _phoneController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
    );

    try {
      if (widget.initialAddress == null) {
        await widget.controller.addAddress(address);
      } else {
        await widget.controller.updateAddress(address);
      }
      await widget.controller.loadAddresses(forceRefresh: true);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialAddress != null;

    return AlertDialog(
      title: Text(
        isEditing
            ? context.l10n.addressesEditTitle
            : context.l10n.addressesAddTitle,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RequiredTextField(
                  controller: _labelController,
                  label: context.l10n.addressesNameLabel,
                ),
                const SizedBox(height: AppSpacing.md),
                _RequiredTextField(
                  controller: _streetController,
                  label: context.l10n.addressesStreetLabel,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                _RequiredTextField(
                  controller: _cityController,
                  label: context.l10n.addressesCityLabel,
                ),
                const SizedBox(height: AppSpacing.md),
                _RequiredTextField(
                  controller: _stateController,
                  label: context.l10n.addressesStateLabel,
                ),
                const SizedBox(height: AppSpacing.md),
                _RequiredTextField(
                  controller: _countryController,
                  label: context.l10n.addressesCountryLabel,
                ),
                const SizedBox(height: AppSpacing.md),
                _RequiredTextField(
                  controller: _zipController,
                  label: context.l10n.addressesZipLabel,
                ),
                const SizedBox(height: AppSpacing.md),
                _RequiredTextField(
                  controller: _phoneController,
                  label: context.l10n.addressesPhoneLabel,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  initialValue: _latitude != null && _longitude != null
                      ? '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'
                      : 'Not set',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Coordinates',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.addressesSetDefault),
                  value: _isDefault,
                  onChanged: (value) => setState(() => _isDefault = value),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.commonSave),
        ),
      ],
    );
  }
}

class _RequiredTextField extends StatelessWidget {
  const _RequiredTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}
