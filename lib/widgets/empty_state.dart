import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shown on the cards screen once the deck is exhausted. Summarises the run and
/// offers a restart.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.bestStreak,
    required this.onRestart,
    required this.onViewProgress,
  });

  final int correctCount;
  final int wrongCount;
  final int bestStreak;
  final VoidCallback onRestart;
  final VoidCallback onViewProgress;

  @override
  Widget build(BuildContext context) {
    final total = correctCount + wrongCount;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Колода пройдена!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Верно $correctCount из $total · лучший стрик $bestStreak',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.seed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Начать заново',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onViewProgress,
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('Посмотреть прогресс'),
            ),
          ],
        ),
      ),
    );
  }
}
