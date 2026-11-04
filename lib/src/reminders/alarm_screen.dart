import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/database.dart' hide Priority;
import '../providers.dart';
import 'reminder_planner.dart';
import 'reminder_service.dart';

/// Màn chuông báo thức toàn màn hình: Xong, Hoãn 10 phút, Tắt (AC-20).
class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key, required this.response});

  final NotificationResponse response;

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> {
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
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
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
    final time = TimeOfDay.now().format(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.alarm,
                size: 96,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(height: 16),
              Text(
                time,
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
