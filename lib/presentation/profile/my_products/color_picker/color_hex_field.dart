import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'color_picker_dialog.dart';
import 'color_utils.dart';

class ColorHexField extends StatefulWidget {
  const ColorHexField({
    required this.initialColor,
    required this.onColorChanged,
    this.label,
    super.key,
  });

  final String initialColor;
  final ValueChanged<String> onColorChanged;
  final String? label;

  @override
  State<ColorHexField> createState() => _ColorHexFieldState();
}

class _ColorHexFieldState extends State<ColorHexField> {
  late final String _controllerTag;
  late final _ColorHexFieldController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'color-hex-field-${identityHashCode(this)}';
    _controller = Get.put(
      _ColorHexFieldController(widget.initialColor, widget.onColorChanged),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<_ColorHexFieldController>(tag: _controllerTag)) {
      Get.delete<_ColorHexFieldController>(tag: _controllerTag);
    }
    super.dispose();
  }

  Future<void> _openPickerDialog() async {
    final selectedHex = await showDialog<String>(
      context: context,
      builder: (_) =>
          ColorPickerDialog(initialColor: _controller.currentHex.value),
    );
    if (!mounted || selectedHex == null) {
      return;
    }
    _controller.setHex(selectedHex);
  }

  @override
  Widget build(BuildContext context) {
    final fieldLabel = widget.label ?? AppLocalizations.of(context).productColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldLabel, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller.textController,
                onChanged: _controller.updateFromText,
                keyboardType: TextInputType.text,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  if (!isValidHex(value ?? '')) {
                    return AppLocalizations.of(context).colorPickerInvalidHex;
                  }
                  return null;
                },
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).colorPickerHexHint,
                  prefixText: '#',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: AppSpacing.insetsMd,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Obx(
                () => GestureDetector(
                  onTap: _openPickerDialog,
                  child: _ColorPreview(
                    color: _controller.previewColor.value,
                    hasValidColor: _controller.hasValidColor.value,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorHexFieldController extends GetxController {
  _ColorHexFieldController(this.initialColor, this.onColorChanged);

  final String initialColor;
  final ValueChanged<String> onColorChanged;

  final textController = TextEditingController();
  final currentHex = ''.obs;
  final previewColor = Rxn<Color>();
  final hasValidColor = false.obs;

  @override
  void onInit() {
    super.onInit();
    final normalized = _normalizeInput(initialColor);
    final initialHex = isValidHex(normalized) ? normalized : '';
    textController.text = initialHex;
    updateFromText(initialHex);
  }

  void updateFromText(String value) {
    final normalized = _normalizeInput(value);
    if (textController.text != normalized) {
      _setText(normalized);
    }

    currentHex.value = normalized;
    final parsedColor = hexToColor(normalized);
    previewColor.value = parsedColor;
    final isValid = parsedColor != null && normalized.length == 6;
    hasValidColor.value = isValid;

    if (isValid) {
      onColorChanged(colorToHex(parsedColor));
    }
  }

  void setHex(String value) {
    final normalized = _normalizeInput(value);
    _setText(normalized);
    updateFromText(normalized);
  }

  void _setText(String value) {
    textController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  String _normalizeInput(String value) {
    return value.trim().replaceFirst('#', '').toUpperCase();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}

class _ColorPreview extends StatelessWidget {
  const _ColorPreview({required this.color, required this.hasValidColor});

  final Color? color;
  final bool hasValidColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          borderColor: Theme.of(context).dividerColor,
          paintDashedBorder: !hasValidColor,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasValidColor ? color : AppColors.black,
            border: hasValidColor
                ? Border.all(color: Theme.of(context).dividerColor)
                : null,
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.borderColor,
    required this.paintDashedBorder,
  });

  final Color borderColor;
  final bool paintDashedBorder;

  @override
  void paint(Canvas canvas, Size size) {
    if (!paintDashedBorder) {
      return;
    }

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final radius = size.width / 2;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    var startAngle = 0.0;
    final circumference = 2 * 3.141592653589793 * radius;
    final dashAngle = (dashWidth / circumference) * 2 * 3.141592653589793;
    final spaceAngle = (dashSpace / circumference) * 2 * 3.141592653589793;

    while (startAngle < 2 * 3.141592653589793) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius - 1,
        ),
        startAngle,
        dashAngle,
        false,
        paint,
      );
      startAngle += dashAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return borderColor != oldDelegate.borderColor ||
        paintDashedBorder != oldDelegate.paintDashedBorder;
  }
}
