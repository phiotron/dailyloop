import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/activity_repository.dart';
import 'data/category_repository.dart';
import 'data/database.dart';
import 'data/schedule.dart';
import 'data/settings_repository.dart';

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

/// Lịch đang áp dụng của từng mục, để hiện mô tả lịch trong danh sách.
final currentRuleProvider = FutureProvider.family<ScheduleRule?, int>((
  ref,
  id,
) {
  // Sửa mục thì danh sách phát lại, đọc lại lịch.
  ref.watch(habitsProvider);
  return ref.watch(activityRepositoryProvider).currentRule(id);
});
