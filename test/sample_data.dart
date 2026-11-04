import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:dailyloop/src/data/settings_repository.dart';

/// Chụp toàn bộ bảng thành JSON để so hai cơ sở dữ liệu.
Future<Map<String, Object>> dump(AppDatabase db) async => {
  'categories': [
    for (final r in await db.select(db.categories).get()) r.toJson(),
  ],
  'activities': [
    for (final r in await db.select(db.activities).get()) r.toJson(),
  ],
  'schedules': [
    for (final r in await db.select(db.schedules).get()) r.toJson(),
  ],
  'checklistItems': [
    for (final r in await db.select(db.checklistItems).get()) r.toJson(),
  ],
  'entries': [for (final r in await db.select(db.entries).get()) r.toJson()],
  'checklistMarks': [
    for (final r in await db.select(db.checklistMarks).get()) r.toJson(),
  ],
  'reminders': [
    for (final r in await db.select(db.reminders).get()) r.toJson(),
  ],
  'settings': [for (final r in await db.select(db.settings).get()) r.toJson()],
};

/// Dữ liệu mẫu đủ mọi bảng: thói quen 4 kiểu, việc, mục con, giờ nhắc, cài đặt.
Future<void> sampleData(AppDatabase db) async {
  final repo = ActivityRepository(db);
  final entries = EntryRepository(db);
  final water = await repo.create(
    const ActivityDraft(
      name: 'Uống nước',
      description: 'Ít nhất 8 ly, "đủ" nước',
      categoryId: 1,
      evaluation: Evaluation.quantity,
      target: 8,
      condition: TargetCondition.atLeast,
      unit: 'ly',
      startDate: '2026-11-01',
      reminders: [(minute: 480, kind: ReminderKind.notification)],
    ),
  );
  final run = await repo.create(
    const ActivityDraft(
      name: 'Chạy bộ',
      evaluation: Evaluation.duration,
      target: 30,
      condition: TargetCondition.atLeast,
      startDate: '2026-11-01',
      rule: ScheduleRule.daily,
      reminders: [(minute: 1200, kind: ReminderKind.alarm)],
    ),
  );
  final pack = await repo.create(
    const ActivityDraft(
      name: 'Chuẩn bị đồ',
      evaluation: Evaluation.checklist,
      checklist: [(id: null, title: 'Sạc pin'), (id: null, title: 'Ví')],
      startDate: '2026-11-01',
    ),
  );
  final task = await repo.create(
    const ActivityDraft(
      kind: ActivityKind.task,
      name: 'Nộp thuế',
      startDate: '2026-11-04',
      rule: ScheduleRule.once,
    ),
  );
  await entries.setValue(water, '2026-11-03', 8);
  await entries.setValue(water, '2026-11-02', 3.5);
  await entries.setValue(run, '2026-11-03', 20);
  await entries.setSkipped(run, '2026-11-02', true);
  final items = await repo.checklistOf(pack);
  await entries.toggleMark(pack, '2026-11-03', items.first.id);
  await entries.setValue(task, '2026-11-04', 1);
  final settings = SettingsRepository(db);
  await settings.setLocaleCode('en');
  await settings.setWeekStart(DateTime.sunday);
}
