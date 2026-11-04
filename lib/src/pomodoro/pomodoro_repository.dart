import 'dart:async';

import '../data/database.dart';
import '../data/dates.dart';
import '../data/entry_repository.dart';
import '../data/settings_repository.dart';
import 'pomodoro_state.dart';

/// Lưu cấu hình và lần chạy Pomodoro trong bảng cài đặt, và cộng số phút vào
/// thói quen kiểu Thời gian (F-09, D-009). Mọi việc tính theo mốc thời gian
/// đã lưu nên giữ đúng khi tắt màn hình hoặc tắt hẳn app (AC-36, AC-38).
class PomodoroRepository {
  PomodoroRepository(this._db)
    : _settings = SettingsRepository(_db),
      _entries = EntryRepository(_db);

  final AppDatabase _db;
  final SettingsRepository _settings;
  final EntryRepository _entries;

  static const configKey = 'pomodoroConfig';
  static const runKey = 'pomodoroRun';

  Stream<PomodoroConfig> watchConfig() =>
      _settings.watchValue(configKey).map(PomodoroConfig.fromJson);

  Future<PomodoroConfig> loadConfig() async =>
      PomodoroConfig.fromJson(await _settings.readValue(configKey));

  Future<void> setConfig(PomodoroConfig c) =>
      _settings.writeValue(configKey, c.toJson());

  Stream<PomodoroRun?> watchRun() =>
      _settings.watchValue(runKey).map(PomodoroRun.fromJson);

  Future<PomodoroRun?> loadRun() async =>
      PomodoroRun.fromJson(await _settings.readValue(runKey));

  Future<void> _saveRun(PomodoroRun r) =>
      _settings.writeValue(runKey, r.toJson());

  /// Bắt đầu phiên tập trung đầu tiên lúc [now]; [habitId] là thói quen kiểu
  /// Thời gian được cộng phút (AC-37).
  Future<PomodoroRun> start(DateTime now, {int? habitId}) async {
    final run = PomodoroRun.startFocus(
      now,
      await loadConfig(),
      habitId: habitId,
    );
    await _saveRun(run);
    return run;
  }

  /// Cộng số phút của [run] vào thói quen, vào ngày giai đoạn thực sự kết
  /// thúc (không quá [now]). Trả về số phút đã cộng.
  Future<int> _credit(PomodoroRun run, DateTime now) async {
    final minutes = run.creditMinutes(now);
    final habit = run.habitId;
    if (habit == null || minutes <= 0) return 0;
    final when = now.isBefore(run.endsAt) ? now : run.endsAt;
    await _entries.addValue(habit, dateKey(when), minutes.toDouble());
    return minutes;
  }

  /// Dừng: cộng phút đã chạy của phiên tập trung (nếu chưa cộng) rồi xóa lần
  /// chạy (AC-37). Trả về số phút đã cộng.
  Future<int> stop(DateTime now) => _db.transaction(() async {
    final run = await loadRun();
    if (run == null) return 0;
    final minutes = run.credited ? 0 : await _credit(run, now);
    await _settings.removeValue(runKey);
    return minutes;
  });

  /// Nếu giai đoạn tập trung đã hết giờ mà chưa cộng phút (hết giờ lúc app
  /// đóng, hoặc vừa hết khi đang mở) thì cộng đủ phút, đúng một lần (AC-37,
  /// AC-38). Trả về số phút đã cộng.
  Future<int> settleIfFinished(DateTime now) => _db.transaction(() async {
    final run = await loadRun();
    if (run == null ||
        run.phase != PomodoroPhase.focus ||
        run.credited ||
        !run.isFinished(now)) {
      return 0;
    }
    final minutes = await _credit(run, now);
    await _saveRun(run.markCredited());
    return minutes;
  });

  /// Sang giai đoạn kế tiếp lúc [now]: dùng khi giai đoạn hiện tại đã hết
  /// giờ, hoặc để bỏ qua nghỉ. Đang tập trung mà chưa hết giờ thì không làm
  /// gì (phải bấm Dừng).
  Future<PomodoroRun?> startNext(DateTime now) => _db.transaction(() async {
    final run = await loadRun();
    if (run == null) return null;
    if (run.phase == PomodoroPhase.focus && !run.isFinished(now)) return run;
    if (run.phase == PomodoroPhase.focus && !run.credited) {
      await _credit(run, now);
    }
    final next = run.startNext(now, await loadConfig());
    await _saveRun(next);
    return next;
  });
}
