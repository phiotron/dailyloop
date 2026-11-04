import 'package:drift/drift.dart';

import 'database.dart';
import 'evaluation.dart';

/// Chữ trong file CSV theo ngôn ngữ app (AC-44).
class CsvLabels {
  const CsvLabels({
    required this.habit,
    required this.task,
    required this.done,
    required this.notDone,
    required this.skipped,
  });

  final String habit;
  final String task;
  final String done;
  final String notDone;
  final String skipped;
}

/// Ô CSV: bọc nháy khi có dấu phẩy/nháy/xuống dòng; ô bắt đầu bằng `= + - @`
/// được thêm dấu `'` để Excel không coi là công thức.
String csvCell(String v) {
  if (v.startsWith(RegExp(r'[=+\-@]'))) v = "'$v";
  return RegExp(r'[",\r\n]').hasMatch(v) ? '"${v.replaceAll('"', '""')}"' : v;
}

String _number(double v) =>
    v == v.roundToDouble() ? '${v.toInt()}' : v.toString();

/// Xuất lịch sử ra CSV: ngày, tên mục, loại, kết quả, giá trị (AC-44).
/// UTF-8 có BOM để Excel và Google Sheets đọc đúng chữ tiếng Việt. Giá trị:
/// Có/Không là 1 hoặc 0, Số lượng theo đơn vị, Thời gian là phút, Danh sách
/// con là số mục con đã xong.
Future<String> buildHistoryCsv(AppDatabase db, CsvLabels labels) async {
  final rows =
      await (db.select(db.entries).join([
            innerJoin(
              db.activities,
              db.activities.id.equalsExp(db.entries.activityId),
            ),
          ])..orderBy([
            OrderingTerm.asc(db.entries.date),
            OrderingTerm.asc(db.activities.sortOrder),
            OrderingTerm.asc(db.activities.id),
          ]))
          .get();
  // Số mục con của từng mục và số đã đánh dấu từng ngày, cho kiểu Danh sách con.
  final totals = <int, int>{};
  for (final r in await db.select(db.checklistItems).get()) {
    totals[r.activityId] = (totals[r.activityId] ?? 0) + 1;
  }
  final checked = <int, int>{};
  for (final m in await db.select(db.checklistMarks).get()) {
    checked[m.entryId] = (checked[m.entryId] ?? 0) + 1;
  }

  final lines = ['date,activity,type,result,value'];
  for (final row in rows) {
    final e = row.readTable(db.entries);
    final a = row.readTable(db.activities);
    final isChecklist = a.evaluation == Evaluation.checklist;
    final count = checked[e.id] ?? 0;
    final String result;
    if (e.skipped) {
      result = labels.skipped;
    } else {
      final ok = isAchieved(
        evaluation: a.evaluation,
        value: e.value,
        target: a.target,
        condition: a.condition,
        checklistMinDone: a.checklistMinDone,
        checkedItems: count,
        totalItems: totals[a.id] ?? 0,
      );
      result = ok ? labels.done : labels.notDone;
    }
    lines.add(
      [
        e.date,
        csvCell(a.name),
        a.kind == ActivityKind.task ? labels.task : labels.habit,
        csvCell(result),
        isChecklist ? '$count' : _number(e.value),
      ].join(','),
    );
  }
  return '﻿${lines.join('\r\n')}\r\n';
}
