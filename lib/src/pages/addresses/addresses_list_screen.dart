import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../controllers/address_controller.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../model/address_model.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../state/auth_state.dart';
import '../../themes/theme.dart';
import 'map_picker_result.dart';
import 'mapbox_address_picker_screen.dart';

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

  // ── FAB bottom sheet ───────────────────────────────────────────────────────

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
              onTap: () {
                Navigator.pop(context);
                _showAddressDialog(openMapPickerOnStart: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_location_alt_outlined),
              title: const Text('Enter address manually'),
              onTap: () {
                Navigator.pop(context);
                _showAddressDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<MapPickerResult?> _openMapPicker({
    AddressModel? existing,
  }) async {
    return Navigator.of(context).push<MapPickerResult>(
      MaterialPageRoute(
        builder: (_) => MapboxAddressPickerScreen(
          initialLatitude: existing?.latitude,
          initialLongitude: existing?.longitude,
        ),
      ),
    );
  }

  // ── Add / Edit dialog ──────────────────────────────────────────────────────

  Future<void> _showAddressDialog({
    AddressModel? existing,
    double? latitude,
    double? longitude,
    bool openMapPickerOnStart = false,
  }) async {
    final auth = context.read<AuthState>();
    final username = auth.user?.username.trim() ?? _controller.username.trim();
    if (username.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please log in to manage addresses.',
        type: AppSnackBarType.error,
      );
      return;
    }

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddressDialog(
        controller: _controller,
        username: username,
        initialAddress: existing,
        initialLatitude: latitude ?? existing?.latitude,
        initialLongitude: longitude ?? existing?.longitude,
        fallbackPhone: auth.user?.phone ?? '',
        fallbackCountry: auth.user?.country ?? 'Jordan',
        onOpenMapPicker: () => _openMapPicker(existing: existing),
        openMapPickerOnStart: openMapPickerOnStart,
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

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _deleteAddress(AddressModel address) async {
    final id = address.addressId;
    if (id == null || id <= 0) {
      AppSnackBar.show(
        context,
        message: 'Cannot delete: address has no ID.',
        type: AppSnackBarType.error,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete address'),
        content: Text('Delete "${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _controller.deleteAddress(id);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Address deleted',
        type: AppSnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: _controller.error.value,
        type: AppSnackBarType.error,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final isLoggedIn = auth.isLoggedIn && auth.user != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
        onPressed: _showAddOptions,
        child: const Icon(Icons.add),
      )
          : null,
      body: !isLoggedIn
          ? const Center(child: Text('Please log in to manage addresses'))
          : Obx(() {
        final list = _controller.addresses.toList();
        final err = _controller.error.value.trim();

        // Loading spinner (only when list is empty — avoids flicker on refresh)
        if (_controller.isLoading.value && list.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (err.isNotEmpty && list.isEmpty) {
          return _centeredRefreshable(
            child: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Unable to load addresses',
              subtitle: err,
              action: ElevatedButton.icon(
                onPressed: () =>
                    _controller.loadAddresses(forceRefresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          );
        }

        // Empty state
        if (list.isEmpty) {
          return _centeredRefreshable(
            child: const EmptyStateWidget(
              icon: Icons.location_off_outlined,
              title: 'No saved addresses',
              subtitle: 'Tap + to add your first delivery address',
            ),
          );
        }

        // Address list
        return RefreshIndicator(
          onRefresh: () =>
              _controller.loadAddresses(forceRefresh: true),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppTheme.padding,
            itemCount: list.length,
            separatorBuilder: (_, _) =>
            const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, index) {
              final address = list[index];
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

  Widget _centeredRefreshable({required Widget child}) {
    return RefreshIndicator(
      onRefresh: () => _controller.loadAddresses(forceRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: 520, child: child)],
      ),
    );
  }
}

// ── Address Card ──────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final details = [
      address.streetAddress,
      address.city,
      address.state,
      address.country,
      address.zipCode,
    ].where((s) => s.trim().isNotEmpty).join(', ');

    final hasCoords =
        address.latitude != null && address.longitude != null;

    return Card(
      child: Padding(
        padding: AppTheme.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label row
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.label.isNotEmpty ? address.label : '—',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (address.isDefault == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      'Default',
                      style:
                      Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),

            // Address details
            if (details.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(details,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],

            // Phone
            if (address.phone.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(address.phone,
                  style: Theme.of(context).textTheme.bodySmall),
            ],

            // Coordinates
            if (hasCoords) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${address.latitude!.toStringAsFixed(5)}, '
                    '${address.longitude!.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.xs),

            // Action buttons
            Row(
              children: [
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add / Edit Dialog ─────────────────────────────────────────────────────────

class _AddressDialog extends StatefulWidget {
  const _AddressDialog({
    required this.controller,
    required this.username,
    required this.fallbackPhone,
    required this.fallbackCountry,
    required this.onOpenMapPicker,
    this.openMapPickerOnStart = false,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
  });

  final AddressController controller;
  final String username;
  final String fallbackPhone;
  final String fallbackCountry;
  final Future<MapPickerResult?> Function() onOpenMapPicker;
  final bool openMapPickerOnStart;
  final AddressModel? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _label;
  late final TextEditingController _street;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _country;
  late final TextEditingController _zip;
  late final TextEditingController _phone;

  double? _latitude;
  double? _longitude;
  String? _pickedAddress;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.initialAddress != null;

  /// True when coordinates are available (from map picker or existing address)
  bool get _hasCoords => _latitude != null && _longitude != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAddress;
    _label = TextEditingController(text: a?.label ?? '');
    _street = TextEditingController(text: a?.streetAddress ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _state = TextEditingController(text: a?.state ?? '');
    _country = TextEditingController(
      text: a?.country.isNotEmpty == true
          ? a!.country
          : widget.fallbackCountry,
    );
    _zip = TextEditingController(text: a?.zipCode ?? '');
    _phone = TextEditingController(
      text: a?.phone.isNotEmpty == true ? a!.phone : widget.fallbackPhone,
    );
    _latitude = widget.initialLatitude ?? a?.latitude;
    _longitude = widget.initialLongitude ?? a?.longitude;
    _pickedAddress = a?.streetAddress;

    if (widget.openMapPickerOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickLocationOnMap();
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_label, _street, _city, _state, _country, _zip, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  // Fields are required when there are no coordinates
  String? _required(String fieldName, String? value) {
    if (_hasCoords) return null; // coords make manual fields optional
    if ((value ?? '').trim().isEmpty) return 'Please enter $fieldName';
    return null;
  }

  Future<void> _pickLocationOnMap() async {
    if (_saving) return;

    final result = await widget.onOpenMapPicker();
    if (!mounted || result == null) return;

    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      _pickedAddress = result.address.trim();
      _error = null;
      if (_street.text.trim().isEmpty && _pickedAddress!.isNotEmpty) {
        _street.text = _pickedAddress!;
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_label.text.trim().isEmpty) {
      setState(() => _error = 'Label is required.');
      return;
    }

    if (!_hasCoords &&
        _street.text.trim().isEmpty &&
        _city.text.trim().isEmpty) {
      setState(() => _error = 'Enter an address or pick a location on the map.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final address = AddressModel(
      addressId: widget.initialAddress?.addressId,
      username: widget.username,
      label: _label.text.trim(),
      streetAddress: _street.text.trim().isNotEmpty
          ? _street.text.trim()
          : (_pickedAddress ?? ''),
      city: _city.text.trim(),
      state: _state.text.trim(),
      country: _country.text.trim(),
      zipCode: _zip.text.trim(),
      phone: _phone.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      isDefault: widget.initialAddress?.isDefault ?? 0,
    );

    try {
      if (_isEditing) {
        await widget.controller.updateAddress(address);
      } else {
        await widget.controller.addAddress(address);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = widget.controller.error.value.isNotEmpty
            ? widget.controller.error.value
            : e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Address' : 'New Address'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_label, 'Label (e.g. Home)',
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'Label is required'
                        : null),
                _gap,
                _field(_street, 'Street Address',
                    maxLines: 2,
                    validator: (v) => _required('a street address', v)),
                _gap,
                _field(_city, 'City',
                    validator: (v) => _required('a city', v)),
                _gap,
                _field(_state, 'State / Province',
                    validator: (v) => _required('a state', v)),
                _gap,
                _field(_country, 'Country',
                    validator: (v) => _required('a country', v)),
                _gap,
                _field(_zip, 'ZIP / Postal Code',
                    validator: (v) => _required('a zip code', v)),
                _gap,
                _field(_phone, 'Phone Number',
                    keyboardType: TextInputType.phone),
                _gap,
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _pickLocationOnMap,
                    icon: const Icon(Icons.map_outlined),
                    label: Text(
                      _hasCoords
                          ? 'Change location on map'
                          : 'Pick location on map',
                    ),
                  ),
                ),
                _gap,

                // Coordinates display (read-only)
                TextFormField(
                  initialValue: _hasCoords
                      ? '${_latitude!.toStringAsFixed(5)}, '
                      '${_longitude!.toStringAsFixed(5)}'
                      : 'Not set',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Coordinates',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                if ((_pickedAddress ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _pickedAddress!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
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
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(_isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  Widget get _gap => const SizedBox(height: AppSpacing.md);

  Widget _field(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
