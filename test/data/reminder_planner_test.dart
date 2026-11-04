import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:dailyloop/src/reminders/reminder_planner.dart';
import 'package:dailyloop/src/reminders/reminder_service.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

/// Thứ Ba 3/11/2026, 9:00.
final now = DateTime(2026, 11, 3, 9);

void main() {
  late AppDatabase db;
  late ActivityRepository activities;

  setUp(() {
    db = memoryDatabase();
    activities = ActivityRepository(db);
  });
  tearDown(() => db.close());

  Future<int> habit(
    String name, {
    List<({int minute, ReminderKind kind})> reminders = const [],
    ScheduleRule rule = ScheduleRule.daily,
    Evaluation evaluation = Evaluation.yesNo,
  }) => activities.create(
    ActivityDraft(
      name: name,
      startDate: '2026-11-01',
      rule: rule,
      evaluation: evaluation,
      target: evaluation == Evaluation.yesNo ? null : 8,
      reminders: reminders,
    ),
  );

  const at8 = (minute: 8 * 60, kind: ReminderKind.notification);
  const at20 = (minute: 20 * 60, kind: ReminderKind.alarm);

  test('lưu tối đa 5 giờ nhắc, bỏ giờ trùng (AC-17)', () async {
    final id = await habit('Thiền', reminders: [at8, at8, at20]);
    final r = await activities.remindersOf(id);
    expect(r.map((x) => x.minuteOfDay), [480, 1200]);
    expect(r.last.kind, ReminderKind.alarm);
    expect(
      ActivityDraft(
        name: 'A',
        startDate: '2026-11-01',
        reminders: [
          for (var i = 0; i < 6; i++)
            (minute: i, kind: ReminderKind.notification),
        ],
      ).validate(),
      'reminders',
    );
  });

  test('bỏ lần đã qua giờ, lập lịch 7 ngày, sớm nhất trước (D-007)', () async {
    await habit('Thiền', reminders: [at8, at20]);
    final plan = await planReminders(db, now: now);
    // Hôm nay 8:00 đã qua nên chỉ còn 20:00; 6 ngày sau mỗi ngày 2 lần.
    expect(plan, hasLength(1 + 6 * 2));
    expect(plan.first.at, DateTime(2026, 11, 3, 20));
    expect(plan.first.kind, ReminderKind.alarm);
    expect(plan[1].at, DateTime(2026, 11, 4, 8));
    expect(plan.last.at, DateTime(2026, 11, 9, 20));
    expect(plan.map((p) => p.id).toSet(), hasLength(plan.length));
  });

  test('chỉ nhắc vào ngày đến hạn (AC-17)', () async {
    // Thứ Hai và Thứ Năm.
    await habit(
      'Gym',
      reminders: [at20],
      rule: const ScheduleRule(type: ScheduleType.weekdays, weekdays: 1 | 8),
    );
    final plan = await planReminders(db, now: now);
    expect(plan.map((p) => p.date), ['2026-11-05', '2026-11-09']);
  });

  test('đã xong hoặc bỏ qua trong ngày thì không nhắc nữa (AC-22)', () async {
    final done = await habit('Thiền', reminders: [at20]);
    final skipped = await habit('Chạy', reminders: [at20]);
    final entries = EntryRepository(db);
    await entries.toggleDone(done, '2026-11-03');
    await entries.setSkipped(skipped, '2026-11-03', true);
    final today = (await planReminders(
      db,
      now: now,
    )).where((p) => p.date == '2026-11-03').toList();
    expect(today, isEmpty);
  });

  test('Số lượng chưa đủ mục tiêu thì vẫn nhắc, không có nút Xong', () async {
    final id = await habit(
      'Nước',
      reminders: [at20],
      evaluation: Evaluation.quantity,
    );
    await EntryRepository(db).setValue(id, '2026-11-03', 3);
    final p = (await planReminders(db, now: now)).first;
    expect(p.date, '2026-11-03');
    expect(p.yesNo, isFalse);
  });

  test('việc quá hạn có giờ nhắc thì nhắc hôm nay, ghi vào ngày gốc', () async {
    final id = await activities.create(
      const ActivityDraft(
        kind: ActivityKind.task,
        name: 'Nộp thuế',
        startDate: '2026-10-31',
        rule: ScheduleRule.once,
        reminders: [at20],
      ),
    );
    final plan = await planReminders(db, now: now);
    expect(plan.single.activityId, id);
    expect(plan.single.at, DateTime(2026, 11, 3, 20));
    expect(plan.single.date, '2026-10-31');
    expect(plan.single.yesNo, isTrue);
  });

  test('giới hạn số lần nhắc', () async {
    await habit('A', reminders: [at8, at20]);
    await habit('B', reminders: [at8, at20]);
    expect(await planReminders(db, now: now, limit: 5), hasLength(5));
  });

  test('payload đọc lại được', () {
    final p = parsePayload('12|2026-11-03|alarm')!;
    expect(p.activityId, 12);
    expect(p.date, '2026-11-03');
    expect(p.kind, ReminderKind.alarm);
    expect(parsePayload('rác'), isNull);
  });

  test('đồng bộ lịch đặt kết quả vào cổng hệ điều hành', () async {
    await habit('Thiền', reminders: [at20]);
    final gateway = FakeReminderGateway();
    final sync = ReminderSync(
      db: db,
      gateway: gateway,
      clock: () => now,
      texts: () => const ReminderTexts(
        channelReminders: 'r',
        channelAlarms: 'a',
        body: '',
        done: 'd',
        snooze: 's',
        dismiss: 'x',
      ),
    );
    await sync.syncNow();
    expect(gateway.scheduled, hasLength(7));
    await sync.dispose();
  });

  test('lần hoãn chỉ giữ cho mục còn cần làm hôm nay (D-007)', () async {
    final keepId = await habit('Còn làm', reminders: [at20]);
    final doneId = await habit('Đã xong', reminders: [at20]);
    final goneId = await habit('Sẽ xóa', reminders: [at20]);
    await EntryRepository(db).toggleDone(doneId, '2026-11-03');
    await activities.delete(goneId);

    final gateway = FakeReminderGateway();
    final sync = ReminderSync(
      db: db,
      gateway: gateway,
      clock: () => now,
      texts: () => const ReminderTexts(
        channelReminders: 'r',
        channelAlarms: 'a',
        body: '',
        done: 'd',
        snooze: 's',
        dismiss: 'x',
      ),
    );
    await sync.syncNow();
    // Chỉ mục còn cần làm hôm nay được giữ lần hoãn; mục đã xong hoặc đã
    // xóa thì cổng hệ điều hành sẽ hủy lần hoãn của chúng.
    expect(gateway.live, {'$keepId|2026-11-03'});
    await sync.dispose();
  });
}
