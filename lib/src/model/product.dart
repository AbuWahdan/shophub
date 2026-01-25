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
}
