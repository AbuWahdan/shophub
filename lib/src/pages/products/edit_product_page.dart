import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/categories_data.dart';
import '../../../models/category.dart';
import '../../config/size_options.dart';
import '../../design/app_spacing.dart';
import '../../l10n/l10n.dart';
import '../../model/product_api.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/app_text_field.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.product,
    required this.details,
    this.detailsRows = const [],
    this.itemImages = const [],
    required this.currentUser,
  });

  final ApiProduct product;
  final ApiProductDetails details;
  final List<ApiProductDetails> detailsRows;
  final List<ApiItemImage> itemImages;
  final String currentUser;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  final List<_VariantEntry> _variantEntries = [];
  final List<String> _imagePaths = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSubmitting = false;
  final int _defaultImageIndex = 0;
  late final int _itemId;
  Category? _selectedCategory;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final d = widget.details;
    _itemId = d.itemId;
    _nameController = TextEditingController(text: d.itemName);
    _descController = TextEditingController(text: d.itemDesc);
    _selectedCategory = CategoriesData.getCategoryById(d.catId);
    _initializeVariants();
    _initializeImages();
  }

  void _initializeVariants() {
    for (final d in widget.detailsRows) {
      // ITEM_SIZE from the API can be:
      //   • An integer ID  → "5" → findSizeOptionById(5)
      //   • A SIZE_CODE    → "XL" / "EU 42" → code match
      //   • A SIZE_NAME    → "Extra Large"  → name match
      //   • "0" or ""      → no size, leave both dropdowns empty
      final opt = _resolveSize(d.itemSize);
      _variantEntries.add(_VariantEntry(
        detId: d.detId,
        isActive: d.isActive == 1,
        sizeGroupId: opt?.groupId,
        sizeId: opt?.id,
        brand: d.brand,
        color: d.color,
        price: d.itemPrice,
        qty: d.itemQty,
        discount: d.discount,
      ));
    }
  }

  /// Resolves a raw ITEM_SIZE string to a SizeOption using 3-step priority:
  ///  1) Parse as int → findSizeOptionById  (API returns integer ID)
  ///  2) Code match  (e.g. "XL", "EU 42", "32/30")
  ///  3) Name match  (e.g. "Extra Large")
  SizeOption? _resolveSize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == '0') return null;

    // Step 1: numeric → by ID
    final asId = int.tryParse(trimmed);
    if (asId != null && asId > 0) {
      final byId = findSizeOptionById(asId);
      if (byId != null) return byId;
    }

    // Step 2: by SIZE_CODE (case-insensitive)
    final lower = trimmed.toLowerCase();
    for (final list in sizeOptions.values) {
      for (final opt in list) {
        if (opt.code.toLowerCase() == lower) return opt;
      }
    }

    // Step 3: by SIZE_NAME (case-insensitive)
    for (final list in sizeOptions.values) {
      for (final opt in list) {
        if (opt.name.toLowerCase() == lower) return opt;
      }
    }

    return null;
  }

  void _initializeImages() {
    for (final img in widget.itemImages) {
      _imagePaths.add(img.imagePath);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final e in _variantEntries) e.dispose();
    super.dispose();
  }

  int get _totalQty => _variantEntries.fold(
      0, (sum, e) => sum + (int.tryParse(e.qtyController.text) ?? 0));

  // ── Variant active toggle — local only; delete-check runs at save ─────────
  void _toggleVariantActive(int index, bool newValue) {
    setState(() {
      final e = _variantEntries[index];
      e.isActive = newValue;
      e.pendingDeactivate = !newValue && !e.isNew;
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      AppSnackBar.show(context,
          message: 'Please select a category', type: AppSnackBarType.warning);
      return;
    }
    if (_variantEntries.isEmpty) {
      AppSnackBar.show(context,
          message: 'Add at least one variant', type: AppSnackBarType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // ── Step 1: pending deactivations ────────────────────────────────────
      final toHardDelete = <int>{};
      for (final e
      in _variantEntries.where((e) => !e.isNew && e.pendingDeactivate)) {
        try {
          final deleted = await _productService.deleteVariantDetail(e.detId!);
          if (deleted) toHardDelete.add(e.detId!);
        } catch (_) {
          // fall through → include with is_active=0
        }
      }

      // ── Step 2: update existing variants ─────────────────────────────────
      final existingDetails = <UpdateItemDetail>[];
      for (final e in _variantEntries.where((e) => !e.isNew)) {
        if (toHardDelete.contains(e.detId)) continue;
        final price = double.tryParse(e.priceController.text.trim()) ?? 0;
        if (price <= 0) throw 'All variants must have a price > 0';

        // Derive SIZE_CODE from the selected sizeId at submit time
        final sizeOpt =
        e.sizeId != null ? findSizeOptionById(e.sizeId!) : null;
        final sizeCode = sizeOpt?.code ?? '';

        existingDetails.add(UpdateItemDetail(
          detailId: e.detId!,
          itemPrice: price,
          itemQty: int.tryParse(e.qtyController.text.trim()) ?? 0,
          brand: e.brandController.text.trim().isEmpty
              ? 'N/A'
              : e.brandController.text.trim(),
          color: e.colorController.text.trim().isEmpty
              ? 'N/A'
              : e.colorController.text.trim(),
          modifiedBy: widget.currentUser,
          size: sizeCode, // SIZE_CODE string (e.g. "XL", "42")
          isActive: e.isActive ? 1 : 0,
        ));
      }

      // product is_active = 1 if any variant is active
      final productIsActive =
      existingDetails.any((d) => d.isActive == 1) ? 1 : 0;

      await _productService.updateProduct(UpdateProductRequest(
        id: _itemId,
        itemName: _nameController.text.trim(),
        itemDesc: _descController.text.trim(),
        isActive: productIsActive,
        itemDetails: existingDetails,
        categoryId: _selectedCategory!.id,
        itemImgUrl: _imagePaths.isNotEmpty ? _imagePaths.first : null,
      ));

      // ── Step 3: insert new variants ───────────────────────────────────────
      final newEntries = _variantEntries.where((e) => e.isNew).toList();
      if (newEntries.isNotEmpty) {
        final insertDetails = <CreateProductDetail>[];
        for (final e in newEntries) {
          final price = double.tryParse(e.priceController.text.trim()) ?? 0;
          if (price <= 0) throw 'New variant price must be > 0';

          final sizeOpt =
          e.sizeId != null ? findSizeOptionById(e.sizeId!) : null;
          final sizeCode = sizeOpt?.code ?? '';

          insertDetails.add(CreateProductDetail(
            brand: e.brandController.text.trim().isEmpty
                ? 'N/A'
                : e.brandController.text.trim(),
            color: e.colorController.text.trim().isEmpty
                ? 'N/A'
                : e.colorController.text.trim(),
            itemSize: sizeCode, // String SIZE_CODE
            itemPrice: price,
            itemQty: int.tryParse(e.qtyController.text.trim()) ?? 0,
            discount: double.tryParse(e.discountController.text.trim()) ?? 0,
            isActive: e.isActive ? 1 : 0,
          ));
        }
        await _productService.insertProductDetails(
          itemId: _itemId,
          details: insertDetails,
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
                _buildVariants(context),
                const SizedBox(height: AppSpacing.xl),
                _buildImages(context),
                const SizedBox(height: AppSpacing.xl),
                _buildCategorySection(context, l10n),
                // ← is_active toggle REMOVED from here
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
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
              ]),
        ),
      ]),
    );
  }

  Widget _buildBasicInfo(BuildContext context, dynamic l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(context, 'Basic Information', Icons.info_outline),
      const SizedBox(height: AppSpacing.lg),
      AppTextField(
        controller: _nameController,
        label: l10n.productItemName,
        hintText: l10n.productItemNameHint,
        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
      ),
      const SizedBox(height: AppSpacing.lg),
      AppTextField(
        controller: _descController,
        label: l10n.productDescriptionLabel,
        hintText: l10n.productDescriptionHint,
        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
      ),
    ]);
  }

  Widget _buildVariants(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _variantEntries.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (_, i) =>
              _buildVariantCard(context, i, _variantEntries[i]),
        ),
      const SizedBox(height: AppSpacing.lg),
      OutlinedButton.icon(
        onPressed: _isSubmitting
            ? null
            : () => setState(() => _variantEntries.add(_VariantEntry())),
        icon: const Icon(Icons.add),
        label: const Text('Add Variant'),
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48)),
      ),
    ]);
  }

  /// Variant card — identical pattern to InsertProductPage._buildVariantCard.
  /// Size group + size are stored directly on _VariantEntry and updated via
  /// setState on the PARENT, exactly like the working insert page.
  Widget _buildVariantCard(
      BuildContext context, int index, _VariantEntry entry) {
    // The sizes available for the currently selected group
    final groupSizes =
    (sizeOptions[entry.sizeGroupId] ?? <SizeOption>[]);

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(children: [
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
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Remove',
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() {
                  entry.dispose();
                  _variantEntries.removeAt(index);
                }),
              )
            else
            // Active/inactive toggle for existing variants
              Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(
                  child: Text(
                    entry.isActive ? 'Active' : 'Inactive',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: entry.isActive
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(
                  value: entry.isActive,
                  activeColor: Colors.green,
                  onChanged: _isSubmitting
                      ? null
                      : (val) => _toggleVariantActive(index, val),
                ),
              ]),
          ]),

          if (!entry.isActive && entry.pendingDeactivate)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'Will be removed or deactivated on save',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error),
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          // ── Brand / Color ────────────────────────────────────────────────
          Row(children: [
            Expanded(
              child: AppTextField(
                controller: entry.brandController,
                label: 'Brand',
                hintText: 'Brand name',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: entry.colorController,
                label: 'Color',
                hintText: 'Color',
              ),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // ── Size Group dropdown ──────────────────────────────────────────
          // Pattern copied exactly from InsertProductPage:
          // • value comes from entry.sizeGroupId (always current, always valid)
          // • setState on parent updates the entry and rebuilds the card
          // • No separate StatefulWidget — no stale state issues
          DropdownButtonFormField<int>(
            value: entry.sizeGroupId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Size Group',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
            ),
            hint: const Text('Select group (optional)',
                overflow: TextOverflow.ellipsis),
            items: sizeGroups
                .map((g) => DropdownMenuItem<int>(
              value: g.id,
              child: Text(g.name,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
            ))
                .toList(),
            onChanged: _isSubmitting
                ? null
                : (val) {
              setState(() {
                entry.sizeGroupId = val;
                // Clear size if it no longer belongs to new group
                final options = sizeOptions[val] ?? [];
                if (val == null ||
                    options.every((o) => o.id != entry.sizeId)) {
                  entry.sizeId = null;
                }
              });
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Size dropdown (filtered by group) ────────────────────────────
          DropdownButtonFormField<int>(
            value: entry.sizeId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Size',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
            ),
            hint: Text(
              entry.sizeGroupId == null
                  ? 'Select a group first'
                  : 'Select size (optional)',
              overflow: TextOverflow.ellipsis,
            ),
            items: groupSizes
                .map((s) => DropdownMenuItem<int>(
              value: s.id,
              child: Text(s.name,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
            ))
                .toList(),
            onChanged: (_isSubmitting || entry.sizeGroupId == null)
                ? null
                : (val) {
              setState(() => entry.sizeId = val);
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Price / Qty / Discount ───────────────────────────────────────
          Row(children: [
            Expanded(
              child: AppTextField(
                controller: entry.priceController,
                label: 'Price',
                hintText: '0.00',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: entry.qtyController,
                label: 'Qty',
                hintText: '0',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: entry.discountController,
                label: 'Disc %',
                hintText: '0',
                keyboardType: TextInputType.number,
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildImages(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(context, 'Product Images', Icons.image_outlined),
      const SizedBox(height: AppSpacing.lg),
      if (_imagePaths.isEmpty)
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
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _imagePaths.length,
          itemBuilder: (_, i) => _buildImageTile(context, i),
        ),
      const SizedBox(height: AppSpacing.lg),
      OutlinedButton.icon(
        onPressed: _isSubmitting ? null : _pickImage,
        icon: const Icon(Icons.image_outlined),
        label: const Text('Add Image'),
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48)),
      ),
    ]);
  }

  Widget _buildImageTile(BuildContext context, int index) {
    return Stack(fit: StackFit.expand, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imagePaths[index],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Theme.of(context).dividerColor,
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
      Positioned(
        top: 4,
        right: 4,
        child: GestureDetector(
          onTap: _isSubmitting
              ? null
              : () => setState(() => _imagePaths.removeAt(index)),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.85),
                borderRadius: BorderRadius.circular(50)),
            padding: const EdgeInsets.all(4),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ),
      ),
      if (index == _defaultImageIndex)
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(50)),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: const Text('Default',
                style: TextStyle(color: Colors.white, fontSize: 10),
                overflow: TextOverflow.ellipsis),
          ),
        ),
    ]);
  }

  // is_active toggle removed — product active state is derived from variants
  Widget _buildCategorySection(BuildContext context, dynamic l10n) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(context, 'Category', Icons.category_outlined),
      const SizedBox(height: AppSpacing.lg),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: DropdownButtonFormField<Category>(
          value: _selectedCategory,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.productCategory,
            border: InputBorder.none,
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
    ]);
  }

  Widget _buildActions(BuildContext context, dynamic l10n) {
    return Column(children: [
      AppButton(
        label: l10n.productUpdateAction,
        leading: _isSubmitting
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
              AlwaysStoppedAnimation<Color>(Colors.white)),
        )
            : null,
        onPressed: _isSubmitting ? null : _updateProduct,
      ),
      const SizedBox(height: AppSpacing.md),
      OutlinedButton(
        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48)),
        child:
        Text(context.l10n.commonCancel, overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  Future<void> _pickImage() async {
    try {
      final result = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (result != null && mounted) {
        setState(() => _imagePaths.add(result.path));
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context,
            message: 'Failed to pick image', type: AppSnackBarType.error);
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _VariantEntry — plain Dart object (no widget state)
// sizeGroupId / sizeId stored here and read by the parent's setState.
// This is the same pattern as _VariantFormEntry in InsertProductPage.
// ══════════════════════════════════════════════════════════════════════════════
class _VariantEntry {
  final int? detId;
  bool isActive;
  bool pendingDeactivate;

  /// Drives the Size Group dropdown directly
  int? sizeGroupId;

  /// Drives the Size dropdown directly
  int? sizeId;

  final TextEditingController brandController;
  final TextEditingController colorController;
  final TextEditingController priceController;
  final TextEditingController qtyController;
  final TextEditingController discountController;

  _VariantEntry({
    this.detId,
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
        priceController =
        TextEditingController(text: price > 0 ? price.toString() : ''),
        qtyController =
        TextEditingController(text: qty > 0 ? qty.toString() : ''),
        discountController =
        TextEditingController(text: discount > 0 ? discount.toString() : '');

  bool get isNew => detId == null || detId! <= 0;

  void dispose() {
    brandController.dispose();
    colorController.dispose();
    priceController.dispose();
    qtyController.dispose();
    discountController.dispose();
  }
}