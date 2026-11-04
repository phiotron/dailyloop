import '../data/database.dart';
import '../data/dates.dart';
import '../data/day_repository.dart';

/// Một lần nhắc cụ thể sẽ được đặt với hệ điều hành (D-007).
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.activityId,
    required this.reminderId,
    required this.date,
    required this.at,
    required this.kind,
    required this.title,
    required this.yesNo,
  });

  /// Mã thông báo, cố định theo (giờ nhắc, ngày) để đặt lại không bị trùng.
  final int id;
  final int activityId;
  final int reminderId;

  /// Ngày `YYYY-MM-DD` mà lần nhắc thuộc về; nút "Xong" ghi vào ngày này.
  final String date;

  /// Giờ địa phương sẽ nhắc.
  final DateTime at;
  final ReminderKind kind;
  final String title;

  /// Có/Không hoặc việc: thông báo có nút "Xong" (AC-19).
  final bool yesNo;

  /// Dữ liệu đi kèm thông báo: `activityId|date|kind`.
  String get payload => '$activityId|$date|${kind.name}';

  @override
  String toString() => 'PlannedReminder($title @ $at, $kind)';
}

/// Đọc lại [PlannedReminder.payload].
({int activityId, String date, ReminderKind kind})? parsePayload(String? p) {
  final parts = p?.split('|');
  if (parts == null || parts.length != 3) return null;
  final id = int.tryParse(parts[0]);
  final kind = ReminderKind.values.asNameMap()[parts[2]];
  if (id == null || kind == null) return null;
  return (activityId: id, date: parts[1], kind: kind);
}

/// Mã thông báo của một giờ nhắc trong một ngày. Dùng 400 ngày xoay vòng
/// nên trong cửa sổ 7 ngày không bao giờ trùng.
int notificationId(int reminderId, String date) {
  final day =
      parseDateKey(date).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return reminderId * 400 + day % 400;
}

/// Tính các lần nhắc trong [days] ngày tới, tối đa [limit] lần, sớm nhất
/// trước (D-007). Bỏ lần đã qua giờ và lần của mục đã xong hoặc bỏ qua trong
/// ngày (AC-22); chỉ nhắc vào ngày mục đến hạn (AC-17).
Future<List<PlannedReminder>> planReminders(
  AppDatabase db, {
  required DateTime now,
  int days = 7,
  int limit = 100,
}) async {
  final reminders = await db.select(db.reminders).get();
  if (reminders.isEmpty) return const [];
  final byActivity = <int, List<Reminder>>{};
  for (final r in reminders) {
    (byActivity[r.activityId] ??= []).add(r);
  }

  final dayRepo = DayRepository(db);
  final today = dayOf(now);
  final out = <PlannedReminder>[];
  for (var i = 0; i < days; i++) {
    final day = today.add(Duration(days: i));
    // Hôm nay thì gồm cả việc quá hạn: nhắc lại vào giờ của nó.
    final items = await dayRepo.loadDay(day, today: today);
    for (final item in items) {
      final list = byActivity[item.activity.id];
      if (list == null || item.settled) continue;
      for (final r in list) {
        final at = DateTime(
          day.year,
          day.month,
          day.day,
          r.minuteOfDay ~/ 60,
          r.minuteOfDay % 60,
        );
        if (!at.isAfter(now)) continue;
        final a = item.activity;
        out.add(
          PlannedReminder(
            id: notificationId(r.id, dateKey(day)),
            activityId: a.id,
            reminderId: r.id,
            date: item.date,
            at: at,
            kind: r.kind,
            title: a.name,
            yesNo:
                a.kind == ActivityKind.task || a.evaluation == Evaluation.yesNo,
          ),
        );
      }
    }
  }
  out.sort((a, b) => a.at.compareTo(b.at));
  return out.length > limit ? out.sublist(0, limit) : out;
}
