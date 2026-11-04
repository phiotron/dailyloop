import 'dart:io';
import 'dart:ui' show Locale;

import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/settings_repository.dart';
import 'package:dailyloop/src/reminders/reminder_planner.dart';
import 'package:dailyloop/src/reminders/reminder_service.dart';
import 'package:dailyloop/src/reminders/time_change_entry.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

/// Gateway giả ghi lại cả chữ đã dùng để đặt lịch.
class _RecordingGateway extends FakeReminderGateway {
  ReminderTexts? texts;
  int replaceCalls = 0;

  @override
  Future<void> replaceAll(
    List<PlannedReminder> plan,
    ReminderTexts texts, {
    Set<String> liveItems = const {},
  }) async {
    replaceCalls++;
    this.texts = texts;
    await super.replaceAll(plan, texts, liveItems: liveItems);
  }
}

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<void> addHabit() => ActivityRepository(db).create(
    const ActivityDraft(
      name: 'Uống nước',
      startDate: '2026-11-01',
      reminders: [(minute: 8 * 60, kind: ReminderKind.notification)],
    ),
  );

  group('đặt lại giờ nhắc khi đổi giờ hoặc múi giờ lúc app tắt (AC-21)', () {
    test('tính lại lịch từ dữ liệu theo giờ hiện tại của máy', () async {
      await addHabit();
      final gateway = _RecordingGateway();
      // Máy vừa đổi múi giờ: giờ địa phương bây giờ là 7:30 sáng.
      await resyncRemindersInBackground(
        db: db,
        gateway: gateway,
        clock: () => DateTime(2026, 11, 3, 7, 30),
        deviceLocale: const Locale('vi'),
      );
      expect(gateway.replaceCalls, 1);
      // 8:00 hôm nay vẫn còn sắp tới, cùng 6 ngày sau.
      expect(gateway.scheduled.first.at, DateTime(2026, 11, 3, 8));
      expect(gateway.scheduled, hasLength(7));

      // Sau đó giờ máy chỉnh sang 9:00: lịch tính lại, bỏ lần 8:00 hôm nay.
      await resyncRemindersInBackground(
        db: db,
        gateway: gateway,
        clock: () => DateTime(2026, 11, 3, 9),
        deviceLocale: const Locale('vi'),
      );
      expect(gateway.scheduled.first.at, DateTime(2026, 11, 4, 8));
      // Chạy lại nhiều lần không sinh thêm lần nhắc (không nhắc trùng).
      final ids = gateway.scheduled.map((p) => p.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('chữ thông báo theo ngôn ngữ đã chọn trong cài đặt', () async {
      await SettingsRepository(db).setLocaleCode('en');
      final t = await backgroundTexts(db, const Locale('vi'));
      expect(t.done, 'Done');
    });

    test(
      'không chọn thì theo ngôn ngữ máy; không hỗ trợ thì tiếng Anh',
      () async {
        expect((await backgroundTexts(db, const Locale('vi'))).done, 'Xong');
        expect((await backgroundTexts(db, const Locale('fr'))).done, 'Done');
      },
    );
  });

  group('bộ nhận hệ thống Android (AC-21)', () {
    // Phần native không chạy được trong test: kiểm tra đã khai báo đúng. Chạy
    // thật trên máy: CHƯA thử (xem notes G7).
    test('manifest khai bộ nhận đổi giờ, đổi múi giờ, khởi động lại', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      final start = manifest.indexOf('.TimeChangeReceiver');
      expect(start, greaterThan(0));
      final block = manifest.substring(
        start,
        manifest.indexOf('</receiver>', start),
      );
      for (final action in [
        'android.intent.action.TIMEZONE_CHANGED',
        'android.intent.action.TIME_SET',
        'android.intent.action.BOOT_COMPLETED',
      ]) {
        expect(block, contains(action));
      }
      expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    });

    test('Kotlin gọi đúng điểm vào Dart có trong thư viện', () {
      final kotlin = File(
        'android/app/src/main/kotlin/com/phiotron/dailyloop/TimeChangeReceiver.kt',
      ).readAsStringSync();
      expect(
        kotlin,
        contains('package:dailyloop/src/reminders/time_change_entry.dart'),
      );
      expect(kotlin, contains('"timeChangedMain"'));
      final dart = File('lib/src/reminders/time_change_entry.dart')
          .readAsStringSync();
      expect(dart, contains("@pragma('vm:entry-point')"));
      expect(dart, contains('Future<void> timeChangedMain()'));
      expect(kotlin, contains('dailyloop/background'));
      expect(dart, contains("'dailyloop/background'"));
    });
  });
}
