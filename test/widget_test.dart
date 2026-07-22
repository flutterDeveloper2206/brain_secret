import 'package:flutter_test/flutter_test.dart';
import 'package:finger_print_scan/main.dart';

void main() {
  testWidgets('Fingerprint App renders successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RidgeCounterApp());

    // Verify that our home landing dashboard loads successfully.
    expect(find.text('Fingerprint Scanner Dashboard'), findsOneWidget);
  });
}
