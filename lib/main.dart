import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/data/database.dart';
import 'src/providers.dart';
import 'src/reminders/reminder_host.dart';
import 'src/reminders/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Chỉ màn hình dọc (SPEC mục 5); Android còn khóa trong manifest.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Một kết nối cơ sở dữ liệu cho cả giao diện lẫn nút "Xong" trên thông báo
  // (D-007), sống suốt vòng đời app.
  final database = AppDatabase();
  // Chạm thông báo hoặc chuông mở app thì chuyển cho ReminderHost (AC-20).
  final reminders = PluginReminderGateway(
    database: database,
    onTap: (r) => pendingNotificationTap.value = r,
  );
  await reminders.init();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        reminderGatewayProvider.overrideWithValue(reminders),
      ],
      child: const DailyLoopApp(),
    ),
  );
}
