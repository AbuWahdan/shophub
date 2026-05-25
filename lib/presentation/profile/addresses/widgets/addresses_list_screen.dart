import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/address_controller.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/addresses/address_model.dart';
import '../../../../models/addresses/map_picker_result_model.dart';
import '../../../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../mapbox_address_picker_screen.dart';
import 'saved_addresses/add_address_button.dart';
import 'saved_addresses/address_card.dart';
import 'saved_addresses/address_header.dart';
import 'saved_addresses/address_modal_sheet.dart';
import 'saved_addresses/address_search_bar.dart';

class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({super.key});

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  late final AddressController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AddressController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndLoad());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _refresh() => _controller.loadAddresses(forceRefresh: true);

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

  Future<void> _showAddressSheet({
    AddressModel? existing,
    MapPickerResultModel? mapResult,
  }) async {
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthState>();
    final username = auth.user?.username.trim() ?? _controller.username.trim();

    if (username.isEmpty) {
      CustomSnackBar.show(
        context,
        message: l10n.addressesLoginRequired,
        type: AppSnackBarType.error,
      );
      return;
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressModalSheet(
        controller: _controller,
        username: username,
        initialAddress: existing,
        initialMapResult: mapResult,
        fallbackPhone: auth.user?.phone ?? '',
        fallbackCountry: auth.user?.country ?? l10n.addressesFallbackCountry,
        onOpenMapPicker: () => _openMapPicker(existing: existing),
      ),
    );

    if (saved == true && mounted) {
      CustomSnackBar.show(
        context,
        message: existing == null
            ? l10n.addressesAdded
            : l10n.notificationAddressUpdateSuccess,
        type: AppSnackBarType.success,
      );
    }
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.addressesDeleteTitle),
        content: Text(l10n.addressesDeleteMessage(address.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _controller.deleteAddress(address.addressId!);
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: l10n.addressesDeleted,
          type: AppSnackBarType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: _controller.error.value,
          type: AppSnackBarType.error,
        );
      }
    }
  }

  List<AddressModel> _filterAddresses(List<AddressModel> addresses) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return addresses;
    return addresses.where((address) {
      final haystack = [
        address.label,
        address.streetAddress,
        address.city,
        address.state,
        address.country,
        address.zipCode,
        address.phone,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthState>();
    final isLoggedIn = auth.isLoggedIn && auth.user != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AddressHeader(
            title: l10n.savedAddressesTitle,
            onBack: () => Navigator.maybePop(context),
            onSettings: () {},
            settingsSemanticLabel: l10n.addressesSettingsLabel,
          ),
          Expanded(
            child: !isLoggedIn
                ? _RefreshableMessage(
                    onRefresh: _refresh,
                    message: l10n.addressesLoginRequired,
                  )
                : Obx(() {
                    final addresses = _filterAddresses(
                      _controller.addresses.toList(),
                    );
                    final isLoading = _controller.isLoading.value;

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: AddressSearchBar(
                              controller: _searchController,
                              hintText: l10n.searchSavedAddressesHint,
                              onChanged: (value) =>
                                  setState(() => _query = value),
                            ),
                          ),
                          if (isLoading && addresses.isEmpty)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (addresses.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Text(
                                    l10n.noSavedAddresses,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.sm,
                                AppSpacing.md,
                                AppSpacing.xxxl + AppSpacing.xl,
                              ),
                              sliver: SliverList.separated(
                                itemCount: addresses.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: AppSpacing.md),
                                itemBuilder: (_, index) {
                                  final address = addresses[index];
                                  return AddressCard(
                                    address: address,
                                    isActive:
                                        address.isDefault == 1 ||
                                        _controller.selectedAddressId.value ==
                                            address.addressId,
                                    onEdit: () =>
                                        _showAddressSheet(existing: address),
                                    onDelete: () => _deleteAddress(address),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
          ),
        ],
      ),
      bottomNavigationBar: isLoggedIn
          ? AddAddressButton(
              label: l10n.addNewAddress,
              onPressed: () => _showAddressSheet(),
            )
          : null,
    );
  }
}

class _RefreshableMessage extends StatelessWidget {
  const _RefreshableMessage({required this.onRefresh, required this.message});

  final RefreshCallback onRefresh;
  final String message;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(child: Text(message, textAlign: TextAlign.center)),
          ),
        ],
      ),
    );
  }
}
