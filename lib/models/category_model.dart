class CategoryModel {
  final int id;
  final String name;
  final String arabicName;
  final int? parentId;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    this.arabicName = '',
    this.parentId,
    this.children = const [],
  });

  bool get isMainCategory => parentId == null;
  bool get hasChildren => children.isNotEmpty;

  // Returns the localised name based on locale code ('ar' → arabicName).
  String localizedName(String languageCode) =>
      languageCode == 'ar' && arabicName.isNotEmpty ? arabicName : name;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _int(json['ID'] ?? json['id']),
      name: (json['NAME'] ?? json['name'] ?? '').toString().trim(),
      arabicName: (json['ARABIC_NAME'] ?? json['arabic_name'] ?? '').toString().trim(),
      parentId: _nullableInt(json['PARENT_ID'] ?? json['parent_id']),
    );
  }

  CategoryModel copyWith({List<CategoryModel>? children}) => CategoryModel(
    id: id,
    name: name,
    arabicName: arabicName,
    parentId: parentId,
    children: children ?? this.children,
  );

  static int _int(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse((v ?? '').toString()) ?? 0;
  }

  static int? _nullableInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    final parsed = int.tryParse(v.toString());
    return (parsed != null && parsed > 0) ? parsed : null;
  }
}
