import 'package:drift/drift.dart';

import 'database.dart';

/// Thêm, sửa, xóa danh mục (AC-31).
class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<Category>> watch() => (_db.select(
    _db.categories,
  )..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).watch();

  Future<int> add({
    required String name,
    required String icon,
    required int color,
  }) async {
    final maxOrder = _db.categories.sortOrder.max();
    final last = await (_db.selectOnly(
      _db.categories,
    )..addColumns([maxOrder])).map((r) => r.read(maxOrder)).getSingle();
    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: Value(name.trim()),
            icon: icon,
            color: color,
            sortOrder: Value((last ?? -1) + 1),
          ),
        );
  }

  /// Sửa danh mục. [name] null thì giữ tên hiện có (kể cả tên mặc định
  /// theo ngôn ngữ).
  Future<void> edit(
    int id, {
    String? name,
    required String icon,
    required int color,
  }) => (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
    CategoriesCompanion(
      name: name == null ? const Value.absent() : Value(name.trim()),
      icon: Value(icon),
      color: Value(color),
    ),
  );

  /// Số mục (thói quen và việc) đang thuộc danh mục.
  Future<int> usageCount(int id) async {
    final count = _db.activities.id.count();
    return (_db.selectOnly(_db.activities)
          ..addColumns([count])
          ..where(_db.activities.categoryId.equals(id)))
        .map((r) => r.read(count)!)
        .getSingle();
  }

  /// Xóa danh mục, chuyển các mục của nó sang [moveTo] (null là không có
  /// danh mục) trong cùng một giao dịch (AC-31).
  Future<void> delete(int id, {int? moveTo}) => _db.transaction(() async {
    await (_db.update(_db.activities)..where((a) => a.categoryId.equals(id)))
        .write(ActivitiesCompanion(categoryId: Value(moveTo)));
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  });
}
