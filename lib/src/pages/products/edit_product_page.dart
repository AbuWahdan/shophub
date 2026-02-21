import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/categories_data.dart';
import '../../../models/category.dart';
import '../../design/app_spacing.dart';
import '../../l10n/l10n.dart';
import '../../model/product_api.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_image.dart';
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
  late final TextEditingController _imageUrlController;

  final List<_EditableVariantFormEntry> _variantEntries =
      <_EditableVariantFormEntry>[];
  final List<_EditableVariantFormEntry> _retiredVariantEntries =
      <_EditableVariantFormEntry>[];
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
    _imageUrlController = TextEditingController();

    _isActive = details.isActive == 1;
    _selectedCategory = CategoriesData.getCategoryById(details.catId);
    if (_selectedCategory == null) {
      _loadCategoryById(details.catId);
    }

    try {
      _initializeVariantsFromDetailsRows();
      _initializeImages();
      _syncActiveStateFromVariantQty();
      _logVariantControllerState(
        'init',
        variantsListLength: _initialVariantsListLength(),
      );
      if (kDebugMode) {
        debugPrint(
          '[EditProduct][Init] detailsRows=${widget.detailsRows.length} variantEntries=${_variantEntries.length}',
        );
      }
    } catch (error, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showCrashSnackbar('variant-init', error, stackTrace);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    for (final entry in _variantEntries) {
      entry.qtyController.removeListener(_syncActiveStateFromVariantQty);
      entry.dispose();
    }
    for (final entry in _retiredVariantEntries) {
      entry.qtyController.removeListener(_syncActiveStateFromVariantQty);
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
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
                  Text(
                    _nameController.text.trim(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _selectedCategory?.name ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                  _buildVariantsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildImagesSection(),
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
                        : (value) {
                            _runGuarded(
                              step: 'category-onChanged',
                              fn: () => _safeSetState(
                                () => _selectedCategory = value,
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.productIsActive),
                    value: _isActive,
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            _runGuarded(
                              step: 'active-onChanged',
                              fn: () {
                                if (value && _totalVariantQty <= 0) {
                                  AppSnackBar.show(
                                    context,
                                    message:
                                        'This product must have stock to be active.',
                                    type: AppSnackBarType.warning,
                                  );
                                  return;
                                }
                                _safeSetState(() => _isActive = value);
                              },
                            );
                          },
                  ),
                  if (_totalVariantQty <= 0)
                    Text(
                      'Set variant quantity above 0 to enable active status.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
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
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            _runGuardedAsync(
                              step: 'update-onSubmit',
                              fn: _updateProduct,
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (error, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showCrashSnackbar('build', error, stackTrace);
      });
      return const Scaffold(body: SizedBox.shrink());
    }
  }

  int get _totalVariantQty {
    var sum = 0;
    for (final entry in _variantEntries) {
      final parsed = int.tryParse(entry.qtyController.text.trim()) ?? 0;
      if (parsed > 0) sum += parsed;
    }
    return sum;
  }

  void _initializeVariantsFromDetailsRows() {
    try {
      final rows = widget.detailsRows;
      if (rows.isNotEmpty) {
        for (final row in rows) {
          _variantEntries.add(_EditableVariantFormEntry.fromDetailsRow(row));
        }
      } else if (widget.product.details.isNotEmpty) {
        for (final variant in widget.product.details) {
          _variantEntries.add(_EditableVariantFormEntry.fromVariant(variant));
        }
      } else {
        _variantEntries.add(
          _EditableVariantFormEntry(
            detId: _detId > 0 ? _detId : null,
            brand: widget.details.brand,
            color: widget.details.color,
            itemSize: widget.details.itemSize.toString(),
            discount: widget.details.discount,
            itemPrice: widget.details.itemPrice,
            itemQty: widget.details.itemQty,
          ),
        );
      }

      for (final entry in _variantEntries) {
        entry.qtyController.addListener(_syncActiveStateFromVariantQty);
      }
      if (kDebugMode) {
        debugPrint(
          '[EditProduct][Variants] rows=${rows.length} controllers=${_variantEntries.length}',
        );
      }
    } catch (error, stackTrace) {
      _showCrashSnackbar('variant-initialize', error, stackTrace);
    }
  }

  void _initializeImages() {
    final fromItemImages = widget.itemImages
        .map((image) => image.imagePath.trim())
        .where((path) => path.isNotEmpty)
        .toList();
    final fromDetailsCsv = _parseImageCsv(widget.details.itemImgUrl);
    final fromProductCsv = _parseImageCsv(widget.product.itemImgUrl);

    final merged = <String>[];
    final seen = <String>{};
    for (final source in [fromItemImages, fromDetailsCsv, fromProductCsv]) {
      for (final path in source) {
        if (seen.add(path)) merged.add(path);
      }
    }

    _imagePaths
      ..clear()
      ..addAll(merged);

    final defaultFromApi = widget.itemImages.indexWhere(
      (image) => image.isDefault == 1,
    );
    if (defaultFromApi >= 0 && defaultFromApi < _imagePaths.length) {
      _defaultImageIndex = defaultFromApi;
    }
  }

  List<String> _parseImageCsv(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return const [];
    try {
      if (!value.contains(',')) {
        final single = value.replaceAll(RegExp(r'^"+|"+$'), '').trim();
        return single.isEmpty ? const [] : [single];
      }
      return value
          .split(',')
          .map((part) => part.trim())
          .map((part) => part.replaceAll(RegExp(r'^"+|"+$'), ''))
          .where((part) => part.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Widget _buildImagesSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      padding: AppSpacing.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Images', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _imageUrlController,
            label: context.l10n.productImageUrlLabel,
            hintText: context.l10n.productImageUrlHint,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      _runGuardedAsync(
                        step: 'image-add-onSubmit',
                        fn: _addImageFromInputOrPicker,
                      );
                    },
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Add image'),
            ),
          ),
          if (_imagePaths.isEmpty)
            const _SectionEmptyState(
              icon: Icons.image_not_supported_outlined,
              message: 'No images available',
            ),
          if (_imagePaths.isNotEmpty)
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _imagePaths.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final isDefault = index == _defaultImageIndex;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        child: AppImage(
                          path: _imagePaths[index],
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            isDefault ? Icons.star : Icons.star_border,
                            color: isDefault ? Colors.amber : Colors.white,
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  _runGuarded(
                                    step: 'image-default',
                                    fn: () {
                                      _safeSetState(() {
                                        _defaultImageIndex = index;
                                      });
                                    },
                                  );
                                },
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  _runGuarded(
                                    step: 'image-remove',
                                    fn: () {
                                      _safeSetState(() {
                                        _imagePaths.removeAt(index);
                                        if (_imagePaths.isEmpty) {
                                          _defaultImageIndex = 0;
                                        } else if (index < _defaultImageIndex) {
                                          _defaultImageIndex -= 1;
                                        } else if (_defaultImageIndex >=
                                            _imagePaths.length) {
                                          _defaultImageIndex =
                                              _imagePaths.length - 1;
                                        }
                                      });
                                    },
                                  );
                                },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addImageFromInputOrPicker() async {
    final value = _imageUrlController.text.trim();
    if (value.isNotEmpty) {
      _addImageFromInput();
      return;
    }
    await _showAddImageOptions();
  }

  void _addImageFromInput() {
    final value = _imageUrlController.text.trim();
    if (value.isEmpty || _imagePaths.contains(value)) {
      _imageUrlController.clear();
      return;
    }
    _safeSetState(() {
      _imagePaths.add(value);
      _imageUrlController.clear();
      if (_imagePaths.length == 1) {
        _defaultImageIndex = 0;
      }
    });
    debugPrint('[EditProduct][Image] Added from text input: $value');
  }

  Widget _buildVariantsSection() {
    try {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        padding: AppSpacing.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Variants',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: _isSubmitting ? null : _addVariantEntry,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_variantEntries.isEmpty)
              const _SectionEmptyState(
                icon: Icons.inventory_2_outlined,
                message: 'Please add at least one variant.',
              )
            else
              ..._variantEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final variant = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildVariantCard(index, variant),
                );
              }),
          ],
        ),
      );
    } catch (error, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showCrashSnackbar('variant-render', error, stackTrace);
      });
      return const SizedBox.shrink();
    }
  }

  Widget _buildVariantCard(int index, _EditableVariantFormEntry variant) {
    try {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: AppSpacing.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Variant ${index + 1}${variant.detId != null ? ' (DET_ID: ${variant.detId})' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          _runGuarded(
                            step: 'variant-remove-button',
                            fn: () => _removeVariantEntry(index),
                          );
                        },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ],
            ),
            AppTextField(
              controller: variant.colorController,
              label: context.l10n.productColor,
              hintText: 'Enter color',
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: variant.brandController,
              label: 'Brand',
              hintText: 'Enter brand',
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: variant.sizeController,
              label: context.l10n.productSize,
              hintText: 'Enter item size',
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: variant.priceController,
              label: context.l10n.productPriceLabel,
              hintText: context.l10n.productPriceHint,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _positiveDoubleValidator,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: variant.qtyController,
              label: context.l10n.productQuantityLabel,
              hintText: context.l10n.productQuantityHint,
              keyboardType: TextInputType.number,
              validator: _nonNegativeIntValidator,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: variant.discountController,
              label: 'Discount (%)',
              hintText: 'Optional, defaults to 0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _nonNegativeDoubleOrEmptyValidator,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      );
    } catch (error, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showCrashSnackbar('variant-card-render', error, stackTrace);
      });
      return const SizedBox.shrink();
    }
  }

  void _addVariantEntry() {
    try {
      _safeSetState(() {
        final entry = _EditableVariantFormEntry();
        entry.qtyController.addListener(_syncActiveStateFromVariantQty);
        _variantEntries.add(entry);
        _logVariantControllerState('variant-add');
      });
    } catch (error, stackTrace) {
      _showCrashSnackbar('variant-add', error, stackTrace);
    }
  }

  void _removeVariantEntry(int index) {
    try {
      if (_variantEntries.length == 1) return;
      if (index < 0 || index >= _variantEntries.length) {
        throw RangeError.index(index, _variantEntries, 'variantIndex');
      }
      _safeSetState(() {
        final removed = _variantEntries.removeAt(index);
        removed.qtyController.removeListener(_syncActiveStateFromVariantQty);
        _retiredVariantEntries.add(removed);
        _logVariantControllerState('variant-remove');
      });
      _syncActiveStateFromVariantQty();
    } catch (error, stackTrace) {
      _showCrashSnackbar('variant-remove', error, stackTrace);
    }
  }

  void _syncActiveStateFromVariantQty() {
    try {
      final hasStock = _totalVariantQty > 0;
      if (!hasStock && _isActive) {
        _safeSetState(() {
          _isActive = false;
        });
        return;
      }
      _safeSetState(() {});
    } catch (error, stackTrace) {
      _showCrashSnackbar('variant-sync', error, stackTrace);
    }
  }

  List<CreateProductDetail> _buildVariantDetails() {
    try {
      final details = <CreateProductDetail>[];
      for (var i = 0; i < _variantEntries.length; i++) {
        final variant = _variantEntries[i];
        final color = variant.colorController.text.trim();
        final brand = variant.brandController.text.trim();
        final size = variant.sizeController.text.trim();
        final parsedSize = int.tryParse(size) ?? 0;
        final price = double.tryParse(variant.priceController.text.trim());
        final qty = int.tryParse(variant.qtyController.text.trim()) ?? 0;
        final discountText = variant.discountController.text.trim();
        final discount = discountText.isEmpty
            ? 0.0
            : (double.tryParse(discountText) ?? 0.0);
        if (kDebugMode) {
          debugPrint(
            '[EditProduct][Variant:$i] detId=${variant.detId} sizeRaw="$size" sizeParsed=$parsedSize color="$color" brand="$brand" price=${variant.priceController.text} qty=${variant.qtyController.text}',
          );
        }
        if (variant.detId == null || variant.detId! <= 0) {
          throw StateError('Missing DET_ID for variant index $i.');
        }
        if (color.isEmpty ||
            brand.isEmpty ||
            size.isEmpty ||
            price == null ||
            price <= 0 ||
            qty < 0) {
          return const [];
        }
        details.add(
          CreateProductDetail(
            detId: variant.detId,
            color: color,
            brand: brand,
            itemSize: parsedSize,
            itemPrice: price,
            itemQty: qty,
            discount: discount < 0 ? 0 : discount,
          ),
        );
      }
      return details;
    } catch (error, stackTrace) {
      _showCrashSnackbar('variant-build-request', error, stackTrace);
      return const [];
    }
  }

  List<String> _orderedImagePathsForSubmit() {
    if (_imagePaths.isEmpty) return const [];
    if (_imagePaths.length == 1) return [_imagePaths.first];
    final safeDefault = _defaultImageIndex.clamp(0, _imagePaths.length - 1);
    final ordered = <String>[_imagePaths[safeDefault]];
    for (var i = 0; i < _imagePaths.length; i++) {
      if (i == safeDefault) continue;
      ordered.add(_imagePaths[i]);
    }
    return ordered.where((value) => value.trim().isNotEmpty).toList();
  }

  Future<void> _updateProduct() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCategory == null) {
      AppSnackBar.show(
        context,
        message: context.l10n.productSelectCategoryValidation,
        type: AppSnackBarType.warning,
      );
      return;
    }

    final imagePaths = _orderedImagePathsForSubmit();
    if (imagePaths.isEmpty) {
      AppSnackBar.show(
        context,
        message: context.l10n.productAddImageValidation,
        type: AppSnackBarType.warning,
      );
      return;
    }

    final details = _buildVariantDetails();
    if (details.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please add at least one valid product variant.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    _safeSetState(() {
      _isSubmitting = true;
    });

    var step = 'build-request';
    try {
      final normalizedQty = _totalVariantQty;
      final normalizedActive = normalizedQty <= 0 ? 0 : (_isActive ? 1 : 0);
      final normalizedPrice = details.first.itemPrice;
      final imagesCsv = imagePaths.join(',');

      final request = UpdateProductRequest(
        id: _itemId,
        detId: _detId > 0 ? _detId : null,
        itemName: _nameController.text.trim(),
        itemDesc: _descController.text.trim(),
        itemPrice: normalizedPrice,
        itemQty: normalizedQty,
        itemImgUrl: imagesCsv,
        imagesCsv: imagesCsv,
        details: details,
        categoryId: _selectedCategory!.id,
        isActive: normalizedActive,
      );

      final payload = request.toJson();
      _logUpdateRequestPayload(payload, details);

      step = 'api-update';
      final updateResult = await _productService.updateProduct(request);
      debugPrint(
        '[EditProduct][UpdateItem] status=${updateResult.statusCode} body=${updateResult.rawBody}',
      );
      if (updateResult.rawBody.toUpperCase().contains('ORA-')) {
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: updateResult.rawBody,
          type: AppSnackBarType.error,
        );
        return;
      }
      step = 'reload-details';
      final reloadedRows = await _reloadDetailsRowsFromApi();
      _verifyBackendUpdatedImage(reloadedRows, imagesCsv);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: context.l10n.productUpdateSuccess,
        type: AppSnackBarType.success,
      );
      Navigator.pop(context, true);
    } on ProductException catch (error, stackTrace) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: '[$step] ${error.message}',
        type: AppSnackBarType.error,
      );
      if (_containsOra(error.message)) {
        AppSnackBar.show(
          context,
          message: error.message,
          type: AppSnackBarType.error,
        );
      } else {
        _showCrashSnackbar(step, error, stackTrace);
      }
    } catch (error, stackTrace) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: '[$step] ${error.toString()}',
        type: AppSnackBarType.error,
      );
      _showCrashSnackbar(step, error, stackTrace);
    } finally {
      _safeSetState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _loadCategoryById(int categoryId) async {
    try {
      final category = await _productService.loadCategoryById(categoryId);
      if (!mounted || category == null) return;
      _safeSetState(() {
        _selectedCategory = CategoriesData.getCategoryById(category.id);
      });
    } catch (error, stackTrace) {
      _showCrashSnackbar('category-load', error, stackTrace);
      // Keep current state if category lookup fails.
    }
  }

  Future<List<ApiProductDetails>> _reloadDetailsRowsFromApi() async {
    try {
      final rows = await _productService.getItemDetailsRows(itemId: _itemId);
      if (!mounted || rows.isEmpty) return rows;
      final first = rows.first;
      _safeSetState(() {
        for (final entry in _variantEntries) {
          entry.qtyController.removeListener(_syncActiveStateFromVariantQty);
          _retiredVariantEntries.add(entry);
        }
        _variantEntries.clear();
        for (final row in rows) {
          final entry = _EditableVariantFormEntry.fromDetailsRow(row);
          entry.qtyController.addListener(_syncActiveStateFromVariantQty);
          _variantEntries.add(entry);
        }
        _nameController.text = first.itemName;
        _descController.text = first.itemDesc;
        _isActive = first.isActive == 1;
        _logVariantControllerState('reload');
      });
      _syncActiveStateFromVariantQty();
      return rows;
    } catch (error, stackTrace) {
      _showCrashSnackbar('reload-details', error, stackTrace);
      rethrow;
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  void _showCrashSnackbar(String step, Object error, StackTrace stackTrace) {
    if (!mounted) return;
    final stackLine = _firstStackLine(stackTrace);
    AppSnackBar.show(
      context,
      message: '[$step] ${error.toString()} | $stackLine',
      type: AppSnackBarType.error,
    );
  }

  void _runGuarded({required String step, required VoidCallback fn}) {
    try {
      fn();
    } catch (error, stackTrace) {
      _showCrashSnackbar(step, error, stackTrace);
    }
  }

  Future<void> _runGuardedAsync({
    required String step,
    required Future<void> Function() fn,
  }) async {
    try {
      await fn();
    } catch (error, stackTrace) {
      _showCrashSnackbar(step, error, stackTrace);
    }
  }

  Future<void> _showAddImageOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
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
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image == null) {
        debugPrint('[EditProduct][ImagePicker] No image selected.');
        return;
      }
      debugPrint('[EditProduct][ImagePicker] Picked path: ${image.path}');
      if (!mounted) return;
      _safeSetState(() {
        _imagePaths.add(image.path);
        if (_imagePaths.length == 1) {
          _defaultImageIndex = 0;
        }
      });
    } catch (error, stackTrace) {
      _showCrashSnackbar('image-picker', error, stackTrace);
    }
  }

  void _logVariantControllerState(String source, {int? variantsListLength}) {
    final currentVariantsListLength =
        variantsListLength ?? _variantEntries.length;
    final variantControllersLength = _variantEntries.length;
    debugPrint(
      '[EditProduct][$source] variantControllers.length=$variantControllersLength variantsList.length=$currentVariantsListLength',
    );
  }

  int _initialVariantsListLength() {
    if (widget.detailsRows.isNotEmpty) return widget.detailsRows.length;
    if (widget.product.details.isNotEmpty) return widget.product.details.length;
    return 1;
  }

  void _logUpdateRequestPayload(
    Map<String, dynamic> payload,
    List<CreateProductDetail> details,
  ) {
    debugPrint('[EditProduct][UpdateItem] request body: {"items": [$payload]}');
    debugPrint(
      '[EditProduct][UpdateItem] details count=${details.length} hasDetails=${details.isNotEmpty}',
    );
    debugPrint(
      '[EditProduct][UpdateItem] details det_ids=${details.map((d) => d.detId).toList()}',
    );
    debugPrint(
      '[EditProduct][UpdateItem] details item_price types=${details.map((d) => d.itemPrice.runtimeType).toList()}',
    );
    debugPrint(
      '[EditProduct][UpdateItem] details item_qty types=${details.map((d) => d.itemQty.runtimeType).toList()}',
    );
    debugPrint(
      '[EditProduct][UpdateItem] item_img_url=${payload['item_img_url']}',
    );
    if (kDebugMode) {
      debugPrint(
        '[EditProduct] item_size values before API call: ${details.map((d) => d.itemSize).toList()}',
      );
    }
  }

  void _verifyBackendUpdatedImage(
    List<ApiProductDetails> rows,
    String sentImagesCsv,
  ) {
    if (!mounted || rows.isEmpty) return;
    final backendImageCsv = rows.first.itemImgUrl.trim();
    final normalizedSent = _normalizeCsv(sentImagesCsv);
    final normalizedBackend = _normalizeCsv(backendImageCsv);
    if (normalizedSent.isEmpty) return;
    if (normalizedBackend != normalizedSent) {
      AppSnackBar.show(
        context,
        message:
            'Image was sent to backend but ITEM_IMG_URL was not updated in database — possible backend issue',
        type: AppSnackBarType.error,
      );
    }
  }

  String _normalizeCsv(String raw) {
    return raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(',');
  }

  bool _containsOra(String value) {
    final lower = value.toLowerCase();
    return lower.contains('ora-') || lower.contains('pl/sql');
  }

  String _firstStackLine(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return stackTrace.toString().trim();
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

  String? _nonNegativeIntValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return context.l10n.productRequiredField;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 0) return context.l10n.productInvalidValue;
    return null;
  }

  String? _nonNegativeDoubleOrEmptyValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) return context.l10n.productInvalidValue;
    return null;
  }
}

