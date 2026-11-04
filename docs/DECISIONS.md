# DECISIONS — Nhật ký quyết định kiến trúc

Mỗi quyết định một mục, mới nhất ở trên cùng.

## D-007 · Nhắc giờ: flutter_local_notifications, SCHEDULE_EXACT_ALARM do người dùng cấp, lịch lăn 7 ngày · 2026-11-03
- Bối cảnh: SPEC F-04 (AC-17 tới AC-22). Đã tra ngày 2026-11-03:
  - Tài liệu Android (developer.android.com/about/versions/14/changes/schedule-exact-alarms): từ Android 14, `SCHEDULE_EXACT_ALARM` bị tắt sẵn với app mới cài, người dùng phải tự bật trong "Báo thức và lời nhắc". `USE_EXACT_ALARM` chỉ dành cho app báo thức hoặc lịch.
  - Chính sách Google Play (support.google.com/googleplay/android-developer/answer/13986130): app không phải báo thức hoặc lịch mà khai `USE_EXACT_ALARM` thì bị chặn phát hành. `USE_FULL_SCREEN_INTENT` chỉ tự cấp cho app báo thức hoặc gọi điện, app khác phải xin người dùng, và nên nộp khai báo trong Play Console.
  - Tài liệu AOSP (source.android.com/docs/core/permissions/fsi-limits): không được cấp quyền toàn màn hình thì hiện thông báo nổi khoảng 60 giây.
- Quyết định:
  - Dùng `flutter_local_notifications` 22 cùng `timezone` và `flutter_timezone`.
  - Khai `SCHEDULE_EXACT_ALARM` (KHÔNG khai `USE_EXACT_ALARM`), `USE_FULL_SCREEN_INTENT`, `RECEIVE_BOOT_COMPLETED`; `POST_NOTIFICATIONS` và `VIBRATE` do thư viện khai.
  - Có quyền báo thức chính xác thì nhắc đúng giờ (`exactAllowWhileIdle`, chuông dùng `alarmClock`). Không có thì vẫn nhắc nhưng có thể trễ (`inexactAllowWhileIdle`), và app hiện cảnh báo.
  - Chuông: kênh riêng mức cao nhất, `fullScreenIntent`, âm thanh loại báo thức lặp lại (`FLAG_INSISTENT`), tự tắt sau 5 phút (`timeoutAfter`), có nút Xong, Hoãn 10 phút, Tắt.
  - Lập lịch kiểu "lăn": mỗi lần mở app, quay lại app hoặc dữ liệu đổi thì tính các lần nhắc trong 7 ngày tới (tối đa 100 lần, vì Samsung giới hạn 500 báo thức mỗi app), hủy lịch cũ rồi đặt lại. Mục đã xong hoặc bỏ qua trong ngày thì không nhắc nữa.
  - Nút "Xong" trên thông báo chạy ở tiến trình nền, mở cơ sở dữ liệu và ghi kết quả, không mở app. Khi app đang mở thì dùng chung kết nối cơ sở dữ liệu của app.
  - Lần hoãn (mã thông báo đánh dấu bằng bit 30) được giữ qua các lần đặt lại lịch, nhưng bị hủy nếu mục đã xóa hoặc đã xong. Thử máy thật 2026-11-04: lịch đăng ký đúng, thông báo lệch 0,1 giây, nút Xong chạy khi app đóng, chuông toàn màn hình hiện khi màn hình tắt.
  - Một kênh nhỏ viết bằng Kotlin (`dailyloop/system`) để kiểm quyền toàn màn hình và mở cài đặt thông báo của app.
- Lý do / phương án đã loại: `USE_EXACT_ALARM` (loại: trái chính sách Google Play với app thói quen). Lặp lại bằng `matchDateTimeComponents` (loại: không biểu diễn được "cứ N ngày", "ngày 31", ngày kết thúc, và không bỏ được lần nhắc khi đã xong). Dịch vụ chạy nền liên tục (loại: tốn pin, phải khai báo foreground service).
- Hệ quả cần nhớ:
  - Khởi động lại máy: thư viện tự đặt lại các lần nhắc đã lưu.
  - Đổi giờ hoặc múi giờ khi app đang tắt: các lần nhắc giữ giờ tuyệt đối cũ cho tới lần mở app kế tiếp. AC-21 chỉ đạt một phần, ghi ở BACKLOG.
  - Không mở app quá 7 ngày thì hết lịch nhắc.
  - Trình tối ưu pin của từng hãng vẫn có thể làm trễ.
  - Khi phát hành phải nộp khai báo full-screen intent trong Play Console và khai trong Data safety rằng không có dữ liệu nào rời máy.

