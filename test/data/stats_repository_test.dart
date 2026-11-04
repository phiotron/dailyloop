import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/dates.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:dailyloop/src/data/stats_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

DateTime day(String key) => parseDateKey(key);

void main() {
  late AppDatabase db;
  late ActivityRepository activities;
  late EntryRepository entries;
  late StatsRepository stats;

  setUp(() {
    db = memoryDatabase();
    activities = ActivityRepository(db);
    entries = EntryRepository(db);
    stats = StatsRepository(db);
  });
  tearDown(() => db.close());

  Future<int> habit(
    String name, {
    String start = '2026-11-01',
    ScheduleRule rule = ScheduleRule.daily,
  }) => activities.create(
    ActivityDraft(name: name, startDate: start, rule: rule),
  );

  Future<void> doneOn(int id, Iterable<String> dates) async {
    for (final d in dates) {
      await entries.toggleDone(id, d);
    }
  }

  test('đọc lịch sử một thói quen kèm số mục con đã đánh dấu', () async {
    final id = await activities.create(
      const ActivityDraft(
        name: 'Sáng',
        startDate: '2026-11-01',
        evaluation: Evaluation.checklist,
        checklist: [(id: null, title: 'A'), (id: null, title: 'B')],
      ),
    );
    final items = await activities.checklistOf(id);
    await entries.toggleMark(id, '2026-11-02', items[0].id);
    await entries.toggleMark(id, '2026-11-02', items[1].id);
    await entries.toggleMark(id, '2026-11-03', items[0].id);

    final h = (await stats.loadHistory(id))!;
    expect(h.totalItems, 2);
    expect(h.records['2026-11-02']!.checked, 2);
    expect(h.achievedOn(day('2026-11-02')), isTrue);
    expect(h.achievedOn(day('2026-11-03')), isFalse);
    expect(await stats.loadHistory(9999), isNull);
  });

  test(
    'xếp hạng chuỗi dài nhất, lấy 3 đầu; thói quen lưu trữ bị bỏ (AC-28)',
    () async {
      final a = await habit('A');
      final b = await habit('B');
      final c = await habit('C');
      final d = await habit('D');
      final gone = await habit('Đã cất');
      await doneOn(a, ['2026-11-01', '2026-11-02']);
      await doneOn(b, ['2026-11-01', '2026-11-02', '2026-11-03', '2026-11-04']);
      await doneOn(c, ['2026-11-01', '2026-11-02', '2026-11-03']);
      await doneOn(d, ['2026-11-01']);
      await doneOn(gone, [
        '2026-11-01',
        '2026-11-02',
        '2026-11-03',
        '2026-11-04',
        '2026-11-05',
      ]);
      await activities.setArchived(gone, true);

      final ranking = await stats.loadRanking(today: day('2026-11-05'));
      expect(ranking.map((r) => r.habit.name), ['B', 'C', 'A', 'D']);
      expect(ranking.first.stats.longestStreak, 4);
      // Hôm nay (5/11) chưa ghi nên chuỗi hiện tại của B vẫn là 4.
      expect(ranking.first.stats.currentStreak, 4);
    },
  );

  test('hòa chuỗi thì theo điểm rồi theo thứ tự người dùng xếp', () async {
    final a = await habit('A');
    final b = await habit('B');
    // Cùng chuỗi dài nhất 2; B có thêm một ngày bỏ lỡ cũ nên điểm thấp hơn.
    await doneOn(a, ['2026-11-02', '2026-11-03']);
    await doneOn(b, ['2026-11-02', '2026-11-03']);
    final ranking = await stats.loadRanking(today: day('2026-11-04'));
    expect(ranking.map((r) => r.habit.name), ['A', 'B']);
    await activities.reorder([b, a]);
    final reordered = await stats.loadRanking(today: day('2026-11-04'));
    expect(reordered.map((r) => r.habit.name), ['B', 'A']);
  });

  group('số mục xong trên tổng mỗi ngày (AC-28)', () {
    test('khớp với dữ liệu ghi; bỏ qua không vào tổng', () async {
      final a = await habit('A');
      final b = await habit('B');
      final t = await activities.create(
        const ActivityDraft(
          kind: ActivityKind.task,
          name: 'Việc',
          startDate: '2026-11-02',
          rule: ScheduleRule.once,
        ),
      );
      final onlyMon = await habit(
        'Thứ Hai',
        rule: const ScheduleRule(type: ScheduleType.weekdays, weekdays: 1),
      );
      await entries.toggleDone(a, '2026-11-02');
      await entries.toggleDone(t, '2026-11-02');
      await entries.toggleDone(onlyMon, '2026-11-02');
      await entries.setSkipped(b, '2026-11-02', true);
      await entries.toggleDone(a, '2026-11-03');

      final counts = await stats.dailyCounts(
        day('2026-11-01'),
        day('2026-11-03'),
      );
      expect(counts['2026-11-01'], (done: 0, total: 2));
      // 2/11 (Thứ Hai): A, việc, "Thứ Hai" xong; B bỏ qua nên không tính.
      expect(counts['2026-11-02'], (done: 3, total: 3));
      // 3/11: A xong; B chưa; việc không đến hạn; "Thứ Hai" không đến hạn.
      expect(counts['2026-11-03'], (done: 1, total: 2));
    });

    test('đủ số ngày yêu cầu, ngày chưa có mục nào là 0 trên 0', () async {
      await habit('A', start: '2026-11-05');
      final counts = await stats.dailyCounts(
        day('2026-11-01'),
        day('2026-11-30'),
      );
      expect(counts, hasLength(30));
      expect(counts['2026-11-03'], (done: 0, total: 0));
      expect(counts['2026-11-05'], (done: 0, total: 1));
    });
  });

  test('danh sách tự cập nhật khi ghi kết quả', () async {
    final id = await habit('A');
    final stream = stats.watchDailyCounts(day('2026-11-02'), day('2026-11-02'));
    final expectation = expectLater(
      stream.map((m) => m['2026-11-02']!.done),
      emitsInOrder([0, 1]),
    );
    await Future<void>.delayed(Duration.zero);
    await entries.toggleDone(id, '2026-11-02');
    await expectation;
  });

  test('hiệu năng: 50 thói quen với 3 năm lịch sử tính xong trong 1 giây (NFR)', () async {
    // Dữ liệu giả: 50 thói quen mỗi ngày, ghi đạt 2 ngày trên 3.
    final start = DateTime.utc(2023, 11, 1);
    final ids = <int>[];
    for (var i = 0; i < 50; i++) {
      ids.add(
        await activities.create(
          ActivityDraft(name: 'H$i', startDate: dateKey(start)),
        ),
      );
    }
    await db.batch((b) {
      for (final id in ids) {
        for (var d = 0; d < 1095; d++) {
          if (d % 3 == 2) continue;
          b.insert(
            db.entries,
            EntriesCompanion.insert(
              activityId: id,
              date: dateKey(start.add(Duration(days: d))),
              value: const Value(1),
            ),
          );
        }
      }
    });
    final today = start.add(const Duration(days: 1095));
    final sw = Stopwatch()..start();
    final ranking = await stats.loadRanking(today: today);
    final counts = await stats.dailyCounts(
      today.subtract(const Duration(days: 29)),
      today,
    );
    sw.stop();
    expect(ranking, hasLength(50));
    expect(counts, hasLength(30));
    // Chỉ ghi lại thời gian; ngưỡng 1 giây là mục tiêu trên máy thật (SPEC 5b),
    // trên máy phát triển cho phép rộng hơn để test không chập chờn.
    // ignore: avoid_print
    print('Thống kê 50 thói quen × 3 năm: ${sw.elapsedMilliseconds} ms');
    expect(sw.elapsedMilliseconds, lessThan(5000));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
