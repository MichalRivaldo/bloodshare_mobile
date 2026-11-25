import 'package:flutter_test/flutter_test.dart';
import 'package:bloodshare/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BloodShareApp());
    expect(find.byType(BloodShareApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
