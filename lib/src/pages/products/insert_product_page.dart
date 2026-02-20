import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../data/categories_data.dart';
import '../../config/route.dart';
import '../../design/app_spacing.dart';
import '../../l10n/l10n.dart';
import '../../model/product_api.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../state/auth_state.dart';
import '../../themes/theme.dart';

class InsertProductPage extends StatefulWidget {
  const InsertProductPage({super.key});

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
  bool _isActive = true;
  final List<XFile> _images = [];
  int _defaultImageIndex = 0;
  int? _expandedCategoryId;
  int? _selectedSubCategoryId;
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = context.watch<AuthState>();
    final authUser = authState.user;
    final username = authUser?.username.trim();
    final usernamePreview = (username == null || username.isEmpty)
        ? 'Guest'
        : username;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.insertProductMenu)),
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
                _buildVariantsSection(),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Images',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_a_photo),
                      onPressed: _isSubmitting ? null : _showAddImageOptions,
                    ),
                  ],
                ),
                if (_images.isEmpty) Text(l10n.productAddImageValidation),
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
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
                              child: Image.file(
                                File(_images[index].path),
                                width: 92,
                                height: 92,
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
                                  color: isDefault
                                      ? Colors.amber
                                      : Colors.white,
                                ),
                                onPressed: _isSubmitting
                                    ? null
                                    : () {
                                        setState(() {
                                          _defaultImageIndex = index;
                                        });
                                      },
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: _isSubmitting
                                    ? null
                                    : () {
                                        setState(() {
                                          _images.removeAt(index);
                                          if (_images.isEmpty) {
                                            _defaultImageIndex = 0;
                                          } else if (index <
                                              _defaultImageIndex) {
                                            _defaultImageIndex -= 1;
                                          } else if (_defaultImageIndex >=
                                              _images.length) {
                                            _defaultImageIndex =
                                                _images.length - 1;
                                          }
                                        });
                                      },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(l10n.productCategory),
                        subtitle: _selectedSubCategoryId == null
                            ? null
                            : Text(
                                CategoriesData.getCategoryById(
                                      _selectedSubCategoryId!,
                                    )?.name ??
                                    '',
                              ),
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
                                trailing: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onTap: _isSubmitting
                                    ? null
                                    : () {
                                        setState(() {
                                          if (_expandedCategoryId ==
                                              mainCategory.id) {
                                            _expandedCategoryId = null;
                                          } else {
                                            _expandedCategoryId =
                                                mainCategory.id;
                                          }
                                        });
                                      },
                              ),
                              if (isExpanded)
                                ...mainCategory.children.map((child) {
                                  final isSelected =
                                      _selectedSubCategoryId == child.id;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.only(
                                      left: 32,
                                      right: 16,
                                    ),
                                    title: Text(child.name),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                        : null,
                                    tileColor: isSelected
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : null,
                                    onTap: _isSubmitting
                                        ? null
                                        : () {
                                            setState(() {
                                              _selectedSubCategoryId = child.id;
                                            });
                                          },
                                  );
                                }),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '${l10n.productUsername}: $usernamePreview',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.productIsActive),
                  value: _isActive,
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                ),
                const SizedBox(height: AppSpacing.xl),
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

  Future<void> _submit() async {
    if (_submitLocked || _isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSubCategoryId == null) {
      AppSnackBar.show(
        context,
        message: context.l10n.productSelectCategoryValidation,
        type: AppSnackBarType.warning,
      );
      return;
    }
    if (_images.isEmpty) {
      AppSnackBar.show(
        context,
        message: context.l10n.productAddImageValidation,
        type: AppSnackBarType.warning,
      );
      return;
    }

    final authState = context.read<AuthState>();
    final createdBy = authState.user?.username.trim() ?? '';
    if (createdBy.isEmpty) {
      AppSnackBar.show(
        context,
        message: context.l10n.productAccountUnavailable,
        type: AppSnackBarType.error,
      );
      return;
    }

    final orderedImagePaths = _orderedImagePathsForSubmit();
    if (orderedImagePaths.isEmpty) {
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

    _submitLocked = true;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final imagesCsv = orderedImagePaths.isEmpty
          ? null
          : orderedImagePaths.join(',');
      final request = CreateProductRequest(
        itemName: _nameController.text.trim(),
        itemDesc: _descController.text.trim(),
        itemPrice: details.first.itemPrice,
        itemQty: details.first.itemQty,
        itemImgUrl: imagesCsv,
        imagesCsv: imagesCsv,
        details: details,
        categoryId: _selectedSubCategoryId!,
        createdBy: createdBy,
        isActive: _isActive ? 1 : 0,
      );
      final requestBody = {
        'items': [request.toJson()],
      };
      if (kDebugMode) {
        debugPrint('=== Product Insertion Debug ===');
        debugPrint('created_by: $createdBy');
        debugPrint('Is Logged In: ${authState.isLoggedIn}');
        debugPrint('Auth User Object: ${authState.user}');
        debugPrint('Item Name: "${_nameController.text}"');
        debugPrint('Item Desc: "${_descController.text}"');
        debugPrint('Variants count: ${details.length}');
        debugPrint('Category ID: $_selectedSubCategoryId');
        debugPrint('item_img_url: ${request.itemImgUrl}');
        debugPrint('Request body: $requestBody');
        _debugLogInsertPayloadTypes(requestBody);
        debugPrint('===============================');
      }
      await _productService.insertProduct(request);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: context.l10n.productInsertSuccess,
        type: AppSnackBarType.success,
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (route) => false,
      );
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
        message: context.l10n.productInsertFailed,
        type: AppSnackBarType.error,
      );
    } finally {
      _submitLocked = false;
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image == null) return;
    if (!mounted) return;
    setState(() {
      _images.add(image);
      if (_images.length == 1) {
        _defaultImageIndex = 0;
      }
    });
  }

  List<String> _orderedImagePathsForSubmit() {
    final paths = _images.map((image) => image.path.trim()).toList();
    if (paths.isEmpty) return const [];
    if (paths.length == 1) return [paths.first];
    final safeDefaultIndex = _defaultImageIndex.clamp(0, paths.length - 1);
    final ordered = <String>[paths[safeDefaultIndex]];
    for (var i = 0; i < paths.length; i++) {
      if (i == safeDefaultIndex) continue;
      ordered.add(paths[i]);
    }
    return ordered.where((path) => path.isNotEmpty).toList();
  }

  Widget _buildVariantsSection() {
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
                  style: TextStyle(fontWeight: FontWeight.w600),
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
            const Text('Please add at least one variant.')
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
  }

  Widget _buildVariantCard(int index, _VariantFormEntry variant) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      padding: AppSpacing.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Variant ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _removeVariantEntry(index),
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
          AppTextField(
            controller: variant.brandController,
            label: 'Brand',
            hintText: 'Enter brand',
            validator: _requiredValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: variant.colorController,
            label: context.l10n.productColor,
            hintText: 'Enter color',
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _positiveDoubleValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: variant.qtyController,
            label: context.l10n.productQuantityLabel,
            hintText: context.l10n.productQuantityHint,
            keyboardType: TextInputType.number,
            validator: _positiveIntOrEmptyDefaultValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: variant.discountController,
            label: 'Discount (%)',
            hintText: 'Optional, defaults to 0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _nonNegativeDoubleOrEmptyValidator,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  void _addVariantEntry() {
    setState(() {
      _variantEntries.add(_VariantFormEntry());
    });
  }

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
    for (final variant in _variantEntries) {
      final brand = variant.brandController.text.trim();
      final color = variant.colorController.text.trim();
      final size = variant.sizeController.text.trim();
      final priceText = variant.priceController.text.trim();
      final qtyText = variant.qtyController.text.trim();
      final discountText = variant.discountController.text.trim();
      final price = double.tryParse(priceText);
      final qty = qtyText.isEmpty ? 1 : int.tryParse(qtyText);
      final double discount = discountText.isEmpty
          ? 0.0
          : (double.tryParse(discountText) ?? 0.0);
      if (brand.isEmpty ||
          color.isEmpty ||
          size.isEmpty ||
          price == null ||
          price <= 0 ||
          qty == null ||
          qty < 1) {
        return const [];
      }
      details.add(
        CreateProductDetail(
          brand: brand,
          color: color,
          itemSize: size,
          discount: discount < 0 ? 0.0 : discount,
          itemPrice: price,
          itemQty: qty,
        ),
      );
    }
    return details;
  }

  String? _nonNegativeDoubleOrEmptyValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) return context.l10n.productInvalidValue;
    return null;
  }

  String? _positiveIntOrEmptyDefaultValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) return context.l10n.productInvalidValue;
    return null;
  }

  void _debugLogInsertPayloadTypes(Map<String, dynamic> requestBody) {
    if (!kDebugMode) return;
    final items = requestBody['items'];
    if (items is! List || items.isEmpty || items.first is! Map) {
      debugPrint('[InsertProduct][Types] Invalid items payload.');
      return;
    }
    final product = Map<String, dynamic>.from(items.first as Map);
    debugPrint(
      '[InsertProduct][Types] item_name: ${product['item_name']?.runtimeType}',
    );
    debugPrint(
      '[InsertProduct][Types] item_desc: ${product['item_desc']?.runtimeType}',
    );
    debugPrint(
      '[InsertProduct][Types] item_price: ${product['item_price']?.runtimeType}',
    );
    debugPrint(
      '[InsertProduct][Types] item_qty: ${product['item_qty']?.runtimeType}',
    );
    debugPrint(
      '[InsertProduct][Types] item_img_url: ${product['item_img_url']?.runtimeType}',
    );
    debugPrint(
      '[InsertProduct][Types] category_id: ${product['category_id']?.runtimeType}',
    );
    debugPrint(
      '[InsertProduct][Types] created_by: ${product['created_by']?.runtimeType}',
    );
    debugPrint(
      '[InsertProduct][Types] is_active: ${product['is_active']?.runtimeType}',
    );
    final details = product['details'];
    if (details is List && details.isNotEmpty && details.first is Map) {
      final firstDetail = Map<String, dynamic>.from(details.first as Map);
      debugPrint(
        '[InsertProduct][Types] details.brand: ${firstDetail['brand']?.runtimeType}',
      );
      debugPrint(
        '[InsertProduct][Types] details.color: ${firstDetail['color']?.runtimeType}',
      );
      debugPrint(
        '[InsertProduct][Types] details.item_size: ${firstDetail['item_size']?.runtimeType}',
      );
      debugPrint(
        '[InsertProduct][Types] details.discount: ${firstDetail['discount']?.runtimeType}',
      );
      debugPrint(
        '[InsertProduct][Types] details.item_price: ${firstDetail['item_price']?.runtimeType}',
      );
      debugPrint(
        '[InsertProduct][Types] details.item_qty: ${firstDetail['item_qty']?.runtimeType}',
      );
    }
  }
}

class _VariantFormEntry {
  final TextEditingController brandController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  void dispose() {
    brandController.dispose();
    colorController.dispose();
    sizeController.dispose();
    discountController.dispose();
    priceController.dispose();
    qtyController.dispose();
  }
}
