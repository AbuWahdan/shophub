class ProductComment {
  final int productId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> imageUrls;

  const ProductComment({
    required this.productId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.imageUrls = const [],
  });
}
