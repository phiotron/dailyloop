import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/activity_repository.dart';
import '../../data/database.dart';
import '../../data/dates.dart';
import '../../data/schedule.dart';
import '../../l10n_names.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';
import '../../ui/schedule_text.dart';

/// Tạo hoặc sửa thói quen (AC-01 tới AC-05) hoặc việc cần làm (AC-13,
/// AC-14). [habitId] null là tạo mới loại [kind]; sửa thì lấy loại của mục.
class HabitEditorScreen extends ConsumerStatefulWidget {
  const HabitEditorScreen({
    super.key,
    this.habitId,
    this.kind = ActivityKind.habit,
    this.initialDate,
  });

  final int? habitId;
  final ActivityKind kind;

  /// Ngày `YYYY-MM-DD` điền sẵn khi tạo mới (tạo việc từ một ngày ở màn
  /// Hôm nay); null là hôm nay.
  final String? initialDate;

  @override
  ConsumerState<HabitEditorScreen> createState() => _HabitEditorScreenState();
}

/// Một ô nhập mục con; giữ id mục cũ để không mất dấu đã xong.
class _Item {
  _Item({this.id, String text = ''})
    : controller = TextEditingController(text: text);

  final int? id;
  final TextEditingController controller;
}

class _HabitEditorScreenState extends ConsumerState<HabitEditorScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _target = TextEditingController();
  final _unit = TextEditingController();
  final _interval = TextEditingController(text: '2');
  final _times = TextEditingController(text: '3');
  final _items = <_Item>[];

  bool _loading = true;
  int? _categoryId;
  Priority _priority = Priority.normal;
  Evaluation _evaluation = Evaluation.yesNo;
  TargetCondition _condition = TargetCondition.atLeast;
  int? _checklistMinDone;
  late ActivityKind _kind = widget.kind;
  late ScheduleType _scheduleType = widget.kind == ActivityKind.task
      ? ScheduleType.once
      : ScheduleType.daily;
  int _weekdays = 0;
  Set<int> _monthDays = {};
  SchedulePeriod _period = SchedulePeriod.week;

  /// Thói quen luôn có ngày bắt đầu; việc null là "Chưa xếp lịch".
  String? _startDate;
  String? _endDate;

  /// Giờ của việc, số phút từ 00:00.
  int? _timeOfDay;

  bool get _isTask => _kind == ActivityKind.task;

  /// Lỗi đang hiện, theo tên trường của [ActivityDraft.validate].
  String? _error;

  /// Gắn vào dòng báo lỗi đang hiện để cuộn tới.
  final _errorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate ?? dateKey(ref.read(clockProvider)());
    _load();
  }

  Future<void> _load() async {
    final id = widget.habitId;
    if (id != null) {
      final repo = ref.read(activityRepositoryProvider);
      final a = await repo.find(id);
      final items = await repo.checklistOf(id);
      final rule = await repo.currentRule(id);
      if (a != null) {
        _kind = a.kind;
        _timeOfDay = a.timeOfDay;
        _name.text = a.name;
        _description.text = a.description ?? '';
        _categoryId = a.categoryId;
        _priority = a.priority;
        _evaluation = a.evaluation;
        _condition = a.condition ?? TargetCondition.atLeast;
        _target.text = a.target == null ? '' : _formatNumber(a.target!);
        _unit.text = a.unit ?? '';
        _checklistMinDone = a.checklistMinDone;
        _items.addAll([for (final c in items) _Item(id: c.id, text: c.title)]);
        _startDate = a.kind == ActivityKind.task
            ? a.startDate
            : (a.startDate ?? _startDate);
        _endDate = a.endDate;
      }
      if (rule != null) {
        _scheduleType = rule.type;
        _weekdays = rule.weekdays;
        _monthDays = {...rule.monthDays};
        if (rule.interval != null) _interval.text = '${rule.interval}';
        if (rule.timesPerPeriod != null) _times.text = '${rule.timesPerPeriod}';
        _period = rule.period ?? SchedulePeriod.week;
      }
    }
    // Thói quen kiểu Danh sách con cần ít nhất một ô; việc thì không bắt buộc.
    if (_items.isEmpty && !_isTask) _items.add(_Item());
    if (mounted) setState(() => _loading = false);
  }

  static String _formatNumber(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    for (final c in [_name, _description, _target, _unit, _interval, _times]) {
      c.dispose();
    }
    for (final i in _items) {
      i.controller.dispose();
    }
    super.dispose();
  }

  ScheduleRule get _rule => ScheduleRule(
    type: _scheduleType,
    weekdays: _weekdays,
    monthDays: _monthDays,
    interval: int.tryParse(_interval.text.trim()),
    timesPerPeriod: int.tryParse(_times.text.trim()),
    period: _period,
  );

  ActivityDraft get _draft => ActivityDraft(
    kind: _kind,
    name: _name.text,
    description: _description.text,
    categoryId: _categoryId,
    priority: _priority,
    evaluation: _isTask ? Evaluation.yesNo : _evaluation,
    timeOfDay: _isTask && _startDate != null ? _timeOfDay : null,
    target: double.tryParse(_target.text.trim().replaceAll(',', '.')),
    condition: _condition,
    unit: _unit.text,
    checklistMinDone: _checklistMinDone,
    checklist: [for (final i in _items) (id: i.id, title: i.controller.text)],
    startDate: _startDate,
    endDate: _endDate,
    rule: _rule,
  );

  Future<void> _save() async {
    final draft = _draft;
    final error = draft.validate();
    if (error != null) {
      setState(() => _error = error);
      // Lỗi có thể nằm khuất dưới màn hình: cuộn tới để người dùng thấy.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _errorKey.currentContext;
        if (target != null && target.mounted) {
          Scrollable.ensureVisible(
            target,
            alignment: 0.3,
            duration: const Duration(milliseconds: 200),
          );
        }
      });
      return;
    }
    final repo = ref.read(activityRepositoryProvider);
    final id = widget.habitId;
    if (id == null) {
      await repo.create(draft);
    } else {
      await repo.update(id, draft, today: ref.read(clockProvider)());
    }
    if (mounted) context.pop();
  }

  Future<void> _archive() async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(activityRepositoryProvider);
    final id = widget.habitId!;
    await repo.setArchived(id, true);
    if (!mounted) return;
    context.pop();
    showUndoSnackBar(
      message: l.archivedMessage,
      undoLabel: l.undo,
      onUndo: () => repo.setArchived(id, false),
    );
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(_isTask ? l.deleteTaskConfirm : l.deleteHabitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final repo = ref.read(activityRepositoryProvider);
    final snapshot = await repo.delete(widget.habitId!);
    if (!mounted) return;
    context.pop();
    showUndoSnackBar(
      message: l.deleted,
      undoLabel: l.undo,
      onUndo: () => repo.restore(snapshot),
    );
  }

  /// Bỏ con trỏ khỏi ô nhập trước khi mở hộp chọn; không thì đóng hộp xong
  /// con trỏ quay lại ô Tên và bàn phím bật lên (thấy trên máy thật).
  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  Future<void> _pickTime() async {
    _unfocus();
    final t = _timeOfDay ?? 9 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: t ~/ 60, minute: t % 60),
    );
    if (picked != null) {
      setState(() => _timeOfDay = picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _pickDate({required bool end}) async {
    _unfocus();
    final fallback = dateKey(ref.read(clockProvider)());
    final initial = parseDateKey(
      end ? (_endDate ?? _startDate ?? fallback) : (_startDate ?? fallback),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (end) {
        _endDate = dateKey(picked);
      } else {
        _startDate = dateKey(picked);
      }
    });
  }

  String? _errorText(AppLocalizations l, String field) {
    if (_error != field) return null;
    return switch (field) {
      'name' => _name.text.trim().isEmpty ? l.nameRequired : l.nameTooLong,
      'target' => l.targetRequired,
      'checklist' || 'checklistMin' => l.checklistRequired,
      'weekdays' => l.weekdaysRequired,
      'monthDays' => l.monthDaysRequired,
      'interval' => l.intervalInvalid,
      'timesPerPeriod' => l.timesInvalid,
      'endDate' => l.endDateInvalid,
      'startDate' => l.startDateRequired,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final editing = widget.habitId != null;
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final weekStart = ref.watch(weekStartProvider).value ?? DateTime.monday;
    final dateFormat = DateFormat.yMMMd(locale);
    String showDate(String key) {
      final d = parseDateKey(key);
      return dateFormat.format(DateTime(d.year, d.month, d.day));
    }

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );

    Widget errorLine(String field) {
      final e = _errorText(l, field);
      if (e == null) return const SizedBox.shrink();
      return Padding(
        key: _errorKey,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Text(
          e,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isTask
              ? (editing ? l.editTask : l.newTask)
              : (editing ? l.editHabit : l.newHabit),
        ),
        actions: [
          if (editing)
            PopupMenuButton<String>(
              onSelected: (v) => v == 'archive' ? _archive() : _delete(),
              itemBuilder: (context) => [
                if (!_isTask)
                  PopupMenuItem(value: 'archive', child: Text(l.archive)),
                PopupMenuItem(value: 'delete', child: Text(l.delete)),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          // Dựng hết một lần (không lười) để cuộn được tới dòng báo lỗi.
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      controller: _name,
                      maxLength: 60,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: l.name,
                        errorText: _errorText(l, 'name'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _description,
                      maxLength: 300,
                      maxLines: null,
                      decoration: InputDecoration(labelText: l.description),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: DropdownButtonFormField<int?>(
                      initialValue: categories.any((c) => c.id == _categoryId)
                          ? _categoryId
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l.category),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l.noCategory),
                        ),
                        for (final c in categories)
                          DropdownMenuItem(
                            value: c.id,
                            child: Text(categoryLabel(l, c)),
                          ),
                      ],
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: DropdownButtonFormField<Priority>(
                      initialValue: _priority,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l.priority),
                      items: [
                        DropdownMenuItem(
                          value: Priority.low,
                          child: Text(l.priorityLow),
                        ),
                        DropdownMenuItem(
                          value: Priority.normal,
                          child: Text(l.priorityNormal),
                        ),
                        DropdownMenuItem(
                          value: Priority.high,
                          child: Text(l.priorityHigh),
                        ),
                      ],
                      onChanged: (v) => setState(() => _priority = v!),
                    ),
                  ),
                  if (_isTask) ...[
                    header(l.subtasks),
                    _checklistFields(l),
                  ] else ...[
                    header(l.evaluation),
                    RadioGroup<Evaluation>(
                      groupValue: _evaluation,
                      onChanged: (v) => setState(() {
                        _evaluation = v!;
                        _error = null;
                      }),
                      child: Column(
                        children: [
                          RadioListTile(
                            value: Evaluation.yesNo,
                            title: Text(l.evalYesNo),
                          ),
                          RadioListTile(
                            value: Evaluation.quantity,
                            title: Text(l.evalQuantity),
                          ),
                          RadioListTile(
                            value: Evaluation.duration,
                            title: Text(l.evalDuration),
                          ),
                          RadioListTile(
                            value: Evaluation.checklist,
                            title: Text(l.evalChecklist),
                          ),
                        ],
                      ),
                    ),
                    if (_evaluation == Evaluation.quantity ||
                        _evaluation == Evaluation.duration)
                      _targetFields(l),
                    if (_evaluation == Evaluation.checklist)
                      _checklistFields(l),
                  ],
                  header(l.repeat),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<ScheduleType>(
                      initialValue: _scheduleType,
                      isExpanded: true,
                      items: [
                        if (_isTask)
                          DropdownMenuItem(
                            value: ScheduleType.once,
                            child: Text(l.repeatNone),
                          ),
                        DropdownMenuItem(
                          value: ScheduleType.daily,
                          child: Text(l.repeatDaily),
                        ),
                        DropdownMenuItem(
                          value: ScheduleType.weekdays,
                          child: Text(l.repeatWeekdays),
                        ),
                        DropdownMenuItem(
                          value: ScheduleType.monthDays,
                          child: Text(l.repeatMonthDays),
                        ),
                        DropdownMenuItem(
                          value: ScheduleType.everyNDays,
                          child: Text(l.repeatEveryN),
                        ),
                        DropdownMenuItem(
                          value: ScheduleType.timesPerPeriod,
                          child: Text(l.repeatTimesPerPeriod),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _scheduleType = v!;
                        _error = null;
                      }),
                    ),
                  ),
                  _scheduleFields(l, locale, weekStart),
                  errorLine('weekdays'),
                  errorLine('monthDays'),
                  errorLine('interval'),
                  errorLine('timesPerPeriod'),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: Text(
                      _isTask && _scheduleType == ScheduleType.once
                          ? l.taskDate
                          : l.startDate,
                    ),
                    subtitle: Text(
                      _startDate == null
                          ? l.unscheduled
                          : showDate(_startDate!),
                    ),
                    // Việc một lần được bỏ ngày để vào "Chưa xếp lịch" (AC-13).
                    trailing:
                        _isTask &&
                            _scheduleType == ScheduleType.once &&
                            _startDate != null
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: l.clear,
                            onPressed: () => setState(() {
                              _startDate = null;
                              _timeOfDay = null;
                            }),
                          )
                        : null,
                    onTap: () => _pickDate(end: false),
                  ),
                  errorLine('startDate'),
                  if (_isTask && _startDate != null)
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(l.taskTime),
                      subtitle: Text(
                        _timeOfDay == null
                            ? l.noTime
                            : MaterialLocalizations.of(context).formatTimeOfDay(
                                TimeOfDay(
                                  hour: _timeOfDay! ~/ 60,
                                  minute: _timeOfDay! % 60,
                                ),
                              ),
                      ),
                      trailing: _timeOfDay == null
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              tooltip: l.clear,
                              onPressed: () =>
                                  setState(() => _timeOfDay = null),
                            ),
                      onTap: _pickTime,
                    ),
                  if (!_isTask || _scheduleType != ScheduleType.once)
                    ListTile(
                      leading: const Icon(Icons.event_busy_outlined),
                      title: Text(l.endDate),
                      subtitle: Text(
                        _endDate == null ? l.noEndDate : showDate(_endDate!),
                      ),
                      trailing: _endDate == null
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              tooltip: l.clear,
                              onPressed: () => setState(() => _endDate = null),
                            ),
                      onTap: () => _pickDate(end: true),
                    ),
                  errorLine('endDate'),
                ],
              ),
            ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _save,
                  child: Text(l.save),
                ),
              ),
            ),
    );
  }

  Widget _targetFields(AppLocalizations l) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        DropdownButtonFormField<TargetCondition>(
          initialValue: _condition,
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: TargetCondition.atLeast,
              child: Text(l.condAtLeast),
            ),
            DropdownMenuItem(
              value: TargetCondition.exactly,
              child: Text(l.condExactly),
            ),
            DropdownMenuItem(
              value: TargetCondition.atMost,
              child: Text(l.condAtMost),
            ),
          ],
          onChanged: (v) => setState(() => _condition = v!),
        ),
        TextField(
          controller: _target,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: InputDecoration(
            labelText: l.target,
            suffixText: _evaluation == Evaluation.duration ? l.minutes : null,
            errorText: _errorText(l, 'target'),
          ),
        ),
        if (_evaluation == Evaluation.quantity)
          TextField(
            controller: _unit,
            maxLength: 20,
            decoration: InputDecoration(labelText: l.unit),
          ),
      ],
    ),
  );

  Widget _checklistFields(AppLocalizations l) {
    final count = _items.length;
    return Column(
      children: [
        for (final (i, item) in _items.indexed)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.controller,
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: l.itemTitle(i + 1),
                      counterText: '',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: l.removeItem,
                  onPressed: count <= 1 && !_isTask
                      ? null
                      : () => setState(() {
                          _items.removeAt(i).controller.dispose();
                          if ((_checklistMinDone ?? 0) > _items.length) {
                            _checklistMinDone = null;
                          }
                        }),
                ),
              ],
            ),
          ),
        if (count < 20)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l.addItem),
                onPressed: () => setState(() => _items.add(_Item())),
              ),
            ),
          ),
        if (!_isTask)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<int?>(
              initialValue: _checklistMinDone,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.checklistMinDone),
              items: [
                DropdownMenuItem(value: null, child: Text(l.checklistAll)),
                for (var n = 1; n < count; n++)
                  DropdownMenuItem(
                    value: n,
                    child: Text(l.checklistAtLeast(n)),
                  ),
              ],
              onChanged: (v) => setState(() => _checklistMinDone = v),
            ),
          ),
        if (_error == 'checklist' || _error == 'checklistMin')
          Padding(
            key: _errorKey,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l.checklistRequired,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
      ],
    );
  }

  Widget _scheduleFields(AppLocalizations l, String locale, int weekStart) {
    switch (_scheduleType) {
      case ScheduleType.weekdays:
        final names = weekdayShortNames(locale);
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final i in weekdayOrder(weekStart))
                FilterChip(
                  label: Text(names[i]),
                  selected: _weekdays & (1 << i) != 0,
                  onSelected: (on) => setState(() => _weekdays ^= 1 << i),
                ),
            ],
          ),
        );
      case ScheduleType.monthDays:
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (var d = 1; d <= 31; d++)
                FilterChip(
                  label: Text('$d'),
                  showCheckmark: false,
                  selected: _monthDays.contains(d),
                  onSelected: (on) => setState(
                    () => on ? _monthDays.add(d) : _monthDays.remove(d),
                  ),
                ),
            ],
          ),
        );
      case ScheduleType.everyNDays:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _interval,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l.everyNLabel),
          ),
        );
      case ScheduleType.timesPerPeriod:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                controller: _times,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l.timesLabel),
              ),
              DropdownButtonFormField<SchedulePeriod>(
                initialValue: _period,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: SchedulePeriod.week,
                    child: Text(l.perWeek),
                  ),
                  DropdownMenuItem(
                    value: SchedulePeriod.month,
                    child: Text(l.perMonth),
                  ),
                ],
                onChanged: (v) => setState(() => _period = v!),
              ),
            ],
          ),
        );
      case ScheduleType.daily:
      case ScheduleType.once:
        return const SizedBox.shrink();
    }
  }
}
