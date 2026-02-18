import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import '../../../data/categories_data.dart';
import '../../../models/category.dart';
import '../../design/app_spacing.dart';
import '../../l10n/l10n.dart';
import '../../model/product_api.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../themes/theme.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.product,
    required this.details,
    this.itemImages = const [],
  });

  final ApiProduct product;
  final ApiProductDetails details;
  final List<ApiItemImage> itemImages;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _qtyController;
  late final TextEditingController _imageUrlController;

  bool _isSubmitting = false;
  late final int _itemId;
  late final int _detId;
  late final int _imageId;
  late final int _catId;
  late final String _category;
  late final String _itemOwner;
  late final int _reviews;
  late final double _rating;
  late final int _itemSize;
  late final String _color;
  late final String _brand;
  late bool _isActive;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final details = widget.details;
    _itemId = details.itemId;
    _detId = details.detId;
    _imageId = details.imageId;
    _catId = details.catId;
    _category = details.category;
    _itemOwner = details.itemOwner;
    _reviews = details.reviews;
    _rating = details.rating;
    _itemSize = details.itemSize;
    _color = details.color;
    _brand = details.brand;
    _nameController = TextEditingController(text: details.itemName);
    _descController = TextEditingController(text: details.itemDesc);
    _priceController = TextEditingController(
      text: details.itemPrice.toString(),
    );
    // Quantity is not part of GetItemDetails response, keep existing list value.
    _qtyController = TextEditingController(
      text: widget.product.itemQty.toString(),
    );
    final defaultImagePath = widget.itemImages.isNotEmpty
        ? widget.itemImages.first.imagePath
        : details.itemImgUrl;
    _imageUrlController = TextEditingController(text: defaultImagePath);
    _isActive = details.isActive == 1;
    _selectedCategory = CategoriesData.getCategoryById(details.catId);
    if (_selectedCategory == null) {
      _loadCategoryById(details.catId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.productEditTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: l10n.productItemName,
                  hintText: l10n.productItemNameHint,
                  validator: _requiredValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _descController,
                  label: l10n.productDescriptionLabel,
                  hintText: l10n.productDescriptionHint,
                  validator: _requiredValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _priceController,
                  label: l10n.productPriceLabel,
                  hintText: l10n.productPriceHint,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _positiveDoubleValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _qtyController,
                  label: l10n.productQuantityLabel,
                  hintText: l10n.productQuantityHint,
                  keyboardType: TextInputType.number,
                  validator: _positiveIntValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _imageUrlController,
                  label: l10n.productImageUrlLabel,
                  hintText: l10n.productImageUrlHint,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<Category>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: l10n.productCategory,
                    hintText: l10n.productCategoryHint,
                  ),
                  items: CategoriesData.getAllCategoriesFlat()
                      .map(
                        (category) => DropdownMenuItem<Category>(
                          value: category,
                          child: Text(
                            category.parentId == null
                                ? category.name
                                : '  - ${category.name}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) => setState(() => _selectedCategory = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.productIsActive),
                  value: _isActive,
                  onChanged: _isSubmitting
                      ? null
                      : (value) => setState(() => _isActive = value),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: l10n.productUpdateAction,
                  leading: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onPressed: _isSubmitting ? null : _updateProduct,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return context.l10n.productRequiredField;
    }
    return null;
  }

  String? _positiveDoubleValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return context.l10n.productRequiredField;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) return context.l10n.productInvalidValue;
    return null;
  }

  String? _positiveIntValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return context.l10n.productRequiredField;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 0) return context.l10n.productInvalidValue;
    return null;
  }

  Future<void> _loadCategoryById(int categoryId) async {
    try {
      final category = await _productService.loadCategoryById(categoryId);
      if (!mounted || category == null) return;
      setState(() {
        _selectedCategory = CategoriesData.getCategoryById(category.id);
      });
    } on ProductException {
      // Keep current UI behavior if API category lookup fails.
    } catch (_) {
      // Keep current UI behavior if API category lookup fails.
    }
  }

  Future<void> _updateProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory == null) {
      AppSnackBar.show(
        context,
        message: context.l10n.productSelectCategoryValidation,
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (kDebugMode) {
        debugPrint(
          'Edit metadata => detId: $_detId, imageId: $_imageId, catId: $_catId, '
          'category: $_category, owner: $_itemOwner, reviews: $_reviews, '
          'rating: $_rating, itemSize: $_itemSize, color: $_color, brand: $_brand',
        );
      }
      final request = UpdateProductRequest(
        id: _itemId,
        itemName: _nameController.text.trim(),
        itemDesc: _descController.text.trim(),
        itemPrice: double.parse(_priceController.text.trim()),
        itemQty: int.parse(_qtyController.text.trim()),
        itemImgUrl: _imageUrlController.text.trim(),
        categoryId: _selectedCategory!.id,
        isActive: _isActive ? 1 : 0,
      );
      await _productService.updateProduct(request);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: context.l10n.productUpdateSuccess,
        type: AppSnackBarType.success,
      );
      Navigator.pop(context, true);
    } on ProductException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: context.l10n.productUpdateFailed,
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
