import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skorbord_flutter/widgets/score_display.dart';

void main() {
  testWidgets('ScoreDisplay running tally and animation', (WidgetTester tester) async {
    int score = 10;
    const key = 'test-score';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplay(score: score, scoreDisplayKey: key),
        ),
      ),
    );

    // Initial score
    expect(find.text('10'), findsOneWidget);
    expect(find.byType(ScoreDisplay), findsOneWidget);

    // Update score: +2
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplay(score: score + 2, scoreDisplayKey: key),
        ),
      ),
    );
    await tester.pump(); // Start animation
    expect(find.text('+2'), findsOneWidget);

    // Update score again within 3s: +3 (should show +5)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplay(score: score + 5, scoreDisplayKey: key),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('+5'), findsOneWidget);

    // Wait 3 seconds for tally to fade
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('+5'), findsNothing);

    // Negative tally
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplay(score: score - 2, scoreDisplayKey: key),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('-2'), findsOneWidget);

    // Wait 3 seconds for tally to fade
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('-2'), findsNothing);
  });
}
