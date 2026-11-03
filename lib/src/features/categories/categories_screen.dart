import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/database.dart';
import '../../l10n_names.dart';
import '../../providers.dart';
import '../../ui/category_style.dart';

/// Quản lý danh mục: thêm, sửa tên, icon, màu, xóa (AC-31).
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.categories)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          for (final c in categories)
            ListTile(
              key: ValueKey(c.id),
              minTileHeight: 56,
              leading: CategoryAvatar(category: c),
              title: Text(categoryLabel(l, c)),
              onTap: () => showCategoryEditor(context, category: c),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addCategory,
        onPressed: () => showCategoryEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Thêm hoặc sửa danh mục; xóa thì hỏi chuyển các mục sang danh mục khác.
Future<void> showCategoryEditor(BuildContext context, {Category? category}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _CategoryEditor(category: category),
      ),
    );

class _CategoryEditor extends ConsumerStatefulWidget {
  const _CategoryEditor({this.category});

  final Category? category;

  @override
  ConsumerState<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends ConsumerState<_CategoryEditor> {
  final _name = TextEditingController();
  late String _icon = widget.category?.icon ?? 'more_horiz';
  late int _color = widget.category?.color ?? categoryColors.first;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = widget.category;
    if (c != null && _name.text.isEmpty) {
      _name.text = categoryLabel(AppLocalizations.of(context), c);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = l.nameRequired);
      return;
    }
    final repo = ref.read(categoryRepositoryProvider);
    final c = widget.category;
    if (c == null) {
      await repo.add(name: name, icon: _icon, color: _color);
    } else {
      // Không đổi tên thì giữ tên mặc định theo ngôn ngữ.
      final unchangedName = name == categoryLabel(l, c) && c.nameKey != null;
      await repo.edit(
        c.id,
        name: unchangedName ? null : name,
        icon: _icon,
        color: _color,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final c = widget.category!;
    final repo = ref.read(categoryRepositoryProvider);
    final others = (ref.read(categoriesProvider).value ?? const <Category>[])
        .where((o) => o.id != c.id)
        .toList();
    final count = await repo.usageCount(c.id);
    if (!mounted) return;
    // Giá trị trả về: (đích,) với đích null là "Không có danh mục";
    // null là người dùng hủy.
    final choice = await showDialog<(int?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.deleteCategoryConfirm),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(l.moveActivitiesTo(count)),
          ),
          if (count == 0)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, (null,)),
              child: Text(l.delete),
            )
          else ...[
            for (final o in others)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, (o.id,)),
                child: Row(
                  children: [
                    CategoryAvatar(category: o, size: 32),
                    const SizedBox(width: 12),
                    Expanded(child: Text(categoryLabel(l, o))),
                  ],
                ),
              ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, (null,)),
              child: Row(
                children: [
                  const CategoryAvatar(size: 32),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l.noCategory)),
                ],
              ),
            ),
          ],
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
        ],
      ),
    );
    if (choice == null) return;
    await repo.delete(c.id, moveTo: choice.$1);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final editing = widget.category != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            editing ? l.editCategory : l.addCategory,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            maxLength: 40,
            decoration: InputDecoration(labelText: l.name, errorText: _error),
          ),
          Text(l.icon, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final MapEntry(:key, :value) in categoryIcons.entries)
                IconButton(
                  isSelected: key == _icon,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: key == _icon ? Color(_color) : null,
                    foregroundColor: key == _icon ? Colors.white : null,
                  ),
                  tooltip: key,
                  icon: Icon(value),
                  onPressed: () => setState(() => _icon = key),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l.color, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in categoryColors)
                Semantics(
                  button: true,
                  selected: c == _color,
                  label: '${l.color} #${(c & 0xFFFFFF).toRadixString(16)}',
                  child: InkResponse(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: c == _color
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                      child: c == _color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (editing)
                TextButton(onPressed: _delete, child: Text(l.deleteCategory)),
              const Spacer(),
              FilledButton(onPressed: _save, child: Text(l.save)),
            ],
          ),
        ],
      ),
    );
  }
}
