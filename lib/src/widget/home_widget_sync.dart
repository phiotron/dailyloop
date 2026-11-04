import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../data/dates.dart';
import '../data/day_repository.dart';

/// Chữ trên widget theo ngôn ngữ đang dùng của app.
class HomeWidgetTexts {
  const HomeWidgetTexts({
    required this.title,
    required this.empty,
    required this.allDone,
    required this.leftOf,
  });

  final String title;
  final String empty;
  final String allDone;

  /// "Còn N mục".
  final String Function(int n) leftOf;
}

/// Cổng tới widget Android; test dùng bản giả.
abstract class HomeWidgetGateway {
  Future<void> publish(String json);
}

class PluginHomeWidgetGateway implements HomeWidgetGateway {
  static const _channel = MethodChannel('dailyloop/system');

  @override
  Future<void> publish(String json) async {
    try {
      await _channel.invokeMethod<void>('updateWidget', json);
    } on MissingPluginException {
      // Máy không có widget (ví dụ khi chạy test): bỏ qua.
    }
  }
}

class FakeHomeWidgetGateway implements HomeWidgetGateway {
  String? last;
  int count = 0;

  @override
  Future<void> publish(String json) async {
    last = json;
    count++;
  }
}

/// Số ngày tính trước để widget tự sang ngày mới sau 00:00 kể cả khi app
/// không mở (AC-40, D-009).
const widgetDays = 7;

/// Dựng dữ liệu cho widget: danh sách các mục đến hạn của [widgetDays] ngày
/// kể từ hôm nay. [hideNames] bật khi có khóa PIN: chỉ hiện số mục còn lại
/// (AC-41).
Future<String> buildWidgetPayload(
  AppDatabase db, {
  required DateTime now,
  required HomeWidgetTexts texts,
  bool hideNames = false,
}) async {
  final today = dayOf(now);
  final repo = DayRepository(db);
  final days = <String, Object>{};
  for (var i = 0; i < widgetDays; i++) {
    final day = DateTime.utc(today.year, today.month, today.day + i);
    final items = await repo.loadDay(day, today: today);
    final left = items.where((x) => !x.settled).length;
    days[dateKey(day)] = {
      'summary': items.isEmpty
          ? texts.empty
          : left == 0
          ? texts.allDone
          : texts.leftOf(left),
      'items': hideNames
          ? const []
          : [
              for (final x in items)
                {
                  'id': x.activity.id,
                  'date': x.date,
                  'name': x.activity.name,
                  'done': x.achieved,
                  'skipped': x.skipped,
                  'task': x.isTask,
                  // Chỉ Có/Không và việc cần làm đánh xong ngay trên widget.
                  'tap': x.isTask || x.activity.evaluation == Evaluation.yesNo,
                },
            ],
    };
  }
  return jsonEncode({
    'title': texts.title,
    'empty': texts.empty,
    'allDone': texts.allDone,
    // Mẫu "Còn N mục" với N = -1; phía Android thay số khi đánh dấu xong.
    'leftTpl': texts.leftOf(-1),
    'days': days,
  });
}

/// Giữ widget khớp dữ liệu: cập nhật mỗi khi dữ liệu đổi, gộp trong 500 ms
/// (AC-40).
class HomeWidgetSync {
  HomeWidgetSync({
    required this.db,
    required this.gateway,
    required this.clock,
    required this.texts,
    this.hideNames = false,
  });

  final AppDatabase db;
  final HomeWidgetGateway gateway;
  final DateTime Function() clock;
  HomeWidgetTexts Function() texts;
  bool hideNames;

  StreamSubscription<void>? _sub;
  Timer? _debounce;

  void start() {
    _sub ??= db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            db.activities,
            db.schedules,
            db.entries,
            db.checklistMarks,
          ]),
        )
        .listen((_) => schedule());
  }

  void schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => syncNow());
  }

  Future<void> syncNow() async {
    final json = await buildWidgetPayload(
      db,
      now: clock(),
      texts: texts(),
      hideNames: hideNames,
    );
    await gateway.publish(json);
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    await _sub?.cancel();
  }
}
