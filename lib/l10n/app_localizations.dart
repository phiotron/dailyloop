import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'DailyLoop'**
  String get appTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @emptyToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for today'**
  String get emptyToday;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// No description provided for @weekStart.
  ///
  /// In en, this message translates to:
  /// **'First day of week'**
  String get weekStart;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categorySport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get categorySport;

  /// No description provided for @categoryStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get categoryStudy;

  /// No description provided for @categoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// No description provided for @categoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get categoryFinance;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @categoryMind.
  ///
  /// In en, this message translates to:
  /// **'Mind'**
  String get categoryMind;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @newHabit.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabit;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabit;

  /// No description provided for @emptyHabits.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Tap + to create your first one.'**
  String get emptyHabits;

  /// No description provided for @emptyHabitsFiltered.
  ///
  /// In en, this message translates to:
  /// **'No habits in this category'**
  String get emptyHabitsFiltered;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @emptyArchived.
  ///
  /// In en, this message translates to:
  /// **'No archived habits'**
  String get emptyArchived;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get noCategory;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this category?'**
  String get deleteCategoryConfirm;

  /// No description provided for @moveActivitiesTo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No item uses this category.} =1{1 item uses this category. Move it to:} other{{count} items use this category. Move them to:}}'**
  String moveActivitiesTo(int count);

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @reorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get reorderHint;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get nameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most 60 characters'**
  String get nameTooLong;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get description;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @evaluation.
  ///
  /// In en, this message translates to:
  /// **'How to track'**
  String get evaluation;

  /// No description provided for @evalYesNo.
  ///
  /// In en, this message translates to:
  /// **'Yes or no'**
  String get evalYesNo;

  /// No description provided for @evalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get evalQuantity;

  /// No description provided for @evalDuration.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get evalDuration;

  /// No description provided for @evalChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get evalChecklist;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @targetRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a target greater than 0'**
  String get targetRequired;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g. glasses)'**
  String get unit;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @condAtLeast.
  ///
  /// In en, this message translates to:
  /// **'At least'**
  String get condAtLeast;

  /// No description provided for @condExactly.
  ///
  /// In en, this message translates to:
  /// **'Exactly'**
  String get condExactly;

  /// No description provided for @condAtMost.
  ///
  /// In en, this message translates to:
  /// **'At most'**
  String get condAtMost;

  /// No description provided for @checklistItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get checklistItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @itemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item {index}'**
  String itemTitle(int index);

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeItem;

  /// No description provided for @checklistRequired.
  ///
  /// In en, this message translates to:
  /// **'Add 1 to 20 items, none empty'**
  String get checklistRequired;

  /// No description provided for @checklistMinDone.
  ///
  /// In en, this message translates to:
  /// **'Done when at least'**
  String get checklistMinDone;

  /// No description provided for @checklistAll.
  ///
  /// In en, this message translates to:
  /// **'all items'**
  String get checklistAll;

  /// No description provided for @checklistAtLeast.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String checklistAtLeast(int count);

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatDaily;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'On days of the week'**
  String get repeatWeekdays;

  /// No description provided for @repeatMonthDays.
  ///
  /// In en, this message translates to:
  /// **'On days of the month'**
  String get repeatMonthDays;

  /// No description provided for @repeatEveryN.
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get repeatEveryN;

  /// No description provided for @repeatTimesPerPeriod.
  ///
  /// In en, this message translates to:
  /// **'Times per week or month'**
  String get repeatTimesPerPeriod;

  /// No description provided for @weekdaysRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day'**
  String get weekdaysRequired;

  /// No description provided for @monthDaysRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day'**
  String get monthDaysRequired;

  /// No description provided for @everyNLabel.
  ///
  /// In en, this message translates to:
  /// **'Every how many days (2–365)'**
  String get everyNLabel;

  /// No description provided for @intervalInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 2 to 365'**
  String get intervalInvalid;

  /// No description provided for @timesLabel.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get timesLabel;

  /// No description provided for @timesInvalid.
  ///
  /// In en, this message translates to:
  /// **'At most 7 times a week or 31 times a month'**
  String get timesInvalid;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'per week'**
  String get perWeek;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @noEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDate;

  /// No description provided for @endDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'End date is before start date'**
  String get endDateInvalid;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get unarchive;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @archivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedMessage;

  /// No description provided for @deleteHabitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this habit and all its history?'**
  String get deleteHabitConfirm;

  /// No description provided for @scheduleDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get scheduleDaily;

  /// No description provided for @scheduleEveryN.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days'**
  String scheduleEveryN(int n);

  /// No description provided for @scheduleTimesWeek.
  ///
  /// In en, this message translates to:
  /// **'{k} times a week'**
  String scheduleTimesWeek(int k);

  /// No description provided for @scheduleTimesMonth.
  ///
  /// In en, this message translates to:
  /// **'{k} times a month'**
  String scheduleTimesMonth(int k);

  /// No description provided for @scheduleMonthDays.
  ///
  /// In en, this message translates to:
  /// **'Day {days} of each month'**
  String scheduleMonthDays(String days);

  /// No description provided for @scheduleOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get scheduleOnce;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get deleteTaskConfirm;

  /// No description provided for @subtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks (optional)'**
  String get subtasks;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get repeatNone;

  /// No description provided for @taskDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get taskDate;

  /// No description provided for @taskTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get taskTime;

  /// No description provided for @noTime.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get noTime;

  /// No description provided for @unscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get unscheduled;

  /// No description provided for @startDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a start date'**
  String get startDateRequired;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createNew;

  /// No description provided for @addHabit.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get addHabit;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTask;

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get backToToday;

  /// No description provided for @pickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick a day'**
  String get pickDay;

  /// No description provided for @overdueDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Overdue · 1 day} other{Overdue · {count} days}}'**
  String overdueDays(int count);

  /// No description provided for @skipToday.
  ///
  /// In en, this message translates to:
  /// **'Skip this day'**
  String get skipToday;

  /// No description provided for @unskip.
  ///
  /// In en, this message translates to:
  /// **'Undo skip'**
  String get unskip;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @achieved.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get achieved;

  /// No description provided for @notAchieved.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get notAchieved;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @futureDay.
  ///
  /// In en, this message translates to:
  /// **'You can only record days up to today'**
  String get futureDay;

  /// No description provided for @addOne.
  ///
  /// In en, this message translates to:
  /// **'Add 1'**
  String get addOne;

  /// No description provided for @recordValue.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordValue;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'{value} of {target}'**
  String progress(String value, String target);

  /// No description provided for @itemsDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} items'**
  String itemsDone(int done, int total);

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get filterUpcoming;

  /// No description provided for @filterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// No description provided for @filterUnscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get filterUnscheduled;

  /// No description provided for @filterDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get filterDone;

  /// No description provided for @emptyTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks here'**
  String get emptyTasks;

  /// No description provided for @welcomeTitle1.
  ///
  /// In en, this message translates to:
  /// **'Build habits that stick'**
  String get welcomeTitle1;

  /// No description provided for @welcomeBody1.
  ///
  /// In en, this message translates to:
  /// **'Track yes-or-no habits, amounts, time or checklists, on the days you choose.'**
  String get welcomeBody1;

  /// No description provided for @welcomeTitle2.
  ///
  /// In en, this message translates to:
  /// **'Plan your day'**
  String get welcomeTitle2;

  /// No description provided for @welcomeBody2.
  ///
  /// In en, this message translates to:
  /// **'Habits and tasks for the day are together on the Today screen.'**
  String get welcomeBody2;

  /// No description provided for @welcomeTitle3.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this phone'**
  String get welcomeTitle3;

  /// No description provided for @welcomeBody3.
  ///
  /// In en, this message translates to:
  /// **'No account and no internet needed. Export a backup file whenever you want.'**
  String get welcomeBody3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
