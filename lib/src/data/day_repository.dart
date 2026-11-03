import 'package:drift/drift.dart';

import 'database.dart';
import 'dates.dart';
import 'evaluation.dart';
import 'schedule.dart';

/// Một mục hiện trong ngày ở màn Hôm nay hoặc màn Việc.
class DayItem {
  const DayItem({
    required this.activity,
    required this.date,
    this.entry,
    this.items = const [],
    this.marked = const {},
    this.overdueDays = 0,
    this.minuteOfDay,
  });

  final Activity activity;

  /// Ngày mà kết quả được ghi vào. Việc quá hạn ghi vào ngày gốc của việc;
  /// việc chưa xếp lịch ghi vào hôm nay.
  final String date;
  final Entry? entry;
  final List<ChecklistItem> items;
  final Set<int> marked;

  /// Số ngày quá hạn của việc một lần chưa xong (AC-15); 0 là không quá hạn.
  final int overdueDays;

  /// Giờ để sắp xếp: giờ của việc, hoặc giờ nhắc sớm nhất (AC-07).
  final int? minuteOfDay;

  double get value => entry?.value ?? 0;
  bool get skipped => entry?.skipped ?? false;
  bool get isTask => activity.kind == ActivityKind.task;

  /// Đạt mục tiêu trong ngày (AC-09). Việc cần làm: đã đánh xong.
  bool get achieved => isTask
      ? value >= 1
      : isAchieved(
          evaluation: activity.evaluation,
          value: value,
          target: activity.target,
          condition: activity.condition,
          checklistMinDone: activity.checklistMinDone,
          checkedItems: marked.length,
          totalItems: items.length,
        );

  /// Đã xử lý xong trong ngày: đạt hoặc bỏ qua; xếp xuống dưới (AC-07).
  bool get settled => achieved || skipped;
}

/// Bộ lọc màn Việc (AC-16).
enum TaskFilter { today, upcoming, overdue, unscheduled, done }

/// Đọc dữ liệu một ngày cho màn Hôm nay, và danh sách việc theo bộ lọc
/// (F-02, F-03). Tự phát lại khi bất kỳ bảng liên quan thay đổi.
class DayRepository {
  DayRepository(this._db);

  final AppDatabase _db;

  List<TableInfo> get _tables => [
    _db.activities,
    _db.schedules,
    _db.checklistItems,
    _db.entries,
    _db.checklistMarks,
    _db.reminders,
  ];

