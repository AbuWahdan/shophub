import 'package:flutter/material.dart';

import '../../../design/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_empty_state/custom_empty_state.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({
    super.key,
    required this.l10n,
    required this.onStartShopping,
  });

  final AppLocalizations l10n;
  final VoidCallback onStartShopping;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: CustomEmptyState(
            icon: Icons.shopping_cart_outlined,
            title: l10n.cartEmptyTitle,
            subtitle: l10n.cartEmptyMessage,
            action: CustomButton(
              label: l10n.cartStartShopping,
              onPressed: onStartShopping,
              leading: const Icon(Icons.shopping_bag),
              fullWidth: false,
            ),
          ),
        ),
      ),
    );
  }
}