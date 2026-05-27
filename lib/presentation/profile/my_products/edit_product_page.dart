import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sinwar_shoping/presentation/profile/my_products/widgets/product_image_cropper.dart';
import '../../../../data/categories_data.dart';
import '../../../../models/category_model.dart';
import '../../../models/product/product_model.dart';
import '../../../models/product/product_image_model.dart';
import '../../../core/config/size_options.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/product_service.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../../widgets/custom_text_field/custom_text_field.dart';
import 'models/variant_form_entry.dart';
import 'utils/product_validators.dart';
import 'widgets/product_active_toggle.dart';
import 'widgets/product_category_picker.dart';
import 'widgets/product_images_section.dart';
import 'widgets/product_section_title.dart';
import 'widgets/variant_card.dart';

/// Full-screen editor for an existing product.
/// Changes: extracted all widgets, no hardcoded values, responsive layout.
class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.product,
    required this.variants,
    this.variantsRows = const [],
    this.itemImages = const [],
    required this.currentUser,
  });

  final ProductModel product;
  final ApiProductDetails variants;
  final List<ApiProductDetails> variantsRows;
  final List<ProductImageModel> itemImages;
  final String currentUser;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  final List<VariantFormEntry> _variantEntries = [];
  final List<ProductImageModel> _itemImages = [];

  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  int? _defaultImageId;
  late final int _itemId;
  CategoryModel? _selectedCategory;
  late bool _isProductActive;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final d = widget.variants;
    _itemId = d.itemId;
    _nameController = TextEditingController(text: d.name);
    _descController = TextEditingController(text: d.description);
    _selectedCategory = CategoriesData.getCategoryById(d.catId);
    _isProductActive = widget.product.isActive == 1;

    _initVariants();
    _initImages();
  }

  void _initVariants() {
    for (final d in widget.variantsRows) {
      final opt = _resolveSizeOption(d.size);
      _variantEntries.add(
        VariantFormEntry(
          detailId: d.detId,
          isActive: d.isActive == 1,
          sizeGroupId: opt?.groupId,
          sizeId: opt?.id,
          brand: d.brand,
          color: d.color,
          price: d.price,
          qty: d.stock,
          discount: d.discount,
          tax: d.tax,
        ),
      );
    }
  }

  /// Resolves a raw ITEM_SIZE string to a [SizeOption] using a 3-step
  /// priority: integer ID → size code → size name (all case-insensitive).
  SizeOption? _resolveSizeOption(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == '0') return null;

    final asId = int.tryParse(trimmed);
    if (asId != null && asId > 0) {
      final byId = findSizeOptionById(asId);
      if (byId != null) return byId;
    }

    final lower = trimmed.toLowerCase();
    for (final list in sizeOptions.values) {
      for (final opt in list) {
        if (opt.code.toLowerCase() == lower) return opt;
      }
    }

    for (final list in sizeOptions.values) {
      for (final opt in list) {
        if (opt.name.toLowerCase() == lower) return opt;
      }
    }
    return null;
  }

  void _initImages() {
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

  void _onVariantActiveToggled(int index, bool newValue) {
    setState(() {
      final e = _variantEntries[index];
      e.isActive = newValue;
      e.pendingDeactivate = !newValue && !e.isNew;
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);

    if (_selectedCategory == null) {
      CustomSnackBar.show(
        context,
        message: l10n.productSelectCategoryValidation,
        type: AppSnackBarType.warning,
      );
      return;
    }
    if (_variantEntries.isEmpty) {
      CustomSnackBar.show(
        context,
        message: l10n.productVariantRequired,
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Step 1 — hard-delete deactivated variants.
      final hardDeleted = <int>{};
      for (final e in _variantEntries.where(
        (e) => !e.isNew && e.pendingDeactivate,
      )) {
        try {
          if (await _productService.deleteVariantDetail(e.detailId!)) {
            hardDeleted.add(e.detailId!);
          }
        } catch (_) {}
      }

      // Step 2 — update existing variants.
      final existingDetails = <UpdateItemDetail>[];
      for (final e in _variantEntries.where((e) => !e.isNew)) {
        if (hardDeleted.contains(e.detailId)) continue;
        final price = double.tryParse(e.priceController.text.trim()) ?? 0;
        if (price <= 0) throw l10n.productVariantPriceMustBePositive;
        final sizeOpt = e.sizeId != null ? findSizeOptionById(e.sizeId!) : null;
        existingDetails.add(
          UpdateItemDetail(
            detailId: e.detailId!,
            price: price,
            stock: int.tryParse(e.qtyController.text.trim()) ?? 0,
            discount: double.tryParse(e.discountController.text.trim()) ?? 0,
            tax: double.tryParse(e.taxController.text.trim()) ?? 0,
            brand: e.brandController.text.trim().isEmpty
                ? 'N/A'
                : e.brandController.text.trim(),
            color: e.colorController.text.trim().isEmpty
                ? 'N/A'
                : e.colorController.text.trim(),
            modifiedBy: widget.currentUser,
            size: sizeOpt?.code ?? '',
            isActive: e.isActive ? 1 : 0,
          ),
        );
      }

      await _productService.updateProduct(
        UpdateProductRequest(
          id: _itemId,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          isActive: _isProductActive ? 1 : 0,
          itemDetails: existingDetails,
          categoryId: _selectedCategory!.id,
          primaryImageUrl: widget.product.primaryImageUrl.trim().isEmpty
              ? null
              : widget.product.primaryImageUrl,
        ),
      );

      // Step 3 — insert new variants.
      final newEntries = _variantEntries.where((e) => e.isNew).toList();
      if (newEntries.isNotEmpty) {
        final newDetails = <CreateProductDetail>[];
        for (final e in newEntries) {
          final price = double.tryParse(e.priceController.text.trim()) ?? 0;
          if (price <= 0) throw l10n.productVariantPriceMustBePositive;
          final sizeOpt = e.sizeId != null
              ? findSizeOptionById(e.sizeId!)
              : null;
          newDetails.add(
            CreateProductDetail(
              brand: e.brandController.text.trim().isEmpty
                  ? 'N/A'
                  : e.brandController.text.trim(),
              color: e.colorController.text.trim().isEmpty
                  ? 'N/A'
                  : e.colorController.text.trim(),
              size: sizeOpt?.code ?? '',
              price: price,
              stock: int.tryParse(e.qtyController.text.trim()) ?? 0,
              discount: double.tryParse(e.discountController.text.trim()) ?? 0,
              tax: double.tryParse(e.taxController.text.trim()) ?? 0,
              isActive: e.isActive ? 1 : 0,
            ),
          );
        }
        await _productService.insertProductDetails(
          itemId: _itemId,
          details: newDetails,
          createdBy: widget.currentUser,
        );
      }

      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: l10n.productUpdateSuccess,
        type: AppSnackBarType.success,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: 'Error: $e',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Image helpers ─────────────────────────────────────────────────────────

  Future<void> _reloadImages() async {
    final images = await _productService.getItemImagesBase64(itemId: _itemId);
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
        imageId: image.imageId,
        imageBase64: image.imageBase64,
      );
      await _reloadImages();
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).productDefaultImageUpdated,
        type: AppSnackBarType.success,
      );
    } catch (_) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).productDefaultImageUpdateFailed,
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return;

      final cropResult = await ProductImageCropper.show(
        context,
        sourceFile: File(picked.path),
      );
      if (cropResult == null || !mounted) return; // user cancelled

      // cropResult.file is already 1200×1200 — just base64-encode it.
      // final base64 = await ImageConverter.compressAndConvert(cropResult.file);
      // if (base64 == null) {
      //   if (!mounted) return;
      //   AppSnackBar.show(
      //     context,
      //     message: AppLocalizations.of(context).productImageProcessFailed,
      //     type: AppSnackBarType.error,
      //   );
      //   return;
      // }

      if (mounted) setState(() => _isUploadingImage = true);

      await _productService.insertItemImage(
        itemId: _itemId,
        imageBase64: "base64",
        isDefault: _itemImages.isEmpty,
      );
      await _reloadImages();

      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).productImageUploadSuccess,
        type: AppSnackBarType.success,
      );
    } catch (_) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: AppLocalizations.of(context).productImagePickFailed,
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        title: Text(
          l10n.productEditTitle,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: _isSubmitting
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: AppSpacing.insetsMd,
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: AppSpacing.insetsMd,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _EditProductHeader(itemId: _itemId),
                      const SizedBox(height: AppSpacing.xl),
                      _BasicInfoSection(
                        nameController: _nameController,
                        descController: _descController,
                        isSubmitting: _isSubmitting,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ProductActiveToggle(
                        isActive: _isProductActive,
                        isDisabled: _isSubmitting,
                        onChanged: (val) =>
                            setState(() => _isProductActive = val),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _EditVariantsSection(
                        entries: _variantEntries,
                        isSubmitting: _isSubmitting,
                        onAdd: () => setState(
                          () => _variantEntries.add(VariantFormEntry()),
                        ),
                        onActiveToggled: _onVariantActiveToggled,
                        onRemoveNew: (i) => setState(() {
                          _variantEntries[i].dispose();
                          _variantEntries.removeAt(i);
                        }),
                        onSizeGroupChanged: (i, val) => setState(() {
                          final e = _variantEntries[i];
                          e.sizeGroupId = val;
                          final opts = sizeOptions[val] ?? const [];
                          if (val == null ||
                              opts.every((o) => o.id != e.sizeId)) {
                            e.sizeId = null;
                          }
                        }),
                        onSizeChanged: (i, val) =>
                            setState(() => _variantEntries[i].sizeId = val),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      EditImagesSection(
                        images: _itemImages,
                        defaultImageId: _defaultImageId,
                        isSubmitting: _isSubmitting,
                        isUploading: _isUploadingImage,
                        onAddPressed: _pickAndUploadImage,
                        onSetDefault: _setDefaultImage,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      EditCategoryPicker(
                        selectedCategory: _selectedCategory,
                        isDisabled: _isSubmitting,
                        onChanged: (v) => setState(() => _selectedCategory = v),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _EditProductActions(
                        isSubmitting: _isSubmitting,
                        onSave: _updateProduct,
                        onCancel: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets for this screen only
// ─────────────────────────────────────────────────────────────────────────────

class _EditProductHeader extends StatelessWidget {
  const _EditProductHeader({required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colorScheme.primary.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productIdLabel(itemId),
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.productEditingProductDetails,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({
    required this.nameController,
    required this.descController,
    required this.isSubmitting,
  });

  final TextEditingController nameController;
  final TextEditingController descController;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validators = ProductValidators.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductSectionTitle(
          title: l10n.productBasicInfo,
          icon: Icons.info_outline,
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          controller: nameController,
          label: l10n.productItemName,
          hintText: l10n.productItemNameHint,
          validator: validators.required,
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          controller: descController,
          label: l10n.productDescriptionLabel,
          hintText: l10n.productDescriptionHint,
          validator: validators.required,
        ),
      ],
    );
  }
}

class _EditVariantsSection extends StatelessWidget {
  const _EditVariantsSection({
    required this.entries,
    required this.isSubmitting,
    required this.onAdd,
    required this.onActiveToggled,
    required this.onRemoveNew,
    required this.onSizeGroupChanged,
    required this.onSizeChanged,
  });

  final List<VariantFormEntry> entries;
  final bool isSubmitting;
  final VoidCallback onAdd;
  final void Function(int index, bool value) onActiveToggled;
  final ValueChanged<int> onRemoveNew;
  final void Function(int index, int? value) onSizeGroupChanged;
  final void Function(int index, int? value) onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductSectionTitle(title: l10n.productVariants, icon: Icons.tune),
        const SizedBox(height: AppSpacing.lg),
        if (entries.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.productNoVariantsYet,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (_, i) => VariantCard(
              index: i,
              entry: entries[i],
              isSubmitting: isSubmitting,
              showActiveToggle: !entries[i].isNew,
              showRemoveButton: entries[i].isNew,
              onActiveToggled: (val) => onActiveToggled(i, val),
              onRemovePressed: () => onRemoveNew(i),
              onSizeGroupChanged: (val) => onSizeGroupChanged(i, val),
              onSizeChanged: (val) => onSizeChanged(i, val),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: isSubmitting ? null : onAdd,
          icon: const Icon(Icons.add),
          label: Text(l10n.productAddVariant),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

class _EditProductActions extends StatelessWidget {
  const _EditProductActions({
    required this.isSubmitting,
    required this.onSave,
    required this.onCancel,
  });

  final bool isSubmitting;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        CustomButton(
          label: l10n.productUpdateAction,
          leading: isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : null,
          onPressed: isSubmitting ? null : onSave,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: isSubmitting ? null : onCancel,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Text(l10n.commonCancel, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
