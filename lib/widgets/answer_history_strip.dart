import 'package:flutter/material.dart';

import '../models/answer_record.dart';
import '../theme/app_theme.dart';

/// A left-to-right chain of ✓/✗ chips for the most recent answers.
class AnswerHistoryStrip extends StatelessWidget {
  const AnswerHistoryStrip({super.key, required this.records});

  /// Oldest first; the newest answer sits on the right.
  final List<AnswerRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Text(
        'Пока нет ответов',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final record in records)
          _HistoryDot(correct: record.wasCorrect),
      ],
    );
  }
}

class _HistoryDot extends StatelessWidget {
  const _HistoryDot({required this.correct});

  final bool correct;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppTheme.correct : AppTheme.wrong;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Icon(
        correct ? Icons.check_rounded : Icons.close_rounded,
        color: color,
        size: 20,
      ),
    );
  }
}
