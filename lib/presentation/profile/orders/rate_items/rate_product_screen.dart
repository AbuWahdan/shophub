// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../../models/product_api.dart';
// import '../../../../core/app/app_theme.dart';
// import '../../../../services/product_service.dart';
// import '../../../../core/state/auth_state.dart';
// import '../../../../widgets/widgets/app_button.dart';
// import '../../../../widgets/widgets/app_image.dart';
// import '../../../../widgets/widgets/app_snackbar.dart';
// import '../../../../widgets/widgets/app_text_field.dart';
//
// class RateProductScreen extends StatefulWidget {
//   final ApiProduct product;
//
//   const RateProductScreen({
//     super.key,
//     required this.product,
//   });
//
//   @override
//   State<RateProductScreen> createState() => _RateProductScreenState();
// }
//
// class _RateProductScreenState extends State<RateProductScreen> {
//   final ProductService _productService = ProductService();
//   final _commentController = TextEditingController();
//   int _rating = 0;
//   bool _isSubmitting = false;
//
//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleSubmit() async {
//     final auth = context.read<AuthState>();
//     final username = auth.user?.username.trim() ?? '';
//
//     if (username.isEmpty) {
//       AppSnackBar.show(
//         context,
//         message: 'Please log in to submit a review',
//         type: AppSnackBarType.warning,
//       );
//       return;
//     }
//
//     if (_rating < 1 || _rating > 5) {
//       AppSnackBar.show(
//         context,
//         message: 'Please select a rating',
//         type: AppSnackBarType.warning,
//       );
//       return;
//     }
//
//     final comment = _commentController.text.trim();
//     if (comment.isNotEmpty && comment.length < 3) {
//       AppSnackBar.show(
//         context,
//         message: 'Comment must be at least 3 characters',
//         type: AppSnackBarType.warning,
//       );
//       return;
//     }
//
//     if (_isSubmitting) return;
//     setState(() => _isSubmitting = true);
//
//     try {
//       await _productService.addItemComment(
//         itemId: widget.product.id,
//         username: username,
//         rating: _rating,
//         comment: comment,
//       );
//
//       if (!mounted) return;
//       AppSnackBar.show(
//         context,
//         message: 'Review submitted!',
//         type: AppSnackBarType.success,
//       );
//
//       await Future.delayed(const Duration(milliseconds: 500));
//       if (mounted) Navigator.pop(context);
//     } catch (error) {
//       if (!mounted) return;
//       setState(() => _isSubmitting = false);
//       AppSnackBar.show(
//         context,
//         message: error.toString(),
//         type: AppSnackBarType.error,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final product = widget.product;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Rate Product'), centerTitle: true),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: AppSpacing.insetsMd,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Product Image (200px hero)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   width: double.infinity,
//                   height: 200,
//                   color: AppColors.surfaceVariant,
//                   child: product.images.isNotEmpty &&
//                           product.images.first.trim().isNotEmpty
//                       ? AppImage(
//                           path: product.images.first.trim(),
//                           fit: BoxFit.cover,
//                         )
//                       : Center(
//                           child: Icon(
//                             Icons.image_outlined,
//                             size: 80,
//                             color: Colors.grey.shade400,
//                           ),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.lg),
//
//               // Product Name
//               Text(
//                 product.itemName,
//                 style: AppTextStyles.titleLarge,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: AppSpacing.sm),
//
//               // Product Details (brand, color, size)
//               if (product.details.isNotEmpty)
//                 Builder(
//                   builder: (context) {
//                     final variant = product.details.first;
//                     final details = <String>[
//                       if (variant.brand.trim().isNotEmpty) variant.brand,
//                       if (variant.color.trim().isNotEmpty) variant.color,
//                       if (variant.itemSize.trim().isNotEmpty &&
//                           variant.itemSize != 'Default')
//                         variant.itemSize,
//                     ];
//                     if (details.isEmpty) return const SizedBox.shrink();
//                     return Text(
//                       details.join(' • '),
//                       style: AppTextStyles.bodySmall
//                           .copyWith(color: Colors.grey.shade600),
//                       textAlign: TextAlign.center,
//                     );
//                   },
//                 ),
//               const SizedBox(height: AppSpacing.xxl),
//
//               // 5-Star Rating Row
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Your Rating', style: AppTextStyles.titleSmall),
//                   const SizedBox(height: AppSpacing.md),
//                   Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(5, (index) {
//                         final starNumber = index + 1;
//                         final isSelected = _rating >= starNumber;
//
//                         return GestureDetector(
//                           onTap: () =>
//                               setState(() => _rating = starNumber),
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 8),
//                             child: AnimatedScale(
//                               scale: isSelected ? 1.1 : 1.0,
//                               duration: const Duration(milliseconds: 200),
//                               child: Icon(
//                                 isSelected
//                                     ? Icons.star_rounded
//                                     : Icons.star_border_rounded,
//                                 size: 40,
//                                 color: isSelected
//                                     ? const Color(0xFFFFB800)
//                                     : Colors.grey.shade400,
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.sm),
//                   Center(
//                     child: Text(
//                       _rating > 0 ? '$_rating / 5' : 'Tap to rate',
//                       style: AppTextStyles.bodySmall
//                           .copyWith(color: Colors.grey.shade600),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: AppSpacing.xxl),
//
//               // Comment Field
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Your Review (optional)',
//                       style: AppTextStyles.titleSmall),
//                   const SizedBox(height: AppSpacing.md),
//                   AppTextField(
//                     controller: _commentController,
//                     label: 'Review',
//                     hintText: 'Write your thoughts here...',
//                     maxLines: 4,
//                     minLines: 3,
//                     maxLength: 500,
//                     onChanged: (_) => setState(() {}),
//                   ),
//                   const SizedBox(height: AppSpacing.sm),
//                   Text('${_commentController.text.length}/500',
//                       style: AppTextStyles.caption
//                           .copyWith(color: Colors.grey.shade500)),
//                 ],
//               ),
//               const SizedBox(height: AppSpacing.xxl),
//
//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 child: AppButton(
//                   label: 'Submit Review',
//                   onPressed:
//                       _isSubmitting || _rating == 0 ? null : _handleSubmit,
//                   leading: _isSubmitting
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child:
//                               CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : null,
//                 ),
//               ),
//               const SizedBox(height: AppSpacing.xl),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
