# DECISIONS — Nhật ký quyết định kiến trúc

Mỗi quyết định một mục, mới nhất ở trên cùng.

## D-009 · Pomodoro tính theo mốc thời gian đã lưu; widget không dùng gói ngoài · 2026-11-04
- Bối cảnh: G6, SPEC F-09 (AC-35 tới AC-38) và F-10 (AC-39, AC-40).
- Quyết định:
  - **Pomodoro**: cấu hình và lần chạy lưu trong bảng `settings` (khóa `pomodoroConfig`, `pomodoroRun`, JSON; dữ liệu hỏng thì dùng mặc định hoặc coi như không chạy). Thời gian còn lại = giờ kết thúc (mốc bắt đầu + thời lượng) trừ giờ máy, kẹp trong [0, thời lượng]; bộ hẹn giờ trên màn hình chỉ để vẽ lại mỗi giây. Hết giờ báo bằng thông báo hẹn giờ của hệ thống (mã 0x3FFFFFFF, không đụng lịch nhắc), không có dịch vụ chạy nền.
  - **Cộng phút**: chỉ phiên tập trung có liên kết thói quen kiểu Thời gian. Dừng giữa chừng: cộng số phút đã chạy làm tròn tới phút gần nhất, vào ngày lúc dừng. Hết giờ: cộng đủ, đúng một lần (cờ `credited`), vào ngày giờ kết thúc, kể cả khi app đóng và mở lại sau đó (`settleIfFinished` chạy khi mở app và khi quay lại app). Nghỉ không cộng gì. Nghỉ dài sau phiên thứ N (mặc định 4).
  - **Widget**: KHÔNG dùng gói home_widget (thêm phụ thuộc, thêm mục SBOM). Dart dựng bản chụp 7 ngày tới (mục, trạng thái xong, chữ theo ngôn ngữ) và gửi qua kênh `dailyloop/system` (`updateWidget`) vào SharedPreferences; Kotlin vẽ widget bằng RemoteViews và tự chọn ngày theo giờ máy, nên sang ngày mới kể cả khi app đóng; hẹn báo thức không chính xác lúc 00:01 để vẽ lại (AC-40). Chạm ô đánh dấu của mục Có/Không hoặc việc: hoạt động trong suốt `WidgetActionActivity` ghi thẳng vào SQLite (bảng `entries`, thư mục app_flutter) rồi vẽ lại, không mở app. Chạm tên: mở app tại `/habits/ID` hoặc `/tasks/ID`. Khi bật PIN (G7) bản chụp không có tên, chỉ có số mục còn lại (AC-41, tham số `hideNames` đã có).
- Lý do / phương án đã loại: `home_widget` (loại: thêm gói bên thứ ba cho việc 4 file Kotlin làm được). Dịch vụ nền cho bộ đếm (loại: tốn pin, phải khai báo với Google Play). Tính lại danh sách đến hạn bằng Kotlin (loại: phải viết lại logic lịch lặp lần hai; bản chụp 7 ngày đủ cho nửa đêm).
- Hệ quả cần nhớ: Ghi từ widget khi app đang mở: giao diện cập nhật ở lần quay lại app kế tiếp (đã làm mới khi resume). Widget cũ hơn 7 ngày mà chưa mở app thì trống tới lần mở app. Tên file cơ sở dữ liệu `dailyloop.sqlite` và tên bảng `entries` được Kotlin dùng trực tiếp: đổi chúng phải sửa `WidgetStore.kt`.

