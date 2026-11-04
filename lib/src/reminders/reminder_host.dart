import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/database.dart' hide Priority;
import '../providers.dart';
import 'reminder_planner.dart';
import 'reminder_service.dart';

/// Lần chạm thông báo đang chờ xử lý; `main` ghi vào khi app được mở từ
/// thông báo hoặc chuông toàn màn hình.
final pendingNotificationTap = ValueNotifier<NotificationResponse?>(null);

/// Giữ lịch nhắc luôn khớp dữ liệu: đặt lại khi mở app, quay lại app và khi
/// dữ liệu đổi (D-007). Mở màn chuông khi người dùng chạm chuông (AC-20).
class ReminderHost extends ConsumerStatefulWidget {
  const ReminderHost({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<ReminderHost> createState() => _ReminderHostState();
}

class _ReminderHostState extends ConsumerState<ReminderHost> {
  ReminderSync? _sync;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    pendingNotificationTap.addListener(_openTap);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openTap());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l = AppLocalizations.of(context);
    final texts = ReminderTexts(
      channelReminders: l.channelReminders,
      channelAlarms: l.channelAlarms,
      body: '',
      done: l.actionDone,
      snooze: l.actionSnooze,
      dismiss: l.actionDismiss,
    );
    if (_sync == null) {
      _sync = ReminderSync(
        db: ref.read(databaseProvider),
        gateway: ref.read(reminderGatewayProvider),
        clock: ref.read(clockProvider),
        texts: () => texts,
      )..start();
      _sync!.schedule();
    } else {
      // Đổi ngôn ngữ thì đặt lại để chữ trên thông báo theo ngôn ngữ mới.
      _sync!.texts = () => texts;
      _sync!.schedule();
    }
  }

  void _onResume() {
    // Nút "Xong" bấm từ thông báo ghi ở tiến trình nền, màn hình không tự biết.
    ref.invalidate(dayItemsProvider);
    ref.invalidate(taskItemsProvider);
    ref.invalidate(reminderPermissionsProvider);
    _sync?.schedule();
  }

  void _openTap() {
    final r = pendingNotificationTap.value;
    if (r == null) return;
    pendingNotificationTap.value = null;
    final p = parsePayload(r.payload);
    if (p == null) return;
    if (p.kind == ReminderKind.alarm) {
      widget.router.push('/alarm', extra: r);
    } else {
      widget.router.go('/');
    }
  }

  @override
  void dispose() {
    pendingNotificationTap.removeListener(_openTap);
    _lifecycle.dispose();
    _sync?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
