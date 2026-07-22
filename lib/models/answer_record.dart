import 'package:flutter/foundation.dart';

import 'language_card.dart';

/// The outcome of answering a single card. Kept in a session log so the
/// progress screen can render the "last 10 answers" history strip.
@immutable
class AnswerRecord {
  const AnswerRecord({
    required this.card,
    required this.swipedRight,
    required this.wasCorrect,
  });

  final LanguageCard card;

  /// The direction the user swiped: right = "translation is correct".
  final bool swipedRight;

  /// Whether that judgement matched the card's ground truth.
  final bool wasCorrect;
}
