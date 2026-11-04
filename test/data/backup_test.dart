import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/backup.dart';
import 'package:dailyloop/src/data/csv_export.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:dailyloop/src/data/schedule.dart';
import 'package:dailyloop/src/data/settings_repository.dart';
import 'package:dailyloop/src/reminders/reminder_planner.dart';
import 'package:dailyloop/src/reminders/reminder_service.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

/// Chụp toàn bộ bảng thành JSON để so hai cơ sở dữ liệu.
Future<Map<String, Object>> dump(AppDatabase db) async => {
  'categories': [
    for (final r in await db.select(db.categories).get()) r.toJson(),
  ],
  'activities': [
    for (final r in await db.select(db.activities).get()) r.toJson(),
  ],
  'schedules': [
    for (final r in await db.select(db.schedules).get()) r.toJson(),
  ],
  'checklistItems': [
    for (final r in await db.select(db.checklistItems).get()) r.toJson(),
  ],
  'entries': [for (final r in await db.select(db.entries).get()) r.toJson()],
  'checklistMarks': [
    for (final r in await db.select(db.checklistMarks).get()) r.toJson(),
  ],
  'reminders': [
    for (final r in await db.select(db.reminders).get()) r.toJson(),
  ],
  'settings': [for (final r in await db.select(db.settings).get()) r.toJson()],
};

/// Dữ liệu mẫu đủ mọi bảng: thói quen 4 kiểu, việc, mục con, giờ nhắc, cài đặt.
Future<void> sampleData(AppDatabase db) async {
  final repo = ActivityRepository(db);
  final entries = EntryRepository(db);
  final water = await repo.create(
    const ActivityDraft(
      name: 'Uống nước',
      description: 'Ít nhất 8 ly, "đủ" nước',
      categoryId: 1,
      evaluation: Evaluation.quantity,
      target: 8,
      condition: TargetCondition.atLeast,
      unit: 'ly',
      startDate: '2026-11-01',
      reminders: [(minute: 480, kind: ReminderKind.notification)],
    ),
  );
  final run = await repo.create(
    const ActivityDraft(
      name: 'Chạy bộ',
      evaluation: Evaluation.duration,
      target: 30,
      condition: TargetCondition.atLeast,
      startDate: '2026-11-01',
      rule: ScheduleRule.daily,
      reminders: [(minute: 1200, kind: ReminderKind.alarm)],
    ),
  );
  final pack = await repo.create(
    const ActivityDraft(
      name: 'Chuẩn bị đồ',
      evaluation: Evaluation.checklist,
      checklist: [(id: null, title: 'Sạc pin'), (id: null, title: 'Ví')],
      startDate: '2026-11-01',
    ),
  );
  final task = await repo.create(
    const ActivityDraft(
      kind: ActivityKind.task,
      name: 'Nộp thuế',
      startDate: '2026-11-04',
      rule: ScheduleRule.once,
    ),
  );
  await entries.setValue(water, '2026-11-03', 8);
  await entries.setValue(water, '2026-11-02', 3.5);
  await entries.setValue(run, '2026-11-03', 20);
  await entries.setSkipped(run, '2026-11-02', true);
  final items = await repo.checklistOf(pack);
  await entries.toggleMark(pack, '2026-11-03', items.first.id);
  await entries.setValue(task, '2026-11-04', 1);
  final settings = SettingsRepository(db);
  await settings.setLocaleCode('en');
  await settings.setWeekStart(DateTime.sunday);
}

