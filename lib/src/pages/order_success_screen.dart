import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../shared/widgets/app_button.dart';
import '../themes/theme.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for checkmark
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Pulse animation for the circle
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse circle
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: AppSpacing.massive,
                            height: AppSpacing.massive,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ),
                        // Main circle
                        Container(
                          width: AppSpacing.hero,
                          height: AppSpacing.hero,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: const [AppShadows.buttonShadow],
                          ),
                          child: Center(
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Icon(
                                Icons.check_circle,
                                size: AppSpacing.hero,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.jumbo),
                    Text(
                      l10n.orderSuccessTitle,
                      style: AppTextStyles.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.orderSuccessSubtitle,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    Container(
                      padding: AppSpacing.insetsXl,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.orderSuccessOrderId,
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                widget.orderId,
                                style: AppTextStyles.labelLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.orderSuccessTotalAmount,
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                '\$${widget.totalAmount.toStringAsFixed(2)}',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    Text(
                      l10n.orderSuccessThanks,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: AppTheme.padding,
            child: Column(
              children: [
                AppButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/main',
                      (route) => false,
                    );
                  },
                  label: l10n.orderSuccessContinueShopping,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/orders');
                  },
                  label: l10n.orderSuccessViewOrders,
                  style: AppButtonStyle.outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