class _EditableVariantFormEntry {
  _EditableVariantFormEntry({
    this.detId,
    String color = '',
    String brand = '',
    String itemSize = '',
    double discount = 0,
    double itemPrice = 0,
    int itemQty = 0,
  }) {
    colorController.text = color;
    brandController.text = brand;
    sizeController.text = itemSize;
    discountController.text = discount == 0 ? '' : discount.toString();
    priceController.text = itemPrice == 0 ? '' : itemPrice.toString();
    qtyController.text = itemQty.toString();
  }

  factory _EditableVariantFormEntry.fromVariant(ApiProductVariant variant) {
    return _EditableVariantFormEntry(
      detId: variant.detId,
      color: variant.color,
      brand: variant.brand,
      itemSize: variant.itemSize,
      discount: variant.discount,
      itemPrice: variant.itemPrice,
      itemQty: variant.itemQty,
    );
  }

  factory _EditableVariantFormEntry.fromDetailsRow(ApiProductDetails row) {
    return _EditableVariantFormEntry(
      detId: row.detId,
      color: row.color,
      brand: row.brand,
      itemSize: row.itemSize.toString(),
      discount: row.discount,
      itemPrice: row.itemPrice,
      itemQty: row.itemQty,
    );
  }

  final int? detId;
  final TextEditingController colorController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  void dispose() {
    colorController.dispose();
    brandController.dispose();
    sizeController.dispose();
    discountController.dispose();
    priceController.dispose();
    qtyController.dispose();
  }
}

class _SectionEmptyState extends StatelessWidget {
  const _SectionEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
