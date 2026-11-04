import 'dart:convert';

import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/backup.dart';
import 'package:dailyloop/src/data/pin_service.dart';
import 'package:dailyloop/src/features/backup/file_gateway.dart';
import 'package:dailyloop/src/features/welcome/welcome_screen.dart';
import 'package:dailyloop/src/reminders/reminder_service.dart';
import 'package:dailyloop/src/widget/home_widget_sync.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';
import '../sample_data.dart';

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Cài đặt'));
  await settle(tester);
}

Future<void> tapTile(WidgetTester tester, String title) async {
  final tile = find.text(title);
  await tester.scrollUntilVisible(tile, 200);
  await tester.ensureVisible(tile);
  await settle(tester);
  await tester.tap(tile);
  await settle(tester);
}

Future<void> confirmDeleteAll(WidgetTester tester) async {
  await tapTile(tester, 'Xóa toàn bộ dữ liệu');
  await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
  await settle(tester);
  await tester.tap(find.widgetWithText(FilledButton, 'Xóa toàn bộ dữ liệu'));
  await settle(tester);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  /// Nội dung file sao lưu của một máy khác có dữ liệu mẫu.
  Future<String> otherDeviceBackup(WidgetTester tester) async {
    final json = await tester.runAsync(() async {
      final other = memoryDatabase();
      try {
        await sampleData(other);
        return await exportBackup(other, now: DateTime(2026, 11, 3));
      } finally {
        await other.close();
      }
    });
    return json!;
  }

  testWidgets('Xuất bản sao lưu mở bảng chia sẻ với file .dailyloop (AC-42)', (
    tester,
  ) async {
    final files = FakeFileGateway();
    final db = memoryDatabase();
    await tester.runAsync(() => sampleData(db));
    await pumpApp(tester, db: db, files: files);
    await openSettings(tester);
    await tapTile(tester, 'Xuất bản sao lưu');

    expect(files.shared, hasLength(1));
    final f = files.shared.single;
    expect(f.name, 'dailyloop-20261103-0900.dailyloop');
    final root = jsonDecode(f.content) as Map<String, dynamic>;
    expect(root['format'], 'dailyloop-backup');
    expect(f.content, contains('Uống nước'));
    await disposeApp(tester, db);
  });

  testWidgets('Xuất CSV chia sẻ file .csv có BOM (AC-44)', (tester) async {
    final files = FakeFileGateway();
    final db = memoryDatabase();
    await tester.runAsync(() => sampleData(db));
    await pumpApp(tester, db: db, files: files);
    await openSettings(tester);
    await tapTile(tester, 'Xuất lịch sử ra CSV');

    final f = files.shared.single;
    expect(f.name, endsWith('.csv'));
    expect(f.mimeType, 'text/csv');
    expect(f.content.startsWith('﻿date,activity,type,result,value'), isTrue);
    expect(f.content, contains('2026-11-03,Uống nước,Thói quen,Đạt,8'));
    await disposeApp(tester, db);
  });

  testWidgets(
    'Khôi phục: chọn file, hỏi xác nhận, thay toàn bộ và đặt lại giờ nhắc (AC-43)',
    (tester) async {
      final backup = await otherDeviceBackup(tester);
      final files = FakeFileGateway()..toPick = backup;
      final reminders = FakeReminderGateway();
      final db = memoryDatabase();
      await tester.runAsync(
        () => ActivityRepository(db).create(
          const ActivityDraft(name: 'Thói quen cũ', startDate: '2026-11-01'),
        ),
      );
      await pumpApp(tester, db: db, files: files, reminders: reminders);
      await openSettings(tester);

      // Hủy ở hộp xác nhận: dữ liệu giữ nguyên.
      await tapTile(tester, 'Khôi phục từ file');
      expect(
        find.text(
          'Dữ liệu hiện tại sẽ bị thay thế bằng nội dung của file sao lưu.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Hủy'));
      await settle(tester);
      var names = (await tester.runAsync(() => db.select(db.activities).get()))!
          .map((a) => a.name);
      expect(names, ['Thói quen cũ']);

      // Xác nhận: thay hết bằng dữ liệu trong file.
      await tapTile(tester, 'Khôi phục từ file');
      await tester.tap(find.widgetWithText(FilledButton, 'Khôi phục'));
      await settle(tester);
      names = (await tester.runAsync(() => db.select(db.activities).get()))!
          .map((a) => a.name);
      expect(names, isNot(contains('Thói quen cũ')));
      expect(
        names,
        containsAll(['Uống nước', 'Chạy bộ', 'Chuẩn bị đồ', 'Nộp thuế']),
      );
      expect(find.text('Đã khôi phục dữ liệu'), findsOneWidget);
      // Giờ nhắc của dữ liệu khôi phục đã được đặt lại.
      expect(
        reminders.scheduled.map((p) => p.title),
        containsAll(['Uống nước', 'Chạy bộ']),
      );
      await disposeApp(tester, db);
    },
  );

  testWidgets('Khôi phục file hỏng: báo lỗi và giữ nguyên dữ liệu (AC-43)', (
    tester,
  ) async {
    final backup = await otherDeviceBackup(tester);
    final files = FakeFileGateway();
    final db = memoryDatabase();
    await tester.runAsync(
      () => ActivityRepository(db).create(
        const ActivityDraft(name: 'Thói quen cũ', startDate: '2026-11-01'),
      ),
    );
    await pumpApp(tester, db: db, files: files);
    await openSettings(tester);

    for (final bad in [
      'không phải json',
      backup.replaceFirst('Uống nước', 'Uống bia'),
    ]) {
      files.toPick = bad;
      await tapTile(tester, 'Khôi phục từ file');
      expect(find.textContaining('File sao lưu hỏng'), findsOneWidget);
      // Không hỏi xác nhận vì file không dùng được.
      expect(find.widgetWithText(FilledButton, 'Khôi phục'), findsNothing);
    }
    // File không đọc được (không phải UTF-8).
    files
      ..toPick = null
      ..pickError = true;
    await tapTile(tester, 'Khôi phục từ file');
    expect(find.textContaining('File sao lưu hỏng'), findsOneWidget);

    final names = (await tester.runAsync(() => db.select(db.activities).get()))!
        .map((a) => a.name);
    expect(names, ['Thói quen cũ']);
    await disposeApp(tester, db);
  });

  testWidgets('Hủy trình chọn file thì không có gì xảy ra', (tester) async {
    final db = await pumpApp(tester); // toPick = null
    await openSettings(tester);
    await tapTile(tester, 'Khôi phục từ file');
    expect(find.widgetWithText(FilledButton, 'Khôi phục'), findsNothing);
    expect(find.textContaining('File sao lưu hỏng'), findsNothing);
    await disposeApp(tester, db);
  });

  testWidgets(
    'Xóa toàn bộ dữ liệu: hai bước xác nhận, hủy lịch nhắc, làm trống widget, về màn chào (AC-52)',
    (tester) async {
      final reminders = FakeReminderGateway();
      final widget = FakeHomeWidgetGateway();
      final secrets = MemorySecretStore();
      final db = memoryDatabase();
      await tester.runAsync(() => sampleData(db));
      await tester.runAsync(() => PinService(secrets).setPin('2468'));
      await pumpApp(
        tester,
        db: db,
        reminders: reminders,
        homeWidget: widget,
        secrets: secrets,
      );
      // Mở khóa trước.
      for (final d in '2468'.split('')) {
        await tester.tap(find.widgetWithText(TextButton, d));
        await tester.pump();
      }
      await settle(tester);
      await openSettings(tester);

      // Hủy ở bước 1 hoặc bước 2: chưa xóa gì.
      await tapTile(tester, 'Xóa toàn bộ dữ liệu');
      await tester.tap(find.widgetWithText(TextButton, 'Hủy'));
      await settle(tester);
      await tapTile(tester, 'Xóa toàn bộ dữ liệu');
      await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
      await settle(tester);
      expect(find.textContaining('Chắc chắn xóa hết?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Hủy'));
      await settle(tester);
      expect(
        await tester.runAsync(() => db.select(db.activities).get()),
        isNotEmpty,
      );

      // Hai bước xác nhận thật.
      await confirmDeleteAll(tester);

      final counts = await tester.runAsync(
        () async => [
          (await db.select(db.activities).get()).length,
          (await db.select(db.entries).get()).length,
          (await db.select(db.schedules).get()).length,
          (await db.select(db.reminders).get()).length,
          (await db.select(db.settings).get()).length,
        ],
      );
      expect(counts, [0, 0, 0, 0, 0]);
      expect(
        await tester.runAsync(() => db.select(db.categories).get()),
        hasLength(8),
      );
      expect(reminders.scheduled, isEmpty);
      expect(reminders.timerEnd, isNull);
      expect(widget.last, isNotNull);
      expect(widget.last, isNot(contains('Uống nước')));
      expect(
        await tester.runAsync(() => PinService(secrets).isEnabled()),
        isFalse,
      );
      expect(find.byType(WelcomeScreen), findsOneWidget);
      await disposeApp(tester, db);
    },
  );

  testWidgets(
    'Xóa toàn bộ dữ liệu cũng hủy hẹn giờ Pomodoro đang chạy (AC-52)',
    (tester) async {
      final reminders = FakeReminderGateway();
      final db = await pumpApp(tester, reminders: reminders);
      await reminders.scheduleTimerEnd(
        DateTime(2026, 11, 3, 9, 25),
        title: 'Hết giờ',
        body: '',
      );
      expect(reminders.timerEnd, isNotNull);
      await openSettings(tester);
      await confirmDeleteAll(tester);
      expect(reminders.timerEnd, isNull);
      await disposeApp(tester, db);
    },
  );
}
