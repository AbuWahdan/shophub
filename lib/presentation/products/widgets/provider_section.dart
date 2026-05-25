import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProviderSection extends StatelessWidget {
  final String providerName;
  final VoidCallback onTap;

  const ProviderSection({
    super.key,
    required this.providerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        // Matching the 12px padding from .info class
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 11, color: Color(0xFF666666)), // .seller style
            children: [
              const TextSpan(text: "Sold by: "),
              TextSpan(
                text: "$providerName ✔",
                style: const TextStyle(
                  color: Color(0xFF4e54c8), // .seller span style
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}