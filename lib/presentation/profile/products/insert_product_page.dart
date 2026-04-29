import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../data/categories_data.dart';
import '../../../../models/product_api.dart';
import '../../../core/config/route.dart';
import '../../../core/config/size_options.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/l10n.dart';
import '../../../core/app/app_theme.dart';
import '../../../services/product_service.dart';
import '../../../widgets/gallery_section/gallery_viewer.dart';
import '../../../widgets/widgets/app_button.dart';
import '../../../widgets/widgets/app_snackbar.dart';
import '../../../widgets/widgets/app_text_field.dart';
import '../../../core/state/auth_state.dart';
import '../../../widgets/widgets/color_picker/color_hex_field.dart';

class InsertProductPage extends StatefulWidget {
  const InsertProductPage({super.key});

  @override
  State<InsertProductPage> createState() => _InsertProductPageState();
}

class _InsertProductPageState extends State<InsertProductPage> {
  final _formKey         = GlobalKey<FormState>();
  final _nameController  = TextEditingController();
  final _descController  = TextEditingController();

  final ProductService _productService = ProductService();
  final ImagePicker    _imagePicker    = ImagePicker();

  bool _isSubmitting  = false;
  bool _submitLocked  = false;

  // FIX: is_active is ALWAYS true on insert — the switch is removed entirely.
  // New products are always created active; sellers can deactivate later from
  // the edit screen.

  final List<XFile>          _images        = [];
  int                        _defaultImageIndex = 0;
  int?                       _expandedCategoryId;
  int?                       _selectedSubCategoryId;
  final List<_VariantFormEntry> _variantEntries = <_VariantFormEntry>[];

