class ItemCommentModel {
  const ItemCommentModel({
    required this.id,
    required this.itemId,
    required this.username,
    required this.commentText,
    required this.createdAt,
    required this.rate,
  });

  final int id;
  final int itemId;
  final String username;
  final String commentText;
  final DateTime createdAt;
  final int rate;

  String get comment => commentText;
  int get rating => rate;
  bool get hasCreatedAt => createdAt.millisecondsSinceEpoch > 0;

  factory ItemCommentModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = (json['CREATED_AT'] ?? json['created_at'] ?? '')
        .toString()
        .trim();

    return ItemCommentModel(
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
      createdAt:
          DateTime.tryParse(createdAtRaw) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      rate: _asInt(json['RATE'] ?? json['rate'] ?? json['RATING']),
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
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}
