import '../entities/address_entity.dart';

/// Abstract repository for Address domain operations
/// Defines the contract that concrete repositories must implement
abstract class AddressRepository {
  /// Add a new address
  /// 
  /// Parameters:
  ///   - address: AddressEntity to add
  /// 
  /// Returns: The newly created address with addressId
  /// 
  /// Throws:
  ///   - ServerException on API error
  ///   - NetworkException on network error
  Future<AddressEntity> addAddress(AddressEntity address);

  /// Update an existing address
  /// 
  /// Parameters:
  ///   - address: AddressEntity with addressId to update
  /// 
  /// Returns: The updated address
  /// 
  /// Throws:
  ///   - ServerException if address not found or API error
  ///   - NetworkException on network error
  Future<AddressEntity> updateAddress(AddressEntity address);

  /// Delete an address by ID
  /// 
  /// Parameters:
  ///   - addressId: ID of address to delete
  /// 
  /// Throws:
  ///   - ServerException if address not found or API error
  ///   - NetworkException on network error
  Future<void> deleteAddress(int addressId);

  /// Get all addresses for a user
  /// 
  /// Parameters:
  ///   - username: Username to fetch addresses for
  ///   - forceRefresh: If true, bypass cache and fetch from API
  /// 
  /// Returns: List of AddressEntities (empty list if none found, never null)
  /// 
  /// Throws:
  ///   - ServerException on API error
  ///   - NetworkException on network error
  Future<List<AddressEntity>> getUserAddresses(
    String username, {
    bool forceRefresh = false,
  });

  /// Get a single address by ID
  /// 
  /// Parameters:
  ///   - addressId: ID of address to fetch
  /// 
  /// Returns: The AddressEntity
  /// 
  /// Throws:
  ///   - ServerException if address not found
  ///   - NetworkException on network error
  Future<AddressEntity?> getAddressById(int addressId);

  /// Set an address as default
  /// 
  /// Parameters:
  ///   - addressId: ID of address to set as default
  ///   - username: Username that owns the address
  /// 
  /// Throws:
  ///   - ServerException on error
  ///   - NetworkException on network error
  Future<void> setDefaultAddress(int addressId, String username);
}
