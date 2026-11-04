import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../data/database.dart';
import '../data/settings_repository.dart';
import 'reminder_service.dart';

/// Chữ thông báo khi không có giao diện (chạy từ bộ nhận hệ thống): ngôn ngữ
/// người dùng đã chọn, không thì ngôn ngữ máy, không hỗ trợ thì tiếng Anh.
Future<ReminderTexts> backgroundTexts(
  AppDatabase db,
  Locale deviceLocale,
) async {
  final saved = await SettingsRepository(db)
      .readValue(SettingsRepository.localeKey);
  final code = saved ?? deviceLocale.languageCode;
  final supported = AppLocalizations.supportedLocales.any(
    (l) => l.languageCode == code,
  );
  final l = lookupAppLocalizations(Locale(supported ? code : 'en'));
  return ReminderTexts(
    channelReminders: l.channelReminders,
    channelAlarms: l.channelAlarms,
    body: '',
    done: l.actionDone,
    snooze: l.actionSnooze,
    dismiss: l.actionDismiss,
  );
}

/// Đặt lại toàn bộ giờ nhắc theo giờ và múi giờ hiện tại của máy (AC-21).
/// Dùng khi giờ hoặc múi giờ đổi lúc app đang tắt: giờ nhắc lưu theo giờ địa
/// phương ("8:00 mỗi ngày") nên phải tính lại các thời điểm tuyệt đối.
Future<void> resyncRemindersInBackground({
  required AppDatabase db,
  required ReminderGateway gateway,
  required DateTime Function() clock,
  required Locale deviceLocale,
}) async {
  final texts = await backgroundTexts(db, deviceLocale);
  await ReminderSync(
    db: db,
    gateway: gateway,
    clock: clock,
    texts: () => texts,
  ).syncNow();
}

/// Điểm vào Dart cho `TimeChangeReceiver.kt` (Android): chạy trong một
/// FlutterEngine không giao diện khi máy báo đổi giờ, đổi múi giờ, khởi động
/// lại hoặc cập nhật app. Xong thì báo lại cho Kotlin để giải phóng engine.
@pragma('vm:entry-point')
Future<void> timeChangedMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  try {
    final gateway = PluginReminderGateway(database: db);
    await gateway.init();
    await resyncRemindersInBackground(
      db: db,
      gateway: gateway,
      clock: DateTime.now,
      deviceLocale: PlatformDispatcher.instance.locale,
    );
  } finally {
    await db.close();
    try {
      await const MethodChannel('dailyloop/background')
          .invokeMethod<void>('done');
    } on MissingPluginException {
      // Không chạy từ bộ nhận (ví dụ gọi tay khi thử): bỏ qua.
    }
  }
}
