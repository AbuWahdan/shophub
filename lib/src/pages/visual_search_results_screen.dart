import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/widgets/empty_state_widget.dart';
import '../design/app_text_styles.dart';
import '../model/product_api.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';

class VisualSearchResultsScreen extends StatelessWidget {
  final File imageFile;
  final List<ApiProduct> products;

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
                    padding: AppTheme.padding,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
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
                      padding: AppTheme.hPadding,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
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
