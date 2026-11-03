import 'package:flutter/material.dart';

import 'database.dart';

/// Đọc, ghi cài đặt trong bảng khóa-giá trị (D-005).
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const themeModeKey = 'themeMode';
  static const localeKey = 'locale';
  static const weekStartKey = 'weekStart';

  Stream<String?> _watch(String key) {
    final query = _db.select(_db.settings)..where((s) => s.key.equals(key));
    return query.watchSingleOrNull().map((row) => row?.value);
  }

  Future<void> _write(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Future<void> _remove(String key) =>
      (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();

  /// Giao diện sáng, tối hoặc theo hệ thống (AC-48). Mặc định theo hệ thống.
  Stream<ThemeMode> watchThemeMode() =>
      _watch(themeModeKey)
          .map((v) => ThemeMode.values.asNameMap()[v] ?? ThemeMode.system);

  Future<void> setThemeMode(ThemeMode mode) => _write(themeModeKey, mode.name);

  /// Mã ngôn ngữ đã chọn; null là theo ngôn ngữ máy (AC-48).
  Stream<String?> watchLocaleCode() => _watch(localeKey);

  Future<void> setLocaleCode(String? code) =>
      code == null ? _remove(localeKey) : _write(localeKey, code);

  /// Ngày đầu tuần: DateTime.monday (mặc định) hoặc DateTime.sunday (AC-48).
  Stream<int> watchWeekStart() => _watch(
    weekStartKey,
  ).map((v) => v == '${DateTime.sunday}' ? DateTime.sunday : DateTime.monday);

  Future<void> setWeekStart(int weekday) => _write(weekStartKey, '$weekday');

  static const onboardingDoneKey = 'onboardingDone';

  /// Đã xem màn chào chưa (AC-34).
  Stream<bool> watchOnboardingDone() =>
      _watch(onboardingDoneKey).map((v) => v == 'true');

  Future<void> setOnboardingDone() => _write(onboardingDoneKey, 'true');
}
