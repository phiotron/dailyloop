import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart' hide Priority;
import '../data/dates.dart';
import '../data/day_repository.dart';
import '../data/entry_repository.dart';
import 'reminder_planner.dart';

/// Chữ hiện trên thông báo, lấy từ file dịch lúc đặt lịch.
class ReminderTexts {
  const ReminderTexts({
    required this.channelReminders,
    required this.channelAlarms,
    required this.body,
    required this.done,
    required this.snooze,
    required this.dismiss,
  });

  final String channelReminders;
  final String channelAlarms;
  final String body;
  final String done;
  final String snooze;
  final String dismiss;
}

/// Trạng thái các quyền liên quan tới nhắc giờ (AC-18, AC-20).
class ReminderPermissions {
  const ReminderPermissions({
    required this.notifications,
    required this.exactAlarms,
    required this.fullScreen,
  });

  static const allGranted = ReminderPermissions(
    notifications: true,
    exactAlarms: true,
    fullScreen: true,
  );

  final bool notifications;
  final bool exactAlarms;
  final bool fullScreen;
}

/// Phần làm việc với hệ điều hành; test thay bằng bản giả.
abstract class ReminderGateway {
  Future<void> init();
  Future<ReminderPermissions> permissions();
  Future<bool> requestNotifications();
  Future<bool> requestExactAlarms();
  Future<bool> requestFullScreen();
  Future<void> openNotificationSettings();

  /// Báo khi giai đoạn Pomodoro kết thúc (AC-36), kể cả lúc app đóng.
  Future<void> scheduleTimerEnd(
    DateTime at, {
    required String title,
    required String body,
  });
  Future<void> cancelTimerEnd();

  /// Thay toàn bộ lịch đang chờ bằng [plan]. [liveItems] là các mục còn cần
  /// làm hôm nay, dạng `activityId|date`; lần hoãn của mục không còn trong
  /// đó (đã xóa hoặc đã xong) thì bị hủy.
  Future<void> replaceAll(
    List<PlannedReminder> plan,
    ReminderTexts texts, {
    Set<String> liveItems = const {},
  });
}

/// Mã hành động trên thông báo.
const actionDone = 'done';
const actionSnooze = 'snooze';
const actionDismiss = 'dismiss';
const snoozeMinutes = 10;

/// Mã thông báo và nội dung gửi kèm của đồng hồ Pomodoro.
const pomodoroNotificationId = 0x3FFFFFFF;
const pomodoroPayload = 'pomodoro';

/// Chuông tự tắt sau 5 phút (AC-20).
const alarmTimeout = Duration(minutes: 5);

const _channelReminders = 'reminders';
const _channelAlarms = 'alarms_v1';
const _system = MethodChannel('dailyloop/system');

/// Hành động bấm trên thông báo khi app không mở. Chạy ở tiến trình nền
/// riêng nên phải tự mở cơ sở dữ liệu (D-007).
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationAction(NotificationResponse r) async {
  await handleNotificationAction(r);
}

/// Xử lý nút Xong, Hoãn, Tắt (AC-19, AC-20). Trả về true nếu đã xử lý.
Future<bool> handleNotificationAction(
  NotificationResponse r, {
  AppDatabase? db,
}) async {
  final p = parsePayload(r.payload);
  if (p == null) return false;
  final plugin = FlutterLocalNotificationsPlugin();
  switch (r.actionId) {
    case actionDone:
      final database = db ?? AppDatabase();
      try {
        await EntryRepository(database).setValue(p.activityId, p.date, 1);
      } finally {
        if (db == null) await database.close();
      }
      if (r.id != null) await plugin.cancel(id: r.id!);
      return true;
    case actionSnooze:
      if (r.id != null) await plugin.cancel(id: r.id!);
      final database = db ?? AppDatabase();
      Activity? a;
      try {
        a = await (database.select(
          database.activities,
        )..where((x) => x.id.equals(p.activityId))).getSingleOrNull();
      } finally {
        if (db == null) await database.close();
      }
      if (a == null) return true;
      await _ensureTimeZone();
      final yesNo =
          a.kind == ActivityKind.task || a.evaluation == Evaluation.yesNo;
      // Lần hoãn đánh dấu bằng bit 30 để lần đặt lại lịch không xóa nó.
      await plugin.zonedSchedule(
        id: (r.id ?? 0) | 0x40000000,
        scheduledDate: tz.TZDateTime.now(tz.local)
            .add(const Duration(minutes: snoozeMinutes)),
        notificationDetails: p.kind == ReminderKind.alarm
            ? _alarmDetails(_lastTexts, yesNo: yesNo)
            : NotificationDetails(android: _reminderAndroid(_lastTexts, yesNo)),
        androidScheduleMode:
            await plugin
                    .resolvePlatformSpecificImplementation<
                      AndroidFlutterLocalNotificationsPlugin
                    >()
                    ?.canScheduleExactNotifications() ==
                true
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        title: a.name,
        payload: r.payload,
      );
      return true;
    case actionDismiss:
      if (r.id != null) await plugin.cancel(id: r.id!);
      return true;
  }
  return false;
}

