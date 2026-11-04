import 'package:drift/drift.dart' show Value;

import 'database.dart';
import 'dates.dart';

/// Lịch lặp của một mục, độc lập với cơ sở dữ liệu để test được (AC-03).
class ScheduleRule {
  const ScheduleRule({
    required this.type,
    this.weekdays = 0,
    this.monthDays = const {},
    this.interval,
    this.timesPerPeriod,
    this.period,
  });

  factory ScheduleRule.fromRow(Schedule s) => ScheduleRule(
    type: s.type,
    weekdays: s.weekdays ?? 0,
    monthDays: parseMonthDays(s.monthDays),
    interval: s.interval,
    timesPerPeriod: s.timesPerPeriod,
    period: s.period,
  );

  static const daily = ScheduleRule(type: ScheduleType.daily);
  static const once = ScheduleRule(type: ScheduleType.once);

  final ScheduleType type;

  /// Bit 0 là Thứ Hai … bit 6 là Chủ Nhật.
  final int weekdays;
  final Set<int> monthDays;
  final int? interval;
  final int? timesPerPeriod;
  final SchedulePeriod? period;

  /// Lịch có đủ thông tin để dùng không. Trả về null nếu hợp lệ, không thì
  /// tên trường sai.
  String? validate() => switch (type) {
    ScheduleType.weekdays when weekdays & 0x7F == 0 => 'weekdays',
    ScheduleType.monthDays
        when monthDays.isEmpty || monthDays.any((d) => d < 1 || d > 31) =>
      'monthDays',
    ScheduleType.everyNDays
        when interval == null || interval! < 2 || interval! > 365 =>
      'interval',
    ScheduleType.timesPerPeriod
        when period == null ||
            timesPerPeriod == null ||
            timesPerPeriod! < 1 ||
            timesPerPeriod! > (period == SchedulePeriod.week ? 7 : 31) =>
      'timesPerPeriod',
    _ => null,
  };

  SchedulesCompanion toCompanion(int activityId, String effectiveFrom) =>
      SchedulesCompanion.insert(
        activityId: activityId,
        effectiveFrom: effectiveFrom,
        type: type,
        weekdays: Value(type == ScheduleType.weekdays ? weekdays : null),
        monthDays: Value(
          type == ScheduleType.monthDays ? formatMonthDays(monthDays) : null,
        ),
        interval: Value(type == ScheduleType.everyNDays ? interval : null),
        timesPerPeriod: Value(
          type == ScheduleType.timesPerPeriod ? timesPerPeriod : null,
        ),
        period: Value(type == ScheduleType.timesPerPeriod ? period : null),
      );

  /// Ngày [day] có thuộc lịch không, tính từ ngày mốc [anchor] của lịch.
  /// Kiểu "K lần mỗi tuần/tháng" thì ngày nào cũng làm được (AC-03).
  bool matches(DateTime day, DateTime anchor) => switch (type) {
    ScheduleType.once => daysBetween(anchor, day) == 0,
    ScheduleType.daily || ScheduleType.timesPerPeriod => true,
    ScheduleType.weekdays => weekdays & (1 << (day.weekday - 1)) != 0,
    // Tháng không có ngày 31 thì bỏ qua, không dời sang ngày khác.
    ScheduleType.monthDays => monthDays.contains(day.day),
    ScheduleType.everyNDays => daysBetween(anchor, day) % interval! == 0,
  };

  @override
  bool operator ==(Object other) =>
      other is ScheduleRule &&
      other.type == type &&
      (type != ScheduleType.weekdays || other.weekdays == weekdays) &&
      (type != ScheduleType.monthDays ||
          formatMonthDays(other.monthDays) == formatMonthDays(monthDays)) &&
      (type != ScheduleType.everyNDays || other.interval == interval) &&
      (type != ScheduleType.timesPerPeriod ||
          (other.timesPerPeriod == timesPerPeriod && other.period == period));

  @override
  int get hashCode => type.hashCode;
}

Set<int> parseMonthDays(String? s) =>
    s == null || s.isEmpty ? const {} : s.split(',').map(int.parse).toSet();

String formatMonthDays(Set<int> days) => (days.toList()..sort()).join(',');

/// Lịch có ngày hiệu lực (D-005).
typedef DatedRule = ({String effectiveFrom, ScheduleRule rule});

/// Tính ngày đến hạn của một mục từ ngày bắt đầu, ngày kết thúc và các lịch
/// theo thời gian (AC-03, AC-04).
class DueCalculator {
  DueCalculator({
    required String? startDate,
    required String? endDate,
    required List<DatedRule> rules,
  }) : _start = startDate == null ? null : parseDateKey(startDate),
       _end = endDate == null ? null : parseDateKey(endDate),
       _rules = [
         for (final r in [
           ...rules,
         ]..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom)))
           (from: parseDateKey(r.effectiveFrom), rule: r.rule),
       ];

  final DateTime? _start;
  final DateTime? _end;
  final List<({DateTime from, ScheduleRule rule})> _rules;

  /// Lịch áp dụng cho [day]: lịch có ngày hiệu lực gần nhất trước hoặc bằng
  /// [day]. Trước lịch đầu tiên thì dùng lịch đầu tiên.
  ({DateTime from, ScheduleRule rule})? _ruleFor(DateTime day) {
    if (_rules.isEmpty) return null;
    var current = _rules.first;
    for (final r in _rules) {
      if (!r.from.isAfter(day)) current = r;
    }
    return current;
  }

  /// Lịch áp dụng cho [date] (D-005); null nếu mục chưa có lịch.
  ScheduleRule? ruleAt(DateTime date) => _ruleFor(dayOf(date))?.rule;

  bool isDue(DateTime date) {
    final day = dayOf(date);
    if (_start == null) return false;
    if (day.isBefore(_start)) return false;
    if (_end != null && day.isAfter(_end)) return false;
    final r = _ruleFor(day);
    if (r == null) return false;
    // Mốc của "cứ N ngày" và việc một lần là ngày bắt đầu khi lịch đầu tiên
    // có hiệu lực từ trước đó, còn lại là ngày hiệu lực của lịch.
    final anchor = r.from.isBefore(_start) ? _start : r.from;
    return r.rule.matches(day, anchor);
  }

  /// Các ngày đến hạn từ [from] tới [to], tính cả hai đầu.
  List<DateTime> dueDates(DateTime from, DateTime to) {
    final out = <DateTime>[];
    for (
      var d = dayOf(from);
      !d.isAfter(dayOf(to));
      d = d.add(const Duration(days: 1))
    ) {
      if (isDue(d)) out.add(d);
    }
    return out;
  }
}
