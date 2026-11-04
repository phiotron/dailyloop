import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/dates.dart';
import '../../data/habit_stats.dart';
import '../../data/stats_repository.dart';
import '../../providers.dart';
import '../../ui/bar_chart.dart';
import '../../ui/chart_section.dart';

/// Màn Thống kê chung: số mục xong trên tổng của 7 và 30 ngày gần nhất, và 3
/// thói quen có chuỗi dài nhất (AC-28, AC-29).
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ranking = ref.watch(rankingProvider).value ?? const <HabitRank>[];
    final c7 = ref.watch(dailyCountsProvider(7)).value;
    final c30 = ref.watch(dailyCountsProvider(30)).value;
    final empty =
        c30 != null && c30.values.every((c) => c.total == 0) && ranking.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.stats),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: empty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.statsEmpty, textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (c7 != null) _CountsChart(title: l.statsLast7, counts: c7),
                const SizedBox(height: 24),
                if (c30 != null)
                  _CountsChart(title: l.statsLast30, counts: c30),
                const SizedBox(height: 24),
                _TopStreaks(ranking: ranking),
              ],
            ),
    );
  }
}

class _CountsChart extends ConsumerWidget {
  const _CountsChart({required this.title, required this.counts});

  final String title;
  final Map<String, DayCount> counts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final keys = counts.keys.toList()..sort();
    final fmt = DateFormat.MMMd(locale);
    String label(String k) {
      final d = parseDateKey(k);
      return fmt.format(DateTime(d.year, d.month, d.day));
    }

    final bars = [
      for (final k in keys)
        BarData(
          value: counts[k]!.done.toDouble(),
          ghost: counts[k]!.total.toDouble(),
        ),
    ];
    final done = counts.values.fold<int>(0, (s, c) => s + c.done);
    final total = counts.values.fold<int>(0, (s, c) => s + c.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.doneOfTotal(done, total),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ChartSection(
          bars: bars,
          labels: [for (final k in keys) label(k)],
          rows: [
            for (final k in keys)
              l.doneOfTotal(counts[k]!.done, counts[k]!.total),
          ],
          valueHeader: '${l.tableDone} / ${l.tableTotal}',
          maxText: '${barChartMax(bars).round()}',
        ),
      ],
    );
  }
}

class _TopStreaks extends StatelessWidget {
  const _TopStreaks({required this.ranking});

  final List<HabitRank> ranking;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final top = ranking
        .where((r) => r.stats.longestStreak > 0)
        .take(3)
        .toList();
    String unit(HabitRank r) => switch (r.stats.streakUnit) {
      StreakUnit.days => l.streakDays(r.stats.longestStreak),
      StreakUnit.weeks => l.streakWeeks(r.stats.longestStreak),
      StreakUnit.months => l.streakMonths(r.stats.longestStreak),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l.statsTopStreaks,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        if (top.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l.statsNoStreak),
          ),
        for (final (i, r) in top.indexed)
          MergeSemantics(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 56,
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(r.habit.name),
              trailing: Text(unit(r)),
              onTap: () => context.push('/habits/${r.habit.id}'),
            ),
          ),
      ],
    );
  }
}
