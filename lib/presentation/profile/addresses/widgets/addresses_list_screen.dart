import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/address_controller.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/addresses/address_model.dart';
import '../../../../models/addresses/map_picker_result_model.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../../../widgets/widgets/app_snackbar.dart';
import '../../../../widgets/widgets/custom_fab/custom_fab.dart';
import '../mapbox_address_picker_screen.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const double _kDialogMaxWidth = 420.0;

// ── Screen ────────────────────────────────────────────────────────────────────

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndLoad());
  }

  Future<void> _initAndLoad() async {
    final auth = context.read<AuthState>();
    await auth.ensureInitialized();
    if (!mounted) return;

    final username = auth.user?.username.trim() ?? '';
    if (username.isEmpty) return;

    _controller.username = username;
    await _controller.loadAddresses(forceRefresh: true);
  }

  // ── Navigation Flow Fix ────────────────────────────────────────────────────

  Future<void> _showAddOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Set location on map'),
              onTap: () async {
                Navigator.pop(context); // Close sheet
                // 🔥 STEP 1: Open map first
                final result = await _openMapPicker();
                // 🔥 STEP 2: Only open dialog if we got a result
                if (result != null && mounted) {
                  _showAddressDialog(mapResult: result);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_location_alt_outlined),
              title: const Text('Enter address manually'),
              onTap: () {
                Navigator.pop(context); // Close sheet
                _showAddressDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<MapPickerResultModel?> _openMapPicker({AddressModel? existing}) {
    return Navigator.of(context).push<MapPickerResultModel>(
      MaterialPageRoute(
        builder: (_) => MapboxAddressPickerScreen(
          initialLatitude: existing?.latitude,
          initialLongitude: existing?.longitude,
        ),
      ),
    );
  }

  Future<void> _showAddressDialog({
    AddressModel? existing,
    MapPickerResultModel? mapResult, // New parameter to catch map data
  }) async {
    final auth = context.read<AuthState>();
    final username = auth.user?.username.trim() ?? _controller.username.trim();

    if (username.isEmpty) {
      AppSnackBar.show(context, message: 'Please log in to manage addresses.', type: AppSnackBarType.error);
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddressFormDialog(
        controller: _controller,
        username: username,
        initialAddress: existing,
        initialMapResult: mapResult, // Pass it down
        fallbackPhone: auth.user?.phone ?? '',
        fallbackCountry: auth.user?.country ?? 'Jordan',
        onOpenMapPicker: () => _openMapPicker(existing: existing),
      ),
    );

    if (saved == true && mounted) {
      AppSnackBar.show(
        context,
        message: existing == null ? 'Address added' : 'Address updated',
        type: AppSnackBarType.success,
      );
    }
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete address'),
        content: Text('Delete "${address.label}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _controller.deleteAddress(address.addressId!);
      if (mounted) AppSnackBar.show(context, message: 'Address deleted', type: AppSnackBarType.success);
    } catch (_) {
      if (mounted) AppSnackBar.show(context, message: _controller.error.value, type: AppSnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final isLoggedIn = auth.isLoggedIn && auth.user != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      floatingActionButton: isLoggedIn
          ? CustomFab(
        onPressed: _showAddOptions,
        icon: Icons.add,
        tooltip: 'Add Address',
      )
          : null,
      body: !isLoggedIn
          ? const Center(child: Text('Please log in to manage addresses'))
          : Obx(() {
        final addresses = _controller.addresses.toList();
        if (_controller.isLoading.value && addresses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (addresses.isEmpty) {
          return _RefreshableCenter(
            onRefresh: () => _controller.loadAddresses(forceRefresh: true),
            child: const EmptyStateWidget(
              icon: Icons.location_off_outlined,
              title: 'No saved addresses',
              subtitle: 'Tap + to add your first delivery address',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _controller.loadAddresses(forceRefresh: true),
          child: ListView.separated(
            padding: AppSpacing.insetsMd,
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, index) {
              final address = addresses[index];
              return _AddressCard(
                address: address,
                onEdit: () => _showAddressDialog(existing: address),
                onDelete: () => _deleteAddress(address),
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Address Card UI ──────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onEdit, required this.onDelete});
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final details = [address.streetAddress, address.city, address.state, address.country]
        .where((s) => s.trim().isNotEmpty).join(', ');

    return Card(
      child: Padding(
        padding: AppSpacing.insetsMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(address.label, style: AppTextStyles.titleMedium)),
                if (address.isDefault == 1) _DefaultBadge(),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(details, style: AppTextStyles.bodyMedium),
            ],
            if (address.latitude != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('${address.latitude!.toStringAsFixed(5)}, ${address.longitude!.toStringAsFixed(5)}',
                  style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.secondary)),
            ],
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            Row(
              children: [
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline), color: Theme.of(context).colorScheme.error),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Address Form Dialog ───────────────────────────────────────────────────────

class _AddressFormDialog extends StatefulWidget {
  const _AddressFormDialog({
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
  State<_AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<_AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtrl, _streetCtrl, _cityCtrl, _stateCtrl, _countryCtrl, _zipCtrl, _phoneCtrl;
  double? _latitude;
  double? _longitude;
  bool _isSaving = false;
  String? _formError;

  bool get _hasCoords => _latitude != null && _longitude != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAddress;
    final m = widget.initialMapResult;

    _labelCtrl = TextEditingController(text: a?.label ?? '');
    // Prioritize map result for the street field if adding new via map
    _streetCtrl = TextEditingController(text: m?.address ?? a?.streetAddress ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? '');
    _stateCtrl = TextEditingController(text: a?.state ?? '');
    _countryCtrl = TextEditingController(text: a?.country ?? widget.fallbackCountry);
    _zipCtrl = TextEditingController(text: a?.zipCode ?? '');
    _phoneCtrl = TextEditingController(text: a?.phone ?? widget.fallbackPhone);

    _latitude = m?.latitude ?? a?.latitude;
    _longitude = m?.longitude ?? a?.longitude;
  }

  @override
  void dispose() {
    _labelCtrl.dispose(); _streetCtrl.dispose(); _cityCtrl.dispose();
    _stateCtrl.dispose(); _countryCtrl.dispose(); _zipCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  String _fieldLabel(String label) => _hasCoords ? '$label (optional)' : label;

  String? _validateRequired(String field, String? v) {
    if (_hasCoords) return null;
    return (v ?? '').trim().isEmpty ? 'Please enter $field' : null;
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
    setState(() { _isSaving = true; _formError = null; });

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
    } catch (e) {
      setState(() { _isSaving = false; _formError = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialAddress != null ? 'Edit Address' : 'New Address'),
      content: SizedBox(
        width: _kDialogMaxWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FormField(controller: _labelCtrl, label: 'Label', validator: (v) => v!.isEmpty ? 'Required' : null),
                const _FormGap(),
                _FormField(controller: _streetCtrl, label: _fieldLabel('Street'), maxLines: 2, validator: (v) => _validateRequired('street', v)),
                const _FormGap(),
                _FormField(controller: _cityCtrl, label: _fieldLabel('City'), validator: (v) => _validateRequired('city', v)),
                const _FormGap(),
                _FormField(controller: _stateCtrl, label: _fieldLabel('State'), validator: (v) => _validateRequired('state', v)),
                const _FormGap(),
                _FormField(controller: _countryCtrl, label: _fieldLabel('Country'), validator: (v) => _validateRequired('country', v)),
                const _FormGap(),
                _FormField(controller: _zipCtrl, label: _fieldLabel('Zip'), validator: (v) => _validateRequired('zip', v)),
                const _FormGap(),
                _FormField(controller: _phoneCtrl, label: 'Phone', keyboardType: TextInputType.phone),
                const _FormGap(),
                OutlinedButton.icon(onPressed: _pickOnMap, icon: const Icon(Icons.map_outlined), label: Text(_hasCoords ? 'Change location' : 'Pick on map')),
                if (_hasCoords) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}', style: AppTextStyles.bodySmall),
                ],
                if (_formError != null) Text(_formError!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? '...' : 'Save')),
      ],
    );
  }
}

// ── HELPERS ──────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({required this.controller, required this.label, this.maxLines = 1, this.keyboardType, this.validator});
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
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _FormGap extends StatelessWidget {
  const _FormGap();
  @override
  Widget build(BuildContext context) => const SizedBox(height: AppSpacing.md);
}

class _RefreshableCenter extends StatelessWidget {
  const _RefreshableCenter({required this.onRefresh, required this.child});
  final RefreshCallback onRefresh;
  final Widget child;
  @override
  Widget build(BuildContext context) => RefreshIndicator(onRefresh: onRefresh, child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [SizedBox(height: 520, child: child)]));
}

class _DefaultBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(h: AppSpacing.sm, v: AppSpacing.xs),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSpacing.sm)),
      child: Text('Default', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}