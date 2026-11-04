import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../data/database.dart' hide Priority;
import '../features/lock/app_lock.dart';
import '../providers.dart';
import 'reminder_planner.dart';
import '../widget/home_widget_sync.dart';
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
  HomeWidgetSync? _widget;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    pendingNotificationTap.addListener(_openTap);
    // Chạm tên một mục trên widget mở app tại mục đó (AC-39).
    const MethodChannel('dailyloop/system').setMethodCallHandler((call) async {
      if (call.method == 'openRoute' && call.arguments is String) {
        widget.router.push(call.arguments as String);
      }
    });
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
    final widgetTexts = HomeWidgetTexts(
      title: l.today,
      empty: l.emptyToday,
      allDone: l.widgetAllDone,
      leftOf: (n) => l.widgetLeft(n),
    );
    if (_widget == null) {
      _widget = HomeWidgetSync(
        db: ref.read(databaseProvider),
        gateway: ref.read(homeWidgetGatewayProvider),
        clock: ref.read(clockProvider),
        texts: () => widgetTexts,
        // Có khóa PIN thì widget chỉ hiện số mục còn lại, không hiện tên (AC-41).
        hideNames: _hideNames(ref.read(pinEnabledProvider)),
      )..start();
    } else {
      _widget!.texts = () => widgetTexts;
    }
    _widget!.schedule();
    if (_sync == null) {
      _sync = ReminderSync(
        db: ref.read(databaseProvider),
        gateway: ref.read(reminderGatewayProvider),
        clock: ref.read(clockProvider),
        texts: () => texts,
      )..start();
      _sync!.schedule();
      ref
          .read(pomodoroRepositoryProvider)
          .settleIfFinished(ref.read(clockProvider)());
    } else {
      // Đổi ngôn ngữ thì đặt lại để chữ trên thông báo theo ngôn ngữ mới.
      _sync!.texts = () => texts;
      _sync!.schedule();
    }
  }

  void _onResume() {
    // Máy ngủ qua nửa đêm thì bộ hẹn giờ có thể chưa chạy: đọc lại ngày (BUG-001).
    ref.read(todayProvider.notifier).refresh();
    // Pomodoro hết giờ lúc app đóng: cộng phút vào thói quen ngay (AC-37, AC-38).
    ref
        .read(pomodoroRepositoryProvider)
        .settleIfFinished(ref.read(clockProvider)());
    // Nút "Xong" bấm từ thông báo ghi ở tiến trình nền, màn hình không tự biết.
    ref.invalidate(dayItemsProvider);
    ref.invalidate(taskItemsProvider);
    ref.invalidate(reminderPermissionsProvider);
    _sync?.schedule();
    _widget?.schedule();
  }

  void _openTap() {
    final r = pendingNotificationTap.value;
    if (r == null) return;
    pendingNotificationTap.value = null;
    if (r.payload == pomodoroPayload) {
      widget.router.push('/pomodoro');
      return;
    }
    final p = parsePayload(r.payload);
    if (p == null) return;
    if (p.kind == ReminderKind.alarm) {
      // App đang khóa: chuông hiện ngay trên màn khóa, Xong/Hoãn/Tắt không
      // cần PIN (AC-46).
      if (ref.read(lockProvider) != AppLockState.unlocked) {
        ref.read(lockedAlarmProvider.notifier).set(r);
        return;
      }
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
    _widget?.dispose();
    super.dispose();
  }

  /// Chưa biết hoặc lỗi đọc bộ nhớ an toàn thì ẩn tên cho chắc (AC-41).
  static bool _hideNames(AsyncValue<bool> pin) => pin.value ?? true;

  @override
  Widget build(BuildContext context) {
    // Bật hay tắt PIN thì dựng lại dữ liệu widget ngay (AC-41).
    ref.listen(pinEnabledProvider, (_, next) {
      _widget
        ?..hideNames = _hideNames(next)
        ..schedule();
    });
    // Chuông chạm lúc đang khóa mà app mở khóa luôn (không có PIN): mở màn
    // chuông thường.
    ref.listen(lockProvider, (_, next) {
      final alarm = ref.read(lockedAlarmProvider);
      if (next == AppLockState.unlocked && alarm != null) {
        ref.read(lockedAlarmProvider.notifier).set(null);
        widget.router.push('/alarm', extra: alarm);
      }
    });
    return widget.child;
  }
}
