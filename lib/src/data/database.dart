import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'seed.dart';

part 'database.g.dart';

/// Thói quen hay việc cần làm (D-005).
enum ActivityKind { habit, task }

/// Kiểu đánh giá thói quen (AC-02). Việc cần làm luôn là [yesNo].
enum Evaluation { yesNo, quantity, duration, checklist }

/// Điều kiện so với mục tiêu cho kiểu Số lượng và Thời gian (AC-02).
enum TargetCondition { atLeast, exactly, atMost }

/// Mức ưu tiên (AC-01).
enum Priority { low, normal, high }

/// Kiểu lịch lặp (AC-03). [once] là việc một lần.
enum ScheduleType {
  once,
  daily,
  weekdays,
  monthDays,
  everyNDays,
  timesPerPeriod,
}

/// Chu kỳ cho kiểu "K lần mỗi tuần/tháng" (AC-03).
enum SchedulePeriod { week, month }

/// Kiểu nhắc (AC-17).
enum ReminderKind { notification, alarm }

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Khóa dịch cho danh mục mặc định; null khi người dùng tự đặt tên (D-005).
  TextColumn get nameKey => text().nullable()();
  TextColumn get name => text().withLength(max: 40).nullable()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get kind => intEnum<ActivityKind>()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get description => text().withLength(max: 300).nullable()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  IntColumn get priority =>
      intEnum<Priority>().withDefault(Constant(Priority.normal.index))();
  IntColumn get evaluation =>
      intEnum<Evaluation>().withDefault(Constant(Evaluation.yesNo.index))();

  /// Mục tiêu của kiểu Số lượng (theo [unit]) hoặc Thời gian (phút).
  RealColumn get target => real().nullable()();
  IntColumn get condition => intEnum<TargetCondition>().nullable()();
  TextColumn get unit => text().withLength(max: 20).nullable()();

  /// Số mục con tối thiểu phải xong; null là tất cả (AC-02d).
  IntColumn get checklistMinDone => integer().nullable()();

  /// Ngày `YYYY-MM-DD`. Thói quen: ngày bắt đầu. Việc một lần: ngày làm,
  /// null là "Chưa xếp lịch" (AC-13).
  TextColumn get startDate => text().withLength(min: 10, max: 10).nullable()();
  TextColumn get endDate => text().withLength(min: 10, max: 10).nullable()();

  /// Giờ của việc, số phút từ 00:00 (AC-13).
  IntColumn get timeOfDay => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Lịch lặp có ngày hiệu lực: đổi lịch thì thêm dòng mới (AC-04, D-005).
class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId =>
      integer().references(Activities, #id, onDelete: KeyAction.cascade)();
  TextColumn get effectiveFrom => text().withLength(min: 10, max: 10)();
  IntColumn get type => intEnum<ScheduleType>()();

  /// Thứ trong tuần dạng bit: bit 0 là Thứ Hai … bit 6 là Chủ Nhật.
  IntColumn get weekdays => integer().nullable()();

  /// Ngày trong tháng, ví dụ "1,15,31".
  TextColumn get monthDays => text().nullable()();

  /// N của "cứ N ngày một lần", 2 tới 365.
  IntColumn get interval => integer().nullable()();

  /// K của "K lần mỗi tuần/tháng".
  IntColumn get timesPerPeriod => integer().nullable()();
  IntColumn get period => intEnum<SchedulePeriod>().nullable()();
}

class ChecklistItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId =>
      integer().references(Activities, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 60)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Kết quả của một mục trong một ngày (D-005).
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId =>
      integer().references(Activities, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text().withLength(min: 10, max: 10)();

  /// Giá trị đã ghi: Có/Không là 1, Số lượng theo đơn vị, Thời gian là phút.
  RealColumn get value => real()
      // ignore: recursive_getters
      .check(value.isBiggerOrEqualValue(0))
      .withDefault(const Constant(0))();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {activityId, date},
  ];
}

/// Mục con đã xong trong một ngày (AC-09).
class ChecklistMarks extends Table {
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  IntColumn get itemId =>
      integer().references(ChecklistItems, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {entryId, itemId};
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId =>
      integer().references(Activities, #id, onDelete: KeyAction.cascade)();

  /// Số phút từ 00:00, 0 tới 1439.
  IntColumn get minuteOfDay =>
      // ignore: recursive_getters
      integer().check(minuteOfDay.isBetweenValues(0, 1439))();
  IntColumn get kind => intEnum<ReminderKind>()();
}

/// Cài đặt dạng khóa-giá trị, nằm cùng cơ sở dữ liệu để sao lưu một file (D-005).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Categories,
    Activities,
    Schedules,
    ChecklistItems,
    Entries,
    ChecklistMarks,
    Reminders,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'dailyloop'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDefaults(this);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
