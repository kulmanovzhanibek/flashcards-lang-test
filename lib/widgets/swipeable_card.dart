import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../models/language_card.dart';
import '../theme/app_theme.dart';
import 'card_face.dart';

/// Max tilt applied at the edge of the screen, in radians.
const double _maxTilt = 0.18;

/// Commit if dragged past this fraction of the card width…
const double _distanceThreshold = 0.30;

/// …or flicked faster than this (px/s).
const double _velocityThreshold = 800;

/// Exit speed bounds for the fly-away animation (px/s). A slow drag past the
/// threshold leaves at the floor speed; a hard flick keeps its own pace up to
/// the ceiling.
const double _minExitSpeed = 1600;
const double _maxExitSpeed = 4000;

/// Snap-back spring: slightly underdamped so the card lands with a subtle
/// wobble instead of a dead easing curve.
final SpringDescription _snapBackSpring =
    SpringDescription.withDampingRatio(mass: 1, stiffness: 500, ratio: 0.8);

/// A committed swipe, reported at the moment the gesture crosses a threshold —
/// before any exit animation plays. Carries the card's position and release
/// velocity so the exit animation can continue the motion seamlessly.
@immutable
class SwipeCommit {
  const SwipeCommit({
    required this.swipedRight,
    required this.offset,
    required this.velocity,
  });

  /// The judged direction: right = "translation is correct".
  final bool swipedRight;

  /// Card offset relative to its resting position at the moment of commit.
  final Offset offset;

  /// Horizontal release velocity in px/s (signed, may be near zero when the
  /// commit came from the distance threshold rather than a flick).
  final double velocity;
}

/// A draggable flashcard with hand-rolled swipe physics.
///
/// Behaviour:
///   * follows the finger, tilting more the further it is dragged;
///   * shows a green ("ВЕРНО") or red ("НЕВЕРНО") stamp that fades in with the
///     drag distance;
///   * on release, commits the swipe only if the drag passed a distance *or*
///     velocity threshold — otherwise it springs back to centre on a real
///     [SpringSimulation] seeded with the release velocity, so the hand's
///     momentum carries into the snap-back.
///
/// On commit this widget does *not* animate the exit itself: it reports a
/// [SwipeCommit] immediately so the parent can grade the answer right away
/// (instant streak/haptics) and hand the visual exit to [FlyAwayCard].
///
/// I implemented the gesture directly (rather than pulling in a card-swiper
/// package) because the snap-back-vs-commit decision and the tilt are the heart
/// of the task — see README.
class SwipeableCard extends StatefulWidget {
  const SwipeableCard({
    super.key,
    required this.card,
    required this.onCommit,
  });

  final LanguageCard card;

  /// Called the instant the swipe crosses a commit threshold.
  final ValueChanged<SwipeCommit> onCommit;

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<Offset> _animation =
      const AlwaysStoppedAnimation<Offset>(Offset.zero);

  Offset _offset = Offset.zero;
  Size _size = Size.zero;
  bool _committed = false; // blocks input once the swipe is handed off

  @override
  void initState() {
    super.initState();
    // Unbounded so the spring may overshoot past its target (value > 1.0).
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() => _offset = _animation.value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails _) {
    if (_committed) return;
    _controller.stop(); // grabbing mid-snap-back picks the card up in place
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_committed) return;
    setState(() => _offset += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_committed) return;
    final width = _size.width == 0 ? 1.0 : _size.width;
    final dx = _offset.dx;
    final vx = details.velocity.pixelsPerSecond.dx;

    final passedDistance = dx.abs() > width * _distanceThreshold;
    // The tiny distance guard filters out twitchy zero-length flicks.
    final passedVelocity = vx.abs() > _velocityThreshold && dx.abs() > 12;

    if (passedDistance || passedVelocity) {
      // Direction follows the flick when velocity-triggered, else the drag.
      final swipedRight = (passedVelocity ? vx : dx) > 0;
      _committed = true;
      widget.onCommit(SwipeCommit(
        swipedRight: swipedRight,
        offset: _offset,
        velocity: vx,
      ));
    } else {
      _springBack(details.velocity.pixelsPerSecond);
    }
  }

  /// Springs the card back to centre, seeding the simulation with the release
  /// velocity so it first drifts with the hand before returning.
  void _springBack(Offset releaseVelocity) {
    _animation = Tween<Offset>(begin: _offset, end: Offset.zero)
        .animate(_controller);

    // The controller runs 0→1 along the offset→centre track; project the
    // release velocity (px/s) onto that track to get its unit-space speed.
    final delta = -_offset;
    final unitVelocity = delta == Offset.zero
        ? 0.0
        : (releaseVelocity.dx * delta.dx + releaseVelocity.dy * delta.dy) /
            delta.distanceSquared;

    _controller
      ..value = 0
      ..animateWith(SpringSimulation(_snapBackSpring, 0, 1, unitVelocity));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);
        final width = _size.width == 0 ? 1.0 : _size.width;
        final tilt = _tiltFor(_offset, width);

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

/// Tilt shared by the interactive card and the fly-away copy so the exit
/// continues the exact pose the drag left off at.
double _tiltFor(Offset offset, double width) =>
    (offset.dx / width).clamp(-1.0, 1.0) * _maxTilt;

/// The departing card: rendered above the stack after a commit, it flies the
/// card off-screen starting from the exact offset the drag released it at.
///
/// The exit inherits the flick velocity — a hard flick leaves at its own pace
/// (capped at [_maxExitSpeed]), a slow drag past the distance threshold leaves
/// at [_minExitSpeed] — so the animation reads as the same motion continuing,
/// not a canned 300 ms tween.
class FlyAwayCard extends StatefulWidget {
  const FlyAwayCard({
    super.key,
    required this.card,
    required this.commit,
    required this.onDone,
  });

  final LanguageCard card;
  final SwipeCommit commit;

  /// Called once the card has fully left the screen.
  final VoidCallback onDone;

  @override
  State<FlyAwayCard> createState() => _FlyAwayCardState();
}

class _FlyAwayCardState extends State<FlyAwayCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _animation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Sizing arrives via LayoutBuilder, so the flight is configured on the
  /// first build rather than in initState.
  void _startOnce(Size size) {
    if (_started) return;
    _started = true;

    final commit = widget.commit;
    final end = Offset(
      (commit.swipedRight ? 1.5 : -1.5) * size.width,
      commit.offset.dy + size.height * 0.15,
    );
    final distance = (end - commit.offset).distance;
    final speed = commit.velocity.abs().clamp(_minExitSpeed, _maxExitSpeed);

    _animation = Tween<Offset>(begin: commit.offset, end: end)
        .animate(_controller);
    _controller
      ..duration =
          Duration(milliseconds: (distance / speed * 1000).round().clamp(80, 500))
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _startOnce(size);
        final width = size.width == 0 ? 1.0 : size.width;

        return IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final offset = _animation.value;
              return Transform.translate(
                offset: offset,
                child: Transform.rotate(
                  angle: _tiltFor(offset, width),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CardFace(
                        word: widget.card.word,
                        translation: widget.card.translation,
                      ),
                      _SwipeStamp(
                        progress: widget.commit.swipedRight ? 1 : -1,
                      ),
                    ],
                  ),
                ),
              );
            },
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
