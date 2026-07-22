import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/answer_record.dart';
import '../models/language_card.dart';

/// Owns all game state and rules for a single session.
///
/// The UI is intentionally dumb: widgets read derived getters and call
/// [answer] / [restart]. Every mutation runs through here, which keeps the
/// streak rule — "any wrong answer resets the streak to zero" — in exactly one
/// place and makes it trivial to unit-test without a widget tree.
class GameController extends ChangeNotifier {
  GameController({required List<LanguageCard> deck, Random? random})
      : _sourceDeck = List.unmodifiable(deck),
        _random = random ?? Random() {
    _deck = _shuffled();
  }

  final List<LanguageCard> _sourceDeck;
  final Random _random;

  late List<LanguageCard> _deck;
  int _index = 0;

  int _currentStreak = 0;
  int _bestStreak = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  final List<AnswerRecord> _history = <AnswerRecord>[];

  // --- Deck / navigation ---------------------------------------------------

  List<LanguageCard> get deck => List.unmodifiable(_deck);
  int get index => _index;
  int get remaining => _deck.length - _index;
  bool get isFinished => _index >= _deck.length;

  /// The card currently on top of the stack, or `null` once the deck is empty.
  LanguageCard? get currentCard => isFinished ? null : _deck[_index];

  /// The card that will surface next — used to render a peek behind the top
  /// card so the stack feels physical.
  LanguageCard? get nextCard =>
      _index + 1 < _deck.length ? _deck[_index + 1] : null;

  // --- Stats ---------------------------------------------------------------

  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  int get totalAnswered => _correctCount + _wrongCount;

  /// Accuracy in the 0..1 range. Zero when nothing has been answered yet.
  double get accuracy =>
      totalAnswered == 0 ? 0 : _correctCount / totalAnswered;

  /// Whole-percent accuracy for display.
  int get accuracyPercent => (accuracy * 100).round();

  /// Full session log, oldest first.
  List<AnswerRecord> get history => List.unmodifiable(_history);

  /// The most recent [count] answers, oldest first — for the history strip.
  List<AnswerRecord> recentHistory([int count = 10]) {
    if (_history.length <= count) return history;
    return List.unmodifiable(_history.sublist(_history.length - count));
  }

  // --- Actions -------------------------------------------------------------

  /// Grades the top card against a swipe direction, updates all stats and
  /// advances to the next card.
  ///
  /// Returns the grading result so the caller can drive direction-specific
  /// feedback (haptics, colour) without re-deriving it.
  bool answer({required bool swipedRight}) {
    final card = currentCard;
    if (card == null) return false;

    final wasCorrect = card.isSwipeCorrect(swipedRight: swipedRight);
    if (wasCorrect) {
      _correctCount++;
      _currentStreak++;
      _bestStreak = max(_bestStreak, _currentStreak);
    } else {
      _wrongCount++;
      _currentStreak = 0;
    }

    _history.add(AnswerRecord(
      card: card,
      swipedRight: swipedRight,
      wasCorrect: wasCorrect,
    ));
    _index++;
    notifyListeners();
    return wasCorrect;
  }

  /// Reshuffles the deck and clears every stat for a fresh session.
  void restart() {
    _deck = _shuffled();
    _index = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _history.clear();
    notifyListeners();
  }

  List<LanguageCard> _shuffled() {
    final copy = List<LanguageCard>.of(_sourceDeck);
    copy.shuffle(_random);
    return copy;
  }
}
