import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

Future<void> openHabits(WidgetTester tester) async {
  await tester.tap(find.text('Thói quen').last);
  await tester.pumpAndSettle();
}

/// Chạm một thói quen mở màn tiến độ; bấm "Sửa" ở đó để vào màn sửa. Màn tiến
/// độ có vòng quay chờ dữ liệu nên không dùng `pumpAndSettle` ở giữa.
Future<void> openHabitEditor(WidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await pumpUntilFound(tester, find.byTooltip('Sửa'));
  await tester.tap(find.byTooltip('Sửa'));
  await settle(tester);
}

Future<int> insertHabit(
  WidgetTester tester,
  AppDatabase db,
  ActivityDraft draft,
) async {
  final id = await tester.runAsync(() => ActivityRepository(db).create(draft));
  await settle(tester);
  return id!;
}

void main() {
  testWidgets('tạo thói quen Có/Không mỗi ngày (AC-01, AC-03)', (tester) async {
    final db = await pumpApp(tester);
    await openHabits(tester);
    expect(
      find.text('Chưa có thói quen nào. Bấm + để tạo thói quen đầu tiên.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Thói quen mới'));
    await tester.pumpAndSettle();
    await settle(tester);

    // Tên trống thì báo lỗi, không lưu.
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('Nhập tên'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'Đọc sách');
    await tester.tap(find.text('Lưu'));
    await settle(tester);

    expect(find.text('Đọc sách'), findsOneWidget);
    expect(find.text('Mỗi ngày'), findsOneWidget);
    final a = (await tester.runAsync(() => db.select(db.activities).get()))!;
    expect(a.single.startDate, '2026-11-03');
    await disposeApp(tester, db);
  });

  testWidgets('Số lượng cần mục tiêu, lưu đúng đơn vị (AC-02)', (tester) async {
    final db = await pumpApp(tester);
    await openHabits(tester);
    await tester.tap(find.byTooltip('Thói quen mới'));
    await settle(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'Uống nước');
    await tester.tap(find.text('Số lượng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('Nhập mục tiêu lớn hơn 0'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Mục tiêu'), '8');
    await tester.enterText(
      find.widgetWithText(TextField, 'Đơn vị (ví dụ: ly)'),
      'ly',
    );
    await tester.tap(find.text('Lưu'));
    await settle(tester);

    final a = (await tester.runAsync(() => db.select(db.activities).get()))!;
    expect(a.single.evaluation, Evaluation.quantity);
    expect(a.single.target, 8);
    expect(a.single.unit, 'ly');
    expect(a.single.condition, TargetCondition.atLeast);
    await disposeApp(tester, db);
  });

  testWidgets('lịch các thứ trong tuần: phải chọn ít nhất một thứ (AC-03)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openHabits(tester);
    await tester.tap(find.byTooltip('Thói quen mới'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'Chạy bộ');

    final repeat = find.byType(DropdownButtonFormField<ScheduleType>);
    await tester.ensureVisible(repeat);
    // Đưa ô lên giữa màn hình, khỏi bị nút Lưu ở đáy che.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(repeat);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Các thứ trong tuần').last);
    await tester.pumpAndSettle();
    expect(find.text('Th 2'), findsOneWidget);
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('Chọn ít nhất một thứ'), findsOneWidget);

    await tester.tap(find.text('Th 2'));
    await tester.tap(find.text('Th 6'));
    await tester.pump();
    await tester.tap(find.text('Lưu'));
    await settle(tester);

    expect(find.text('Th 2, Th 6'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('lưu trữ rồi khôi phục từ "Đã lưu trữ" (AC-05)', (tester) async {
    final db = await pumpApp(tester);
    await insertHabit(
      tester,
      db,
      const ActivityDraft(name: 'Thiền', startDate: '2026-11-01'),
    );
    await openHabits(tester);
    await openHabitEditor(tester, 'Thiền');
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu trữ'));
    await settle(tester);

    expect(find.text('Thiền'), findsNothing);
    expect(find.text('Đã lưu trữ'), findsOneWidget); // thanh thông báo

    await tester.tap(find.byTooltip('Đã lưu trữ'));
    await settle(tester);
    expect(find.text('Thiền'), findsOneWidget);
    await tester.tap(find.text('Khôi phục'));
    await settle(tester);
    expect(find.text('Chưa có thói quen nào được lưu trữ'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('xóa có xác nhận và hoàn tác (AC-05)', (tester) async {
    final db = await pumpApp(tester);
    await insertHabit(
      tester,
      db,
      const ActivityDraft(name: 'Tập gym', startDate: '2026-11-01'),
    );
    await openHabits(tester);
    await openHabitEditor(tester, 'Tập gym');
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    expect(
      find.text('Xóa thói quen này cùng toàn bộ lịch sử?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Xóa').last);
    await settle(tester);

    expect(find.text('Tập gym'), findsNothing);
    await tester.tap(find.text('Hoàn tác'));
    await settle(tester);
    expect(find.text('Tập gym'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('sửa thói quen giữ lịch và hiện lịch mới (AC-04)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await insertHabit(
      tester,
      db,
      const ActivityDraft(
        name: 'Học tiếng Anh',
        startDate: '2026-11-01',
        rule: ScheduleRule(type: ScheduleType.everyNDays, interval: 3),
      ),
    );
    await openHabits(tester);
    expect(find.text('Cứ 3 ngày một lần'), findsOneWidget);
    await openHabitEditor(tester, 'Học tiếng Anh');
    await tester.scrollUntilVisible(
      find.widgetWithText(TextField, 'Cứ mấy ngày một lần (2–365)'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Cứ mấy ngày một lần (2–365)'),
      '2',
    );
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    // Lưu xong quay về màn tiến độ; lùi một bước nữa về danh sách để xem lịch.
    await pumpUntilFound(tester, find.byType(BackButton));
    // `pageBack` tìm chú thích "Back" tiếng Anh, còn test chạy ở tiếng Việt.
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text('Cứ 2 ngày một lần'), findsOneWidget);
    final s = (await tester.runAsync(() => db.select(db.schedules).get()))!;
    expect(s.map((x) => x.effectiveFrom), ['2026-11-01', '2026-11-03']);
    await disposeApp(tester, db);
  });

  testWidgets('lọc theo danh mục (AC-32)', (tester) async {
    final db = await pumpApp(tester);
    await insertHabit(
      tester,
      db,
      const ActivityDraft(name: 'Chạy', categoryId: 2, startDate: '2026-11-01'),
    );
    await insertHabit(
      tester,
      db,
      const ActivityDraft(name: 'Đọc', categoryId: 3, startDate: '2026-11-01'),
    );
    await openHabits(tester);
    expect(find.text('Chạy'), findsOneWidget);
    expect(find.text('Đọc'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Thể thao'));

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Thể thao'));
    await settle(tester);
    expect(find.text('Chạy'), findsOneWidget);
    expect(find.text('Đọc'), findsNothing);

    await tester.ensureVisible(find.text('Tất cả'));

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Tất cả'));
    await settle(tester);
    expect(find.text('Chạy'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('thêm danh mục và xóa danh mục đang dùng (AC-31)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    final id = await insertHabit(
      tester,
      db,
      const ActivityDraft(name: 'Chạy', categoryId: 2, startDate: '2026-11-01'),
    );
    await openHabits(tester);
    await tester.tap(find.byTooltip('Danh mục'));
    await settle(tester);

    await tester.tap(find.byTooltip('Thêm danh mục'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'Âm nhạc');
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('Âm nhạc'), findsOneWidget);

    await tester.tap(find.text('Thể thao'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa danh mục'));
    await settle(tester);
    expect(
      find.text('1 mục đang dùng danh mục này. Chuyển sang:'),
      findsOneWidget,
    );
    await tester.tap(find.text('Sức khỏe').last);
    await settle(tester);

    expect(find.text('Thể thao'), findsNothing);
    final a = (await tester.runAsync(
      () =>
          (db.select(db.activities)..where((x) => x.id.equals(id))).getSingle(),
    ))!;
    expect(a.categoryId, 1);
    await disposeApp(tester, db);
  });

  testWidgets('màn soạn không tràn ở cỡ chữ 200% (AC-50)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final db = await pumpApp(tester);
    await openHabits(tester);
    await tester.tap(find.byTooltip('Thói quen mới'));
    await settle(tester);
    await tester.tap(find.text('Danh sách con'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await disposeApp(tester, db);
  });
}
