import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

/// Hôm nay trong test là 2026-11-03 (Thứ Ba).
Future<int> habit(
  WidgetTester tester,
  AppDatabase db,
  String name, {
  String start = '2026-10-30',
  List<String> done = const [],
  ActivityDraft? draft,
}) async {
  final id = await tester.runAsync(() async {
    final id = await ActivityRepository(db)
        .create(draft ?? ActivityDraft(name: name, startDate: start));
    for (final d in done) {
      await EntryRepository(db).toggleDone(id, d);
    }
    return id;
  });
  await settle(tester);
  return id!;
}

Finder navTab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// Mở màn tiến độ của thói quen [name] từ danh sách Thói quen.
Future<void> openDetail(WidgetTester tester, String name) async {
  await tester.tap(navTab('Thói quen'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name));
  await pumpUntilFound(tester, find.text('Chuỗi hiện tại'));
  await settle(tester);
}

void main() {
  testWidgets(
    'màn Thống kê: số mục xong trên tổng và 3 chuỗi dài nhất (AC-28)',
    (tester) async {
      final db = await pumpApp(tester);
      // A: xong 30/10 tới 2/11 (chuỗi 4); B: chỉ xong 1/11; C: không xong ngày nào.
      await habit(
        tester,
        db,
        'A',
        done: ['2026-10-30', '2026-10-31', '2026-11-01', '2026-11-02'],
      );
      await habit(tester, db, 'B', start: '2026-11-01', done: ['2026-11-01']);
      await habit(tester, db, 'C', start: '2026-11-01');
      tester.view.physicalSize = const Size(1080, 4800);

      await tester.tap(navTab('Thống kê'));
      await settle(tester);

      // 7 ngày (28/10–3/11): A đến hạn 5 ngày xong 4; B 3 ngày xong 1; C 3 ngày xong 0.
      expect(find.text('7 ngày gần nhất'), findsOneWidget);
      expect(
        find.text('5 trên 11 xong'),
        findsNWidgets(2),
      ); // 7 ngày và 30 ngày
      expect(find.text('30 ngày gần nhất'), findsOneWidget);

      expect(find.text('Chuỗi dài nhất'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'A'), findsOneWidget);
      expect(find.text('4 ngày'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'B'), findsOneWidget);
      expect(find.text('1 ngày'), findsOneWidget);
      // C chưa có chuỗi nào nên không nằm trong danh sách.
      expect(find.widgetWithText(ListTile, 'C'), findsNothing);
      await disposeApp(tester, db);
    },
  );

  testWidgets('màn Thống kê có bảng thay thế cho biểu đồ (AC-29)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await habit(tester, db, 'A', done: ['2026-11-02']);
    tester.view.physicalSize = const Size(1080, 4800);
    await tester.tap(navTab('Thống kê'));
    await settle(tester);

    expect(find.bySemanticsLabel(RegExp('^Biểu đồ, 7 cột')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Biểu đồ, 30 cột')), findsOneWidget);
    // Bảng thu gọn: mở ra thì có từng ngày với "x trên y xong".
    await tester.tap(find.text('Xem dạng bảng').first);
    await tester.pumpAndSettle();
    expect(find.text('2 thg 11'), findsWidgets);
    expect(find.text('1 trên 1 xong'), findsWidgets);
    await disposeApp(tester, db);
  });

  testWidgets('chưa có gì thì màn Thống kê hiện hướng dẫn', (tester) async {
    final db = await pumpApp(tester);
    await tester.tap(navTab('Thống kê'));
    await settle(tester);
    expect(
      find.text('Thêm thói quen hoặc việc để xem thống kê'),
      findsOneWidget,
    );
    await disposeApp(tester, db);
  });

  testWidgets('màn tiến độ: chuỗi, điểm, tỉ lệ (AC-23 tới AC-25)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await habit(
      tester,
      db,
      'Thiền',
      done: ['2026-10-30', '2026-10-31', '2026-11-01', '2026-11-02'],
    );
    await openDetail(tester, 'Thiền');

    expect(find.text('Chuỗi hiện tại'), findsOneWidget);
    expect(find.text('Chuỗi dài nhất'), findsOneWidget);
    expect(find.text('4 ngày'), findsNWidgets(2));
    expect(find.text('100/100'), findsOneWidget);
    expect(find.text('100%'), findsNWidgets(3)); // 7 ngày, 30 ngày, từ đầu
    await disposeApp(tester, db);
  });

  testWidgets('chưa có ngày nào đến hạn đã qua thì tỉ lệ là "Chưa có"', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await habit(tester, db, 'Mới', start: '2026-11-03');
    await openDetail(tester, 'Mới');
    expect(find.text('Chưa có'), findsNWidgets(3));
    expect(find.text('0/100'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets(
    'lịch tháng: chạm một ngày đã qua sửa kết quả; ngày tương lai không chạm được (AC-26)',
    (tester) async {
      final db = await pumpApp(tester);
      final id = await habit(tester, db, 'Thiền', done: ['2026-11-02']);
      await openDetail(tester, 'Thiền');

      final nov2 = find.bySemanticsLabel(RegExp('^2 tháng 11, 2026, Đạt'));
      expect(nov2, findsOneWidget);
      // 3/11 là hôm nay chưa xong, 4/11 là tương lai.
      expect(
        find.bySemanticsLabel(RegExp('^3 tháng 11, 2026, Hôm nay, chưa xong')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('^4 tháng 11, 2026, Sắp tới')),
        findsOneWidget,
      );
      // 1/11 chưa ghi, đến hạn đã qua: chưa đạt.
      expect(
        find.bySemanticsLabel(RegExp('^1 tháng 11, 2026, Chưa đạt')),
        findsOneWidget,
      );

      // Chạm 1/11 để đánh đạt, chạm 2/11 để bỏ đạt.
      await tester.tap(find.bySemanticsLabel(RegExp('^1 tháng 11, 2026')));
      await settle(tester);
      await tester.tap(nov2);
      await settle(tester);
      final e = (await tester.runAsync(
        () => (db.select(
          db.entries,
        )..where((x) => x.activityId.equals(id))).get(),
      ))!;
      final byDate = {for (final x in e) x.date: x.value};
      expect(byDate['2026-11-01'], 1);
      expect(byDate['2026-11-02'], 0);
      expect(
        find.bySemanticsLabel(RegExp('^1 tháng 11, 2026, Đạt')),
        findsOneWidget,
      );
      await disposeApp(tester, db);
    },
  );

  testWidgets(
    'lịch tháng: đổi tháng bằng mũi tên và vuốt, không lùi trước tháng bắt đầu (AC-26)',
    (tester) async {
      final db = await pumpApp(tester);
      await habit(tester, db, 'Thiền', start: '2026-10-15');
      await openDetail(tester, 'Thiền');

      expect(find.text('tháng 11 năm 2026'), findsOneWidget);
      await tester.tap(find.byTooltip('Tháng trước'));
      await tester.pumpAndSettle();
      expect(find.text('tháng 10 năm 2026'), findsOneWidget);

      // Tháng 10 là tháng bắt đầu nên nút lùi bị khóa.
      final back = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(back.onPressed, isNull);

      // Vuốt sang trái là tháng sau, vuốt sang phải là tháng trước.
      await tester.fling(
        find.text('tháng 10 năm 2026'),
        const Offset(-300, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('tháng 11 năm 2026'), findsOneWidget);
      await tester.fling(
        find.text('tháng 11 năm 2026'),
        const Offset(300, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('tháng 10 năm 2026'), findsOneWidget);
      await disposeApp(tester, db);
    },
  );

  testWidgets(
    'biểu đồ giá trị có bảng thay thế và chuyển theo tuần (AC-27, AC-29)',
    (tester) async {
      final db = await pumpApp(tester);
      final id = await habit(
        tester,
        db,
        'Nước',
        draft: const ActivityDraft(
          name: 'Nước',
          startDate: '2026-10-01',
          evaluation: Evaluation.quantity,
          target: 8,
          unit: 'ly',
        ),
      );
      await tester.runAsync(() async {
        await EntryRepository(db).setValue(id, '2026-11-03', 8);
        await EntryRepository(db).setValue(id, '2026-11-02', 6);
      });
      await settle(tester);
      tester.view.physicalSize = const Size(1080, 4800);
      await openDetail(tester, 'Nước');

      expect(find.bySemanticsLabel(RegExp('^Biểu đồ, 30 cột')), findsOneWidget);
      await tester.tap(find.text('Xem dạng bảng'));
      await tester.pumpAndSettle();
      expect(find.text('8 ly'), findsWidgets);
      expect(find.text('6 ly'), findsWidgets);

      await tester.tap(find.text('Theo tuần'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('^Biểu đồ, 8 cột')), findsOneWidget);
      // Bảng vẫn đang mở từ lần trước nên không bấm lại (bấm lại là đóng).
      // Tuần 2/11: 8 + 6 = 14 ly, mục tiêu 8 ly × 7 ngày = 56 ly.
      expect(find.text('14 ly / 56 ly'), findsOneWidget);
      await disposeApp(tester, db);
    },
  );

  testWidgets('thói quen kiểu Có/Không không có biểu đồ giá trị', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await habit(tester, db, 'Thiền');
    await openDetail(tester, 'Thiền');
    expect(find.text('Theo ngày'), findsNothing);
    expect(find.text('Lịch'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('từ màn Hôm nay mở "Xem tiến độ" (AC-23)', (tester) async {
    final db = await pumpApp(tester);
    await habit(tester, db, 'Thiền', start: '2026-11-01');
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem tiến độ'));
    await pumpUntilFound(tester, find.text('Chuỗi hiện tại'));
    await settle(tester);
    expect(find.text('Chuỗi hiện tại'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('màn tiến độ và màn Thống kê không tràn ở cỡ chữ 200% (AC-50)', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final db = await pumpApp(tester);
    await habit(
      tester,
      db,
      'Uống nước mỗi ngày thật đều đặn',
      done: ['2026-11-02'],
    );
    await tester.tap(navTab('Thống kê'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(navTab('Thói quen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uống nước mỗi ngày thật đều đặn'));
    await pumpUntilFound(tester, find.byTooltip('Sửa'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await disposeApp(tester, db);
  });
}
