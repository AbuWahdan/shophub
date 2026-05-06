import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/design/app_radius.dart';
import 'package:sinwar_shoping/models/cart_item_model.dart';
import '../../../../controllers/address_controller.dart';
import '../../../../core/utils/apex_response_helper.dart';
import '../../../../models/payment_method_model.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/addresses/address_model.dart';
import '../../../../models/get_code_option_model.dart';
import '../../../models/checkout/checkout_request_model.dart';
import '../../../models/checkout/checkout_summary_model.dart';
import '../../../core/state/auth_state.dart';
import '../../../repositories/checkout_repository.dart';
import '../../../repositories/codes_repository.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../profile/addresses/widgets/address_selection_bottom_sheet.dart';
import '../../profile/addresses/addresses_page.dart';
import 'order_confirmation/order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cartItems});

  final List<CartItemModel> cartItems;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final AddressController _addressController;
  late final CheckoutRepository _checkoutRepository;
  late final CodesRepository _codesRepository;

  // Added Promo Controller
  late final TextEditingController _promoController;

  bool _isSubmitting = false;
  bool _isLoadingAddresses = false;
  bool _isLoadingPaymentMethods = false;
  AddressModel? _selectedAddress;
  int? _selectedPaymentMethodId;
  String? _addressError;
  String? _paymentMethodError;
  String? _paymentMethodLoadError;
  String? _authError;
  bool _isValidatingPromo = false;
  PromoValidationResult? _promoResult;
  String? _promoError;
  Timer? _promoDebounce;
  int _promoValidationToken = 0;
  List<GetCodeOptionModel> _paymentMethodOptions = const <GetCodeOptionModel>[];

  @override
  void initState() {
    super.initState();
    _addressController = Get.find<AddressController>();
    _checkoutRepository = Get.find<CheckoutRepository>();
    _codesRepository = Get.find<CodesRepository>();
    _promoController = TextEditingController();
    _promoController.addListener(_onPromoCodeChanged);
    _loadUserAddresses();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _promoDebounce?.cancel();
    _promoController
      ..removeListener(_onPromoCodeChanged)
      ..dispose();
    super.dispose();
  }

  CheckoutSummaryModel get _checkoutSummary =>
      CheckoutSummaryModel.fromCartItems(
        widget.cartItems,
        promoDiscount: _promoResult?.isValid == true
            ? _promoResult!.discountAmount
            : 0,
      );

  double get _totalPrice => _checkoutSummary.grandTotal;

  void _onPromoCodeChanged() {
    _promoDebounce?.cancel();
    final code = _promoController.text.trim();
    final token = ++_promoValidationToken;

    if (code.isEmpty) {
      setState(() {
        _isValidatingPromo = false;
        _promoResult = null;
        _promoError = null;
      });
      return;
    }

    setState(() {
      _isValidatingPromo = true;
      _promoError = null;
      _promoResult = null;
    });

    _promoDebounce = Timer(
      const Duration(milliseconds: 600),
      () => _validatePromoCode(code: code, token: token),
    );
  }

  Future<void> _validatePromoCode({
    required String code,
    required int token,
  }) async {
    try {
      final summary = CheckoutSummaryModel.fromCartItems(widget.cartItems);
      final result = await _checkoutRepository.validatePromoCode(
        code: code,
        orderAmount: summary.grandTotal,
      );
      if (!mounted || token != _promoValidationToken) return;
      setState(() {
        _promoResult = result;
        _promoError = result.isValid
            ? null
            : result.message.isNotEmpty
            ? result.message
            : 'Invalid promo code';
        _isValidatingPromo = false;
      });
    } catch (error) {
      if (!mounted || token != _promoValidationToken) return;
      setState(() {
        _promoResult = PromoValidationResult.invalid();
        _promoError = ApexResponseHelper.messageForContext(
          'CheckPromoCode',
          error.toString(),
        );
        _isValidatingPromo = false;
      });
    }
  }

  List<PaymentMethodModel> _paymentMethods(BuildContext context) {
    return _paymentMethodOptions
        .map(
          (option) => PaymentMethodModel(
            id: option.minorCode,
            label: option.label,
            icon: _paymentMethodIcon(option),
          ),
        )
        .toList(growable: false);
  }

  PaymentMethodModel? _selectedPaymentMethod(BuildContext context) {
    final selectedId = _selectedPaymentMethodId;
    if (selectedId == null) return null;
    for (final method in _paymentMethods(context)) {
      if (method.id == selectedId) {
        return method;
      }
    }
    return null;
  }

  Future<void> _loadPaymentMethods({bool forceRefresh = false}) async {
    if (!mounted) return;

    setState(() {
      _isLoadingPaymentMethods = true;
      _paymentMethodLoadError = null;
    });

    try {
      final options = await _codesRepository.getCodes(
        majorCode: GetCodeOptionModel.paymentMethodMajorCode,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _paymentMethodOptions = options;
        if (_selectedPaymentMethodId != null &&
            !_paymentMethodOptions.any(
              (option) => option.minorCode == _selectedPaymentMethodId,
            )) {
          _selectedPaymentMethodId = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _paymentMethodLoadError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPaymentMethods = false;
        });
      }
    }
  }

  IconData _paymentMethodIcon(GetCodeOptionModel option) {
    switch (option.minorCode) {
      case 1:
        return Icons.payments_outlined;
      case 2:
        return Icons.qr_code_scanner_outlined;
      case 3:
        return Icons.credit_card_outlined;
      case 4:
        return Icons.account_balance_outlined;
      case 5:
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  Future<void> _loadUserAddresses({bool forceRefresh = false}) async {
    if (!mounted) return;

    setState(() {
      _isLoadingAddresses = true;
      _authError = null;
      _addressError = null;
    });

    try {
      final authState = context.read<AuthState>();
      await authState.ensureInitialized();
      final username = authState.user?.username.trim() ?? '';

      if (username.isEmpty) {
        setState(() {
          _authError = 'Please log in to continue with checkout.';
          _isLoadingAddresses = false;
        });
        return;
      }

      _addressController.username = username;
      await _addressController.loadAddresses(forceRefresh: forceRefresh);

      final controllerError = _addressController.error.value.trim();
      if (controllerError.isNotEmpty && _addressController.addresses.isEmpty) {
        setState(() {
          _addressError = controllerError;
        });
        return;
      }

      final selectedAddressId = _addressController.selectedAddressId.value;
      final defaultAddress = _addressController.getDefaultAddress();
      final matchedAddress = selectedAddressId != null
          ? _addressController.getAddressById(selectedAddressId)
          : defaultAddress;

      setState(() {
        _selectedAddress = matchedAddress;
        _addressController.selectedAddressId.value = matchedAddress?.addressId;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddresses = false;
        });
      }
    }
  }

  Future<void> _openAddressSelection() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressSelectionBottomSheet(
        savedAddresses: _addressController.addresses.toList(),
        selectedAddressId:
            _selectedAddress?.addressId ??
            _addressController.selectedAddressId.value,
        onAddressSelected: (address) {
          setState(() {
            _selectedAddress = address;
            _addressController.selectedAddressId.value = address.addressId;
            _addressError = null;
          });
        },
        onAddNewAddress: () async {
          Navigator.of(context).pop();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressesPage()),
          );
          await _loadUserAddresses(forceRefresh: true);
        },
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_isSubmitting) return;

    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!mounted) return;

    final username = authState.user?.username.trim();
    final addressId = _selectedAddress?.addressId;
    final paymentMethodId = _selectedPaymentMethodId;

    setState(() {
      _authError = (username == null || username.isEmpty)
          ? 'Please log in to continue.'
          : null;
      _addressError = addressId == null
          ? 'Please select a delivery address.'
          : null;
      _paymentMethodError = paymentMethodId == null
          ? 'Please select a payment method.'
          : null;
    });

    if (_authError != null ||
        _addressError != null ||
        _paymentMethodError != null) {
      return;
    }

    if (widget.cartItems.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'Your cart_tab is empty.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _checkoutRepository.placeOrder(
        CheckoutRequestModel(
          username: username!,
          shippingAddress: addressId!,
          paymentMethod: paymentMethodId!,
          promoCode: _promoResult?.isValid == true
              ? _promoController.text.trim().toUpperCase()
              : null,
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OrderConfirmationScreen(receipt: response, total: _totalPrice),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: ApexResponseHelper.messageForContext(
          'PlaceOrder',
          error.toString(),
        ),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _refreshCheckoutData() async {
    await Future.wait([
      _loadUserAddresses(forceRefresh: true),
      _loadPaymentMethods(forceRefresh: true),
    ]);
    final promoCode = _promoController.text.trim();
    if (promoCode.isNotEmpty) {
      final token = ++_promoValidationToken;
      await _validatePromoCode(code: promoCode, token: token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCheckoutData,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.insetsMd,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_authError != null) ...[
                      Text(
                        _authError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    Text(
                      l10n.checkoutOrderSummary,
                      style: AppTextStyles.headingMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (widget.cartItems.isEmpty)
                      Text(
                        l10n.cartEmptyMessage,
                        style: AppTextStyles.bodyMedium,
                      )
                    else
                      ...widget.cartItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _OrderSummaryRow(item: item),
                        ),
                      ),
                    const Divider(height: AppSpacing.xl),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.checkoutDeliveryAddress,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: _isLoadingAddresses ? null : _openAddressSelection,
                      child: Container(
                        padding: AppSpacing.insetsMd,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedAddress != null
                                ? AppColors.primary
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          color: _selectedAddress != null
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : Colors.transparent,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: _selectedAddress != null
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _isLoadingAddresses
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppSpacing.sm,
                                      ),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedAddress?.label ??
                                              'Select delivery address',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: _selectedAddress != null
                                                    ? null
                                                    : Colors.grey[600],
                                              ),
                                        ),
                                        if (_selectedAddress != null) ...[
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            _selectedAddress!.streetAddress,
                                            style: AppTextStyles.bodySmall,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            [
                                                  _selectedAddress!.city,
                                                  _selectedAddress!.country,
                                                ]
                                                .where(
                                                  (value) =>
                                                      value.trim().isNotEmpty,
                                                )
                                                .join(', '),
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ],
                                      ],
                                    ),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                    if (_addressError != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _addressError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // --- NEW PROMO CODE SECTION (Container Design) ---
                    Text(
                      'Promo Code (Optional)',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: AppSpacing.insetsMd,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _promoError != null
                              ? AppColors.error
                              : _promoResult?.isValid == true
                              ? AppColors.success
                              : AppColors.neutral300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 20,
                            color: _promoResult?.isValid == true
                                ? AppColors.success
                                : AppColors.neutral500,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              textCapitalization: TextCapitalization.characters,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ENTER CODE', // Capital hint
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey[400],
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_isValidatingPromo)
                            const SizedBox(
                              width: AppSpacing.iconMd,
                              height: AppSpacing.iconMd,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (_promoResult?.isValid == true)
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                            )
                          else if (_promoError != null)
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                            ),
                        ],
                      ),
                    ),
                    if (_promoError != null ||
                        (_promoResult != null && _promoResult!.isValid)) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _promoResult?.isValid == true
                            ? 'Promo applied'
                            : _promoError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _promoResult?.isValid == true
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      l10n.checkoutPaymentMethod,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_isLoadingPaymentMethods)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: LinearProgressIndicator(),
                      ),
                    if (_paymentMethodLoadError != null &&
                        _paymentMethodOptions.isEmpty) ...[
                      Text(
                        _paymentMethodLoadError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () =>
                              _loadPaymentMethods(forceRefresh: true),
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                    ..._paymentMethodOptions.map((option) {
                      final method = PaymentMethodModel(
                        id: option.minorCode,
                        label: option.label,
                        icon: _paymentMethodIcon(option),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethodId = method.id;
                              _paymentMethodError = null;
                            });
                          },
                          child: Container(
                            padding: AppSpacing.insetsMd,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: _selectedPaymentMethodId == method.id
                                    ? AppColors.primary
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(method.icon, color: AppColors.primary),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    method.label,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                                Radio<int>(
                                  value: method.id,
                                  groupValue: _selectedPaymentMethodId,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMethodId = value;
                                      _paymentMethodError = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_paymentMethodError != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _paymentMethodError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    _CheckoutTotalsSection(
                      summary: _checkoutSummary,
                      totalLabel: l10n.checkoutTotal,
                    ),
                    if (_selectedPaymentMethod(context) != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Selected payment: ${_selectedPaymentMethod(context)!.label}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      label: 'Place Order',
                      leading: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onPressed: _isSubmitting ? null : _placeOrder,
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

class _OrderSummaryRow extends StatelessWidget {
  const _OrderSummaryRow({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: AppTextStyles.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${AppLocalizations.of(context).checkoutQuantity(item.bookedQty)} • ${item.displayColor} • ${item.displaySize}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '\$${item.total.toStringAsFixed(2)}',
          style: AppTextStyles.bodyLarge,
        ),
      ],
    );
  }
}

class _CheckoutTotalsSection extends StatelessWidget {
  const _CheckoutTotalsSection({
    required this.summary,
    required this.totalLabel,
  });

  final CheckoutSummaryModel summary;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AmountRow(label: 'Subtotal', value: summary.subtotal),
        const SizedBox(height: AppSpacing.sm),
        _AmountRow(
          label: 'Discount',
          value: summary.totalDiscount,
          valueColor: AppColors.error,
          isDiscount: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        _AmountRow(label: 'Tax', value: summary.tax),
        const Divider(height: AppSpacing.xl),
        _AmountRow(label: totalLabel, value: summary.grandTotal, isTotal: true),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isDiscount = false,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final Color? valueColor;
  final bool isDiscount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? AppTextStyles.titleMedium
        : AppTextStyles.bodyMedium;
    final valueStyle = isTotal
        ? AppTextStyles.priceMedium
        : AppTextStyles.bodyMedium;
    final formattedValue = '\$${value.toStringAsFixed(2)}';

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(
          isDiscount && value > 0 ? '-$formattedValue' : formattedValue,
          style: valueStyle.copyWith(
            color: valueColor,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
