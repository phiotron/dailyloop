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
}
