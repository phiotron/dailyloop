import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/reminders/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

/// Mở màn tạo thói quen và nhập tên. Màn hình test cao 1600 dp để cả form
/// hiện hết, không cần cuộn: các test ở đây kiểm tra logic giờ nhắc và xin
/// quyền, còn việc cuộn tới dòng báo lỗi đã có test ở `habits_flow_test`.
Future<void> openEditor(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 4800);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Thói quen').last);
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Thói quen mới'));
  await settle(tester);
  await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'Uống thuốc');
}

/// Thêm một giờ nhắc, chấp nhận giờ mặc định 08:00 trong hộp chọn giờ.
Future<void> addReminder(WidgetTester tester) async {
  await tester.tap(find.text('Thêm giờ nhắc'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('thêm giờ nhắc khi đã có đủ quyền, lưu và lập lịch (AC-17)', (
    tester,
  ) async {
    final gateway = FakeReminderGateway();
    final db = await pumpApp(tester, reminders: gateway);
    await openEditor(tester);
    await addReminder(tester);
    expect(find.text('08:00'), findsOneWidget);
    expect(gateway.requests, isEmpty);

    await tester.tap(find.text('Lưu'));
    await settle(tester);
    final r = (await tester.runAsync(() => db.select(db.reminders).get()))!;
    expect(r.single.minuteOfDay, 480);
    expect(r.single.kind, ReminderKind.notification);

    // Lịch được đặt lại sau 500 ms gộp thay đổi.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 700)),
    );
    expect(gateway.scheduled, isNotEmpty);
    expect(gateway.scheduled.first.title, 'Uống thuốc');
    await disposeApp(tester, db);
  });

  testWidgets('chưa có quyền: giải thích trước rồi mới xin (AC-18)', (
    tester,
  ) async {
    final gateway = FakeReminderGateway(
      granted: const ReminderPermissions(
        notifications: false,
        exactAlarms: false,
        fullScreen: false,
      ),
    );
    final db = await pumpApp(tester, reminders: gateway);
    await openEditor(tester);
    await addReminder(tester);

    expect(find.text('Cho phép thông báo?'), findsOneWidget);
    expect(gateway.requests, isEmpty);
    await tester.tap(find.text('Cho phép'));
    await tester.pumpAndSettle();
    expect(gateway.requests, ['notifications']);

    // Quyền báo thức chính xác: người dùng chọn "Để sau".
    expect(find.text('Nhắc đúng giờ?'), findsOneWidget);
    await tester.tap(find.text('Để sau'));
    await settle(tester);
    expect(gateway.requests, ['notifications']);

    // Bị từ chối thì vẫn lưu được, có cảnh báo và nút mở cài đặt.
    await tester.ensureVisible(
      find.text('Thông báo đang tắt, nhắc giờ sẽ không hiện'),
    );
    expect(find.text('Mở cài đặt'), findsOneWidget);
    await tester.tap(find.text('Mở cài đặt'));
    await settle(tester);
    expect(gateway.requests.last, 'settings');

    await tester.tap(find.text('Lưu'));
    await settle(tester);
    final r = (await tester.runAsync(() => db.select(db.reminders).get()))!;
    expect(r, hasLength(1));
    await disposeApp(tester, db);
  });

  testWidgets('chọn chuông thì xin thêm quyền toàn màn hình (AC-20)', (
    tester,
  ) async {
    final gateway = FakeReminderGateway(
      granted: const ReminderPermissions(
        notifications: true,
        exactAlarms: true,
        fullScreen: false,
      ),
    );
    final db = await pumpApp(tester, reminders: gateway);
    await openEditor(tester);
    await addReminder(tester);
    expect(gateway.requests, isEmpty);

    await tester.tap(find.text('Thông báo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chuông báo thức').last);
    await tester.pumpAndSettle();
    expect(find.text('Hiện chuông trên màn hình khóa?'), findsOneWidget);
    await tester.tap(find.text('Cho phép'));
    await settle(tester);
    expect(gateway.requests, ['fullScreen']);
    await tester.ensureVisible(find.text('Chuông sẽ hiện dạng thông báo nổi'));

    await tester.tap(find.text('Lưu'));
    await settle(tester);
    final r = (await tester.runAsync(() => db.select(db.reminders).get()))!;
    expect(r.single.kind, ReminderKind.alarm);
    await disposeApp(tester, db);
  });
}
