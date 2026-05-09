import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_app/app.dart';
import 'package:ai_app/injection_container.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  testWidgets('Halo app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HaloApp());
    expect(find.byType(HaloApp), findsOneWidget);
  });
}
