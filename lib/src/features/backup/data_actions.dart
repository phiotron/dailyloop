import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/backup.dart';
import '../../data/csv_export.dart';
import '../../providers.dart';
import '../../reminders/reminder_service.dart';
import '../../ui/messenger.dart';
import '../../widget/home_widget_sync.dart';
import '../lock/app_lock.dart';
import 'file_gateway.dart';

final fileGatewayProvider = Provider<FileGateway>(
  (ref) => const PluginFileGateway(),
);

String _stamp(DateTime d) =>
    '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}'
    '-${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}';

/// Vùng của nút vừa bấm, để iPad neo bảng chia sẻ.
Rect? _originOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Xuất bản sao lưu `.dailyloop` rồi mở bảng chia sẻ (AC-42).
Future<void> exportBackupFile(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final origin = _originOf(context);
  final now = ref.read(clockProvider)();
  try {
    final json = await exportBackup(ref.read(databaseProvider), now: now);
    await ref
        .read(fileGatewayProvider)
        .share(
          'dailyloop-${_stamp(now)}.dailyloop',
          json,
          'application/json',
          origin: origin,
        );
  } catch (_) {
    showMessage(l.exportFailed);
  }
}

/// Xuất lịch sử ra CSV (AC-44).
Future<void> exportCsvFile(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final origin = _originOf(context);
  final now = ref.read(clockProvider)();
  try {
    final csv = await buildHistoryCsv(
      ref.read(databaseProvider),
      CsvLabels(
        habit: l.csvHabit,
        task: l.csvTask,
        done: l.csvDone,
        notDone: l.csvNotDone,
        skipped: l.skipped,
      ),
    );
    await ref
        .read(fileGatewayProvider)
        .share('dailyloop-${_stamp(now)}.csv', csv, 'text/csv', origin: origin);
  } catch (_) {
    showMessage(l.exportFailed);
  }
}

/// Đặt lại toàn bộ giờ nhắc theo dữ liệu hiện tại (AC-43, AC-52).
Future<void> resyncReminders(WidgetRef ref, AppLocalizations l) => ReminderSync(
  db: ref.read(databaseProvider),
  gateway: ref.read(reminderGatewayProvider),
  clock: ref.read(clockProvider),
  texts: () => ReminderTexts(
    channelReminders: l.channelReminders,
    channelAlarms: l.channelAlarms,
    body: '',
    done: l.actionDone,
    snooze: l.actionSnooze,
    dismiss: l.actionDismiss,
  ),
).syncNow();

/// Chọn file sao lưu, kiểm tra, hỏi xác nhận rồi khôi phục (AC-43). File hỏng
/// thì báo lỗi và giữ nguyên dữ liệu.
Future<void> restoreFromFile(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final db = ref.read(databaseProvider);
  final String? content;
  try {
    content = await ref.read(fileGatewayProvider).pickText();
  } catch (_) {
    showMessage(l.restoreFailed);
    return;
  }
  if (content == null || !context.mounted) return;
  try {
    validateBackup(db, content);
  } on BackupFormatException {
    showMessage(l.restoreFailed);
    return;
  }
  if (!context.mounted) return;
  if (!await _confirm(context, l.restore, l.restoreConfirm, l.restore)) return;
  try {
    await importBackup(db, content);
  } on BackupFormatException {
    showMessage(l.restoreFailed);
    return;
  }
  ref.invalidate(habitFilterProvider);
  await resyncReminders(ref, l);
  showMessage(l.restoreDone);
}

/// Xóa toàn bộ dữ liệu sau hai lần xác nhận (AC-47, AC-52): xóa cơ sở dữ liệu,
/// cài đặt và PIN, hủy mọi giờ nhắc, làm trống widget. Trả về true nếu đã xóa.
/// [onReset] đưa router về màn đầu; màn chào hiện lại vì cài đặt đã bị xóa.
Future<bool> deleteEverything(
  BuildContext context,
  WidgetRef ref, {
  VoidCallback? onReset,
}) async {
  final l = AppLocalizations.of(context);
  if (!await _confirm(context, l.deleteAll, l.deleteAllConfirm, l.delete)) {
    return false;
  }
  if (!context.mounted) return false;
  if (!await _confirm(context, l.deleteAll, l.deleteAllConfirm2, l.deleteAll)) {
    return false;
  }
  final db = ref.read(databaseProvider);
  await deleteAllData(db);
  await ref.read(pinServiceProvider).disable();
  ref.invalidate(pinEnabledProvider);
  ref.invalidate(habitFilterProvider);
  ref.invalidate(selectedDayProvider);
  ref.invalidate(taskFilterProvider);
  // Dữ liệu trống nên lịch nhắc rỗng: mọi lần nhắc và lần hoãn bị hủy. Hẹn giờ
  // Pomodoro nằm ngoài lịch nhắc nên hủy riêng.
  await resyncReminders(ref, l);
  await ref.read(reminderGatewayProvider).cancelTimerEnd();
  await HomeWidgetSync(
    db: db,
    gateway: ref.read(homeWidgetGatewayProvider),
    clock: ref.read(clockProvider),
    texts: () => HomeWidgetTexts(
      title: l.today,
      empty: l.emptyToday,
      allDone: l.widgetAllDone,
      leftOf: (n) => l.widgetLeft(n),
    ),
  ).syncNow();
  onReset?.call();
  showMessage(l.deleteAllDone);
  return true;
}

Future<bool> _confirm(
  BuildContext context,
  String title,
  String body,
  String action,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
