class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.children = const [],
  });

  bool get isMainCategory => parentId == null;

  bool get hasChildren => children.isNotEmpty;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return CategoryModel(
      id: asInt(json['id'] ?? json['ID']),
      name: (json['name'] ?? json['NAME'] ?? '').toString(),
      parentId: (json['parent_id'] ?? json['PARENT_ID']) == null
          ? null
          : asInt(json['parent_id'] ?? json['PARENT_ID']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'parent_id': parentId};
  }
}
