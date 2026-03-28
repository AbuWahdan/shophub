import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/domain_models/address_entity.dart';
import '../data/repositories/address_repository_interface.dart';

// State classes
class AddressInitial {}

class AddressLoading {}

class AddressesLoaded {
  final List<AddressEntity> addresses;
  AddressesLoaded(this.addresses);
}

class AddressLoaded {
  final AddressEntity address;
  AddressLoaded(this.address);
}

class AddressError {
  final String message;
  AddressError(this.message);
}

class AddressesEmpty {}

/// GetX Controller for managing Address operations
class AddressController extends GetxController {
  final AddressRepositoryInterface _repository;

  AddressController(this._repository);

  // Observable state
  final addresses = <AddressEntity>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final selectedAddressId = Rx<int?>(null);

  String username = '';

  /// Load all addresses for current user
  Future<void> loadAddresses({bool forceRefresh = false}) async {
    if (username.isEmpty) {
      if (kDebugMode) {
        debugPrint('[AddressController.loadAddresses] ⚠️ Username is empty');
      }
      error.value = 'Username not set';
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      if (kDebugMode) {
        debugPrint('[AddressController.loadAddresses] Loading addresses for username=$username');
      }

      final result = await _repository.getUserAddresses(
        username,
        forceRefresh: forceRefresh,
      );

      if (kDebugMode) {
        debugPrint('[AddressController.loadAddresses] Got ${result.length} addresses');
      }

      addresses.assignAll(result);

      if (kDebugMode) {
        debugPrint('[AddressController.loadAddresses] ✅ Addresses loaded successfully');
      }
    } catch (e) {
      error.value = e.toString();
      if (kDebugMode) {
        debugPrint('[AddressController.loadAddresses] ❌ Error: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new address
  Future<void> addAddress(AddressEntity address) async {
    try {
      if (kDebugMode) {
        debugPrint('[AddressController.addAddress] Adding address: ${address.label}');
      }

      isLoading.value = true;
      error.value = '';

      final result = await _repository.addAddress(address);

      // Add to list
      addresses.add(result);

      if (kDebugMode) {
        debugPrint(
          '[AddressController.addAddress] ✅ Address added with ID=${result.addressId}',
        );
      }
    } catch (e) {
      error.value = e.toString();
      if (kDebugMode) {
        debugPrint('[AddressController.addAddress] ❌ Error: $e');
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing address
  Future<void> updateAddress(AddressEntity address) async {
    if (address.addressId == null) {
      error.value = 'Address ID cannot be null';
      return;
    }

    try {
      if (kDebugMode) {
        debugPrint('[AddressController.updateAddress] Updating ID=${address.addressId}');
      }

      isLoading.value = true;
      error.value = '';

      final result = await _repository.updateAddress(address);

      // Update in list
      final index = addresses.indexWhere((a) => a.addressId == result.addressId);
      if (index >= 0) {
        addresses[index] = result;
      }

      if (kDebugMode) {
        debugPrint('[AddressController.updateAddress] ✅ Address updated successfully');
      }
    } catch (e) {
      error.value = e.toString();
      if (kDebugMode) {
        debugPrint('[AddressController.updateAddress] ❌ Error: $e');
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete an address
  Future<void> deleteAddress(int addressId) async {
    try {
      if (kDebugMode) {
        debugPrint('[AddressController.deleteAddress] Deleting ID=$addressId');
      }

      isLoading.value = true;
      error.value = '';

      await _repository.deleteAddress(addressId);

      // Remove from list
      addresses.removeWhere((a) => a.addressId == addressId);

      if (selectedAddressId.value == addressId) {
        selectedAddressId.value = null;
      }

      if (kDebugMode) {
        debugPrint('[AddressController.deleteAddress] ✅ Address deleted successfully');
      }
    } catch (e) {
      error.value = e.toString();
      if (kDebugMode) {
        debugPrint('[AddressController.deleteAddress] ❌ Error: $e');
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Set an address as default
  Future<void> setDefaultAddress(int addressId) async {
    try {
      if (kDebugMode) {
        debugPrint('[AddressController.setDefaultAddress] Setting default: $addressId');
      }

      isLoading.value = true;
      error.value = '';

      await _repository.setDefaultAddress(addressId, username);

      // Update all addresses
      for (int i = 0; i < addresses.length; i++) {
        if (addresses[i].addressId == addressId) {
          final updated = addresses[i].copyWith(isDefault: true);
          addresses[i] = updated;
          selectedAddressId.value = addressId;
        } else {
          if (addresses[i].isDefault) {
            final updated = addresses[i].copyWith(isDefault: false);
            addresses[i] = updated;
          }
        }
      }

      if (kDebugMode) {
        debugPrint('[AddressController.setDefaultAddress] ✅ Default address set');
      }
    } catch (e) {
      error.value = e.toString();
      if (kDebugMode) {
        debugPrint('[AddressController.setDefaultAddress] ❌ Error: $e');
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get default address
  AddressEntity? getDefaultAddress() {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return null;
    }
  }

  /// Get address by ID
  AddressEntity? getAddressById(int addressId) {
    try {
      return addresses.firstWhere((a) => a.addressId == addressId);
    } catch (_) {
      return null;
    }
  }

  /// Clear all data
  void clear() {
    addresses.clear();
    error.value = '';
    selectedAddressId.value = null;
    username = '';
    isLoading.value = false;
    if (kDebugMode) {
      debugPrint('[AddressController.clear] Cleared all address data');
    }
  }
}
