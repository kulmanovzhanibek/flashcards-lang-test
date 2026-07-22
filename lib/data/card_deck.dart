import '../models/language_card.dart';

/// Seed deck of English→Russian flashcards.
///
/// A deliberate mix of genuine and false translations so both swipe directions
/// are exercised. Hardcoded on purpose — the task explicitly allows it and the
/// app has no persistence layer.
const List<LanguageCard> kCardDeck = <LanguageCard>[
  // --- Genuine translations (swipe right) ---
  LanguageCard(id: 'doll', word: 'Doll', translation: 'кукла', isTranslationCorrect: true),
  LanguageCard(id: 'window', word: 'Window', translation: 'окно', isTranslationCorrect: true),
  LanguageCard(id: 'apple', word: 'Apple', translation: 'яблоко', isTranslationCorrect: true),
  LanguageCard(id: 'river', word: 'River', translation: 'река', isTranslationCorrect: true),
  LanguageCard(id: 'bridge', word: 'Bridge', translation: 'мост', isTranslationCorrect: true),
  LanguageCard(id: 'mountain', word: 'Mountain', translation: 'гора', isTranslationCorrect: true),
  LanguageCard(id: 'candle', word: 'Candle', translation: 'свеча', isTranslationCorrect: true),
  LanguageCard(id: 'winter', word: 'Winter', translation: 'зима', isTranslationCorrect: true),
  LanguageCard(id: 'spoon', word: 'Spoon', translation: 'ложка', isTranslationCorrect: true),
  LanguageCard(id: 'garden', word: 'Garden', translation: 'сад', isTranslationCorrect: true),
  LanguageCard(id: 'letter', word: 'Letter', translation: 'письмо', isTranslationCorrect: true),
  LanguageCard(id: 'cloud', word: 'Cloud', translation: 'облако', isTranslationCorrect: true),

  // --- False translations (swipe left) ---
  LanguageCard(id: 'ball', word: 'Ball', translation: 'стол', isTranslationCorrect: false),
  LanguageCard(id: 'chair', word: 'Chair', translation: 'дерево', isTranslationCorrect: false),
  LanguageCard(id: 'book', word: 'Book', translation: 'дверь', isTranslationCorrect: false),
  LanguageCard(id: 'sun', word: 'Sun', translation: 'ночь', isTranslationCorrect: false),
  LanguageCard(id: 'milk', word: 'Milk', translation: 'хлеб', isTranslationCorrect: false),
  LanguageCard(id: 'flower', word: 'Flower', translation: 'камень', isTranslationCorrect: false),
  LanguageCard(id: 'horse', word: 'Horse', translation: 'кошка', isTranslationCorrect: false),
  LanguageCard(id: 'clock', word: 'Clock', translation: 'стул', isTranslationCorrect: false),
  LanguageCard(id: 'bread', word: 'Bread', translation: 'вода', isTranslationCorrect: false),
  LanguageCard(id: 'key', word: 'Key', translation: 'рыба', isTranslationCorrect: false),
  LanguageCard(id: 'shoe', word: 'Shoe', translation: 'небо', isTranslationCorrect: false),
  LanguageCard(id: 'fire', word: 'Fire', translation: 'снег', isTranslationCorrect: false),
];
