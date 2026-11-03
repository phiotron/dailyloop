import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/dates.dart';
import 'package:dailyloop/src/data/evaluation.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

DateTime d(String key) => parseDateKey(key);

List<String> due(DueCalculator c, String from, String to) =>
    c.dueDates(d(from), d(to)).map(dateKey).toList();

DueCalculator calc(
  ScheduleRule rule, {
  String start = '2026-11-02',
  String? end,
}) => DueCalculator(
  startDate: start,
  endDate: end,
  rules: [(effectiveFrom: start, rule: rule)],
);

void main() {
  group('lịch lặp (AC-03)', () {
    test('mỗi ngày, không trước ngày bắt đầu', () {
      expect(due(calc(ScheduleRule.daily), '2026-10-31', '2026-11-04'), [
        '2026-11-02',
        '2026-11-03',
        '2026-11-04',
      ]);
    });

    test('dừng sau ngày kết thúc', () {
      expect(
        due(
          calc(ScheduleRule.daily, end: '2026-11-03'),
          '2026-11-01',
          '2026-11-06',
        ),
        ['2026-11-02', '2026-11-03'],
      );
    });

    test('các thứ cố định trong tuần: Thứ Hai, Tư, Sáu', () {
      // Bit 0 Thứ Hai, bit 2 Thứ Tư, bit 4 Thứ Sáu.
      const rule = ScheduleRule(
        type: ScheduleType.weekdays,
        weekdays: 1 | 4 | 16,
      );
      expect(due(calc(rule), '2026-11-02', '2026-11-15'), [
        '2026-11-02',
        '2026-11-04',
        '2026-11-06',
        '2026-11-09',
        '2026-11-11',
        '2026-11-13',
      ]);
    });

    test('Chủ Nhật là bit 6', () {
      const rule = ScheduleRule(type: ScheduleType.weekdays, weekdays: 64);
      expect(due(calc(rule), '2026-11-02', '2026-11-15'), [
        '2026-11-08',
        '2026-11-15',
      ]);
    });

    test('ngày 31 bị bỏ qua ở tháng không có ngày 31', () {
      const rule = ScheduleRule(
        type: ScheduleType.monthDays,
        monthDays: {1, 31},
      );
      expect(due(calc(rule, start: '2026-10-01'), '2026-10-01', '2026-12-31'), [
        '2026-10-01',
        '2026-10-31',
        '2026-11-01',
        '2026-12-01',
        '2026-12-31',
      ]);
    });

    test('ngày 29 tháng 2 chỉ có ở năm nhuận', () {
      const rule = ScheduleRule(type: ScheduleType.monthDays, monthDays: {29});
      final c = calc(rule, start: '2027-01-01');
      expect(due(c, '2027-02-01', '2027-03-01'), isEmpty);
      expect(due(c, '2028-02-01', '2028-03-01'), ['2028-02-29']);
    });

    test('cứ 3 ngày một lần tính từ ngày bắt đầu', () {
      const rule = ScheduleRule(type: ScheduleType.everyNDays, interval: 3);
      expect(due(calc(rule), '2026-11-01', '2026-11-12'), [
        '2026-11-02',
        '2026-11-05',
        '2026-11-08',
        '2026-11-11',
      ]);
    });

    test('cứ N ngày qua cuối năm nhuận vẫn đúng nhịp', () {
      const rule = ScheduleRule(type: ScheduleType.everyNDays, interval: 2);
      final c = calc(rule, start: '2028-02-27');
      expect(due(c, '2028-02-27', '2028-03-03'), [
        '2028-02-27',
        '2028-02-29',
        '2028-03-02',
      ]);
    });

    test('K lần mỗi tuần: ngày nào cũng làm được', () {
      const rule = ScheduleRule(
        type: ScheduleType.timesPerPeriod,
        timesPerPeriod: 3,
        period: SchedulePeriod.week,
      );
      expect(due(calc(rule), '2026-11-02', '2026-11-08'), hasLength(7));
    });

    test('việc một lần chỉ đến hạn đúng ngày', () {
      expect(
        due(
          calc(ScheduleRule.once, start: '2026-11-05'),
          '2026-11-01',
          '2026-11-30',
        ),
        ['2026-11-05'],
      );
    });

    test('không có ngày bắt đầu thì không bao giờ đến hạn', () {
      final c = DueCalculator(
        startDate: null,
        endDate: null,
        rules: [(effectiveFrom: '2026-11-01', rule: ScheduleRule.once)],
      );
      expect(due(c, '2026-11-01', '2026-11-30'), isEmpty);
    });
  });

  test('đổi lịch chỉ ảnh hưởng từ ngày hiệu lực (AC-04)', () {
    final c = DueCalculator(
      startDate: '2026-11-02',
      endDate: null,
      rules: [
        (effectiveFrom: '2026-11-02', rule: ScheduleRule.daily),
        (
          effectiveFrom: '2026-11-05',
          rule: const ScheduleRule(type: ScheduleType.everyNDays, interval: 2),
        ),
      ],
    );
    expect(due(c, '2026-11-02', '2026-11-10'), [
      '2026-11-02',
      '2026-11-03',
      '2026-11-04',
      '2026-11-05',
      '2026-11-07',
      '2026-11-09',
    ]);
  });

  group('kiểm tra lịch hợp lệ', () {
    test('thiếu thứ, ngày, N, K thì báo lỗi', () {
      expect(
        const ScheduleRule(type: ScheduleType.weekdays).validate(),
        'weekdays',
      );
      expect(
        const ScheduleRule(type: ScheduleType.monthDays).validate(),
        'monthDays',
      );
      expect(
        const ScheduleRule(
          type: ScheduleType.everyNDays,
          interval: 1,
        ).validate(),
        'interval',
      );
      expect(
        const ScheduleRule(
          type: ScheduleType.everyNDays,
          interval: 366,
        ).validate(),
        'interval',
      );
      expect(
        const ScheduleRule(
          type: ScheduleType.timesPerPeriod,
          timesPerPeriod: 8,
          period: SchedulePeriod.week,
        ).validate(),
        'timesPerPeriod',
      );
      expect(ScheduleRule.daily.validate(), isNull);
    });

    test('ngày trong tháng đọc và ghi lại giống nhau', () {
      expect(formatMonthDays({31, 1, 15}), '1,15,31');
      expect(parseMonthDays('1,15,31'), {1, 15, 31});
      expect(parseMonthDays(null), isEmpty);
    });
  });

  group('đạt mục tiêu (AC-02)', () {
    test('Có/Không', () {
      expect(isAchieved(evaluation: Evaluation.yesNo, value: 1), isTrue);
      expect(isAchieved(evaluation: Evaluation.yesNo, value: 0), isFalse);
    });

    test('Số lượng: ít nhất, đúng bằng, nhiều nhất', () {
      bool q(double v, TargetCondition c) => isAchieved(
        evaluation: Evaluation.quantity,
        value: v,
        target: 8,
        condition: c,
      );
      expect(q(8, TargetCondition.atLeast), isTrue);
      expect(q(7, TargetCondition.atLeast), isFalse);
      expect(q(8, TargetCondition.exactly), isTrue);
      expect(q(9, TargetCondition.exactly), isFalse);
      expect(q(3, TargetCondition.atMost), isTrue);
      expect(q(9, TargetCondition.atMost), isFalse);
    });

    test('Thời gian theo phút', () {
      expect(
        isAchieved(
          evaluation: Evaluation.duration,
          value: 30,
          target: 30,
          condition: TargetCondition.atLeast,
        ),
        isTrue,
      );
    });

    test('Danh sách con: mặc định phải xong hết, hoặc ít nhất N', () {
      expect(
        isAchieved(
          evaluation: Evaluation.checklist,
          value: 0,
          checkedItems: 2,
          totalItems: 3,
        ),
        isFalse,
      );
      expect(
        isAchieved(
          evaluation: Evaluation.checklist,
          value: 0,
          checklistMinDone: 2,
          checkedItems: 2,
          totalItems: 3,
        ),
        isTrue,
      );
    });
  });
}
