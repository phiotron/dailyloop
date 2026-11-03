import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/database.dart';
import '../../l10n_names.dart';
import '../../providers.dart';
import '../../ui/category_style.dart';
import '../../ui/schedule_text.dart';

/// Danh sách thói quen: lọc theo danh mục, kéo để sắp xếp (AC-06, AC-32).
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final habits = ref.watch(habitsProvider).value ?? const <Activity>[];
    final filter = ref.watch(habitFilterProvider);
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final byId = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: Text(l.habits),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: l.archived,
            onPressed: () => context.push('/habits/archived'),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l.categories,
            onPressed: () => context.push('/categories'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Không cố định chiều cao để chữ cỡ 200% không bị cắt (AC-50).
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: l.allCategories,
                  selected: filter == null,
                  onSelected: () =>
                      ref.read(habitFilterProvider.notifier).select(null),
                ),
                for (final c in categories)
                  _FilterChip(
                    label: categoryLabel(l, c),
                    selected: filter == c.id,
                    onSelected: () =>
                        ref.read(habitFilterProvider.notifier).select(c.id),
                  ),
              ],
            ),
          ),
          Expanded(
            child: habits.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        filter == null ? l.emptyHabits : l.emptyHabitsFiltered,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: habits.length,
                    onReorderItem: (oldIndex, newIndex) {
                      final ids = habits.map((h) => h.id).toList();
                      ids.insert(newIndex, ids.removeAt(oldIndex));
                      ref.read(activityRepositoryProvider).reorder(ids);
                    },
                    itemBuilder: (context, i) => HabitTile(
                      key: ValueKey(habits[i].id),
                      habit: habits[i],
                      category: byId[habits[i].categoryId],
                      dragIndex: i,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Mỗi tab có nút + riêng; tắt hero để không trùng khi mở màn mới.
        heroTag: null,
        tooltip: l.newHabit,
        onPressed: () => context.push('/habits/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    ),
  );
}

/// Một dòng thói quen: icon danh mục, tên, mô tả lịch; chạm để sửa.
class HabitTile extends ConsumerWidget {
  const HabitTile({
    super.key,
    required this.habit,
    this.category,
    this.dragIndex,
    this.trailing,
  });

  final Activity habit;
  final Category? category;

  /// Có thì hiện tay kéo để sắp xếp.
  final int? dragIndex;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final rule = ref.watch(currentRuleProvider(habit.id)).value;
    final weekStart = ref.watch(weekStartProvider).value ?? DateTime.monday;
    return ListTile(
      minTileHeight: 64,
      leading: CategoryAvatar(category: category),
      title: Text(habit.name),
      subtitle: rule == null
          ? null
          : Text(scheduleSummary(l, locale, rule, weekStart: weekStart)),
      trailing:
          trailing ??
          (dragIndex == null
              ? null
              : ReorderableDragStartListener(
                  index: dragIndex!,
                  child: Tooltip(
                    message: l.reorderHint,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                )),
      onTap: () => context.push('/habits/${habit.id}'),
    );
  }
}

/// Thói quen đã lưu trữ, khôi phục được (AC-05).
class ArchivedHabitsScreen extends ConsumerWidget {
  const ArchivedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final habits =
        ref.watch(archivedHabitsProvider).value ?? const <Activity>[];
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final byId = {for (final c in categories) c.id: c};
    return Scaffold(
      appBar: AppBar(title: Text(l.archived)),
      body: habits.isEmpty
          ? Center(child: Text(l.emptyArchived))
          : ListView(
              children: [
                for (final h in habits)
                  HabitTile(
                    key: ValueKey(h.id),
                    habit: h,
                    category: byId[h.categoryId],
                    trailing: TextButton(
                      onPressed: () => ref
                          .read(activityRepositoryProvider)
                          .setArchived(h.id, false),
                      child: Text(l.unarchive),
                    ),
                  ),
              ],
            ),
    );
  }
}
