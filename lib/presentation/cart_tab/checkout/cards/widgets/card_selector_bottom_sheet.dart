import 'package:flutter/material.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../models/credit_card_model.dart';
import 'credit_card_tile.dart';

class CardSelectorResult {
  const CardSelectorResult._({this.card, this.addNew = false});

  const CardSelectorResult.card(CreditCardModel card) : this._(card: card);

  const CardSelectorResult.addNew() : this._(addNew: true);

  final CreditCardModel? card;
  final bool addNew;
}

class CardSelectorBottomSheet extends StatelessWidget {
  const CardSelectorBottomSheet({
    super.key,
    required this.cards,
    this.selectedCardId,
  });

  final List<CreditCardModel> cards;
  final int? selectedCardId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: AppSpacing.insetsMd,
        child: LayoutBuilder(
          builder: (context, _) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.sizeOf(context).height *
                    AppSpacing.bottomSheetMaxHeightFactor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.selectCardTitle, style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cards.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return CreditCardTile(
                          card: card,
                          compact: true,
                          selected: selectedCardId == card.cardId,
                          onTap: () => Navigator.of(
                            context,
                          ).pop(CardSelectorResult.card(card)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(const CardSelectorResult.addNew()),
                      icon: const Icon(Icons.add_card_rounded),
                      label: Text(l10n.addNewCard),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