  @override
  void initState() {
    super.initState();
    _variantEntries.add(_VariantFormEntry());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
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

  // ── Validators ─────────────────────────────────────────────────────────────

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) return context.l10n.productRequiredField;
    return null;
  }

  String? _positiveDoubleValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return context.l10n.productRequiredField;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) return context.l10n.productInvalidValue;
    return null;
  }

  String? _positiveIntOrEmptyDefaultValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return context.l10n.productRequiredField;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) return context.l10n.productInvalidValue;
    return null;
  }

  String? _nonNegativeDoubleOrEmptyValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0 || parsed > 100) {
      return context.l10n.productDiscountInvalidRange;
    }
    return null;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_submitLocked || _isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedSubCategoryId == null) {
      AppSnackBar.show(context,
          message: context.l10n.productSelectCategoryValidation,
          type: AppSnackBarType.warning);
      return;
    }
    if (_images.isEmpty) {
      AppSnackBar.show(context,
          message: context.l10n.productAddImageValidation,
          type: AppSnackBarType.warning);
      return;
    }

    final authState = context.read<AuthState>();
    final createdBy = authState.user?.username.trim() ?? '';
    if (createdBy.isEmpty) {
      AppSnackBar.show(context,
          message: context.l10n.productAccountUnavailable,
          type: AppSnackBarType.error);
      return;
    }

    final orderedImagePaths = _orderedImagePathsForSubmit();
    if (orderedImagePaths.isEmpty) {
      AppSnackBar.show(context,
          message: context.l10n.productAddImageValidation,
          type: AppSnackBarType.warning);
      return;
    }

    final details = _buildVariantDetails();
    if (details.isEmpty) {
      AppSnackBar.show(context,
          message: context.l10n.productVariantRequired,
          type: AppSnackBarType.warning);
      return;
    }

    _submitLocked = true;
    setState(() => _isSubmitting = true);

    try {
      final imagesCsv = orderedImagePaths.join(',');
      final request = CreateProductRequest(
        itemName:   _nameController.text.trim(),
        itemDesc:   _descController.text.trim(),
        itemImgUrl: imagesCsv,
        imagesCsv:  imagesCsv,
        details:    details,
        categoryId: _selectedSubCategoryId!,
        createdBy:  createdBy,
        // FIX: always 1 — not user-controlled on insert
        // isActive:   1,
      );

      if (kDebugMode) {
        final requestBody = {'items': [request.toJson()]};
        debugPrint('=== Product Insertion Debug ===');
        debugPrint('created_by: $createdBy');
        debugPrint('Is Logged In: ${authState.isLoggedIn}');
        debugPrint('Variants count: ${details.length}');
        debugPrint('Category ID: $_selectedSubCategoryId');
        _debugLogInsertPayloadTypes(requestBody);
        debugPrint('===============================');
      }

      await _productService.insertProduct(request);
      if (!mounted) return;

      AppSnackBar.show(context,
          message: context.l10n.productInsertSuccess,
          type: AppSnackBarType.success);
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.main, (route) => false);
    } on ProductException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context,
          message: error.message, type: AppSnackBarType.error);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context,
          message: context.l10n.productInsertFailed,
          type: AppSnackBarType.error);
    } finally {
      _submitLocked = false;
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Image picking ──────────────────────────────────────────────────────────

  Future<void> _showAddImageOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo now'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image =
    await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (image == null || !mounted) return;
    setState(() {
      _images.add(image);
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

  List<String> _orderedImagePathsForSubmit() {
    final paths = _images.map((x) => x.path.trim()).toList();
    if (paths.isEmpty) return const [];
    if (paths.length == 1) return [paths.first];
    final safeDefault = _defaultImageIndex.clamp(0, paths.length - 1);
    final ordered = <String>[paths[safeDefault]];
    for (var i = 0; i < paths.length; i++) {
      if (i != safeDefault) ordered.add(paths[i]);
    }
    return ordered.where((p) => p.isNotEmpty).toList();
  }

  // ── Variant helpers ────────────────────────────────────────────────────────

  void _addVariantEntry() =>
      setState(() => _variantEntries.add(_VariantFormEntry()));

  void _removeVariantEntry(int index) {
    if (_variantEntries.length == 1) return;
    setState(() {
      final removed = _variantEntries.removeAt(index);
      removed.dispose();
    });
  }

  List<CreateProductDetail> _buildVariantDetails() {
    if (_variantEntries.isEmpty) return const [];
    final details = <CreateProductDetail>[];
    for (var i = 0; i < _variantEntries.length; i++) {
      final v        = _variantEntries[i];
      final price    = double.tryParse(v.priceController.text.trim());
      final qtyText  = v.qtyController.text.trim();
      final qty      = qtyText.isEmpty ? 1 : int.tryParse(qtyText);
      final discount =
          double.tryParse(v.discountController.text.trim()) ?? 0.0;

      if (price == null || price <= 0 || qty == null || qty < 1) {
        return const [];
      }

      if (kDebugMode) {
        debugPrint(
            '[InsertProduct][Variant:$i] sizeGroup=${v.selectedSizeGroupId ?? 0} '
                'sizeId=${v.selectedSizeId ?? 0} price=$price qty=$qty');
      }

      details.add(CreateProductDetail(
        brand:     v.brandController.text.trim().isEmpty ? 'N/A' : v.brandController.text.trim(),
        color:     v.colorController.text.trim().isEmpty ? 'N/A' : v.colorController.text.trim(),
        itemSize:  (v.selectedSizeId ?? 0).toString(),
        discount:  discount < 0 ? 0.0 : discount,
        itemPrice: price,
        itemQty:   qty,
        // FIX: always 1 on insert
        isActive:  1,
      ));
    }
    return details;
  }

  void _debugLogInsertPayloadTypes(Map<String, dynamic> requestBody) {
    if (!kDebugMode) return;
    final items = requestBody['items'];
    if (items is! List || items.isEmpty || items.first is! Map) return;
    final product = Map<String, dynamic>.from(items.first as Map);
    debugPrint('[InsertProduct][Types] item_name: ${product['item_name']?.runtimeType}');
    debugPrint('[InsertProduct][Types] category_id: ${product['category_id']?.runtimeType}');
    debugPrint('[InsertProduct][Types] is_active: ${product['is_active']?.runtimeType}');
    final det = product['details'];
    if (det is List && det.isNotEmpty && det.first is Map) {
      final d = Map<String, dynamic>.from(det.first as Map);
      debugPrint('[InsertProduct][Types] details.item_size: ${d['item_size']?.runtimeType}');
      debugPrint('[InsertProduct][Types] details.item_price: ${d['item_price']?.runtimeType}');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n      = context.l10n;
    final authState = context.watch<AuthState>();
    final username  = authState.user?.username.trim();
    final usernamePreview =
    (username == null || username.isEmpty) ? 'Guest' : username;

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
                AppTextField(
                  controller:          _nameController,
                  label:               l10n.productItemName,
                  hintText:            l10n.productItemNameHint,
                  validator:           _requiredValidator,
                  showRequiredAsterisk: true,
                  textInputAction:     TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller:      _descController,
                  label:           l10n.productDescriptionLabel,
                  hintText:        l10n.productDescriptionHint,
                  validator:       _requiredValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildVariantsSection(),
                const SizedBox(height: AppSpacing.lg),
                _buildImagesSection(),
                const SizedBox(height: AppSpacing.lg),
                _buildCategorySection(context, l10n),
                const SizedBox(height: AppSpacing.lg),
                Text('${l10n.productUsername}: $usernamePreview',
                    style: Theme.of(context).textTheme.bodySmall),
                // FIX: SwitchListTile for is_active is REMOVED entirely.
                // Products are always created active (isActive: 1 above).
                // Sellers can toggle active/inactive from the Edit screen.
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: l10n.productInsertAction,
                  leading: _isSubmitting
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : null,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, dynamic l10n) {
    return Container(
      decoration: BoxDecoration(
        border:       Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        children: [
          ListTile(
            title: RichText(
              text: TextSpan(
                text:     l10n.productCategory,
                style:    Theme.of(context).textTheme.titleMedium,
                children: [
                  TextSpan(
                    text:  ' *',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
            subtitle: _selectedSubCategoryId == null
                ? null
                : Text(CategoriesData.getCategoryById(
                _selectedSubCategoryId!)?.name ??
                ''),
            trailing: const Icon(Icons.arrow_drop_down),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CategoriesData.getMainCategories().length,
            itemBuilder: (context, index) {
              final mainCategory =
              CategoriesData.getMainCategories()[index];
              final isExpanded =
                  _expandedCategoryId == mainCategory.id;
              return Column(
                children: [
                  ListTile(
                    title: Text(mainCategory.name),
                    trailing: Icon(isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more),
                    onTap: _isSubmitting
                        ? null
                        : () => setState(() {
                      _expandedCategoryId = isExpanded
                          ? null
                          : mainCategory.id;
                    }),
                  ),
                  if (isExpanded)
                    ...mainCategory.children.map((child) {
                      final isSelected =
                          _selectedSubCategoryId == child.id;
                      return ListTile(
                        contentPadding: const EdgeInsets.only(
                            left: 32, right: 16),
                        title: Text(child.name),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                            color: AppColors.success)
                            : null,
                        tileColor: isSelected
                            ? AppColors.success
                            .withValues(alpha: 0.1)
                            : null,
                        onTap: _isSubmitting
                            ? null
                            : () => setState(() =>
                        _selectedSubCategoryId = child.id),
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVariantsSection() {
    return Container(
      decoration: BoxDecoration(
        border:       Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      padding: AppSpacing.insetsMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                  child: Text('Variants', style: AppTextStyles.labelLarge)),
              IconButton(
                onPressed: _isSubmitting ? null : _addVariantEntry,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_variantEntries.isEmpty)
            const Text('Please add at least one variant.')
          else
            ..._variantEntries.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildVariantCard(e.key, e.value),
            )),
        ],
      ),
    );
  }

  Widget _buildVariantCard(int index, _VariantFormEntry variant) {
    return Container(
      decoration: BoxDecoration(
        border:       Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      padding: AppSpacing.insetsMd,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Variant ${index + 1}',
                      style: AppTextStyles.labelLarge)),
              IconButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _removeVariantEntry(index),
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
          AppTextField(
            controller:      variant.brandController,
            label:           context.l10n.productBrand,
            hintText:        context.l10n.productBrandHint,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sm),
          ColorHexField(
            initialColor:   variant.colorController.text,
            label:          context.l10n.productColor,
            onColorChanged: (v) => variant.colorController.text = v,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<int>(
            initialValue: variant.selectedSizeGroupId,
            decoration: InputDecoration(
              labelText: context.l10n.productSizeGroup,
              hintText:  context.l10n.productSizeGroupOptional,
            ),
            items: sizeGroups
                .map((g) => DropdownMenuItem<int>(
                value: g.id, child: Text(g.name)))
                .toList(),
            onChanged: _isSubmitting
                ? null
                : (value) {
              setState(() {
                variant.selectedSizeGroupId = value;
                final options =
                    sizeOptions[value] ?? const <SizeOption>[];
                if (value == null ||
                    options.every(
                            (o) => o.id != variant.selectedSizeId)) {
                  variant.selectedSizeId = null;
                }
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<int>(
            initialValue: variant.selectedSizeId,
            decoration: InputDecoration(
              labelText: context.l10n.productSize,
              hintText: variant.selectedSizeGroupId == null
                  ? context.l10n.productSelectGroupFirst
                  : context.l10n.productSelectSizeOptional,
            ),
            items: (sizeOptions[variant.selectedSizeGroupId] ??
                const <SizeOption>[])
                .map((s) => DropdownMenuItem<int>(
                value: s.id, child: Text(s.name)))
                .toList(),
            onChanged:
            _isSubmitting || variant.selectedSizeGroupId == null
                ? null
                : (value) =>
                setState(() => variant.selectedSizeId = value),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller:          variant.priceController,
            label:               context.l10n.productPriceLabel,
            hintText:            context.l10n.productPriceHint,
            keyboardType:        const TextInputType.numberWithOptions(decimal: true),
            validator:           _positiveDoubleValidator,
            showRequiredAsterisk: true,
            textInputAction:     TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller:          variant.qtyController,
            label:               context.l10n.productQuantityLabel,
            hintText:            context.l10n.productQuantityHint,
            keyboardType:        TextInputType.number,
            validator:           _positiveIntOrEmptyDefaultValidator,
            showRequiredAsterisk: true,
            textInputAction:     TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller:      variant.discountController,
            label:           context.l10n.productDiscountLabel,
            hintText:        context.l10n.productDiscountHint,
            keyboardType:    const TextInputType.numberWithOptions(decimal: true),
            validator:       _nonNegativeDoubleOrEmptyValidator,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  // ── Images section ─────────────────────────────────────────────────────────

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images', style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),

        // ── Big preview (tap to add when empty; tap to view full-screen when
        //    images exist) ────────────────────────────────────────────────────
        GestureDetector(
          onTap: _isSubmitting
              ? null
              : _images.isEmpty
              ? _showAddImageOptions
          // FIX: open GalleryViewer when images already exist
              : () => GalleryViewer.show(
            context,
            images: _images.map((x) => x.path).toList(),
            initialIndex: _defaultImageIndex
                .clamp(0, _images.length - 1),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color:        AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _images.isEmpty
                    ? AppColors.neutral400
                    : AppColors.primary,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                    color:      Colors.black12,
                    blurRadius: 8,
                    offset:     Offset(0, 4)),
              ],
            ),
            child: _images.isEmpty
                ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 52, color: AppColors.neutral500),
                SizedBox(height: 12),
                Text('Tap to add product image',
                    style: TextStyle(
                        fontSize:    15,
                        color:       AppColors.neutral600,
                        fontWeight:  FontWeight.w500)),
                SizedBox(height: 4),
                Text('JPG, PNG supported',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.neutral400)),
              ],
            )
                : Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(_images[_defaultImageIndex
                        .clamp(0, _images.length - 1)]
                        .path),
                    fit: BoxFit.cover,
                  ),
                ),
                // Default badge
                Positioned(
                  bottom: 10,
                  left:   10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color:        AppColors.primary,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Default',
                            style: TextStyle(
                                color:      Colors.white,
                                fontSize:   11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                // Count badge
                if (_images.length > 1)
                  Positioned(
                    top:   10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color:        Colors.black54,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('${_images.length} photos',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11)),
                    ),
                  ),
                // Hint overlay
                Positioned(
                  top:   10,
                  left:  10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color:        Colors.black38,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Tap to view',
                            style: TextStyle(
                                color:    Colors.white,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Thumbnail strip ────────────────────────────────────────────────
        if (_images.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1, // +1 = Add button
              separatorBuilder: (_, _) =>
              const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                // ── Add button ─────────────────────────────────────────
                if (index == _images.length) {
                  return GestureDetector(
                    onTap: _isSubmitting ? null : _showAddImageOptions,
                    child: Container(
                      width:  88,
                      height: 88,
                      decoration: BoxDecoration(
                        color:        AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        border: Border.all(
                            color: AppColors.neutral400, width: 1.5),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: AppColors.primary, size: 26),
                          SizedBox(height: 4),
                          Text('Add',
                              style: TextStyle(
                                  fontSize:   11,
                                  color:      AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }

                // ── Regular thumbnail ──────────────────────────────────
                final isDefault = index == _defaultImageIndex;
                return Stack(
                  children: [
                    // FIX: tap thumbnail → GalleryViewer (full-screen)
                    GestureDetector(
                      onTap: _isSubmitting
                          ? null
                          : () => GalleryViewer.show(
                        context,
                        images: _images
                            .map((x) => x.path)
                            .toList(),
                        initialIndex: index,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width:  88,
                        height: 88,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(AppSpacing.sm),
                          border: Border.all(
                            color: isDefault
                                ? AppColors.primary
                                : AppColors.neutral300,
                            width: isDefault ? 2.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppSpacing.sm - 1),
                          child: Image.file(
                            File(_images[index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Star → set as default
                    Positioned(
                      top:   2,
                      right: 2,
                      child: GestureDetector(
                        onTap: _isSubmitting
                            ? null
                            : () => setState(
                                () => _defaultImageIndex = index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isDefault
                                ? AppColors.warning
                                : Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDefault
                                ? Icons.star
                                : Icons.star_border,
                            size:  13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Remove
                    Positioned(
                      top:  2,
                      left: 2,
                      child: GestureDetector(
                        onTap: _isSubmitting
                            ? null
                            : () => _removeImageAt(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              size: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],

        if (_images.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              context.l10n.productAddImageValidation,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _VariantFormEntry {
  final TextEditingController brandController    = TextEditingController();
  final TextEditingController colorController    = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController priceController    = TextEditingController();
  final TextEditingController qtyController      = TextEditingController();
  int? selectedSizeGroupId;
  int? selectedSizeId;

  void dispose() {
    brandController.dispose();
    colorController.dispose();
    discountController.dispose();
    priceController.dispose();
    qtyController.dispose();
  }
}