var _tzReady = false;

Future<void> _ensureTimeZone() async {
  if (_tzReady) return;
  tzdata.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } catch (_) {
    // Không đọc được múi giờ thì dùng UTC, giờ nhắc sẽ lệch; ghi log để thấy.
    debugPrint('Không đọc được múi giờ máy, dùng UTC');
  }
  _tzReady = true;
}

/// Chữ dự phòng cho lần hoãn chạy ở tiến trình nền (không có file dịch).
var _lastTexts = const ReminderTexts(
  channelReminders: 'Reminders',
  channelAlarms: 'Alarms',
  body: '',
  done: 'Done',
  snooze: 'Snooze 10 min',
  dismiss: 'Dismiss',
);

AndroidNotificationDetails _reminderAndroid(ReminderTexts t, bool yesNo) =>
    AndroidNotificationDetails(
      _channelReminders,
      t.channelReminders,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      category: AndroidNotificationCategory.reminder,
      actions: [if (yesNo) AndroidNotificationAction(actionDone, t.done)],
    );

NotificationDetails _alarmDetails(ReminderTexts t, {bool yesNo = true}) =>
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channelAlarms,
        t.channelAlarms,
        importance: Importance.max,
        priority: Priority.max,
        icon: 'ic_notification',
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        // Âm thanh lặp lại tới khi người dùng bấm (FLAG_INSISTENT = 4).
        additionalFlags: Int32List.fromList([4]),
        timeoutAfter: alarmTimeout.inMilliseconds,
        ongoing: true,
        autoCancel: false,
        actions: [
          if (yesNo) AndroidNotificationAction(actionDone, t.done),
          AndroidNotificationAction(actionSnooze, t.snooze),
          AndroidNotificationAction(actionDismiss, t.dismiss),
        ],
      ),
    );

/// Bản thật dùng flutter_local_notifications.
class PluginReminderGateway implements ReminderGateway {
  PluginReminderGateway({this.onTap, this.database});

  /// Người dùng chạm thông báo hoặc chuông mở toàn màn hình.
  final void Function(NotificationResponse)? onTap;

  /// Cơ sở dữ liệu của app đang chạy. Nút "Xong" bấm lúc app đang mở phải
  /// ghi qua chính kết nối này, không thì các danh sách trên màn hình không
  /// biết dữ liệu đã đổi. Tiến trình nền (app đã đóng) tự mở kết nối riêng.
  final AppDatabase? database;

