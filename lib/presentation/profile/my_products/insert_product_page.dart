import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/presentation/profile/my_products/widgets/product_image_cropper.dart';
import 'package:sinwar_shoping/presentation/profile/my_products/widgets/variant_card.dart';

import '../../../../models/product_model.dart';
import '../../../core/config/route.dart';
import '../../../core/config/size_options.dart';
import '../../../design/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/product_service.dart';
import '../../../core/state/auth_state.dart';
import '../../../widgets/widgets/app_button.dart';
import '../../../widgets/widgets/app_snackbar.dart';
import '../../../widgets/widgets/app_text_field.dart';
import 'models/variant_form_entry.dart';
import 'utils/product_validators.dart';
import 'widgets/product_category_picker.dart';
import 'widgets/product_images_section.dart';
import 'widgets/product_section_title.dart';

/// Full-screen modal for creating a new product.
/// Opened via FAB on [MyProductsPage].
///
/// New products are always created with `is_active = 1`.
/// Sellers can toggle active/inactive later from [EditProductPage].
class InsertProductPage extends StatefulWidget {
  const InsertProductPage({super.key, required this.currentUser});

  final String currentUser;

  @override
  State<InsertProductPage> createState() => _InsertProductPageState();
}

class _InsertProductPageState extends State<InsertProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final ProductService _productService = ProductService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSubmitting = false;
  bool _submitLocked = false;

  final List<XFile> _images = [];
  int _defaultImageIndex = 0;
  int? _selectedSubCategoryId;
  final List<VariantFormEntry> _variantEntries = [];

  @override
  void initState() {
    super.initState();
    _variantEntries.add(VariantFormEntry());
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
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

  // ── Image helpers ─────────────────────────────────────────────────────────

  Future<void> _showImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(source: source);
// No imageQuality here — we handle compression ourselves.
    if (picked == null || !mounted) return;
// Open interactive square crop screen.
    final result = await ProductImageCropper.show(
      context,
      sourceFile: File(picked.path),
    );
    if (result == null || !mounted) return;  // user cancelled
// result.file is the processed 1200×1200 JPEG temp file.
    setState(() {
      _images.add(XFile(result.file.path));
      if (_images.length == 1) _defaultImageIndex = 0;
    });
  }

  void _removeImageAt(int index) {
    setState(() {
      _images.removeAt(index);
      if (_images.isEmpty) {
        _defaultImageIndex = 0;
      } else if (index < _defaultImageIndex) {
        _defaultImageIndex -= 1;
      } else if (_defaultImageIndex >= _images.length) {
        _defaultImageIndex = _images.length - 1;
      }
    });
  }

  List<String> _orderedImagePaths() {
    if (_images.isEmpty) return const [];
    final paths = _images.map((x) => x.path.trim()).toList();
    if (paths.length == 1) return [paths.first];
    final safe = _defaultImageIndex.clamp(0, paths.length - 1);
    return [
      paths[safe],
      for (var i = 0; i < paths.length; i++)
        if (i != safe) paths[i],
    ].where((p) => p.isNotEmpty).toList();
  }

  // ── Variant helpers ───────────────────────────────────────────────────────

  List<CreateProductDetail> _buildVariantPayload() {
    final details = <CreateProductDetail>[];
    for (var i = 0; i < _variantEntries.length; i++) {
      final v = _variantEntries[i];
      final price = double.tryParse(v.priceController.text.trim());
      final qty = int.tryParse(v.qtyController.text.trim()) ?? 1;
      final discount =
          double.tryParse(v.discountController.text.trim()) ?? 0.0;

      if (price == null || price <= 0 || qty < 1) return const [];

      details.add(CreateProductDetail(
        brand: v.brandController.text.trim().isEmpty
            ? 'N/A'
            : v.brandController.text.trim(),
        color: v.colorController.text.trim().isEmpty
            ? 'N/A'
            : v.colorController.text.trim(),
        itemSize: (v.sizeId ?? 0).toString(),
        discount: discount < 0 ? 0.0 : discount,
        itemPrice: price,
        itemQty: qty,
        isActive: 1, // Always active on insert.
      ));
    }
    return details;
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_submitLocked || _isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context);
    final validators = ProductValidators.of(context);

    if (_selectedSubCategoryId == null) {
      AppSnackBar.show(context,
          message: l10n.productSelectCategoryValidation,
          type: AppSnackBarType.warning);
      return;
    }
    if (_images.isEmpty) {
      AppSnackBar.show(context,
          message: l10n.productAddImageValidation,
          type: AppSnackBarType.warning);
      return;
    }

    final orderedPaths = _orderedImagePaths();
    if (orderedPaths.isEmpty) {
      AppSnackBar.show(context,
          message: l10n.productAddImageValidation,
          type: AppSnackBarType.warning);
      return;
    }

    final details = _buildVariantPayload();
    if (details.isEmpty) {
      AppSnackBar.show(context,
          message: l10n.productVariantRequired,
          type: AppSnackBarType.warning);
      return;
    }

    _submitLocked = true;
    setState(() => _isSubmitting = true);

    try {
      final imagesCsv = orderedPaths.join(',');
      await _productService.insertProduct(
        CreateProductRequest(
          itemName: _nameController.text.trim(),
          itemDesc: _descController.text.trim(),
          itemImgUrl: imagesCsv,
          imagesCsv: imagesCsv,
          details: details,
          categoryId: _selectedSubCategoryId!,
          createdBy: widget.currentUser,
          // isActive is always 1 — not user-controlled on insert.
        ),
      );

      if (!mounted) return;
      AppSnackBar.show(context,
          message: l10n.productInsertSuccess, type: AppSnackBarType.success);
      Navigator.pop(context, true);
    } on ProductException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context,
          message: error.message, type: AppSnackBarType.error);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context,
          message: AppLocalizations.of(context).productInsertFailed,
          type: AppSnackBarType.error);
    } finally {
      _submitLocked = false;
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validators = ProductValidators.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.insertProductMenu)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.insetsMd,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Basic info ────────────────────────────────────────────
                AppTextField(
                  controller: _nameController,
                  label: l10n.productItemName,
                  hintText: l10n.productItemNameHint,
                  validator: validators.required,
                  showRequiredAsterisk: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _descController,
                  label: l10n.productDescriptionLabel,
                  hintText: l10n.productDescriptionHint,
                  validator: validators.required,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Variants ──────────────────────────────────────────────
                _InsertVariantsSection(
                  entries: _variantEntries,
                  isSubmitting: _isSubmitting,
                  onAdd: () => setState(
                        () => _variantEntries.add(VariantFormEntry()),
                  ),
                  onRemove: (i) {
                    if (_variantEntries.length == 1) return;
                    setState(() {
                      _variantEntries.removeAt(i).dispose();
                    });
                  },
                  onSizeGroupChanged: (i, val) => setState(() {
                    final e = _variantEntries[i];
                    e.sizeGroupId = val;
                    final options = sizeOptions[val] ?? const [];
                    if (val == null ||
                        options.every((o) => o.id != e.sizeId)) {
                      e.sizeId = null;
                    }
                  }),
                  onSizeChanged: (i, val) =>
                      setState(() => _variantEntries[i].sizeId = val),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Images ────────────────────────────────────────────────
                InsertImagesSection(
                  images: _images,
                  defaultImageIndex: _defaultImageIndex,
                  isSubmitting: _isSubmitting,
                  onAddPressed: _showImageSourcePicker,
                  onSetDefault: (i) =>
                      setState(() => _defaultImageIndex = i),
                  onRemove: _removeImageAt,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Category ──────────────────────────────────────────────
                InsertCategoryPicker(
                  selectedSubCategoryId: _selectedSubCategoryId,
                  isDisabled: _isSubmitting,
                  onSelected: (id) =>
                      setState(() => _selectedSubCategoryId = id),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  '${l10n.productUsername}: ${widget.currentUser}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Actions ───────────────────────────────────────────────
                AppButton(
                  label: l10n.productInsertAction,
                  leading: _isSubmitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : null,
                  onPressed: _isSubmitting ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Variants section — private to this screen
// ─────────────────────────────────────────────────────────────────────────────

class _InsertVariantsSection extends StatelessWidget {
  const _InsertVariantsSection({
    required this.entries,
    required this.isSubmitting,
    required this.onAdd,
    required this.onRemove,
    required this.onSizeGroupChanged,
    required this.onSizeChanged,
  });

  final List<VariantFormEntry> entries;
  final bool isSubmitting;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int index, int? value) onSizeGroupChanged;
  final void Function(int index, int? value) onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      padding: AppSpacing.insetsMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductSectionTitle(
            title: l10n.productVariants,
            icon: Icons.tune,
            trailing: IconButton(
              onPressed: isSubmitting ? null : onAdd,
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add variant',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (entries.isEmpty)
            Text(l10n.productVariantRequired)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) => VariantCard(
                index: i,
                entry: entries[i],
                isSubmitting: isSubmitting,
                showRemoveButton: true,
                onRemovePressed: () => onRemove(i),
                onSizeGroupChanged: (val) => onSizeGroupChanged(i, val),
                onSizeChanged: (val) => onSizeChanged(i, val),
              ),
            ),
        ],
      ),
    );
  }
}