## D-006 · Việc cần làm ghi kết quả vào ngày của việc; một màn soạn cho cả thói quen và việc · 2026-11-03
- Bối cảnh: G3, SPEC F-03 (AC-13 tới AC-16) và F-02 (AC-07 tới AC-12).
- Quyết định: Việc một lần là mục `kind = task` có lịch `once`, ngày của việc ở `startDate` (null là "Chưa xếp lịch"). Xong việc thì ghi `entries` với `value = 1` vào chính ngày của việc, kể cả khi đánh xong lúc đã quá hạn. Việc chưa xếp lịch ghi vào ngày đánh xong. Việc lặp lại dùng chung bảng lịch với thói quen. Việc con lưu ở `checklist_items`, chỉ để đánh dấu, không quyết định xong hay chưa. Màn Hôm nay và màn Việc đọc qua `DayRepository`, phát lại mỗi khi các bảng liên quan đổi (`tableUpdates`). Màn soạn thói quen dùng chung cho việc (tham số `kind`): ẩn phần "Cách theo dõi", thêm "Không lặp lại", ngày bỏ trống được, có giờ.
- Lý do / phương án đã loại: Cột `completedAt` riêng cho việc (loại: phải xử lý việc lặp lại theo cách khác, sao lưu thêm một kiểu dữ liệu). Hai màn soạn riêng (loại: lặp gần hết phần tên, danh mục, ưu tiên, lịch lặp).
- Hệ quả cần nhớ: Đổi ngày của việc đã xong thì kết quả cũ ở ngày cũ không đi theo, việc thành chưa xong ở ngày mới. "Hôm nay" được đọc khi mở màn hình, nên app mở qua nửa đêm sẽ không tự sang ngày mới (BUG-001).

## D-005 · Mô hình dữ liệu: thói quen và việc chung một bảng, lịch lặp có ngày hiệu lực · 2026-11-03
- Bối cảnh: Màn Hôm nay (AC-07), giờ nhắc (AC-17), sao lưu (AC-43) đều xử lý thói quen và việc như nhau. AC-04 đòi đổi lịch lặp chỉ ảnh hưởng từ hôm nay. AC-12 đòi kết quả lưu ngay.
- Quyết định: Bảng `activities` chứa cả thói quen và việc (cột `kind`). Lịch lặp nằm ở bảng `schedules`, mỗi dòng có `effectiveFrom`. Đổi lịch thì thêm dòng mới từ hôm nay, giữ dòng cũ cho các ngày trước. Kết quả theo ngày ở bảng `entries` (mỗi mục mỗi ngày tối đa một dòng): `value` là số thực (lần, ly, km; kiểu Thời gian tính bằng phút; Có/Không là 1), `skipped` đánh dấu bỏ qua. Mục con đã xong ở bảng `checklist_marks`. Ngày lưu chữ `YYYY-MM-DD` theo giờ địa phương, giờ nhắc lưu số phút từ 00:00. Cài đặt lưu bảng khóa-giá trị trong cùng SQLite, để một file sao lưu chứa đủ. Danh mục mặc định có `nameKey` để hiện theo ngôn ngữ máy.
- Lý do / phương án đã loại: Hai bảng riêng cho thói quen và việc (loại: phải ghép ở màn Hôm nay, giờ nhắc, sao lưu). Lưu lịch lặp ngay trong `activities` (loại: không giữ được lịch cũ cho ngày đã qua, sai AC-04). Lưu ngày bằng timestamp (loại: đổi múi giờ làm kết quả nhảy sang ngày khác).
- Hệ quả cần nhớ: Trạng thái "đạt" không lưu mà tính từ `value` và điều kiện của mục, nên sửa mục tiêu thì kết quả ngày cũ tính lại theo mục tiêu mới. G2 cân nhắc giữ mục tiêu theo `schedules` nếu cần. Mọi đổi schema phải tăng `schemaVersion` và viết migration kèm test.

## D-004 · SQLite qua drift, file sinh tự động được commit · 2026-11-03
- Bối cảnh: Cần lưu offline, có giao dịch (AC-12, SPEC 5b), migration và test không cần máy thật. APP-001 đã dùng cách này ổn định qua 5 giai đoạn.
- Quyết định: `drift` + `drift_flutter`. Sinh mã bằng `dart run build_runner build`. File `*.g.dart` được COMMIT để clone về là chạy được `flutter analyze` và `flutter test` ngay.
- Lý do / phương án đã loại: `sqflite` (loại: SQL viết tay, không kiểm kiểu). Hive/Isar (loại: thống kê theo khoảng ngày cần truy vấn SQL; Isar ít được bảo trì).
- Hệ quả cần nhớ: Sửa bảng xong phải chạy lại build_runner rồi mới analyze/test. Test dùng cơ sở dữ liệu trong bộ nhớ (`NativeDatabase.memory()`). Widget chạy ở tiến trình Android (G6) sẽ cần đọc cùng dữ liệu: quyết ở G6 là đọc qua Flutter hay qua bản tóm tắt ghi riêng.

