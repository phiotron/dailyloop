import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/dates.dart';
import '../../data/day_repository.dart';
import '../../providers.dart';
import 'day_item_tile.dart';

/// Màn Hôm nay: dải ngày, các mục đến hạn, ghi kết quả (F-02).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = dayOf(ref.watch(clockProvider)());
    final day = ref.watch(selectedDayProvider);
    final items = ref.watch(dayItemsProvider).value ?? const <DayItem>[];
    final isToday = day == today;
    // Ngày tương lai chỉ xem, không ghi (AC-08).
    final editable = !day.isAfter(today);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isToday
              ? l.today
              : DateFormat.MMMMEEEEd(locale)
                    .format(DateTime(day.year, day.month, day.day)),
        ),
        actions: [
          if (!isToday)
            IconButton(
              icon: const Icon(Icons.today),
              tooltip: l.backToToday,
              onPressed: () =>
                  ref.read(selectedDayProvider.notifier).select(today),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: l.pickDay,
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(day.year, day.month, day.day),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                ref.read(selectedDayProvider.notifier).select(picked);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          DayStrip(
            selected: day,
            today: today,
            onSelect: (d) => ref.read(selectedDayProvider.notifier).select(d),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? _EmptyDay(date: dateKey(day))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, i) => DayItemTile(
                      key: ValueKey('${items[i].activity.id}|${items[i].date}'),
                      item: items[i],
                      editable: editable,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Mỗi tab có nút + riêng; tắt hero để không trùng khi mở màn mới.
        heroTag: null,
        tooltip: l.createNew,
        onPressed: () => showCreateSheet(context, date: dateKey(day)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Dải 7 ngày quanh ngày đang chọn (AC-08).
class DayStrip extends StatelessWidget {
  const DayStrip({
    super.key,
    required this.selected,
    required this.today,
    required this.onSelect,
  });

  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final full = DateFormat.yMMMMEEEEd(locale);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          for (var i = -3; i <= 3; i++)
            Builder(
              builder: (context) {
                final d = selected.add(Duration(days: i));
                final local = DateTime(d.year, d.month, d.day);
                final isSelected = i == 0;
                final isToday = d == today;
                return Expanded(
                  child: Semantics(
                    selected: isSelected,
                    button: true,
                    label: full.format(local),
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onSelect(d),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 56),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? scheme.primary : null,
                          borderRadius: BorderRadius.circular(12),
                          border: isToday && !isSelected
                              ? Border.all(color: scheme.primary, width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat.E(locale).format(local),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? scheme.onPrimary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${d.day}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Ngày không có mục nào: hướng dẫn và nút tạo nhanh (AC-11).
class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.emptyToday, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.repeat),
                  label: Text(l.addHabit),
                  onPressed: () => context.push('/habits/new'),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.task_alt),
                  label: Text(l.addTask),
                  onPressed: () => context.push('/tasks/new?date=$date'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
