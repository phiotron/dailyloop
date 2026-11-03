import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dailyloop/src/app.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/settings_repository.dart';
import 'package:dailyloop/src/providers.dart';

/// Ngày cố định cho test.
final testToday = DateTime(2026, 11, 3, 9);

/// Cơ sở dữ liệu trong bộ nhớ. Với widget test phải tạo bên trong thân
/// `testWidgets`; tạo ở `setUp` thì thao tác đầu tiên bị treo (APP-001).
AppDatabase memoryDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Chờ thao tác cơ sở dữ liệu thật xong rồi vẽ lại.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }
}

/// Mở app với cơ sở dữ liệu mới, ngôn ngữ [localeCode], ngày [testToday].
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  String? localeCode = 'vi',
  AppDatabase? db,
}) async {
  usePhoneScreen(tester);
  final database = db ?? memoryDatabase();
  await tester.runAsync(
    () => SettingsRepository(database).setLocaleCode(localeCode),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => testToday),
      ],
      child: DailyLoopApp(router: createRouter()),
    ),
  );
  await settle(tester);
  return database;
}

/// Màn hình dọc 360×800 dp, bề rộng nhỏ nhất SPEC hỗ trợ (mục 5).
void usePhoneScreen(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Gỡ cây widget và đóng cơ sở dữ liệu để không còn stream treo khi test kết thúc.
Future<void> disposeApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(db.close);
}
