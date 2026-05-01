import 'package:flutter/material.dart';

/// Holds all mutable state for a single product variant form row.
/// Used on both [InsertProductPage] and [EditProductPage].
class VariantFormEntry {
  VariantFormEntry({
    this.detailId,
    this.isActive = true,
    this.sizeGroupId,
    this.sizeId,
    String brand = '',
    String color = '',
    double price = 0,
    int qty = 0,
    double discount = 0,
  })  : pendingDeactivate = false,
        brandController = TextEditingController(text: brand),
        colorController = TextEditingController(text: color),
        priceController = TextEditingController(
          text: price > 0 ? price.toString() : '',
        ),
        qtyController = TextEditingController(
          text: qty > 0 ? qty.toString() : '',
        ),
        discountController = TextEditingController(
          text: discount > 0 ? discount.toString() : '',
        );

  /// Null or <= 0 means this is a brand-new (unsaved) variant.
  final int? detailId;

  bool isActive;

  /// Marks an existing variant to be hard-deleted on save.
  bool pendingDeactivate;

  int? sizeGroupId;
  int? sizeId;

  final TextEditingController brandController;
  final TextEditingController colorController;
  final TextEditingController priceController;
  final TextEditingController qtyController;
  final TextEditingController discountController;

  bool get isNew => detailId == null || detailId! <= 0;

  void dispose() {
    brandController.dispose();
    colorController.dispose();
    priceController.dispose();
    qtyController.dispose();
    discountController.dispose();
  }
}