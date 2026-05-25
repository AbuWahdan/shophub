import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/credit_card_controller.dart';
import '../../../../core/config/route.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/credit_card_model.dart';
import '../../../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../widgets/custom_empty_state/custom_empty_state.dart';
import 'widgets/card_preview_widget.dart';
import 'widgets/payment_methods_tokens.dart';
import 'widgets/save_card_button.dart';
import 'widgets/saved_cards_list.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCards());
  }

  Future<void> _loadCards() async {
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!mounted) return;
    final username = authState.user?.username.trim() ?? '';
    await context.read<CreditCardController>().fetchCards(username);
  }

  Future<void> _deleteCard(int cardId) async {
    final controller = context.read<CreditCardController>();
    final l10n = AppLocalizations.of(context);
    await controller.deleteCard(cardId);
    if (!mounted) return;
    final error = controller.errorMessage?.trim();
    CustomSnackBar.show(
      context,
      message: error == null || error.isEmpty ? l10n.cardDeletedSuccess : error,
      type: error == null || error.isEmpty
          ? AppSnackBarType.success
          : AppSnackBarType.error,
    );
  }

  Future<void> _openAddCard() async {
    final added = await Navigator.pushNamed(context, AppRoutes.addCard);
    if (added == true) {
      await _loadCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<CreditCardController>();
    final authState = context.watch<AuthState>();
    final isLoggedIn = authState.isLoggedIn && authState.user != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.paymentMethodsTitle)),
      body: RefreshIndicator(
        onRefresh: _loadCards,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: CardPreviewWidget(
                  cardType: controller.cards.isNotEmpty
                      ? controller.cards.first.cardType
                      : 'VISA',
                  cardNumber: controller.cards.isNotEmpty
                      ? controller.cards.first.maskedNumber
                      : '',
                  cardholderName: controller.cards.isNotEmpty
                      ? controller.cards.first.cardholderName
                      : '',
                  expiryText: controller.cards.isNotEmpty
                      ? controller.cards.first.expiryFormatted
                      : l10n.cardPreviewExpiry,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.savedCardsTitle,
                        style: AppTextStyles.headingSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.addNewCardTitle,
                      onPressed: _openAddCard,
                      icon: const Icon(PaymentMethodsTokens.addCardIcon),
                    ),
                  ],
                ),
              ),
            ),
            if (!isLoggedIn)
              SliverFillRemaining(
                hasScrollBody: false,
                child: CustomEmptyState(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.wishlistLoginRequired,
                  subtitle: l10n.noCardsSubtitle,
                ),
              )
            else if (!controller.hasLoaded || controller.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if ((controller.errorMessage?.trim() ?? '').isNotEmpty &&
                controller.cards.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: CustomEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: controller.errorMessage!.trim(),
                  subtitle: l10n.retry,
                ),
              )
            else if (controller.cards.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: CustomEmptyState(
                  icon: PaymentMethodsTokens.cardIcon,
                  title: l10n.noCardsTitle,
                  subtitle: l10n.noCardsSubtitle,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xxxl,
                ),
                sliver: SavedCardsList(
                  cards: controller.cards,
                  onSetDefault: (card) => controller.setDefault(card.cardId),
                  onDelete: (CreditCardModel card) => _deleteCard(card.cardId),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: SaveCardButton(
          label: l10n.addNewCardTitle,
          isSaving: false,
          onPressed: _openAddCard,
        ),
      ),
    );
  }
}
