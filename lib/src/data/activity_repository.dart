import 'package:drift/drift.dart';

import 'database.dart';
import 'dates.dart';
import 'schedule.dart';

/// Nội dung người dùng nhập ở màn soạn thói quen hoặc việc (AC-01, AC-02).
class ActivityDraft {
  const ActivityDraft({
    this.kind = ActivityKind.habit,
    required this.name,
    this.description,
    this.categoryId,
    this.priority = Priority.normal,
    this.evaluation = Evaluation.yesNo,
    this.target,
    this.condition,
    this.unit,
    this.checklistMinDone,
    this.checklist = const [],
    this.startDate,
    this.endDate,
    this.timeOfDay,
    this.rule = ScheduleRule.daily,
  });

  final ActivityKind kind;
  final String name;
  final String? description;
  final int? categoryId;
  final Priority priority;
  final Evaluation evaluation;
  final double? target;
  final TargetCondition? condition;
  final String? unit;
  final int? checklistMinDone;

  /// Mục con theo thứ tự; `id` null là mục mới.
  final List<({int? id, String title})> checklist;
  final String? startDate;
  final String? endDate;
  final int? timeOfDay;
  final ScheduleRule rule;

  /// Lỗi nhập liệu đầu tiên tìm thấy, null nếu hợp lệ. Giá trị trả về là
  /// tên trường để màn hình hiện lỗi đúng chỗ.
  String? validate() {
    final n = name.trim();
    if (n.isEmpty || n.length > 60) return 'name';
    if ((description?.length ?? 0) > 300) return 'description';
    if (evaluation == Evaluation.quantity ||
        evaluation == Evaluation.duration) {
      if (target == null || target! <= 0) return 'target';
    }
    if (evaluation == Evaluation.checklist) {
      if (checklist.isEmpty || checklist.length > 20) return 'checklist';
      if (checklist.any((c) => c.title.trim().isEmpty)) return 'checklist';
      final m = checklistMinDone;
      if (m != null && (m < 1 || m > checklist.length)) return 'checklistMin';
    }
    if (kind == ActivityKind.habit && startDate == null) return 'startDate';
    if (startDate != null &&
        endDate != null &&
        endDate!.compareTo(startDate!) < 0) {
      return 'endDate';
    }
    return rule.validate();
  }

  /// Chỉ kiểu Danh sách con mới lưu mục con; đổi sang kiểu khác thì xóa hết.
  List<({int? id, String title})> get _checklistToSave =>
      evaluation == Evaluation.checklist ? checklist : const [];

  ActivitiesCompanion _fields() {
    final measured =
        evaluation == Evaluation.quantity || evaluation == Evaluation.duration;
    final desc = description?.trim();
    return ActivitiesCompanion(
      kind: Value(kind),
      name: Value(name.trim()),
      description: Value(desc == null || desc.isEmpty ? null : desc),
      categoryId: Value(categoryId),
      priority: Value(priority),
      evaluation: Value(evaluation),
      target: Value(measured ? target : null),
      condition: Value(
        measured ? (condition ?? TargetCondition.atLeast) : null,
      ),
      unit: Value(evaluation == Evaluation.quantity ? unit?.trim() : null),
      checklistMinDone: Value(
        evaluation == Evaluation.checklist ? checklistMinDone : null,
      ),
      startDate: Value(startDate),
      endDate: Value(endDate),
      timeOfDay: Value(timeOfDay),
    );
  }
}

/// Mọi thứ thuộc về một mục, để hoàn tác sau khi xóa (AC-05).
class ActivitySnapshot {
  ActivitySnapshot._(
    this.activity,
    this.schedules,
    this.checklist,
    this.entries,
    this.marks,
    this.reminders,
  );

  final Activity activity;
  final List<Schedule> schedules;
  final List<ChecklistItem> checklist;
  final List<Entry> entries;
  final List<ChecklistMark> marks;
  final List<Reminder> reminders;
}

/// Thêm, sửa, lưu trữ, xóa, sắp xếp thói quen và việc (F-01, D-005).
class ActivityRepository {
  ActivityRepository(this._db);

  final AppDatabase _db;

  /// Thói quen đang dùng (hoặc đã lưu trữ), theo thứ tự người dùng xếp,
  /// lọc theo danh mục nếu có (AC-05, AC-06, AC-32).
  Stream<List<Activity>> watchHabits({bool archived = false, int? categoryId}) {
    final q = _db.select(_db.activities)
      ..where(
        (a) =>
            a.kind.equalsValue(ActivityKind.habit) &
            a.archived.equals(archived),
      )
      ..orderBy([
        (a) => OrderingTerm.asc(a.sortOrder),
        (a) => OrderingTerm.asc(a.id),
      ]);
    if (categoryId != null) q.where((a) => a.categoryId.equals(categoryId));
    return q.watch();
  }

