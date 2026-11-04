// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DailyLoop';

  @override
  String get today => 'Today';

  @override
  String get emptyToday => 'Nothing planned for today';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get weekStart => 'First day of week';

  @override
  String get monday => 'Monday';

  @override
  String get sunday => 'Sunday';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categorySport => 'Sport';

  @override
  String get categoryStudy => 'Study';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryMind => 'Mind';

  @override
  String get categoryOther => 'Other';

  @override
  String get habits => 'Habits';

  @override
  String get newHabit => 'New habit';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get emptyHabits => 'No habits yet. Tap + to create your first one.';

  @override
  String get emptyHabitsFiltered => 'No habits in this category';

  @override
  String get archived => 'Archived';

  @override
  String get emptyArchived => 'No archived habits';

  @override
  String get allCategories => 'All';

  @override
  String get categories => 'Categories';

  @override
  String get noCategory => 'No category';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get deleteCategoryConfirm => 'Delete this category?';

  @override
  String moveActivitiesTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items use this category. Move them to:',
      one: '1 item uses this category. Move it to:',
      zero: 'No item uses this category.',
    );
    return '$_temp0';
  }

  @override
  String get icon => 'Icon';

  @override
  String get color => 'Color';

  @override
  String get reorderHint => 'Drag to reorder';

  @override
  String get name => 'Name';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get nameTooLong => 'At most 60 characters';

  @override
  String get description => 'Description (optional)';

  @override
  String get category => 'Category';

  @override
  String get priority => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityHigh => 'High';

  @override
  String get evaluation => 'How to track';

  @override
  String get evalYesNo => 'Yes or no';

  @override
  String get evalQuantity => 'Amount';

  @override
  String get evalDuration => 'Time';

  @override
  String get evalChecklist => 'Checklist';

  @override
  String get target => 'Target';

  @override
  String get targetRequired => 'Enter a target greater than 0';

  @override
  String get unit => 'Unit (e.g. glasses)';

  @override
  String get minutes => 'minutes';

  @override
  String get condAtLeast => 'At least';

  @override
  String get condExactly => 'Exactly';

  @override
  String get condAtMost => 'At most';

  @override
  String get checklistItems => 'Items';

  @override
  String get addItem => 'Add item';

  @override
  String itemTitle(int index) {
    return 'Item $index';
  }

  @override
  String get removeItem => 'Remove item';

  @override
  String get checklistRequired => 'Add 1 to 20 items, none empty';

  @override
  String get checklistMinDone => 'Done when at least';

  @override
  String get checklistAll => 'all items';

  @override
  String checklistAtLeast(int count) {
    return '$count items';
  }

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatDaily => 'Every day';

  @override
  String get repeatWeekdays => 'On days of the week';

  @override
  String get repeatMonthDays => 'On days of the month';

  @override
  String get repeatEveryN => 'Every N days';

  @override
  String get repeatTimesPerPeriod => 'Times per week or month';

  @override
  String get weekdaysRequired => 'Pick at least one day';

  @override
  String get monthDaysRequired => 'Pick at least one day';

  @override
  String get everyNLabel => 'Every how many days (2–365)';

  @override
  String get intervalInvalid => 'Enter a number from 2 to 365';

  @override
  String get timesLabel => 'Times';

  @override
  String get timesInvalid => 'At most 7 times a week or 31 times a month';

  @override
  String get perWeek => 'per week';

  @override
  String get perMonth => 'per month';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get noEndDate => 'No end date';

  @override
  String get endDateInvalid => 'End date is before start date';

  @override
  String get clear => 'Clear';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Restore';

  @override
  String get undo => 'Undo';

  @override
  String get deleted => 'Deleted';

  @override
  String get archivedMessage => 'Archived';

  @override
  String get deleteHabitConfirm => 'Delete this habit and all its history?';

  @override
  String get scheduleDaily => 'Every day';

  @override
  String scheduleEveryN(int n) {
    return 'Every $n days';
  }

  @override
  String scheduleTimesWeek(int k) {
    return '$k times a week';
  }

  @override
  String scheduleTimesMonth(int k) {
    return '$k times a month';
  }

  @override
  String scheduleMonthDays(String days) {
    return 'Day $days of each month';
  }

  @override
  String get scheduleOnce => 'Once';

  @override
  String get tasks => 'Tasks';

  @override
  String get newTask => 'New task';

  @override
  String get editTask => 'Edit task';

  @override
  String get deleteTaskConfirm => 'Delete this task?';

  @override
  String get subtasks => 'Subtasks (optional)';

  @override
  String get repeatNone => 'Does not repeat';

  @override
  String get taskDate => 'Date';

  @override
  String get taskTime => 'Time';

  @override
  String get noTime => 'No time';

  @override
  String get unscheduled => 'Unscheduled';

  @override
  String get startDateRequired => 'Pick a start date';

  @override
  String get createNew => 'Create';

  @override
  String get addHabit => 'Add habit';

  @override
  String get addTask => 'Add task';

  @override
  String get backToToday => 'Back to today';

  @override
  String get pickDay => 'Pick a day';

  @override
  String overdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Overdue · $count days',
      one: 'Overdue · 1 day',
    );
    return '$_temp0';
  }

  @override
  String get skipToday => 'Skip this day';

  @override
  String get unskip => 'Undo skip';

  @override
  String get skipped => 'Skipped';

  @override
  String get achieved => 'Done';

  @override
  String get notAchieved => 'Not done';

  @override
  String get edit => 'Edit';

  @override
  String get futureDay => 'You can only record days up to today';

  @override
  String get addOne => 'Add 1';

  @override
  String get recordValue => 'Record';

  @override
  String progress(String value, String target) {
    return '$value of $target';
  }

  @override
  String itemsDone(int done, int total) {
    return '$done of $total items';
  }

  @override
  String get filterToday => 'Today';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterUnscheduled => 'Unscheduled';

  @override
  String get filterDone => 'Done';

  @override
  String get emptyTasks => 'No tasks here';

  @override
  String get welcomeTitle1 => 'Build habits that stick';

  @override
  String get welcomeBody1 =>
      'Track yes-or-no habits, amounts, time or checklists, on the days you choose.';

  @override
  String get welcomeTitle2 => 'Plan your day';

  @override
  String get welcomeBody2 =>
      'Habits and tasks for the day are together on the Today screen.';

  @override
  String get welcomeTitle3 => 'Your data stays on this phone';

  @override
  String get welcomeBody3 =>
      'No account and no internet needed. Export a backup file whenever you want.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get reminders => 'Reminders';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get removeReminder => 'Remove reminder';

  @override
  String get reminderNotification => 'Notification';

  @override
  String get reminderAlarm => 'Alarm';

  @override
  String get channelReminders => 'Reminders';

  @override
  String get channelAlarms => 'Alarms';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSnooze => 'Snooze 10 min';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get allow => 'Allow';

  @override
  String get notNow => 'Not now';

  @override
  String get openSettings => 'Open settings';

  @override
  String get permNotifTitle => 'Allow notifications?';

  @override
  String get permNotifBody =>
      'DailyLoop uses notifications only to remind you at the times you set. Without them, reminders will not appear. You can still use the rest of the app.';

  @override
  String get permExactTitle => 'Remind on time?';

  @override
  String get permExactBody =>
      'To remind you at the exact minute, Android needs the \"Alarms & reminders\" permission. Without it, reminders may arrive a few minutes late.';

  @override
  String get permFullTitle => 'Show alarms on the lock screen?';

  @override
  String get permFullBody =>
      'Alarms can fill the screen like a clock alarm. Without this permission, alarms appear as a pop-up notification instead.';

  @override
  String get warnNotifications =>
      'Notifications are off, reminders will not appear';

  @override
  String get warnExact => 'Reminders may be a few minutes late';

  @override
  String get warnFullScreen => 'Alarms will show as a pop-up notification';

  @override
  String get alarmFor => 'Time for';

  @override
  String get stats => 'Statistics';

  @override
  String get statsLast7 => 'Last 7 days';

  @override
  String get statsLast30 => 'Last 30 days';

  @override
  String get statsEmpty => 'Add habits or tasks to see statistics';

  @override
  String get statsTopStreaks => 'Longest streaks';

  @override
  String get statsNoStreak => 'No streaks yet';

  @override
  String doneOfTotal(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get streakCurrent => 'Current streak';

  @override
  String get streakLongest => 'Longest streak';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String streakWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String streakMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get habitScore => 'Score';

  @override
  String get successRate => 'Success rate';

  @override
  String get rate7 => '7 days';

  @override
  String get rate30 => '30 days';

  @override
  String get rateAll => 'All time';

  @override
  String get noRate => 'None yet';

  @override
  String get calendar => 'Calendar';

  @override
  String get prevMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get dayNotDue => 'Not scheduled';

  @override
  String get dayFuture => 'Upcoming';

  @override
  String get dayPending => 'Today, not done yet';

  @override
  String get chartByDay => 'By day';

  @override
  String get chartByWeek => 'By week';

  @override
  String get chartTable => 'Show as table';

  @override
  String get tableDate => 'Date';

  @override
  String get tableValue => 'Value';

  @override
  String get tableDone => 'Done';

  @override
  String get tableTotal => 'Total';

  @override
  String chartSummary(int count, String max) {
    return 'Chart, $count bars, highest value $max';
  }

  @override
  String weekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get viewProgress => 'View progress';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get pomodoroStart => 'Start';

  @override
  String get pomodoroStop => 'Stop';

  @override
  String get pomodoroNextPhase => 'Next phase';

  @override
  String get pomodoroSkipBreak => 'Skip break';

  @override
  String get phaseFocus => 'Focus';

  @override
  String get phaseShortBreak => 'Short break';

  @override
  String get phaseLongBreak => 'Long break';

  @override
  String pomodoroSession(int n) {
    return 'Session $n';
  }

  @override
  String get pomodoroSettings => 'Durations (minutes)';

  @override
  String get pomodoroFocus => 'Focus';

  @override
  String get pomodoroShortBreak => 'Short break';

  @override
  String get pomodoroLongBreak => 'Long break';

  @override
  String get pomodoroSessions => 'Sessions before long break';

  @override
  String get pomodoroHabit => 'Add minutes to habit';

  @override
  String get pomodoroNoHabit => 'Not linked';

  @override
  String pomodoroCredited(int minutes) {
    return 'Added $minutes min';
  }

  @override
  String get pomodoroDoneTitle => 'Time is up';

  @override
  String get pomodoroDoneBody => 'This phase has ended.';

  @override
  String get pomodoroFinished => 'Finished';

  @override
  String get pomodoroStartTimer => 'Start timer';

  @override
  String widgetLeft(int n) {
    return '$n left';
  }

  @override
  String get widgetAllDone => 'All done';

  @override
  String get dataSection => 'Data';

  @override
  String get securitySection => 'Security';

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupExportHint =>
      'Creates a .dailyloop file to keep or move to another device';

  @override
  String get backupRestore => 'Restore from file';

  @override
  String get backupRestoreHint => 'Pick a .dailyloop file you exported earlier';

  @override
  String get restore => 'Restore';

  @override
  String get restoreConfirm =>
      'Your current data will be replaced by the contents of the backup file.';

  @override
  String get restoreDone => 'Data restored';

  @override
  String get restoreFailed =>
      'The backup file is damaged, in the wrong format or made by a newer DailyLoop. Your current data was left untouched.';

  @override
  String get exportFailed => 'Could not export the file';

  @override
  String get csvExport => 'Export history as CSV';

  @override
  String get csvExportHint => 'Opens in Excel or Google Sheets';

  @override
  String get csvHabit => 'Habit';

  @override
  String get csvTask => 'Task';

  @override
  String get csvDone => 'Done';

  @override
  String get csvNotDone => 'Not done';

  @override
  String get confirm => 'Confirm';

  @override
  String get pinLock => 'PIN lock';

  @override
  String get pinLockHintOff => 'Off';

  @override
  String get pinLockHintOn => 'On';

  @override
  String get pinChange => 'Change PIN';

  @override
  String get pinDisable => 'Turn off PIN lock';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get enterCurrentPin => 'Enter your current PIN';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get newPin => 'Set a 4-digit PIN';

  @override
  String get confirmPin => 'Enter the PIN again';

  @override
  String get pinMismatch => 'The two entries do not match';

  @override
  String get pinWarning =>
      'The PIN only keeps curious people out of the app; it does not encrypt your data. If you forget it, the only way back in is to erase all data.';

  @override
  String get forgotPin => 'Forgot PIN';

  @override
  String get forgotPinBody =>
      'If you forgot the PIN, the only option is to erase all data on this device and start over. Data you exported to a backup file can be restored.';

  @override
  String digit(String d) {
    return 'Digit $d';
  }

  @override
  String pinProgress(int n) {
    return '$n of 4 digits entered';
  }

  @override
  String get keypadBackspace => 'Delete last digit';

  @override
  String get lockedOpenApp => 'Open app (PIN required)';

  @override
  String get deleteAll => 'Erase all data';

  @override
  String get deleteAllHint =>
      'Deletes habits, tasks, history, reminders, settings and the PIN';

  @override
  String get deleteAllConfirm =>
      'All habits, tasks, history, reminders and settings will be erased from this device. This cannot be undone.';

  @override
  String get deleteAllConfirm2 =>
      'Really erase everything? Export a backup first if you still need your data.';

  @override
  String get deleteAllDone => 'All data erased';
}
