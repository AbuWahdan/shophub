import 'package:flutter_test/flutter_test.dart';
import 'package:sinwar_shoping/core/app/app.dart';
import 'package:sinwar_shoping/core/app/app_initializer.dart';

void main() {
  testWidgets('App boots without widget exceptions', (
      WidgetTester tester,
      ) async {
    final providers = await AppInitializer.initialize();

    await tester.pumpWidget(MyApp(providers: providers));
    await tester.pump(const Duration(seconds: 4));

    expect(find.byType(MyApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}