## D-003 · Phiên bản Flutter, quản lý trạng thái, điều hướng, đa ngôn ngữ · 2026-11-03
- Bối cảnh: G1 khởi tạo dự án. Flutter 3.47.8 có sẵn ở `C:/src/flutter` (chưa có trong PATH), giống APP-001.
- Quyết định: Ghim Flutter 3.47.8. Không dùng FVM, vì hai app đang dùng cùng một phiên bản. Trạng thái: `flutter_riverpod` 3. Điều hướng: `go_router`. Đa ngôn ngữ: `flutter_localizations` + `gen-l10n` với file `.arb` (vi, en). Chỉ tạo nền tảng Android. Tên gói `com.phiotron.dailyloop` (người dùng chọn). Đặt `kotlin.incremental=false` ngay từ đầu, vì APP-001 đã gặp lỗi build release khi dự án ở ổ D: còn pub cache ở ổ C:.
- Lý do / phương án đã loại: Provider (loại: Riverpod test được mà không cần widget). Bloc (loại: nhiều mã mẫu). Navigator 1.0 (loại: go_router dễ mở thẳng một mục từ thông báo hoặc widget ở G4 và G6).
- Hệ quả cần nhớ: Không trộn cách quản lý trạng thái khác. Không import code từ APP-001, chỉ viết lại theo cùng mẫu.

## D-002 · Chỉ lưu trên máy, không máy chủ, không SDK bên thứ ba · 2026-11-03
- Bối cảnh: App miễn phí, bán ở Việt Nam và toàn cầu. Tên thói quen có thể lộ thông tin sức khỏe. Người dùng chọn "Miễn phí hoàn toàn".
- Quyết định: Dữ liệu chỉ nằm trong SQLite trên máy. Không tài khoản, không máy chủ, không analytics, không quảng cáo, không SDK báo crash. Bản release không có quyền INTERNET. Sao lưu bằng file người dùng tự xuất. Theo dõi crash qua Android vitals của Play Console.
- Lý do / phương án đã loại: Sao lưu đám mây kèm đăng nhập Google như HabitNow Premium (loại ở v1: cần đăng nhập và nhà cung cấp lưu trữ, kéo theo D-05, D-10, chuyển dữ liệu xuyên biên giới). Firebase Crashlytics (loại: gửi dữ liệu ra ngoài, phải xin đồng ý ở EU và khai Data safety).
- Hệ quả cần nhớ: Mất máy mà chưa xuất file là mất dữ liệu. Thêm bất kỳ tính năng gọi mạng nào sau này phải mở lại COMPLIANCE.

## D-001 · Stack: Flutter, v1 chỉ Android · 2026-11-03
- Bối cảnh: SPEC cần nhắc giờ chính xác, chuông báo thức toàn màn hình, widget màn hình chính, đồng hồ Pomodoro, chạy offline hoàn toàn. Người dùng chọn Flutter.
- Quyết định: Flutter. v1 chỉ build và phát hành Android. Code giữ khả năng thêm iOS sau. Dự kiến ghim Flutter 3.47.8 như APP-001 (`C:/src/flutter`), xác nhận ở G1. Các thư viện (quản lý trạng thái, cơ sở dữ liệu, thông báo, widget) chọn ở G1 và G4, mỗi cái ghi một D-xxx.
- Lý do / phương án đã loại: Expo/React Native (loại: chưa app nào trong kho dùng; báo thức chính xác, màn hình toàn màn hình và widget đều cần module native và development build, không chạy bằng Expo Go). Flutter thì đã có máy, có CI mẫu và kinh nghiệm thử máy thật từ APP-001 (L-011). Bản iOS ở v1 (loại: cần máy Mac và tài khoản Apple, nhắc giờ trên iOS có giới hạn riêng).
- Hệ quả cần nhớ: Widget và chuông báo thức cần thêm mã Kotlin trong `android/`. Không import code từ APP-001; nếu cần dùng chung thì chép sang và ghi lại, hoặc đề xuất đưa vào `shared/`.
