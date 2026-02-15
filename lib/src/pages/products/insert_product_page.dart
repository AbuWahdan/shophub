import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../design/app_spacing.dart';
import '../../model/category.dart';
import '../../model/data.dart';
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
  List<XFile> _images = [];
  int _defaultImageIndex = 0;
  Categories? _selectedCategory;

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
    final authState = context.watch<AuthState>();
    final authUser = authState.user;
    final createdByPreview = _resolveCreatedBy(authState.userId, authUser);

    return Scaffold(
      appBar: AppBar(title: const Text('Insert Product')),
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
                  label: 'Item Name',
                  hintText: 'Enter item name',
                  validator: _requiredValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _descController,
                  label: 'Item Description',
                  hintText: 'Enter item description',
                  validator: _requiredValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _priceController,
                  label: 'Item Price',
                  hintText: 'Enter item price',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _positiveDoubleValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _qtyController,
                  label: 'Item Quantity',
                  hintText: 'Enter item quantity',
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
                if (_images.isEmpty)
                  const Text('Please add at least one image.'),
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      separatorBuilder: (_, __) =>
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
                DropdownButtonFormField<Categories>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'Select a category',
                  ),
                  items: AppData.categoryList
                      .where(
                        (category) =>
                            category.name != null && category.name != 'All',
                      )
                      .map(
                        (category) => DropdownMenuItem<Categories>(
                          value: category,
                          child: Text(category.name!),
                        ),
                      )
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Created by: $createdByPreview',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Is Active'),
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
                  label: 'Insert Product',
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
      return 'Required field';
    }
    return null;
  }

  String? _positiveDoubleValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Required field';
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) return 'Enter a valid value';
    return null;
  }

  String? _positiveIntValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Required field';
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 0) return 'Enter a valid value';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory?.id == null) {
      AppSnackBar.show(
        context,
        message: 'Please select a category.',
        type: AppSnackBarType.warning,
      );
      return;
    }
    if (_images.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please add product images.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    final authState = context.read<AuthState>();
    final createdBy = _resolveCreatedBy(authState.userId, authState.user);
    if (createdBy.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Account details are not available.',
        type: AppSnackBarType.error,
      );
      return;
    }

    final request = CreateProductRequest(
      itemName: _nameController.text.trim(),
      itemDesc: _descController.text.trim(),
      itemPrice: double.parse(_priceController.text.trim()),
      itemQty: int.parse(_qtyController.text.trim()),
      itemImgUrl: _images[_defaultImageIndex].path,
      categoryId: _selectedCategory!.id!,
      createdBy: createdBy,
      isActive: _isActive ? 1 : 0,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _productService.insertProduct(request);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Product inserted successfully.',
        type: AppSnackBarType.success,
      );
      _formKey.currentState?.reset();
      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _qtyController.clear();
      setState(() {
        _isActive = true;
        _images = [];
        _defaultImageIndex = 0;
        _selectedCategory = null;
      });
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
        message: 'Failed to insert product.',
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

  String _resolveCreatedBy(String userId, dynamic user) {
    final id = userId.trim();
    if (id.isNotEmpty) return id;
    if (user == null) return '';
    final username = (user.username ?? '').toString().trim();
    if (username.isNotEmpty) return username;
    final fullName = (user.fullname ?? '').toString().trim();
    if (fullName.isNotEmpty) return fullName;
    final email = (user.email ?? '').toString().trim();
    if (email.isNotEmpty) return email;
    return '';
  }
}
