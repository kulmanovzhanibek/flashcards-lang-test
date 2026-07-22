import 'package:flutter/material.dart';

/// Shows the current consecutive-correct streak and pops with a scale bounce
/// whenever it grows. A reset to zero fades to a muted style instead.
class StreakBadge extends StatefulWidget {
  const StreakBadge({super.key, required this.streak});

  final int streak;

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant StreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only celebrate growth, not resets.
    if (widget.streak > oldWidget.streak) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.streak > 0;
    return ScaleTransition(
      scale: _scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFFFF8C42), Color(0xFFFF5E62)],
                )
              : null,
          color: active ? null : Colors.white.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              'Стрик ${widget.streak}',
              style: TextStyle(
                color:
                    active ? Colors.white : Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
