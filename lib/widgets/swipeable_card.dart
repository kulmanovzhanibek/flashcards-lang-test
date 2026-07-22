import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/language_card.dart';
import '../theme/app_theme.dart';
import 'card_face.dart';

/// A draggable flashcard with hand-rolled swipe physics.
///
/// Behaviour:
///   * follows the finger, tilting more the further it is dragged;
///   * shows a green ("ВЕРНО") or red ("НЕВЕРНО") stamp that fades in with the
///     drag distance;
///   * on release, commits the swipe only if the drag passed a distance *or*
///     velocity threshold — otherwise it springs back to centre (snap-back);
///   * a committed swipe flies the card off-screen, fires haptics matching the
///     grade, then notifies the parent via [onSwipe].
///
/// I implemented the gesture directly (rather than pulling in a card-swiper
/// package) because the snap-back-vs-commit decision and the tilt are the heart
/// of the task — see README.
class SwipeableCard extends StatefulWidget {
  const SwipeableCard({
    super.key,
    required this.card,
    required this.onSwipe,
  });

  final LanguageCard card;

  /// Called once the committed card has finished flying off-screen.
  final void Function(bool swipedRight) onSwipe;

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  /// Max tilt applied at the edge of the screen, in radians.
  static const double _maxTilt = 0.18;

  /// Commit if dragged past this fraction of the card width…
  static const double _distanceThreshold = 0.30;

  /// …or flicked faster than this (px/s).
  static const double _velocityThreshold = 800;

  late final AnimationController _controller;
  Animation<Offset> _animation = const AlwaysStoppedAnimation<Offset>(Offset.zero);

  Offset _offset = Offset.zero;
  Size _size = Size.zero;
  bool _locked = false; // blocks input while the card flies out
  VoidCallback? _onSettled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )
      ..addListener(() => setState(() => _offset = _animation.value))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          final callback = _onSettled;
          _onSettled = null;
          callback?.call();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails _) {
    if (_locked) return;
    _controller.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_locked) return;
    setState(() => _offset += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_locked) return;
    final width = _size.width == 0 ? 1.0 : _size.width;
    final dx = _offset.dx;
    final vx = details.velocity.pixelsPerSecond.dx;

    final passedDistance = dx.abs() > width * _distanceThreshold;
    final passedVelocity = vx.abs() > _velocityThreshold && dx.abs() > 12;

    if (passedDistance || passedVelocity) {
      // Direction follows the flick when velocity-triggered, else the drag.
      final swipedRight = (passedVelocity ? vx : dx) > 0;
      _flyOut(swipedRight);
    } else {
      _settle(Offset.zero); // not enough — snap back to centre
    }
  }

  void _flyOut(bool swipedRight) {
    // Fire feedback immediately on commit, while the card is still animating,
    // so it feels responsive. Grade is derivable here from ground truth.
    final wasCorrect = widget.card.isSwipeCorrect(swipedRight: swipedRight);
    if (wasCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    _locked = true;
    final target = Offset(
      (swipedRight ? 1.5 : -1.5) * _size.width,
      _offset.dy + _size.height * 0.15,
    );
    _onSettled = () => widget.onSwipe(swipedRight);
    _settle(target, curve: Curves.easeIn);
  }

  void _settle(Offset target, {Curve curve = Curves.easeOut}) {
    _animation = Tween<Offset>(begin: _offset, end: target).animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );
    _controller
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);
        final width = _size.width == 0 ? 1.0 : _size.width;
        final tilt = (_offset.dx / width).clamp(-1.0, 1.0) * _maxTilt;

        // Overlay intensity tracks progress toward the commit threshold.
        final progress =
            (_offset.dx / (width * _distanceThreshold)).clamp(-1.0, 1.0);

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform.translate(
            offset: _offset,
            child: Transform.rotate(
              angle: tilt,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CardFace(
                    word: widget.card.word,
                    translation: widget.card.translation,
                  ),
                  _SwipeStamp(progress: progress),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The tinted overlay + corner stamp that fades in as the card is dragged.
/// [progress] is signed: positive = swiping right (correct), negative = left.
class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final magnitude = progress.abs();
    if (magnitude < 0.02) return const SizedBox.shrink();

    final isRight = progress > 0;
    final color = isRight ? AppTheme.correct : AppTheme.wrong;
    final label = isRight ? 'ВЕРНО' : 'НЕВЕРНО';
    final icon = isRight ? Icons.check_rounded : Icons.close_rounded;

    return IgnorePointer(
      child: Opacity(
        opacity: magnitude.clamp(0.0, 1.0),
        child: Stack(
          children: [
            // Colour wash over the whole card.
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: color.withValues(alpha: 0.18),
                border: Border.all(color: color, width: 3),
              ),
            ),
            // Corner stamp, rotated like a rubber stamp.
            Align(
              alignment: isRight ? Alignment.topLeft : Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Transform.rotate(
                  angle: isRight ? -0.35 : 0.35,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color, width: 3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: color, size: 22),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
