import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/card_deck.dart';
import 'screens/home_shell.dart';
import 'state/game_controller.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LanguageCardsApp());
}

class LanguageCardsApp extends StatelessWidget {
  const LanguageCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(deck: kCardDeck),
      child: MaterialApp(
        title: 'Language Cards',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeShell(),
      ),
    );
  }
}
