import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/dates.dart';
import 'package:dailyloop/src/data/habit_stats.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

DateTime day(String key) => parseDateKey(key);

/// Ghi nhận Có/Không đạt vào các ngày [keys], ngày trong [skipped] là bỏ qua.
Map<String, DayRecord> done(
  Iterable<String> keys, {
  Iterable<String> skipped = const [],
}) => {
  for (final k in keys) k: const DayRecord(value: 1),
  for (final k in skipped) k: const DayRecord(skipped: true),
};

void main() {
  late AppDatabase db;
  late ActivityRepository repo;

  setUp(() {
    db = memoryDatabase();
    repo = ActivityRepository(db);
  });
  tearDown(() => db.close());

  Future<HabitHistory> history(
    ActivityDraft draft,
    Map<String, DayRecord> records, {
    int totalItems = 0,
  }) async {
    final id = await repo.create(draft);
    final a = (await repo.find(id))!;
    return HabitHistory(
      habit: a,
      calculator: await repo.dueCalculator(a),
      records: records,
      totalItems: totalItems,
    );
  }

  const daily = ActivityDraft(name: 'Thiền', startDate: '2026-11-01');

  group('chuỗi ngày (AC-23)', () {
    test(
      'tính tới hôm qua khi hôm nay chưa xong, cộng hôm nay khi đã xong',
      () async {
        final records = done([
          '2026-11-01',
          '2026-11-02',
          '2026-11-04',
          '2026-11-05',
        ]);
        final h = await history(daily, records);
        final s = computeStats(h, today: day('2026-11-06'));
        expect(s.currentStreak, 2);
        expect(s.longestStreak, 2);

        final h2 = await history(
          daily,
          done([
            '2026-11-01',
            '2026-11-02',
            '2026-11-04',
            '2026-11-05',
            '2026-11-06',
          ]),
        );
        final s2 = computeStats(h2, today: day('2026-11-06'));
        expect(s2.currentStreak, 3);
        expect(s2.longestStreak, 3);
      },
    );

    test('ngày bỏ qua không làm đứt chuỗi', () async {
      final h = await history(
        daily,
        done(['2026-11-01', '2026-11-03'], skipped: ['2026-11-02']),
      );
      final s = computeStats(h, today: day('2026-11-03'));
      expect(s.currentStreak, 2);
    });

    test('ngày không đến hạn không làm đứt chuỗi', () async {
      // Thứ Hai, Tư, Sáu (bit 0, 2, 4).
      final h = await history(
        const ActivityDraft(
          name: 'Gym',
          startDate: '2026-11-02',
          rule: ScheduleRule(type: ScheduleType.weekdays, weekdays: 1 | 4 | 16),
        ),
        done(['2026-11-02', '2026-11-04', '2026-11-06']),
      );
      final s = computeStats(h, today: day('2026-11-06'));
      expect(s.currentStreak, 3);
    });

    test(
      'bỏ lỡ một ngày đến hạn thì chuỗi hiện tại về 0, chuỗi dài nhất giữ',
      () async {
        final h = await history(
          daily,
          done(['2026-11-01', '2026-11-02', '2026-11-03']),
        );
        final s = computeStats(h, today: day('2026-11-06'));
        expect(s.currentStreak, 0);
        expect(s.longestStreak, 3);
      },
    );

    test('mục tiêu số lượng: chỉ ngày đủ mục tiêu mới đạt', () async {
      final h = await history(
        const ActivityDraft(
          name: 'Nước',
          startDate: '2026-11-01',
          evaluation: Evaluation.quantity,
          target: 8,
          condition: TargetCondition.atLeast,
        ),
        {
          '2026-11-01': const DayRecord(value: 8),
          '2026-11-02': const DayRecord(value: 7),
          '2026-11-03': const DayRecord(value: 9),
        },
      );
      final s = computeStats(h, today: day('2026-11-04'));
      expect(s.longestStreak, 1);
      expect(s.currentStreak, 1);
    });

    test(
      'ngày chưa ghi với mục tiêu "nhiều nhất" tính là đạt, như màn Hôm nay',
      () async {
        final h = await history(
          const ActivityDraft(
            name: 'Cà phê',
            startDate: '2026-11-01',
            evaluation: Evaluation.quantity,
            target: 2,
            condition: TargetCondition.atMost,
          ),
          {'2026-11-02': const DayRecord(value: 3)},
        );
        expect(h.achievedOn(day('2026-11-01')), isTrue);
        expect(h.achievedOn(day('2026-11-02')), isFalse);
      },
    );

    test('Danh sách con: đạt khi đủ số mục đánh dấu', () async {
      final h = await history(
        const ActivityDraft(
          name: 'Sáng',
          startDate: '2026-11-01',
          evaluation: Evaluation.checklist,
          checklist: [(id: null, title: 'A'), (id: null, title: 'B')],
          checklistMinDone: 2,
        ),
        {
          '2026-11-01': const DayRecord(checked: 2),
          '2026-11-02': const DayRecord(checked: 1),
        },
        totalItems: 2,
      );
      expect(h.achievedOn(day('2026-11-01')), isTrue);
      expect(h.achievedOn(day('2026-11-02')), isFalse);
    });

    test('K lần mỗi tuần: chuỗi tính theo tuần đủ K lần', () async {
      const draft = ActivityDraft(
        name: 'Chạy',
        startDate: '2026-11-02', // Thứ Hai
        rule: ScheduleRule(
          type: ScheduleType.timesPerPeriod,
          timesPerPeriod: 3,
          period: SchedulePeriod.week,
        ),
      );
      // Tuần 2–8/11 đủ 3 lần, tuần 9–15/11 đủ 3 lần, tuần 16–22/11 mới 1 lần.
      final h = await history(
        draft,
        done([
          '2026-11-02',
          '2026-11-03',
          '2026-11-05',
          '2026-11-09',
          '2026-11-11',
          '2026-11-13',
          '2026-11-16',
        ]),
      );
      final s = computeStats(h, today: day('2026-11-18'));
      expect(s.streakUnit, StreakUnit.weeks);
      expect(s.currentStreak, 2); // tuần hiện tại chưa đủ nhưng chưa kết thúc
      expect(s.longestStreak, 2);

      // Một tuần không đủ K thì đứt chuỗi.
      final broken = await history(
        draft,
        done([
          '2026-11-02',
          '2026-11-03',
          '2026-11-05',
          '2026-11-09',
          '2026-11-11',
        ]),
      );
      final sb = computeStats(broken, today: day('2026-11-18'));
      expect(sb.currentStreak, 0);
      expect(sb.longestStreak, 1);
    });

    test(
      'K lần mỗi tuần: kỳ đầu bắt đầu giữa tuần không bị tính là thất bại',
      () async {
        final h = await history(
          const ActivityDraft(
            name: 'Chạy',
            startDate: '2026-11-04', // Thứ Tư
            rule: ScheduleRule(
              type: ScheduleType.timesPerPeriod,
              timesPerPeriod: 3,
              period: SchedulePeriod.week,
            ),
          ),
          done(['2026-11-04', '2026-11-10', '2026-11-11', '2026-11-12']),
        );
        final s = computeStats(h, today: day('2026-11-14'));
        expect(s.units.first.result, UnitResult.skipped);
        expect(s.currentStreak, 1);
      },
    );

    test('K lần mỗi tháng', () async {
      final h = await history(
        const ActivityDraft(
          name: 'Họp',
          startDate: '2026-10-01',
          rule: ScheduleRule(
            type: ScheduleType.timesPerPeriod,
            timesPerPeriod: 2,
            period: SchedulePeriod.month,
          ),
        ),
        done(['2026-10-05', '2026-10-20', '2026-11-03', '2026-11-04']),
      );
      final s = computeStats(h, today: day('2026-11-10'));
      expect(s.streakUnit, StreakUnit.months);
      expect(s.currentStreak, 2);
    });

    test('thói quen đã kết thúc không tính ngày sau ngày kết thúc', () async {
      final h = await history(
        const ActivityDraft(
          name: 'Thử',
          startDate: '2026-11-01',
          endDate: '2026-11-03',
        ),
        done(['2026-11-01', '2026-11-02', '2026-11-03']),
      );
      final s = computeStats(h, today: day('2026-11-20'));
      expect(s.currentStreak, 3);
      expect(s.rateAll, 1);
    });
  });

  group('tỉ lệ thành công (AC-24)', () {
    test('7 ngày, 30 ngày, từ đầu; bỏ qua và hôm nay chưa ghi không tính', () async {
      // 1–5 đạt, 6–7 bỏ lỡ, 8–9 đạt, 10 là hôm nay chưa ghi.
      final h = await history(
        daily,
        done([
          '2026-11-01',
          '2026-11-02',
          '2026-11-03',
          '2026-11-04',
          '2026-11-05',
          '2026-11-08',
          '2026-11-09',
        ]),
      );
      final s = computeStats(h, today: day('2026-11-10'));
      expect(s.rateAll, closeTo(7 / 9, 1e-9));
      expect(s.rate30, closeTo(7 / 9, 1e-9));
      // 7 ngày gần nhất: 4–9/11 (hôm nay chưa ghi): đạt 4, 5, 8, 9; bỏ lỡ 6, 7.
      expect(s.rate7, closeTo(4 / 6, 1e-9));
    });

    test('hôm nay đã đạt thì được tính', () async {
      final h = await history(daily, done(['2026-11-01', '2026-11-02']));
      final s = computeStats(h, today: day('2026-11-02'));
      expect(s.rateAll, 1);
    });

    test('ngày bỏ qua không vào mẫu số', () async {
      final h = await history(
        daily,
        done(['2026-11-01'], skipped: ['2026-11-02']),
      );
      final s = computeStats(h, today: day('2026-11-03'));
      expect(s.rateAll, 1);
    });

    test('chưa có ngày nào đến hạn đã qua thì không có tỉ lệ', () async {
      final h = await history(daily, const {});
      final s = computeStats(h, today: day('2026-11-01'));
      expect(s.rateAll, isNull);
      expect(s.rate7, isNull);
    });
  });

  group('điểm thói quen (AC-25)', () {
    test('toàn đạt là 100, toàn bỏ lỡ là 0, chưa có dữ liệu là 0', () async {
      final all = await history(
        daily,
        done([
          for (var d = 1; d <= 10; d++)
            '2026-11-${d.toString().padLeft(2, '0')}',
        ]),
      );
      expect(computeStats(all, today: day('2026-11-11')).score, 100);

      final none = await history(daily, const {});
      expect(computeStats(none, today: day('2026-11-11')).score, 0);
      expect(computeStats(none, today: day('2026-11-01')).score, 0);
    });

    test('lần đạt gần đây nặng hơn lần đạt cũ', () async {
      // Cũ nhất → mới nhất: bỏ lỡ 1–3, đạt 4–6.
      final recentGood = await history(
        daily,
        done(['2026-11-04', '2026-11-05', '2026-11-06']),
      );
      // Đạt 1–3, bỏ lỡ 4–6.
      final recentBad = await history(
        daily,
        done(['2026-11-01', '2026-11-02', '2026-11-03']),
      );
      final good = computeStats(recentGood, today: day('2026-11-07')).score;
      final bad = computeStats(recentBad, today: day('2026-11-07')).score;
      // Trọng số 0,95 mỗi bước: 100·2,8525/5,2982 ≈ 54 và 100·2,4457/5,2982 ≈ 46.
      expect(good, 54);
      expect(bad, 46);
    });

    test('cùng dữ liệu luôn ra cùng điểm', () async {
      final h = await history(
        daily,
        done(['2026-11-01', '2026-11-03', '2026-11-04']),
      );
      final a = computeStats(h, today: day('2026-11-08')).score;
      final b = computeStats(h, today: day('2026-11-08')).score;
      expect(a, b);
    });

    test('chỉ xét 60 đơn vị gần nhất', () async {
      // 100 ngày: 40 ngày đầu bỏ lỡ, 60 ngày sau đạt hết → điểm 100.
      final start = DateTime.utc(2026, 1, 1);
      final keys = [
        for (var i = 40; i < 100; i++) dateKey(start.add(Duration(days: i))),
      ];
      final h = await history(
        const ActivityDraft(name: 'Dài', startDate: '2026-01-01'),
        done(keys),
      );
      final s = computeStats(h, today: start.add(const Duration(days: 100)));
      expect(s.score, 100);
    });
  });

  group('trạng thái ngày trên lịch (AC-26)', () {
    test(
      'đạt, chưa đạt, bỏ qua, không đến hạn, tương lai, hôm nay chưa xong',
      () async {
        final h = await history(
          const ActivityDraft(
            name: 'Gym',
            startDate: '2026-11-02',
            // Thứ Hai, Tư, Sáu.
            rule: ScheduleRule(
              type: ScheduleType.weekdays,
              weekdays: 1 | 4 | 16,
            ),
          ),
          done(['2026-11-02'], skipped: ['2026-11-04']),
        );
        final today = day('2026-11-06'); // Thứ Sáu
        DayStatus at(String k) => dayStatus(h, day(k), today);
        expect(at('2026-11-02'), DayStatus.achieved);
        expect(at('2026-11-03'), DayStatus.notDue); // Thứ Ba
        expect(at('2026-11-04'), DayStatus.skipped);
        expect(at('2026-11-06'), DayStatus.pending);
        expect(at('2026-11-09'), DayStatus.future);
        expect(at('2026-10-30'), DayStatus.notDue); // trước ngày bắt đầu
      },
    );

    test('đến hạn đã qua mà chưa ghi là chưa đạt; ghi vào ngày không đến hạn vẫn là đạt', () async {
      final h = await history(
        const ActivityDraft(
          name: 'Gym',
          startDate: '2026-11-02',
          rule: ScheduleRule(type: ScheduleType.weekdays, weekdays: 1),
        ),
        done(['2026-11-03']),
      );
      final today = day('2026-11-10');
      expect(dayStatus(h, day('2026-11-09'), today), DayStatus.missed);
      expect(dayStatus(h, day('2026-11-03'), today), DayStatus.achieved);
    });

    test(
      'K lần mỗi tuần: ngày chưa chọn là không đến hạn, không phải chưa đạt',
      () async {
        final h = await history(
          const ActivityDraft(
            name: 'Chạy',
            startDate: '2026-11-02',
            rule: ScheduleRule(
              type: ScheduleType.timesPerPeriod,
              timesPerPeriod: 3,
              period: SchedulePeriod.week,
            ),
          ),
          done(['2026-11-03']),
        );
        final today = day('2026-11-10');
        expect(dayStatus(h, day('2026-11-03'), today), DayStatus.achieved);
        expect(dayStatus(h, day('2026-11-04'), today), DayStatus.notDue);
      },
    );
  });

  group('dữ liệu biểu đồ (AC-27)', () {
    test('theo ngày: 30 ngày kết thúc hôm nay, ngày bỏ qua là 0', () async {
      final h = await history(
        const ActivityDraft(
          name: 'Nước',
          startDate: '2026-10-01',
          evaluation: Evaluation.quantity,
          target: 8,
        ),
        {
          '2026-11-09': const DayRecord(value: 6),
          '2026-11-10': const DayRecord(value: 8),
          '2026-11-08': const DayRecord(value: 5, skipped: true),
        },
      );
      final v = valuesByDay(h, day('2026-11-10'));
      expect(v, hasLength(30));
      expect(dateKey(v.first.date), '2026-10-12');
      expect(v.last.value, 8);
      expect(v[28].value, 6);
      expect(v[27].value, 0);
    });

    test('theo tuần: tổng giá trị và mục tiêu nhân số ngày đến hạn', () async {
      final h = await history(
        const ActivityDraft(
          name: 'Nước',
          startDate: '2026-10-01',
          evaluation: Evaluation.quantity,
          target: 8,
        ),
        {
          '2026-11-02': const DayRecord(value: 8),
          '2026-11-04': const DayRecord(value: 4),
          '2026-11-09': const DayRecord(value: 2),
        },
      );
      final w = valuesByWeek(h, day('2026-11-10'), weeks: 2);
      expect(w, hasLength(2));
      expect(dateKey(w[0].start), '2026-11-02');
      expect(w[0].value, 12);
      expect(w[0].target, 56);
      expect(dateKey(w[1].start), '2026-11-09');
      expect(w[1].value, 2);
    });

    test(
      'theo tuần: kiểu K lần mỗi tuần thì mục tiêu là mục tiêu nhân K',
      () async {
        final h = await history(
          const ActivityDraft(
            name: 'Chạy',
            startDate: '2026-10-01',
            evaluation: Evaluation.duration,
            target: 30,
            rule: ScheduleRule(
              type: ScheduleType.timesPerPeriod,
              timesPerPeriod: 3,
              period: SchedulePeriod.week,
            ),
          ),
          const {},
        );
        final w = valuesByWeek(h, day('2026-11-10'), weeks: 1);
        expect(w.single.target, 90);
      },
    );
  });
}
