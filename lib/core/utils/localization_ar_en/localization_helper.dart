import 'package:flutter/cupertino.dart';

class LocalizationHelper {
  static String getLocalizedText(BuildContext context, {
    required String arabic,
    required String english,
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'ar' ? arabic : english;
  }

  static String getCurrentLanguageCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }
}