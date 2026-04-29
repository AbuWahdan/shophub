import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/addresses/address_model.dart';

class AddressRepository {
  final http.Client _client;

  static const String _baseUrl = 'https://oracleapex.com/ords/topg/users';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  AddressRepository({http.Client? client}) : _client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // Oracle APEX sometimes returns TWO concatenated JSON objects in one response:
  //   {"status":"success","data":[...]}{"status":"error","message":"ORA-..."}
  // Standard jsonDecode crashes on this. This method extracts only the first
  // complete JSON object/array, ignoring anything after it.
  // ---------------------------------------------------------------------------
  String _extractFirstJson(String body) {
    int depth = 0;
    bool inString = false;
    bool escape = false;
    bool started = false;

    for (int i = 0; i < body.length; i++) {
      final char = body[i];

      if (escape) {
        escape = false;
        continue;
      }
      if (char == r'\' && inString) {
        escape = true;
        continue;
      }
      if (char == '"') {
        inString = !inString;
        if (!started) started = true;
        continue;
      }
      if (inString) continue;

      if (char == '{' || char == '[') {
        started = true;
        depth++;
      } else if (char == '}' || char == ']') {
        depth--;
        if (started && depth == 0) {
          return body.substring(0, i + 1);
        }
      }
    }
    return body;
  }

  // ---------------------------------------------------------------------------
  // GET /GetUserAddress?USERNAME={username}
  // ---------------------------------------------------------------------------
  Future<List<AddressModel>> getUserAddresses(String username) async {
    final uri = Uri.parse(
      '$_baseUrl/GetUserAddress?USERNAME=${Uri.encodeComponent(username)}',
    );

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        debugPrint('[AddressRepository] GET $uri');
        debugPrint('[AddressRepository] status: ${response.statusCode}');
        debugPrint('[AddressRepository] raw body: ${response.body}');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server error (${response.statusCode})');
      }

      if (response.body.trim().isEmpty) return [];

      // Extract only the first valid JSON object — discards any appended error block
      final firstJson = _extractFirstJson(response.body.trim());

      dynamic decoded;
      try {
        decoded = jsonDecode(firstJson);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[AddressRepository] JSON parse error: $e');
          debugPrint('[AddressRepository] attempted to parse: $firstJson');
        }
        return [];
      }

      List<dynamic> rawList;

      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final status = (decoded['status'] ?? '').toString().toLowerCase();
        if (status == 'error') {
          if (kDebugMode) {
            debugPrint(
              '[AddressRepository] API returned error: ${decoded['message']}',
            );
          }
          return [];
        }

        // Try common wrapper keys
        final data =
            decoded['data'] ??
                decoded['items'] ??
                decoded['addresses'] ??
                decoded['ADDRESSES'];

        if (data is List) {
          rawList = data;
        } else if (data is Map<String, dynamic>) {
          rawList = [data];
        } else {
          // The root object itself might be a single address
          rawList = [decoded];
        }
      } else {
        return [];
      }

      final result = <AddressModel>[];
      for (final item in rawList) {
        if (item is! Map<String, dynamic>) continue;
        try {
          result.add(AddressModel.fromJson(item));
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[AddressRepository] skipping bad item: $e | $item');
          }
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[AddressRepository] parsed ${result.length} addresses',
        );
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressRepository] getUserAddresses error: $e');
      }
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // POST /AddUserAddress
  // Returns the saved address. After saving, always reload from server
  // because APEX may not echo back the full row with the new ADDRESS_ID.
  // ---------------------------------------------------------------------------
  Future<void> addAddress(AddressModel address) async {
    final uri = Uri.parse('$_baseUrl/AddUserAddress');
    final body = jsonEncode(address.toJson());

    if (kDebugMode) {
      debugPrint('[AddressRepository] POST AddUserAddress: $body');
    }

    final response = await _client
        .post(uri, headers: _headers, body: body)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) {
      debugPrint('[AddressRepository] add status: ${response.statusCode}');
      debugPrint('[AddressRepository] add response: ${response.body}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add address (${response.statusCode})');
    }

    // Check if APEX returned an error payload
    if (response.body.trim().isNotEmpty) {
      try {
        final firstJson = _extractFirstJson(response.body.trim());
        final decoded = jsonDecode(firstJson);
        if (decoded is Map<String, dynamic>) {
          final status = (decoded['status'] ?? '').toString().toLowerCase();
          if (status == 'error') {
            final message =
                decoded['message'] ?? decoded['error'] ?? 'Failed to add address';
            throw Exception(message.toString());
          }
        }
      } catch (e) {
        if (e.toString().contains('Failed to add')) rethrow;
        // JSON parse failed — not an error, just an unparseable success response
      }
    }
    // Caller must call getUserAddresses() after this to get the real saved data
  }

  // ---------------------------------------------------------------------------
  // POST /UpdateUserAddress  — address_id required
  // ---------------------------------------------------------------------------
  Future<void> updateAddress(AddressModel address) async {
    assert(address.addressId != null, 'address_id must not be null for update');

    final uri = Uri.parse('$_baseUrl/UpdateUserAddress');
    final body = jsonEncode(address.toJson());

    if (kDebugMode) {
      debugPrint('[AddressRepository] POST UpdateUserAddress: $body');
    }

    final response = await _client
        .post(uri, headers: _headers, body: body)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) {
      debugPrint('[AddressRepository] update status: ${response.statusCode}');
      debugPrint('[AddressRepository] update response: ${response.body}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update address (${response.statusCode})');
    }

    if (response.body.trim().isNotEmpty) {
      try {
        final firstJson = _extractFirstJson(response.body.trim());
        final decoded = jsonDecode(firstJson);
        if (decoded is Map<String, dynamic>) {
          final status = (decoded['status'] ?? '').toString().toLowerCase();
          if (status == 'error') {
            final message =
                decoded['message'] ?? decoded['error'] ?? 'Failed to update address';
            throw Exception(message.toString());
          }
        }
      } catch (e) {
        if (e.toString().contains('Failed to update')) rethrow;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // POST /DeleteUserAddress
  // ---------------------------------------------------------------------------
  Future<void> deleteAddress(int addressId) async {
    final uri = Uri.parse('$_baseUrl/DeleteUserAddress');
    final body = jsonEncode({'address_id': addressId});

    if (kDebugMode) {
      debugPrint('[AddressRepository] POST DeleteUserAddress: $body');
    }

    final response = await _client
        .post(uri, headers: _headers, body: body)
        .timeout(const Duration(seconds: 30));

    if (kDebugMode) {
      debugPrint('[AddressRepository] delete status: ${response.statusCode}');
      debugPrint('[AddressRepository] delete response: ${response.body}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete address (${response.statusCode})');
    }
  }
}