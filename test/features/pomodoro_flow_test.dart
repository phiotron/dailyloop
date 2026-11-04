import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:dailyloop/src/pomodoro/pomodoro_repository.dart';
import 'package:dailyloop/src/reminders/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

Future<void> openPomodoro(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Pomodoro'));
  await tester.pumpAndSettle();
}

String timeShown(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('pomodoroTime'))).data!;

void main() {
  testWidgets(
    'mở màn Pomodoro, chỉnh thời gian, bắt đầu và dừng (AC-35, AC-36)',
    (tester) async {
      var now = DateTime(2026, 11, 3, 9);
      final gateway = FakeReminderGateway();
      final db = await pumpApp(tester, reminders: gateway, clock: () => now);
      await openPomodoro(tester);

      expect(timeShown(tester), '25:00');
      await tester.tap(find.byTooltip('+ Tập trung'));
      await settle(tester);
      expect(timeShown(tester), '26:00');

      await tester.tap(find.text('Bắt đầu'));
      await settle(tester);
      expect(gateway.timerEnd, DateTime(2026, 11, 3, 9, 26));

      now = DateTime(2026, 11, 3, 9, 6, 30);
      await tester.pump(const Duration(seconds: 1));
      await settle(tester);
      expect(timeShown(tester), '19:30');

      await tester.tap(find.text('Dừng'));
      await settle(tester);
      expect(gateway.timerEnd, isNull);
      expect(timeShown(tester), '26:00');
      await disposeApp(tester, db);
    },
  );

  testWidgets('mở từ thói quen kiểu Thời gian, dừng thì cộng phút (AC-37)', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 3, 9);
    final db = await pumpApp(tester, clock: () => now);
    late int id;
    await tester.runAsync(() async {
      id = await ActivityRepository(db).create(
        const ActivityDraft(
          name: 'Đọc sách',
          startDate: '2026-11-01',
          evaluation: Evaluation.duration,
          target: 30,
        ),
      );
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thói quen').last);
    await settle(tester);
    await tester.tap(find.text('Đọc sách'));
    await settle(tester);
    await tester.tap(find.byTooltip('Bấm giờ'));
    await settle(tester);

    await tester.tap(find.text('Bắt đầu'));
    await settle(tester);
    now = DateTime(2026, 11, 3, 9, 12);
    await tester.tap(find.text('Dừng'));
    await settle(tester);

    final value = await tester.runAsync(
      () async => (await EntryRepository(db).find(id, '2026-11-03'))?.value,
    );
    expect(value, 12);
    await disposeApp(tester, db);
  });

  testWidgets('mở lại khi đã lưu một lần chạy thì còn đúng thời gian (AC-38)', (
    tester,
  ) async {
    final now = DateTime(2026, 11, 3, 9, 10);
    final db = await pumpApp(tester, clock: () => now);
    await tester.runAsync(
      () => PomodoroRepository(db).start(DateTime(2026, 11, 3, 9)),
    );
    await openPomodoro(tester);
    expect(timeShown(tester), '15:00');
    expect(find.text('Dừng'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('hết giờ khi mở màn thì báo đã hết và cho sang nghỉ', (
    tester,
  ) async {
    final now = DateTime(2026, 11, 3, 10);
    final db = await pumpApp(tester, clock: () => now);
    await tester.runAsync(
      () => PomodoroRepository(db).start(DateTime(2026, 11, 3, 9)),
    );
    await openPomodoro(tester);
    expect(timeShown(tester), 'Đã hết giờ');
    await tester.tap(find.text('Giai đoạn kế tiếp'));
    await settle(tester);
    expect(find.textContaining('Nghỉ ngắn'), findsWidgets);
    expect(timeShown(tester), '05:00');
    await disposeApp(tester, db);
  });
}
