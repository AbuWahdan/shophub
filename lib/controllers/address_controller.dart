import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/repositories/address_repository.dart';
import '../models/addresses/address_model.dart';

/// GetX controller for all address operations.
/// Uses [AddressModel] exclusively — there is no AddressEntity in this project.
/// After every mutation (add/update/delete) it reloads from the server so the
/// list always reflects the real database state, including the server-assigned
/// ADDRESS_ID that APEX may not echo back in the write response.
class AddressController extends GetxController {
  final AddressRepository _repository;

  AddressController(this._repository);

  // ── Observable state ───────────────────────────────────────────────────────
  final addresses = <AddressModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final selectedAddressId = Rx<int?>(null);

  /// Must be set before calling [loadAddresses].
  String username = '';

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<void> loadAddresses({bool forceRefresh = false}) async {
    if (username.trim().isEmpty) {
      addresses.clear();
      error.value = 'User not authenticated';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      if (kDebugMode) {
        debugPrint(
          '[AddressController] loading addresses for "$username"',
        );
      }

      final result = await _repository.getUserAddresses(username.trim());
      addresses.assignAll(result);

      if (kDebugMode) {
        debugPrint(
          '[AddressController] ✅ loaded ${result.length} addresses',
        );
      }
    } catch (e) {
      error.value = _friendlyError(e);
      if (kDebugMode) {
        debugPrint('[AddressController] ❌ loadAddresses: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Adds [address] then reloads the list so the server-assigned ID is present.
  Future<void> addAddress(AddressModel address) async {
    isLoading.value = true;
    error.value = '';
    try {
      await _repository.addAddress(address);
      // Reload to get the real ADDRESS_ID from the server
      await _reload();
    } catch (e) {
      error.value = _friendlyError(e);
      if (kDebugMode) debugPrint('[AddressController] ❌ addAddress: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates [address] then reloads the list.
  Future<void> updateAddress(AddressModel address) async {
    if (address.addressId == null) {
      error.value = 'Address ID is missing — cannot update.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      await _repository.updateAddress(address);
      await _reload();
    } catch (e) {
      error.value = _friendlyError(e);
      if (kDebugMode) debugPrint('[AddressController] ❌ updateAddress: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes the address with [addressId] and removes it from the local list.
  Future<void> deleteAddress(int addressId) async {
    isLoading.value = true;
    error.value = '';
    try {
      await _repository.deleteAddress(addressId);
      await _reload();
      if (selectedAddressId.value == addressId &&
          getAddressById(addressId) == null) {
        selectedAddressId.value = null;
      }
    } catch (e) {
      error.value = _friendlyError(e);
      if (kDebugMode) debugPrint('[AddressController] ❌ deleteAddress: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  AddressModel? getDefaultAddress() {
    try {
      return addresses.firstWhere((a) => a.isDefault == 1);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  AddressModel? getAddressById(int addressId) {
    try {
      return addresses.firstWhere((a) => a.addressId == addressId);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    addresses.clear();
    error.value = '';
    selectedAddressId.value = null;
    username = '';
    isLoading.value = false;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _reload() async {
    final result = await _repository.getUserAddresses(username.trim());
    addresses.assignAll(result);
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    // Hide raw Oracle / APEX internals from the UI
    if (raw.contains('ORA-') || raw.contains('cursor') || raw.contains('PL/SQL')) {
      return 'Something went wrong. Please try again.';
    }
    // Strip the leading "Exception: " that Dart adds
    return raw.replaceFirst('Exception: ', '');
  }
}
