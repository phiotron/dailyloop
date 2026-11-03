import 'package:dailyloop/src/data/settings_repository.dart';
import 'package:dailyloop/src/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

ThemeMode _themeMode(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

void main() {
  testWidgets('chữ giao diện theo ngôn ngữ đã chọn (AC-48)', (tester) async {
    final db = await pumpApp(tester);
    expect(find.widgetWithText(AppBar, 'Hôm nay'), findsOneWidget);
    expect(find.text('Hôm nay chưa có việc nào'), findsOneWidget);

    await tester.runAsync(() => SettingsRepository(db).setLocaleCode('en'));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'Today'), findsOneWidget);
    expect(find.text('Nothing planned for today'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('đổi giao diện tối trong Cài đặt (AC-48)', (tester) async {
    final db = await pumpApp(tester);
    expect(_themeMode(tester), ThemeMode.system);

    await tester.tap(find.byTooltip('Cài đặt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tối'));
    await settle(tester);
    expect(_themeMode(tester), ThemeMode.dark);
    await disposeApp(tester, db);
  });

  testWidgets('đổi ngôn ngữ và ngày đầu tuần trong Cài đặt (AC-48)', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tester.tap(find.byTooltip('Cài đặt'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chủ Nhật'));
    await settle(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    expect(container.read(weekStartProvider).value, DateTime.sunday);

    await tester.tap(find.text('English'));
    await settle(tester);
    expect(find.text('Settings'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('cài đặt còn nguyên khi mở lại app với cùng dữ liệu', (
    tester,
  ) async {
    final db = memoryDatabase();
    await tester.runAsync(
      () => SettingsRepository(db).setThemeMode(ThemeMode.light),
    );
    await pumpApp(tester, db: db);
    expect(_themeMode(tester), ThemeMode.light);
    await disposeApp(tester, db);
  });

  testWidgets('màn Cài đặt không tràn ở cỡ chữ 200% (AC-50)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final db = await pumpApp(tester);
    await tester.tap(find.byTooltip('Cài đặt'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await disposeApp(tester, db);
  });
}
