import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

Future<int> insert(
  WidgetTester tester,
  AppDatabase db,
  ActivityDraft draft,
) async {
  final id = await tester.runAsync(() => ActivityRepository(db).create(draft));
  await settle(tester);
  return id!;
}

Future<List<Entry>> entriesOf(WidgetTester tester, AppDatabase db) async =>
    (await tester.runAsync(() => db.select(db.entries).get()))!;

/// Ô trạng thái ở đầu dòng của mục [name].
Finder statusButton(String name) => find
    .descendant(
      of: find.ancestor(of: find.text(name), matching: find.byType(ListTile)),
      matching: find.byType(IconButton),
    )
    .first;

void main() {
  testWidgets('trạng thái trống có nút tạo nhanh (AC-11)', (tester) async {
    final db = await pumpApp(tester);
    expect(find.text('Hôm nay chưa có việc nào'), findsOneWidget);
    expect(find.text('Thêm thói quen'), findsOneWidget);
    await tester.tap(find.text('Thêm việc'));
    await settle(tester);
    expect(find.text('Việc mới'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('Có/Không: một chạm để xong, chạm lại để bỏ (AC-09, AC-12)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await insert(
      tester,
      db,
      const ActivityDraft(name: 'Thiền', startDate: '2026-11-01'),
    );
    expect(find.text('Thiền'), findsOneWidget);
    expect(find.byTooltip('Chưa đạt'), findsOneWidget);

    await tester.tap(find.text('Thiền'));
    await settle(tester);
    expect(find.byTooltip('Đạt'), findsOneWidget);
    final e = await entriesOf(tester, db);
    expect(e.single.date, '2026-11-03');
    expect(e.single.value, 1);

    await tester.tap(statusButton('Thiền'));
    await settle(tester);
    expect(find.byTooltip('Chưa đạt'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('Số lượng: nút +1 và nhập số (AC-09)', (tester) async {
    final db = await pumpApp(tester);
    await insert(
      tester,
      db,
      const ActivityDraft(
        name: 'Uống nước',
        evaluation: Evaluation.quantity,
        target: 8,
        unit: 'ly',
        startDate: '2026-11-01',
      ),
    );
    expect(find.text('0 trên 8 ly'), findsOneWidget);
    await tester.tap(find.byTooltip('Thêm 1'));
    await settle(tester);
    expect(find.text('1 trên 8 ly'), findsOneWidget);

    await tester.tap(find.text('Uống nước'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), '8');
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('8 trên 8 ly'), findsOneWidget);
    expect(find.byTooltip('Đạt'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('Danh sách con: đánh dấu từng mục (AC-09)', (tester) async {
    final db = await pumpApp(tester);
    await insert(
      tester,
      db,
      const ActivityDraft(
        name: 'Buổi sáng',
        evaluation: Evaluation.checklist,
        checklist: [(id: null, title: 'Uống nước'), (id: null, title: 'Tập')],
        startDate: '2026-11-01',
      ),
    );
    expect(find.text('0 trên 2 mục'), findsOneWidget);
    await tester.tap(find.text('Buổi sáng'));
    await settle(tester);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Uống nước'));
    await settle(tester);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Tập'));
    await settle(tester);
    await tester.tapAt(const Offset(20, 100)); // đóng bảng
    await settle(tester);
    expect(find.text('2 trên 2 mục'), findsOneWidget);
    expect(find.byTooltip('Đạt'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('bỏ qua ngày này (AC-10)', (tester) async {
    final db = await pumpApp(tester);
    await insert(
      tester,
      db,
      const ActivityDraft(name: 'Chạy', startDate: '2026-11-01'),
    );
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bỏ qua ngày này'));
    await settle(tester);
    expect(find.byTooltip('Đã bỏ qua'), findsOneWidget);
    expect((await entriesOf(tester, db)).single.skipped, isTrue);
    await disposeApp(tester, db);
  });

  testWidgets(
    'dải ngày: ngày đã qua ghi được, ngày tương lai chỉ xem (AC-08)',
    (tester) async {
      final db = await pumpApp(tester);
      await insert(
        tester,
        db,
        const ActivityDraft(name: 'Thiền', startDate: '2026-11-01'),
      );

      // Hôm qua (Thứ Hai 2/11).
      await tester.tap(find.bySemanticsLabel(RegExp('Thứ Hai, 2 tháng 11')));
      await settle(tester);
      expect(find.byTooltip('Về hôm nay'), findsOneWidget);
      await tester.tap(find.text('Thiền'));
      await settle(tester);
      expect((await entriesOf(tester, db)).single.date, '2026-11-02');

      // Ngày mai thì không ghi được.
      await tester.tap(find.byTooltip('Về hôm nay'));
      await settle(tester);
      await tester.tap(find.bySemanticsLabel(RegExp('Thứ Tư, 4 tháng 11')));
      await settle(tester);
      await tester.tap(find.text('Thiền'));
      await settle(tester);
      expect(find.text('Chỉ ghi được kết quả tới hôm nay'), findsOneWidget);
      expect(await entriesOf(tester, db), hasLength(1));
      await disposeApp(tester, db);
    },
  );

  testWidgets('việc quá hạn ở đầu màn Hôm nay (AC-15)', (tester) async {
    final db = await pumpApp(tester);
    await insert(
      tester,
      db,
      const ActivityDraft(name: 'Thiền', startDate: '2026-11-01'),
    );
    await insert(
      tester,
      db,
      const ActivityDraft(
        kind: ActivityKind.task,
        name: 'Nộp thuế',
        startDate: '2026-10-31',
        rule: ScheduleRule.once,
      ),
    );
    expect(find.text('Quá hạn · 3 ngày'), findsOneWidget);
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect((tiles.first.title! as Text).data, 'Nộp thuế');

    await tester.tap(find.text('Nộp thuế'));
    await settle(tester);
    expect(find.text('Nộp thuế'), findsNothing);
    expect((await entriesOf(tester, db)).single.date, '2026-10-31');
    await disposeApp(tester, db);
  });

  testWidgets('tạo việc chưa xếp lịch, hiện ở bộ lọc (AC-13, AC-16)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tester.tap(find.byTooltip('Tạo mới'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Việc mới'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'Mua sách');
    // Bỏ ngày: việc vào "Chưa xếp lịch".
    await tester.ensureVisible(find.byTooltip('Bỏ').first);
    await tester.tap(find.byTooltip('Bỏ').first);
    await tester.pump();
    expect(find.text('Chưa xếp lịch'), findsOneWidget);
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('Hôm nay chưa có việc nào'), findsOneWidget);

    await tester.tap(find.text('Việc').last);
    await settle(tester);
    expect(find.text('Không có việc nào'), findsOneWidget);
    await tester.ensureVisible(
      find.widgetWithText(ChoiceChip, 'Chưa xếp lịch'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Chưa xếp lịch'));
    await settle(tester);
    expect(find.text('Mua sách'), findsOneWidget);

    await tester.tap(find.text('Mua sách'));
    await settle(tester);
    expect(find.text('Mua sách'), findsNothing);
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Đã xong'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Đã xong'));
    await settle(tester);
    expect(find.text('Mua sách'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('tạo việc có giờ từ màn Hôm nay hiện đúng ngày (AC-13)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tester.tap(find.byTooltip('Tạo mới'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Việc mới'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Tên'), 'Gọi mẹ');
    await tester.tap(find.text('Lưu'));
    await settle(tester);
    expect(find.text('Gọi mẹ'), findsOneWidget);
    final a = (await tester.runAsync(() => db.select(db.activities).get()))!;
    expect(a.single.kind, ActivityKind.task);
    expect(a.single.startDate, '2026-11-03');
    await disposeApp(tester, db);
  });

  testWidgets('màn chào lần đầu, bỏ qua được, không hiện lại (AC-34)', (
    tester,
  ) async {
    final db = memoryDatabase();
    await pumpApp(tester, db: db, onboarded: false);
    expect(find.text('Xây thói quen bền vững'), findsOneWidget);
    await tester.tap(find.text('Tiếp'));
    await tester.pumpAndSettle();
    expect(find.text('Sắp xếp ngày của bạn'), findsOneWidget);
    await tester.tap(find.text('Bỏ qua'));
    await settle(tester);
    expect(find.text('Hôm nay chưa có việc nào'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('màn Hôm nay không tràn ở cỡ chữ 200% (AC-50)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final db = await pumpApp(tester);
    await insert(
      tester,
      db,
      const ActivityDraft(
        name: 'Uống nước mỗi ngày thật đều đặn',
        evaluation: Evaluation.quantity,
        target: 8,
        unit: 'ly',
        startDate: '2026-11-01',
      ),
    );
    expect(tester.takeException(), isNull);
    await disposeApp(tester, db);
  });
}
