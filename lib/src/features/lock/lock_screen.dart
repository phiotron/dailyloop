import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse, NotificationResponseType;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/database.dart' hide Priority;
import '../../providers.dart';
import '../../reminders/reminder_planner.dart';
import '../../reminders/reminder_service.dart';
import '../backup/data_actions.dart';
import 'app_lock.dart';
import 'pin_pad.dart';

/// Màn khóa phủ lên toàn app khi bật PIN (AC-46, AC-47). Có Navigator riêng
/// vì nằm ngoài Navigator của router.
class LockScreen extends ConsumerWidget {
  const LockScreen({super.key, required this.checking, this.onReset});

  final bool checking;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = Theme.of(context).colorScheme.surface;
    if (checking) {
      return ColoredBox(color: background, child: const SizedBox.expand());
    }
    return Navigator(
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (_) => _LockBody(onReset: onReset)),
    );
  }
}

class _LockBody extends ConsumerStatefulWidget {
  const _LockBody({this.onReset});

  final VoidCallback? onReset;

  @override
  ConsumerState<_LockBody> createState() => _LockBodyState();
}

class _LockBodyState extends ConsumerState<_LockBody> {
  String? _error;

  /// "Quên mã": giải thích rồi xóa toàn bộ dữ liệu qua hai bước xác nhận (AC-47).
  Future<void> _forgot() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.forgotPin),
        content: Text(l.forgotPinBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.deleteAll),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (await deleteEverything(context, ref, onReset: widget.onReset)) {
      ref.read(lockProvider.notifier).unlockAfterReset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final alarm = ref.watch(lockedAlarmProvider);
    if (alarm != null) return _LockedAlarm(response: alarm);
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  PinPad(
                    title: l.enterPin,
                    error: _error,
                    onCompleted: (pin) async {
                      final ok = await ref
                          .read(lockProvider.notifier)
                          .unlock(pin);
                      if (!ok && mounted) setState(() => _error = l.wrongPin);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _forgot, child: Text(l.forgotPin)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chuông báo thức hiện trên màn khóa: Xong, Hoãn, Tắt không cần PIN; muốn mở
/// app thì phải nhập PIN (AC-46).
class _LockedAlarm extends ConsumerStatefulWidget {
  const _LockedAlarm({required this.response});

  final NotificationResponse response;

  @override
  ConsumerState<_LockedAlarm> createState() => _LockedAlarmState();
}

class _LockedAlarmState extends ConsumerState<_LockedAlarm> {
  Activity? _activity;

  @override
  void initState() {
    super.initState();
    final p = parsePayload(widget.response.payload);
    if (p != null) {
      ref.read(activityRepositoryProvider).find(p.activityId).then((a) {
        if (mounted) setState(() => _activity = a);
      });
    }
  }

  Future<void> _act(String actionId) async {
    final r = widget.response;
    await handleNotificationAction(
      NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        id: r.id,
        actionId: actionId,
        payload: r.payload,
      ),
      db: ref.read(databaseProvider),
    );
    // Xử lý xong thì về màn nhập PIN, không vào app.
    ref.read(lockedAlarmProvider.notifier).set(null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = _activity;
    final yesNo =
        a == null ||
        a.kind == ActivityKind.task ||
        a.evaluation == Evaluation.yesNo;
    final onColor = theme.colorScheme.onPrimaryContainer;
    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.alarm, size: 96, color: onColor),
              const SizedBox(height: 16),
              Text(
                TimeOfDay.now().format(context),
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(color: onColor),
              ),
              const SizedBox(height: 8),
              Text(
                l.alarmFor,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              Semantics(
                header: true,
                child: Text(
                  a?.name ?? '',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const Spacer(),
              if (yesNo)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(l.actionDone),
                  onPressed: () => _act(actionDone),
                ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                icon: const Icon(Icons.snooze),
                label: Text(l.actionSnooze),
                onPressed: () => _act(actionSnooze),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                icon: const Icon(Icons.alarm_off),
                label: Text(l.actionDismiss),
                onPressed: () => _act(actionDismiss),
              ),
              const SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () =>
                    ref.read(lockedAlarmProvider.notifier).set(null),
                child: Text(l.lockedOpenApp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