  final _plugin = FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> init() async {
    await _ensureTimeZone();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
      ),
      onDidReceiveNotificationResponse: (r) async {
        if (!await handleNotificationAction(r, db: database)) onTap?.call(r);
      },
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationAction,
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final r = launch?.notificationResponse;
    if (launch?.didNotificationLaunchApp == true && r != null) onTap?.call(r);
  }

  @override
  Future<ReminderPermissions> permissions() async {
    final android = _android;
    if (android == null) return ReminderPermissions.allGranted;
    bool full;
    try {
      full = await _system.invokeMethod<bool>('canUseFullScreenIntent') ?? true;
    } on MissingPluginException {
      full = true;
    }
    return ReminderPermissions(
      notifications: await android.areNotificationsEnabled() ?? true,
      exactAlarms: await android.canScheduleExactNotifications() ?? true,
      fullScreen: full,
    );
  }

  @override
  Future<bool> requestNotifications() async =>
      await _android?.requestNotificationsPermission() ?? true;

  @override
  Future<bool> requestExactAlarms() async =>
      await _android?.requestExactAlarmsPermission() ?? true;

  @override
  Future<bool> requestFullScreen() async =>
      await _android?.requestFullScreenIntentPermission() ?? true;

  @override
  Future<void> openNotificationSettings() =>
      _system.invokeMethod<void>('openNotificationSettings');

  @override
  Future<void> scheduleTimerEnd(
    DateTime at, {
    required String title,
    required String body,
  }) async {
    await _ensureTimeZone();
    final exact = await _android?.canScheduleExactNotifications() ?? true;
    await _plugin.zonedSchedule(
      id: pomodoroNotificationId,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro',
          'Pomodoro',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
        ),
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
      payload: pomodoroPayload,
    );
  }

  @override
  Future<void> cancelTimerEnd() => _plugin.cancel(id: pomodoroNotificationId);

  @override
  Future<void> replaceAll(
    List<PlannedReminder> plan,
    ReminderTexts texts, {
    Set<String> liveItems = const {},
  }) async {
    _lastTexts = texts;
    await _ensureTimeZone();
    final keep = {for (final p in plan) p.id};
    for (final pending in await _plugin.pendingNotificationRequests()) {
      if (pending.id & 0x40000000 != 0) {
        // Lần hoãn (bit 30): giữ tới khi tự báo, trừ khi mục đã xóa hoặc xong.
        final p = parsePayload(pending.payload);
        if (p == null || !liveItems.contains('${p.activityId}|${p.date}')) {
          await _plugin.cancel(id: pending.id);
        }
        continue;
      }
      if (pending.id == pomodoroNotificationId) continue;
      if (!keep.contains(pending.id)) await _plugin.cancel(id: pending.id);
    }
    final exact = await _android?.canScheduleExactNotifications() ?? true;
    for (final p in plan) {
      final alarm = p.kind == ReminderKind.alarm;
      await _plugin.zonedSchedule(
        id: p.id,
        scheduledDate: tz.TZDateTime.from(p.at, tz.local),
        notificationDetails: alarm
            ? _alarmDetails(texts, yesNo: p.yesNo)
            : NotificationDetails(android: _reminderAndroid(texts, p.yesNo)),
        // Không có quyền báo thức chính xác thì vẫn nhắc, có thể trễ (D-007).
        androidScheduleMode: !exact
            ? AndroidScheduleMode.inexactAllowWhileIdle
            : alarm
            ? AndroidScheduleMode.alarmClock
            : AndroidScheduleMode.exactAllowWhileIdle,
        title: p.title,
        body: texts.body.isEmpty ? null : texts.body,
        payload: p.payload,
      );
    }
  }
}

/// Bản giả cho test: ghi lại lịch đã đặt.
class FakeReminderGateway implements ReminderGateway {
  FakeReminderGateway({this.granted = ReminderPermissions.allGranted});

  ReminderPermissions granted;
  List<PlannedReminder> scheduled = const [];
  Set<String> live = const {};
  final requests = <String>[];

  @override
  Future<void> init() async {}

  @override
  Future<ReminderPermissions> permissions() async => granted;

  @override
  Future<bool> requestNotifications() async {
    requests.add('notifications');
    return granted.notifications;
  }

  @override
  Future<bool> requestExactAlarms() async {
    requests.add('exact');
    return granted.exactAlarms;
  }

  @override
  Future<bool> requestFullScreen() async {
    requests.add('fullScreen');
    return granted.fullScreen;
  }

  @override
  Future<void> openNotificationSettings() async => requests.add('settings');

  DateTime? timerEnd;

  @override
  Future<void> scheduleTimerEnd(
    DateTime at, {
    required String title,
    required String body,
  }) async => timerEnd = at;

  @override
  Future<void> cancelTimerEnd() async => timerEnd = null;

  @override
  Future<void> replaceAll(
    List<PlannedReminder> plan,
    ReminderTexts texts, {
    Set<String> liveItems = const {},
  }) async {
    scheduled = plan;
    live = liveItems;
  }
}

/// Đặt lại lịch nhắc mỗi khi dữ liệu đổi, chờ 500 ms để gộp nhiều lần ghi.
class ReminderSync {
  ReminderSync({
    required this.db,
    required this.gateway,
    required this.clock,
    required this.texts,
  });

  final AppDatabase db;
  final ReminderGateway gateway;
  final DateTime Function() clock;
  ReminderTexts Function() texts;

  StreamSubscription<void>? _sub;
  Timer? _debounce;

  void start() {
    _sub ??= db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            db.activities,
            db.schedules,
            db.reminders,
            db.entries,
            db.checklistMarks,
          ]),
        )
        .listen((_) => schedule());
  }

  void schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => syncNow());
  }

  Future<void> syncNow() async {
    final now = clock();
    final plan = await planReminders(db, now: now);
    // Mục còn cần làm hôm nay: để hủy lần hoãn của mục đã xóa hoặc đã xong.
    final today = dayOf(now);
    final items = await DayRepository(db).loadDay(today, today: today);
    final live = {
      for (final i in items)
        if (!i.settled) '${i.activity.id}|${i.date}',
    };
    await gateway.replaceAll(plan, texts(), liveItems: live);
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    await _sub?.cancel();
  }
}
