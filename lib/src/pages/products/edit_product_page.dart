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
import '../../themes/theme.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.product,
    required this.details,
    this.detailsRows = const [],
    this.itemImages = const [],
    /// The username of the currently-logged-in user.
    /// Used as "modified_by" in the update payload.
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

  final List<_VariantEntry> _variantEntries = <_VariantEntry>[];
  final List<String> _imagePaths = <String>[];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSubmitting = false;
  int _defaultImageIndex = 0;

  late final int _itemId;
  late bool _isActive;
  Category? _selectedCategory;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final details = widget.details;
    _itemId = details.itemId;

    _nameController = TextEditingController(text: details.itemName);
    _descController = TextEditingController(text: details.itemDesc);

    _isActive = details.isActive == 1;
    _selectedCategory = CategoriesData.getCategoryById(details.catId);

    _initializeVariants();
    _initializeImages();
    _syncActiveState();
  }

  void _initializeVariants() {
    for (final detail in widget.detailsRows) {
      _variantEntries.add(
        _VariantEntry(
          detId: detail.detId,
          isActive: detail.isActive == 1,
          brand: detail.brand,
          color: detail.color,
          // Store the original string label from the API (e.g. "ll", "15 inch")
          sizeLabel: detail.itemSize,
          // Also resolve to int-id so the dropdown can show the right option
          sizeId: _findSizeIdByLabel(detail.itemSize),
          price: detail.itemPrice,
          qty: detail.itemQty,
          discount: detail.discount,
        ),
      );
    }
  }

  void _initializeImages() {
    for (final img in widget.itemImages) {
      _imagePaths.add(img.imagePath);
    }
  }

  void _syncActiveState() {
    if (_totalQty <= 0 && _isActive) _isActive = false;
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

  // ── Helpers ──────────────────────────────────────────────────────────────

  int get _totalQty => _variantEntries.fold<int>(
    0,
        (sum, e) => sum + (int.tryParse(e.qtyController.text) ?? 0),
  );

  /// Returns the integer sizeId for a given label string, or 0 if not found.
  int _findSizeIdByLabel(String label) {
    final normalized = label.trim().toLowerCase();
    for (final sizeList in sizeOptions.values) {
      for (final size in sizeList) {
        if (size.name.trim().toLowerCase() == normalized) return size.id;
      }
    }
    return 0;
  }

  /// Returns the label string for a sizeId, falling back to [fallback].
  String _resolveSizeLabel(int sizeId, String fallback) {
    for (final sizeList in sizeOptions.values) {
      for (final size in sizeList) {
        if (size.id == sizeId) return size.name;
      }
    }
    return fallback.isNotEmpty ? fallback : 'N/A';
  }

  // ── Variant active-toggle with delete-check ──────────────────────────────

  /// Called when the is_active Switch on an *existing* variant is toggled.
  ///
  /// Toggle ON  → simply marks the variant active (no API call needed).
  /// Toggle OFF → calls the delete-check endpoint:
  ///   • result == true  (no orders): confirms with user, then removes from list
  ///     (the API has already hard-deleted the record on the server).
  ///   • result == false (has orders): soft-deactivates (is_active = 0); the
  ///     variant stays in the list and will be included in the update payload.
  Future<void> _toggleExistingVariantActive(int index, bool newValue) async {
    final entry = _variantEntries[index];

    // Turning ON — no server call needed.
    if (newValue) {
      setState(() => entry.isActive = true);
      return;
    }

    // Turning OFF — need to ask the server if the variant can be deleted.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Variant'),
        content: const Text(
          'Do you want to deactivate this variant?\n\n'
              'If it has no orders it will be permanently removed. '
              'If it has existing orders it will be deactivated instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => entry.isCheckingDeletion = true);

    try {
      // This endpoint deletes the record if it has no orders (returns true)
      // or blocks deletion if it does have orders (returns false).
      final wasDeleted = await _productService.deleteVariantDetail(entry.detId!);

      if (!mounted) return;

      if (wasDeleted) {
        // Hard-deleted on the server — remove from UI too.
        setState(() {
          entry.dispose();
          _variantEntries.removeAt(index);
        });
        AppSnackBar.show(
          context,
          message: 'Variant removed (no orders found)',
          type: AppSnackBarType.success,
        );
      } else {
        // Has orders — keep the row but mark inactive.
        setState(() {
          entry.isCheckingDeletion = false;
          entry.isActive = false;
        });
        AppSnackBar.show(
          context,
          message: 'Variant deactivated (has existing orders)',
          type: AppSnackBarType.warning,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => entry.isCheckingDeletion = false);
      AppSnackBar.show(
        context,
        message: 'Error checking variant: $e',
        type: AppSnackBarType.error,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.productEditTitle), elevation: 0),
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
                _buildBasicInfoSection(context, l10n),
                const SizedBox(height: AppSpacing.xl),
                _buildVariantsSection(context, l10n),
                const SizedBox(height: AppSpacing.xl),
                _buildImagesSection(context, l10n),
                const SizedBox(height: AppSpacing.xl),
                _buildSettingsSection(context, l10n),
                const SizedBox(height: AppSpacing.xl),
                _buildActionButtons(context, l10n),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section builders ──────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Icon(Icons.shopping_bag_outlined,
                color: Theme.of(context).primaryColor, size: 28),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product ID: $_itemId',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: AppSpacing.xs),
                Text('Editing product details',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Basic Information', Icons.info_outline),
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
      ],
    );
  }

  Widget _buildVariantsSection(BuildContext context, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Variants', Icons.tune),
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
          onPressed: _isSubmitting ? null : _addVariant,
          icon: const Icon(Icons.add),
          label: const Text('Add Variant'),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48)),
        ),
      ],
    );
  }

  Widget _buildVariantCard(
      BuildContext context, int index, _VariantEntry entry) {
    final allSizes = <SizeOption>[];
    for (final sizeList in sizeOptions.values) {
      allSizes.addAll(sizeList);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          // Highlight inactive variants with a muted border
          color: entry.isActive
              ? Theme.of(context).dividerColor
              : Theme.of(context).colorScheme.error.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Variant ${index + 1}${entry.isNew ? '  (new)' : ''}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                // NEW variants → show a simple remove button (not yet in DB)
                // EXISTING variants → show is_active toggle (no delete button)
                if (entry.isNew)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Remove new variant',
                    onPressed: _isSubmitting
                        ? null
                        : () => setState(() {
                      entry.dispose();
                      _variantEntries.removeAt(index);
                    }),
                  )
                else if (entry.isCheckingDeletion)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                // is_active toggle for existing variants
                  Row(
                    children: [
                      Text(
                        entry.isActive ? 'Active' : 'Inactive',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: entry.isActive
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                      Switch(
                        value: entry.isActive,
                        activeColor: Colors.green,
                        onChanged: _isSubmitting
                            ? null
                            : (val) => _toggleExistingVariantActive(index, val),
                      ),
                    ],
                  ),
              ],
            ),

            // ── Fields ───────────────────────────────────────────────────
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
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
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: entry.sizeId > 0 ? entry.sizeId : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Size',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    items: allSizes
                        .where((s) => s.id > 0)
                        .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    ))
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (val) {
                      if (val != null && val > 0) {
                        setState(() {
                          entry.sizeId = val;
                          // Keep sizeLabel in sync so fallback stays correct
                          entry.sizeLabel =
                              _resolveSizeLabel(val, entry.sizeLabel);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: entry.priceController,
                    label: 'Price',
                    hintText: '0.00',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: entry.qtyController,
                    label: 'Quantity',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: entry.discountController,
                    label: 'Discount %',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Product Images', Icons.image_outlined),
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
      ],
    );
  }

  Widget _buildImageTile(BuildContext context, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
            image: DecorationImage(
              image: NetworkImage(_imagePaths[index]),
              fit: BoxFit.cover,
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
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(50),
              ),
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
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: const Text('Default',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Settings', Icons.settings),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: DropdownButtonFormField<Category>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: l10n.productCategory,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            ),
            items: CategoriesData.getAllCategoriesFlat()
                .map((cat) => DropdownMenuItem(
              value: cat,
              child: Text(
                  cat.parentId == null ? cat.name : '  - ${cat.name}'),
            ))
                .toList(),
            onChanged: _isSubmitting
                ? null
                : (val) => setState(() => _selectedCategory = val),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isActive
                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: SwitchListTile(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              l10n.productIsActive,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: _totalQty <= 0
                ? Text(
              'Set quantity > 0 to enable',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error),
            )
                : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            value: _isActive,
            onChanged: _isSubmitting || _totalQty <= 0
                ? null
                : (val) => setState(() => _isActive = val),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic l10n) {
    return Column(
      children: [
        AppButton(
          label: l10n.productUpdateAction,
          leading: _isSubmitting
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation(Colors.white)),
          )
              : null,
          onPressed: _isSubmitting ? null : _updateProduct,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48)),
          child: Text(context.l10n.commonCancel),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _addVariant() {
    setState(() => _variantEntries.add(_VariantEntry()));
  }

  Future<void> _pickImage() async {
    try {
      final result =
      await _imagePicker.pickImage(source: ImageSource.gallery);
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

  // ── Core update ───────────────────────────────────────────────────────────

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
      // ── 1. Build UpdateItemDetail list for EXISTING variants ─────────────
      //       These go in "item_details" with "detail_id" + string "size".
      final existingDetails = <UpdateItemDetail>[];

      for (final entry in _variantEntries.where((e) => !e.isNew)) {
        final price =
            double.tryParse(entry.priceController.text.trim()) ?? 0;
        if (price <= 0) {
          throw 'All variants must have a price greater than 0';
        }

        existingDetails.add(UpdateItemDetail(
          detailId: entry.detId!,
          itemPrice: price,
          itemQty: int.tryParse(entry.qtyController.text.trim()) ?? 0,
          brand: entry.brandController.text.trim().isEmpty
              ? 'N/A'
              : entry.brandController.text.trim(),
          color: entry.colorController.text.trim().isEmpty
              ? 'N/A'
              : entry.colorController.text.trim(),
          // "modified_by" = the currently logged-in user
          modifiedBy: widget.currentUser,
          // Resolve sizeId → label string (fall back to original API label)
          size: _resolveSizeLabel(entry.sizeId, entry.sizeLabel),
          isActive: entry.isActive ? 1 : 0,
        ));
      }

      // ── 2. Submit the update request ─────────────────────────────────────
      //       toJson() now produces:
      //         { "items": [{ "id":..., "item_details": [...], ... }] }
      final request = UpdateProductRequest(
        id: _itemId,
        itemName: _nameController.text.trim(),
        itemDesc: _descController.text.trim(),
        isActive: _isActive ? 1 : 0,
        itemDetails: existingDetails,
        categoryId: _selectedCategory!.id,
        itemImgUrl: _imagePaths.isNotEmpty ? _imagePaths.first : null,
      );

      await _productService.updateProduct(request);

      // ── 3. Insert brand-new variants (those added during this edit session)
      final newEntries = _variantEntries.where((e) => e.isNew).toList();
      if (newEntries.isNotEmpty) {
        final insertDetails = <CreateProductDetail>[];
        for (final entry in newEntries) {
          final price =
              double.tryParse(entry.priceController.text.trim()) ?? 0;
          if (price <= 0) {
            throw 'New variant price must be greater than 0';
          }
          insertDetails.add(CreateProductDetail(
            brand: entry.brandController.text.trim().isEmpty
                ? 'N/A'
                : entry.brandController.text.trim(),
            color: entry.colorController.text.trim().isEmpty
                ? 'N/A'
                : entry.colorController.text.trim(),
            itemSize: entry.sizeId,
            itemPrice: price,
            itemQty: int.tryParse(entry.qtyController.text.trim()) ?? 0,
            discount:
            double.tryParse(entry.discountController.text.trim()) ?? 0,
            isActive: entry.isActive ? 1 : 0,
          ));
        }

        await _productService.insertProductDetails(
          itemId: _itemId,
          details: insertDetails,
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
}

// ── Variant entry (local state per card) ──────────────────────────────────────

class _VariantEntry {
  /// Null / ≤0 means this is a brand-new, unsaved variant.
  final int? detId;

  bool isActive;

  /// True while the delete-check API call is in-flight.
  bool isCheckingDeletion;

  /// Original size label from the API (e.g. "ll", "15 inch").
  /// Used as a fallback when the sizeId can't be resolved back to a label.
  String sizeLabel;

  /// Integer id used to drive the Size DropdownButtonFormField.
  int sizeId;

  final TextEditingController brandController;
  final TextEditingController colorController;
  final TextEditingController priceController;
  final TextEditingController qtyController;
  final TextEditingController discountController;

  _VariantEntry({
    this.detId,
    this.isActive = true,
    this.sizeLabel = '',
    int? sizeId,
    String brand = '',
    String color = '',
    double price = 0,
    int qty = 0,
    double discount = 0,
  })  : isCheckingDeletion = false,
        sizeId = sizeId ?? 0,
        brandController = TextEditingController(text: brand),
        colorController = TextEditingController(text: color),
        priceController =
        TextEditingController(text: price > 0 ? price.toString() : ''),
        qtyController =
        TextEditingController(text: qty > 0 ? qty.toString() : ''),
        discountController = TextEditingController(
            text: discount > 0 ? discount.toString() : '');

  /// True when this variant has not yet been persisted to the server.
  bool get isNew => detId == null || detId! <= 0;

  void dispose() {
    brandController.dispose();
    colorController.dispose();
    priceController.dispose();
    qtyController.dispose();
    discountController.dispose();
  }
}