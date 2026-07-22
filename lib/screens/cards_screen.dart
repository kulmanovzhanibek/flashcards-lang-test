import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_controller.dart';
import '../widgets/card_face.dart';
import '../widgets/empty_state.dart';
import '../widgets/streak_badge.dart';
import '../widgets/swipeable_card.dart';

/// Main screen: the card stack, the live streak, and the finished/empty state.
class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key, required this.onViewProgress});

  /// Switches the shell to the progress tab.
  final VoidCallback onViewProgress;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    if (controller.isFinished) {
      return EmptyState(
        correctCount: controller.correctCount,
        wrongCount: controller.wrongCount,
        bestStreak: controller.bestStreak,
        onRestart: controller.restart,
        onViewProgress: onViewProgress,
      );
    }

    return Column(
      children: [
        _Header(
          streak: controller.currentStreak,
          remaining: controller.remaining,
          total: controller.deck.length,
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440, maxHeight: 580),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _CardStack(controller: controller),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.streak,
    required this.remaining,
    required this.total,
  });

  final int streak;
  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreakBadge(streak: streak),
          Text(
            'Осталось $remaining / $total',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final current = controller.currentCard;
    final next = controller.nextCard;

    return Stack(
      fit: StackFit.expand,
      children: [
        // The next card peeks from behind to give the stack depth.
        if (next != null)
          Transform.translate(
            offset: const Offset(0, 18),
            child: Transform.scale(
              scale: 0.94,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.6,
                  child: CardFace(
                    word: next.word,
                    translation: next.translation,
                    elevation: 6,
                  ),
                ),
              ),
            ),
          ),
        if (current != null)
          SwipeableCard(
            // Fresh key per card => fresh gesture/animation state.
            key: ValueKey(current.id),
            card: current,
            onSwipe: (swipedRight) =>
                controller.answer(swipedRight: swipedRight),
          ),
      ],
    );
  }
}
