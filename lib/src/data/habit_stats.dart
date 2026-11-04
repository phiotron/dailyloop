import 'dart:math' as math;

import 'database.dart';
import 'dates.dart';
import 'evaluation.dart';
import 'schedule.dart';

/// Kết quả ghi nhận của một thói quen trong một ngày.
class DayRecord {
  const DayRecord({this.value = 0, this.skipped = false, this.checked = 0});

  final double value;
  final bool skipped;

  /// Số mục con đã đánh dấu (kiểu Danh sách con).
  final int checked;
}

/// Kết quả của một "đơn vị tính chuỗi": một ngày đến hạn, hoặc một tuần/tháng
/// với kiểu "K lần mỗi tuần/tháng" (D-008).
enum UnitResult { achieved, missed, skipped, pending }

class StatUnit {
  const StatUnit(this.start, this.end, this.result);

  final DateTime start;

  /// Ngày cuối của đơn vị, không quá hôm nay.
  final DateTime end;
  final UnitResult result;
}

/// Trạng thái một ngày trên lịch tháng (AC-26).
enum DayStatus { achieved, missed, skipped, notDue, future, pending }

/// Đơn vị của chuỗi hiện tại: ngày, tuần hoặc tháng (AC-23).
enum StreakUnit { days, weeks, months }

/// Mọi thứ cần để tính thống kê một thói quen, đọc sẵn từ cơ sở dữ liệu.
class HabitHistory {
  HabitHistory({
    required this.habit,
    required this.calculator,
    required this.records,
    required this.totalItems,
  });

  final Activity habit;
  final DueCalculator calculator;

  /// Kết quả theo ngày `YYYY-MM-DD`; ngày không có dòng là chưa ghi.
  final Map<String, DayRecord> records;

  /// Số mục con hiện có, để xét kiểu Danh sách con.
  final int totalItems;

  /// Ngày [d] đạt mục tiêu không. Ngày chưa ghi tính là 0, như màn Hôm nay
  /// (nên mục tiêu "nhiều nhất" mà chưa ghi gì thì đạt). Ngày bỏ qua không đạt.
  bool achievedOn(DateTime d) {
    final r = records[dateKey(d)];
    if (r != null && r.skipped) return false;
    return isAchieved(
      evaluation: habit.evaluation,
      value: r?.value ?? 0,
      target: habit.target,
      condition: habit.condition,
      checklistMinDone: habit.checklistMinDone,
      checkedItems: r?.checked ?? 0,
      totalItems: totalItems,
    );
  }
}

class HabitStats {
  const HabitStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.score,
    required this.rate7,
    required this.rate30,
    required this.rateAll,
    required this.streakUnit,
    required this.units,
  });

  final int currentStreak;
  final int longestStreak;

  /// Điểm thói quen 0 tới 100 (AC-25).
  final int score;

  /// Tỉ lệ thành công 0 tới 1; null là chưa có ngày nào để tính (AC-24).
  final double? rate7;
  final double? rate30;
  final double? rateAll;
  final StreakUnit streakUnit;
  final List<StatUnit> units;
}

class _Period {
  _Period(this.start, this.end);

  final DateTime start;
  final DateTime end;
  int required = 1;
  int count = 0;
}

/// Đầu và cuối của tuần hoặc tháng chứa [d]. Tuần bắt đầu ở [weekStart].
(DateTime, DateTime) periodBounds(
  DateTime d,
  SchedulePeriod period,
  int weekStart,
) {
  if (period == SchedulePeriod.month) {
    return (
      DateTime.utc(d.year, d.month, 1),
      DateTime.utc(d.year, d.month, daysInMonth(d.year, d.month)),
    );
  }
  final back = (d.weekday - weekStart + 7) % 7;
  final start = DateTime.utc(d.year, d.month, d.day - back);
  return (start, start.add(const Duration(days: 6)));
}

