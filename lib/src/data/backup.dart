import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'database.dart';
import 'seed.dart';

/// Định dạng file sao lưu `.dailyloop` (AC-42, D-012).
const backupFormat = 'dailyloop-backup';
const backupVersion = 1;

/// File sao lưu sai định dạng, sai phiên bản hoặc hỏng (AC-43).
class BackupFormatException implements Exception {
  BackupFormatException(this.reason);

  final String reason;

  @override
  String toString() => 'BackupFormatException: $reason';
}

/// Mã băm SHA-256 của phần dữ liệu, để phát hiện file bị sửa hoặc hỏng.
String _checksum(Object tables) =>
    sha256.convert(utf8.encode(jsonEncode(tables))).toString();

/// Xuất toàn bộ danh mục, thói quen, việc, lịch lặp, lịch sử, giờ nhắc và cài
/// đặt ra JSON (AC-42). File không mã hóa; mã PIN không nằm trong file (D-011).
Future<String> exportBackup(AppDatabase db, {required DateTime now}) async {
  final tables = {
    'categories': [
      for (final r in await db.select(db.categories).get()) r.toJson(),
    ],
    'activities': [
      for (final r in await db.select(db.activities).get()) r.toJson(),
    ],
    'schedules': [
      for (final r in await db.select(db.schedules).get()) r.toJson(),
    ],
    'checklistItems': [
      for (final r in await db.select(db.checklistItems).get()) r.toJson(),
    ],
    'entries': [for (final r in await db.select(db.entries).get()) r.toJson()],
    'checklistMarks': [
      for (final r in await db.select(db.checklistMarks).get()) r.toJson(),
    ],
    'reminders': [
      for (final r in await db.select(db.reminders).get()) r.toJson(),
    ],
    'settings': [
      for (final r in await db.select(db.settings).get()) r.toJson(),
    ],
  };
  return jsonEncode({
    'format': backupFormat,
    'version': backupVersion,
    'schemaVersion': db.schemaVersion,
    'exportedAt': now.toIso8601String(),
    'checksum': _checksum(tables),
    'tables': tables,
  });
}

typedef _Parsed = ({
  List<Category> categories,
  List<Activity> activities,
  List<Schedule> schedules,
  List<ChecklistItem> checklistItems,
  List<Entry> entries,
  List<ChecklistMark> checklistMarks,
  List<Reminder> reminders,
  List<Setting> settings,
});

/// Đọc và kiểm hết file (định dạng, phiên bản, mã băm, từng dòng) mà KHÔNG đụng
/// cơ sở dữ liệu. Ném [BackupFormatException] nếu có gì sai.
_Parsed _parseBackup(String content, {required int schemaVersion}) {
  final Map<String, dynamic> root;
  try {
    root = jsonDecode(content) as Map<String, dynamic>;
  } catch (_) {
    throw BackupFormatException('không phải JSON');
  }
  if (root['format'] != backupFormat) {
    throw BackupFormatException('sai định dạng');
  }
  final version = root['version'];
  if (version is! int || version < 1 || version > backupVersion) {
    throw BackupFormatException('phiên bản $version không hỗ trợ');
  }
  final schema = root['schemaVersion'];
  if (schema is! int || schema > schemaVersion) {
    // File tạo bởi bản app mới hơn: có thể chứa cột mà bản này không biết.
    throw BackupFormatException('file từ bản app mới hơn');
  }
  final tables = root['tables'];
  if (tables is! Map<String, dynamic> ||
      root['checksum'] != _checksum(tables)) {
    throw BackupFormatException('mã băm không khớp');
  }

  List<T> rows<T>(String name, T Function(Map<String, dynamic>) fromJson) {
    final list = tables[name];
    if (list is! List) throw BackupFormatException('thiếu bảng $name');
    try {
      return [for (final r in list) fromJson(r as Map<String, dynamic>)];
    } catch (e) {
      throw BackupFormatException('bảng $name hỏng: $e');
    }
  }

  return (
    categories: rows('categories', Category.fromJson),
    activities: rows('activities', Activity.fromJson),
    schedules: rows('schedules', Schedule.fromJson),
    checklistItems: rows('checklistItems', ChecklistItem.fromJson),
    entries: rows('entries', Entry.fromJson),
    checklistMarks: rows('checklistMarks', ChecklistMark.fromJson),
    reminders: rows('reminders', Reminder.fromJson),
    settings: rows('settings', Setting.fromJson),
  );
}

/// Kiểm file sao lưu mà không ghi gì; dùng để báo file hỏng TRƯỚC khi hỏi xác
/// nhận (AC-43).
void validateBackup(AppDatabase db, String content) =>
    _parseBackup(content, schemaVersion: db.schemaVersion);

/// Thay TOÀN BỘ dữ liệu bằng bản sao lưu (AC-43). Kiểm tra định dạng, phiên
/// bản, mã băm và đọc hết dữ liệu TRƯỚC khi xóa; xóa và ghi trong một giao dịch
/// nên có lỗi giữa chừng thì dữ liệu hiện có giữ nguyên.
Future<void> importBackup(AppDatabase db, String content) async {
  final p = _parseBackup(content, schemaVersion: db.schemaVersion);
  try {
    await db.transaction(() async {
      await _clearAll(db);
      await db.batch((b) {
        b.insertAll(db.categories, p.categories);
        b.insertAll(db.activities, p.activities);
        b.insertAll(db.schedules, p.schedules);
        b.insertAll(db.checklistItems, p.checklistItems);
        b.insertAll(db.entries, p.entries);
        b.insertAll(db.checklistMarks, p.checklistMarks);
        b.insertAll(db.reminders, p.reminders);
        b.insertAll(db.settings, p.settings);
      });
    });
  } catch (e) {
    // Ví dụ khóa ngoại sai, giá trị âm, trùng khóa: giao dịch đã quay lui.
    throw BackupFormatException('dữ liệu không hợp lệ: $e');
  }
}

/// Xóa hết các bảng, con trước cha (khóa ngoại bật).
Future<void> _clearAll(AppDatabase db) async {
  await db.delete(db.checklistMarks).go();
  await db.delete(db.entries).go();
  await db.delete(db.checklistItems).go();
  await db.delete(db.reminders).go();
  await db.delete(db.schedules).go();
  await db.delete(db.activities).go();
  await db.delete(db.categories).go();
  await db.delete(db.settings).go();
}

/// Xóa toàn bộ dữ liệu rồi tạo lại danh mục mặc định, như lúc mới cài (AC-52).
/// Cài đặt cũng bị xóa nên màn chào hiện lại.
Future<void> deleteAllData(AppDatabase db) => db.transaction(() async {
  await _clearAll(db);
  await db.customStatement('DELETE FROM sqlite_sequence');
  await seedDefaults(db);
});
