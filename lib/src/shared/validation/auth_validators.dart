class AuthValidators {
  const AuthValidators._();

  static String? email(String? value, {required String emptyMessage, required String invalidMessage}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return emptyMessage;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) return invalidMessage;
    return null;
  }

  static String? phone(String? value, {required String emptyMessage, required String invalidMessage}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return emptyMessage;
    final phoneRegex = RegExp(r'^[0-9+\-\s]{7,15}$');
    if (!phoneRegex.hasMatch(trimmed)) return invalidMessage;
    return null;
  }

  static String? password(
    String? value, {
    required String emptyMessage,
    required String tooShortMessage,
    int minLength = 6,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return emptyMessage;
    if (trimmed.length < minLength) return tooShortMessage;
    return null;
  }

  static String? confirmPassword(
    String? value, {
    required String original,
    required String emptyMessage,
    required String mismatchMessage,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return emptyMessage;
    if (trimmed != original) return mismatchMessage;
    return null;
  }

  static String? otp(
    String? value, {
    required int length,
    required String emptyMessage,
    required String invalidMessage,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return emptyMessage;
    if (trimmed.length != length) return invalidMessage;
    return null;
  }
}
