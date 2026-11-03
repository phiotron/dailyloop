/// Ngày dạng chữ `YYYY-MM-DD` theo giờ địa phương (D-005).
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Đọc `YYYY-MM-DD` thành ngày UTC lúc 00:00, để cộng trừ ngày không bị
/// lệch giờ mùa hè.
DateTime parseDateKey(String key) {
  final p = key.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// Ngày UTC lúc 00:00 cùng năm, tháng, ngày với [d].
DateTime dayOf(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Số ngày từ [from] tới [to] (cả hai là ngày UTC 00:00).
int daysBetween(DateTime from, DateTime to) =>
    dayOf(to).difference(dayOf(from)).inDays;

/// Ngày cuối của tháng chứa [d].
int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;
