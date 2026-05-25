import 'package:flutter/material.dart';
import '../../../../../design/app_spacing.dart';
import 'payment_methods_tokens.dart';

class ExpiryCvvRow extends StatelessWidget {
  const ExpiryCvvRow({
    super.key,
    required this.monthDropdown,
    required this.yearDropdown,
    required this.cvvLabel,
    required this.cvvController,
  });

  final Widget monthDropdown;
  final Widget yearDropdown;
  final String cvvLabel;
  final TextEditingController cvvController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: monthDropdown),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: yearDropdown),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: cvvLabel,
                  prefixIcon: const Icon(PaymentMethodsTokens.lockIcon),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: monthDropdown),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: yearDropdown),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: cvvLabel,
                  prefixIcon: const Icon(PaymentMethodsTokens.lockIcon),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
