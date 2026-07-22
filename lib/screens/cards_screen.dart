import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/language_card.dart';
import '../state/game_controller.dart';
import '../widgets/card_face.dart';
import '../widgets/empty_state.dart';
import '../widgets/streak_badge.dart';
import '../widgets/swipeable_card.dart';

/// Main screen: the card stack, the live streak, and the finished/empty state.
///
/// Stateful because it owns the cards currently flying off-screen: the answer
/// is graded the instant a swipe commits (so the streak and haptics react
/// immediately), while the departing card keeps animating above the stack as
/// a [FlyAwayCard] until it leaves the screen.
class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key, required this.onViewProgress});

  /// Switches the shell to the progress tab.
  final VoidCallback onViewProgress;

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final List<_Departure> _departures = <_Departure>[];
  int _departureSeq = 0;

  void _handleCommit(LanguageCard card, SwipeCommit commit) {
    final controller = context.read<GameController>();
    final wasCorrect = controller.answer(swipedRight: commit.swipedRight);
    if (wasCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    setState(() {
      _departures.add(_Departure(id: _departureSeq++, card: card, commit: commit));
    });
  }

  void _handleDepartureDone(int id) {
    setState(() => _departures.removeWhere((d) => d.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    // Hold the empty state back until the last card has finished flying out.
    final showEmpty = controller.isFinished && _departures.isEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: showEmpty
          ? EmptyState(
              key: const ValueKey('empty'),
              correctCount: controller.correctCount,
              wrongCount: controller.wrongCount,
              bestStreak: controller.bestStreak,
              onRestart: controller.restart,
              onViewProgress: widget.onViewProgress,
            )
          : Column(
              key: const ValueKey('playing'),
              children: [
                _Header(
                  streak: controller.currentStreak,
                  remaining: controller.remaining,
                  total: controller.deck.length,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 440, maxHeight: 580),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildStack(controller),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
    );
  }

  Widget _buildStack(GameController controller) {
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
            onCommit: (commit) => _handleCommit(current, commit),
          ),
        // Committed cards fly out above the (already interactive) new top card.
        for (final departure in _departures)
          FlyAwayCard(
            key: ValueKey('fly-${departure.id}'),
            card: departure.card,
            commit: departure.commit,
            onDone: () => _handleDepartureDone(departure.id),
          ),
      ],
    );
  }
}

/// A card mid-flight after its swipe was committed and graded.
class _Departure {
  const _Departure({required this.id, required this.card, required this.commit});

  final int id;
  final LanguageCard card;
  final SwipeCommit commit;
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
