import 'package:flutter/foundation.dart';
import '../../core/exceptions/app_exception.dart';
import '../../data/datasources/address_remote_datasource.dart';
import '../../src/model/address_model.dart';
import '../domain_models/address_entity.dart';
import 'address_repository_interface.dart';

/// Concrete implementation of AddressRepository
/// Implements domain contract using data layer (RemoteDataSource)
/// and maps between Models and Entities
class AddressRepositoryImpl implements AddressRepositoryInterface {
  final AddressRemoteDataSource _remoteDataSource;
  
  // Local caching
  static List<AddressEntity> _cachedAddresses = <AddressEntity>[];
  static DateTime? _lastAddressesFetch;
  static const Duration _cacheTtl = Duration(minutes: 5);

  AddressRepositoryImpl(this._remoteDataSource);

  @override
  Future<AddressEntity> addAddress(AddressEntity address) async {
    try {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.addAddress] Adding address: ${address.label}');
      }

      // Convert Entity → Model
      final model = _entityToModel(address);
      
      // Call remote data source
      final resultModel = await _remoteDataSource.addAddress(model);
      
      // Invalidate cache
      _invalidateCache();
      
      // Convert Model → Entity
      final resultEntity = _modelToEntity(resultModel);
      
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.addAddress] ✅ Address added with ID=${resultEntity.addressId}');
      }

      return resultEntity;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.addAddress] ❌ Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<AddressEntity> updateAddress(AddressEntity address) async {
    if (address.addressId == null || address.addressId! <= 0) {
      throw ServerException('Cannot update address without valid addressId');
    }

    try {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.updateAddress] Updating address ID=${address.addressId}');
      }

      final model = _entityToModel(address);
      final resultModel = await _remoteDataSource.updateAddress(model);
      
      _invalidateCache();
      
      final resultEntity = _modelToEntity(resultModel);

      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.updateAddress] ✅ Address updated successfully');
      }

      return resultEntity;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.updateAddress] ❌ Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(int addressId) async {
    if (addressId <= 0) {
      throw ServerException('Invalid addressId: $addressId');
    }

    try {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.deleteAddress] Deleting address ID=$addressId');
      }

      await _remoteDataSource.deleteAddress(addressId);
      
      _invalidateCache();

      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.deleteAddress] ✅ Address deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.deleteAddress] ❌ Error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<AddressEntity>> getUserAddresses(
    String username, {
    bool forceRefresh = false,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();

    if (normalizedUsername.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[AddressRepositoryImpl.getUserAddresses] ⚠️ Empty username - returning empty list',
        );
      }
      return <AddressEntity>[];
    }

    // Check cache
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedAddresses.isNotEmpty &&
        _lastAddressesFetch != null &&
        now.difference(_lastAddressesFetch!) < _cacheTtl) {
      if (kDebugMode) {
        debugPrint(
          '[AddressRepositoryImpl.getUserAddresses] Cache HIT: ${_cachedAddresses.length} addresses',
        );
      }
      return List.from(_cachedAddresses);
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[AddressRepositoryImpl.getUserAddresses] Fetching addresses for username=$normalizedUsername',
        );
      }

      final models = await _remoteDataSource.getUserAddresses(normalizedUsername);
      
      if (kDebugMode) {
        debugPrint(
          '[AddressRepositoryImpl.getUserAddresses] Got ${models.length} models from remote',
        );
      }

      // Convert Models → Entities
      final entities = models.map(_modelToEntity).toList();
      
      // Update cache
      _cachedAddresses = entities;
      _lastAddressesFetch = now;

      if (kDebugMode) {
        debugPrint(
          '[AddressRepositoryImpl.getUserAddresses] ✅ Cached ${entities.length} addresses',
        );
      }

      return entities;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.getUserAddresses] ❌ Error: $e');
      }
      _invalidateCache();
      rethrow;
    }
  }

  @override
  @override
  Future<AddressEntity?> getAddressById(int addressId) async {
    if (addressId <= 0) {
      return null;
    }

    try {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.getAddressById] Finding address ID=$addressId');
      }

      // Try to find in cache first
      for (final addr in _cachedAddresses) {
        if (addr.addressId == addressId) {
          if (kDebugMode) {
            debugPrint('[AddressRepositoryImpl.getAddressById] Found in cache');
          }
          return addr;
        }
      }

      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.getAddressById] ⚠️ Address not found');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.getAddressById] ❌ Error: $e');
      }
      return null;
    }
  }

  @override
  Future<void> setDefaultAddress(int addressId, String username) async {
    // This might require a separate API endpoint
    // For now, we can update the address with isDefault = 1
    try {
      if (kDebugMode) {
        debugPrint(
          '[AddressRepositoryImpl.setDefaultAddress] Setting default: addressId=$addressId',
        );
      }

      // Find the address and update it
      final addresses = await getUserAddresses(username, forceRefresh: true);
      final addressToUpdate = addresses.firstWhere(
        (addr) => addr.addressId == addressId,
        orElse: () => throw ServerException('Address not found'),
      );

      final updated = addressToUpdate.copyWith(isDefault: true);
      await updateAddress(updated);

      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.setDefaultAddress] ✅ Default address set');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRepositoryImpl.setDefaultAddress] ❌ Error: $e');
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Mapping Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Map Model → Entity
  AddressEntity _modelToEntity(AddressModel model) {
    return AddressEntity(
      addressId: model.addressId,
      username: model.username,
      label: model.label,
      streetAddress: model.streetAddress,
      city: model.city,
      state: model.state,
      country: model.country,
      zipCode: model.zipCode,
      phone: model.phone,
      latitude: model.latitude,
      longitude: model.longitude,
      isDefault: (model.isDefault ?? 0) == 1,
    );
  }

  /// Map Entity → Model
  AddressModel _entityToModel(AddressEntity entity) {
    return AddressModel(
      addressId: entity.addressId,
      username: entity.username,
      label: entity.label,
      streetAddress: entity.streetAddress,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      zipCode: entity.zipCode,
      phone: entity.phone,
      latitude: entity.latitude,
      longitude: entity.longitude,
      isDefault: entity.isDefault ? 1 : 0,
    );
  }

  /// Invalidate cache
  void _invalidateCache() {
    _cachedAddresses.clear();
    _lastAddressesFetch = null;
    if (kDebugMode) {
      debugPrint('[AddressRepositoryImpl] Cache invalidated');
    }
  }
}
