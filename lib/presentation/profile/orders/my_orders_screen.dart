import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/order_controller.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../models/orders_model.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/order_card.dart'; // Ensure correct import path

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!mounted) return;

    final username = authState.user?.username.trim() ?? '';
    await context.read<OrderController>().loadOrders(username: username);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<OrderController>();
    final orders = controller.orders;
    final error = controller.error.trim();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _buildOrdersBody(
          context: context,
          controller: controller,
          orders: orders,
          error: error,
          l10n: l10n,
        ),
      ),
    );
  }

  Widget _buildOrdersBody({
    required BuildContext context,
    required OrderController controller,
    required List<OrdersModel> orders,
    required String error,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);

    if (controller.isLoading && orders.isEmpty) {
      return _buildScrollableFallback(
        child: const CircularProgressIndicator(),
      );
    }

    if (error.isNotEmpty && orders.isEmpty) {
      return _buildScrollableFallback(
        child: _OrdersStateMessage(
          icon: Icons.error_outline,
          iconColor: theme.colorScheme.error,
          title: l10n.errorLoadingOrders,
          subtitle: error,
          onRetry: _loadOrders,
        ),
      );
    }

    if (orders.isEmpty) {
      return _buildScrollableFallback(
        child: _OrdersStateMessage(
          icon: Icons.shopping_bag_outlined,
          iconColor: theme.colorScheme.outline,
          title: l10n.noOrdersYet,
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.insetsMd,
      itemCount: orders.length,
      itemBuilder: (context, index) => OrderCard(order: orders[index]),
    );
  }

  /// Ensures that empty/loading states remain scrollable to trigger the Pull-to-Refresh
  Widget _buildScrollableFallback({required Widget child}) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: child),
        ),
      ],
    );
  }
}

class _OrdersStateMessage extends StatelessWidget {
  const _OrdersStateMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: AppSpacing.insetsLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSpacing.xxl, color: iconColor),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ],
      ),
    );
  }
}