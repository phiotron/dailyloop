import 'dart:convert';

/// Ba giai đoạn của đồng hồ Pomodoro.
enum PomodoroPhase { focus, shortBreak, longBreak }

/// Thời gian các giai đoạn, chỉnh được (AC-35). Mặc định 25, 5, 15 phút và
/// 4 phiên tập trung trước mỗi lần nghỉ dài.
class PomodoroConfig {
  const PomodoroConfig({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
  });

  static const defaults = PomodoroConfig();

  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;

  /// Khoảng cho phép của từng giá trị; ngoài khoảng thì bị kẹp vào (AC-35).
  static const focusRange = (min: 1, max: 180);
  static const shortRange = (min: 1, max: 60);
  static const longRange = (min: 1, max: 120);
  static const sessionsRange = (min: 1, max: 12);

  static int _clamp(int v, ({int min, int max}) r) =>
      v < r.min ? r.min : (v > r.max ? r.max : v);

  PomodoroConfig copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
  }) => PomodoroConfig(
    focusMinutes: _clamp(focusMinutes ?? this.focusMinutes, focusRange),
    shortBreakMinutes: _clamp(
      shortBreakMinutes ?? this.shortBreakMinutes,
      shortRange,
    ),
    longBreakMinutes: _clamp(
      longBreakMinutes ?? this.longBreakMinutes,
      longRange,
    ),
    sessionsBeforeLongBreak: _clamp(
      sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      sessionsRange,
    ),
  );

  int minutesOf(PomodoroPhase p) => switch (p) {
    PomodoroPhase.focus => focusMinutes,
    PomodoroPhase.shortBreak => shortBreakMinutes,
    PomodoroPhase.longBreak => longBreakMinutes,
  };

  String toJson() => jsonEncode({
    'focus': focusMinutes,
    'short': shortBreakMinutes,
    'long': longBreakMinutes,
    'sessions': sessionsBeforeLongBreak,
  });

  /// Đọc lại; dữ liệu hỏng hoặc thiếu thì dùng mặc định, không làm app lỗi.
  static PomodoroConfig fromJson(String? s) {
    if (s == null) return defaults;
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return defaults.copyWith(
        focusMinutes: m['focus'] as int?,
        shortBreakMinutes: m['short'] as int?,
        longBreakMinutes: m['long'] as int?,
        sessionsBeforeLongBreak: m['sessions'] as int?,
      );
    } catch (_) {
      return defaults;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is PomodoroConfig &&
      other.focusMinutes == focusMinutes &&
      other.shortBreakMinutes == shortBreakMinutes &&
      other.longBreakMinutes == longBreakMinutes &&
      other.sessionsBeforeLongBreak == sessionsBeforeLongBreak;

  @override
  int get hashCode => Object.hash(
    focusMinutes,
    shortBreakMinutes,
    longBreakMinutes,
    sessionsBeforeLongBreak,
  );
}

/// Một lần chạy của một giai đoạn. Thời gian còn lại luôn tính từ mốc bắt
/// đầu đã lưu, không dựa vào vòng đếm chạy nền, nên đúng cả khi tắt màn hình,
/// chuyển app hoặc tắt hẳn app (AC-36, AC-38).
class PomodoroRun {
  const PomodoroRun({
    required this.phase,
    required this.startedAt,
    required this.durationSeconds,
    this.habitId,
    this.sessionsDone = 0,
    this.credited = false,
  });

  final PomodoroPhase phase;

  /// Giờ bắt đầu giai đoạn, giờ địa phương.
  final DateTime startedAt;
  final int durationSeconds;

  /// Thói quen kiểu Thời gian được cộng phút khi tập trung xong hoặc dừng.
  final int? habitId;

  /// Số phiên tập trung đã xong TRƯỚC giai đoạn này.
  final int sessionsDone;

  /// Đã cộng phút của giai đoạn tập trung này vào thói quen chưa.
  final bool credited;

  DateTime get endsAt => startedAt.add(Duration(seconds: durationSeconds));

  bool isFinished(DateTime now) => !now.isBefore(endsAt);

  Duration remaining(DateTime now) {
    final r = endsAt.difference(now);
    final full = Duration(seconds: durationSeconds);
    if (r.isNegative) return Duration.zero;
    return r > full ? full : r;
  }

  /// Thời gian đã chạy, không quá thời lượng của giai đoạn.
  Duration elapsed(DateTime now) {
    final e = now.difference(startedAt);
    if (e.isNegative) return Duration.zero;
    final full = Duration(seconds: durationSeconds);
    return e > full ? full : e;
  }

  /// Số phút được cộng khi dừng hoặc hết giờ: thời gian đã chạy làm tròn tới
  /// phút gần nhất; chỉ giai đoạn tập trung mới được cộng (AC-37).
  int creditMinutes(DateTime now) =>
      phase == PomodoroPhase.focus ? (elapsed(now).inSeconds / 60).round() : 0;

  /// Giai đoạn kế tiếp sau khi giai đoạn này xong: nghỉ sau mỗi phiên tập
  /// trung (nghỉ dài sau phiên thứ N), tập trung sau khi nghỉ.
  PomodoroPhase nextPhase(PomodoroConfig config) {
    if (phase != PomodoroPhase.focus) return PomodoroPhase.focus;
    final done = sessionsDone + 1;
    return done % config.sessionsBeforeLongBreak == 0
        ? PomodoroPhase.longBreak
        : PomodoroPhase.shortBreak;
  }

  /// Bắt đầu giai đoạn kế tiếp lúc [now].
  PomodoroRun startNext(DateTime now, PomodoroConfig config) {
    final next = nextPhase(config);
    return PomodoroRun(
      phase: next,
      startedAt: now,
      durationSeconds: config.minutesOf(next) * 60,
      habitId: habitId,
      sessionsDone: phase == PomodoroPhase.focus
          ? sessionsDone + 1
          : sessionsDone,
    );
  }

  PomodoroRun markCredited() => PomodoroRun(
    phase: phase,
    startedAt: startedAt,
    durationSeconds: durationSeconds,
    habitId: habitId,
    sessionsDone: sessionsDone,
    credited: true,
  );

  /// Chạy một phiên tập trung mới lúc [now].
  static PomodoroRun startFocus(
    DateTime now,
    PomodoroConfig config, {
    int? habitId,
    int sessionsDone = 0,
  }) => PomodoroRun(
    phase: PomodoroPhase.focus,
    startedAt: now,
    durationSeconds: config.focusMinutes * 60,
    habitId: habitId,
    sessionsDone: sessionsDone,
  );

  String toJson() => jsonEncode({
    'phase': phase.name,
    'startedAt': startedAt.millisecondsSinceEpoch,
    'duration': durationSeconds,
    'habit': habitId,
    'done': sessionsDone,
    'credited': credited,
  });

  /// Đọc lại; hỏng thì trả null (coi như không có lần chạy nào).
  static PomodoroRun? fromJson(String? s) {
    if (s == null) return null;
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      final phase = PomodoroPhase.values.asNameMap()[m['phase']];
      final started = m['startedAt'] as int?;
      final duration = m['duration'] as int?;
      if (phase == null || started == null || duration == null) return null;
      if (duration <= 0) return null;
      return PomodoroRun(
        phase: phase,
        startedAt: DateTime.fromMillisecondsSinceEpoch(started),
        durationSeconds: duration,
        habitId: m['habit'] as int?,
        sessionsDone: (m['done'] as int?) ?? 0,
        credited: (m['credited'] as bool?) ?? false,
      );
    } catch (_) {
      return null;
    }
  }
}
