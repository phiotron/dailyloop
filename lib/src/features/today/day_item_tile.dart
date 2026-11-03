import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/database.dart';
import '../../data/dates.dart';
import '../../data/day_repository.dart';
import '../../providers.dart';
import '../../ui/messenger.dart';

String _number(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

/// Mô tả tiến độ, ví dụ "5 trên 8 ly", "2 trên 3 mục"; null với Có/Không.
String? progressText(AppLocalizations l, DayItem item) {
  final a = item.activity;
  if (a.isTaskOrYesNo) {
    // Việc có thể có việc con, chỉ để đánh dấu, không quyết định xong.
    return item.items.isEmpty
        ? null
        : l.itemsDone(item.marked.length, item.items.length);
  }
  switch (a.evaluation) {
    case Evaluation.quantity:
      final unit = a.unit == null || a.unit!.isEmpty ? '' : ' ${a.unit}';
      return '${l.progress(_number(item.value), _number(a.target ?? 0))}$unit';
    case Evaluation.duration:
      return '${l.progress(_number(item.value), _number(a.target ?? 0))} '
          '${l.minutes}';
    case Evaluation.checklist:
      return l.itemsDone(item.marked.length, item.items.length);
    case Evaluation.yesNo:
      return null;
  }
}

extension on Activity {
  bool get isTaskOrYesNo =>
      kind == ActivityKind.task || evaluation == Evaluation.yesNo;
}

/// Một mục ở màn Hôm nay hoặc màn Việc: chạm để ghi kết quả (AC-09).
/// [editable] false (ngày tương lai) thì không ghi được (AC-08).
class DayItemTile extends ConsumerWidget {
  const DayItemTile({
    super.key,
    required this.item,
    this.editable = true,
    this.showDate = false,
  });

  final DayItem item;
  final bool editable;

  /// Hiện ngày của việc (màn Việc).
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = item.activity;
    final entries = ref.read(entryRepositoryProvider);
    final yesNo = a.isTaskOrYesNo;

    void record() {
      if (!editable) {
        showMessage(l.futureDay);
        return;
      }
      if (yesNo) {
        entries.toggleDone(a.id, item.date);
      } else if (a.evaluation == Evaluation.checklist) {
        showChecklistSheet(context, item);
      } else {
        showValueSheet(context, item);
      }
    }

    final status = item.achieved
        ? l.achieved
        : item.skipped
        ? l.skipped
        : l.notAchieved;
    final progress = progressText(l, item);
    final details = <String>[
      if (item.overdueDays > 0) l.overdueDays(item.overdueDays),
      if (showDate && a.startDate != null && item.overdueDays == 0)
        _dateLabel(context, a.startDate!),
      if (a.timeOfDay != null)
        MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay(hour: a.timeOfDay! ~/ 60, minute: a.timeOfDay! % 60),
        ),
      ?progress,
      if (item.skipped) l.skipped,
    ];

    // Trạng thái có cả icon và chữ, không chỉ màu (AC-50).
    final icon = item.achieved
        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
        : item.skipped
        ? Icon(Icons.redo, color: theme.colorScheme.outline)
        : Icon(Icons.radio_button_unchecked, color: theme.colorScheme.outline);

    return MergeSemantics(
      child: ListTile(
        minTileHeight: 64,
        enabled: true,
        leading: Semantics(
          label: status,
          button: true,
          child: IconButton(icon: icon, tooltip: status, onPressed: record),
        ),
        title: Text(
          a.name,
          style: item.settled
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        subtitle: details.isEmpty
            ? null
            : Text(
                details.join(' · '),
                style: item.overdueDays > 0
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (a.kind == ActivityKind.habit &&
                a.evaluation == Evaluation.quantity &&
                editable)
              IconButton(
                icon: const Icon(Icons.exposure_plus_1),
                tooltip: l.addOne,
                onPressed: () => entries.addValue(a.id, item.date, 1),
              ),
            PopupMenuButton<String>(
              onSelected: (v) {
                switch (v) {
                  case 'skip':
                    entries.setSkipped(a.id, item.date, !item.skipped);
                  case 'edit':
                    context.push(
                      a.kind == ActivityKind.task
                          ? '/tasks/${a.id}'
                          : '/habits/${a.id}',
                    );
                }
              },
              itemBuilder: (context) => [
                if (editable && a.kind == ActivityKind.habit)
                  PopupMenuItem(
                    value: 'skip',
                    child: Text(item.skipped ? l.unskip : l.skipToday),
                  ),
                PopupMenuItem(value: 'edit', child: Text(l.edit)),
              ],
            ),
          ],
        ),
        onTap: record,
      ),
    );
  }

  static String _dateLabel(BuildContext context, String key) {
    final d = parseDateKey(key);
    return DateFormat.MMMd(Localizations.localeOf(context).toString())
        .format(DateTime(d.year, d.month, d.day));
  }
}

/// Nhập giá trị cho kiểu Số lượng hoặc Thời gian (phút) (AC-09).
Future<void> showValueSheet(BuildContext context, DayItem item) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _ValueSheet(item: item),
      ),
    );

class _ValueSheet extends ConsumerStatefulWidget {
  const _ValueSheet({required this.item});

  final DayItem item;

  @override
  ConsumerState<_ValueSheet> createState() => _ValueSheetState();
}

class _ValueSheetState extends ConsumerState<_ValueSheet> {
  late final _value = TextEditingController(
    text: widget.item.value == 0 ? '' : _number(widget.item.value),
  );

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = double.tryParse(_value.text.trim().replaceAll(',', '.')) ?? 0;
    await ref
        .read(entryRepositoryProvider)
        .setValue(widget.item.activity.id, widget.item.date, v);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = widget.item.activity;
    final suffix = a.evaluation == Evaluation.duration ? l.minutes : a.unit;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(a.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _value,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: l.recordValue,
              suffixText: suffix,
              helperText: '${l.target}: ${_number(a.target ?? 0)}',
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _save,
            child: Text(l.save),
          ),
        ],
      ),
    );
  }
}

/// Đánh dấu từng mục con trong ngày (AC-09).
Future<void> showChecklistSheet(BuildContext context, DayItem item) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _ChecklistSheet(item: item),
    );

class _ChecklistSheet extends ConsumerStatefulWidget {
  const _ChecklistSheet({required this.item});

  final DayItem item;

  @override
  ConsumerState<_ChecklistSheet> createState() => _ChecklistSheetState();
}

class _ChecklistSheetState extends ConsumerState<_ChecklistSheet> {
  late final _marked = {...widget.item.marked};

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                item.activity.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final c in item.items)
              CheckboxListTile(
                value: _marked.contains(c.id),
                title: Text(c.title),
                onChanged: (_) {
                  setState(
                    () => _marked.contains(c.id)
                        ? _marked.remove(c.id)
                        : _marked.add(c.id),
                  );
                  ref
                      .read(entryRepositoryProvider)
                      .toggleMark(item.activity.id, item.date, c.id);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Nút "+" mở chọn tạo thói quen hay việc (AC-33).
Future<void> showCreateSheet(BuildContext context, {String? date}) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(l.newHabit),
            onTap: () {
              Navigator.pop(sheet);
              context.push('/habits/new');
            },
          ),
          ListTile(
            leading: const Icon(Icons.task_alt),
            title: Text(l.newTask),
            onTap: () {
              Navigator.pop(sheet);
              context.push(
                date == null ? '/tasks/new' : '/tasks/new?date=$date',
              );
            },
          ),
        ],
      ),
    ),
  );
}
