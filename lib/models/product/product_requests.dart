// // models/product_requests.dart
// //
// // All DTOs (Data Transfer Objects) for product API calls.
// // Kept separate from ProductModel so the model stays lean.
//
// // ─────────────────────────────────────────────────────────────────────────────
// // GET
// // ─────────────────────────────────────────────────────────────────────────────
//
// class GetProductsRequest {
//   final String? createdBy;
//   final int? categoryId;
//   final int? detId;
//
//   const GetProductsRequest({
//     this.createdBy,
//     this.categoryId,
//     this.detId,
//   });
//
//   Map<String, String> toQueryParameters() {
//     final normalizedCreatedBy = createdBy?.trim();
//     return {
//       if (categoryId != null) 'CAT_ID': categoryId.toString(),
//       if (detId != null) 'DET_ID': detId.toString(),
//       if (normalizedCreatedBy != null && normalizedCreatedBy.isNotEmpty)
//         'created_by': normalizedCreatedBy,
//     };
//   }
//
//   Map<String, dynamic> toBody() {
//     final normalizedCreatedBy = createdBy?.trim();
//     return {
//       if (categoryId != null) 'CAT_ID': categoryId,
//       if (detId != null) 'DET_ID': detId,
//       if (normalizedCreatedBy != null && normalizedCreatedBy.isNotEmpty)
//         'created_by': normalizedCreatedBy,
//     };
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // CREATE
// // ─────────────────────────────────────────────────────────────────────────────
//
// class CreateProductRequest {
//   final String itemName;
//   final String itemDesc;
//   final String? itemImgUrl;
//   final String? imagesCsv;
//   final List<CreateProductDetailDto> details;
//   final int categoryId;
//   final String createdBy;
//
//   const CreateProductRequest({
//     required this.itemName,
//     required this.itemDesc,
//     this.itemImgUrl,
//     this.imagesCsv,
//     required this.details,
//     required this.categoryId,
//     required this.createdBy,
//   });
//
//   Map<String, dynamic> toJson() {
//     final normalizedImages = _normalizeImagesCsv(imagesCsv ?? itemImgUrl ?? '');
//     return {
//       'item_name': itemName,
//       'item_desc': itemDesc,
//       'item_img_url': normalizedImages.isEmpty ? itemImgUrl : normalizedImages,
//       'details': details.map((d) => d.toJson()).toList(),
//       'category_id': categoryId,
//       'created_by': createdBy,
//     };
//   }
//
//   String _normalizeImagesCsv(String raw) => raw
//       .split(',')
//       .map((p) => p.trim())
//       .where((p) => p.isNotEmpty)
//       .join(',');
// }
//
// class CreateProductDetailDto {
//   final int? detId;
//   final String brand;
//   final String color;
//   final String size; // SIZE_CODE string — NOT int
//   final double discount;
//   final double tax;
//   final double price;
//   final int stock;
//   final int isActive;
//
//   const CreateProductDetailDto({
//     this.detId,
//     required this.brand,
//     required this.color,
//     required this.size,
//     required this.discount,
//     this.tax = 0,
//     required this.price,
//     required this.stock,
//     this.isActive = 1,
//   });
//
//   Map<String, dynamic> toJson() => {
//     if (detId != null && detId! > 0) 'det_id': detId,
//     'brand': brand,
//     'color': color,
//     'item_size': size,
//     'discount': discount,
//     'tax': tax,
//     'item_price': price,
//     'item_qty': stock,
//     'is_active': isActive,
//   };
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // UPDATE
// // ─────────────────────────────────────────────────────────────────────────────
//
// class UpdateProductRequest {
//   final int id;
//   final String itemName;
//   final String itemDesc;
//   final int isActive;
//   final List<UpdateProductDetailDto> itemDetails;
//   final int categoryId;
//   final String? itemImgUrl;
//
//   const UpdateProductRequest({
//     required this.id,
//     required this.itemName,
//     required this.itemDesc,
//     required this.isActive,
//     required this.itemDetails,
//     required this.categoryId,
//     this.itemImgUrl,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'item_name': itemName,
//     'item_desc': itemDesc,
//     'is_active': isActive,
//     'category_id': categoryId,
//     if (itemImgUrl != null && itemImgUrl!.isNotEmpty)
//       'item_img_url': itemImgUrl,
//     'item_details': itemDetails.map((d) => d.toJson()).toList(),
//   };
// }
//
// class UpdateProductDetailDto {
//   final int detailId;
//   final double price;
//   final int stock;
//   final double discount;
//   final double tax;
//   final String brand;
//   final String color;
//   final String modifiedBy;
//   final String size; // SIZE_CODE string
//   final int isActive;
//
//   const UpdateProductDetailDto({
//     required this.detailId,
//     required this.price,
//     required this.stock,
//     this.discount = 0,
//     this.tax = 0,
//     required this.brand,
//     required this.color,
//     required this.modifiedBy,
//     required this.size,
//     required this.isActive,
//   });
//
//   factory UpdateProductDetailDto.fromJson(Map<String, dynamic> json) {
//     return UpdateProductDetailDto(
//       detailId: _int(_pick(json, const ['detail_id', 'DETAIL_ID'])),
//       price: _dbl(_pick(json, const ['item_price', 'ITEM_PRICE'])),
//       stock: _int(_pick(json, const ['item_qty', 'ITEM_QTY'])),
//       discount: _dbl(_pick(json, const ['item_discount', 'ITEM_DISCOUNT'])),
//       tax: _dbl(_pick(json, const ['item_tax', 'ITEM_TAX'])),
//       brand: _str(json, const ['brand', 'BRAND']),
//       color: _str(json, const ['color', 'COLOR']),
//       modifiedBy: _str(json, const ['modified_by', 'MODIFIED_BY']),
//       size: _str(json, const ['size', 'SIZE', 'item_size', 'ITEM_SIZE']),
//       isActive: _int(_pick(json, const ['is_active', 'IS_ACTIVE'])),
//     );
//   }
//
//   UpdateProductDetailDto copyWith({
//     int? detailId,
//     double? price,
//     int? stock,
//     double? discount,
//     double? tax,
//     String? brand,
//     String? color,
//     String? modifiedBy,
//     String? size,
//     int? isActive,
//   }) =>
//       UpdateProductDetailDto(
//         detailId: detailId ?? this.detailId,
//         price: price ?? this.price,
//         stock: stock ?? this.stock,
//         discount: discount ?? this.discount,
//         tax: tax ?? this.tax,
//         brand: brand ?? this.brand,
//         color: color ?? this.color,
//         modifiedBy: modifiedBy ?? this.modifiedBy,
//         size: size ?? this.size,
//         isActive: isActive ?? this.isActive,
//       );
//
//   Map<String, dynamic> toJson() => {
//     'detail_id': detailId,
//     'item_price': price,
//     'item_qty': stock,
//     'item_discount': discount,
//     'item_tax': tax,
//     'brand': brand,
//     'color': color,
//     'modified_by': modifiedBy,
//     'size': size,
//     'item_size': size,
//     'is_active': isActive,
//   };
//
//   // ── Private helpers ──────────────────────────────────────────────────────
//
//   static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
//     for (final key in keys) {
//       if (json.containsKey(key)) return json[key];
//     }
//     return null;
//   }
//
//   static String _str(Map<String, dynamic> json, List<String> keys) =>
//       (_pick(json, keys) ?? '').toString().trim();
//
//   static double _dbl(dynamic v) {
//     if (v is num) return v.toDouble();
//     return double.tryParse((v ?? '').toString()) ?? 0.0;
//   }
//
//   static int _int(dynamic v) {
//     if (v is num) return v.toInt();
//     return int.tryParse((v ?? '').toString()) ?? 0;
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // READ — flat detail row returned by the API detail endpoint
// // ─────────────────────────────────────────────────────────────────────────────
//
// class ProductDetailResponse {
//   final int itemId;
//   final int detId;
//   final String itemName;
//   final String itemDesc;
//   final double price;
//   final int stock;
//   final double discount;
//   final double tax;
//   final String imageUrl;
//   final int imageId;
//   final String category;
//   final int categoryId;
//   final int isActive;
//   final String owner;
//   final int reviews;
//   final double rating;
//   final String size;
//   final String color;
//   final String brand;
//
//   const ProductDetailResponse({
//     required this.itemId,
//     required this.detId,
//     required this.itemName,
//     required this.itemDesc,
//     required this.price,
//     required this.stock,
//     required this.discount,
//     this.tax = 0,
//     required this.imageUrl,
//     required this.imageId,
//     required this.category,
//     required this.categoryId,
//     required this.isActive,
//     required this.owner,
//     required this.reviews,
//     required this.rating,
//     required this.size,
//     required this.color,
//     required this.brand,
//   });
//
//   factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
//     return ProductDetailResponse(
//       itemId: _int(_pick(json, const ['ITEM_ID', 'item_id', 'ID', 'id'])),
//       detId: _int(_pick(json, const ['DET_ID', 'det_id'])),
//       itemName: _str(json, const ['ITEM_NAME', 'item_name']),
//       itemDesc: _str(json, const ['ITEM_DESC', 'item_desc']),
//       price: _dbl(_pick(json, const ['ITEM_PRICE', 'item_price'])),
//       stock: _int(_pick(json, const ['ITEM_QTY', 'item_qty'])),
//       discount: _dbl(
//         _pick(json, const [
//           'ITEM_DISCOUNT',
//           'item_discount',
//           'DISCOUNT',
//           'discount',
//         ]),
//       ),
//       tax: _dbl(_pick(json, const ['TAX', 'tax', 'ITEM_TAX', 'item_tax'])),
//       imageUrl: _str(json, const ['ITEM_IMG_URL', 'item_img_url']),
//       imageId: _int(_pick(json, const ['IMAGE_ID', 'image_id'])),
//       category: _str(json, const ['CATEGORY', 'category']),
//       categoryId: _int(_pick(json, const ['CAT_ID', 'cat_id', 'CATEGORY_ID'])),
//       isActive: _int(_pick(json, const ['IS_ACTIVE', 'is_active'])),
//       owner: _str(json, const ['ITEM_OWNER', 'item_owner']),
//       reviews: _int(_pick(json, const ['REVIEWS', 'reviews'])),
//       rating: _dbl(_pick(json, const ['RATING', 'rating'])),
//       size: _str(json, const ['ITEM_SIZE', 'item_size']),
//       color: _str(json, const ['COLOR', 'color']),
//       brand: _str(json, const ['BRAND', 'brand']),
//     );
//   }
//
//   // ── Private helpers ──────────────────────────────────────────────────────
//
//   static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
//     for (final key in keys) {
//       if (json.containsKey(key)) return json[key];
//     }
//     return null;
//   }
//
//   static String _str(Map<String, dynamic> json, List<String> keys) =>
//       (_pick(json, keys) ?? '').toString().trim();
//
//   static double _dbl(dynamic v) {
//     if (v is num) return v.toDouble();
//     return double.tryParse((v ?? '').toString()) ?? 0.0;
//   }
//
//   static int _int(dynamic v) {
//     if (v is num) return v.toInt();
//     return int.tryParse((v ?? '').toString()) ?? 0;
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Image DTO
// // ─────────────────────────────────────────────────────────────────────────────
//
// class ProductImageDto {
//   final int imageId;
//   final String imagePath;
//   final bool isDefault;
//
//   const ProductImageDto({
//     required this.imageId,
//     required this.imagePath,
//     required this.isDefault,
//   });
//
//   factory ProductImageDto.fromJson(Map<String, dynamic> json) {
//     return ProductImageDto(
//       imageId: _int(_pick(json, const ['IMAGE_ID', 'image_id', 'id', 'ID'])),
//       imagePath: _str(json, const ['IMAGE_PATH', 'image_path', 'path']),
//       isDefault:
//       _int(_pick(json, const ['IS_DEFAULT', 'is_default'])) == 1,
//     );
//   }
//
//   static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
//     for (final key in keys) {
//       if (json.containsKey(key)) return json[key];
//     }
//     return null;
//   }
//
//   static String _str(Map<String, dynamic> json, List<String> keys) =>
//       (_pick(json, keys) ?? '').toString().trim();
//
//   static int _int(dynamic v) {
//     if (v is num) return v.toInt();
//     return int.tryParse((v ?? '').toString()) ?? 0;
//   }
// }