
class ProductImageModel {
  final int imageId;
  final String imagePath;
  final bool isDefault;

  const ProductImageModel({
    required this.imageId,
    required this.imagePath,
    required this.isDefault,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      imageId: (json['IMAGE_ID'] as num?)?.toInt() ?? 0,
      imagePath: (json['IMAGE_PATH'] as String?)?.trim() ?? '',
      isDefault: ((json['IS_DEFAULT'] as num?)?.toInt() ?? 0) == 1,
    );
  }

  // Kept for backwards compat with base64 path if ever needed
  String get imageBase64 => imagePath;
}
