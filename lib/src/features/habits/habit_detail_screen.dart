import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/database.dart';
import '../../data/dates.dart';
import '../../data/habit_stats.dart';
import '../../providers.dart';
import '../../ui/bar_chart.dart';
import '../../ui/chart_section.dart';
import '../../ui/month_calendar.dart';
import '../today/day_item_tile.dart';

String _number(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// Tiến độ một thói quen: chuỗi, điểm, tỉ lệ, lịch tháng và biểu đồ
/// (F-05, F-06). Từ đây mở màn sửa.
class HabitDetailScreen extends ConsumerStatefulWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final int habitId;

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  DateTime? _month;
  bool _byWeek = false;
  bool _wasLoaded = false;

  /// Thói quen đã lưu trữ ngay lúc mở màn này chưa; null là chưa đọc xong.
  bool? _openedArchived;

  Future<void> _record(HabitHistory h, DateTime date) async {
    final a = h.habit;
    final key = dateKey(date);
    if (a.evaluation == Evaluation.yesNo) {
      await ref.read(entryRepositoryProvider).toggleDone(a.id, key);
      return;
    }
    final item = await ref.read(dayRepositoryProvider).itemFor(a, key);
    if (!mounted) return;
    if (a.evaluation == Evaluation.checklist) {
      await showChecklistSheet(context, item);
    } else {
      await showValueSheet(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final history = ref.watch(habitHistoryProvider(widget.habitId));
    final weekStart = ref.watch(weekStartProvider).value ?? DateTime.monday;
    final today = ref.watch(todayProvider);

    final h = history.value;
    if (history.hasValue) {
      // Thói quen vừa bị xóa hoặc lưu trữ từ màn sửa: quay lại danh sách. Mở
      // màn này từ danh sách "Đã lưu trữ" (đã lưu trữ ngay từ đầu) thì ở lại.
      final nowArchived = h?.habit.archived ?? false;
      if (h != null) {
        _wasLoaded = true;
        _openedArchived ??= nowArchived;
      }
      final gone = h == null && _wasLoaded;
      final justArchived = h != null && nowArchived && _openedArchived == false;
      if (gone || justArchived) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.canPop()) context.pop();
        });
      }
    }
    if (h == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final a = h.habit;
    final stats = computeStats(h, today: today, weekStart: weekStart);
    final month = _month ?? DateTime.utc(today.year, today.month, 1);
    final startKey = a.startDate;
    final first = startKey == null
        ? null
        : DateTime.utc(
            parseDateKey(startKey).year,
            parseDateKey(startKey).month,
            1,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(a.name),
        actions: [
          if (a.evaluation == Evaluation.duration)
            IconButton(
              icon: const Icon(Icons.timer_outlined),
              tooltip: l.pomodoroStartTimer,
              onPressed: () => context.push('/pomodoro?habit=${a.id}'),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.edit,
            onPressed: () => context.push('/habits/${a.id}/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _StreakCards(stats: stats),
          const SizedBox(height: 16),
          _Rates(stats: stats),
          const SizedBox(height: 24),
          _SectionTitle(l.calendar),
          MonthCalendar(
            month: month,
            today: today,
            weekStart: weekStart,
            firstMonth: first,
            statusOf: (d) => dayStatus(h, d, today),
            onMonthChanged: (m) => setState(() => _month = m),
            onDayTap: (d) => _record(h, d),
          ),
          if (a.evaluation == Evaluation.quantity ||
              a.evaluation == Evaluation.duration) ...[
            const SizedBox(height: 24),
            _SectionTitle(
              a.evaluation == Evaluation.duration
                  ? l.evalDuration
                  : l.evalQuantity,
            ),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: false, label: Text(l.chartByDay)),
                ButtonSegment(value: true, label: Text(l.chartByWeek)),
              ],
              selected: {_byWeek},
              onSelectionChanged: (s) => setState(() => _byWeek = s.single),
            ),
            const SizedBox(height: 12),
            _ValueChart(
              h: h,
              today: today,
              weekStart: weekStart,
              byWeek: _byWeek,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    ),
  );
}

class _StreakCards extends StatelessWidget {
  const _StreakCards({required this.stats});

  final HabitStats stats;

  String _unit(AppLocalizations l, int n) => switch (stats.streakUnit) {
    StreakUnit.days => l.streakDays(n),
    StreakUnit.weeks => l.streakWeeks(n),
    StreakUnit.months => l.streakMonths(n),
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget card(IconData icon, String label, String value) => Expanded(
      child: MergeSemantics(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 4),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // IntrinsicHeight: trong danh sách cuộn chiều cao không bị chặn, nên
    // `stretch` phải có chiều cao tự nhiên của thẻ cao nhất để dựa vào.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          card(
            Icons.local_fire_department_outlined,
            l.streakCurrent,
            _unit(l, stats.currentStreak),
          ),
          card(
            Icons.emoji_events_outlined,
            l.streakLongest,
            _unit(l, stats.longestStreak),
          ),
          card(Icons.speed, l.habitScore, '${stats.score}/100'),
        ],
      ),
    );
  }
}

class _Rates extends StatelessWidget {
  const _Rates({required this.stats});

  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String pct(double? r) => r == null ? l.noRate : '${(r * 100).round()}%';
    Widget cell(String label, double? r) => Expanded(
      child: MergeSemantics(
        child: Column(
          children: [
            Text(
              pct(r),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l.successRate),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cell(l.rate7, stats.rate7),
            cell(l.rate30, stats.rate30),
            cell(l.rateAll, stats.rateAll),
          ],
        ),
      ],
    );
  }
}

/// Biểu đồ cột giá trị theo ngày (30 ngày) hoặc theo tuần (8 tuần), có vạch
/// mục tiêu (AC-27).
class _ValueChart extends StatelessWidget {
  const _ValueChart({
    required this.h,
    required this.today,
    required this.weekStart,
    required this.byWeek,
  });

  final HabitHistory h;
  final DateTime today;
  final int weekStart;
  final bool byWeek;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final a = h.habit;
    final suffix = a.evaluation == Evaluation.duration
        ? ' ${l.minutes}'
        : (a.unit == null || a.unit!.isEmpty ? '' : ' ${a.unit}');
    final dayFmt = DateFormat.MMMd(locale);

    final List<BarData> bars;
    final List<String> labels;
    final List<String> rows;
    if (byWeek) {
      final w = valuesByWeek(h, today, weekStart: weekStart);
      bars = [for (final e in w) BarData(value: e.value, target: e.target)];
      labels = [
        for (final e in w)
          l.weekOf(
            dayFmt.format(DateTime(e.start.year, e.start.month, e.start.day)),
          ),
      ];
      rows = [
        for (final e in w)
          '${_number(e.value)}$suffix / ${_number(e.target)}$suffix',
      ];
    } else {
      final v = valuesByDay(h, today);
      final target = a.target ?? 0;
      bars = [for (final e in v) BarData(value: e.value, target: target)];
      labels = [
        for (final e in v)
          dayFmt.format(DateTime(e.date.year, e.date.month, e.date.day)),
      ];
      rows = [for (final e in v) '${_number(e.value)}$suffix'];
    }
    return ChartSection(
      bars: bars,
      labels: labels,
      rows: rows,
      valueHeader: byWeek ? '${l.tableValue} / ${l.target}' : l.tableValue,
      maxText: '${_number(barChartMax(bars))}$suffix',
    );
  }
}
