import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/day_repository.dart';
import '../../providers.dart';
import '../today/day_item_tile.dart';

/// Màn Việc: mọi việc cần làm theo bộ lọc (AC-16).
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final filter = ref.watch(taskFilterProvider);
    final items = ref.watch(taskItemsProvider).value ?? const <DayItem>[];
    final labels = {
      TaskFilter.today: l.filterToday,
      TaskFilter.upcoming: l.filterUpcoming,
      TaskFilter.overdue: l.filterOverdue,
      TaskFilter.unscheduled: l.filterUnscheduled,
      TaskFilter.done: l.filterDone,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.tasks)),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (final f in TaskFilter.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(labels[f]!),
                      selected: f == filter,
                      onSelected: (_) =>
                          ref.read(taskFilterProvider.notifier).select(f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(l.emptyTasks))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: items.length,
                    itemBuilder: (context, i) => DayItemTile(
                      key: ValueKey('${items[i].activity.id}|${items[i].date}'),
                      item: items[i],
                      showDate: true,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Mỗi tab có nút + riêng; tắt hero để không trùng khi mở màn mới.
        heroTag: null,
        tooltip: l.createNew,
        onPressed: () => showCreateSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