## D-008 · Chuỗi ngày, tỉ lệ, điểm tính từ "đơn vị", biểu đồ tự vẽ · 2026-11-04
- Bối cảnh: G5, SPEC F-05 (AC-23 tới AC-25) và F-06 (AC-26 tới AC-29).
- Quyết định:
  - **Đơn vị tính**: mỗi ngày đến hạn là một đơn vị. Thói quen kiểu "K lần mỗi tuần/tháng" thì mỗi tuần (bắt đầu theo cài đặt) hoặc mỗi tháng là một đơn vị, chỉ ngày có ghi mới tính, đủ K là đạt. Kết quả đơn vị: đạt, bỏ lỡ, bỏ qua, chưa xong (hôm nay hoặc kỳ chưa kết thúc).
  - **Chuỗi**: đạt thì +1, bỏ lỡ thì về 0, bỏ qua và chưa xong thì giữ nguyên. Chuỗi hiện tại là chuỗi tại đơn vị mới nhất; chuỗi dài nhất là lớn nhất từ trước tới nay. Ngày không đến hạn không phải đơn vị nên không ảnh hưởng.
  - **Tỉ lệ thành công** (7 ngày, 30 ngày, từ đầu): số đơn vị đạt chia số đơn vị đạt cộng bỏ lỡ, trong các đơn vị kết thúc trong khoảng đó; null (hiện "Chưa có") nếu chưa có đơn vị nào. Với "K lần": theo tuần hoặc tháng chứ không theo ngày.
  - **Điểm 0–100**: lấy tối đa 60 đơn vị gần nhất (chỉ đạt và bỏ lỡ), đơn vị thứ i tính từ mới nhất có trọng số 0,95^i; điểm = 100 × tổng trọng số của đơn vị đạt / tổng trọng số, làm tròn. Chưa có đơn vị nào thì 0. Ví dụ kiểm bằng tay: bỏ lỡ 3 ngày rồi đạt 3 ngày gần nhất cho 54; đạt 3 ngày rồi bỏ lỡ 3 ngày gần nhất cho 46.
  - **Kỳ đầu bắt đầu giữa tuần/tháng** (kiểu "K lần") mà không đủ K thì không tính là bỏ lỡ.
  - **Ngày chưa ghi** tính là giá trị 0 như màn Hôm nay, nên mục tiêu "nhiều nhất" mà chưa ghi gì thì đạt.
  - **Màn Thống kê chung**: mỗi ngày đếm các mục đến hạn (thói quen và việc, kể cả kiểu "K lần" vì chúng hiện hằng ngày ở màn Hôm nay); mục bỏ qua không vào tổng. Việc quá hạn tính ở ngày gốc của nó. Top 3 theo chuỗi dài nhất, hòa thì theo điểm, rồi theo thứ tự người dùng xếp.
  - **Biểu đồ cột tự vẽ** bằng `CustomPaint`, không thêm thư viện. Chữ (nhãn đầu, cuối, giá trị lớn nhất) và bảng thay thế mở được ("Xem dạng bảng") là widget thường, để co theo cỡ chữ hệ thống và TalkBack đọc được (AC-29, AC-50). Mỗi ô lịch có cả màu lẫn biểu tượng nhỏ.
  - Chạm một thói quen ở danh sách mở màn tiến độ; màn sửa mở từ nút "Sửa" ở đó hoặc từ menu ở màn Hôm nay.
- Lý do / phương án đã loại: `fl_chart` (loại: thêm một thư viện cho hai loại biểu đồ đơn giản, khó kiểm soát nhãn cho trình đọc màn hình). Lưu chuỗi và điểm vào cơ sở dữ liệu (loại: dữ liệu suy ra được, lưu thêm dễ lệch khi sửa lịch sử). Tính trong SQL (loại: lịch lặp nhiều kiểu, cần logic Dart đã có).
- Hệ quả cần nhớ:
  - Thống kê tính lại từ toàn bộ lịch sử mỗi lần dữ liệu đổi. Đo trên máy phát triển: 50 thói quen × 3 năm hết khoảng 0,4 giây; CHƯA đo trên điện thoại (ngưỡng SPEC mục 5b là 1 giây).
  - Đổi mục tiêu của một thói quen thì kết quả các ngày cũ tính lại theo mục tiêu mới (D-005).
  - Truy vấn mục con đã đánh dấu dùng phép nối bảng, không dùng `IN (...)` với danh sách mã (vượt giới hạn biến của SQLite khi lịch sử dài; lỗi tìm ra bằng test hiệu năng).

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

## D-001 · Stack: Flutter, Android + iOS · 2026-11-03 (sửa 2026-11-04)
- Bối cảnh: SPEC cần nhắc giờ chính xác, chuông báo thức toàn màn hình, widget màn hình chính, đồng hồ Pomodoro, chạy offline hoàn toàn. Người dùng chọn Flutter.
- Quyết định: Flutter. ~~v1 chỉ Android~~ → **2026-11-04: thêm iOS vào bản 1** (build/ký/test trên GitHub Actions macOS runner; không có iPhone → thử trên simulator CI). Widget iOS bằng WidgetKit; kiểu "Chuông" trên iOS = thông báo time-sensitive (D-010). Code giữ khả năng thêm iOS sau. Dự kiến ghim Flutter 3.47.8 như APP-001 (`C:/src/flutter`), xác nhận ở G1. Các thư viện (quản lý trạng thái, cơ sở dữ liệu, thông báo, widget) chọn ở G1 và G4, mỗi cái ghi một D-xxx.
- Lý do / phương án đã loại: Expo/React Native (loại: chưa app nào trong kho dùng; báo thức chính xác, màn hình toàn màn hình và widget đều cần module native và development build, không chạy bằng Expo Go). Flutter thì đã có máy, có CI mẫu và kinh nghiệm thử máy thật từ APP-001 (L-011). Bản iOS ở v1 (loại: cần máy Mac và tài khoản Apple, nhắc giờ trên iOS có giới hạn riêng).
- Hệ quả cần nhớ: Widget và chuông báo thức cần thêm mã Kotlin trong `android/`. Không import code từ APP-001; nếu cần dùng chung thì chép sang và ghi lại, hoặc đề xuất đưa vào `shared/`.
