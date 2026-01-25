import 'package:flutter/material.dart';

import '../model/product.dart';
import '../pages/product_details_new.dart';
import '../themes/light_color.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ValueChanged<Product>? onSelected;
  const ProductCard({super.key, required this.product, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(product: product),
            ),
          );
          onSelected?.call(product);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Hero(
                        tag: 'product_${product.id}',
                        child: Image.asset(
                          product.images.isNotEmpty
                              ? product.images[0]
                              : 'assets/placeholder.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite
                              ? LightColor.red
                              : LightColor.iconColor,
                        ),
                        onPressed: () {
                          // Toggle like
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  if (product.discountPrice != null) ...[
                    Text(
                      '\$${product.finalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: LightColor.skyBlue,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: LightColor.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ] else
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
