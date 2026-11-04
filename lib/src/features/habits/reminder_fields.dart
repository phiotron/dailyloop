import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/database.dart';
import '../../providers.dart';

/// Danh sách giờ nhắc trong màn soạn (AC-17). Lần đầu thêm giờ nhắc hoặc
/// chọn chuông thì giải thích rồi mới xin quyền (AC-18, AC-20, L-010).
class ReminderFields extends ConsumerWidget {
  const ReminderFields({
    super.key,
    required this.reminders,
    required this.onChanged,
    this.beforePick,
  });

  /// Danh sách được sửa trực tiếp; gọi [onChanged] sau mỗi lần sửa.
  final List<({int minute, ReminderKind kind})> reminders;
  final VoidCallback onChanged;

  /// Gọi trước khi mở hộp chọn giờ (bỏ con trỏ khỏi ô nhập).
  final VoidCallback? beforePick;

  static const max = 5;

  Future<TimeOfDay?> _pickTime(BuildContext context, int minute) {
    beforePick?.call();
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    );
  }

  Future<bool> _explain(BuildContext context, String title, String body) async {
    final l = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.notNow),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.allow),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Xin các quyền còn thiếu cho kiểu nhắc [kind], mỗi quyền có giải thích
  /// trước. Từ chối thì vẫn lưu giờ nhắc, chỉ hiện cảnh báo (AC-18).
  Future<void> _ensurePermissions(
    BuildContext context,
    WidgetRef ref,
    ReminderKind kind,
  ) async {
    final l = AppLocalizations.of(context);
    final gateway = ref.read(reminderGatewayProvider);
    final p = await gateway.permissions();
    if (!p.notifications && context.mounted) {
      if (await _explain(context, l.permNotifTitle, l.permNotifBody)) {
        await gateway.requestNotifications();
      }
    }
    if (!p.exactAlarms && context.mounted) {
      if (await _explain(context, l.permExactTitle, l.permExactBody)) {
        await gateway.requestExactAlarms();
      }
    }
    if (kind == ReminderKind.alarm && !p.fullScreen && context.mounted) {
      if (await _explain(context, l.permFullTitle, l.permFullBody)) {
        await gateway.requestFullScreen();
      }
    }
    ref.invalidate(reminderPermissionsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final perms = ref.watch(reminderPermissionsProvider).value;
    final hasAlarm = reminders.any((r) => r.kind == ReminderKind.alarm);
    final warnings = <String>[
      if (reminders.isNotEmpty && perms != null) ...[
        if (!perms.notifications) l.warnNotifications,
        if (perms.notifications && !perms.exactAlarms) l.warnExact,
        if (perms.notifications && hasAlarm && !perms.fullScreen)
          l.warnFullScreen,
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, r) in reminders.indexed)
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: Icon(
                      r.kind == ReminderKind.alarm
                          ? Icons.alarm
                          : Icons.notifications_outlined,
                    ),
                    title: Text(
                      MaterialLocalizations.of(context).formatTimeOfDay(
                        TimeOfDay(hour: r.minute ~/ 60, minute: r.minute % 60),
                      ),
                    ),
                    subtitle: DropdownButton<ReminderKind>(
                      value: r.kind,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(
                          value: ReminderKind.notification,
                          child: Text(l.reminderNotification),
                        ),
                        DropdownMenuItem(
                          value: ReminderKind.alarm,
                          child: Text(l.reminderAlarm),
                        ),
                      ],
                      onChanged: (k) async {
                        reminders[i] = (minute: r.minute, kind: k!);
                        onChanged();
                        if (k == ReminderKind.alarm) {
                          await _ensurePermissions(context, ref, k);
                        }
                      },
                    ),
                    onTap: () async {
                      final t = await _pickTime(context, r.minute);
                      if (t == null) return;
                      reminders[i] = (
                        minute: t.hour * 60 + t.minute,
                        kind: r.kind,
                      );
                      onChanged();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: l.removeReminder,
                  onPressed: () {
                    reminders.removeAt(i);
                    onChanged();
                  },
                ),
              ],
            ),
          ),
        if (reminders.length < max)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton.icon(
                icon: const Icon(Icons.add_alarm),
                label: Text(l.addReminder),
                onPressed: () async {
                  final t = await _pickTime(context, 8 * 60);
                  if (t == null || !context.mounted) return;
                  reminders.add((
                    minute: t.hour * 60 + t.minute,
                    kind: ReminderKind.notification,
                  ));
                  onChanged();
                  await _ensurePermissions(
                    context,
                    ref,
                    ReminderKind.notification,
                  );
                },
              ),
            ),
          ),
        for (final w in warnings)
          ListTile(
            leading: Icon(Icons.warning_amber, color: theme.colorScheme.error),
            title: Text(w),
            trailing: TextButton(
              onPressed: () async {
                final gateway = ref.read(reminderGatewayProvider);
                if (w == l.warnExact) {
                  await gateway.requestExactAlarms();
                } else if (w == l.warnFullScreen) {
                  await gateway.requestFullScreen();
                } else {
                  await gateway.openNotificationSettings();
                }
                ref.invalidate(reminderPermissionsProvider);
              },
              child: Text(l.openSettings),
            ),
          ),
      ],
    );
  }
}
