import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/credit_card_controller.dart';
import '../../core/config/route.dart';
import '../../core/state/auth_state.dart';
import '../../design/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../widgets/custom_empty_state/custom_empty_state.dart';
import '../../widgets/custom_fab/custom_fab.dart';
import 'widgets/credit_card_tile.dart';

class MyCardsPage extends StatefulWidget {
  const MyCardsPage({super.key});

  @override
  State<MyCardsPage> createState() => _MyCardsPageState();
}

class _MyCardsPageState extends State<MyCardsPage> {
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
      appBar: AppBar(title: Text(l10n.myCardsTitle)),
      floatingActionButton: CustomFab(
        onPressed: _openAddCard,
        icon: Icons.add_card_rounded,
        label: l10n.addCard,
        tooltip: l10n.addCard,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCards,
        child: LayoutBuilder(
          builder: (context, _) {
            if (!isLoggedIn) {
              return _CardsMessage(
                icon: Icons.lock_outline_rounded,
                title: l10n.wishlistLoginRequired,
                subtitle: l10n.noCardsSubtitle,
              );
            }

            if (!controller.hasLoaded || controller.isLoading) {
              return const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            final error = controller.errorMessage?.trim() ?? '';
            if (error.isNotEmpty && controller.cards.isEmpty) {
              return _CardsMessage(
                icon: Icons.error_outline_rounded,
                title: error,
                subtitle: l10n.retry,
              );
            }

            if (controller.cards.isEmpty) {
              return _CardsMessage(
                icon: Icons.credit_card_rounded,
                title: l10n.noCardsTitle,
                subtitle: l10n.noCardsSubtitle,
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.insetsMd,
              itemCount: controller.cards.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final card = controller.cards[index];
                return CreditCardTile(
                  card: card,
                  onSetDefault: () => controller.setDefault(card.cardId),
                  onDelete: () => _deleteCard(card.cardId),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CardsMessage extends StatelessWidget {
  const _CardsMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: CustomEmptyState(icon: icon, title: title, subtitle: subtitle),
        ),
      ],
    );
  }
}
