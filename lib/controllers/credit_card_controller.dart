import 'package:flutter/foundation.dart';

import '../models/credit_card_model.dart';
import '../repositories/credit_card_repository.dart';

class CreditCardController extends ChangeNotifier {
  CreditCardController(this._repository);

  final CreditCardRepository _repository;

  List<CreditCardModel> _cards = const [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoaded = false;
  String? _lastUsername;

  List<CreditCardModel> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoaded => _hasLoaded;

  Future<void> fetchCards(String username) async {
    final normalizedUsername = username.trim().toUpperCase();
    if (normalizedUsername.isEmpty) {
      _cards = const [];
      _hasLoaded = true;
      notifyListeners();
      return;
    }

    _lastUsername = normalizedUsername;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cards = await _repository.getUserCards(normalizedUsername);
      _hasLoaded = true;
    } on CardException catch (error) {
      _errorMessage = error.message;
      _hasLoaded = true;
    } catch (error) {
      _errorMessage = error.toString();
      _hasLoaded = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCard(AddCardRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.addCard(request);
      await fetchCards(request.username);
    } on CardException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCard(int cardId) async {
    final username = _lastUsername;
    final previousCards = List<CreditCardModel>.from(_cards);

    _cards = _cards.where((card) => card.cardId != cardId).toList();
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteCard(cardId);
      if (username != null && username.isNotEmpty) {
        await fetchCards(username);
      }
    } on CardException catch (error) {
      _cards = previousCards;
      _errorMessage = error.message;
      notifyListeners();
    } catch (error) {
      _cards = previousCards;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  void setDefault(int cardId) {
    _cards = _cards
        .map((card) => card.copyWith(isDefault: card.cardId == cardId))
        .toList(growable: false);
    notifyListeners();
  }
}
