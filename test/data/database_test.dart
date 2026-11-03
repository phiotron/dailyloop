import 'package:dailyloop/l10n/app_localizations_en.dart';
import 'package:dailyloop/l10n/app_localizations_vi.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/seed.dart';
import 'package:dailyloop/src/l10n_names.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart' show SqliteException;
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  test(
    'lần mở đầu có 8 danh mục mặc định, tên theo ngôn ngữ (AC-30)',
    () async {
      final cats = await (db.select(
        db.categories,
      )..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();
      expect(cats.map((c) => c.nameKey), defaultCategories.map((c) => c.$1));
      expect(cats.every((c) => c.icon.isNotEmpty), isTrue);

      final vi = AppLocalizationsVi();
      final en = AppLocalizationsEn();
      expect(cats.map((c) => categoryLabel(vi, c)), [
        'Sức khỏe',
        'Thể thao',
        'Học tập',
        'Công việc',
        'Tài chính',
        'Nhà cửa',
        'Tinh thần',
        'Khác',
      ]);
      expect(cats.every((c) => categoryLabel(en, c).isNotEmpty), isTrue);
    },
  );

  test('tên người dùng đặt thắng tên mặc định', () async {
    await (db.update(db.categories)..where((c) => c.id.equals(1))).write(
      const CategoriesCompanion(name: Value('Chạy bộ')),
    );
    final cat = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(1))).getSingle();
    expect(categoryLabel(AppLocalizationsVi(), cat), 'Chạy bộ');
  });

  Future<int> insertHabit() => db
      .into(db.activities)
      .insert(
        ActivitiesCompanion.insert(
          kind: ActivityKind.habit,
          name: 'Uống nước',
          evaluation: const Value(Evaluation.quantity),
          target: const Value(8),
          condition: const Value(TargetCondition.atLeast),
          unit: const Value('ly'),
          startDate: const Value('2026-11-03'),
        ),
      );

  test('mỗi mục mỗi ngày chỉ có một kết quả (D-005)', () async {
    final id = await insertHabit();
    await db
        .into(db.entries)
        .insert(
          EntriesCompanion.insert(
            activityId: id,
            date: '2026-11-03',
            value: const Value(3),
          ),
        );
    expect(
      () => db
          .into(db.entries)
          .insert(EntriesCompanion.insert(activityId: id, date: '2026-11-03')),
      throwsA(isA<SqliteException>()),
    );
  });

  test('giá trị âm và giờ nhắc ngoài 0–1439 bị từ chối', () async {
    final id = await insertHabit();
    expect(
      () => db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              activityId: id,
              date: '2026-11-04',
              value: const Value(-1),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
    expect(
      () => db
          .into(db.reminders)
          .insert(
            RemindersCompanion.insert(
              activityId: id,
              minuteOfDay: 1440,
              kind: ReminderKind.notification,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('tên thói quen trống không lưu được (AC-01 mức dữ liệu)', () async {
    expect(
      () => db
          .into(db.activities)
          .insert(
            ActivitiesCompanion.insert(kind: ActivityKind.habit, name: ''),
          ),
      throwsA(isA<InvalidDataException>()),
    );
  });

  test('xóa mục thì xóa luôn lịch lặp, kết quả, giờ nhắc', () async {
    final id = await insertHabit();
    await db
        .into(db.schedules)
        .insert(
          SchedulesCompanion.insert(
            activityId: id,
            effectiveFrom: '2026-11-03',
            type: ScheduleType.daily,
          ),
        );
    await db
        .into(db.entries)
        .insert(EntriesCompanion.insert(activityId: id, date: '2026-11-03'));
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            activityId: id,
            minuteOfDay: 480,
            kind: ReminderKind.alarm,
          ),
        );

    await (db.delete(db.activities)..where((a) => a.id.equals(id))).go();
    expect(await db.select(db.schedules).get(), isEmpty);
    expect(await db.select(db.entries).get(), isEmpty);
    expect(await db.select(db.reminders).get(), isEmpty);
  });
}
