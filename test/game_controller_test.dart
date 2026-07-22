import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_cards/models/language_card.dart';
import 'package:language_cards/state/game_controller.dart';

/// A tiny deterministic deck: 3 genuine, 2 false.
final List<LanguageCard> _deck = [
  const LanguageCard(id: 'a', word: 'A', translation: 'а', isTranslationCorrect: true),
  const LanguageCard(id: 'b', word: 'B', translation: 'б', isTranslationCorrect: false),
  const LanguageCard(id: 'c', word: 'C', translation: 'в', isTranslationCorrect: true),
  const LanguageCard(id: 'd', word: 'D', translation: 'г', isTranslationCorrect: false),
  const LanguageCard(id: 'e', word: 'E', translation: 'д', isTranslationCorrect: true),
];

GameController _newController() =>
    // Fixed seed => deterministic shuffle across runs.
    GameController(deck: _deck, random: Random(42));

/// Answers the current card correctly by matching its ground truth.
void _answerCorrectly(GameController c) =>
    c.answer(swipedRight: c.currentCard!.isTranslationCorrect);

/// Answers the current card incorrectly.
void _answerWrong(GameController c) =>
    c.answer(swipedRight: !c.currentCard!.isTranslationCorrect);

void main() {
  group('grading', () {
    test('a swipe matching ground truth is correct', () {
      final c = _newController();
      final card = c.currentCard!;
      final result = c.answer(swipedRight: card.isTranslationCorrect);
      expect(result, isTrue);
      expect(c.correctCount, 1);
      expect(c.wrongCount, 0);
    });

    test('a swipe against ground truth is wrong', () {
      final c = _newController();
      final card = c.currentCard!;
      final result = c.answer(swipedRight: !card.isTranslationCorrect);
      expect(result, isFalse);
      expect(c.correctCount, 0);
      expect(c.wrongCount, 1);
    });
  });

  group('streak logic', () {
    test('increments on consecutive correct answers', () {
      final c = _newController();
      _answerCorrectly(c);
      _answerCorrectly(c);
      _answerCorrectly(c);
      expect(c.currentStreak, 3);
      expect(c.bestStreak, 3);
    });

    test('resets to zero on any wrong answer', () {
      final c = _newController();
      _answerCorrectly(c);
      _answerCorrectly(c);
      _answerWrong(c);
      expect(c.currentStreak, 0);
    });

    test('best streak remembers the peak after a reset', () {
      final c = _newController();
      _answerCorrectly(c);
      _answerCorrectly(c);
      _answerWrong(c);
      _answerCorrectly(c);
      expect(c.currentStreak, 1);
      expect(c.bestStreak, 2);
    });
  });

  group('stats', () {
    test('accuracy is zero before any answers', () {
      expect(_newController().accuracy, 0);
      expect(_newController().accuracyPercent, 0);
    });

    test('accuracy reflects correct ratio', () {
      final c = _newController();
      _answerCorrectly(c); // 1/1
      _answerWrong(c); // 1/2
      _answerCorrectly(c); // 2/3
      _answerCorrectly(c); // 3/4
      expect(c.totalAnswered, 4);
      expect(c.correctCount, 3);
      expect(c.accuracyPercent, 75);
    });
  });

  group('deck progression', () {
    test('finishes once every card is answered', () {
      final c = _newController();
      expect(c.isFinished, isFalse);
      for (var i = 0; i < _deck.length; i++) {
        _answerCorrectly(c);
      }
      expect(c.isFinished, isTrue);
      expect(c.currentCard, isNull);
    });

    test('answering past the end is a no-op', () {
      final c = _newController();
      for (var i = 0; i < _deck.length; i++) {
        _answerCorrectly(c);
      }
      final before = c.totalAnswered;
      final result = c.answer(swipedRight: true);
      expect(result, isFalse);
      expect(c.totalAnswered, before);
    });
  });

  group('history', () {
    test('recentHistory returns at most the last N, newest last', () {
      final c = GameController(deck: List.generate(
        15,
        (i) => LanguageCard(
          id: '$i',
          word: 'W$i',
          translation: 'П$i',
          isTranslationCorrect: i.isEven,
        ),
      ), random: Random(1));

      for (var i = 0; i < 12; i++) {
        _answerCorrectly(c);
      }
      final recent = c.recentHistory(10);
      expect(recent.length, 10);
      // Every entry here was answered correctly.
      expect(recent.every((r) => r.wasCorrect), isTrue);
    });
  });

  group('restart', () {
    test('clears every stat', () {
      final c = _newController();
      _answerCorrectly(c);
      _answerWrong(c);
      c.restart();
      expect(c.currentStreak, 0);
      expect(c.bestStreak, 0);
      expect(c.correctCount, 0);
      expect(c.wrongCount, 0);
      expect(c.totalAnswered, 0);
      expect(c.isFinished, isFalse);
      expect(c.history, isEmpty);
    });
  });
}
