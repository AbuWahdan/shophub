import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';
import 'card_number_field.dart';
import 'card_type_selector.dart';
import 'default_checkbox.dart';
import 'expiry_cvv_row.dart';
import 'holder_name_field.dart';
import 'save_card_button.dart';

class AddCardForm extends StatelessWidget {
  const AddCardForm({
    super.key,
    required this.formKey,
    required this.cardholderController,
    required this.numberController,
    required this.cvvController,
    required this.cardTypes,
    required this.cardType,
    required this.expiryMonth,
    required this.expiryYear,
    required this.years,
    required this.isDefault,
    required this.isSaving,
    required this.addNewCardTitle,
    required this.cardHolderNameLabel,
    required this.cardNumberLabel,
    required this.expiryMonthLabel,
    required this.expiryYearLabel,
    required this.cardTypeLabel,
    required this.cvvLabel,
    required this.setAsDefaultLabel,
    required this.savePaymentCardButton,
    required this.requiredMessage,
    required this.cardNumberInvalidMessage,
    required this.onCardTypeChanged,
    required this.onExpiryMonthChanged,
    required this.onExpiryYearChanged,
    required this.onDefaultChanged,
    required this.onSubmit,
    required this.cardNumberInputFormatters,
    required this.digitsOnly,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController cardholderController;
  final TextEditingController numberController;
  final TextEditingController cvvController;
  final List<String> cardTypes;
  final String cardType;
  final int? expiryMonth;
  final int? expiryYear;
  final List<int> years;
  final bool isDefault;
  final bool isSaving;
  final String addNewCardTitle;
  final String cardHolderNameLabel;
  final String cardNumberLabel;
  final String expiryMonthLabel;
  final String expiryYearLabel;
  final String cardTypeLabel;
  final String cvvLabel;
  final String setAsDefaultLabel;
  final String savePaymentCardButton;
  final String requiredMessage;
  final String cardNumberInvalidMessage;
  final ValueChanged<String> onCardTypeChanged;
  final ValueChanged<int?> onExpiryMonthChanged;
  final ValueChanged<int?> onExpiryYearChanged;
  final ValueChanged<bool> onDefaultChanged;
  final VoidCallback onSubmit;
  final List<TextInputFormatter> cardNumberInputFormatters;
  final String Function(String) digitsOnly;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(addNewCardTitle, style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.md),
          HolderNameField(
            controller: cardholderController,
            label: cardHolderNameLabel,
            validator: (value) =>
                (value ?? '').trim().isEmpty ? requiredMessage : null,
          ),
          const SizedBox(height: AppSpacing.md),
          CardTypeSelector(
            label: cardTypeLabel,
            types: cardTypes,
            selectedType: cardType,
            onChanged: onCardTypeChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          CardNumberField(
            controller: numberController,
            label: cardNumberLabel,
            inputFormatters: cardNumberInputFormatters,
            validator: (value) {
              final digits = digitsOnly(value ?? '');
              return digits.length == AppSpacing.md.toInt()
                  ? null
                  : cardNumberInvalidMessage;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          ExpiryCvvRow(
            monthDropdown: _DropdownField<int>(
              value: expiryMonth,
              label: expiryMonthLabel,
              items: List<int>.generate(
                (AppSpacing.xxl / AppSpacing.xs).toInt(),
                (index) => index + 1,
              ),
              onChanged: onExpiryMonthChanged,
              itemLabel: (month) => month.toString().padLeft(2, '0'),
              requiredMessage: requiredMessage,
            ),
            yearDropdown: _DropdownField<int>(
              value: expiryYear,
              label: expiryYearLabel,
              items: years,
              onChanged: onExpiryYearChanged,
              itemLabel: (year) => year.toString(),
              requiredMessage: requiredMessage,
            ),
            cvvLabel: cvvLabel,
            cvvController: cvvController,
          ),
          const SizedBox(height: AppSpacing.md),
          DefaultCheckbox(
            value: isDefault,
            label: setAsDefaultLabel,
            onChanged: onDefaultChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          SaveCardButton(
            label: savePaymentCardButton,
            isSaving: isSaving,
            onPressed: isSaving ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    required this.requiredMessage,
  });

  final T? value;
  final String label;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;
  final String requiredMessage;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? requiredMessage : null,
    );
  }
}
