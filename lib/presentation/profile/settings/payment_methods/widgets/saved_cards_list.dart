import 'package:flutter/material.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../models/credit_card_model.dart';
import 'saved_card_tile.dart';

class SavedCardsList extends StatelessWidget {
  const SavedCardsList({
    super.key,
    required this.cards,
    required this.onSetDefault,
    required this.onDelete,
  });

  final List<CreditCardModel> cards;
  final ValueChanged<CreditCardModel> onSetDefault;
  final ValueChanged<CreditCardModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: cards.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final card = cards[index];
        return SavedCardTile(
          card: card,
          onSetDefault: () => onSetDefault(card),
          onDelete: () => onDelete(card),
        );
      },
    );
  }
}
