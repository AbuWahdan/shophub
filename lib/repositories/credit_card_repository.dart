import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/credit_card_model.dart';

class CardException implements Exception {
  const CardException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CreditCardRepository {
  CreditCardRepository({http.Client? client})
    : _client = client ?? http.Client();

  static final Uri _baseUri = Uri.parse(
    'https://oracleapex.com/ords/topg/Card/',
  );
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  Future<List<CreditCardModel>> getUserCards(String username) async {
    final response = await _post('GetUserCard', {
      'username': username,
    });
    final items = _extractItems(response);
    return items
        .whereType<Map>()
        .map(
          (item) => CreditCardModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<void> addCard(AddCardRequest request) async {
    await _post('AddCard', request.toJson());
  }

  Future<void> deleteCard(int cardId) async {
    await _post('DeleteUserCard', {'card_id': cardId});
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
            _baseUri.resolve(path),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CardException(_extractMessage(response.body));
      }

      if (response.body.trim().isEmpty) return null;
      final decoded = jsonDecode(response.body);
      final message = _messageFromDecoded(decoded);
      final status = _statusFromDecoded(decoded);
      if (status == 'error' && message.isNotEmpty) {
        throw CardException(message);
      }
      return decoded;
    } on CardException {
      rethrow;
    } on TimeoutException {
      throw const CardException('Request timed out. Please try again.');
    } on FormatException {
      throw const CardException('Invalid card service response.');
    } catch (error) {
      throw CardException(error.toString());
    }
  }

  List<dynamic> _extractItems(dynamic response) {
    if (response == null) return const [];
    if (response is List) return response;
    if (response is Map<String, dynamic>) {
      for (final key in const ['items', 'data', 'cards', 'GetUserCard']) {
        final value = response[key];
        if (value is List) return value;
      }
      return [response];
    }
    if (response is Map) {
      return _extractItems(Map<String, dynamic>.from(response));
    }
    return const [];
  }

  String _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      final message = _messageFromDecoded(decoded);
      return message.isEmpty ? body : message;
    } catch (_) {
      return body;
    }
  }

  String _messageFromDecoded(dynamic decoded) {
    if (decoded is Map) {
      for (final key in const ['message', 'MESSAGE', 'error', 'ERROR']) {
        final value = decoded[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    }
    return '';
  }

  String _statusFromDecoded(dynamic decoded) {
    if (decoded is Map) {
      final value = decoded['status'] ?? decoded['STATUS'];
      return (value ?? '').toString().trim().toLowerCase();
    }
    return '';
  }
}
