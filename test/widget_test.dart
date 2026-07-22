import 'package:flutter_test/flutter_test.dart';
import 'package:language_cards/main.dart';

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

  testWidgets('progress tab shows the accuracy label', (tester) async {
    await tester.pumpWidget(const LanguageCardsApp());
    await tester.pump();

    await tester.tap(find.text('Прогресс'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2)); // let counters settle

    expect(find.text('точность'), findsOneWidget);
  });
}
