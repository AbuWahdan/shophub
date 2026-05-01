import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' hide colorToHex;
import 'package:get/get.dart';
import '../../../../design/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/widgets/app_button.dart';
import 'color_utils.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({required this.initialColor, super.key});

  final String initialColor;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late final String _controllerTag;
  late final _ColorPickerDialogController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'color-picker-dialog-${identityHashCode(this)}';
    _controller = Get.put(
      _ColorPickerDialogController(widget.initialColor),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<_ColorPickerDialogController>(tag: _controllerTag)) {
      Get.delete<_ColorPickerDialogController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.productColor)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ColorPicker(
                              pickerColor: _controller.selectedColor.value,
                              onColorChanged: _controller.updateFromPicker,
                              enableAlpha: false,
                              displayThumbColor: true,
                              paletteType: PaletteType.hsvWithHue,
                              pickerAreaHeightPercent: 0.7,
                              labelTypes: const [],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          TextField(
                            controller: _controller.hexController,
                            onChanged: _controller.updateFromText,
                            keyboardType: TextInputType.text,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9a-fA-F]'),
                              ),
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.productColor,
                              hintText: l10n.colorPickerHexHint,
                              prefixText: '#',
                              errorText: _controller.shouldShowError.value
                                  ? l10n.colorPickerInvalidHex
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                              AppSpacing.buttonMd,
                            ),
                          ),
                          child: Text(l10n.commonCancel),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          label: l10n.commonSelect,
                          onPressed: _controller.isSelectionEnabled.value
                              ? () {
                                  Navigator.pop(
                                    context,
                                    _controller.selectedHex,
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
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

class _ColorPickerDialogController extends GetxController {
  _ColorPickerDialogController(this.initialColor);

  final String initialColor;

  final hexController = TextEditingController();
  final selectedColor = Colors.white.obs;
  final isSelectionEnabled = false.obs;
  final shouldShowError = false.obs;

  String get selectedHex => colorToHex(selectedColor.value);

  @override
  void onInit() {
    super.onInit();
    final normalized = _normalizeInput(initialColor);
    if (isValidHex(normalized)) {
      final color = hexToColor(normalized);
      if (color != null) {
        selectedColor.value = color;
        _setHex(normalized);
        isSelectionEnabled.value = true;
        shouldShowError.value = false;
        return;
      }
    }

    _setHex('');
    isSelectionEnabled.value = false;
    shouldShowError.value = false;
  }

  void updateFromPicker(Color color) {
    selectedColor.value = color;
    isSelectionEnabled.value = true;
    shouldShowError.value = false;
    _setHex(colorToHex(color));
  }

  void updateFromText(String value) {
    final normalized = _normalizeInput(value);
    if (hexController.text != normalized) {
      _setHex(normalized);
    }

    if (!isValidHex(normalized)) {
      isSelectionEnabled.value = false;
      shouldShowError.value = normalized.isNotEmpty;
      return;
    }

    final parsedColor = hexToColor(normalized);
    if (parsedColor == null) {
      isSelectionEnabled.value = false;
      shouldShowError.value = true;
      return;
    }

    selectedColor.value = parsedColor;
    isSelectionEnabled.value = true;
    shouldShowError.value = false;
  }

  void _setHex(String value) {
    hexController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _normalizeInput(String value) {
    return value.trim().replaceFirst('#', '').toUpperCase();
  }

  @override
  void onClose() {
    hexController.dispose();
    super.onClose();
  }
}
