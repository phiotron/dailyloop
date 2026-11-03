import '../l10n/app_localizations.dart';
import 'data/database.dart';

/// Tên hiển thị của danh mục mặc định theo `nameKey` (D-005).
/// Trả về null khi khóa không có trong bảng dịch.
String? defaultName(AppLocalizations l, String key) => switch (key) {
  'health' => l.categoryHealth,
  'sport' => l.categorySport,
  'study' => l.categoryStudy,
  'work' => l.categoryWork,
  'finance' => l.categoryFinance,
  'home' => l.categoryHome,
  'mind' => l.categoryMind,
  'other' => l.categoryOther,
  _ => null,
};

/// Tên người dùng đặt nếu có, không thì tên mặc định theo ngôn ngữ.
String categoryLabel(AppLocalizations l, Category c) =>
    c.name ?? (c.nameKey == null ? null : defaultName(l, c.nameKey!)) ?? '';
