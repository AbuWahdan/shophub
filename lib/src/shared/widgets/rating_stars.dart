import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.maxStars = 5,
    this.color = const Color(0xFFFFB800),
  });

  final double rating;
  final double size;
  final int maxStars;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clampedRating = rating.clamp(0, maxStars.toDouble());
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(maxStars, (index) {
        final starNumber = index + 1;
        final icon = clampedRating >= starNumber
            ? Icons.star_rounded
            : clampedRating >= starNumber - 0.5
            ? Icons.star_half_rounded
            : Icons.star_border_rounded;
        return Icon(icon, size: size, color: color);
      }),
    );
  }
}
