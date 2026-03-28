import 'package:flutter/foundation.dart';
import '../../core/api/api_service.dart';
import '../../core/exceptions/app_exception.dart';
import '../../src/model/address_model.dart';

/// Remote data source for User Addresses
/// Handles all API calls related to address CRUD operations
class AddressRemoteDataSource {
  final ApiService _apiService;

  // API endpoints
  static const String _addAddress = '/AddUserAddress';
  static const String _updateAddress = '/UpdateUserAddress';
  static const String _deleteAddress = '/DeleteUserAddress';
  static const String _getAddresses = '/GetUserAddress';

  AddressRemoteDataSource(this._apiService);

  /// Add a new address for user
  /// POST /AddUserAddress
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.addAddress] Adding address: ${address.label}');
      }

      final response = await _apiService.post(
        _addAddress,
        body: address.toJson(),
        isReadOperation: false,
      );

      if (response == null) {
        throw ServerException('Failed to add address');
      }

      // Parse response - could be the newly created address
      final newAddress = _parseAddressResponse(response);
      
      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.addAddress] ✅ Address added successfully');
      }

      return newAddress;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.addAddress] ❌ Error: $e');
      }
      rethrow;
    }
  }

  /// Update an existing address
  /// POST /UpdateUserAddress
  Future<AddressModel> updateAddress(AddressModel address) async {
    if (address.addressId == null) {
      throw ServerException('Cannot update address without addressId');
    }

    try {
      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.updateAddress] Updating address id=${address.addressId}');
      }

      final response = await _apiService.post(
        _updateAddress,
        body: address.toJson(),
        isReadOperation: false,
      );

      if (response == null) {
        throw ServerException('Failed to update address');
      }

      final updatedAddress = _parseAddressResponse(response);

      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.updateAddress] ✅ Address updated successfully');
      }

      return updatedAddress;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.updateAddress] ❌ Error: $e');
      }
      rethrow;
    }
  }

  /// Delete an address
  /// POST /DeleteUserAddress
  Future<void> deleteAddress(int addressId) async {
    try {
      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.deleteAddress] Deleting address id=$addressId');
      }

      await _apiService.post(
        _deleteAddress,
        body: {'address_id': addressId},
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.deleteAddress] ✅ Address deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.deleteAddress] ❌ Error: $e');
      }
      rethrow;
    }
  }

  /// Get all addresses for a user
  /// GET /GetUserAddress?USERNAME={username}
  Future<List<AddressModel>> getUserAddresses(String username) async {
    final normalizedUsername = username.trim();
    
    if (normalizedUsername.isEmpty) {
      throw ServerException('Username cannot be empty');
    }

    try {
      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.getUserAddresses] Fetching addresses for username=$normalizedUsername');
      }

      final response = await _apiService.get(
        _getAddresses,
        queryParams: {'USERNAME': normalizedUsername},
        isReadOperation: true,
      );

      if (response == null) {
        if (kDebugMode) {
          debugPrint('[AddressRemoteDataSource.getUserAddresses] API returned null - returning empty list');
        }
        return <AddressModel>[];
      }

      final addresses = _parseAddressListResponse(response);

      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.getUserAddresses] ✅ Fetched ${addresses.length} addresses');
      }

      return addresses;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRemoteDataSource.getUserAddresses] ❌ Error: $e');
      }
      rethrow;
    }
  }

  /// Parse single address from response
  /// Handles various response formats
  AddressModel _parseAddressResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      // Direct address map
      if (response.containsKey('address_id') || 
          response.containsKey('addressId') || 
          response.containsKey('username')) {
        return AddressModel.fromJson(response);
      }
      
      // Nested in 'data', 'result', 'address' keys
      final candidates = [
        response['data'],
        response['result'],
        response['address'],
        response['ADDRESS'],
        response['item'],
        response['ITEM'],
      ];

      for (final candidate in candidates) {
        if (candidate is Map<String, dynamic>) {
          return AddressModel.fromJson(candidate);
        }
      }
    }

    // If we can't parse, create a minimal address
    if (response is Map<String, dynamic>) {
      return AddressModel.fromJson(response);
    }

    throw ServerException('Failed to parse address response');
  }

  /// Parse list of addresses from response
  /// Handles various response formats
  List<AddressModel> _parseAddressListResponse(dynamic response) {
    final List<AddressModel> addresses = [];

    if (response is List) {
      for (final item in response) {
        if (item is Map<String, dynamic>) {
          addresses.add(AddressModel.fromJson(item));
        }
      }
      return addresses;
    }

    if (response is Map<String, dynamic>) {
      // Try common nested keys
      final candidates = [
        response['data'],
        response['DATA'],
        response['result'],
        response['RESULT'],
        response['addresses'],
        response['Addresses'],
        response['ADDRESSES'],
        response['items'],
        response['Items'],
        response['ITEMS'],
        response['records'],
        response['Records'],
        response['RECORDS'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          for (final item in candidate) {
            if (item is Map<String, dynamic>) {
              addresses.add(AddressModel.fromJson(item));
            }
          }
          return addresses;
        }
      }

      // Try to parse as single address and return as list
      try {
        final single = AddressModel.fromJson(response);
        return [single];
      } catch (_) {
        return addresses;
      }
    }

    return addresses;
  }
}
