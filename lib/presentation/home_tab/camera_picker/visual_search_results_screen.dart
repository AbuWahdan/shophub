import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../models/product_model.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/product_card.dart';

class VisualSearchResultsScreen extends StatelessWidget {
  final File imageFile;
  final List<ProductModel> products;

  const VisualSearchResultsScreen({
    super.key,
    required this.imageFile,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visual Search Results')),
      body: SafeArea(
        child: products.isEmpty
            ? const Center(
                child: EmptyStateWidget(
                  icon: Icons.image_search,
                  title: 'No similar products found',
                  subtitle: 'Try another image with clearer product details.',
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: AppSpacing.insetsMd,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppRadius.md,
                          ),
                          child: Image.file(
                            imageFile,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Similar products',
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${products.length} matches found',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding:AppSpacing.insetsMd,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.82,
                            mainAxisSpacing: AppSpacing.lg,
                            crossAxisSpacing: AppSpacing.lg,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: products[index]);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