String _resign(Map<String, dynamic> root) {
  root['checksum'] = sha256
      .convert(utf8.encode(jsonEncode(root['tables'])))
      .toString();
  return jsonEncode(root);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  final now = DateTime(2026, 11, 4, 10, 30);

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  group('sao lưu và khôi phục (AC-42, AC-43)', () {
    test(
      'file có định dạng, phiên bản, mã băm; xuất rồi nhập lại y nguyên',
      () async {
        await sampleData(db);
        final json = await exportBackup(db, now: now);
        final root = jsonDecode(json) as Map<String, dynamic>;
        expect(root['format'], 'dailyloop-backup');
        expect(root['version'], 1);
        expect(root['schemaVersion'], db.schemaVersion);
        expect(root['checksum'], isA<String>());
        expect(root['tables'], isA<Map>());

        final other = memoryDatabase();
        addTearDown(other.close);
        // Dữ liệu cũ của máy khác sẽ bị thay hết.
        await ActivityRepository(other).create(
          const ActivityDraft(name: 'Sẽ bị xóa', startDate: '2026-01-01'),
        );
        await importBackup(other, json);
        expect(await dump(other), await dump(db));
        // Dữ liệu có thật: thói quen, mục con, lịch sử, giờ nhắc, cài đặt.
        expect((await other.select(other.activities).get()).length, 4);
        expect((await other.select(other.checklistMarks).get()).length, 1);
        expect((await other.select(other.reminders).get()).length, 2);
        expect(
          (await other.select(other.settings).get()).map((s) => s.key),
          containsAll([
            SettingsRepository.localeKey,
            SettingsRepository.weekStartKey,
          ]),
        );
      },
    );

    test('khôi phục thay TOÀN BỘ: danh mục và mục cũ không còn sót', () async {
      await sampleData(db);
      final json = await exportBackup(db, now: now);
      await ActivityRepository(db).create(
        const ActivityDraft(
          name: 'Thêm sau khi sao lưu',
          startDate: '2026-11-04',
        ),
      );
      await db
          .into(db.categories)
          .insert(CategoriesCompanion.insert(icon: 'star', color: 0xFF000000));
      await importBackup(db, json);
      final names = (await db.select(db.activities).get()).map((a) => a.name);
      expect(names, isNot(contains('Thêm sau khi sao lưu')));
      expect(names, contains('Uống nước'));
      expect((await db.select(db.categories).get()).length, 8);
    });

    test('file không phải JSON, sai định dạng, thiếu bảng thì từ chối và giữ nguyên dữ liệu', () async {
      await sampleData(db);
      final before = await dump(db);
      final good =
          jsonDecode(await exportBackup(db, now: now)) as Map<String, dynamic>;

      final noTable = jsonDecode(jsonEncode(good)) as Map<String, dynamic>;
      (noTable['tables'] as Map).remove('entries');
      final wrongFormat = {...good, 'format': 'vigon-backup'};

      for (final bad in [
        '',
        'xin chào',
        '[1,2]',
        '{}',
        jsonEncode(wrongFormat),
        _resign(noTable),
      ]) {
        expect(
          () => importBackup(db, bad),
          throwsA(isA<BackupFormatException>()),
          reason: bad,
        );
        expect(
          () => validateBackup(db, bad),
          throwsA(isA<BackupFormatException>()),
        );
      }
      expect(await dump(db), before);
    });

    test('file bị sửa (mã băm không khớp) thì từ chối', () async {
      await sampleData(db);
      final json = await exportBackup(db, now: now);
      final tampered = json.replaceFirst('Uống nước', 'Uống rượu');
      expect(tampered, isNot(json));
      expect(
        () => validateBackup(db, tampered),
        throwsA(isA<BackupFormatException>()),
      );
      final before = await dump(db);
      await expectLater(
        importBackup(db, tampered),
        throwsA(isA<BackupFormatException>()),
      );
      expect(await dump(db), before);
    });

    test('file từ phiên bản mới hơn thì từ chối', () async {
      await sampleData(db);
      final root =
          jsonDecode(await exportBackup(db, now: now)) as Map<String, dynamic>;
      for (final patch in [
        {'version': 2},
        {'schemaVersion': db.schemaVersion + 1},
      ]) {
        final newer = jsonEncode({...root, ...patch});
        expect(
          () => validateBackup(db, newer),
          throwsA(isA<BackupFormatException>()),
        );
      }
    });

    test('dữ liệu sai ràng buộc (mã băm đúng) thì quay lui, dữ liệu cũ còn nguyên', () async {
      await sampleData(db);
      final before = await dump(db);
      final root =
          jsonDecode(await exportBackup(db, now: now)) as Map<String, dynamic>;
      // Kết quả trỏ tới thói quen không tồn tại: vi phạm khóa ngoại giữa chừng.
      final tables = root['tables'] as Map<String, dynamic>;
      (tables['entries'] as List).add({
        'id': 999,
        'activityId': 12345,
        'date': '2026-11-01',
        'value': 1.0,
        'skipped': false,
      });
      await expectLater(
        importBackup(db, _resign(root)),
        throwsA(isA<BackupFormatException>()),
      );
      expect(await dump(db), before);

      // Giá trị âm vi phạm ràng buộc CHECK.
      final root2 =
          jsonDecode(await exportBackup(db, now: now)) as Map<String, dynamic>;
      ((root2['tables'] as Map)['entries'] as List).first['value'] = -5.0;
      await expectLater(
        importBackup(db, _resign(root2)),
        throwsA(isA<BackupFormatException>()),
      );
      expect(await dump(db), before);
    });

    test(
      'khôi phục xong thì lịch nhắc được đặt lại theo dữ liệu mới (AC-43)',
      () async {
        await sampleData(db);
        final json = await exportBackup(db, now: now);
        // Máy khác: chưa có gì, đang có một lịch nhắc cũ.
        final other = memoryDatabase();
        addTearDown(other.close);
        final gateway = FakeReminderGateway();
        ReminderSync sync() => ReminderSync(
          db: other,
          gateway: gateway,
          clock: () => now,
          texts: () => const ReminderTexts(
            channelReminders: 'r',
            channelAlarms: 'a',
            body: '',
            done: 'd',
            snooze: 's',
            dismiss: 'x',
          ),
        );
        await sync().syncNow();
        expect(gateway.scheduled, isEmpty);
        await importBackup(other, json);
        await sync().syncNow();
        final titles = gateway.scheduled.map((p) => p.title).toSet();
        expect(titles, containsAll(['Uống nước', 'Chạy bộ']));
        expect(
          gateway.scheduled.any((p) => p.kind == ReminderKind.alarm),
          isTrue,
        );
      },
    );
  });

  group('xóa toàn bộ dữ liệu (AC-52)', () {
    test('trống hết, chỉ còn danh mục mặc định; id đếm lại từ đầu', () async {
      await sampleData(db);
      await deleteAllData(db);
      expect(await db.select(db.activities).get(), isEmpty);
      expect(await db.select(db.schedules).get(), isEmpty);
      expect(await db.select(db.entries).get(), isEmpty);
      expect(await db.select(db.checklistItems).get(), isEmpty);
      expect(await db.select(db.checklistMarks).get(), isEmpty);
      expect(await db.select(db.reminders).get(), isEmpty);
      expect(await db.select(db.settings).get(), isEmpty);
      final cats = await db.select(db.categories).get();
      expect(cats.length, 8);
      expect(cats.map((c) => c.id), [1, 2, 3, 4, 5, 6, 7, 8]);
      // Như mới cài: tạo thói quen đầu tiên có id 1.
      final id = await ActivityRepository(db)
          .create(const ActivityDraft(name: 'Mới', startDate: '2026-11-04'));
      expect(id, 1);
    });
  });

  group('xuất CSV (AC-44)', () {
    const labels = CsvLabels(
      habit: 'Thói quen',
      task: 'Việc',
      done: 'Đạt',
      notDone: 'Chưa đạt',
      skipped: 'Bỏ qua',
    );

    test(
      'UTF-8 có BOM, tiêu đề, đúng cột ngày, tên, loại, kết quả, giá trị',
      () async {
        await sampleData(db);
        final csv = await buildHistoryCsv(db, labels);
        expect(csv.codeUnitAt(0), 0xFEFF);
        final lines = csv.substring(1).trimRight().split('\r\n');
        expect(lines.first, 'date,activity,type,result,value');
        expect(lines.skip(1), [
          '2026-11-02,Uống nước,Thói quen,Chưa đạt,3.5',
          '2026-11-02,Chạy bộ,Thói quen,Bỏ qua,0',
          '2026-11-03,Uống nước,Thói quen,Đạt,8',
          '2026-11-03,Chạy bộ,Thói quen,Chưa đạt,20',
          '2026-11-03,Chuẩn bị đồ,Thói quen,Chưa đạt,1',
          '2026-11-04,Nộp thuế,Việc,Đạt,1',
        ]);
        // Bytes UTF-8 giữ nguyên chữ tiếng Việt có dấu.
        expect(utf8.decode(utf8.encode(csv)), contains('Uống nước'));
      },
    );

    test('tên có dấu phẩy, nháy, xuống dòng được bọc; "=..." không thành công thức', () async {
      final repo = ActivityRepository(db);
      final a = await repo.create(
        const ActivityDraft(
          name: 'Đọc, "sách"\nbuổi tối',
          startDate: '2026-11-01',
        ),
      );
      final b = await repo.create(
        const ActivityDraft(name: '=HYPERLINK("x")', startDate: '2026-11-01'),
      );
      await EntryRepository(db).setValue(a, '2026-11-03', 1);
      await EntryRepository(db).setValue(b, '2026-11-03', 1);
      final csv = await buildHistoryCsv(db, labels);
      expect(csv, contains('"Đọc, ""sách""\nbuổi tối"'));
      expect(csv, contains('"\'=HYPERLINK(""x"")"'));
      expect(csv, isNot(contains(',=HYPERLINK')));
    });

    test('chưa có lịch sử thì chỉ có dòng tiêu đề', () async {
      final csv = await buildHistoryCsv(db, labels);
      expect(csv, '﻿date,activity,type,result,value\r\n');
    });
  });
}
