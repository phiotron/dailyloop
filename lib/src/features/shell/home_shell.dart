import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

/// Thanh điều hướng dưới (AC-33): Hôm nay, Thói quen, Việc, Thống kê.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l.today,
          ),
          NavigationDestination(
            icon: const Icon(Icons.repeat),
            selectedIcon: const Icon(Icons.repeat_on),
            label: l.habits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            selectedIcon: const Icon(Icons.task_alt),
            label: l.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l.stats,
          ),
        ],
      ),
    );
  }
}
