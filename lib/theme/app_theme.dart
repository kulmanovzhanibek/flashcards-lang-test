import 'package:flutter/material.dart';

/// Central place for colours and the app-wide [ThemeData].
///
/// Keeping semantic colours (correct/wrong) here means the swipe overlay, the
/// history strip and the progress bars all speak the same visual language.
class AppTheme {
  const AppTheme._();

  static const Color seed = Color(0xFF6C5CE7);
  static const Color correct = Color(0xFF12B886);
  static const Color wrong = Color(0xFFF03E3E);

  static const Color bgTop = Color(0xFF1E1B33);
  static const Color bgBottom = Color(0xFF121022);
  static const Color surface = Color(0xFF262340);

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: bgBottom,
      textTheme: base.textTheme.apply(fontFamilyFallback: const ['Roboto']),
    );
  }

  /// Full-screen backdrop gradient used behind every screen.
  static const LinearGradient backdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );
}
