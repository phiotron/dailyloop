import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/database.dart' hide Priority;
import '../../pomodoro/pomodoro_state.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';

/// Đồng hồ Pomodoro (F-09). Thời gian còn lại luôn tính từ mốc bắt đầu đã
/// lưu; bộ hẹn giờ chỉ để vẽ lại màn hình mỗi giây (AC-36).
class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key, this.habitId});

  final int? habitId;

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  Timer? _ticker;
  int? _habit;
  bool _settling = false;

  @override
  void initState() {
    super.initState();
    _habit = widget.habitId;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    if (!mounted) return;
    final now = ref.read(clockProvider)();
    final run = ref.read(pomodoroRunProvider).value;
    if (run != null &&
        run.phase == PomodoroPhase.focus &&
        !run.credited &&
        run.isFinished(now) &&
        !_settling) {
      _settling = true;
      final l = AppLocalizations.of(context);
      try {
        final m = await ref
            .read(pomodoroRepositoryProvider)
            .settleIfFinished(now);
        if (m > 0) showMessage(l.pomodoroCredited(m));
      } finally {
        _settling = false;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _scheduleEnd(PomodoroRun run) async {
    final l = AppLocalizations.of(context);
    await ref
        .read(reminderGatewayProvider)
        .scheduleTimerEnd(
          run.endsAt,
          title: l.pomodoroDoneTitle,
          body: l.pomodoroDoneBody,
        );
  }

  Future<void> _start() async {
    final gateway = ref.read(reminderGatewayProvider);
    final perms = await gateway.permissions();
    if (!perms.notifications) await gateway.requestNotifications();
    final run = await ref
        .read(pomodoroRepositoryProvider)
        .start(ref.read(clockProvider)(), habitId: _habit);
    if (mounted) await _scheduleEnd(run);
  }

  Future<void> _stop() async {
    final l = AppLocalizations.of(context);
    final m = await ref
        .read(pomodoroRepositoryProvider)
        .stop(ref.read(clockProvider)());
    await ref.read(reminderGatewayProvider).cancelTimerEnd();
    if (m > 0) showMessage(l.pomodoroCredited(m));
  }

  Future<void> _next() async {
    final run = await ref
        .read(pomodoroRepositoryProvider)
        .startNext(ref.read(clockProvider)());
    if (run != null && mounted) await _scheduleEnd(run);
  }

  Future<void> _edit(PomodoroConfig c) =>
      ref.read(pomodoroRepositoryProvider).setConfig(c);

  String _phaseName(AppLocalizations l, PomodoroPhase p) => switch (p) {
    PomodoroPhase.focus => l.phaseFocus,
    PomodoroPhase.shortBreak => l.phaseShortBreak,
    PomodoroPhase.longBreak => l.phaseLongBreak,
  };

  static String format(Duration d) {
    final s = (d.inMilliseconds / 1000).ceil();
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final run = ref.watch(pomodoroRunProvider).value;
    final config =
        ref.watch(pomodoroConfigProvider).value ?? PomodoroConfig.defaults;
    final now = ref.read(clockProvider)();
    final finished = run != null && run.isFinished(now);
    final habits = (ref.watch(habitsProvider).value ?? const <Activity>[])
        .where((a) => a.evaluation == Evaluation.duration)
        .toList();
    final linked = run?.habitId ?? _habit;
    final theme = Theme.of(context);
    final timeText = run == null
        ? format(Duration(minutes: config.focusMinutes))
        : finished
        ? l.pomodoroFinished
        : format(run.remaining(now));

    return Scaffold(
      appBar: AppBar(title: Text(l.pomodoro)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          if (run != null) ...[
            Center(
              child: Text(
                '${_phaseName(l, run.phase)} · ${l.pomodoroSession(run.phase == PomodoroPhase.focus ? run.sessionsDone + 1 : run.sessionsDone)}',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Center(
            child: Text(
              timeText,
              key: const Key('pomodoroTime'),
              style: theme.textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: 24),
          if (run == null)
            Center(
              child: FilledButton(
                onPressed: _start,
                child: Text(l.pomodoroStart),
              ),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                if (finished)
                  FilledButton(
                    onPressed: _next,
                    child: Text(l.pomodoroNextPhase),
                  )
                else if (run.phase != PomodoroPhase.focus)
                  OutlinedButton(
                    onPressed: _next,
                    child: Text(l.pomodoroSkipBreak),
                  ),
                FilledButton.tonal(
                  onPressed: _stop,
                  child: Text(l.pomodoroStop),
                ),
              ],
            ),
          const SizedBox(height: 32),
          if (run == null && habits.isNotEmpty) ...[
            Text(l.pomodoroHabit, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              initialValue: habits.any((a) => a.id == linked) ? linked : null,
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l.pomodoroNoHabit),
                ),
                for (final a in habits)
                  DropdownMenuItem<int?>(value: a.id, child: Text(a.name)),
              ],
              onChanged: (v) => setState(() => _habit = v),
            ),
            const SizedBox(height: 24),
          ],
          Text(l.pomodoroSettings, style: theme.textTheme.titleSmall),
          _Stepper(
            label: l.pomodoroFocus,
            value: config.focusMinutes,
            onChanged: (v) => _edit(config.copyWith(focusMinutes: v)),
          ),
          _Stepper(
            label: l.pomodoroShortBreak,
            value: config.shortBreakMinutes,
            onChanged: (v) => _edit(config.copyWith(shortBreakMinutes: v)),
          ),
          _Stepper(
            label: l.pomodoroLongBreak,
            value: config.longBreakMinutes,
            onChanged: (v) => _edit(config.copyWith(longBreakMinutes: v)),
          ),
          _Stepper(
            label: l.pomodoroSessions,
            value: config.sessionsBeforeLongBreak,
            onChanged: (v) =>
                _edit(config.copyWith(sessionsBeforeLongBreak: v)),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label)),
      IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        tooltip: '− $label',
        onPressed: () => onChanged(value - 1),
      ),
      SizedBox(width: 36, child: Text('$value', textAlign: TextAlign.center)),
      IconButton(
        icon: const Icon(Icons.add_circle_outline),
        tooltip: '+ $label',
        onPressed: () => onChanged(value + 1),
      ),
    ],
  );
}
