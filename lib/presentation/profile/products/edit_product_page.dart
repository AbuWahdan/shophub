import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/image_converter.dart';
import '../../../../data/categories_data.dart';
import '../../../../models/category.dart';
import '../../../../models/product_api.dart';
import '../../../../models/product_image_model.dart';
import '../../../core/config/size_options.dart';
import '../../../design/app_spacing.dart';
import '../../../l10n/l10n.dart';
import '../../../core/app/app_theme.dart';
import '../../../services/product_service.dart';
import '../../../widgets/gallery_section/gallery_viewer.dart';
import '../../../widgets/widgets/app_button.dart';
import '../../../widgets/widgets/app_snackbar.dart';
import '../../../widgets/widgets/app_text_field.dart';
import '../../../widgets/widgets/color_picker/color_hex_field.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.product,
    required this.details,
    this.detailsRows = const [],
    this.itemImages  = const [],
    required this.currentUser,
  });

  final ApiProduct             product;
  final ApiProductDetails      details;
  final List<ApiProductDetails> detailsRows;
  final List<ProductImageModel> itemImages;
  final String                  currentUser;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey         = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  final List<_VariantEntry>      _variantEntries  = [];
  final List<ProductImageModel>  _itemImages      = [];
  final ImagePicker              _imagePicker     = ImagePicker();

  bool  _isSubmitting     = false;
  bool  _isUploadingImage = false;
  int?  _defaultImageId;
  late final int _itemId;
  Category? _selectedCategory;

  // FIX: Global product is_active toggle.
  // Shown and editable only on the edit screen.
  // Initialized from the product that was passed in.
  late bool _isProductActive;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final d = widget.details;
    _itemId            = d.itemId;
    _nameController    = TextEditingController(text: d.itemName);
    _descController    = TextEditingController(text: d.itemDesc);
    _selectedCategory  = CategoriesData.getCategoryById(d.catId);

    // FIX: read is_active from the product (1 = active, anything else = inactive)
    _isProductActive   = widget.product.isActive == 1;

    _initializeVariants();
    _initializeImages();
  }

  void _initializeVariants() {
    for (final d in widget.detailsRows) {
      final opt = _resolveSize(d.itemSize);
      _variantEntries.add(_VariantEntry(
        detId:       d.detId,
        isActive:    d.isActive == 1,
        sizeGroupId: opt?.groupId,
        sizeId:      opt?.id,
        brand:       d.brand,
        color:       d.color,
        price:       d.itemPrice,
        qty:         d.itemQty,
        discount:    d.discount,
      ));
    }
  }

  /// Resolves a raw ITEM_SIZE string to a SizeOption (3-step priority).
  SizeOption? _resolveSize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == '0') return null;

    // 1) Parse as int → by ID
    final asId = int.tryParse(trimmed);
    if (asId != null && asId > 0) {
      final byId = findSizeOptionById(asId);
      if (byId != null) return byId;
    }

    // 2) By SIZE_CODE (case-insensitive)
    final lower = trimmed.toLowerCase();
    for (final list in sizeOptions.values) {
      for (final opt in list) {
        if (opt.code.toLowerCase() == lower) return opt;
      }
    }

    // 3) By SIZE_NAME (case-insensitive)
    for (final list in sizeOptions.values) {
      for (final opt in list) {
        if (opt.name.toLowerCase() == lower) return opt;
      }
    }
    return null;
  }

  void _initializeImages() {
    for (final img in widget.itemImages) {
      _itemImages.add(img);
      if (img.isDefault) _defaultImageId = img.imageId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final e in _variantEntries) {
      e.dispose();
    }
    super.dispose();
  }

  // ── Variant active toggle ─────────────────────────────────────────────────

  void _toggleVariantActive(int index, bool newValue) {
    setState(() {
      final e = _variantEntries[index];
      e.isActive         = newValue;
      e.pendingDeactivate = !newValue && !e.isNew;
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      AppSnackBar.show(context,
          message: 'Please select a category',
          type: AppSnackBarType.warning);
      return;
    }
    if (_variantEntries.isEmpty) {
      AppSnackBar.show(context,
          message: 'Add at least one variant',
          type: AppSnackBarType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Step 1 — pending deactivations
      final toHardDelete = <int>{};
      for (final e in _variantEntries.where(
              (e) => !e.isNew && e.pendingDeactivate)) {
        try {
          final deleted =
          await _productService.deleteVariantDetail(e.detId!);
          if (deleted) toHardDelete.add(e.detId!);
        } catch (_) {}
      }

      // Step 2 — update existing variants
      final existingDetails = <UpdateItemDetail>[];
      for (final e in _variantEntries.where((e) => !e.isNew)) {
        if (toHardDelete.contains(e.detId)) continue;
        final price = double.tryParse(e.priceController.text.trim()) ?? 0;
        if (price <= 0) throw 'All variants must have a price > 0';
        final sizeOpt =
        e.sizeId != null ? findSizeOptionById(e.sizeId!) : null;
        existingDetails.add(UpdateItemDetail(
          detailId:     e.detId!,
          itemPrice:    price,
          itemQty:      int.tryParse(e.qtyController.text.trim()) ?? 0,
          itemDiscount: double.tryParse(e.discountController.text.trim()) ?? 0,
          brand: e.brandController.text.trim().isEmpty
              ? 'N/A'
              : e.brandController.text.trim(),
          color: e.colorController.text.trim().isEmpty
              ? 'N/A'
              : e.colorController.text.trim(),
          modifiedBy: widget.currentUser,
          size:       sizeOpt?.code ?? '',
          isActive:   e.isActive ? 1 : 0,
        ));
      }

      // FIX: Use the explicit _isProductActive toggle instead of deriving
      // from variant state.  The seller sets this deliberately.
      await _productService.updateProduct(UpdateProductRequest(
        id:          _itemId,
        itemName:    _nameController.text.trim(),
        itemDesc:    _descController.text.trim(),
        isActive:    _isProductActive ? 1 : 0,
        itemDetails: existingDetails,
        categoryId:  _selectedCategory!.id,
        itemImgUrl:  widget.product.itemImgUrl.trim().isEmpty
            ? null
            : widget.product.itemImgUrl,
      ));

      // Step 3 — insert new variants
      final newEntries = _variantEntries.where((e) => e.isNew).toList();
      if (newEntries.isNotEmpty) {
        final insertDetails = <CreateProductDetail>[];
        for (final e in newEntries) {
          final price = double.tryParse(e.priceController.text.trim()) ?? 0;
          if (price <= 0) throw 'New variant price must be > 0';
          final sizeOpt =
          e.sizeId != null ? findSizeOptionById(e.sizeId!) : null;
          insertDetails.add(CreateProductDetail(
            brand: e.brandController.text.trim().isEmpty
                ? 'N/A'
                : e.brandController.text.trim(),
            color: e.colorController.text.trim().isEmpty
                ? 'N/A'
                : e.colorController.text.trim(),
            itemSize:  sizeOpt?.code ?? '',
            itemPrice: price,
            itemQty:   int.tryParse(e.qtyController.text.trim()) ?? 0,
            discount:  double.tryParse(e.discountController.text.trim()) ?? 0,
            isActive:  e.isActive ? 1 : 0,
          ));
        }
        await _productService.insertProductDetails(
          itemId:    _itemId,
          details:   insertDetails,
          createdBy: widget.currentUser,
        );
      }

      if (!mounted) return;
      AppSnackBar.show(context,
          message: 'Product updated successfully',
          type: AppSnackBarType.success);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context,
          message: 'Error: $e', type: AppSnackBarType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productEditTitle, overflow: TextOverflow.ellipsis),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xl),
                _buildBasicInfo(context, l10n),
                const SizedBox(height: AppSpacing.xl),
                // FIX: global is_active toggle — visible and editable
                // on the edit screen only.
                _buildActiveToggle(context),
                const SizedBox(height: AppSpacing.xl),
                _buildVariants(context),
                const SizedBox(height: AppSpacing.xl),
                _buildImages(context),
                const SizedBox(height: AppSpacing.xl),
                _buildCategorySection(context, l10n),
                const SizedBox(height: AppSpacing.xl),
                _buildActions(context, l10n),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIX: New widget — shows and controls the global product is_active flag.
  Widget _buildActiveToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isProductActive
              ? Colors.green.withOpacity(0.4)
              : Theme.of(context).colorScheme.error.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        title: const Text('Product active',
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          _isProductActive
              ? 'Visible to customers'
              : 'Hidden from customers',
          style: TextStyle(
            color: _isProductActive
                ? Colors.green
                : Theme.of(context).colorScheme.error,
            fontSize: 12,
          ),
        ),
        secondary: Icon(
          _isProductActive
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: _isProductActive
              ? Colors.green
              : Theme.of(context).colorScheme.error,
        ),
        value:       _isProductActive,
        activeColor: Colors.green,
        onChanged:   _isSubmitting
            ? null
            : (val) => setState(() => _isProductActive = val),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color:        Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color:        Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_bag_outlined,
                color: Theme.of(context).primaryColor, size: 28),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product ID: $_itemId',
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.xs),
                Text('Editing product details',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Basic Information', Icons.info_outline),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _nameController,
          label:      l10n.productItemName,
          hintText:   l10n.productItemNameHint,
          validator:  (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _descController,
          label:      l10n.productDescriptionLabel,
          hintText:   l10n.productDescriptionHint,
          validator:  (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildVariants(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Variants', Icons.tune),
        const SizedBox(height: AppSpacing.lg),
        if (_variantEntries.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('No variants yet',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics:    const NeverScrollableScrollPhysics(),
            itemCount:  _variantEntries.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (_, i) =>
                _buildVariantCard(context, i, _variantEntries[i]),
          ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: _isSubmitting
              ? null
              : () => setState(() => _variantEntries.add(_VariantEntry())),
          icon:  const Icon(Icons.add),
          label: const Text('Add Variant'),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48)),
        ),
      ],
    );
  }

  Widget _buildVariantCard(
      BuildContext context, int index, _VariantEntry entry) {
    final l10n      = context.l10n;
    final groupSizes = sizeOptions[entry.sizeGroupId] ?? <SizeOption>[];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: entry.isActive
              ? Theme.of(context).dividerColor
              : Theme.of(context).colorScheme.error.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Variant ${index + 1}${entry.isNew ? ' (new)' : ''}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                if (entry.isNew)
                  IconButton(
                    icon:    const Icon(Icons.close, size: 20),
                    tooltip: 'Remove',
                    onPressed: _isSubmitting
                        ? null
                        : () => setState(() {
                      entry.dispose();
                      _variantEntries.removeAt(index);
                    }),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          entry.isActive ? 'Active' : 'Inactive',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                            color: entry.isActive
                                ? Colors.green
                                : Theme.of(context).colorScheme.error,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Switch(
                        value:           entry.isActive,
                        activeThumbColor: Colors.green,
                        onChanged: _isSubmitting
                            ? null
                            : (val) => _toggleVariantActive(index, val),
                      ),
                    ],
                  ),
              ],
            ),

            if (!entry.isActive && entry.pendingDeactivate)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Will be removed or deactivated on save',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: entry.brandController,
                    label:      l10n.productBrand,
                    hintText:   l10n.productBrandHint,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ColorHexField(
                    initialColor:   entry.colorController.text,
                    label:          l10n.productColor,
                    onColorChanged: (v) => entry.colorController.text = v,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<int>(
              initialValue: entry.sizeGroupId,
              isExpanded:   true,
              decoration: InputDecoration(
                labelText:      l10n.productSizeGroup,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
              ),
              hint: Text(l10n.productSelectGroupOptional,
                  overflow: TextOverflow.ellipsis),
              items: sizeGroups
                  .map((g) => DropdownMenuItem<int>(
                  value: g.id,
                  child: Text(g.name,
                      overflow: TextOverflow.ellipsis, maxLines: 1)))
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (val) {
                setState(() {
                  entry.sizeGroupId = val;
                  final options = sizeOptions[val] ?? [];
                  if (val == null ||
                      options.every((o) => o.id != entry.sizeId)) {
                    entry.sizeId = null;
                  }
                });
              },
            ),

            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<int>(
              initialValue: entry.sizeId,
              isExpanded:   true,
              decoration: InputDecoration(
                labelText: l10n.productSize,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
              ),
              hint: Text(
                entry.sizeGroupId == null
                    ? l10n.productSelectGroupFirst
                    : l10n.productSelectSizeOptional,
                overflow: TextOverflow.ellipsis,
              ),
              items: groupSizes
                  .map((s) => DropdownMenuItem<int>(
                  value: s.id,
                  child: Text(s.name,
                      overflow: TextOverflow.ellipsis, maxLines: 1)))
                  .toList(),
              onChanged: (_isSubmitting || entry.sizeGroupId == null)
                  ? null
                  : (val) => setState(() => entry.sizeId = val),
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller:   entry.priceController,
                    label:        'Price',
                    hintText:     '0.00',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller:   entry.qtyController,
                    label:        'Qty',
                    hintText:     '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller:   entry.discountController,
                    label:        l10n.productDiscountLabel,
                    hintText:     l10n.productDiscountHint,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: _validateDiscount,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Images section ─────────────────────────────────────────────────────────

  Widget _buildImages(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Product Images', Icons.image_outlined),
        const SizedBox(height: AppSpacing.lg),
        if (_itemImages.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('No images yet',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics:    const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   3,
              crossAxisSpacing: 8,
              mainAxisSpacing:  8,
            ),
            itemCount: _itemImages.length + 1,
            itemBuilder: (_, i) {
              if (i == _itemImages.length) return _buildAddImageTile(context);
              return _buildImageTile(context, i);
            },
          ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: (_isSubmitting || _isUploadingImage) ? null : _pickImage,
          icon:  const Icon(Icons.image_outlined),
          label: Text(_isUploadingImage ? 'Uploading...' : 'Add Image'),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48)),
        ),
      ],
    );
  }

  Widget _buildAddImageTile(BuildContext context) {
    return InkWell(
      onTap:        (_isSubmitting || _isUploadingImage) ? null : _pickImage,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: Theme.of(context).dividerColor),
          color:        Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined),
            const SizedBox(height: 8),
            Text(
              _isUploadingImage ? 'Uploading' : 'Add',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, int index) {
    final image    = _itemImages[index];
    final bytes    = ImageConverter.base64ToBytes(image.imageBase64);
    final isDefault = image.isDefault ||
        (_defaultImageId != null && image.imageId == _defaultImageId);

    // Build the image widget — try bytes first (new upload), then network URL.
    Widget imageWidget;
    if (bytes != null) {
      imageWidget = Image.memory(bytes, fit: BoxFit.cover);
    } else if (image.imagePath.trim().isNotEmpty) {
      imageWidget = Image.network(
        image.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Theme.of(context).dividerColor,
          child: const Icon(Icons.broken_image_outlined),
        ),
      );
    } else {
      imageWidget = Container(
        color: Theme.of(context).dividerColor,
        child: const Icon(Icons.broken_image_outlined),
      );
    }

    // Build a flat list of displayable paths for GalleryViewer.
    List<String> _galleryPaths() => _itemImages.map((img) {
      if (img.imagePath.trim().isNotEmpty) return img.imagePath.trim();
      // No URL — pass base64 with a prefix so GalleryViewer can decode it
      return 'base64:${img.imageBase64}';
    }).toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        // FIX: Tapping the image opens GalleryViewer (full-screen viewer).
        GestureDetector(
          onTap: _isSubmitting
              ? null
              : () => GalleryViewer.show(
            context,
            images:       _galleryPaths(),
            initialIndex: index,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          ),
        ),

        // Default star (top-left indicator)
        Positioned(
          top:  6,
          left: 6,
          child: Icon(
            isDefault ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isDefault ? Colors.amber : Colors.white,
            size:  20,
          ),
        ),

        // "Default" badge at bottom
        if (isDefault)
          Positioned(
            bottom: 4,
            left:   4,
            child: Container(
              decoration: BoxDecoration(
                color:        Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: const Text('Default',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  overflow: TextOverflow.ellipsis),
            ),
          ),

        // "Set default" tap target (separate from the image tap)
        if (!isDefault)
          Positioned(
            right:  6,
            bottom: 6,
            child: GestureDetector(
              onTap: (_isSubmitting || _isUploadingImage)
                  ? null
                  : () => _setDefaultImage(image),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color:        Colors.black54,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Set default',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Category', Icons.category_outlined),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color:        Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: Theme.of(context).dividerColor),
          ),
          child: DropdownButtonFormField<Category>(
            initialValue: _selectedCategory,
            isExpanded:   true,
            decoration: InputDecoration(
              labelText:      l10n.productCategory,
              border:         InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            ),
            items: CategoriesData.getAllCategoriesFlat()
                .map((c) => DropdownMenuItem(
              value: c,
              child: Text(
                c.parentId == null ? c.name : '  - ${c.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ))
                .toList(),
            onChanged: _isSubmitting
                ? null
                : (v) => setState(() => _selectedCategory = v),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, dynamic l10n) {
    return Column(
      children: [
        AppButton(
          label: context.l10n.productUpdateAction,
          leading: _isSubmitting
              ? const SizedBox(
              width:  18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth:  2,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              ))
              : null,
          onPressed: _isSubmitting ? null : _updateProduct,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48)),
          child: Text(context.l10n.commonCancel,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color:        Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String? _validateDiscount(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0 || parsed > 100) {
      return context.l10n.productDiscountInvalidRange;
    }
    return null;
  }

  // ── Image helpers ──────────────────────────────────────────────────────────

  Future<void> _reloadImages() async {
    final images =
    await _productService.getItemImagesBase64(itemId: _itemId);
    if (!mounted) return;
    setState(() {
      _itemImages
        ..clear()
        ..addAll(images);
      final di = images.indexWhere((img) => img.isDefault);
      _defaultImageId = di == -1 ? null : images[di].imageId;
    });
  }

  Future<void> _setDefaultImage(ProductImageModel image) async {
    setState(() => _isUploadingImage = true);
    try {
      await _productService.setDefaultItemImage(
        imageId:     image.imageId,
        imageBase64: image.imageBase64,
      );
      await _reloadImages();
      if (!mounted) return;
      AppSnackBar.show(context,
          message: 'Default image updated',
          type: AppSnackBarType.success);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context,
          message: 'Failed to update default image',
          type: AppSnackBarType.error);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final result =
      await _imagePicker.pickImage(source: ImageSource.gallery);
      if (result == null) return;

      final base64 =
      await ImageConverter.compressAndConvert(File(result.path));
      if (base64 == null) {
        if (!mounted) return;
        AppSnackBar.show(context,
            message: 'Failed to process image',
            type: AppSnackBarType.error);
        return;
      }

      if (mounted) setState(() => _isUploadingImage = true);

      await _productService.insertItemImage(
        itemId:      _itemId,
        imageBase64: base64,
        isDefault:   _itemImages.isEmpty,
      );
      await _reloadImages();
      if (!mounted) return;
      AppSnackBar.show(context,
          message: 'Image uploaded successfully',
          type: AppSnackBarType.success);
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context,
            message: 'Failed to pick image',
            type: AppSnackBarType.error);
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _VariantEntry
// ─────────────────────────────────────────────────────────────────────────────
class _VariantEntry {
  final int? detId;
  bool isActive;
  bool pendingDeactivate;
  int? sizeGroupId;
  int? sizeId;

  final TextEditingController brandController;
  final TextEditingController colorController;
  final TextEditingController priceController;
  final TextEditingController qtyController;
  final TextEditingController discountController;

  _VariantEntry({
    this.detId,
    this.isActive     = true,
    this.sizeGroupId,
    this.sizeId,
    String brand      = '',
    String color      = '',
    double price      = 0,
    int    qty        = 0,
    double discount   = 0,
  }) : pendingDeactivate  = false,
        brandController    = TextEditingController(text: brand),
        colorController    = TextEditingController(text: color),
        priceController    = TextEditingController(
            text: price > 0 ? price.toString() : ''),
        qtyController      = TextEditingController(
            text: qty > 0 ? qty.toString() : ''),
        discountController = TextEditingController(
            text: discount > 0 ? discount.toString() : '');

  bool get isNew => detId == null || detId! <= 0;

  void dispose() {
    brandController.dispose();
    colorController.dispose();
    priceController.dispose();
    qtyController.dispose();
    discountController.dispose();
  }
}