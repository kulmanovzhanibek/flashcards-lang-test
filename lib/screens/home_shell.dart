import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'cards_screen.dart';
import 'progress_screen.dart';

/// Hosts the two screens behind a bottom navigation bar. An [IndexedStack]
/// keeps both alive so the card stack's position and animations survive a trip
/// to the progress tab and back.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backdrop),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            children: [
              CardsScreen(onViewProgress: () => _goTo(1)),
              const ProgressScreen(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.seed.withValues(alpha: 0.35),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.style_outlined),
              selectedIcon: Icon(Icons.style_rounded),
              label: 'Карточки',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Прогресс',
            ),
          ],
        ),
      ),
    );
  }
}
