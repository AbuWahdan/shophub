import 'package:flutter/foundation.dart';

class ReviewRefreshNotifier {
  ReviewRefreshNotifier._();

  static final ValueNotifier<int?> updatedItemId = ValueNotifier<int?>(null);

  static void notifyItemReviewed(int itemId) {
    updatedItemId.value = itemId;
  }
}
