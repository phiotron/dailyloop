import 'package:dailyloop/src/data/activity_repository.dart';
import 'package:dailyloop/src/data/database.dart';
import 'package:dailyloop/src/data/entry_repository.dart';
import 'package:dailyloop/src/pomodoro/pomodoro_repository.dart';
import 'package:dailyloop/src/pomodoro/pomodoro_state.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

import '../helpers.dart';

final t0 = DateTime(2026, 11, 4, 9);

void main() {
  group('cấu hình (AC-35)', () {
    test('mặc định 25, 5, 15 phút và 4 phiên', () {
      const c = PomodoroConfig.defaults;
      expect(c.focusMinutes, 25);
      expect(c.shortBreakMinutes, 5);
      expect(c.longBreakMinutes, 15);
      expect(c.sessionsBeforeLongBreak, 4);
    });

    test('chỉnh được và bị kẹp trong khoảng cho phép', () {
      final c = PomodoroConfig.defaults.copyWith(
        focusMinutes: 50,
        shortBreakMinutes: 0,
        longBreakMinutes: 999,
        sessionsBeforeLongBreak: 3,
      );
      expect(c.focusMinutes, 50);
      expect(c.shortBreakMinutes, 1);
      expect(c.longBreakMinutes, 120);
      expect(c.sessionsBeforeLongBreak, 3);
    });

    test('lưu rồi đọc lại giống nhau; dữ liệu hỏng thì dùng mặc định', () {
      final c = PomodoroConfig.defaults.copyWith(focusMinutes: 45);
      expect(PomodoroConfig.fromJson(c.toJson()), c);
      expect(PomodoroConfig.fromJson('rác'), PomodoroConfig.defaults);
      expect(PomodoroConfig.fromJson(null), PomodoroConfig.defaults);
      expect(PomodoroConfig.fromJson('{"focus": 7}').focusMinutes, 7);
    });
  });

  group('thời gian tính từ mốc bắt đầu (AC-36)', () {
    final run = PomodoroRun.startFocus(t0, PomodoroConfig.defaults);

    test('còn lại giảm theo giờ máy, không đụng bộ đếm nào', () {
      expect(run.remaining(t0), const Duration(minutes: 25));
      expect(
        run.remaining(t0.add(const Duration(minutes: 10, seconds: 30))),
        const Duration(minutes: 14, seconds: 30),
      );
      expect(
        run.isFinished(t0.add(const Duration(minutes: 24, seconds: 59))),
        isFalse,
      );
      expect(run.isFinished(t0.add(const Duration(minutes: 25))), isTrue);
    });

    test('hết giờ thì còn lại 0, đã chạy không vượt thời lượng', () {
      final late = t0.add(const Duration(hours: 5));
      expect(run.remaining(late), Duration.zero);
      expect(run.elapsed(late), const Duration(minutes: 25));
    });

    test('giờ máy lùi (chỉnh giờ) không cho giá trị âm', () {
      final early = t0.subtract(const Duration(minutes: 3));
      expect(run.elapsed(early), Duration.zero);
      expect(run.remaining(early), const Duration(minutes: 25));
    });

    test('số phút cộng: làm tròn tới phút gần nhất, chỉ phiên tập trung', () {
      expect(run.creditMinutes(t0.add(const Duration(seconds: 29))), 0);
      expect(run.creditMinutes(t0.add(const Duration(seconds: 30))), 1);
      expect(
        run.creditMinutes(t0.add(const Duration(minutes: 10, seconds: 20))),
        10,
      );
      expect(run.creditMinutes(t0.add(const Duration(hours: 2))), 25);
      final rest = run.startNext(t0, PomodoroConfig.defaults);
      expect(rest.creditMinutes(t0.add(const Duration(minutes: 3))), 0);
    });

    test('lưu rồi đọc lại; dữ liệu hỏng thì không có lần chạy', () {
      final r = PomodoroRun.startFocus(
        t0,
        PomodoroConfig.defaults,
        habitId: 7,
        sessionsDone: 2,
      ).markCredited();
      final back = PomodoroRun.fromJson(r.toJson())!;
      expect(back.phase, PomodoroPhase.focus);
      expect(back.startedAt, t0);
      expect(back.durationSeconds, 1500);
      expect(back.habitId, 7);
      expect(back.sessionsDone, 2);
      expect(back.credited, isTrue);
      expect(PomodoroRun.fromJson('rác'), isNull);
      expect(PomodoroRun.fromJson(null), isNull);
      expect(PomodoroRun.fromJson('{"phase":"focus"}'), isNull);
      expect(
        PomodoroRun.fromJson('{"phase":"focus","startedAt":1,"duration":0}'),
        isNull,
      );
    });
  });

  group('thứ tự các giai đoạn (AC-35)', () {
    test('nghỉ ngắn sau mỗi phiên, nghỉ dài sau phiên thứ N, rồi lặp lại', () {
      const c = PomodoroConfig.defaults;
      var run = PomodoroRun.startFocus(t0, c);
      final order = <PomodoroPhase>[];
      for (var i = 0; i < 9; i++) {
        run = run.startNext(t0, c);
        order.add(run.phase);
      }
      expect(order, [
        PomodoroPhase.shortBreak, // sau phiên 1
        PomodoroPhase.focus,
        PomodoroPhase.shortBreak, // sau phiên 2
        PomodoroPhase.focus,
        PomodoroPhase.shortBreak, // sau phiên 3
        PomodoroPhase.focus,
        PomodoroPhase.longBreak, // sau phiên 4
        PomodoroPhase.focus,
        PomodoroPhase.shortBreak, // chu kỳ mới: sau phiên 5 (1 của chu kỳ 2)
      ]);
    });

    test('số phiên trước nghỉ dài chỉnh được; thời lượng theo cấu hình', () {
      final c = PomodoroConfig.defaults.copyWith(
        sessionsBeforeLongBreak: 2,
        focusMinutes: 50,
        shortBreakMinutes: 10,
        longBreakMinutes: 30,
      );
      var run = PomodoroRun.startFocus(t0, c);
      expect(run.durationSeconds, 3000);
      run = run.startNext(t0, c);
      expect(run.phase, PomodoroPhase.shortBreak);
      expect(run.durationSeconds, 600);
      run = run.startNext(t0, c).startNext(t0, c);
      expect(run.phase, PomodoroPhase.longBreak);
      expect(run.durationSeconds, 1800);
    });

    test('giữ thói quen liên kết qua các giai đoạn', () {
      var run = PomodoroRun.startFocus(t0, PomodoroConfig.defaults, habitId: 3);
      run = run.startNext(t0, PomodoroConfig.defaults);
      expect(run.habitId, 3);
    });
  });

  group('kho Pomodoro: cộng phút vào thói quen (AC-37, AC-38)', () {
    late AppDatabase db;
    late PomodoroRepository repo;
    late int habit;

    setUp(() async {
      db = memoryDatabase();
      repo = PomodoroRepository(db);
      habit = await ActivityRepository(db).create(
        const ActivityDraft(
          name: 'Đọc',
          startDate: '2026-11-01',
          evaluation: Evaluation.duration,
          target: 30,
        ),
      );
    });
    tearDown(() => db.close());

    Future<double> minutesOn(String date) async {
      final e = await EntryRepository(db).find(habit, date);
      return e?.value ?? 0;
    }

    test('bấm dừng giữa chừng thì cộng số phút đã chạy', () async {
      await repo.start(t0, habitId: habit);
      final credited = await repo.stop(
        t0.add(const Duration(minutes: 10, seconds: 10)),
      );
      expect(credited, 10);
      expect(await minutesOn('2026-11-04'), 10);
      expect(await repo.loadRun(), isNull);
    });

    test('dừng khi chưa liên kết thói quen thì không cộng gì', () async {
      await repo.start(t0);
      expect(await repo.stop(t0.add(const Duration(minutes: 12))), 0);
      expect(await minutesOn('2026-11-04'), 0);
      expect(await repo.loadRun(), isNull);
    });

    test('hết giờ thì cộng đủ phút, chỉ một lần dù gọi nhiều lần', () async {
      await repo.start(t0, habitId: habit);
      final end = t0.add(const Duration(minutes: 25, seconds: 3));
      expect(await repo.settleIfFinished(end), 25);
      expect(await repo.settleIfFinished(end), 0);
      expect(await repo.settleIfFinished(end.add(const Duration(hours: 1))), 0);
      expect(await minutesOn('2026-11-04'), 25);
      // Đã cộng rồi mà bấm dừng thì không cộng thêm.
      expect(await repo.stop(end.add(const Duration(minutes: 2))), 0);
      expect(await minutesOn('2026-11-04'), 25);
    });

    test('chưa hết giờ thì settle không cộng gì', () async {
      await repo.start(t0, habitId: habit);
      expect(
        await repo.settleIfFinished(t0.add(const Duration(minutes: 24))),
        0,
      );
      expect(await minutesOn('2026-11-04'), 0);
    });

    test('tắt app khi đang chạy, mở lại sau khi hết giờ vẫn cộng đủ vào đúng ngày (AC-38)', () async {
      await repo.start(DateTime(2026, 11, 4, 23, 50), habitId: habit);
      // Mở lại ngày hôm sau, 8 giờ sáng: phiên đã kết thúc lúc 00:15 ngày 5/11.
      final minutes = await repo.settleIfFinished(DateTime(2026, 11, 5, 8));
      expect(minutes, 25);
      expect(await minutesOn('2026-11-05'), 25);
      expect(await minutesOn('2026-11-04'), 0);
    });

    test(
      'mở lại khi còn đang chạy thì còn lại đúng thời gian (AC-38)',
      () async {
        final run = await repo.start(t0, habitId: habit);
        // "Tắt hẳn app" = chỉ còn dữ liệu đã lưu.
        final back = (await repo.loadRun())!;
        final later = t0.add(const Duration(minutes: 7));
        expect(back.remaining(later), const Duration(minutes: 18));
        expect(back.startedAt, run.startedAt);
        expect(await repo.settleIfFinished(later), 0);
      },
    );

    test('cộng dồn vào kết quả có sẵn của ngày', () async {
      await EntryRepository(db).setValue(habit, '2026-11-04', 12);
      await repo.start(t0, habitId: habit);
      await repo.stop(t0.add(const Duration(minutes: 8)));
      expect(await minutesOn('2026-11-04'), 20);
    });

    test(
      'sang nghỉ rồi phiên tiếp: giữ đếm phiên và chỉ cộng phiên tập trung',
      () async {
        await repo.start(t0, habitId: habit);
        final end1 = t0.add(const Duration(minutes: 25));
        var next = (await repo.startNext(end1))!;
        expect(next.phase, PomodoroPhase.shortBreak);
        expect(next.sessionsDone, 1);
        expect(
          await minutesOn('2026-11-04'),
          25,
        ); // phiên 1 đã cộng khi sang nghỉ

        // Nghỉ xong: bỏ qua nghỉ sang phiên 2; dừng giữa phiên 2 sau 5 phút.
        final end2 = end1.add(const Duration(minutes: 5));
        next = (await repo.startNext(end2))!;
        expect(next.phase, PomodoroPhase.focus);
        expect(next.sessionsDone, 1);
        expect(await repo.stop(end2.add(const Duration(minutes: 5))), 5);
        expect(await minutesOn('2026-11-04'), 30);
      },
    );

    test('đang tập trung mà chưa hết giờ thì không sang giai đoạn kế (phải bấm Dừng)', () async {
      final run = await repo.start(t0, habitId: habit);
      final same = (await repo.startNext(t0.add(const Duration(minutes: 5))))!;
      expect(same.phase, PomodoroPhase.focus);
      expect(same.startedAt, run.startedAt);
      expect(await minutesOn('2026-11-04'), 0);
    });

    test('bỏ qua nghỉ khi đang nghỉ', () async {
      await repo.start(t0);
      await repo.startNext(t0.add(const Duration(minutes: 25)));
      final skipped = (await repo.startNext(
        t0.add(const Duration(minutes: 27)),
      ))!;
      expect(skipped.phase, PomodoroPhase.focus);
    });

    test('lưu và đọc cấu hình', () async {
      expect(await repo.loadConfig(), PomodoroConfig.defaults);
      await repo.setConfig(PomodoroConfig.defaults.copyWith(focusMinutes: 40));
      expect((await repo.loadConfig()).focusMinutes, 40);
      await repo.start(t0);
      expect((await repo.loadRun())!.durationSeconds, 2400);
    });
  });
}
