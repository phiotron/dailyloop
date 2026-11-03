import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../data/database.dart';
import '../data/schedule.dart';

/// Tên thứ ngắn theo ngôn ngữ, bit 0 là Thứ Hai … bit 6 là Chủ Nhật.
/// Ngày 2026-11-02 là Thứ Hai.
List<String> weekdayShortNames(String locale) => [
  for (var i = 0; i < 7; i++)
    DateFormat.E(locale).format(DateTime(2026, 11, 2 + i)),
];

/// Thứ tự hiện các thứ theo ngày đầu tuần (chỉ số bit 0–6).
List<int> weekdayOrder(int weekStart) => weekStart == DateTime.sunday
    ? const [6, 0, 1, 2, 3, 4, 5]
    : const [0, 1, 2, 3, 4, 5, 6];

/// Mô tả ngắn lịch lặp, ví dụ "Th 2, Th 4" hoặc "Cứ 3 ngày một lần".
String scheduleSummary(
  AppLocalizations l,
  String locale,
  ScheduleRule rule, {
  int weekStart = DateTime.monday,
}) {
  switch (rule.type) {
    case ScheduleType.once:
      return l.scheduleOnce;
    case ScheduleType.daily:
      return l.scheduleDaily;
    case ScheduleType.weekdays:
      final names = weekdayShortNames(locale);
      return [
        for (final i in weekdayOrder(weekStart))
          if (rule.weekdays & (1 << i) != 0) names[i],
      ].join(', ');
    case ScheduleType.monthDays:
      return l.scheduleMonthDays(
        formatMonthDays(rule.monthDays).replaceAll(',', ', '),
      );
    case ScheduleType.everyNDays:
      return l.scheduleEveryN(rule.interval ?? 2);
    case ScheduleType.timesPerPeriod:
      final k = rule.timesPerPeriod ?? 1;
      return rule.period == SchedulePeriod.month
          ? l.scheduleTimesMonth(k)
          : l.scheduleTimesWeek(k);
  }
}
