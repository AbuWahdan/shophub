import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/models/cart_item_model.dart';
import '../../../../controllers/address_controller.dart';
import '../../../../controllers/credit_card_controller.dart';
import '../../../../models/payment_method_model.dart';
import '../../../core/utils/localization_ar_en/localized_text_extensions.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/addresses/address_model.dart';
import '../../../../models/get_code_option_model.dart';
import '../../../models/checkout/checkout_request_model.dart';
import '../../../models/checkout/checkout_summary_model.dart';
import '../../../models/credit_card_model.dart';
import '../../../core/state/auth_state.dart';
import '../../../repositories/checkout_repository.dart';
import '../../../repositories/codes_repository.dart';
import '../../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../profile/addresses/widgets/address_selection_bottom_sheet.dart';
import '../../profile/addresses/addresses_page.dart';
import 'cards/add_card_page_in_checkout.dart';
import 'cards/widgets/card_selector_bottom_sheet.dart';
import 'widgets/checkout_items_list.dart';
import 'widgets/checkout_tokens.dart';
import 'widgets/delivery_address_card.dart';
import 'widgets/order_summary_card.dart';
import 'widgets/payment_method_card.dart';
import 'widgets/place_order_bar.dart';
import 'widgets/promo_code_input.dart';
import 'order_summary_page.dart';

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

  bool _isLoadingAddresses = false;
  bool _isLoadingPaymentMethods = false;
  AddressModel? _selectedAddress;
  CreditCardModel? _selectedCard;
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

  CheckoutSummaryModel get _checkoutSummary {
    final base = CheckoutSummaryModel.fromCartItems(widget.cartItems);

    double promoDiscount = 0;

    if (_promoResult?.isValid == true) {
      final result = _promoResult!;
      final orderAmount = base.taxableAmount + base.tax;

      if (result.discountType == 'PERCENT') {
        promoDiscount = (orderAmount * result.discountValue) / 100;

        // apply max cap
        if (result.maxDiscount > 0 && promoDiscount > result.maxDiscount) {
          promoDiscount = result.maxDiscount;
        }
      } else {
        promoDiscount = result.discountValue;
      }
    }

    return CheckoutSummaryModel(
      subtotal: base.subtotal,
      itemDiscount: base.itemDiscount,
      tax: base.tax,
      promoDiscount: promoDiscount,
    );
  }

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

    _promoDebounce = Timer(const Duration(milliseconds: 600), () {
      _validatePromoCode(code: code, token: token);
    });
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
            : (result.message.isNotEmpty
                  ? result.message
                  : AppLocalizations.of(context).invalidPromoCode);
        _isValidatingPromo = false;
      });
    } catch (error) {
      if (!mounted || token != _promoValidationToken) return;

      setState(() {
        _promoResult = PromoValidationResult.invalid();
        _promoError = error.toString();
        _isValidatingPromo = false;
      });
    }
  }

  List<PaymentMethodModel> _paymentMethods(BuildContext context) {
    return _paymentMethodOptions
        .map(
          (option) => PaymentMethodModel(
            id: option.minorCode,
            label: option.localizedTitle(context),
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
          _authError = AppLocalizations.of(context).checkoutLoginRequired;
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
      backgroundColor: AppColors.transparent,
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
    final l10n = AppLocalizations.of(context);

    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!mounted) return;

    final username = authState.user?.username.trim();
    final addressId = _selectedAddress?.addressId;
    final paymentMethodId = _selectedPaymentMethodId;

    setState(() {
      _authError = (username == null || username.isEmpty)
          ? l10n.checkoutLoginRequiredShort
          : null;
      _addressError = addressId == null ? l10n.checkoutSelectAddress : null;
      _paymentMethodError = paymentMethodId == null
          ? l10n.checkoutSelectPayment
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
        message: l10n.checkoutCartEmptyWarning,
        type: AppSnackBarType.warning,
      );
      return;
    }
    final enteredPromo = _promoController.text.trim();

    if (enteredPromo.isNotEmpty &&
        (_promoResult == null || _promoResult!.isValid != true)) {
      CustomSnackBar.show(
        context,
        message: l10n.invalidPromoCode,
        type: AppSnackBarType.error,
      );
      return;
    }
    final paymentMethod = _selectedPaymentMethod(context)!;
    CreditCardModel? selectedCard = _selectedCard;
    final requiresCard = _isCreditCardPayment(paymentMethod);
    if (requiresCard) {
      selectedCard = await _ensureCreditCardSelected(username!);
      if (!mounted || selectedCard == null) return;
      setState(() => _selectedCard = selectedCard);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSummaryPage(
          items: widget.cartItems,
          address: _selectedAddress!,
          paymentMethod: paymentMethod,
          summary: _checkoutSummary,
          promoCode: _promoResult?.isValid == true
              ? _promoController.text.trim().toUpperCase()
              : null,
          selectedCard: selectedCard,
          requiresCard: requiresCard,
          onConfirm: () => _submitConfirmedOrder(
            username: username!,
            addressId: addressId!,
            paymentMethodId: paymentMethodId!,
            cardId: selectedCard?.cardId,
          ),
        ),
      ),
    );
  }

  bool _isCreditCardPayment(PaymentMethodModel method) {
    return method.id == 3 ||
        method.label.trim().toLowerCase() ==
            AppLocalizations.of(context).checkoutPaymentCard.toLowerCase();
  }

  Future<CreditCardModel?> _ensureCreditCardSelected(String username) async {
    final cardsController = context.read<CreditCardController>();
    if (!cardsController.hasLoaded) {
      await cardsController.fetchCards(username);
    }
    if (!mounted) return null;

    var cards = cardsController.cards;
    if (cards.isEmpty) {
      final added = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AddCardPage()),
      );
      if (added != true || !mounted) return null;
      await cardsController.fetchCards(username);
      cards = cardsController.cards;
      if (cards.isEmpty) return null;
    }

    while (mounted) {
      if (!mounted) return null;
      final result = await showModalBottomSheet<CardSelectorResult>(
        context: context,
        isScrollControlled: true,
        builder: (_) => CardSelectorBottomSheet(
          cards: cards,
          selectedCardId: _selectedCard?.cardId,
        ),
      );
      if (!mounted || result == null) return null;
      if (result.addNew) {
        final added = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const AddCardPage()),
        );
        if (added != true || !mounted) return null;
        await cardsController.fetchCards(username);
        cards = cardsController.cards;
        continue;
      }
      return result.card;
    }
    return null;
  }

  Future<Map<String, dynamic>> _submitConfirmedOrder({
    required String username,
    required int addressId,
    required int paymentMethodId,
    int? cardId,
  }) async {
    final response = await _checkoutRepository.placeOrder(
      CheckoutRequestModel(
        username: username,
        shippingAddress: addressId,
        paymentMethod: paymentMethodId,
        promoCode: _promoResult?.isValid == true
            ? _promoController.text.trim().toUpperCase()
            : null,
        cardId: cardId,
      ),
    );

    return response;
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
    final paymentMethods = _paymentMethods(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      bottomNavigationBar: PlaceOrderBar(
        label: l10n.placeOrderButton,
        onPressed: _placeOrder,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCheckoutData,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                CheckoutTokens.bottomBarReserve,
              ),
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
                      l10n.orderItemsSection,
                      style: AppTextStyles.headingMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (widget.cartItems.isEmpty)
                      Text(
                        l10n.cartEmptyMessage,
                        style: AppTextStyles.bodyMedium,
                      )
                    else
                      CheckoutItemsList(items: widget.cartItems),
                    const SizedBox(height: AppSpacing.xl),
                    DeliveryAddressCard(
                      title: l10n.deliveryAddressTitle,
                      selectLabel: l10n.checkoutSelectDeliveryAddress,
                      estimateText: l10n.deliveryEstimateLabel,
                      address: _selectedAddress,
                      isLoading: _isLoadingAddresses,
                      errorText: _addressError,
                      onTap: _isLoadingAddresses ? null : _openAddressSelection,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PromoCodeInput(
                      controller: _promoController,
                      hintText: l10n.promoCodeHint,
                      isLoading: _isValidatingPromo,
                      isApplied: _promoResult?.isValid == true,
                      errorText: _promoError,
                      appliedText: l10n.promoApplied,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PaymentMethodCard(
                      title: l10n.paymentMethodTitle,
                      methods: paymentMethods,
                      selectedMethodId: _selectedPaymentMethodId,
                      selectedCardNumber: _selectedCard?.maskedNumber,
                      isLoading: _isLoadingPaymentMethods,
                      errorText: _paymentMethodLoadError,
                      retryLabel: l10n.retry,
                      onRetry: () => _loadPaymentMethods(forceRefresh: true),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethodId = value;
                          _paymentMethodError = null;
                        });
                      },
                    ),
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
                    OrderSummaryCard(
                      title: l10n.orderSummaryTitle,
                      summary: _checkoutSummary,
                      subtotalLabel: l10n.subtotalLabel,
                      discountLabel: l10n.discountLabel,
                      shippingLabel: l10n.shippingLabel,
                      taxLabel: l10n.taxLabel,
                      totalLabel: l10n.totalLabel,
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
