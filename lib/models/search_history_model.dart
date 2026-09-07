/// Model representing a single search history entry.
class SearchHistoryModel {
  const SearchHistoryModel({
    required this.id,
    required this.searchText,
    required this.searchType,
    this.createdAt,
  });

  final int id;
  final String searchText;
  final String searchType;
  final DateTime? createdAt;

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      // Support common column name casings from Oracle APEX
      id: (json['ID'] ?? json['id'] ?? 0) as int,
      searchText:
      (json['SEARCH_TEXT'] ?? json['search_text'] ?? '') as String,
      searchType:
      (json['SEARCH_TYPE'] ?? json['search_type'] ?? 'PRODUCT') as String,
      createdAt: _parseDate(json['CREATED_AT'] ?? json['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw as String);
    } catch (_) {
      return null;
    }
  }
}