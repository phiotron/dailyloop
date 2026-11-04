import 'package:dailyloop/src/data/database.dart' hide Priority;
import 'package:dailyloop/src/reminders/reminder_planner.dart';
import 'package:dailyloop/src/reminders/reminder_service.dart';
import 'package:flutter_test/flutter_test.dart' hide Evaluation;

/// Giới hạn 64 thông báo chờ của iOS (D-010).
List<PlannedReminder> _plan(int n) => [
  for (var i = 0; i < n; i++)
    PlannedReminder(
      id: i,
      activityId: 1,
      reminderId: 1,
      date: '2026-11-05',
      at: DateTime(2026, 11, 5).add(Duration(minutes: i)),
      kind: ReminderKind.notification,
      title: 'Mục $i',
      yesNo: true,
    ),
];

void main() {
  test('lịch ngắn hơn giới hạn thì giữ nguyên', () {
    final plan = _plan(10);
    expect(limitPlanForIos(plan), plan);
  });

  test('cắt đuôi, giữ các lần gần giờ nhất, chừa chỗ cho Pomodoro và hoãn', () {
    final plan = _plan(100);
    final out = limitPlanForIos(plan);
    expect(out.length, iosPendingLimit - iosReservedSlots);
    expect(out.first, plan.first);
    expect(out.last, plan[out.length - 1]);
  });

  test('lần hoãn đang chờ chiếm chỗ của lịch lăn', () {
    final out = limitPlanForIos(_plan(100), snoozesPending: 5);
    expect(out.length, iosPendingLimit - iosReservedSlots - 5);
  });

  test('quá nhiều lần hoãn thì lịch lăn rỗng, không lỗi', () {
    expect(limitPlanForIos(_plan(10), snoozesPending: 100), isEmpty);
  });

  test('tổng không bao giờ vượt 64', () {
    for (var snoozes = 0; snoozes < 70; snoozes += 7) {
      final out = limitPlanForIos(_plan(200), snoozesPending: snoozes);
      expect(out.length + snoozes + 1, lessThanOrEqualTo(iosPendingLimit));
    }
  });
}
