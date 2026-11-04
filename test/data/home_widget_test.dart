import 'dart:convert';

import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:dailyloop/src/widget/home_widget_sync.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

const texts = HomeWidgetTexts(
  title: 'Hôm nay',
  empty: 'Trống',
  allDone: 'Xong hết',
  leftOf: _left,
);
String _left(int n) => 'Còn $n mục';

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  final now = DateTime(2026, 11, 4, 9);

  Future<Map<String, dynamic>> build({bool hide = false}) async => jsonDecode(
    await buildWidgetPayload(db, now: now, texts: texts, hideNames: hide),
  ) as Map<String, dynamic>;

  test('không có mục nào thì ghi chữ "trống" cho cả 7 ngày', () async {
    final p = await build();
    final days = p['days'] as Map<String, dynamic>;
    expect(days.keys.first, '2026-11-04');
    expect(days.length, widgetDays);
    expect(days['2026-11-04']['summary'], 'Trống');
    expect(p['leftTpl'], 'Còn -1 mục');
  });

  test(
    'liệt kê mục đến hạn, trạng thái xong và mục chạm được (AC-39)',
    () async {
      final repo = ActivityRepository(db);
      final a = await repo.create(
        const ActivityDraft(name: 'Thiền', startDate: '2026-11-01'),
      );
      await repo.create(
        const ActivityDraft(
          name: 'Uống nước',
          startDate: '2026-11-01',
          evaluation: Evaluation.quantity,
          target: 8,
        ),
      );
      await repo.create(
        const ActivityDraft(
          kind: ActivityKind.task,
          name: 'Nộp thuế',
          startDate: '2026-11-04',
          rule: ScheduleRule.once,
        ),
      );
      var p = await build();
      var today = p['days']['2026-11-04'] as Map<String, dynamic>;
      final items = (today['items'] as List).cast<Map<String, dynamic>>();
      expect(
        items.map((i) => i['name']),
        containsAll(['Thiền', 'Uống nước', 'Nộp thuế']),
      );
      expect(items.firstWhere((i) => i['name'] == 'Thiền')['tap'], isTrue);
      expect(items.firstWhere((i) => i['name'] == 'Uống nước')['tap'], isFalse);
      expect(today['summary'], 'Còn 3 mục');

      await EntryRepository(db).setValue(a, '2026-11-04', 1);
      p = await build();
      today = p['days']['2026-11-04'] as Map<String, dynamic>;
      expect(today['summary'], 'Còn 2 mục');
      final done = (today['items'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((i) => i['name'] == 'Thiền');
      expect(done['done'], isTrue);
    },
  );

  test(
    'có mục ở ngày sau thì nằm đúng ngày để widget sang ngày mới (AC-40)',
    () async {
      await ActivityRepository(db).create(
        const ActivityDraft(
          kind: ActivityKind.task,
          name: 'Họp',
          startDate: '2026-11-06',
          rule: ScheduleRule.once,
        ),
      );
      final p = await build();
      final days = p['days'] as Map<String, dynamic>;
      expect(days['2026-11-04']['items'], isEmpty);
      expect((days['2026-11-06']['items'] as List).single['name'], 'Họp');
    },
  );

  test('khi cần ẩn tên thì chỉ còn số lượng (AC-41)', () async {
    await ActivityRepository(db)
        .create(const ActivityDraft(name: 'Bí mật', startDate: '2026-11-01'));
    final p = await build(hide: true);
    final today = p['days']['2026-11-04'] as Map<String, dynamic>;
    expect(today['items'], isEmpty);
    expect(today['summary'], 'Còn 1 mục');
    expect(jsonEncode(p).contains('Bí mật'), isFalse);
  });
}
