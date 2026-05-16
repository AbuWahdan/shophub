import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' hide colorToHex;
import 'package:get/get.dart';
import '../../../../design/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/custom_button/custom_button.dart';
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

                          Column(
                            children: [
                              TextField(
                                controller: _controller.hexController,
                                onChanged: _controller.updateFromHex,
                                keyboardType: TextInputType.text,
                                maxLength: 6,
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.allow(
                                //     RegExp(r'[0-9a-fA-F]'),
                                //   ),
                                //   LengthLimitingTextInputFormatter(6),
                                // ],
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,\s]')),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'HEX',
                                  prefixText: '#',
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              TextField(
                                controller: _controller.rgbController,
                                onChanged: _controller.updateFromRgb,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'RGB',
                                  hintText: '255, 255, 255',
                                ),
                              ),
                            ],
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
                        child: CustomButton(
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
  final rgbController = TextEditingController();
  final selectedColor = Colors.white.obs;
  final isSelectionEnabled = false.obs;
  final shouldShowError = false.obs;

  String get selectedHex => colorToHex(selectedColor.value);


  String get rgbValue {
    final color = selectedColor.value;

    return 'RGB(${color.red}, ${color.green}, ${color.blue})';
  }

  String get hsvValue {
    final hsv = HSVColor.fromColor(selectedColor.value);

    return 'HSV('
        '${hsv.hue.toStringAsFixed(0)}, '
        '${(hsv.saturation * 100).toStringAsFixed(0)}%, '
        '${(hsv.value * 100).toStringAsFixed(0)}%'
        ')';
  }


  @override
  void onInit() {
    super.onInit();

    final normalized = _normalizeInput(initialColor);

    final initialHex = isValidHex(normalized)
        ? normalized
        : '000000';

    final color = hexToColor(initialHex)!;

    _updateColor(color);
  }

  void updateFromPicker(Color color) {
    _updateColor(color);
  }
  void updateFromHex(String value) {
    final normalized = _normalizeInput(value);

    hexController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );

    if (!isValidHex(normalized)) {
      return;
    }

    final color = hexToColor(normalized);

    if (color == null) {
      return;
    }

    selectedColor.value = color;

    final rgb = colorToRgb(color);

    rgbController.value = TextEditingValue(
      text: rgb,
      selection: TextSelection.collapsed(offset: rgb.length),
    );

    isSelectionEnabled.value = true;
  }

  void updateFromRgb(String value) {
    rgbController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );

    final color = rgbToColor(value);

    if (color == null) {
      return;
    }

    selectedColor.value = color;

    final hex = colorToHex(color);

    hexController.value = TextEditingValue(
      text: hex,
      selection: TextSelection.collapsed(offset: hex.length),
    );

    isSelectionEnabled.value = true;
  }

  void _updateColor(Color color) {
    selectedColor.value = color;

    final hex = colorToHex(color);

    hexController.value = TextEditingValue(
      text: hex,
      selection: TextSelection.collapsed(offset: hex.length),
    );

    final rgb = colorToRgb(color);

    rgbController.value = TextEditingValue(
      text: rgb,
      selection: TextSelection.collapsed(offset: rgb.length),
    );

    isSelectionEnabled.value = true;
  }
  // void updateFromText(String value) {
  //   final normalized = _normalizeInput(value);
  //   if (hexController.text != normalized) {
  //     _setHex(normalized);
  //   }
  //
  //   if (!isValidHex(normalized)) {
  //     isSelectionEnabled.value = false;
  //     shouldShowError.value = normalized.isNotEmpty;
  //     return;
  //   }
  //
  //   final parsedColor = hexToColor(normalized);
  //   if (parsedColor == null) {
  //     isSelectionEnabled.value = false;
  //     shouldShowError.value = true;
  //     return;
  //   }
  //
  //   selectedColor.value = parsedColor;
  //   isSelectionEnabled.value = true;
  //   shouldShowError.value = false;
  // }

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
    rgbController.dispose();
    super.onClose();
  }
}
