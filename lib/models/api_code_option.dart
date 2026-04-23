class ApiCodeOption {
  const ApiCodeOption({
    required this.majorCode,
    required this.minorCode,
    required this.label,
    this.labelAr = '',
  });

  // ── Major code constants ──────────────────────────────────────────────────
  static const int deliveryStatusMajorCode = 1;
  static const int genderMajorCode         = 2;
  static const int paymentMethodMajorCode  = 3;

  final int    majorCode;
  final int    minorCode;
  final String label;    // EN_NAME
  final String labelAr;  // AR_NAME — kept for future localisation

  // minorCode 0 is the major-code header row — never show it in a list.
  bool get isRenderable => minorCode > 0 && label.trim().isNotEmpty;

  factory ApiCodeOption.fromJson(Map<String, dynamic> json) {
    return ApiCodeOption(
      majorCode: _asInt(
        _pick(json, const ['MAJOR_CODE', 'major_code', 'major', 'MAJOR']),
      ),
      minorCode: _asInt(
        _pick(json, const ['MINOR_CODE', 'minor_code', 'minor', 'MINOR']),
      ),
      // FIX: EN_NAME is the actual key the backend returns.
      // The original list only had generic keys (name, label, meaning …)
      // so label was always empty and isRenderable was always false.
      label: _asString(json, const [
        'EN_NAME',       // ← what the backend actually sends
        'en_name',
        'minor_name',    'MINOR_NAME',
        'minor_desc',    'MINOR_DESC',
        'label',         'LABEL',
        'name',          'NAME',
        'code_name',     'CODE_NAME',
        'meaning',       'MEANING',
        'description',   'DESCRIPTION',
        'display_value', 'DISPLAY_VALUE',
      ]),
      labelAr: _asString(json, const [
        'AR_NAME', 'ar_name',
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  static String _asString(Map<String, dynamic> json, List<String> keys) {
    final value = _pick(json, keys);
    return (value ?? '').toString().trim();
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}