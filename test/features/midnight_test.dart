import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:dailyloop/src/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

void main() {
  testWidgets('qua nửa đêm màn Hôm nay tự sang ngày mới (BUG-001)', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 3, 23, 59, 30);
    final db = await pumpApp(tester, clock: () => now);
    await tester.runAsync(() async {
      final repo = ActivityRepository(db);
      await repo.create(
        const ActivityDraft(name: 'Thiền', startDate: '2026-11-01'),
      );
      await repo.create(
        const ActivityDraft(
          kind: ActivityKind.task,
          name: 'Nộp thuế',
          startDate: '2026-11-03',
          rule: ScheduleRule.once,
        ),
      );
    });
    await settle(tester);

    // Trước nửa đêm: hôm nay là 3/11, việc "Nộp thuế" đến hạn, không quá hạn.
    expect(find.text('Nộp thuế'), findsOneWidget);
    expect(find.text('Quá hạn · 1 ngày'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp('^Thứ Ba, 3 tháng 11, 2026')),
      findsOneWidget,
    );

    // Qua 00:00: đổi giờ máy rồi để bộ hẹn giờ (hoặc lần quay lại app) làm mới.
    now = DateTime(2026, 11, 4, 0, 0, 5);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(todayProvider.notifier).refresh();
    await settle(tester);

    // Đang xem hôm nay nên dải ngày chuyển theo sang 4/11, việc hôm qua quá hạn.
    expect(
      find.bySemanticsLabel(RegExp('^Thứ Tư, 4 tháng 11, 2026')),
      findsOneWidget,
    );
    expect(find.text('Quá hạn · 1 ngày'), findsOneWidget);
    expect(find.text('Nộp thuế'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('đang xem một ngày khác thì qua nửa đêm không bị kéo đi', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 3, 23, 59, 30);
    final db = await pumpApp(tester, clock: () => now);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container
        .read(selectedDayProvider.notifier)
        .select(DateTime.utc(2026, 11, 1));
    await settle(tester);

    now = DateTime(2026, 11, 4, 0, 0, 5);
    container.read(todayProvider.notifier).refresh();
    await settle(tester);

    expect(container.read(todayProvider), DateTime.utc(2026, 11, 4));
    expect(container.read(selectedDayProvider), DateTime.utc(2026, 11, 1));
    await disposeApp(tester, db);
  });

  testWidgets('bộ hẹn giờ nửa đêm chạy lúc 00:00 và đặt lại cho đêm sau', (
    tester,
  ) async {
    // Dùng đồng hồ giả của test: kéo thời gian tới qua nửa đêm.
    var now = DateTime(2026, 11, 3, 23, 59, 30);
    final db = await pumpApp(tester, clock: () => now);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    expect(container.read(todayProvider), DateTime.utc(2026, 11, 3));

    now = DateTime(2026, 11, 4, 0, 0, 1);
    // Bộ hẹn giờ đặt sau 31 giây (tới 00:00:00 cộng 1 giây).
    await tester.pump(const Duration(seconds: 31));
    expect(container.read(todayProvider), DateTime.utc(2026, 11, 4));
    await disposeApp(tester, db);
  });
}
