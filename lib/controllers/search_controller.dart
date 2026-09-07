import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/search_history_model.dart';
import '../models/search_result_model.dart';
import '../repositories/search_repository.dart';

/// Manages all state and logic for the search screen.
///
/// Register once in a binding or lazily via Get.lazyPut:
/// ```dart
/// Get.lazyPut(() => SearchController(repository: SearchRepository()));
/// ```
class SearchController extends GetxController {
  SearchController({required SearchRepository repository})
      : _repository = repository;

  final SearchRepository _repository;
  bool _isDisposed = false;
  // ── Config ─────────────────────────────────────────────────────────────────

  /// Debounce delay before firing a search after the user stops typing.
  static const Duration _debounce = Duration(milliseconds: 500);

  /// Minimum query length before triggering a network search.
  static const int _minQueryLength = 2;

  // ── Public observables ─────────────────────────────────────────────────────

  final TextEditingController textController = TextEditingController();

  /// Current text in the search field.
  final RxString query = ''.obs;

  /// Products returned by the last search call.
  final RxList<SearchResultModel> results = <SearchResultModel>[].obs;

  /// Latest search history from the server.
  final RxList<SearchHistoryModel> history = <SearchHistoryModel>[].obs;

  /// True while a search request is in-flight.
  final RxBool isSearching = false.obs;

  /// True while history is loading.
  final RxBool isHistoryLoading = false.obs;

  /// True while clearing all history.
  final RxBool isClearingHistory = false.obs;

  /// Non-null when the most recent search threw an error.
  final Rxn<String> searchError = Rxn<String>();

  /// Whether the history panel should be visible.
  ///
  /// Shown when the field is focused and empty (or short), hidden once the
  /// user has real results or dismisses the keyboard.
  final RxBool showHistory = false.obs;

  // ── Private ────────────────────────────────────────────────────────────────

  Timer? _debounceTimer;

  /// The username used for history API calls.
  /// TODO: replace with real session value once auth is wired up.
  String _username = 'guest';

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    _isDisposed = true;

    _debounceTimer?.cancel();

    textController
      ..removeListener(_onTextChanged)
      ..dispose();

    super.onClose();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call this when the screen is opened so we know the current user.
  void initForUser(String username) {
    _username = username;
    _loadHistory();
  }

  /// Called when the search field gains focus.
  void onFieldFocused() {
    if (query.value.trim().length < _minQueryLength) {
      showHistory.value = true;
    }
  }

  /// Called when the user taps a history chip — populates the search field.
  void onHistoryItemTapped(SearchHistoryModel item) {
    textController.text = item.searchText;
    // Move cursor to end.
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: item.searchText.length),
    );
    query.value = item.searchText;
    showHistory.value = false;
    _executeSearch(item.searchText);
  }

  /// Deletes a single history entry and refreshes the local list.
  Future<void> deleteHistoryItem(SearchHistoryModel item) async {
    // Optimistic removal for instant UI feedback.
    history.remove(item);

    try {
      await _repository.deleteSearchHistory(item.id);
    } catch (e) {
      // Revert on failure.
      _loadHistory();
      _showSnackbar('error_deleting_history'.tr);
    }
  }

  /// Clears all history for the current user.
  Future<void> clearAllHistory() async {
    if (isClearingHistory.value) return;
    isClearingHistory.value = true;

    // Optimistic clear.
    history.clear();

    try {
      await _repository.deleteAllSearchHistory(_username);
    } catch (e) {
      _loadHistory(); // Revert on failure.
      _showSnackbar('error_clearing_history'.tr);
    } finally {
      isClearingHistory.value = false;
    }
  }

  /// Clears the search field and resets state.
  void clearSearch() {
    textController.clear();
    query.value = '';
    results.clear();
    searchError.value = null;
    showHistory.value = true;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _onTextChanged() {
    final text = textController.text;
    query.value = text;

    _debounceTimer?.cancel();

    if (text.trim().length < _minQueryLength) {
      results.clear();
      searchError.value = null;
      showHistory.value = true;
      return;
    }

    showHistory.value = false;

    _debounceTimer = Timer(_debounce, () => _executeSearch(text.trim()));
  }

  Future<void> _executeSearch(String q) async {
    if (_isDisposed) return;
    if (q.trim().length < _minQueryLength) return;

    isSearching.value = true;
    searchError.value = null;

    try {
      final data = await _repository.searchProducts(q);
      if (_isDisposed) return;

      results.assignAll(data);

      unawaited(
        _repository.insertSearchHistory(
          username: _username,
          searchText: q,
        ),
      );

      unawaited(_loadHistory());
    } catch (e) {
      if (_isDisposed) return;

      searchError.value = e.toString();
      results.clear();
    } finally {
      if (_isDisposed) return;
      isSearching.value = false;
    }
  }
  Future<void> _loadHistory() async {
    if (_isDisposed) return;

    isHistoryLoading.value = true;

    try {
      final data = await _repository.getSearchHistory(_username);
      if (_isDisposed) return;

      history.assignAll(data);
    } catch (_) {
      // silent
    } finally {
      if (_isDisposed) return;
      isHistoryLoading.value = false;
    }
  }
  void _showSnackbar(String message) {
    if (_isDisposed) return;

    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}