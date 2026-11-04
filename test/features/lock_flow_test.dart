import 'dart:convert';

import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:dailyloop/src/data/pin_service.dart';
import 'package:dailyloop/src/features/welcome/welcome_screen.dart';
import 'package:dailyloop/src/reminders/reminder_host.dart';
import 'package:dailyloop/src/widget/home_widget_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse, NotificationResponseType;
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.widgetWithText(TextButton, d));
    await tester.pump();
  }
  await settle(tester);
}

Future<MemorySecretStore> secretsWithPin(
  WidgetTester tester,
  String pin,
) async {
  final secrets = MemorySecretStore();
  await tester.runAsync(() => PinService(secrets).setPin(pin));
  return secrets;
}

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Cài đặt'));
  await settle(tester);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  testWidgets(
    'bật PIN thì mở app phải nhập mã; sai báo lỗi, đúng thì vào (AC-46)',
    (tester) async {
      final secrets = await secretsWithPin(tester, '2468');
      final db = await pumpApp(tester, secrets: secrets);
      expect(find.text('Nhập mã PIN'), findsOneWidget);
      expect(find.text('Hôm nay chưa có việc nào'), findsNothing);

      await enterPin(tester, '1111');
      expect(find.text('Sai mã PIN'), findsOneWidget);
      await enterPin(tester, '2468');
      expect(find.text('Nhập mã PIN'), findsNothing);
      expect(find.text('Hôm nay chưa có việc nào'), findsOneWidget);
      await disposeApp(tester, db);
    },
  );

  testWidgets('không bật PIN thì vào thẳng app, không thấy màn khóa', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    expect(find.text('Nhập mã PIN'), findsNothing);
    expect(find.text('Hôm nay chưa có việc nào'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('đặt PIN trong Cài đặt: nhập hai lần phải khớp (AC-45)', (
    tester,
  ) async {
    final secrets = MemorySecretStore();
    final db = await pumpApp(tester, secrets: secrets);
    await openSettings(tester);
    await tester.scrollUntilVisible(find.text('Khóa bằng mã PIN'), 200);
    await tester.tap(find.text('Khóa bằng mã PIN'));
    await settle(tester);
    expect(find.text('Đặt mã PIN 4 số'), findsOneWidget);
    expect(find.textContaining('không mã hóa dữ liệu'), findsOneWidget);
    await enterPin(tester, '1357');
    expect(find.text('Nhập lại mã PIN'), findsOneWidget);
    await enterPin(tester, '1358');
    expect(find.text('Hai lần nhập không khớp'), findsOneWidget);
    await enterPin(tester, '1357');
    await enterPin(tester, '1357');
    expect(
      await tester.runAsync(() => PinService(secrets).verify('1357')),
      isTrue,
    );
    expect(find.text('Đang bật'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('đổi PIN và tắt PIN đều đòi mã hiện tại', (tester) async {
    final secrets = await secretsWithPin(tester, '2468');
    final db = await pumpApp(tester, secrets: secrets);
    await enterPin(tester, '2468');
    await openSettings(tester);
    await tester.scrollUntilVisible(find.text('Đổi mã PIN'), 200);
    await tester.ensureVisible(find.text('Đổi mã PIN'));
    await settle(tester);

    // Đổi: sai mã hiện tại thì dừng lại.
    await tester.tap(find.text('Đổi mã PIN'));
    await settle(tester);
    expect(find.text('Nhập mã PIN hiện tại'), findsOneWidget);
    await enterPin(tester, '0000');
    expect(find.text('Sai mã PIN'), findsOneWidget);
    await enterPin(tester, '2468');
    expect(find.text('Đặt mã PIN 4 số'), findsOneWidget);
    await enterPin(tester, '9999');
    await enterPin(tester, '9999');
    expect(
      await tester.runAsync(() => PinService(secrets).verify('9999')),
      isTrue,
    );

    // Tắt: đúng mã mới tắt được.
    await tester.tap(find.byType(Switch));
    await settle(tester);
    await enterPin(tester, '9999');
    expect(
      await tester.runAsync(() => PinService(secrets).isEnabled()),
      isFalse,
    );
    expect(find.text('Đang tắt'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets(
    'quên mã: giải thích, xác nhận hai bước rồi xóa dữ liệu và PIN (AC-47)',
    (tester) async {
      final secrets = await secretsWithPin(tester, '2468');
      final db = memoryDatabase();
      await tester.runAsync(
        () => ActivityRepository(
          db,
        ).create(const ActivityDraft(name: 'Thiền', startDate: '2026-11-01')),
      );
      await pumpApp(tester, db: db, secrets: secrets);

      await tester.tap(find.text('Quên mã'));
      await settle(tester);
      expect(
        find.textContaining('chỉ có thể xóa toàn bộ dữ liệu'),
        findsOneWidget,
      );
      // Hủy ở bước giải thích: dữ liệu còn nguyên.
      await tester.tap(find.widgetWithText(TextButton, 'Hủy'));
      await settle(tester);
      expect(
        await tester.runAsync(() => db.select(db.activities).get()),
        isNotEmpty,
      );

      await tester.tap(find.text('Quên mã'));
      await settle(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Xóa toàn bộ dữ liệu'));
      await settle(tester);
      // Bước 1.
      await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
      await settle(tester);
      // Bước 2.
      await tester.tap(
        find.widgetWithText(FilledButton, 'Xóa toàn bộ dữ liệu'),
      );
      await settle(tester);

      expect(find.text('Nhập mã PIN'), findsNothing);
      expect(
        await tester.runAsync(() => db.select(db.activities).get()),
        isEmpty,
      );
      expect(
        await tester.runAsync(() => PinService(secrets).isEnabled()),
        isFalse,
      );
      // Như mới cài: màn chào hiện lại.
      expect(find.byType(WelcomeScreen), findsOneWidget);
      await disposeApp(tester, db);
    },
  );

  testWidgets('bộ nhớ an toàn lỗi thì vẫn hiện màn khóa, không kẹt màn trắng', (
    tester,
  ) async {
    final db = await pumpApp(tester, secrets: _BrokenSecretStore());
    expect(find.text('Nhập mã PIN'), findsOneWidget);
    expect(find.text('Quên mã'), findsOneWidget);
    await enterPin(tester, '1234');
    expect(find.text('Nhập mã PIN'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await disposeApp(tester, db);
  });

  group('chuông báo thức trên màn khóa (AC-46)', () {
    NotificationResponse alarmTap(int activityId) => NotificationResponse(
      notificationResponseType: NotificationResponseType.selectedNotification,
      payload: '$activityId|2026-11-03|alarm',
    );

    testWidgets(
      'chuông hiện với Xong, Hoãn, Tắt không cần PIN; Xong ghi kết quả; mở app thì phải nhập PIN',
      (tester) async {
        final secrets = await secretsWithPin(tester, '2468');
        final db = memoryDatabase();
        final id = await tester.runAsync(
          () => ActivityRepository(db).create(
            const ActivityDraft(name: 'Uống thuốc', startDate: '2026-11-01'),
          ),
        );
        await pumpApp(tester, db: db, secrets: secrets);
        expect(find.text('Nhập mã PIN'), findsOneWidget);

        pendingNotificationTap.value = alarmTap(id!);
        await settle(tester);
        expect(find.text('Tới giờ'), findsOneWidget);
        expect(find.text('Uống thuốc'), findsOneWidget);
        expect(find.text('Xong'), findsOneWidget);
        expect(find.text('Hoãn 10 phút'), findsOneWidget);
        expect(find.text('Tắt'), findsOneWidget);
        expect(find.text('Nhập mã PIN'), findsNothing);

        await tester.tap(find.text('Xong'));
        await settle(tester);
        final entry = await tester.runAsync(
          () => EntryRepository(db).find(id, '2026-11-03'),
        );
        expect(entry?.value, 1);
        // Xử lý xong thì về màn PIN, vẫn chưa vào được app.
        expect(find.text('Tới giờ'), findsNothing);
        expect(find.text('Nhập mã PIN'), findsOneWidget);
        expect(find.text('Hôm nay chưa có việc nào'), findsNothing);

        // Chạm chuông lần nữa rồi chọn "Mở app": phải nhập PIN.
        pendingNotificationTap.value = alarmTap(id);
        await settle(tester);
        await tester.tap(find.text('Mở app (cần mã PIN)'));
        await settle(tester);
        expect(find.text('Nhập mã PIN'), findsOneWidget);
        await disposeApp(tester, db);
      },
    );

    testWidgets('không bật PIN thì chuông mở màn chuông thường của app', (
      tester,
    ) async {
      final db = memoryDatabase();
      final id = await tester.runAsync(
        () => ActivityRepository(db).create(
          const ActivityDraft(name: 'Uống thuốc', startDate: '2026-11-01'),
        ),
      );
      await pumpApp(tester, db: db);
      pendingNotificationTap.value = alarmTap(id!);
      await settle(tester);
      expect(find.text('Tới giờ'), findsOneWidget);
      expect(find.text('Nhập mã PIN'), findsNothing);
      await disposeApp(tester, db);
    });
  });

  group('widget ẩn tên khi có PIN (AC-41)', () {
    Future<Map<String, dynamic>> lastPayload(
      WidgetTester tester,
      FakeHomeWidgetGateway gw,
    ) async {
      // Hẹn giờ gộp 500 ms rồi ghi thật.
      await tester.pump(const Duration(milliseconds: 600));
      await settle(tester);
      return jsonDecode(gw.last!) as Map<String, dynamic>;
    }

    Future<AppDatabase> withHabit(WidgetTester tester) async {
      final db = memoryDatabase();
      await tester.runAsync(
        () => ActivityRepository(
          db,
        ).create(const ActivityDraft(name: 'Thiền', startDate: '2026-11-01')),
      );
      return db;
    }

    testWidgets('không có PIN: widget hiện tên mục', (tester) async {
      final gw = FakeHomeWidgetGateway();
      final db = await withHabit(tester);
      await pumpApp(tester, db: db, homeWidget: gw);
      final p = await lastPayload(tester, gw);
      final today = p['days']['2026-11-03'] as Map<String, dynamic>;
      expect((today['items'] as List).single['name'], 'Thiền');
      await disposeApp(tester, db);
    });

    testWidgets('có PIN: widget chỉ còn số mục còn lại, không có tên', (
      tester,
    ) async {
      final gw = FakeHomeWidgetGateway();
      final secrets = await secretsWithPin(tester, '2468');
      final db = await withHabit(tester);
      await pumpApp(tester, db: db, homeWidget: gw, secrets: secrets);
      await enterPin(tester, '2468');
      final p = await lastPayload(tester, gw);
      final today = p['days']['2026-11-03'] as Map<String, dynamic>;
      expect(today['items'], isEmpty);
      expect(today['summary'], 'Còn 1 mục');
      expect(gw.last, isNot(contains('Thiền')));
      await disposeApp(tester, db);
    });

    testWidgets('bật PIN trong Cài đặt thì widget được vẽ lại, hết tên', (
      tester,
    ) async {
      final gw = FakeHomeWidgetGateway();
      final db = await withHabit(tester);
      await pumpApp(tester, db: db, homeWidget: gw);
      var p = await lastPayload(tester, gw);
      expect(gw.last, contains('Thiền'));

      await openSettings(tester);
      await tester.scrollUntilVisible(find.text('Khóa bằng mã PIN'), 200);
      await tester.tap(find.text('Khóa bằng mã PIN'));
      await settle(tester);
      await enterPin(tester, '1357');
      await enterPin(tester, '1357');
      p = await lastPayload(tester, gw);
      expect(gw.last, isNot(contains('Thiền')));
      expect(
        (p['days']['2026-11-03'] as Map<String, dynamic>)['items'],
        isEmpty,
      );
      await disposeApp(tester, db);
    });
  });
}

class _BrokenSecretStore implements SecretStore {
  @override
  Future<String?> read(String key) async => throw StateError('keystore lỗi');

  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}
}
