import 'database.dart';

/// Một kết quả trong ngày có đạt mục tiêu không (AC-02, AC-09).
/// [value] là giá trị đã ghi, [checkedItems] là số mục con đã xong,
/// [totalItems] là tổng số mục con.
bool isAchieved({
  required Evaluation evaluation,
  required double value,
  double? target,
  TargetCondition? condition,
  int? checklistMinDone,
  int checkedItems = 0,
  int totalItems = 0,
}) {
  switch (evaluation) {
    case Evaluation.yesNo:
      return value >= 1;
    case Evaluation.quantity:
    case Evaluation.duration:
      final t = target ?? 0;
      return switch (condition ?? TargetCondition.atLeast) {
        TargetCondition.atLeast => value >= t,
        TargetCondition.exactly => value == t,
        // "Nhiều nhất" (ví dụ ≤ 2 ly cà phê): ngày chưa ghi gì tính là 0, đạt.
        TargetCondition.atMost => value <= t,
      };
    case Evaluation.checklist:
      if (totalItems == 0) return false;
      final need = (checklistMinDone ?? totalItems).clamp(1, totalItems);
      return checkedItems >= need;
  }
}
