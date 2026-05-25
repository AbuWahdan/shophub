import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/credit_card_controller.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/credit_card_model.dart';
import '../../../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../../profile/settings/payment_methods/widgets/add_card_form.dart';
import '../../../profile/settings/payment_methods/widgets/card_preview_widget.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  static const List<String> _cardTypes = ['VISA', 'MASTERCARD', 'AMEX'];

  final _formKey = GlobalKey<FormState>();
  final _cardholderController = TextEditingController();
  final _numberController = TextEditingController();
  final _cvvController = TextEditingController();

  int? _expiryMonth;
  int? _expiryYear;
  String _cardType = _cardTypes.first;
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cardholderController.addListener(_uppercaseCardholder);
    _numberController.addListener(_detectCardType);
  }

  @override
  void dispose() {
    _cardholderController
      ..removeListener(_uppercaseCardholder)
      ..dispose();
    _numberController
      ..removeListener(_detectCardType)
      ..dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _uppercaseCardholder() {
    final text = _cardholderController.text;
    final upper = text.toUpperCase();
    if (text == upper) return;
    _cardholderController.value = _cardholderController.value.copyWith(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
      composing: TextRange.empty,
    );
  }

  void _detectCardType() {
    final digits = _digitsOnly(_numberController.text);
    final detected = _detectType(digits);
    if (detected != null && detected != _cardType) {
      setState(() => _cardType = detected);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || !_expiryIsValid()) {
      if (!_expiryIsValid()) {
        CustomSnackBar.show(
          context,
          message: l10n.cardExpiryInvalid,
          type: AppSnackBarType.error,
        );
      }
      return;
    }

    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!mounted) return;
    final username = authState.user?.username.trim() ?? '';
    if (username.isEmpty) {
      CustomSnackBar.show(
        context,
        message: l10n.checkoutLoginRequiredShort,
        type: AppSnackBarType.error,
      );
      return;
    }

    final digits = _digitsOnly(_numberController.text);
    final last4 = digits.substring(digits.length - AppSpacing.xs.toInt());
    final maskedNumber = CreditCardModel.formatMasked(
      '${digits.substring(0, AppSpacing.xs.toInt())}********$last4',
    );

    setState(() => _isSaving = true);
    final controller = context.read<CreditCardController>();
    await controller.addCard(
      AddCardRequest(
        username: username,
        // Replace with a real payment SDK token in production.
        cardToken: 'tok_$last4',
        maskedNumber: maskedNumber,
        cardType: _cardType,
        expiryMonth: _expiryMonth!,
        expiryYear: _expiryYear!,
        cardholderName: _cardholderController.text.trim(),
        isDefault: _isDefault,
      ),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    final error = controller.errorMessage?.trim();
    if (error != null && error.isNotEmpty) {
      CustomSnackBar.show(context, message: error, type: AppSnackBarType.error);
      return;
    }

    CustomSnackBar.show(
      context,
      message: l10n.cardAddedSuccess,
      type: AppSnackBarType.success,
    );
    Navigator.of(context).pop(true);
  }

  bool _expiryIsValid() {
    final month = _expiryMonth;
    final year = _expiryYear;
    if (month == null || year == null) return false;
    final now = DateTime.now();
    final nextMonth = month == 12
        ? DateTime(year + 1)
        : DateTime(year, month + 1);
    return now.isBefore(nextMonth);
  }

  String? _detectType(String digits) {
    if (digits.startsWith('4')) return 'VISA';
    if (digits.startsWith('34') || digits.startsWith('37')) return 'AMEX';
    if (digits.length >= 2) {
      final prefix = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (prefix >= 51 && prefix <= 55) return 'MASTERCARD';
    }
    if (digits.length >= AppSpacing.xs.toInt()) {
      final prefix =
          int.tryParse(digits.substring(0, AppSpacing.xs.toInt())) ?? 0;
      if (prefix >= 2221 && prefix <= 2720) return 'MASTERCARD';
    }
    return null;
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(
      AppSpacing.cardExpiryYearCount,
      (index) => currentYear + index,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addNewCardTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: AppSpacing.insetsMd,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _cardholderController,
                      _numberController,
                    ]),
                    builder: (context, _) {
                      final expiryText =
                          _expiryMonth == null || _expiryYear == null
                          ? l10n.cardPreviewExpiry
                          : '${_expiryMonth!.toString().padLeft(2, '0')}/$_expiryYear';
                      return CardPreviewWidget(
                        cardType: _cardType,
                        cardNumber: _numberController.text,
                        cardholderName: _cardholderController.text,
                        expiryText: expiryText,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: AddCardForm(
                      formKey: _formKey,
                      cardholderController: _cardholderController,
                      numberController: _numberController,
                      cvvController: _cvvController,
                      cardTypes: _cardTypes,
                      cardType: _cardType,
                      expiryMonth: _expiryMonth,
                      expiryYear: _expiryYear,
                      years: years,
                      isDefault: _isDefault,
                      isSaving: _isSaving,
                      addNewCardTitle: l10n.addNewCardTitle,
                      cardHolderNameLabel: l10n.cardHolderNameLabel,
                      cardNumberLabel: l10n.cardNumberLabel,
                      expiryMonthLabel: l10n.expiryMonthLabel,
                      expiryYearLabel: l10n.expiryYearLabel,
                      cardTypeLabel: l10n.cardTypeLabel,
                      cvvLabel: l10n.cvvLabel,
                      setAsDefaultLabel: l10n.setAsDefaultLabel,
                      savePaymentCardButton: l10n.savePaymentCardButton,
                      requiredMessage: l10n.productRequiredField,
                      cardNumberInvalidMessage: l10n.cardNumberInvalid,
                      onCardTypeChanged: (value) =>
                          setState(() => _cardType = value),
                      onExpiryMonthChanged: (value) =>
                          setState(() => _expiryMonth = value),
                      onExpiryYearChanged: (value) =>
                          setState(() => _expiryYear = value),
                      onDefaultChanged: (value) =>
                          setState(() => _isDefault = value),
                      onSubmit: _submit,
                      cardNumberInputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberInputFormatter(),
                      ],
                      digitsOnly: _digitsOnly,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > AppSpacing.md.toInt()
        ? digits.substring(0, AppSpacing.md.toInt())
        : digits;
    final buffer = StringBuffer();
    for (var index = 0; index < limited.length; index++) {
      if (index > 0 && index % AppSpacing.xs.toInt() == 0) {
        buffer.write(' ');
      }
      buffer.write(limited[index]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
