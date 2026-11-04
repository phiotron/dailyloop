import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../data/dates.dart';
import '../data/habit_stats.dart';
import 'schedule_text.dart';

/// Lịch tháng tô màu từng ngày (AC-26). Mỗi trạng thái có cả màu lẫn biểu
/// tượng nhỏ nên không chỉ phân biệt bằng màu (AC-50). Vuốt ngang hoặc bấm
/// mũi tên để đổi tháng; chạm một ngày đã qua để sửa kết quả.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.today,
    required this.statusOf,
    required this.onMonthChanged,
    required this.onDayTap,
    this.weekStart = DateTime.monday,
    this.firstMonth,
  });

  /// Một ngày bất kỳ trong tháng đang xem (UTC).
  final DateTime month;
  final DateTime today;
  final DayStatus Function(DateTime day) statusOf;
  final ValueChanged<DateTime> onMonthChanged;

  /// Gọi khi chạm ngày đã qua hoặc hôm nay.
  final ValueChanged<DateTime> onDayTap;
  final int weekStart;

  /// Tháng sớm nhất cho phép lùi tới (tháng của ngày bắt đầu); null là không giới hạn.
  final DateTime? firstMonth;

  DateTime get _first => DateTime.utc(month.year, month.month, 1);

  void _go(int delta) {
    final next = DateTime.utc(month.year, month.month + delta, 1);
    if (delta < 0 && firstMonth != null && next.isBefore(firstMonth!)) return;
    onMonthChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final first = _first;
    final lead = (first.weekday - weekStart + 7) % 7;
    final days = daysInMonth(first.year, first.month);
    final rows = ((lead + days) / 7).ceil();
    final names = weekdayShortNames(locale);
    final canGoBack =
        firstMonth == null ||
        !DateTime.utc(month.year, month.month - 1, 1).isBefore(firstMonth!);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v > 300) _go(-1);
        if (v < -300) _go(1);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: l.prevMonth,
                onPressed: canGoBack ? () => _go(-1) : null,
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    DateFormat.yMMMM(locale).format(first),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: l.nextMonth,
                onPressed: () => _go(1),
              ),
            ],
          ),
          Table(
            children: [
              TableRow(
                children: [
                  for (final i in weekdayOrder(weekStart))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ExcludeSemantics(
                        child: Text(
                          names[i],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                ],
              ),
              for (var r = 0; r < rows; r++)
                TableRow(
                  children: [
                    for (var c = 0; c < 7; c++)
                      _cell(context, l, locale, r * 7 + c - lead + 1, days),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          _Legend(),
        ],
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    AppLocalizations l,
    String locale,
    int dayNumber,
    int daysInThisMonth,
  ) {
    if (dayNumber < 1 || dayNumber > daysInThisMonth) {
      return const SizedBox(height: 52);
    }
    final date = DateTime.utc(month.year, month.month, dayNumber);
    final status = statusOf(date);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isToday = date == dayOf(today);
    final tappable = status != DayStatus.future;

    final (
      Color? fill,
      Color text,
      IconData? icon,
      Color iconColor,
    ) = switch (status) {
      DayStatus.achieved => (
        scheme.primary,
        scheme.onPrimary,
        Icons.check,
        scheme.onPrimary,
      ),
      DayStatus.missed => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.close,
        scheme.onErrorContainer,
      ),
      DayStatus.skipped => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
        Icons.redo,
        scheme.onSurfaceVariant,
      ),
      DayStatus.pending => (
        null,
        scheme.onSurface,
        Icons.more_horiz,
        scheme.primary,
      ),
      DayStatus.notDue => (
        null,
        scheme.onSurfaceVariant,
        null,
        Colors.transparent,
      ),
      DayStatus.future => (
        null,
        scheme.onSurfaceVariant.withValues(alpha: 0.6),
        null,
        Colors.transparent,
      ),
    };

    final statusText = switch (status) {
      DayStatus.achieved => l.achieved,
      DayStatus.missed => l.notAchieved,
      DayStatus.skipped => l.skipped,
      DayStatus.pending => l.dayPending,
      DayStatus.notDue => l.dayNotDue,
      DayStatus.future => l.dayFuture,
    };
    final label = '${DateFormat.yMMMMd(locale).format(date)}, $statusText';

    return Semantics(
      label: label,
      button: tappable,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: tappable ? () => onDayTap(date) : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(color: scheme.primary, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$dayNumber',
                style: theme.textTheme.bodyMedium?.copyWith(color: text),
              ),
              if (icon != null) Icon(icon, size: 14, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chú thích các trạng thái, bằng chữ lẫn biểu tượng.
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    Widget item(IconData icon, Color color, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
    return ExcludeSemantics(
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          item(Icons.check_circle, scheme.primary, l.achieved),
          item(Icons.cancel, scheme.error, l.notAchieved),
          item(Icons.redo, scheme.onSurfaceVariant, l.skipped),
        ],
      ),
    );
  }
}
