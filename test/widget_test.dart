import 'package:flutter_test/flutter_test.dart';
import 'package:language_cards/main.dart';
import 'package:language_cards/widgets/swipeable_card.dart';

void main() {
  testWidgets('app boots and shows the streak and navigation', (tester) async {
    await tester.pumpWidget(const LanguageCardsApp());
    await tester.pump();

    // Streak badge starts visible.
    expect(find.textContaining('Стрик'), findsOneWidget);

    // Bottom navigation exposes both destinations.
    expect(find.text('Карточки'), findsOneWidget);
    expect(find.text('Прогресс'), findsOneWidget);
  });

  testWidgets('swiping the top card grades it and advances the deck',
      (tester) async {
    await tester.pumpWidget(const LanguageCardsApp());
    await tester.pump();

    expect(find.text('Осталось 24 / 24'), findsOneWidget);

    // Commit a swipe, then let the fly-away animation finish.
    await tester.timedDrag(find.byType(SwipeableCard), const Offset(240, 0),
        const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Осталось 23 / 24'), findsOneWidget);
  });

  testWidgets('progress tab shows the accuracy label', (tester) async {
    await tester.pumpWidget(const LanguageCardsApp());
    await tester.pump();

    await tester.tap(find.text('Прогресс'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2)); // let counters settle

    expect(find.text('точность'), findsOneWidget);
  });
}
