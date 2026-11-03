import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/day_repository.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

final today = DateTime(2026, 11, 3); // Thứ Ba

void main() {
  late AppDatabase db;
  late ActivityRepository activities;
  late EntryRepository entries;
  late DayRepository days;

  setUp(() {
    db = memoryDatabase();
    activities = ActivityRepository(db);
    entries = EntryRepository(db);
    days = DayRepository(db);
  });
  tearDown(() => db.close());

  Future<int> habit(
    String name, {
    ScheduleRule rule = ScheduleRule.daily,
    Evaluation evaluation = Evaluation.yesNo,
    double? target,
    TargetCondition? condition,
    List<String> checklist = const [],
    int? minDone,
    Priority priority = Priority.normal,
    String start = '2026-11-01',
  }) => activities.create(
    ActivityDraft(
      name: name,
      rule: rule,
      evaluation: evaluation,
      target: target,
      condition: condition,
      checklist: [for (final c in checklist) (id: null, title: c)],
      checklistMinDone: minDone,
      priority: priority,
      startDate: start,
    ),
  );

  Future<int> task(
    String name, {
    String? date,
    int? time,
    ScheduleRule rule = ScheduleRule.once,
    Priority priority = Priority.normal,
  }) => activities.create(
    ActivityDraft(
      kind: ActivityKind.task,
      name: name,
      startDate: date,
      timeOfDay: time,
      rule: rule,
      priority: priority,
    ),
  );

  Future<List<String>> names(DateTime day) async => (await days.loadDay(
    day,
    today: today,
  )).map((i) => i.activity.name).toList();

  group('màn Hôm nay (AC-07)', () {
    test('chỉ mục đến hạn trong ngày; thói quen lưu trữ bị ẩn', () async {
      await habit('Mỗi ngày');
      await habit(
        'Thứ Hai',
        rule: const ScheduleRule(type: ScheduleType.weekdays, weekdays: 1),
      );
      final archived = await habit('Đã cất');
      await activities.setArchived(archived, true);
      await task('Đi chợ', date: '2026-11-03');
      await task('Ngày mai', date: '2026-11-04');
      await task('Chưa xếp lịch');

      expect(await names(today), unorderedEquals(['Mỗi ngày', 'Đi chợ']));
      expect(
        await names(DateTime(2026, 11, 2)),
        unorderedEquals(['Mỗi ngày', 'Thứ Hai']),
      );
    });

    test('theo giờ, rồi ưu tiên; mục xong xuống dưới', () async {
      await habit('Thường');
      await habit('Cao', priority: Priority.high);
      await task('9 giờ', date: '2026-11-03', time: 540);
      final early = await task('7 giờ', date: '2026-11-03', time: 420);
      expect(await names(today), ['7 giờ', '9 giờ', 'Cao', 'Thường']);

      await entries.toggleDone(early, '2026-11-03');
      expect(await names(today), ['9 giờ', 'Cao', 'Thường', '7 giờ']);
    });
  });

  group('ghi kết quả (AC-09, AC-10, AC-12)', () {
    test('Có/Không: chạm để xong, chạm lại để bỏ', () async {
      final id = await habit('Thiền');
      await entries.toggleDone(id, '2026-11-03');
      expect((await days.loadDay(today, today: today)).single.achieved, isTrue);
      await entries.toggleDone(id, '2026-11-03');
      expect(
        (await days.loadDay(today, today: today)).single.achieved,
        isFalse,
      );
    });

    test('Số lượng: +1 dồn tới mục tiêu', () async {
      final id = await habit(
        'Nước',
        evaluation: Evaluation.quantity,
        target: 3,
        condition: TargetCondition.atLeast,
      );
      for (var i = 0; i < 2; i++) {
        await entries.addValue(id, '2026-11-03', 1);
      }
      var item = (await days.loadDay(today, today: today)).single;
      expect(item.value, 2);
      expect(item.achieved, isFalse);
      await entries.addValue(id, '2026-11-03', 1);
      item = (await days.loadDay(today, today: today)).single;
      expect(item.achieved, isTrue);
    });

    test('Thời gian: nhập số phút', () async {
      final id = await habit(
        'Đọc',
        evaluation: Evaluation.duration,
        target: 30,
        condition: TargetCondition.atLeast,
      );
      await entries.setValue(id, '2026-11-03', 45);
      expect((await days.loadDay(today, today: today)).single.achieved, isTrue);
    });

    test('Danh sách con: đạt khi xong đủ N mục', () async {
      final id = await habit(
        'Sáng',
        evaluation: Evaluation.checklist,
        checklist: ['A', 'B', 'C'],
        minDone: 2,
      );
      final items = await activities.checklistOf(id);
      await entries.toggleMark(id, '2026-11-03', items[0].id);
      var item = (await days.loadDay(today, today: today)).single;
      expect(item.marked, {items[0].id});
      expect(item.achieved, isFalse);
      await entries.toggleMark(id, '2026-11-03', items[2].id);
      item = (await days.loadDay(today, today: today)).single;
      expect(item.achieved, isTrue);
      await entries.toggleMark(id, '2026-11-03', items[2].id);
      item = (await days.loadDay(today, today: today)).single;
      expect(item.marked, {items[0].id});
    });

    test(
      'bỏ qua hôm nay: không đạt nhưng đã xử lý, ghi giá trị thì bỏ dấu',
      () async {
        final id = await habit('Chạy');
        await entries.setSkipped(id, '2026-11-03', true);
        var item = (await days.loadDay(today, today: today)).single;
        expect(item.skipped, isTrue);
        expect(item.achieved, isFalse);
        expect(item.settled, isTrue);
        await entries.toggleDone(id, '2026-11-03');
        item = (await days.loadDay(today, today: today)).single;
        expect(item.skipped, isFalse);
        expect(item.achieved, isTrue);
      },
    );

    test('ngày đã qua ghi được riêng, không lẫn với hôm nay (AC-08)', () async {
      final id = await habit('Thiền');
      await entries.toggleDone(id, '2026-11-02');
      expect(
        (await days.loadDay(
          DateTime(2026, 11, 2),
          today: today,
        )).single.achieved,
        isTrue,
      );
      expect(
        (await days.loadDay(today, today: today)).single.achieved,
        isFalse,
      );
    });
  });

  group('việc cần làm (AC-13 tới AC-16)', () {
    test('việc quá hạn hiện đầu màn Hôm nay kèm số ngày (AC-15)', () async {
      await habit('Thiền');
      final late = await task('Nộp thuế', date: '2026-10-31');
      final day = await days.loadDay(today, today: today);
      expect(day.first.activity.name, 'Nộp thuế');
      expect(day.first.overdueDays, 3);
      expect(day.first.date, '2026-10-31');

      // Đánh xong thì ghi vào ngày gốc và biến khỏi danh sách.
      await entries.toggleDone(late, '2026-10-31');
      expect(await names(today), ['Thiền']);
      // Ngày khác hôm nay không hiện việc quá hạn.
      expect(await names(DateTime(2026, 11, 2)), ['Thiền']);
    });

    test('việc lặp lại đến hạn theo lịch (AC-14)', () async {
      await task(
        'Đổ rác',
        date: '2026-11-01',
        rule: const ScheduleRule(type: ScheduleType.everyNDays, interval: 2),
      );
      expect(await names(today), ['Đổ rác']);
      expect(await names(DateTime(2026, 11, 4)), isEmpty);
    });

    test('bộ lọc màn Việc (AC-16)', () async {
      await task('Hôm nay', date: '2026-11-03');
      await task('Ngày mai', date: '2026-11-04');
      await task('Hôm qua', date: '2026-11-02');
      final undated = await task('Chưa xếp');
      final done = await task('Xong rồi', date: '2026-11-01');
      await entries.toggleDone(done, '2026-11-01');
      await entries.toggleDone(undated, '2026-11-03');
      await task('Chưa xếp 2');

      Future<List<String>> list(TaskFilter f) async => (await days.loadTasks(
        f,
        today: today,
      )).map((i) => i.activity.name).toList();

      expect(await list(TaskFilter.today), ['Hôm nay']);
      expect(await list(TaskFilter.upcoming), ['Ngày mai']);
      expect(await list(TaskFilter.overdue), ['Hôm qua']);
      expect(await list(TaskFilter.unscheduled), ['Chưa xếp 2']);
      expect(
        await list(TaskFilter.done),
        unorderedEquals(['Xong rồi', 'Chưa xếp']),
      );
    });

    test('việc lặp lại cần ngày bắt đầu; giờ cần có ngày', () {
      expect(
        const ActivityDraft(
          kind: ActivityKind.task,
          name: 'A',
          rule: ScheduleRule.daily,
        ).validate(),
        'startDate',
      );
      expect(
        const ActivityDraft(
          kind: ActivityKind.task,
          name: 'A',
          rule: ScheduleRule.once,
          timeOfDay: 600,
        ).validate(),
        'time',
      );
      expect(
        const ActivityDraft(
          kind: ActivityKind.task,
          name: 'A',
          rule: ScheduleRule.once,
        ).validate(),
        isNull,
      );
    });

    test('mục con của việc được lưu dù kiểu là Có/Không', () async {
      final id = await activities.create(
        const ActivityDraft(
          kind: ActivityKind.task,
          name: 'Dọn nhà',
          rule: ScheduleRule.once,
          checklist: [(id: null, title: 'Lau'), (id: null, title: 'Quét')],
        ),
      );
      expect(await activities.checklistOf(id), hasLength(2));
    });
  });

  test('danh sách tự cập nhật khi ghi kết quả', () async {
    final id = await habit('Thiền');
    final stream = days.watchDay(today, today: today);
    final expectation = expectLater(
      stream.map((l) => l.single.achieved),
      emitsInOrder([false, true]),
    );
    await Future<void>.delayed(Duration.zero);
    await entries.toggleDone(id, '2026-11-03');
    await expectation;
  });

  test('ghi giá trị âm thì lưu 0', () async {
    final id = await habit('Nước', evaluation: Evaluation.quantity, target: 2);
    await entries.setValue(id, '2026-11-03', -3);
    final e = await (db.select(
      db.entries,
    )..where((e) => e.activityId.equals(id))).getSingle();
    expect(e.value, 0);
  });
}
