import 'package:drift/drift.dart';

import 'database.dart';

/// Ghi kết quả của một mục trong một ngày (AC-09, AC-10, AC-12). Mỗi lần
/// ghi nằm trong một giao dịch nên tắt app ngay sau đó không mất dữ liệu.
class EntryRepository {
  EntryRepository(this._db);

  final AppDatabase _db;

  Future<Entry?> find(int activityId, String date) =>
      (_db.select(_db.entries)..where(
            (e) => e.activityId.equals(activityId) & e.date.equals(date),
          ))
          .getSingleOrNull();

  /// Lấy kết quả của ngày, chưa có thì tạo dòng trống.
  Future<Entry> _ensure(int activityId, String date) async {
    final found = await find(activityId, date);
    if (found != null) return found;
    final id = await _db
        .into(_db.entries)
        .insert(EntriesCompanion.insert(activityId: activityId, date: date));
    return (await (_db.select(
      _db.entries,
    )..where((e) => e.id.equals(id))).getSingle());
  }

  /// Ghi giá trị (Có/Không là 1 hoặc 0, Số lượng, Thời gian theo phút).
  /// Ghi giá trị thì bỏ dấu "bỏ qua".
  Future<void> setValue(int activityId, String date, double value) =>
      _db.transaction(() async {
        final e = await _ensure(activityId, date);
        await (_db.update(_db.entries)..where((x) => x.id.equals(e.id))).write(
          EntriesCompanion(
            value: Value(value < 0 ? 0 : value),
            skipped: const Value(false),
          ),
        );
      });

  /// Cộng thêm vào giá trị hiện có (nút +1, cộng phút từ đồng hồ).
  Future<void> addValue(int activityId, String date, double delta) =>
      _db.transaction(() async {
        final e = await _ensure(activityId, date);
        await setValue(activityId, date, e.value + delta);
      });

  /// Có/Không: chạm để xong, chạm lại để bỏ (AC-09).
  Future<void> toggleDone(int activityId, String date) =>
      _db.transaction(() async {
        final e = await find(activityId, date);
        await setValue(activityId, date, (e?.value ?? 0) >= 1 ? 0 : 1);
      });

  /// Đánh dấu "bỏ qua hôm nay" hoặc bỏ dấu đó (AC-10).
  Future<void> setSkipped(int activityId, String date, bool skipped) =>
      _db.transaction(() async {
        final e = await _ensure(activityId, date);
        await (_db.update(_db.entries)..where((x) => x.id.equals(e.id))).write(
          EntriesCompanion(skipped: Value(skipped)),
        );
      });

  /// Đánh dấu hoặc bỏ dấu một mục con trong ngày (AC-09).
  Future<void> toggleMark(
    int activityId,
    String date,
    int itemId,
  ) => _db.transaction(() async {
    final e = await _ensure(activityId, date);
    final existing =
        await (_db.select(_db.checklistMarks)
              ..where((m) => m.entryId.equals(e.id) & m.itemId.equals(itemId)))
            .getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.checklistMarks)
          .insert(
            ChecklistMarksCompanion.insert(entryId: e.id, itemId: itemId),
          );
    } else {
      await (_db.delete(
        _db.checklistMarks,
      )..where((m) => m.entryId.equals(e.id) & m.itemId.equals(itemId))).go();
    }
    await (_db.update(_db.entries)..where((x) => x.id.equals(e.id))).write(
      const EntriesCompanion(skipped: Value(false)),
    );
  });
}
