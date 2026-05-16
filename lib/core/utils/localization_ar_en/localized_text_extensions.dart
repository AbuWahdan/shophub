import 'package:flutter/widgets.dart';
import '../../../models/get_code_option_model.dart';
import 'localization_helper.dart';

extension LocalizedOption on GetCodeOptionModel {
  String localizedTitle(BuildContext context) {
    return LocalizationHelper.getLocalizedText(
      context,
      arabic: labelAr,
      english: label,
    );
  }


}