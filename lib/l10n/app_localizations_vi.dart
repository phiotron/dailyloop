// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'DailyLoop';

  @override
  String get today => 'Hôm nay';

  @override
  String get emptyToday => 'Hôm nay chưa có việc nào';

  @override
  String get settings => 'Cài đặt';

  @override
  String get theme => 'Giao diện';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo máy';

  @override
  String get weekStart => 'Ngày đầu tuần';

  @override
  String get monday => 'Thứ Hai';

  @override
  String get sunday => 'Chủ Nhật';

  @override
  String get categoryHealth => 'Sức khỏe';

  @override
  String get categorySport => 'Thể thao';

  @override
  String get categoryStudy => 'Học tập';

  @override
  String get categoryWork => 'Công việc';

  @override
  String get categoryFinance => 'Tài chính';

  @override
  String get categoryHome => 'Nhà cửa';

  @override
  String get categoryMind => 'Tinh thần';

  @override
  String get categoryOther => 'Khác';

  @override
  String get habits => 'Thói quen';

  @override
  String get newHabit => 'Thói quen mới';

  @override
  String get editHabit => 'Sửa thói quen';

  @override
  String get emptyHabits =>
      'Chưa có thói quen nào. Bấm + để tạo thói quen đầu tiên.';

  @override
  String get emptyHabitsFiltered => 'Danh mục này chưa có thói quen';

  @override
  String get archived => 'Đã lưu trữ';

  @override
  String get emptyArchived => 'Chưa có thói quen nào được lưu trữ';

  @override
  String get allCategories => 'Tất cả';

  @override
  String get categories => 'Danh mục';

  @override
  String get noCategory => 'Không có danh mục';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get editCategory => 'Sửa danh mục';

  @override
  String get deleteCategory => 'Xóa danh mục';

  @override
  String get deleteCategoryConfirm => 'Xóa danh mục này?';

  @override
  String moveActivitiesTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mục đang dùng danh mục này. Chuyển sang:',
      zero: 'Không có mục nào dùng danh mục này.',
    );
    return '$_temp0';
  }

  @override
  String get icon => 'Biểu tượng';

  @override
  String get color => 'Màu';

  @override
  String get reorderHint => 'Kéo để sắp xếp';

  @override
  String get name => 'Tên';

  @override
  String get nameRequired => 'Nhập tên';

  @override
  String get nameTooLong => 'Tối đa 60 ký tự';

  @override
  String get description => 'Mô tả (không bắt buộc)';

  @override
  String get category => 'Danh mục';

  @override
  String get priority => 'Ưu tiên';

  @override
  String get priorityLow => 'Thấp';

  @override
  String get priorityNormal => 'Thường';

  @override
  String get priorityHigh => 'Cao';

  @override
  String get evaluation => 'Cách theo dõi';

  @override
  String get evalYesNo => 'Có hoặc không';

  @override
  String get evalQuantity => 'Số lượng';

  @override
  String get evalDuration => 'Thời gian';

  @override
  String get evalChecklist => 'Danh sách con';

  @override
  String get target => 'Mục tiêu';

  @override
  String get targetRequired => 'Nhập mục tiêu lớn hơn 0';

  @override
  String get unit => 'Đơn vị (ví dụ: ly)';

  @override
  String get minutes => 'phút';

  @override
  String get condAtLeast => 'Ít nhất';

  @override
  String get condExactly => 'Đúng bằng';

  @override
  String get condAtMost => 'Nhiều nhất';

  @override
  String get checklistItems => 'Các mục';

  @override
  String get addItem => 'Thêm mục';

  @override
  String itemTitle(int index) {
    return 'Mục $index';
  }

  @override
  String get removeItem => 'Bỏ mục';

  @override
  String get checklistRequired => 'Thêm 1 tới 20 mục, không để mục trống';

  @override
  String get checklistMinDone => 'Đạt khi xong ít nhất';

  @override
  String get checklistAll => 'tất cả các mục';

  @override
  String checklistAtLeast(int count) {
    return '$count mục';
  }

  @override
  String get repeat => 'Lặp lại';

  @override
  String get repeatDaily => 'Mỗi ngày';

  @override
  String get repeatWeekdays => 'Các thứ trong tuần';

  @override
  String get repeatMonthDays => 'Các ngày trong tháng';

  @override
  String get repeatEveryN => 'Cứ N ngày một lần';

  @override
  String get repeatTimesPerPeriod => 'Số lần mỗi tuần hoặc tháng';

  @override
  String get weekdaysRequired => 'Chọn ít nhất một thứ';

  @override
  String get monthDaysRequired => 'Chọn ít nhất một ngày';

  @override
  String get everyNLabel => 'Cứ mấy ngày một lần (2–365)';

  @override
  String get intervalInvalid => 'Nhập số từ 2 tới 365';

  @override
  String get timesLabel => 'Số lần';

  @override
  String get timesInvalid => 'Tối đa 7 lần mỗi tuần hoặc 31 lần mỗi tháng';

  @override
  String get perWeek => 'mỗi tuần';

  @override
  String get perMonth => 'mỗi tháng';

  @override
  String get startDate => 'Ngày bắt đầu';

  @override
  String get endDate => 'Ngày kết thúc';

  @override
  String get noEndDate => 'Không có ngày kết thúc';

  @override
  String get endDateInvalid => 'Ngày kết thúc trước ngày bắt đầu';

  @override
  String get clear => 'Bỏ';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get archive => 'Lưu trữ';

  @override
  String get unarchive => 'Khôi phục';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get deleted => 'Đã xóa';

  @override
  String get archivedMessage => 'Đã lưu trữ';

  @override
  String get deleteHabitConfirm => 'Xóa thói quen này cùng toàn bộ lịch sử?';

  @override
  String get scheduleDaily => 'Mỗi ngày';

  @override
  String scheduleEveryN(int n) {
    return 'Cứ $n ngày một lần';
  }

  @override
  String scheduleTimesWeek(int k) {
    return '$k lần mỗi tuần';
  }

  @override
  String scheduleTimesMonth(int k) {
    return '$k lần mỗi tháng';
  }

  @override
  String scheduleMonthDays(String days) {
    return 'Ngày $days hằng tháng';
  }

  @override
  String get scheduleOnce => 'Một lần';

  @override
  String get tasks => 'Việc';

  @override
  String get newTask => 'Việc mới';

  @override
  String get editTask => 'Sửa việc';

  @override
  String get deleteTaskConfirm => 'Xóa việc này?';

  @override
  String get subtasks => 'Việc con (không bắt buộc)';

  @override
  String get repeatNone => 'Không lặp lại';

  @override
  String get taskDate => 'Ngày';

  @override
  String get taskTime => 'Giờ';

  @override
  String get noTime => 'Không đặt giờ';

  @override
  String get unscheduled => 'Chưa xếp lịch';

  @override
  String get startDateRequired => 'Chọn ngày bắt đầu';

  @override
  String get createNew => 'Tạo mới';

  @override
  String get addHabit => 'Thêm thói quen';

  @override
  String get addTask => 'Thêm việc';

  @override
  String get backToToday => 'Về hôm nay';

  @override
  String get pickDay => 'Chọn ngày';

  @override
  String overdueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quá hạn · $count ngày',
    );
    return '$_temp0';
  }

  @override
  String get skipToday => 'Bỏ qua ngày này';

  @override
  String get unskip => 'Bỏ dấu bỏ qua';

  @override
  String get skipped => 'Đã bỏ qua';

  @override
  String get achieved => 'Đạt';

  @override
  String get notAchieved => 'Chưa đạt';

  @override
  String get edit => 'Sửa';

  @override
  String get futureDay => 'Chỉ ghi được kết quả tới hôm nay';

  @override
  String get addOne => 'Thêm 1';

  @override
  String get recordValue => 'Ghi kết quả';

  @override
  String progress(String value, String target) {
    return '$value trên $target';
  }

  @override
  String itemsDone(int done, int total) {
    return '$done trên $total mục';
  }

  @override
  String get filterToday => 'Hôm nay';

  @override
  String get filterUpcoming => 'Sắp tới';

  @override
  String get filterOverdue => 'Quá hạn';

  @override
  String get filterUnscheduled => 'Chưa xếp lịch';

  @override
  String get filterDone => 'Đã xong';

  @override
  String get emptyTasks => 'Không có việc nào';

  @override
  String get welcomeTitle1 => 'Xây thói quen bền vững';

  @override
  String get welcomeBody1 =>
      'Theo dõi thói quen kiểu có hoặc không, số lượng, thời gian hay danh sách con, vào đúng những ngày bạn chọn.';

  @override
  String get welcomeTitle2 => 'Sắp xếp ngày của bạn';

  @override
  String get welcomeBody2 =>
      'Thói quen và việc cần làm trong ngày nằm chung ở màn Hôm nay.';

  @override
  String get welcomeTitle3 => 'Dữ liệu ở lại trên máy';

  @override
  String get welcomeBody3 =>
      'Không cần tài khoản, không cần mạng. Bạn tự xuất file sao lưu khi muốn.';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get next => 'Tiếp';

  @override
  String get getStarted => 'Bắt đầu';
}
