import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_counter.dart';
import '../widgets/answer_history_strip.dart';

/// Progress screen: session accuracy, streaks, tallies and recent history.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Прогресс',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _AccuracyRing(
              percent: controller.accuracyPercent,
              accuracy: controller.accuracy,
              answered: controller.totalAnswered,
            ),
            const SizedBox(height: 16),
            _MotivationBanner(
              accuracy: controller.accuracy,
              answered: controller.totalAnswered,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Текущий стрик',
                    value: controller.currentStreak,
                    icon: Icons.bolt_rounded,
                    color: const Color(0xFFFF8C42),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Лучший стрик',
                    value: controller.bestStreak,
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF5E62),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Верно',
                    value: controller.correctCount,
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.correct,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: 'Неверно',
                    value: controller.wrongCount,
                    icon: Icons.cancel_rounded,
                    color: AppTheme.wrong,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _CorrectWrongBar(
              correct: controller.correctCount,
              wrong: controller.wrongCount,
            ),
            const SizedBox(height: 28),
            Text(
              'Последние ответы',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 14),
            AnswerHistoryStrip(records: controller.recentHistory()),
          ],
        ),
      ),
    );
  }
}

class _AccuracyRing extends StatelessWidget {
  const _AccuracyRing({
    required this.percent,
    required this.accuracy,
    required this.answered,
  });

  final int percent;
  final double accuracy;
  final int answered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: answered == 0 ? 0.0 : accuracy),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 14,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.seed),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedCounter(
                  value: answered == 0 ? 0 : percent,
                  suffix: '%',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'точность',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationBanner extends StatelessWidget {
  const _MotivationBanner({required this.accuracy, required this.answered});

  final double accuracy;
  final int answered;

  String get _message {
    if (answered == 0) return 'Свайпни первую карточку, чтобы начать 👋';
    if (accuracy >= 0.9) return 'Блестяще! Ты почти носитель 🌟';
    if (accuracy >= 0.7) return 'Отличный результат, так держать! 💪';
    if (accuracy >= 0.5) return 'Неплохо — ещё немного практики 📈';
    return 'Всё приходит с практикой, продолжай! 🌱';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.seed.withValues(alpha: 0.14),
        border: Border.all(color: AppTheme.seed.withValues(alpha: 0.4)),
      ),
      child: Text(
        _message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppTheme.surface.withValues(alpha: 0.6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          AnimatedCounter(
            value: value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal bar splitting correct vs wrong. Widths animate on change.
class _CorrectWrongBar extends StatelessWidget {
  const _CorrectWrongBar({required this.correct, required this.wrong});

  final int correct;
  final int wrong;

  @override
  Widget build(BuildContext context) {
    final total = correct + wrong;
    final correctFlex = total == 0 ? 1 : correct;
    final wrongFlex = total == 0 ? 1 : wrong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Соотношение ответов',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 22,
            child: total == 0
                ? Container(color: Colors.white.withValues(alpha: 0.06))
                : Row(
                    children: [
                      Expanded(
                        flex: correctFlex,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          color: AppTheme.correct,
                        ),
                      ),
                      Expanded(
                        flex: wrongFlex,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          color: AppTheme.wrong,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('✓ $correct верно',
                style: const TextStyle(color: AppTheme.correct, fontSize: 13)),
            Text('$wrong неверно ✗',
                style: const TextStyle(color: AppTheme.wrong, fontSize: 13)),
          ],
        ),
      ],
    );
  }
}
