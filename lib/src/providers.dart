import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/activity_repository.dart';
import 'data/category_repository.dart';
import 'data/database.dart';
import 'data/dates.dart';
import 'data/day_repository.dart';
import 'data/entry_repository.dart';
import 'data/schedule.dart';
import 'data/settings_repository.dart';
import 'reminders/reminder_service.dart';

/// Cơ sở dữ liệu của app; test ghi đè bằng cơ sở dữ liệu trong bộ nhớ.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Giờ hiện tại; test ghi đè để cố định ngày.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

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

final onboardingDoneProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).watchOnboardingDone(),
);

/// Ngày đang xem ở màn Hôm nay; mặc định hôm nay (AC-08).
class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => dayOf(ref.read(clockProvider)());

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
        today: ref.read(clockProvider)(),
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
        today: ref.read(clockProvider)(),
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
