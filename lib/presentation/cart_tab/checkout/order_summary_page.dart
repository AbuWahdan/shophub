import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/addresses/address_model.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/checkout/checkout_summary_model.dart';
import '../../../models/credit_card_model.dart';
import '../../../models/payment_method_model.dart';
import '../../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom_image.dart';
import 'order_confirmation/order_confirmation_screen.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({
    super.key,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.summary,
    required this.onConfirm,
    this.promoCode,
    this.selectedCard,
    this.requiresCard = false,
  });

  final List<CartItemModel> items;
  final AddressModel address;
  final PaymentMethodModel paymentMethod;
  final CheckoutSummaryModel summary;
  final String? promoCode;
  final CreditCardModel? selectedCard;
  final bool requiresCard;
  final Future<Map<String, dynamic>> Function() onConfirm;

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    if (_isSubmitting || (widget.requiresCard && widget.selectedCard == null)) {
      return;
    }
    setState(() => _isSubmitting = true);
    Map<String, dynamic> receipt;
    try {
      receipt = await widget.onConfirm();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      CustomSnackBar.show(
        context,
        message: error.toString(),
        type: AppSnackBarType.error,
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          receipt: receipt,
          total: widget.summary.grandTotal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderSummaryTitle)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: CustomButton(
            label: l10n.confirmOrder,
            leading: _isSubmitting
                ? const SizedBox(
                    width: AppSpacing.iconMd,
                    height: AppSpacing.iconMd,
                    child: CircularProgressIndicator(),
                  )
                : null,
            onPressed: widget.requiresCard && widget.selectedCard == null
                ? null
                : _confirm,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.insetsMd,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: l10n.orderItemsSection,
                      child: Column(
                        children: widget.items
                            .map((item) => _OrderItemRow(item: item))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Section(
                      title: l10n.deliveryAddressSection,
                      child: Text(
                        [
                          widget.address.label,
                          widget.address.streetAddress,
                          widget.address.city,
                          widget.address.country,
                        ].where((part) => part.trim().isNotEmpty).join(', '),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Section(
                      title: l10n.checkoutPaymentMethod,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.paymentMethod.label,
                            style: AppTextStyles.bodyMedium,
                          ),
                          if (widget.selectedCard != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.selectedCard!.maskedNumber,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Section(
                      title: l10n.amountBreakdownSection,
                      child: _AmountBreakdown(
                        summary: widget.summary,
                        promoCode: widget.promoCode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.insetsMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: CustomImage(
              path: item.imageUrl,
              width: AppSpacing.xxl,
              height: AppSpacing.xxl,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.checkoutQuantity(item.bookedQty),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            currency.format(item.lineTotal),
            style: AppTextStyles.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _AmountBreakdown extends StatelessWidget {
  const _AmountBreakdown({required this.summary, this.promoCode});

  final CheckoutSummaryModel summary;
  final String? promoCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
    final code = promoCode?.trim() ?? '';

    return Column(
      children: [
        _AmountRow(
          label: l10n.orderSubtotal,
          value: currency.format(summary.subtotal),
        ),
        if (summary.tax > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          _AmountRow(label: l10n.orderTax, value: currency.format(summary.tax)),
        ],
        if (summary.itemDiscount > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          _AmountRow(
            label: l10n.orderDiscount,
            value: currency.format(summary.itemDiscount),
            valueColor: AppColors.error,
          ),
        ],
        if (summary.promoDiscount > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          if (code.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(label: Text(l10n.orderPromoApplied(code))),
            ),
          _AmountRow(
            label: l10n.orderPromoDiscount,
            value: currency.format(summary.promoDiscount),
            valueColor: AppColors.error,
          ),
        ],
        const Divider(height: AppSpacing.xl),
        _AmountRow(
          label: l10n.orderTotal,
          value: currency.format(summary.grandTotal),
          isTotal: true,
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? AppTextStyles.titleMedium
                : AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          value,
          style:
              (isTotal ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium)
                  .copyWith(
                    color: valueColor,
                    fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
                  ),
        ),
      ],
    );
  }
}
