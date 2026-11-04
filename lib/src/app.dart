import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationResponse;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'features/categories/categories_screen.dart';
import 'features/habits/habit_detail_screen.dart';
import 'features/habits/habit_editor_screen.dart';
import 'features/habits/habits_screen.dart';
import 'features/lock/app_lock.dart';
import 'data/database.dart';
import 'features/pomodoro/pomodoro_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/shell/home_shell.dart';
import 'features/stats/stats_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/today/today_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'providers.dart';
import 'reminders/alarm_screen.dart';
import 'reminders/reminder_host.dart';
// Giữ điểm vào Dart của bộ nhận đổi giờ (Android) trong chương trình được biên dịch.
// ignore: unused_import
import 'reminders/time_change_entry.dart';
import 'ui/messenger.dart';

/// Mỗi lần gọi tạo router mới; test dùng để mỗi test bắt đầu ở màn Hôm nay.
/// Màn soạn, danh mục, cài đặt mở đè lên thanh điều hướng dưới.
GoRouter createRouter() {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/tasks/new',
        builder: (context, state) => HabitEditorScreen(
          kind: ActivityKind.task,
          initialDate: state.uri.queryParameters['date'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/tasks/:id',
        builder: (context, state) =>
            HabitEditorScreen(habitId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/habits/new',
        builder: (context, state) => const HabitEditorScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/habits/archived',
        builder: (context, state) => const ArchivedHabitsScreen(),
      ),
      // Chạm một thói quen mở tiến độ; từ đó mới sửa (F-05, F-06).
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/habits/:id',
        builder: (context, state) =>
            HabitDetailScreen(habitId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/habits/:id/edit',
        builder: (context, state) =>
            HabitEditorScreen(habitId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/pomodoro',
        builder: (context, state) => PomodoroScreen(
          habitId: int.tryParse(state.uri.queryParameters['habit'] ?? ''),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/alarm',
        builder: (context, state) =>
            AlarmScreen(response: state.extra! as NotificationResponse),
      ),
    ],
  );
}

final _router = createRouter();

const _seedColor = Color(0xFF3F51B5);

class DailyLoopApp extends ConsumerWidget {
  const DailyLoopApp({super.key, this.router});

  /// Test truyền router từ [createRouter].
  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final localeCode = ref.watch(localeCodeProvider).value;
    final onboarding = ref.watch(onboardingDoneProvider);
    final routerConfig = router ?? _router;
    return MaterialApp.router(
      // Lần mở đầu thì màn chào phủ lên app (AC-34). Đang đọc cài đặt thì
      // để trống, tránh màn chào nháy lên rồi tắt. Lịch nhắc luôn được giữ
      // khớp dữ liệu (D-007).
      builder: (context, child) => ReminderHost(
        router: routerConfig,
        // Khóa PIN phủ lên cả màn chào lẫn app (AC-46); xóa hết dữ liệu vì
        // quên mã thì đưa router về màn đầu (AC-47).
        child: AppLockOverlay(
          onReset: () => routerConfig.go('/'),
          child: switch (onboarding.value) {
            true => child!,
            false => const WelcomeScreen(),
            null => const Scaffold(),
          },
        ),
      ),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: routerConfig,
      scaffoldMessengerKey: rootMessengerKey,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      ),
      locale: localeCode == null ? null : Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
