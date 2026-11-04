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

  @override
  String get reminders => 'Giờ nhắc';

  @override
  String get addReminder => 'Thêm giờ nhắc';

  @override
  String get removeReminder => 'Bỏ giờ nhắc';

  @override
  String get reminderNotification => 'Thông báo';

  @override
  String get reminderAlarm => 'Chuông báo thức';

  @override
  String get channelReminders => 'Nhắc giờ';

  @override
  String get channelAlarms => 'Chuông báo thức';

  @override
  String get actionDone => 'Xong';

  @override
  String get actionSnooze => 'Hoãn 10 phút';

  @override
  String get actionDismiss => 'Tắt';

  @override
  String get allow => 'Cho phép';

  @override
  String get notNow => 'Để sau';

  @override
  String get openSettings => 'Mở cài đặt';

  @override
  String get permNotifTitle => 'Cho phép thông báo?';

  @override
  String get permNotifBody =>
      'DailyLoop chỉ dùng thông báo để nhắc bạn đúng giờ đã đặt. Không cho phép thì sẽ không có nhắc giờ, các phần khác của app vẫn dùng bình thường.';

  @override
  String get permExactTitle => 'Nhắc đúng giờ?';

  @override
  String get permExactBody =>
      'Để nhắc đúng từng phút, Android cần quyền \"Báo thức và lời nhắc\". Không có quyền này thì nhắc có thể trễ vài phút.';

  @override
  String get permFullTitle => 'Hiện chuông trên màn hình khóa?';

  @override
  String get permFullBody =>
      'Chuông báo thức có thể hiện toàn màn hình như đồng hồ báo thức. Không có quyền này thì chuông hiện dạng thông báo nổi.';

  @override
  String get warnNotifications => 'Thông báo đang tắt, nhắc giờ sẽ không hiện';

  @override
  String get warnExact => 'Nhắc có thể trễ vài phút';

  @override
  String get warnFullScreen => 'Chuông sẽ hiện dạng thông báo nổi';

  @override
  String get alarmFor => 'Tới giờ';

  @override
  String get stats => 'Thống kê';

  @override
  String get statsLast7 => '7 ngày gần nhất';

  @override
  String get statsLast30 => '30 ngày gần nhất';

  @override
  String get statsEmpty => 'Thêm thói quen hoặc việc để xem thống kê';

  @override
  String get statsTopStreaks => 'Chuỗi dài nhất';

  @override
  String get statsNoStreak => 'Chưa có chuỗi nào';

  @override
  String doneOfTotal(int done, int total) {
    return '$done trên $total xong';
  }

  @override
  String get streakCurrent => 'Chuỗi hiện tại';

  @override
  String get streakLongest => 'Chuỗi dài nhất';

  @override
  String streakDays(int count) {
    return '$count ngày';
  }

  @override
  String streakWeeks(int count) {
    return '$count tuần';
  }

  @override
  String streakMonths(int count) {
    return '$count tháng';
  }

  @override
  String get habitScore => 'Điểm';

  @override
  String get successRate => 'Tỉ lệ thành công';

  @override
  String get rate7 => '7 ngày';

  @override
  String get rate30 => '30 ngày';

  @override
  String get rateAll => 'Từ đầu';

  @override
  String get noRate => 'Chưa có';

  @override
  String get calendar => 'Lịch';

  @override
  String get prevMonth => 'Tháng trước';

  @override
  String get nextMonth => 'Tháng sau';

  @override
  String get dayNotDue => 'Không đến hạn';

  @override
  String get dayFuture => 'Sắp tới';

  @override
  String get dayPending => 'Hôm nay, chưa xong';

  @override
  String get chartByDay => 'Theo ngày';

  @override
  String get chartByWeek => 'Theo tuần';

  @override
  String get chartTable => 'Xem dạng bảng';

  @override
  String get tableDate => 'Ngày';

  @override
  String get tableValue => 'Giá trị';

  @override
  String get tableDone => 'Xong';

  @override
  String get tableTotal => 'Tổng';

  @override
  String chartSummary(int count, String max) {
    return 'Biểu đồ, $count cột, giá trị cao nhất $max';
  }

  @override
  String weekOf(String date) {
    return 'Tuần từ $date';
  }

  @override
  String get viewProgress => 'Xem tiến độ';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get pomodoroStart => 'Bắt đầu';

  @override
  String get pomodoroStop => 'Dừng';

  @override
  String get pomodoroNextPhase => 'Giai đoạn kế tiếp';

  @override
  String get pomodoroSkipBreak => 'Bỏ qua nghỉ';

  @override
  String get phaseFocus => 'Tập trung';

  @override
  String get phaseShortBreak => 'Nghỉ ngắn';

  @override
  String get phaseLongBreak => 'Nghỉ dài';

  @override
  String pomodoroSession(int n) {
    return 'Phiên $n';
  }

  @override
  String get pomodoroSettings => 'Thời gian (phút)';

  @override
  String get pomodoroFocus => 'Tập trung';

  @override
  String get pomodoroShortBreak => 'Nghỉ ngắn';

  @override
  String get pomodoroLongBreak => 'Nghỉ dài';

  @override
  String get pomodoroSessions => 'Số phiên trước nghỉ dài';

  @override
  String get pomodoroHabit => 'Cộng phút vào thói quen';

  @override
  String get pomodoroNoHabit => 'Không liên kết';

  @override
  String pomodoroCredited(int minutes) {
    return 'Đã cộng $minutes phút';
  }

  @override
  String get pomodoroDoneTitle => 'Hết giờ';

  @override
  String get pomodoroDoneBody => 'Giai đoạn đã kết thúc.';

  @override
  String get pomodoroFinished => 'Đã hết giờ';

  @override
  String get pomodoroStartTimer => 'Bấm giờ';

  @override
  String widgetLeft(int n) {
    return 'Còn $n mục';
  }

  @override
  String get widgetAllDone => 'Đã xong hết';

  @override
  String get dataSection => 'Dữ liệu';

  @override
  String get securitySection => 'Bảo mật';

  @override
  String get backupExport => 'Xuất bản sao lưu';

  @override
  String get backupExportHint =>
      'Tạo file .dailyloop để cất giữ hoặc chuyển sang máy khác';

  @override
  String get backupRestore => 'Khôi phục từ file';

  @override
  String get backupRestoreHint => 'Chọn file .dailyloop đã xuất trước đó';

  @override
  String get restore => 'Khôi phục';

  @override
  String get restoreConfirm =>
      'Dữ liệu hiện tại sẽ bị thay thế bằng nội dung của file sao lưu.';

  @override
  String get restoreDone => 'Đã khôi phục dữ liệu';

  @override
  String get restoreFailed =>
      'File sao lưu hỏng, sai định dạng hoặc do bản DailyLoop mới hơn tạo ra. Dữ liệu hiện tại được giữ nguyên.';

  @override
  String get exportFailed => 'Không xuất được file';

  @override
  String get csvExport => 'Xuất lịch sử ra CSV';

  @override
  String get csvExportHint => 'Mở được bằng Excel hoặc Google Sheets';

  @override
  String get csvHabit => 'Thói quen';

  @override
  String get csvTask => 'Việc';

  @override
  String get csvDone => 'Đạt';

  @override
  String get csvNotDone => 'Chưa đạt';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get pinLock => 'Khóa bằng mã PIN';

  @override
  String get pinLockHintOff => 'Đang tắt';

  @override
  String get pinLockHintOn => 'Đang bật';

  @override
  String get pinChange => 'Đổi mã PIN';

  @override
  String get pinDisable => 'Tắt khóa PIN';

  @override
  String get enterPin => 'Nhập mã PIN';

  @override
  String get enterCurrentPin => 'Nhập mã PIN hiện tại';

  @override
  String get wrongPin => 'Sai mã PIN';

  @override
  String get newPin => 'Đặt mã PIN 4 số';

  @override
  String get confirmPin => 'Nhập lại mã PIN';

  @override
  String get pinMismatch => 'Hai lần nhập không khớp';

  @override
  String get pinWarning =>
      'PIN chỉ ngăn người tò mò mở app, không mã hóa dữ liệu. Quên mã thì chỉ còn cách xóa toàn bộ dữ liệu để dùng lại.';

  @override
  String get forgotPin => 'Quên mã';

  @override
  String get forgotPinBody =>
      'Quên mã thì chỉ có thể xóa toàn bộ dữ liệu trên máy để dùng lại app. Dữ liệu đã xuất ra file sao lưu thì khôi phục lại được.';

  @override
  String digit(String d) {
    return 'Số $d';
  }

  @override
  String pinProgress(int n) {
    return 'Đã nhập $n trên 4 số';
  }

  @override
  String get keypadBackspace => 'Xóa số cuối';

  @override
  String get lockedOpenApp => 'Mở app (cần mã PIN)';

  @override
  String get deleteAll => 'Xóa toàn bộ dữ liệu';

  @override
  String get deleteAllHint =>
      'Xóa thói quen, việc, lịch sử, giờ nhắc, cài đặt và mã PIN';

  @override
  String get deleteAllConfirm =>
      'Toàn bộ thói quen, việc, lịch sử, giờ nhắc và cài đặt sẽ bị xóa khỏi máy này. Không hoàn tác được.';

  @override
  String get deleteAllConfirm2 =>
      'Chắc chắn xóa hết? Hãy xuất bản sao lưu trước nếu còn cần dữ liệu.';

  @override
  String get deleteAllDone => 'Đã xóa toàn bộ dữ liệu';
}
