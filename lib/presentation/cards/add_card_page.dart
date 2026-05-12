import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/credit_card_controller.dart';
import '../../core/state/auth_state.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/credit_card_model.dart';
import '../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../widgets/custom_button/custom_button.dart';

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
      appBar: AppBar(title: Text(l10n.addCard)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: AppSpacing.insetsMd,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _cardholderController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: l10n.cardholderNameLabel,
                      ),
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? l10n.productRequiredField
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.cardNumberLabel,
                      ),
                      validator: (value) {
                        final digits = _digitsOnly(value ?? '');
                        return digits.length == AppSpacing.md.toInt()
                            ? null
                            : l10n.cardNumberInvalid;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.expiryMonthLabel,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _expiryMonth,
                            decoration: InputDecoration(
                              labelText: l10n.expiryMonthLabel,
                            ),
                            items:
                                List<int>.generate(
                                      AppSpacing.borderThick.toInt(),
                                      (index) => index + 1,
                                    )
                                    .map(
                                      (month) => DropdownMenuItem(
                                        value: month,
                                        child: Text(
                                          month.toString().padLeft(2, '0'),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) =>
                                setState(() => _expiryMonth = value),
                            validator: (value) => value == null
                                ? l10n.productRequiredField
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _expiryYear,
                            decoration: InputDecoration(
                              labelText: l10n.expiryYearLabel,
                            ),
                            items: years
                                .map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _expiryYear = value),
                            validator: (value) => value == null
                                ? l10n.productRequiredField
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.cardTypeLabel, style: AppTextStyles.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<String>(
                      segments: _cardTypes
                          .map(
                            (type) =>
                                ButtonSegment(value: type, label: Text(type)),
                          )
                          .toList(),
                      selected: {_cardType},
                      onSelectionChanged: (selection) =>
                          setState(() => _cardType = selection.first),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      value: _isDefault,
                      onChanged: (value) => setState(() => _isDefault = value),
                      title: Text(l10n.setAsDefaultLabel),
                      activeThumbColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      label: l10n.saveCard,
                      leading: _isSaving
                          ? const SizedBox(
                              width: AppSpacing.iconMd,
                              height: AppSpacing.iconMd,
                              child: CircularProgressIndicator(
                                strokeWidth:
                                    AppSpacing.xs *
                                    AppSpacing.xs /
                                    AppSpacing.borderThin,
                              ),
                            )
                          : null,
                      onPressed: _isSaving ? null : _submit,
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
