class Product {
  int id;
  String name;
  String category;
  List<String> images;
  double price;
  double? discountPrice;
  String description;
  List<String> sizes;
  List<String> colors;
  Map<String, List<String>>? imagesByColor;
  Map<String, Map<String, int>>? stockByVariant;
  double rating;
  int reviewCount;
  int soldCount;
  bool isFavorite;
  bool isSelected;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.images,
    required this.price,
    this.discountPrice,
    required this.description,
    required this.sizes,
    required this.colors,
    this.imagesByColor,
    this.stockByVariant,
    required this.rating,
    required this.reviewCount,
    this.soldCount = 0,
    this.isFavorite = false,
    this.isSelected = false,
  });

  int get discountPercentage {
    if (discountPrice == null) return 0;
    return (((price - discountPrice!) / price) * 100).toInt();
  }

  double get finalPrice => discountPrice ?? price;

  List<String> imagesForColor(String? color) {
    if (color == null) return images;
    final mapped = imagesByColor?[color];
    if (mapped != null && mapped.isNotEmpty) {
      return mapped;
    }
    return images;
  }

  int stockFor(String size, String color) {
    final mapped = stockByVariant?[size]?[color];
    if (mapped != null) {
      return mapped;
    }
    final sizeIndex = sizes.indexOf(size);
    final colorIndex = colors.indexOf(color);
    if (sizeIndex == -1 || colorIndex == -1) return 0;
    return ((id + sizeIndex * 3 + colorIndex * 5) % 9) + 1;
  }
}