  Stream<T> _watch<T>(Future<T> Function() load) async* {
    yield await load();
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables(_tables),
    )) {
      yield await load();
    }
  }

  Stream<List<DayItem>> watchDay(DateTime day, {required DateTime today}) =>
      _watch(() => loadDay(day, today: today));

  Stream<List<DayItem>> watchTasks(
    TaskFilter filter, {
    required DateTime today,
  }) => _watch(() => loadTasks(filter, today: today));

  /// Dữ liệu dùng chung cho một lần đọc.
  Future<_Snapshot> _snapshot(Iterable<String> dates) async {
    final activities =
        await (_db.select(_db.activities)
              ..where((a) => a.archived.equals(false))
              ..orderBy([
                (a) => OrderingTerm.asc(a.sortOrder),
                (a) => OrderingTerm.asc(a.id),
              ]))
            .get();
    final schedules = await _db.select(_db.schedules).get();
    final items = await (_db.select(
      _db.checklistItems,
    )..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();
    final reminders = await _db.select(_db.reminders).get();
    final dateList = dates.toSet().toList();
    final entries = dateList.isEmpty
        ? <Entry>[]
        : await (_db.select(
            _db.entries,
          )..where((e) => e.date.isIn(dateList))).get();
    final marks = entries.isEmpty
        ? <ChecklistMark>[]
        : await (_db.select(
            _db.checklistMarks,
          )..where((m) => m.entryId.isIn(entries.map((e) => e.id)))).get();
    return _Snapshot(activities, schedules, items, reminders, entries, marks);
  }

  Future<List<DayItem>> loadDay(DateTime day, {required DateTime today}) async {
    final dayKey = dateKey(day);
    final todayKey = dateKey(today);
    final isToday = dayKey == todayKey;
    // Việc quá hạn chỉ hiện ở hôm nay và cần kết quả ở ngày gốc của nó.
    final overdueDates = isToday
        ? [
            for (final a
                in await (_db.select(_db.activities)..where(
                      (a) =>
                          a.kind.equalsValue(ActivityKind.task) &
                          a.startDate.isSmallerThanValue(todayKey),
                    ))
                    .get())
              a.startDate!,
          ]
        : const <String>[];
    final s = await _snapshot([dayKey, ...overdueDates]);

    final out = <DayItem>[];
    for (final a in s.activities) {
      final rule = s.ruleOf(a.id);
      final once = rule?.type == ScheduleType.once;
      if (a.kind == ActivityKind.task && once) {
        final date = a.startDate;
        if (date == null) continue;
        if (date == dayKey) {
          out.add(s.item(a, dayKey));
        } else if (isToday && date.compareTo(todayKey) < 0) {
          final item = s.item(
            a,
            date,
            overdueDays: daysBetween(
              parseDateKey(date),
              parseDateKey(todayKey),
            ),
          );
          if (!item.achieved) out.add(item);
        }
        continue;
      }
      if (s.calculator(a).isDue(parseDateKey(dayKey))) {
        out.add(s.item(a, dayKey));
      }
    }
    out.sort(_compare);
    return out;
  }

  /// Quá hạn trước, chưa xong trước đã xong, rồi theo giờ, ưu tiên cao trước
  /// (AC-07, AC-15).
  static int _compare(DayItem a, DayItem b) {
    final overdue = (b.overdueDays > 0 ? 1 : 0) - (a.overdueDays > 0 ? 1 : 0);
    if (overdue != 0) return overdue;
    final settled = (a.settled ? 1 : 0) - (b.settled ? 1 : 0);
    if (settled != 0) return settled;
    final ta = a.minuteOfDay, tb = b.minuteOfDay;
    if (ta != tb) {
      if (ta == null) return 1;
      if (tb == null) return -1;
      return ta.compareTo(tb);
    }
    return b.activity.priority.index.compareTo(a.activity.priority.index);
  }

  Future<List<DayItem>> loadTasks(
    TaskFilter filter, {
    required DateTime today,
  }) async {
    final todayKey = dateKey(today);
    final tasks = await (_db.select(
      _db.activities,
    )..where((a) => a.kind.equalsValue(ActivityKind.task))).get();
    // Kết quả của việc một lần nằm ở ngày của nó, việc chưa xếp lịch ở bất kỳ
    // ngày nào (đánh xong ngày nào ghi ngày đó).
    final s = await _snapshot([
      todayKey,
      for (final t in tasks)
        if (t.startDate != null) t.startDate!,
    ]);
    final undatedDone = {
      for (final e
          in await (_db.select(_db.entries)..where(
                (e) =>
                    e.activityId.isIn([
                      for (final t in tasks)
                        if (t.startDate == null) t.id,
                    ]) &
                    e.value.isBiggerOrEqualValue(1),
              ))
              .get())
        e.activityId: e,
    };

    final out = <DayItem>[];
    for (final a in s.activities.where((a) => a.kind == ActivityKind.task)) {
      final once = s.ruleOf(a.id)?.type == ScheduleType.once;
      final date = a.startDate;
      if (!once) {
        // Việc lặp lại: hôm nay nếu đến hạn, sắp tới nếu chưa tới ngày bắt đầu
        // hoặc hôm nay không đến hạn.
        final dueToday = s.calculator(a).isDue(parseDateKey(todayKey));
        final item = s.item(a, todayKey);
        final include = switch (filter) {
          TaskFilter.today => dueToday,
          TaskFilter.upcoming => !dueToday,
          TaskFilter.done => dueToday && item.achieved,
          _ => false,
        };
        if (include) out.add(item);
        continue;
      }
      if (date == null) {
        final doneEntry = undatedDone[a.id];
        final item = doneEntry == null
            ? s.item(a, todayKey)
            : DayItem(activity: a, date: doneEntry.date, entry: doneEntry);
        final include = switch (filter) {
          TaskFilter.unscheduled => !item.achieved,
          TaskFilter.done => item.achieved,
          _ => false,
        };
        if (include) out.add(item);
        continue;
      }
      final cmp = date.compareTo(todayKey);
      final item = s.item(
        a,
        date,
        overdueDays: cmp < 0
            ? daysBetween(parseDateKey(date), parseDateKey(todayKey))
            : 0,
      );
      final include = switch (filter) {
        TaskFilter.today => cmp == 0,
        TaskFilter.upcoming => cmp > 0 && !item.achieved,
        TaskFilter.overdue => cmp < 0 && !item.achieved,
        TaskFilter.done => item.achieved,
        TaskFilter.unscheduled => false,
      };
      if (include) out.add(item);
    }
    if (filter == TaskFilter.upcoming || filter == TaskFilter.overdue) {
      out.sort((a, b) {
        final d = (a.activity.startDate ?? '').compareTo(
          b.activity.startDate ?? '',
        );
        return d != 0 ? d : _compare(a, b);
      });
    } else {
      out.sort(_compare);
    }
    return out;
  }
}

