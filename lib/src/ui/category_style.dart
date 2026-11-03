import 'package:flutter/material.dart';

import '../data/database.dart';

/// Bộ icon chọn được cho danh mục. Khóa là chữ lưu trong cơ sở dữ liệu.
const categoryIcons = <String, IconData>{
  'favorite': Icons.favorite,
  'fitness_center': Icons.fitness_center,
  'directions_run': Icons.directions_run,
  'self_improvement': Icons.self_improvement,
  'spa': Icons.spa,
  'local_drink': Icons.local_drink,
  'restaurant': Icons.restaurant,
  'bedtime': Icons.bedtime,
  'medication': Icons.medication,
  'school': Icons.school,
  'menu_book': Icons.menu_book,
  'language': Icons.language,
  'work': Icons.work,
  'computer': Icons.computer,
  'savings': Icons.savings,
  'home': Icons.home,
  'cleaning_services': Icons.cleaning_services,
  'family_restroom': Icons.family_restroom,
  'pets': Icons.pets,
  'music_note': Icons.music_note,
  'brush': Icons.brush,
  'nature': Icons.nature,
  'more_horiz': Icons.more_horiz,
};

IconData iconFor(String key) => categoryIcons[key] ?? Icons.category;

/// Bảng màu danh mục. Màu đậm để icon trắng đạt tương phản tối thiểu 3:1 (AC-50).
const categoryColors = <int>[
  0xFFC62828, 0xFFAD1457, 0xFF6A1B9A, 0xFF4527A0, //
  0xFF283593, 0xFF1565C0, 0xFF0277BD, 0xFF00838F, //
  0xFF00695C, 0xFF2E7D32, 0xFF558B2F, 0xFFE65100, //
  0xFFBF360C, 0xFF5D4037, 0xFF455A64, 0xFF616161, //
];

/// Hình tròn màu danh mục có icon trắng. Không có danh mục thì màu xám.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, this.category, this.size = 40});

  final Category? category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = category;
    return ExcludeSemantics(
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Color(c?.color ?? 0xFF616161),
        child: Icon(
          c == null ? Icons.label_off_outlined : iconFor(c.icon),
          color: Colors.white,
          size: size * 0.55,
        ),
      ),
    );
  }
}
