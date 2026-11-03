import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/category_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/dates.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

const water = ActivityDraft(
  name: '  Uống nước ',
  categoryId: 1,
  evaluation: Evaluation.quantity,
  target: 8,
  condition: TargetCondition.atLeast,
  unit: 'ly',
  startDate: '2026-11-01',
);

void main() {
  late AppDatabase db;
  late ActivityRepository repo;

  setUp(() {
    db = memoryDatabase();
    repo = ActivityRepository(db);
  });
  tearDown(() => db.close());

  group('kiểm tra nhập liệu (AC-01, AC-02)', () {
    test('tên trống hoặc quá 60 ký tự', () {
      expect(
        const ActivityDraft(name: '  ', startDate: '2026-11-01').validate(),
        'name',
      );
      expect(
        ActivityDraft(name: 'a' * 61, startDate: '2026-11-01').validate(),
        'name',
      );
    });

    test('mô tả quá 300 ký tự', () {
      expect(
        ActivityDraft(
          name: 'Đọc sách',
          description: 'a' * 301,
          startDate: '2026-11-01',
        ).validate(),
        'description',
      );
    });

    test('Số lượng và Thời gian cần mục tiêu dương', () {
      expect(
        const ActivityDraft(
          name: 'Chạy',
          evaluation: Evaluation.duration,
          startDate: '2026-11-01',
        ).validate(),
        'target',
      );
      expect(
        const ActivityDraft(
          name: 'Chạy',
          evaluation: Evaluation.quantity,
          target: 0,
          startDate: '2026-11-01',
        ).validate(),
        'target',
      );
    });

    test('Danh sách con: 1 tới 20 mục, N không quá số mục', () {
      expect(
        const ActivityDraft(
          name: 'Sáng',
          evaluation: Evaluation.checklist,
          startDate: '2026-11-01',
        ).validate(),
        'checklist',
      );
      expect(
        ActivityDraft(
          name: 'Sáng',
          evaluation: Evaluation.checklist,
          checklist: [for (var i = 0; i < 21; i++) (id: null, title: '$i')],
          startDate: '2026-11-01',
        ).validate(),
        'checklist',
      );
      expect(
        const ActivityDraft(
          name: 'Sáng',
          evaluation: Evaluation.checklist,
          checklist: [(id: null, title: 'A'), (id: null, title: 'B')],
          checklistMinDone: 3,
          startDate: '2026-11-01',
        ).validate(),
        'checklistMin',
      );
    });

    test('ngày kết thúc trước ngày bắt đầu', () {
      expect(
        const ActivityDraft(
          name: 'A',
          startDate: '2026-11-05',
          endDate: '2026-11-04',
        ).validate(),
        'endDate',
      );
    });

    test('hợp lệ', () => expect(water.validate(), isNull));
  });

  test('tạo thói quen: cắt khoảng trắng, có lịch, xếp cuối', () async {
    final a = await repo.create(water);
    final b = await repo.create(
      const ActivityDraft(name: 'Đọc sách', startDate: '2026-11-01'),
    );
    final habit = (await repo.find(a))!;
    expect(habit.name, 'Uống nước');
    expect(habit.unit, 'ly');
    expect(habit.target, 8);
    expect((await repo.find(b))!.sortOrder, habit.sortOrder + 1);
    expect(await repo.currentRule(a), ScheduleRule.daily);
  });

  test('mục tiêu bị xóa khi đổi sang kiểu Có/Không', () async {
    final id = await repo.create(water);
    await repo.update(
      id,
      const ActivityDraft(name: 'Uống nước', startDate: '2026-11-01'),
      today: DateTime(2026, 11, 3),
    );
    final a = (await repo.find(id))!;
    expect(a.evaluation, Evaluation.yesNo);
    expect(a.target, isNull);
    expect(a.unit, isNull);
  });

  test(
    'sửa không làm mất kết quả cũ; lịch mới chỉ từ hôm nay (AC-04)',
    () async {
      final id = await repo.create(water);
      await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              activityId: id,
              date: '2026-11-02',
              value: const Value(8),
            ),
          );
      const everyOther = ScheduleRule(
        type: ScheduleType.everyNDays,
        interval: 2,
      );
      await repo.update(
        id,
        const ActivityDraft(
          name: 'Uống nước',
          evaluation: Evaluation.quantity,
          target: 6,
          startDate: '2026-11-01',
          rule: everyOther,
        ),
        today: DateTime(2026, 11, 5),
      );
      expect(await db.select(db.entries).get(), hasLength(1));

      final c = await repo.dueCalculator((await repo.find(id))!);
      expect(
        c
            .dueDates(parseDateKey('2026-11-01'), parseDateKey('2026-11-09'))
            .map(dateKey),
        [
          '2026-11-01',
          '2026-11-02',
          '2026-11-03',
          '2026-11-04',
          '2026-11-05',
          '2026-11-07',
          '2026-11-09',
        ],
      );

      // Sửa lại lần nữa trong cùng ngày thì thay lịch của hôm nay, không chồng.
      await repo.update(
        id,
        const ActivityDraft(name: 'Uống nước', startDate: '2026-11-01'),
        today: DateTime(2026, 11, 5),
      );
      expect(await repo.schedulesOf(id), hasLength(2));
      expect(await repo.currentRule(id), ScheduleRule.daily);
    },
  );

  test('chưa tới ngày bắt đầu thì đổi lịch thay hẳn lịch cũ', () async {
    final id = await repo.create(
      const ActivityDraft(name: 'Gym', startDate: '2026-11-10'),
    );
    await repo.update(
      id,
      const ActivityDraft(
        name: 'Gym',
        startDate: '2026-11-10',
        rule: ScheduleRule(type: ScheduleType.weekdays, weekdays: 1),
      ),
      today: DateTime(2026, 11, 3),
    );
    final s = await repo.schedulesOf(id);
    expect(s, hasLength(1));
    expect(s.single.effectiveFrom, '2026-11-10');
  });

  test('danh sách con: giữ id mục cũ, xóa mục bị bỏ', () async {
    final id = await repo.create(
      const ActivityDraft(
        name: 'Sáng',
        evaluation: Evaluation.checklist,
        checklist: [(id: null, title: 'Uống nước'), (id: null, title: 'Tập')],
        startDate: '2026-11-01',
      ),
    );
    final items = await repo.checklistOf(id);
    await repo.update(
      id,
      ActivityDraft(
        name: 'Sáng',
        evaluation: Evaluation.checklist,
        checklist: [
          (id: items[1].id, title: 'Tập 15 phút'),
          (id: null, title: 'Thiền'),
        ],
        startDate: '2026-11-01',
      ),
      today: DateTime(2026, 11, 3),
    );
    final after = await repo.checklistOf(id);
    expect(after.map((c) => c.title), ['Tập 15 phút', 'Thiền']);
    expect(after.first.id, items[1].id);
  });

  test('lưu trữ: ẩn khỏi danh sách, còn trong "Đã lưu trữ" (AC-05)', () async {
    final id = await repo.create(water);
    await repo.setArchived(id, true);
    expect(await repo.watchHabits().first, isEmpty);
    expect((await repo.watchHabits(archived: true).first).single.id, id);
    await repo.setArchived(id, false);
    expect(await repo.watchHabits().first, hasLength(1));
  });

  test('xóa rồi hoàn tác trả lại đủ lịch sử, cùng id (AC-05)', () async {
    final id = await repo.create(
      const ActivityDraft(
        name: 'Sáng',
        evaluation: Evaluation.checklist,
        checklist: [(id: null, title: 'A')],
        startDate: '2026-11-01',
      ),
    );
    final item = (await repo.checklistOf(id)).single;
    final entryId = await db
        .into(db.entries)
        .insert(EntriesCompanion.insert(activityId: id, date: '2026-11-02'));
    await db
        .into(db.checklistMarks)
        .insert(
          ChecklistMarksCompanion.insert(entryId: entryId, itemId: item.id),
        );
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            activityId: id,
            minuteOfDay: 420,
            kind: ReminderKind.notification,
          ),
        );

    final snap = await repo.delete(id);
    expect(await repo.find(id), isNull);
    expect(await db.select(db.checklistMarks).get(), isEmpty);

    await repo.restore(snap);
    expect((await repo.find(id))!.name, 'Sáng');
    expect(await repo.checklistOf(id), hasLength(1));
    expect(await db.select(db.entries).get(), hasLength(1));
    expect(await db.select(db.checklistMarks).get(), hasLength(1));
    expect(await db.select(db.reminders).get(), hasLength(1));
    expect(await repo.schedulesOf(id), hasLength(1));
  });

  test('sắp xếp lại và lọc theo danh mục (AC-06, AC-32)', () async {
    final a = await repo.create(water);
    final b = await repo.create(
      const ActivityDraft(name: 'Học', categoryId: 3, startDate: '2026-11-01'),
    );
    await repo.reorder([b, a]);
    expect((await repo.watchHabits().first).map((x) => x.id), [b, a]);
    expect((await repo.watchHabits(categoryId: 3).first).map((x) => x.id), [b]);
  });

  group('danh mục (AC-31)', () {
    test('thêm, sửa giữ tên mặc định khi không đổi tên', () async {
      final cats = CategoryRepository(db);
      final id = await cats.add(name: ' Đọc ', icon: 'menu_book', color: 1);
      await cats.edit(1, icon: 'spa', color: 2);
      final all = await cats.watch().first;
      expect(all.last.id, id);
      expect(all.last.name, 'Đọc');
      expect(all.first.nameKey, 'health');
      expect(all.first.name, isNull);
      expect(all.first.icon, 'spa');
    });

    test('xóa danh mục đang dùng thì chuyển mục sang danh mục khác', () async {
      final cats = CategoryRepository(db);
      final id = await repo.create(water);
      expect(await cats.usageCount(1), 1);
      await cats.delete(1, moveTo: 2);
      expect((await repo.find(id))!.categoryId, 2);
      expect((await cats.watch().first).any((c) => c.id == 1), isFalse);
    });
  });
}
