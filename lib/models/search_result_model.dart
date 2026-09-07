/// Model representing a single product returned by the search API.
class SearchResultModel {
  const SearchResultModel({
    required this.id,
    required this.detId,
    required this.itemName,
    required this.itemDesc,
    required this.itemPrice,
    required this.finalPrice,
    required this.itemDiscount,
    required this.itemQty,
    required this.avgRating,
    required this.category,
    required this.catId,
    required this.isActive,
    required this.itemOwner,
    this.itemSize,
    this.itemImgUrl,
    this.imageId,
  });

  final int id;
  final int detId;
  final String itemName;
  final String itemDesc;
  final double itemPrice;
  final double finalPrice;
  final double itemDiscount;
  final int itemQty;
  final double avgRating;
  final String category;
  final int catId;
  final bool isActive;
  final String itemOwner;
  final String? itemSize;
  final String? itemImgUrl;
  final int? imageId;

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['ID'] as int,
      detId: json['DET_ID'] as int,
      itemName: json['ITEM_NAME'] as String? ?? '',
      itemDesc: json['ITEM_DESC'] as String? ?? '',
      itemPrice: (json['ITEM_PRICE'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['FINAL_PRICE'] as num?)?.toDouble() ?? 0.0,
      itemDiscount: (json['ITEM_DISCOUNT'] as num?)?.toDouble() ?? 0.0,
      itemQty: json['ITEM_QTY'] as int? ?? 0,
      avgRating: (json['AVG_RATING'] as num?)?.toDouble() ?? 0.0,
      category: json['CATEGORY'] as String? ?? '',
      catId: json['CAT_ID'] as int? ?? 0,
      isActive: (json['IS_ACTIVE'] as int? ?? 0) == 1,
      itemOwner: json['ITEM_OWNER'] as String? ?? '',
      itemSize: json['ITEM_SIZE'] as String?,
      itemImgUrl: json['ITEM_IMG_URL'] as String?,
      imageId: json['IMAGE_ID'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'ID': id,
    'DET_ID': detId,
    'ITEM_NAME': itemName,
    'ITEM_DESC': itemDesc,
    'ITEM_PRICE': itemPrice,
    'FINAL_PRICE': finalPrice,
    'ITEM_DISCOUNT': itemDiscount,
    'ITEM_QTY': itemQty,
    'AVG_RATING': avgRating,
    'CATEGORY': category,
    'CAT_ID': catId,
    'IS_ACTIVE': isActive ? 1 : 0,
    'ITEM_OWNER': itemOwner,
    if (itemSize != null) 'ITEM_SIZE': itemSize,
    if (itemImgUrl != null) 'ITEM_IMG_URL': itemImgUrl,
    if (imageId != null) 'IMAGE_ID': imageId,
  };

  /// Whether the item has an active discount.
  bool get hasDiscount => itemDiscount > 0;

  /// Effective display price: finalPrice if discounted, otherwise itemPrice.
  double get displayPrice => hasDiscount ? finalPrice : itemPrice;
}