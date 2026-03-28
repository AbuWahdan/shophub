import '../domain_models/address_entity.dart';

/// Abstract repository for Address domain operations
/// Defines the contract that concrete repositories must implement
abstract class AddressRepositoryInterface {
  /// Add a new address
  Future<AddressEntity> addAddress(AddressEntity address);

  /// Update an existing address
  Future<AddressEntity> updateAddress(AddressEntity address);

  /// Delete an address by ID
  Future<void> deleteAddress(int addressId);

  /// Get all addresses for a user
  Future<List<AddressEntity>> getUserAddresses(
    String username, {
    bool forceRefresh = false,
  });

  /// Get a single address by ID
  Future<AddressEntity?> getAddressById(int addressId);

  /// Set an address as default
  Future<void> setDefaultAddress(int addressId, String username);
}
