import 'package:drift/drift.dart';

import 'database.dart';
import 'dates.dart';
import 'habit_stats.dart';
import 'schedule.dart';

/// Số mục đã xong trên tổng số mục của một ngày (AC-28).
typedef DayCount = ({int done, int total});

/// Một thói quen cùng thống kê của nó, để xếp hạng chuỗi (AC-28).
typedef HabitRank = ({Activity habit, HabitStats stats});

/// Đọc lịch sử để tính thống kê (F-05, F-06). Mọi hàm `watch` tự phát lại
/// khi dữ liệu liên quan đổi.
class StatsRepository {
  StatsRepository(this._db);

  final AppDatabase _db;

  Stream<T> _watch<T>(Future<T> Function() load) async* {
    yield await load();
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.activities,
        _db.schedules,
        _db.checklistItems,
        _db.entries,
        _db.checklistMarks,
      ]),
    )) {
      yield await load();
    }
  }

  /// Lịch sử của các mục [activities], đọc bằng vài truy vấn chung.
  Future<List<HabitHistory>> _histories(List<Activity> activities) async {
    if (activities.isEmpty) return const [];
    final ids = activities.map((a) => a.id).toList();
    final schedules = await (_db.select(
      _db.schedules,
    )..where((s) => s.activityId.isIn(ids))).get();
    final items = await (_db.select(
      _db.checklistItems,
    )..where((c) => c.activityId.isIn(ids))).get();
    final entries = await (_db.select(
      _db.entries,
    )..where((e) => e.activityId.isIn(ids))).get();
    // Nối bảng thay vì `entryId IN (...)`: lịch sử dài có hàng chục nghìn
    // kết quả, vượt giới hạn số biến của SQLite (thấy khi test 50 thói quen
    // × 3 năm).
    final marks =
        await (_db.select(_db.checklistMarks).join([
              innerJoin(
                _db.entries,
                _db.entries.id.equalsExp(_db.checklistMarks.entryId),
              ),
            ])..where(_db.entries.activityId.isIn(ids)))
            .map((r) => r.readTable(_db.checklistMarks))
            .get();

    final schedulesBy = <int, List<Schedule>>{};
    for (final s in schedules) {
      (schedulesBy[s.activityId] ??= []).add(s);
    }
    final itemCount = <int, int>{};
    for (final c in items) {
      itemCount[c.activityId] = (itemCount[c.activityId] ?? 0) + 1;
    }
    final markCount = <int, int>{};
    for (final m in marks) {
      markCount[m.entryId] = (markCount[m.entryId] ?? 0) + 1;
    }
    final recordsBy = <int, Map<String, DayRecord>>{};
    for (final e in entries) {
      (recordsBy[e.activityId] ??= {})[e.date] = DayRecord(
        value: e.value,
        skipped: e.skipped,
        checked: markCount[e.id] ?? 0,
      );
    }

    return [
      for (final a in activities)
        HabitHistory(
          habit: a,
          calculator: DueCalculator(
            startDate: a.startDate,
            endDate: a.endDate,
            rules: [
              for (final s in schedulesBy[a.id] ?? const <Schedule>[])
                (effectiveFrom: s.effectiveFrom, rule: ScheduleRule.fromRow(s)),
            ],
          ),
          records: recordsBy[a.id] ?? const {},
          totalItems: itemCount[a.id] ?? 0,
        ),
    ];
  }

  /// Lịch sử của một thói quen; null nếu không có (đã xóa).
  Future<HabitHistory?> loadHistory(int activityId) async {
    final a = await (_db.select(
      _db.activities,
    )..where((x) => x.id.equals(activityId))).getSingleOrNull();
    if (a == null) return null;
    return (await _histories([a])).single;
  }

  Stream<HabitHistory?> watchHistory(int activityId) =>
      _watch(() => loadHistory(activityId));

  /// Thói quen đang dùng, xếp theo chuỗi dài nhất giảm dần, hòa thì theo
  /// điểm rồi theo thứ tự người dùng xếp (AC-28).
  Future<List<HabitRank>> loadRanking({
    required DateTime today,
    int weekStart = DateTime.monday,
  }) async {
    final habits =
        await (_db.select(_db.activities)
              ..where(
                (a) =>
                    a.kind.equalsValue(ActivityKind.habit) &
                    a.archived.equals(false),
              )
              ..orderBy([
                (a) => OrderingTerm.asc(a.sortOrder),
                (a) => OrderingTerm.asc(a.id),
              ]))
            .get();
    final all = await _histories(habits);
    final ranked = [
      for (final h in all)
        (
          habit: h.habit,
          stats: computeStats(h, today: today, weekStart: weekStart),
        ),
    ];
    // Sắp ổn định: List.sort của Dart không ổn định nên kèm chỉ số gốc.
    final order = {for (final (i, r) in ranked.indexed) r.habit.id: i};
    ranked.sort((a, b) {
      final c = b.stats.longestStreak.compareTo(a.stats.longestStreak);
      if (c != 0) return c;
      final s = b.stats.score.compareTo(a.stats.score);
      return s != 0 ? s : order[a.habit.id]!.compareTo(order[b.habit.id]!);
    });
    return ranked;
  }

  Stream<List<HabitRank>> watchRanking({
    required DateTime today,
    int weekStart = DateTime.monday,
  }) => _watch(() => loadRanking(today: today, weekStart: weekStart));

  /// Số mục đã xong trên tổng số mục đến hạn của từng ngày từ [from] tới [to]
  /// (AC-28). Mục bỏ qua không vào tổng. Việc quá hạn tính ở ngày gốc của nó.
  Future<Map<String, DayCount>> dailyCounts(DateTime from, DateTime to) async {
    final activities = await (_db.select(
      _db.activities,
    )..where((a) => a.archived.equals(false))).get();
    final histories = await _histories(activities);
    final out = <String, DayCount>{};
    for (
      var d = dayOf(from);
      !d.isAfter(dayOf(to));
      d = d.add(const Duration(days: 1))
    ) {
      var done = 0;
      var total = 0;
      for (final h in histories) {
        if (!h.calculator.isDue(d)) continue;
        final rec = h.records[dateKey(d)];
        if (rec != null && rec.skipped) continue;
        total++;
        if (h.achievedOn(d)) done++;
      }
      out[dateKey(d)] = (done: done, total: total);
    }
    return out;
  }

  Stream<Map<String, DayCount>> watchDailyCounts(DateTime from, DateTime to) =>
      _watch(() => dailyCounts(from, to));
}