  Future<Activity?> find(int id) => (_db.select(
    _db.activities,
  )..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<List<ChecklistItem>> checklistOf(int id) =>
      (_db.select(_db.checklistItems)
            ..where((c) => c.activityId.equals(id))
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .get();

  Future<List<Schedule>> schedulesOf(int id) =>
      (_db.select(_db.schedules)
            ..where((s) => s.activityId.equals(id))
            ..orderBy([(s) => OrderingTerm.asc(s.effectiveFrom)]))
          .get();

  /// Lịch đang áp dụng (lịch mới nhất).
  Future<ScheduleRule?> currentRule(int id) async {
    final all = await schedulesOf(id);
    return all.isEmpty ? null : ScheduleRule.fromRow(all.last);
  }

  /// Bộ tính ngày đến hạn của một mục (AC-03, AC-04).
  Future<DueCalculator> dueCalculator(Activity a) async => DueCalculator(
    startDate: a.startDate,
    endDate: a.endDate,
    rules: [
      for (final s in await schedulesOf(a.id))
        (effectiveFrom: s.effectiveFrom, rule: ScheduleRule.fromRow(s)),
    ],
  );

  /// Tạo mục mới, xếp cuối danh sách. Trả về id.
  Future<int> create(ActivityDraft draft) {
    assert(draft.validate() == null, draft.validate());
    return _db.transaction(() async {
      final maxOrder = _db.activities.sortOrder.max();
      final last = await (_db.selectOnly(
        _db.activities,
      )..addColumns([maxOrder])).map((r) => r.read(maxOrder)).getSingle();
      final id = await _db
          .into(_db.activities)
          .insert(draft._fields().copyWith(sortOrder: Value((last ?? -1) + 1)));
      await _db
          .into(_db.schedules)
          .insert(
            draft.rule.toCompanion(
              id,
              draft.startDate ?? dateKey(DateTime.now()),
            ),
          );
      await _writeChecklist(id, draft._checklistToSave);
      return id;
    });
  }

  /// Sửa mục. Kết quả đã ghi giữ nguyên. Đổi lịch lặp thì lịch mới có hiệu lực
  /// từ [today] trở đi, các ngày trước giữ lịch cũ (AC-04).
  Future<void> update(int id, ActivityDraft draft, {required DateTime today}) {
    assert(draft.validate() == null, draft.validate());
    return _db.transaction(() async {
      final before = (await find(id))!;
      await (_db.update(
        _db.activities,
      )..where((a) => a.id.equals(id))).write(draft._fields());

      final schedules = await schedulesOf(id);
      final todayKey = dateKey(today);
      final start = draft.startDate ?? todayKey;
      final notStarted =
          start.compareTo(todayKey) > 0 || before.startDate != draft.startDate;
      if (notStarted || schedules.isEmpty) {
        // Chưa tới ngày bắt đầu, hoặc đổi ngày bắt đầu: chưa có lịch sử nào
        // cần giữ lịch cũ, thay hẳn bằng một lịch.
        await (_db.delete(
          _db.schedules,
        )..where((s) => s.activityId.equals(id))).go();
        await _db.into(_db.schedules).insert(draft.rule.toCompanion(id, start));
      } else if (ScheduleRule.fromRow(schedules.last) != draft.rule) {
        if (schedules.last.effectiveFrom.compareTo(todayKey) >= 0) {
          await (_db.delete(
            _db.schedules,
          )..where((s) => s.id.equals(schedules.last.id))).go();
        }
        await _db
            .into(_db.schedules)
            .insert(draft.rule.toCompanion(id, todayKey));
      }
      await _writeChecklist(id, draft._checklistToSave);
    });
  }

  /// Ghi danh sách mục con: giữ id cũ để không mất dấu đã xong, xóa mục bị bỏ.
  Future<void> _writeChecklist(
    int id,
    List<({int? id, String title})> items,
  ) async {
    final keep = items.map((i) => i.id).whereType<int>().toList();
    await (_db.delete(
      _db.checklistItems,
    )..where((c) => c.activityId.equals(id) & c.id.isNotIn(keep))).go();
    for (final (i, item) in items.indexed) {
      final title = item.title.trim();
      if (item.id == null) {
        await _db
            .into(_db.checklistItems)
            .insert(
              ChecklistItemsCompanion.insert(
                activityId: id,
                title: title,
                sortOrder: Value(i),
              ),
            );
      } else {
        await (_db.update(
          _db.checklistItems,
        )..where((c) => c.id.equals(item.id!))).write(
          ChecklistItemsCompanion(title: Value(title), sortOrder: Value(i)),
        );
      }
    }
  }

  /// Lưu trữ hoặc khôi phục; lịch sử giữ nguyên (AC-05).
  Future<void> setArchived(int id, bool archived) =>
      (_db.update(_db.activities)..where((a) => a.id.equals(id))).write(
        ActivitiesCompanion(archived: Value(archived)),
      );

  /// Xóa mục cùng lịch sử, trả về bản chụp để hoàn tác (AC-05).
  Future<ActivitySnapshot> delete(int id) => _db.transaction(() async {
    final a = (await find(id))!;
    final entries = await (_db.select(
      _db.entries,
    )..where((e) => e.activityId.equals(id))).get();
    final entryIds = entries.map((e) => e.id).toList();
    final snapshot = ActivitySnapshot._(
      a,
      await schedulesOf(id),
      await checklistOf(id),
      entries,
      await (_db.select(
        _db.checklistMarks,
      )..where((m) => m.entryId.isIn(entryIds))).get(),
      await (_db.select(
        _db.reminders,
      )..where((r) => r.activityId.equals(id))).get(),
    );
    await (_db.delete(_db.activities)..where((x) => x.id.equals(id))).go();
    return snapshot;
  });

  /// Ghi lại đúng như trước khi xóa, cùng id (AC-05).
  Future<void> restore(ActivitySnapshot s) => _db.transaction(() async {
    await _db.into(_db.activities).insert(s.activity);
    await _db.batch((b) {
      b.insertAll(_db.schedules, s.schedules);
      b.insertAll(_db.checklistItems, s.checklist);
      b.insertAll(_db.entries, s.entries);
      b.insertAll(_db.checklistMarks, s.marks);
      b.insertAll(_db.reminders, s.reminders);
    });
  });

  /// Ghi thứ tự mới theo danh sách id (AC-06).
  Future<void> reorder(List<int> ids) => _db.batch((b) {
    for (final (i, id) in ids.indexed) {
      b.update(
        _db.activities,
        ActivitiesCompanion(sortOrder: Value(i)),
        where: (a) => a.id.equals(id),
      );
    }
  });
}
