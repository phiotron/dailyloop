import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/activity_repository.dart';
import 'data/category_repository.dart';
import 'data/database.dart';
import 'data/dates.dart';
import 'data/day_repository.dart';
import 'data/entry_repository.dart';
import 'data/habit_stats.dart';
import 'data/stats_repository.dart';
import 'data/schedule.dart';
import 'data/settings_repository.dart';
import 'pomodoro/pomodoro_repository.dart';
import 'pomodoro/pomodoro_state.dart';
import 'reminders/reminder_service.dart';
import 'widget/home_widget_sync.dart';

/// Cơ sở dữ liệu của app; test ghi đè bằng cơ sở dữ liệu trong bộ nhớ.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Giờ hiện tại; test ghi đè để cố định ngày.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Hôm nay (ngày UTC 00:00 cùng ngày địa phương). Tự chuyển sang ngày mới lúc
/// 00:00 và khi app quay lại từ nền, để màn Hôm nay, dải ngày, việc quá hạn và
/// thống kê không dính ngày cũ khi app mở qua nửa đêm (BUG-001).
class TodayNotifier extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    final now = ref.read(clockProvider)();
    _scheduleMidnight(now);
    return dayOf(now);
  }

  void _scheduleMidnight(DateTime now) {
    _timer?.cancel();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    // Chậm 1 giây để chắc chắn đã qua 00:00.
    _timer = Timer(
      midnight.difference(now) + const Duration(seconds: 1),
      refresh,
    );
  }

  /// Đọc lại giờ máy; đổi ngày thì các màn đang xem "hôm nay" tự dựng lại.
  void refresh() {
    final now = ref.read(clockProvider)();
    final t = dayOf(now);
    if (t != state) state = t;
    _scheduleMidnight(now);
  }
}

final todayProvider = NotifierProvider<TodayNotifier, DateTime>(
  TodayNotifier.new,
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(databaseProvider)),
);
final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(ref.watch(databaseProvider)),
);

final themeModeProvider = StreamProvider<ThemeMode>(
  (ref) => ref.watch(settingsRepositoryProvider).watchThemeMode(),
);

final localeCodeProvider = StreamProvider<String?>(
  (ref) => ref.watch(settingsRepositoryProvider).watchLocaleCode(),
);

final weekStartProvider = StreamProvider<int>(
  (ref) => ref.watch(settingsRepositoryProvider).watchWeekStart(),
);

final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watch(),
);

/// Danh mục đang lọc ở màn Thói quen; null là tất cả (AC-32).
class HabitFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? categoryId) => state = categoryId;
}

final habitFilterProvider = NotifierProvider<HabitFilterNotifier, int?>(
  HabitFilterNotifier.new,
);

/// Thói quen đang dùng, theo bộ lọc danh mục (AC-06, AC-32).
final habitsProvider = StreamProvider<List<Activity>>(
  (ref) => ref
      .watch(activityRepositoryProvider)
      .watchHabits(categoryId: ref.watch(habitFilterProvider)),
);

final archivedHabitsProvider = StreamProvider<List<Activity>>(
  (ref) => ref.watch(activityRepositoryProvider).watchHabits(archived: true),
);

final entryRepositoryProvider = Provider<EntryRepository>(
  (ref) => EntryRepository(ref.watch(databaseProvider)),
);
final dayRepositoryProvider = Provider<DayRepository>(
  (ref) => DayRepository(ref.watch(databaseProvider)),
);

/// Cổng nhắc giờ với hệ điều hành. `main` ghi đè bằng bản thật; test dùng
/// bản giả mặc định để không gọi Android.
final reminderGatewayProvider = Provider<ReminderGateway>(
  (ref) => FakeReminderGateway(),
);

/// Quyền thông báo, báo thức chính xác, toàn màn hình; làm mới khi quay lại
/// app (AC-18, AC-20).
final reminderPermissionsProvider = FutureProvider<ReminderPermissions>(
  (ref) => ref.watch(reminderGatewayProvider).permissions(),
);

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(databaseProvider)),
);

/// Lịch sử một thói quen để tính chuỗi, điểm, lịch tháng (F-05, F-06).
final habitHistoryProvider = StreamProvider.family<HabitHistory?, int>(
  (ref, id) => ref.watch(statsRepositoryProvider).watchHistory(id),
);

/// Thói quen xếp theo chuỗi dài nhất (AC-28).
final rankingProvider = StreamProvider<List<HabitRank>>(
  (ref) => ref
      .watch(statsRepositoryProvider)
      .watchRanking(
        today: ref.watch(todayProvider),
        weekStart: ref.watch(weekStartProvider).value ?? DateTime.monday,
      ),
);

/// Số mục xong trên tổng của [days] ngày kết thúc hôm nay (AC-28).
final dailyCountsProvider = StreamProvider.family<Map<String, DayCount>, int>((
  ref,
  days,
) {
  final today = ref.watch(todayProvider);
  return ref
      .watch(statsRepositoryProvider)
      .watchDailyCounts(today.subtract(Duration(days: days - 1)), today);
});

final onboardingDoneProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchOnboardingDone(),
);

/// Ngày đang xem ở màn Hôm nay; mặc định hôm nay (AC-08).
class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    // Đang xem hôm nay mà qua nửa đêm thì chuyển theo sang ngày mới.
    ref.listen<DateTime>(todayProvider, (prev, next) {
      if (state == prev) state = next;
    });
    return ref.read(todayProvider);
  }

  void select(DateTime day) => state = dayOf(day);
}

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime>(
  SelectedDayNotifier.new,
);

/// Các mục của ngày đang xem (AC-07).
final dayItemsProvider = StreamProvider<List<DayItem>>(
  (ref) => ref
      .watch(dayRepositoryProvider)
      .watchDay(
        ref.watch(selectedDayProvider),
        today: ref.watch(todayProvider),
      ),
);

/// Bộ lọc đang chọn ở màn Việc (AC-16).
class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.today;

  void select(TaskFilter filter) => state = filter;
}

final taskFilterProvider = NotifierProvider<TaskFilterNotifier, TaskFilter>(
  TaskFilterNotifier.new,
);

final taskItemsProvider = StreamProvider<List<DayItem>>(
  (ref) => ref
      .watch(dayRepositoryProvider)
      .watchTasks(
        ref.watch(taskFilterProvider),
        today: ref.watch(todayProvider),
      ),
);

/// Lịch đang áp dụng của từng mục, để hiện mô tả lịch trong danh sách.
final currentRuleProvider = FutureProvider.family<ScheduleRule?, int>((
  ref,
  id,
) {
  // Sửa mục thì danh sách phát lại, đọc lại lịch.
  ref.watch(habitsProvider);
  return ref.watch(activityRepositoryProvider).currentRule(id);
});

final pomodoroRepositoryProvider = Provider<PomodoroRepository>(
  (ref) => PomodoroRepository(ref.watch(databaseProvider)),
);

/// Cấu hình và lần chạy Pomodoro hiện tại (F-09).
final pomodoroConfigProvider = StreamProvider<PomodoroConfig>(
  (ref) => ref.watch(pomodoroRepositoryProvider).watchConfig(),
);

final pomodoroRunProvider = StreamProvider<PomodoroRun?>(
  (ref) => ref.watch(pomodoroRepositoryProvider).watchRun(),
);

/// Cổng tới widget màn hình chính. `main` ghi đè bằng bản thật.
final homeWidgetGatewayProvider = Provider<HomeWidgetGateway>(
  (ref) => FakeHomeWidgetGateway(),
);