class _Snapshot {
  _Snapshot(
    this.activities,
    List<Schedule> schedules,
    List<ChecklistItem> items,
    List<Reminder> reminders,
    List<Entry> entries,
    List<ChecklistMark> marks,
  ) {
    for (final s in schedules) {
      (_schedules[s.activityId] ??= []).add(s);
    }
    for (final i in items) {
      (_items[i.activityId] ??= []).add(i);
    }
    for (final r in reminders) {
      final cur = _firstReminder[r.activityId];
      if (cur == null || r.minuteOfDay < cur) {
        _firstReminder[r.activityId] = r.minuteOfDay;
      }
    }
    for (final e in entries) {
      _entries['${e.activityId}|${e.date}'] = e;
    }
    for (final m in marks) {
      (_marks[m.entryId] ??= {}).add(m.itemId);
    }
  }

  final List<Activity> activities;
  final _schedules = <int, List<Schedule>>{};
  final _items = <int, List<ChecklistItem>>{};
  final _firstReminder = <int, int>{};
  final _entries = <String, Entry>{};
  final _marks = <int, Set<int>>{};

  ScheduleRule? ruleOf(int id) {
    final list = _schedules[id];
    if (list == null || list.isEmpty) return null;
    final latest = list.reduce(
      (a, b) => a.effectiveFrom.compareTo(b.effectiveFrom) >= 0 ? a : b,
    );
    return ScheduleRule.fromRow(latest);
  }

  DueCalculator calculator(Activity a) => DueCalculator(
    startDate: a.startDate,
    endDate: a.endDate,
    rules: [
      for (final s in _schedules[a.id] ?? const <Schedule>[])
        (effectiveFrom: s.effectiveFrom, rule: ScheduleRule.fromRow(s)),
    ],
  );

  DayItem item(Activity a, String date, {int overdueDays = 0}) {
    final entry = _entries['${a.id}|$date'];
    return DayItem(
      activity: a,
      date: date,
      entry: entry,
      items: _items[a.id] ?? const [],
      marked: entry == null ? const {} : (_marks[entry.id] ?? const {}),
      overdueDays: overdueDays,
      minuteOfDay: a.timeOfDay ?? _firstReminder[a.id],
    );
  }
}
