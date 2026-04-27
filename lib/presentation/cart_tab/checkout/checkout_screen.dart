import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/models/cart_api.dart';
import '../../../../controllers/address_controller.dart';
import '../../../../data/repositories/codes_repository.dart';
import '../../../../data/repositories/checkout_repository.dart';
import '../../../../core/utils/apex_response_helper.dart';
import '../../../../models/payment_method_model.dart';
import '../../../../models/address_model.dart';
import '../../../../models/api_code_option.dart';
import '../../../../models/checkout_request.dart';
import '../../../l10n/l10n.dart';
import '../../../core/app/app_theme.dart';
import '../../../src/shared/widgets/app_button.dart';
import '../../../src/shared/widgets/app_snackbar.dart';
import '../../../src/state/auth_state.dart';
import '../../profile/addresses/address_selection_bottom_sheet.dart';
import '../../profile/addresses/addresses_page.dart';
import '../../profile/orders/order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cartItems});

  final List<ApiCartItem> cartItems;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final AddressController _addressController;
  late final CheckoutRepository _checkoutRepository;
  late final CodesRepository _codesRepository;

  bool _isSubmitting = false;
  bool _isLoadingAddresses = false;
  bool _isLoadingPaymentMethods = false;
  AddressModel? _selectedAddress;
  int? _selectedPaymentMethodId;
  String? _addressError;
  String? _paymentMethodError;
  String? _paymentMethodLoadError;
  String? _authError;
  List<ApiCodeOption> _paymentMethodOptions = const <ApiCodeOption>[];

  @override
  void initState() {
    super.initState();
    _addressController = Get.find<AddressController>();
    _checkoutRepository = Get.find<CheckoutRepository>();
    _codesRepository = Get.find<CodesRepository>();
    _loadUserAddresses();
    _loadPaymentMethods();
  }

  double get _totalPrice {
    return widget.cartItems.fold(0, (sum, item) => sum + item.total);
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
        majorCode: ApiCodeOption.paymentMethodMajorCode,
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

  IconData _paymentMethodIcon(ApiCodeOption option) {
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
      AppSnackBar.show(
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
        CheckoutRequest(
          username: username!,
          shippingAddress: addressId!,
          paymentMethod: paymentMethodId!,
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
      AppSnackBar.show(
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
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
                Text(l10n.cartEmptyMessage, style: AppTextStyles.bodyMedium)
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
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedAddress?.label ??
                                        'Select delivery address',
                                    style: AppTextStyles.bodyMedium.copyWith(
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
                                            (value) => value.trim().isNotEmpty,
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
              Text(l10n.checkoutPaymentMethod, style: AppTextStyles.titleSmall),
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
                    onPressed: () => _loadPaymentMethods(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ),
              ],
              ..._paymentMethods(context).map(
                (method) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethodId = method.id;
                        _paymentMethodError = null;
                      });
                    },
                    child: Container(
                      padding: AppSpacing.insetsMd,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
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
                ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.checkoutTotal, style: AppTextStyles.titleMedium),
                  Text(
                    '\$${_totalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.priceMedium,
                  ),
                ],
              ),
              if (_selectedPaymentMethod(context) != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Selected payment: ${_selectedPaymentMethod(context)!.label}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
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
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  const _OrderSummaryRow({required this.item});

  final ApiCartItem item;

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
                '${context.l10n.checkoutQuantity(item.itemQty)} • ${item.displayColor} • ${item.displaySize}',
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
