import 'package:flutter_test/flutter_test.dart';
import 'package:ai_app/app.dart';

void main() {
  testWidgets('Halo app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HaloApp());
    expect(find.byType(HaloApp), findsOneWidget);
  });
}
