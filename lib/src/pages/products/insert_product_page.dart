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
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();

  final ProductService _productService = ProductService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;
  bool _isActive = true;
  final List<XFile> _images = [];
  int _defaultImageIndex = 0;
  int? _expandedCategoryId;
  int? _selectedSubCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
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

  String? _positiveIntValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return context.l10n.productRequiredField;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 0) return context.l10n.productInvalidValue;
    return null;
  }

  Future<void> _submit() async {
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
    final itemOwner = _resolveCreatorUserId(authState.userId, authState.user);
    if (itemOwner <= 0) {
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
    final imagesCsv = orderedImagePaths.join(',');

    final request = CreateProductRequest(
      itemName: _nameController.text.trim(),
      itemDesc: _descController.text.trim(),
      itemPrice: double.parse(_priceController.text.trim()),
      itemQty: int.parse(_qtyController.text.trim()),
      itemImgUrl: orderedImagePaths.first,
      imagesCsv: imagesCsv,
      categoryId: _selectedSubCategoryId!,
      itemOwner: itemOwner,
      isActive: _isActive ? 1 : 0,
    );

    if (kDebugMode) {
      debugPrint('=== Product Insertion Debug ===');
      debugPrint('User ID: $itemOwner');
      debugPrint('User ID Type: ${itemOwner.runtimeType}');
      debugPrint('Is Logged In: ${authState.isLoggedIn}');
      debugPrint('Auth User Object: ${authState.user}');
      debugPrint('Item Name: "${_nameController.text}"');
      debugPrint('Item Desc: "${_descController.text}"');
      debugPrint('Item Price: "${_priceController.text}"');
      debugPrint('Item Qty: "${_qtyController.text}"');
      debugPrint('Category ID: $_selectedSubCategoryId');
      debugPrint('Default Image Path: "${orderedImagePaths.first}"');
      debugPrint('Images CSV: "$imagesCsv"');
      debugPrint('Request JSON: ${request.toJson()}');
      debugPrint('===============================');
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
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

  int _resolveCreatorUserId(int userId, dynamic user) {
    if (user != null) {
      final userModelId = user.userId;
      if (userModelId is int && userModelId > 0) return userModelId;
    }
    return userId > 0 ? userId : 0;
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
}
