import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pin_service.dart';
import '../../providers.dart';
import 'lock_screen.dart';

final secretStoreProvider = Provider<SecretStore>(
  (ref) => const SecureSecretStore(),
);

final pinServiceProvider = Provider<PinService>(
  (ref) => PinService(ref.watch(secretStoreProvider)),
);

/// Bật khóa PIN hay chưa, để màn Cài đặt hiện đúng công tắc và widget ẩn tên
/// (AC-41). Lỗi đọc bộ nhớ an toàn thì coi như đang bật (an toàn hơn).
final pinEnabledProvider = FutureProvider<bool>((ref) async {
  try {
    return await ref.watch(pinServiceProvider).isEnabled();
  } catch (_) {
    return true;
  }
});

enum AppLockState { checking, locked, unlocked }

/// Trạng thái khóa app: khóa khi mở app và khi quay lại sau hơn 1 phút ở nền
/// (AC-46).
class LockNotifier extends Notifier<AppLockState> {
  static const relockAfter = Duration(minutes: 1);

  DateTime? _hiddenAt;

  @override
  AppLockState build() {
    _init();
    return AppLockState.checking;
  }

  Future<void> _init() async {
    var enabled = true;
    try {
      enabled = await ref.read(pinServiceProvider).isEnabled();
    } catch (_) {
      // Không đọc được bộ nhớ an toàn (Keystore/Keychain hỏng): coi như đang
      // khóa để người dùng thấy màn khóa và nút "Quên mã" thay vì màn trắng.
    }
    state = enabled ? AppLockState.locked : AppLockState.unlocked;
  }

  void onHidden() => _hiddenAt ??= ref.read(clockProvider)();

  Future<void> onResumed() async {
    final hiddenAt = _hiddenAt;
    _hiddenAt = null;
    if (state != AppLockState.unlocked || hiddenAt == null) return;
    if (ref.read(clockProvider)().difference(hiddenAt) <= relockAfter) return;
    var enabled = true;
    try {
      enabled = await ref.read(pinServiceProvider).isEnabled();
    } catch (_) {
      // Như _init: lỗi đọc thì khóa.
    }
    if (enabled) state = AppLockState.locked;
  }

  Future<bool> unlock(String pin) async {
    var ok = false;
    try {
      ok = await ref.read(pinServiceProvider).verify(pin);
    } catch (_) {
      // Lỗi bộ nhớ an toàn: không mở khóa.
    }
    if (ok) state = AppLockState.unlocked;
    return ok;
  }

  /// Mở khóa sau khi người dùng đã xóa toàn bộ dữ liệu vì quên mã (AC-47).
  void unlockAfterReset() => state = AppLockState.unlocked;
}

final lockProvider = NotifierProvider<LockNotifier, AppLockState>(
  LockNotifier.new,
);

/// Chuông báo thức đang chờ hiện trên màn khóa (AC-46). `ReminderHost` đặt vào
/// khi chuông được chạm lúc app đang khóa; màn khóa hiện chuông với Xong,
/// Hoãn, Tắt mà không cần PIN.
class LockedAlarmNotifier extends Notifier<NotificationResponse?> {
  @override
  NotificationResponse? build() => null;

  void set(NotificationResponse? response) => state = response;
}

final lockedAlarmProvider =
    NotifierProvider<LockedAlarmNotifier, NotificationResponse?>(
      LockedAlarmNotifier.new,
    );

/// Phủ màn khóa lên app khi cần; phần app bên dưới chỉ bị ẩn (`Offstage`) nên
/// không mất trạng thái. Theo dõi app ra nền và quay lại để khóa lại (AC-46).
class AppLockOverlay extends ConsumerStatefulWidget {
  const AppLockOverlay({super.key, required this.child, this.onReset});

  final Widget child;

  /// Gọi sau khi quên mã và xóa hết dữ liệu: đưa router về màn đầu.
  final VoidCallback? onReset;

  @override
  ConsumerState<AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends ConsumerState<AppLockOverlay> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onHide: () => ref.read(lockProvider.notifier).onHidden(),
      onResume: () => ref.read(lockProvider.notifier).onResumed(),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(lockProvider);
    final unlocked = lock == AppLockState.unlocked;
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(offstage: !unlocked, child: widget.child),
        if (!unlocked)
          LockScreen(
            checking: lock == AppLockState.checking,
            onReset: widget.onReset,
          ),
      ],
    );
  }
}
