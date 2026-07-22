import 'package:flutter/material.dart';

/// A number that rolls up from zero to [value] when it first appears (and
/// animates smoothly between values afterwards). Used for the progress screen
/// stat tiles.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 900),
    this.style,
  });

  final int value;
  final String suffix;
  final Duration duration;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(
          '${animatedValue.round()}$suffix',
          style: style ??
              const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
        );
      },
    );
  }
}
