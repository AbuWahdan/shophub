import 'package:flutter_test/flutter_test.dart';

import 'package:sinwar_shoping/main.dart';

void main() {
  testWidgets('App boots without widget exceptions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 4));

    expect(find.byType(MyApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
