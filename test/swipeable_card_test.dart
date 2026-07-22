import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_cards/models/language_card.dart';
import 'package:language_cards/widgets/swipeable_card.dart';

const LanguageCard _card = LanguageCard(
  id: 'test',
  word: 'Test',
  translation: 'тест',
  isTranslationCorrect: true,
);

/// Hosts the card in a fixed 400×600 box so thresholds are deterministic:
/// the 30% distance threshold is exactly 120 px.
Widget _harness(ValueChanged<SwipeCommit> onCommit) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          height: 600,
          child: SwipeableCard(card: _card, onCommit: onCommit),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('slow drag past the distance threshold commits rightwards',
      (tester) async {
    SwipeCommit? commit;
    await tester.pumpWidget(_harness((c) => commit = c));

    // 200 px over one second ≈ 200 px/s: well under the velocity threshold,
    // so this exercises the pure distance path.
    await tester.timedDrag(find.byType(SwipeableCard), const Offset(200, 0),
        const Duration(seconds: 1));

    expect(commit, isNotNull);
    expect(commit!.swipedRight, isTrue);
  });

  testWidgets('slow drag past the threshold leftwards commits leftwards',
      (tester) async {
    SwipeCommit? commit;
    await tester.pumpWidget(_harness((c) => commit = c));

    await tester.timedDrag(find.byType(SwipeableCard), const Offset(-200, 0),
        const Duration(seconds: 1));

    expect(commit, isNotNull);
    expect(commit!.swipedRight, isFalse);
  });

  testWidgets('short slow drag snaps back to centre without committing',
      (tester) async {
    SwipeCommit? commit;
    await tester.pumpWidget(_harness((c) => commit = c));

    // 60 px < 120 px threshold, 120 px/s < 800 px/s: neither trigger fires.
    await tester.timedDrag(find.byType(SwipeableCard), const Offset(60, 0),
        const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(commit, isNull);

    // The outermost Transform inside the card is Transform.translate — after
    // the spring settles its translation must be back at (0, 0).
    final transform = tester
        .widgetList<Transform>(find.descendant(
          of: find.byType(SwipeableCard),
          matching: find.byType(Transform),
        ))
        .first;
    final translation = transform.transform.getTranslation();
    expect(translation.x, closeTo(0, 2));
    expect(translation.y, closeTo(0, 2));
  });

  testWidgets('fast flick commits even below the distance threshold',
      (tester) async {
    SwipeCommit? commit;
    await tester.pumpWidget(_harness((c) => commit = c));

    // 80 px < 120 px threshold, but 1200 px/s > 800 px/s: velocity path.
    await tester.fling(find.byType(SwipeableCard), const Offset(80, 0), 1200);

    expect(commit, isNotNull);
    expect(commit!.swipedRight, isTrue);
    expect(commit!.velocity, greaterThan(800));
  });

  testWidgets('fast flick leftwards commits leftwards', (tester) async {
    SwipeCommit? commit;
    await tester.pumpWidget(_harness((c) => commit = c));

    await tester.fling(find.byType(SwipeableCard), const Offset(-80, 0), 1200);

    expect(commit, isNotNull);
    expect(commit!.swipedRight, isFalse);
  });
}
