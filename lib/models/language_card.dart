import 'package:flutter/foundation.dart';

/// A single flashcard: a foreign word paired with a Russian translation that
/// may be either genuine or false.
///
/// The user judges the pairing by swiping:
///   * swipe right  → "the translation is correct"
///   * swipe left   → "the translation is false"
///
/// [isTranslationCorrect] is the ground truth we grade that judgement against.
@immutable
class LanguageCard {
  const LanguageCard({
    required this.id,
    required this.word,
    required this.translation,
    required this.isTranslationCorrect,
  });

  /// Stable identifier — used as a widget key so each card gets fresh
  /// animation state as the deck advances.
  final String id;

  /// The word in the foreign language (English in the seed deck).
  final String word;

  /// The translation shown to the user (Russian). May be true or false.
  final String translation;

  /// Ground truth: whether [translation] is the real meaning of [word].
  final bool isTranslationCorrect;

  /// Whether a right/left swipe is the *correct* action for this card.
  ///
  /// A swipe is graded correct when the user's judgement matches reality:
  /// swiping right on a genuine pair, or left on a false one.
  bool isSwipeCorrect({required bool swipedRight}) =>
      swipedRight == isTranslationCorrect;
}