DateTime _min(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

/// Các đơn vị tính chuỗi theo thời gian (D-008).
List<StatUnit> buildUnits(HabitHistory h, DateTime today, int weekStart) {
  final startKey = h.habit.startDate;
  if (startKey == null) return const [];
  final start = parseDateKey(startKey);
  var last = dayOf(today);
  final endKey = h.habit.endDate;
  if (endKey != null) last = _min(last, parseDateKey(endKey));

  final out = <StatUnit>[];
  final periods = <String, _Period>{};
  for (var d = start; !d.isAfter(last); d = d.add(const Duration(days: 1))) {
    final rule = h.calculator.ruleAt(d);
    if (rule == null) continue;
    if (rule.type == ScheduleType.timesPerPeriod) {
      final period = rule.period ?? SchedulePeriod.week;
      final (pStart, pEnd) = periodBounds(d, period, weekStart);
      final p = periods.putIfAbsent(
        '${period.name}|${dateKey(pStart)}',
        () => _Period(pStart, pEnd),
      );
      p.required = rule.timesPerPeriod ?? 1;
      // Với kiểu "K lần" chỉ ngày có ghi mới tính, không tính ngày trống.
      final rec = h.records[dateKey(d)];
      if (rec != null && h.achievedOn(d)) p.count++;
    } else if (h.calculator.isDue(d)) {
      final rec = h.records[dateKey(d)];
      final UnitResult result;
      if (h.achievedOn(d)) {
        result = UnitResult.achieved;
      } else if (rec != null && rec.skipped) {
        result = UnitResult.skipped;
      } else if (d == dayOf(today)) {
        result = UnitResult.pending;
      } else {
        result = UnitResult.missed;
      }
      out.add(StatUnit(d, d, result));
    }
  }

  final t = dayOf(today);
  for (final p in periods.values) {
    final UnitResult result;
    if (p.count >= p.required) {
      result = UnitResult.achieved;
    } else if (!p.end.isBefore(t)) {
      result = UnitResult.pending;
    } else if (p.start.isBefore(start)) {
      // Kỳ đầu bắt đầu giữa chừng: không đủ K thì không tính là thất bại.
      result = UnitResult.skipped;
    } else {
      result = UnitResult.missed;
    }
    out.add(StatUnit(p.start, _min(p.end, last), result));
  }
  out.sort((a, b) {
    final c = a.end.compareTo(b.end);
    return c != 0 ? c : a.start.compareTo(b.start);
  });
  return out;
}

/// Tỉ lệ thành công trong [windowDays] ngày gần nhất (null là từ đầu): số
/// đơn vị đạt chia số đơn vị đã kết thúc, không tính bỏ qua và đơn vị chưa
/// xong (AC-24).
double? successRate(List<StatUnit> units, DateTime today, int? windowDays) {
  final from = windowDays == null
      ? null
      : dayOf(today).subtract(Duration(days: windowDays - 1));
  var achieved = 0;
  var missed = 0;
  for (final u in units) {
    if (from != null && u.end.isBefore(from)) continue;
    if (u.result == UnitResult.achieved) {
      achieved++;
    } else if (u.result == UnitResult.missed) {
      missed++;
    }
  }
  final total = achieved + missed;
  return total == 0 ? null : achieved / total;
}

/// Điểm thói quen: trung bình có trọng số của tối đa 60 đơn vị gần nhất,
/// đơn vị càng cũ trọng số càng thấp (0,95 mỗi bước); bỏ qua và chưa xong
/// không tính. Chưa có dữ liệu thì 0 (AC-25, D-008).
int habitScore(List<StatUnit> units) {
  var weighted = 0.0;
  var total = 0.0;
  var weight = 1.0;
  var counted = 0;
  for (var i = units.length - 1; i >= 0 && counted < 60; i--) {
    final u = units[i];
    if (u.result != UnitResult.achieved && u.result != UnitResult.missed) {
      continue;
    }
    if (u.result == UnitResult.achieved) weighted += weight;
    total += weight;
    weight *= 0.95;
    counted++;
  }
  return total == 0 ? 0 : (100 * weighted / total).round();
}

/// Chuỗi hiện tại và dài nhất (AC-23). Ngày bỏ qua và đơn vị chưa xong
/// không làm đứt chuỗi; hôm nay chưa đạt thì chuỗi tính tới hôm qua.
({int current, int longest}) streaks(List<StatUnit> units) {
  var run = 0;
  var longest = 0;
  for (final u in units) {
    switch (u.result) {
      case UnitResult.achieved:
        run++;
        longest = math.max(longest, run);
      case UnitResult.missed:
        run = 0;
      case UnitResult.skipped:
      case UnitResult.pending:
        break;
    }
  }
  return (current: run, longest: longest);
}

HabitStats computeStats(
  HabitHistory h, {
  required DateTime today,
  int weekStart = DateTime.monday,
}) {
  final units = buildUnits(h, today, weekStart);
  final s = streaks(units);
  final rule = h.calculator.ruleAt(today);
  final unit = rule?.type == ScheduleType.timesPerPeriod
      ? (rule?.period == SchedulePeriod.month
            ? StreakUnit.months
            : StreakUnit.weeks)
      : StreakUnit.days;
  return HabitStats(
    currentStreak: s.current,
    longestStreak: s.longest,
    score: habitScore(units),
    rate7: successRate(units, today, 7),
    rate30: successRate(units, today, 30),
    rateAll: successRate(units, today, null),
    streakUnit: unit,
    units: units,
  );
}

/// Trạng thái ngày [date] trên lịch tháng (AC-26).
DayStatus dayStatus(HabitHistory h, DateTime date, DateTime today) {
  final d = dayOf(date);
  final t = dayOf(today);
  if (d.isAfter(t)) return DayStatus.future;
  final rec = h.records[dateKey(d)];
  if (rec != null && rec.skipped) return DayStatus.skipped;

  final startKey = h.habit.startDate;
  final endKey = h.habit.endDate;
  final rule = h.calculator.ruleAt(d);
  final within =
      rule != null &&
      startKey != null &&
      !d.isBefore(parseDateKey(startKey)) &&
      (endKey == null || !d.isAfter(parseDateKey(endKey)));
  final due =
      within &&
      rule.type != ScheduleType.timesPerPeriod &&
      h.calculator.isDue(d);

  if (due) {
    if (h.achievedOn(d)) return DayStatus.achieved;
    return d == t ? DayStatus.pending : DayStatus.missed;
  }
  // Ngày không đến hạn nhưng người dùng đã ghi đạt thì vẫn tô màu đạt.
  if (rec != null && h.achievedOn(d)) return DayStatus.achieved;
  return DayStatus.notDue;
}

/// Giá trị đã ghi của [days] ngày kết thúc ở [today], cũ trước (AC-27).
List<({DateTime date, double value})> valuesByDay(
  HabitHistory h,
  DateTime today, {
  int days = 30,
}) {
  final t = dayOf(today);
  return [
    for (var i = days - 1; i >= 0; i--)
      (
        date: t.subtract(Duration(days: i)),
        value: _valueOn(h, t.subtract(Duration(days: i))),
      ),
  ];
}

double _valueOn(HabitHistory h, DateTime d) {
  final r = h.records[dateKey(d)];
  return r == null || r.skipped ? 0 : r.value;
}

/// Tổng giá trị theo [weeks] tuần gần nhất và mục tiêu của tuần đó: mục tiêu
/// mỗi ngày nhân số ngày đến hạn trong tuần (kiểu "K lần mỗi tuần" thì nhân K)
/// (AC-27).
List<({DateTime start, double value, double target})> valuesByWeek(
  HabitHistory h,
  DateTime today, {
  int weeks = 8,
  int weekStart = DateTime.monday,
}) {
  final (thisStart, _) = periodBounds(
    dayOf(today),
    SchedulePeriod.week,
    weekStart,
  );
  final dayTarget = h.habit.target ?? 0;
  final out = <({DateTime start, double value, double target})>[];
  for (var i = weeks - 1; i >= 0; i--) {
    final start = thisStart.subtract(Duration(days: 7 * i));
    var sum = 0.0;
    var due = 0;
    for (var k = 0; k < 7; k++) {
      final d = start.add(Duration(days: k));
      sum += _valueOn(h, d);
      if (h.calculator.isDue(d)) due++;
    }
    final rule = h.calculator.ruleAt(start.add(const Duration(days: 6)));
    final perWeek =
        rule?.type == ScheduleType.timesPerPeriod &&
            rule?.period == SchedulePeriod.week
        ? (rule?.timesPerPeriod ?? 0)
        : due;
    out.add((start: start, value: sum, target: dayTarget * perWeek));
  }
  return out;
}
