class ProductImageModel {
  final int imageId;
  final int itemId;
  final String imageBase64;
  final String imagePath;
  final bool isDefault;

  const ProductImageModel({
    required this.imageId,
    required this.itemId,
    required this.imageBase64,
    required this.imagePath,
    required this.isDefault,
  });

  ProductImageModel copyWith({
    int? imageId,
    int? itemId,
    String? imageBase64,
    String? imagePath,
    bool? isDefault,
  }) {
    return ProductImageModel(
      imageId: imageId ?? this.imageId,
      itemId: itemId ?? this.itemId,
      imageBase64: imageBase64 ?? this.imageBase64,
      imagePath: imagePath ?? this.imagePath,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      imageId: _asInt(
        json['IMAGE_ID'] ?? json['image_id'] ?? json['id'] ?? json['ID'],
      ),
      itemId: _asInt(json['ITEM_ID'] ?? json['item_id']),
      imageBase64: _asString(json['IMAGE_BASE64'] ?? json['image_base64']),
      imagePath: _asString(json['IMAGE_PATH'] ?? json['image_path']),
      isDefault:
          _asInt(
            json['IS_DEFAULT'] ?? json['is_Default'] ?? json['is_default'],
          ) ==
          1,
    );
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }

  static String _asString(dynamic value) {
    return (value ?? '').toString().trim();
  }
}
