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
  });

  final ApiProduct product;
  final ApiProductDetails details;
  final List<ApiProductDetails> detailsRows;
  final List<ApiItemImage> itemImages;

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
  late final int _detId;
  late bool _isActive;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final details = widget.details;
    _itemId = details.itemId;
    _detId = details.detId;

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
          brand: detail.brand,
          color: detail.color,
          sizeId: int.tryParse(detail.itemSize.trim()) ?? 0,
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
    if (_totalQty <= 0 && _isActive) {
      _isActive = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final entry in _variantEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  int get _totalQty {
    return _variantEntries.fold<int>(
      0,
      (sum, entry) => sum + (int.tryParse(entry.qtyController.text) ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productEditTitle),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
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
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product ID: $_itemId',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Editing product details',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context, var l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Basic Information', Icons.info_outline),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _nameController,
          label: l10n.productItemName,
          hintText: l10n.productItemNameHint,
          validator: (value) => (value?.trim().isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _descController,
          label: l10n.productDescriptionLabel,
          hintText: l10n.productDescriptionHint,
          validator: (value) => (value?.trim().isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildVariantsSection(BuildContext context, var l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Variants', Icons.tune),
        const SizedBox(height: AppSpacing.lg),
        if (_variantEntries.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'No variants yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _variantEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) {
              return _buildVariantCard(context, index, _variantEntries[index]);
            },
          ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: _isSubmitting ? null : _addVariant,
          icon: const Icon(Icons.add),
          label: const Text('Add Variant'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildVariantCard(BuildContext context, int index, _VariantEntry entry) {
    final allSizes = <SizeOption>[];
    for (final sizeList in sizeOptions.values) {
      allSizes.addAll(sizeList);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Variant ${index + 1}',
                  style:
Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Remove Variant'),
                              content: Text(
                                'Remove Variant ${index + 1}? This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) _removeVariant(index);
                        },
                ),
              ],
            ),
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
                    isExpanded: true,                    // ← prevents overflow
                    decoration: InputDecoration(
                      labelText: 'Size',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: allSizes
                        .where((s) => s.id > 0)
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,   // ← clips long names
                              maxLines: 1,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value != null && value > 0) {
                              setState(() => entry.sizeId = value);
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

  Widget _buildImagesSection(BuildContext context, var l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Product Images', Icons.image_outlined),
        const SizedBox(height: AppSpacing.lg),
        if (_imagePaths.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('No images yet', style: Theme.of(context).textTheme.bodyMedium),
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
            itemBuilder: (context, index) => _buildImageTile(context, index),
          ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: _isSubmitting ? null : _pickImage,
          icon: const Icon(Icons.image_outlined),
          label: const Text('Add Image'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
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
            onTap: _isSubmitting ? null : () => setState(() => _imagePaths.removeAt(index)),
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
              child: const Text(
                'Default',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, var l10n) {
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
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            items: CategoriesData.getAllCategoriesFlat()
                .map(
                  (cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat.parentId == null ? cat.name : '  - ${cat.name}'),
                  ),
                )
                .toList(),
            onChanged: _isSubmitting
                ? null
                : (value) {
                    setState(() => _selectedCategory = value);
                  },
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              l10n.productIsActive,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: _totalQty <= 0
                ? Text(
                    'Set quantity > 0 to enable',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            value: _isActive,
            onChanged: _isSubmitting || _totalQty <= 0
                ? null
                : (value) {
                    setState(() => _isActive = value);
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, var l10n) {
    return Column(
      children: [
        AppButton(
          label: l10n.productUpdateAction,
          leading: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                )
              : null,
          onPressed: _isSubmitting ? null : _updateProduct,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Text(context.l10n.commonCancel),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _addVariant() {
    setState(() {
      _variantEntries.add(_VariantEntry());
    });
  }

  void _removeVariant(int index) {
    setState(() {
      _variantEntries[index].dispose();
      _variantEntries.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    try {
      final result = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (result != null && mounted) {
        setState(() {
          _imagePaths.add(result.path);
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Failed to pick image',
          type: AppSnackBarType.error,
        );
      }
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      AppSnackBar.show(context, message: 'Please select a category', type: AppSnackBarType.warning);
      return;
    }
    if (_variantEntries.isEmpty) {
      AppSnackBar.show(context, message: 'Add at least one variant', type: AppSnackBarType.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updateDetails = <CreateProductDetail>[];
      final insertDetails = <CreateProductDetail>[];

      for (final entry in _variantEntries) {
        final price = double.tryParse(entry.priceController.text.trim()) ?? 0;
        if (price <= 0) throw 'All variants must have a price greater than 0';

        final detail = CreateProductDetail(
          detId: entry.detId,
          color: entry.colorController.text.trim().isEmpty ? 'N/A' : entry.colorController.text.trim(),
          brand: entry.brandController.text.trim().isEmpty ? 'N/A' : entry.brandController.text.trim(),
          itemSize: entry.sizeId,
          itemPrice: price,
          itemQty: int.tryParse(entry.qtyController.text.trim()) ?? 0,
          discount: double.tryParse(entry.discountController.text.trim()) ?? 0,
          isActive: _isActive ? 1 : 0,  // ← per-detail is_active from the toggle
        );

        if (entry.detId == null || entry.detId! <= 0) {
          insertDetails.add(detail);
        } else {
          updateDetails.add(detail);
        }
      }

      // Derive price from first variant for the top-level item
      final allDetails = [...updateDetails, ...insertDetails];
      final normalizedPrice = allDetails.isNotEmpty ? allDetails.first.itemPrice : 0.01;

      final request = UpdateProductRequest(
        id: _itemId,
        detId: _detId,
        itemName: _nameController.text.trim(),
        itemDesc: _descController.text.trim(),
        itemPrice: normalizedPrice,         // ← no longer hardcoded 0
        itemQty: _totalQty,
        itemImgUrl: _imagePaths.isNotEmpty ? _imagePaths.first : null,
        imagesCsv: _imagePaths.isNotEmpty ? _imagePaths.join(',') : null,
        details: updateDetails,
        categoryId: _selectedCategory!.id,
        isActive: _isActive ? 1 : 0,
      );

      // Step 1: Update main product + existing variants
      await _productService.updateProduct(request);

      // Step 2: Insert brand-new variants — MUST happen before pop
      if (insertDetails.isNotEmpty) {
        await _productService.insertProductDetails(
          itemId: _itemId,
          details: insertDetails,
        );
      }

      // Step 3: Only pop AFTER both calls succeed
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Product updated successfully', type: AppSnackBarType.success);
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Error: $e', type: AppSnackBarType.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _VariantEntry {
  final int? detId;
  final TextEditingController brandController;
  final TextEditingController colorController;
  final TextEditingController priceController;
  final TextEditingController qtyController;
  final TextEditingController discountController;
  int sizeId;

  _VariantEntry({
    this.detId,
    String brand = '',
    String color = '',
    int? sizeId,
    double price = 0,
    int qty = 0,
    double discount = 0,
  })  : brandController = TextEditingController(text: brand),
        colorController = TextEditingController(text: color),
        priceController = TextEditingController(text: price > 0 ? price.toString() : ''),
        qtyController = TextEditingController(text: qty > 0 ? qty.toString() : ''),
        discountController = TextEditingController(text: discount > 0 ? discount.toString() : ''),
        sizeId = sizeId ?? 0;

  void dispose() {
    brandController.dispose();
    colorController.dispose();
    priceController.dispose();
    qtyController.dispose();
    discountController.dispose();
  }
}
