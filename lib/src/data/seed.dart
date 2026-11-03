import 'package:drift/drift.dart';

import 'database.dart';

/// Danh mục mặc định (AC-30): khóa dịch, tên icon Material, màu.
const defaultCategories = [
  ('health', 'favorite', 0xFFC62828),
  ('sport', 'fitness_center', 0xFFE65100),
  ('study', 'school', 0xFF283593),
  ('work', 'work', 0xFF1565C0),
  ('finance', 'savings', 0xFF2E7D32),
  ('home', 'home', 0xFF5D4037),
  ('mind', 'self_improvement', 0xFF6A1B9A),
  ('other', 'more_horiz', 0xFF455A64),
];

/// Ghi danh mục mặc định khi tạo cơ sở dữ liệu lần đầu.
Future<void> seedDefaults(AppDatabase db) => db.batch((b) {
  var order = 0;
  for (final (key, icon, color) in defaultCategories) {
    b.insert(
      db.categories,
      CategoriesCompanion.insert(
        nameKey: Value(key),
        icon: icon,
        color: color,
        sortOrder: Value(order++),
      ),
    );
  }
});
