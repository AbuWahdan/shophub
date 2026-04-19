import 'package:shared_preferences/shared_preferences.dart';

/// Persists wishlist product IDs across app restarts.
///
/// Stored as a JSON list of integers under a per-user key so that
/// multiple accounts on the same device don't share state.
class WishlistPersistence {
  WishlistPersistence._();

  static const String _keyPrefix = 'wishlist_ids_';

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the saved wishlist IDs for [username].
  /// Returns an empty set if nothing has been saved yet or on any error.
  static Future<Set<int>> loadIds(String username) async {
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.isEmpty) return const {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key(normalizedUsername)) ?? const [];
      return raw
          .map((s) => int.tryParse(s))
          .whereType<int>()
          .where((id) => id > 0)
          .toSet();
    } catch (_) {
      return const {};
    }
  }

  /// Overwrites the saved wishlist IDs for [username].
  static Future<void> saveIds(String username, Iterable<int> ids) async {
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key(normalizedUsername),
        ids.where((id) => id > 0).map((id) => id.toString()).toList(),
      );
    } catch (_) {
      // Persistence is best-effort; never crash the UI over it.
    }
  }

  /// Removes all saved wishlist data for [username] (call on logout).
  static Future<void> clear(String username) async {
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(normalizedUsername));
    } catch (_) {}
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static String _key(String normalizedUsername) =>
      '$_keyPrefix$normalizedUsername';
}