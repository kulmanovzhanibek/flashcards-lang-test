import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The static visual of a flashcard: the foreign word and its candidate
/// translation. Kept separate from gesture handling so it can be reused (e.g.
/// the peeking "next" card behind the active one).
class CardFace extends StatelessWidget {
  const CardFace({
    super.key,
    required this.word,
    required this.translation,
    this.elevation = 18,
  });

  final String word;
  final String translation;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF302B4F), AppTheme.surface],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: elevation,
            offset: Offset(0, elevation * 0.5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 44,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.seed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            translation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const Spacer(),
          Text(
            'Свайп вправо — верный перевод\nвлево — ложный',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
