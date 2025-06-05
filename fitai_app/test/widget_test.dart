
import 'package:flutter_test/flutter_test.dart';

import 'package:fitai_app/main.dart';

void main() {
  testWidgets('FitAI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitAIApp());

    // Verify that the splash screen shows FitAI text
    expect(find.text('FitAI'), findsOneWidget);
    expect(find.text('Personal Trainer Premium'), findsOneWidget);
  });
}