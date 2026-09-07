import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../controllers/notification_controller.dart';
import '../../../core/state/auth_state.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NotificationController>();
    final username = context.read<AuthState>().user?.username ?? '';
    controller.username = username;
    controller.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          Obx(() {
            if (!controller.hasUnread) {
              return const SizedBox.shrink();
            }

            return TextButton(
              onPressed: controller.markAllAsRead,
              child: Text(
                l10n.notificationsMarkAllRead,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(
            () => RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: _buildBody(context, l10n),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      AppLocalizations l10n,
      ) {
    if (controller.isLoading.value) {
      return _NotificationShimmerList();
    }

    if (controller.error.value.isNotEmpty) {
      return _ErrorState(
        message: controller.error.value,
        onRetry: controller.loadNotifications,
      );
    }

    if (controller.notifications.isEmpty) {
      return _EmptyState(l10n: l10n);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: AppSpacing.insetsMd,
      itemCount: controller.notifications.length,
      separatorBuilder: (_, __) =>
      const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final notification = controller.notifications[index];

        return _NotificationCard(
          notification: notification,
          onTap: () {
            if (!notification.isRead) {
              controller.markAsRead(notification.id);
            }
          },
        );
      },
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      color: notification.isRead
          ? null
          : AppColors.primary.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(isRead: notification.isRead),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: notification.isRead
                                ? AppTextStyles.bodyLarge
                                : AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: AppSpacing.xs,
                            height: AppSpacing.xs,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatDate(notification.createdAt!),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}

// ── Notification icons ─────────────────────────────────────────────────────────

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({
    required this.isRead,
  });

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.xl,
      height: AppSpacing.xl,
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.primary.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications_outlined,
        size: AppSpacing.iconMd,
        color: AppColors.primary,
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: AppSpacing.insetsLg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: AppSpacing.iconXl,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.3),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.notificationsEmpty,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: AppSpacing.insetsLg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: AppSpacing.iconXl,
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withOpacity(0.6),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      message,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Shimmer loading list ──────────────────────────────────────────────────────

class _NotificationShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: AppSpacing.insetsMd,
      itemCount: 6,
      separatorBuilder: (_, __) =>
      const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => const _ShimmerCard(),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceVariant;
    final highlight = Theme.of(context).colorScheme.surface;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: AppSpacing.insetsMd,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(
                  width: AppSpacing.xl,
                  height: AppSpacing.xl,
                  radius: AppSpacing.xl,
                  base: base,
                  highlight: highlight,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(
                        width: double.infinity,
                        height: AppSpacing.md,
                        radius: AppRadius.sm,
                        base: base,
                        highlight: highlight,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _shimmerBox(
                        width: 200,
                        height: AppSpacing.sm,
                        radius: AppRadius.sm,
                        base: base,
                        highlight: highlight,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _shimmerBox(
                        width: 80,
                        height: AppSpacing.xs,
                        radius: AppRadius.sm,
                        base: base,
                        highlight: highlight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
    required Color base,
    required Color highlight,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(_shimmerAnimation.value - 1, 0),
          end: Alignment(_shimmerAnimation.value + 1, 0),
          colors: [
            base,
            highlight,
            base,
          ],
        ),
      ),
    );
  }
}