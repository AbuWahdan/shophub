class CommentModel {
  final int id;
  final int itemId;
  final String username;
  final String commentText;
  final String createdAtRaw;
  final DateTime? createdAt;
  final int rating;

  const CommentModel({
    required this.id,
    required this.itemId,
    required this.username,
    required this.commentText,
    required this.createdAtRaw,
    required this.createdAt,
    required this.rating,
  });

  String get comment => commentText;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = _asString(json, const [
      'CREATED_AT',
      'created_at',
      'COMMENT_DATE',
      'comment_date',
    ]);

    return CommentModel(
      id: _asInt(json['ID'] ?? json['id']),
      itemId: _asInt(json['ITEM_ID'] ?? json['item_id']),
      username: _asString(json, const [
        'USERNAME',
        'username',
        'USER_NAME',
        'user_name',
      ]),
      commentText: _asString(json, const [
        'COMMENT_TEXT',
        'comment_text',
        'COMMENT',
        'comment',
      ]),
      createdAtRaw: createdAtRaw,
      createdAt: DateTime.tryParse(createdAtRaw),
      rating: _asInt(json['RATE'] ?? json['rating'] ?? json['RATING']),
    );
  }

  static String _asString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) {
        return (json[key] ?? '').toString().trim();
      }
    }
    return '';
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}
