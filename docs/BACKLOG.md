# BACKLOG — DailyLoop (APP-002)

Nguồn sự thật về việc cần làm. Claude đọc đầu phiên, cập nhật cuối phiên (`/end`). Việc chưa xong ghi dạng "[ ] ..." đầu dòng sau dấu gạch; xong đổi thành "[x]". `scripts/status.sh` đếm các việc chưa xong.

## Giai đoạn xây dựng
Mỗi giai đoạn kết thúc bằng: `flutter analyze` sạch, `flutter test` đạt, thử trên máy Android thật và ghi biên bản (L-003), rồi dừng ở cổng chờ người dùng.

### G1 · Khởi tạo dự án và nền dữ liệu — trạng thái: done (chờ người dùng thử tay và duyệt)
- [x] Flutter 3.47.8 ở C:/src/flutter (`flutter --version`; chưa chạy `flutter doctor`, nhưng build release đạt). Tên gói `com.phiotron.dailyloop` (người dùng chọn)
- [x] `flutter create` chỉ Android ở thư mục tạm rồi chép vào, không ghi đè tài liệu; mục "Lệnh" trong CLAUDE.md điền bằng lệnh đã chạy (L-009)
- [x] Chọn thư viện, ghi D-003, D-004, D-005 (Riverpod, go_router, drift, gen-l10n)
- [x] Lớp dữ liệu: bảng danh mục, mục (thói quen/việc), lịch lặp có ngày hiệu lực, mục con, kết quả theo ngày, giờ nhắc, cài đặt. Có ràng buộc: một kết quả mỗi mục mỗi ngày, giá trị ≥ 0, giờ nhắc 0–1439, xóa theo dây chuyền: test `database_test`. Ghi trong giao dịch (AC-12) làm cùng kho dữ liệu ở G2–G3
- [x] Danh mục mặc định theo ngôn ngữ máy (AC-30): test `database_test`
- [x] Khung vi/en, giao diện sáng/tối/theo hệ thống, ngày đầu tuần, không tràn ở cỡ chữ 200% (AC-48, một phần AC-50): test `app_test`
- [x] `allowBackup=false`, chỉ màn hình dọc, APK release không có INTERNET (AC-53): kiểm bằng `aapt2 dump` ngày 2026-11-03, chỉ có quyền `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` do AndroidX tự thêm; minSdk 24, targetSdk 36
- [ ] Thử máy thật: mở app, đổi giao diện, đổi ngôn ngữ, nút Back, xoay máy. Chờ người dùng (máy đang bận); chỉ dùng điện thoại khi người dùng cho phép
- [x] CI `.github/workflows/ci.yml` đã chạy trên GitHub Actions ngày 2026-11-04 cho commit a368887 (`flutter analyze` và `flutter test`, Flutter 3.47.8): đạt, 2 phút 52 giây

### G2 · Thói quen và lịch lặp — trạng thái: done (chờ người dùng duyệt)
- [x] Hàm tính ngày đến hạn `DueCalculator` cho mọi kiểu lịch lặp, kể cả năm nhuận, ngày 31, N ngày, K lần/tuần, ngày kết thúc, đổi lịch giữa chừng (AC-03, AC-04): test `schedule_test`
- [x] Hàm "đạt mục tiêu" cho 4 kiểu đánh giá (AC-02; dùng ở G3 cho AC-09): test `schedule_test`
- [x] Tạo, sửa, lưu trữ/khôi phục, xóa có hoàn tác 5 giây, kéo sắp xếp thói quen; kiểm nhập liệu: tên, mô tả, mục tiêu, mục con, lịch, ngày (AC-01, AC-02, AC-04 tới AC-06): test `activity_repository_test`, `habits_flow_test`
- [x] Quản lý danh mục (thêm, sửa tên/icon/màu, xóa có chuyển mục) và lọc theo danh mục (AC-31, AC-32): test `activity_repository_test`, `habits_flow_test`
- [x] Màn soạn tự cuộn tới dòng báo lỗi bị khuất (lỗi tìm ra khi viết test); không tràn ở cỡ chữ 200%: test `habits_flow_test`
- [x] Làm sớm một phần AC-33: thanh điều hướng dưới có Hôm nay và Thói quen (Việc thêm ở G3, Thống kê ở G5)
- [x] Thử máy thật (biên bản bên dưới): tạo, báo lỗi, sửa lịch, xóa và hoàn tác
- [ ] CHƯA thử trên máy thật: lưu trữ/khôi phục, kéo sắp xếp, màn Danh mục, chọn ngày, cỡ chữ lớn, TalkBack

### G3 · Màn Hôm nay và việc cần làm — trạng thái: done (chờ thử máy thật và người dùng duyệt)
- [x] Màn Hôm nay: dải 7 ngày, chọn ngày bằng lịch, nút về hôm nay; sắp theo giờ rồi ưu tiên, mục xong xuống dưới (AC-07, AC-08): test `day_repository_test`, `today_flow_test`
- [x] Ghi kết quả: Có/Không một chạm, Số lượng có +1 và nhập số, Thời gian nhập phút, Danh sách con đánh từng mục; bỏ qua ngày này; ngày tương lai chỉ xem; lưu ngay trong giao dịch (AC-09, AC-10, AC-12): test `day_repository_test`, `today_flow_test`
- [x] Trạng thái trống có nút Thêm thói quen, Thêm việc (AC-11): test `today_flow_test`
- [x] Việc một lần (ngày, giờ, việc con, không bắt buộc ngày), việc lặp, quá hạn ở đầu màn Hôm nay, màn Việc với 5 bộ lọc (AC-13 tới AC-16): test `day_repository_test`, `today_flow_test`. Màn soạn thói quen dùng chung cho việc
- [x] Thanh điều hướng dưới 3 tab (Thống kê thêm ở G5), nút "+" chọn Thói quen mới hoặc Việc mới, màn chào 3 trang bỏ qua được (AC-33, AC-34): test `today_flow_test`
- [x] Lỗi tìm ra khi chạy test: các nút + ở nhiều tab trùng hiệu ứng hero làm hỏng khi mở màn mới; đã tắt hero cho nút +
- [x] Build APK release đạt (61,4 MB), vẫn không có quyền INTERNET (AC-53): `aapt2 dump permissions` 2026-11-03
- [x] Thử máy thật (biên bản bên dưới): màn chào, chấm Có/Không, ngày tương lai bị chặn, nút +, tạo việc có giờ, màn Việc
- [x] Lỗi tìm ra trên máy thật: đóng hộp chọn giờ thì con trỏ quay lại ô Tên và bàn phím bật lên; đã sửa (bỏ con trỏ trước khi mở hộp chọn ngày/giờ), thử lại trên máy đạt
- [ ] CHƯA thử trên máy: Số lượng / Thời gian / Danh sách con ở màn Hôm nay, bỏ qua ngày này, việc quá hạn, các bộ lọc khác của màn Việc, cỡ chữ lớn, TalkBack
- [ ] Lỗi đã biết BUG-001 (bên dưới)

### G4 · Nhắc giờ và chuông báo thức — trạng thái: code xong, test tự động đạt, đã thử một phần trên Galaxy A13 (biên bản bên dưới)
- [x] Đã tra chính sách Google Play và tài liệu Android (nguồn và ngày tra trong D-007): không khai `USE_EXACT_ALARM` (chỉ cho app báo thức hoặc lịch); khai `SCHEDULE_EXACT_ALARM` để người dùng tự cấp; `USE_FULL_SCREEN_INTENT` phải xin người dùng và nên khai trong Play Console. Chọn `flutter_local_notifications` (D-007)
- [x] Mỗi mục có 0 tới 5 giờ nhắc, mỗi giờ chọn Thông báo hoặc Chuông; lập lịch lăn 7 ngày, chỉ vào ngày đến hạn, bỏ lần đã qua giờ, bỏ lần của mục đã xong hoặc bỏ qua trong ngày, tối đa 100 lần (AC-17, AC-22): test `reminder_planner_test`
- [x] Xin quyền đúng lúc: giải thích rồi mới xin thông báo, báo thức chính xác; chọn chuông thì xin thêm toàn màn hình; từ chối thì vẫn lưu giờ nhắc, hiện cảnh báo và nút "Mở cài đặt" (AC-18): test `reminders_flow_test`
- [x] Thông báo có nút "Xong" chạy được cả khi app đóng, màn chuông toàn màn hình với Xong, Hoãn 10 phút, Tắt, chuông tự tắt sau 5 phút, đặt lại lịch khi mở app, quay lại app và khi dữ liệu đổi (AC-19, AC-20, AC-21). Phần gọi thẳng Android test tự động không phủ được; đã thử trên máy thật một phần, xem biên bản
- [x] Lỗi tìm ra khi thử máy: nút "Hoãn" đặt một báo thức riêng, báo thức này vẫn đổ chuông dù mục đã xóa hoặc đã xong. Đã sửa: khi đặt lại lịch, lần hoãn của mục không còn cần làm hôm nay bị hủy (test `reminder_planner_test`). Bản sửa CHƯA cài lên máy thật
- [x] Manifest: `SCHEDULE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`, `RECEIVE_BOOT_COMPLETED` (+ `VIBRATE`, `POST_NOTIFICATIONS` của thư viện); không có INTERNET, không có `USE_EXACT_ALARM`: `aapt2 dump permissions` 2026-11-04. Build release đạt (63,3 MB)
- [x] Đã thử máy thật: lịch đăng ký với hệ thống, thông báo đúng giờ khi màn hình tắt, nút "Xong" khi app đóng, chuông đánh thức màn hình và hiện toàn màn hình, hoãn 10 phút
- [ ] CHƯA thử: âm thanh chuông (máy đang ở chế độ im lặng/rung nên không nghe được), nút "Xong" và "Tắt" trên màn chuông, chuông tự tắt sau 5 phút (mới kiểm thuộc tính `timeout=5 phút`), chuông khi máy có khóa PIN (máy thử không đặt khóa), khởi động lại máy, 20 lần nhắc đo độ lệch (NFR mục 5b), một máy hãng khác, đổi giờ hoặc múi giờ khi app tắt
- [ ] AC-21 chỉ đạt một phần: đổi giờ hoặc múi giờ khi app đang tắt thì lịch giữ giờ cũ tới lần mở app kế tiếp (ghi ở D-007). Cần quyết: chấp nhận ở v1 hay thêm bộ nhận `TIMEZONE_CHANGED`
- [ ] Khai báo full-screen intent trong Play Console khi phát hành (ghi vào docs/RELEASE.md ở G8)

### G5 · Chuỗi ngày, điểm, lịch và thống kê — trạng thái: code xong, test tự động đạt; CHƯA thử máy thật
- [x] Chuỗi hiện tại và dài nhất (ngày bỏ qua, ngày không đến hạn và hôm nay chưa xong không làm đứt chuỗi; kiểu "K lần mỗi tuần/tháng" tính theo tuần/tháng), tỉ lệ thành công 7 ngày, 30 ngày, từ đầu, điểm 0–100 có công thức (AC-23 tới AC-25, D-008): test `habit_stats_test` (25 test, kể cả điểm 54 và 46 tính tay)
- [x] Màn tiến độ từng thói quen: chuỗi, điểm, tỉ lệ, lịch tháng tô trạng thái (đạt, chưa đạt, bỏ qua, không đến hạn, tương lai, hôm nay chưa xong) có cả biểu tượng; đổi tháng bằng mũi tên hoặc vuốt, không lùi trước tháng bắt đầu; chạm ngày đã qua để sửa kết quả (AC-26): test `stats_flow_test`. Chạm thói quen ở danh sách giờ mở màn này, màn sửa mở bằng nút "Sửa"
- [x] Biểu đồ cột giá trị theo ngày (30 ngày) và theo tuần (8 tuần) có vạch mục tiêu cho kiểu Số lượng và Thời gian (AC-27): test `habit_stats_test`, `stats_flow_test`
- [x] Tab Thống kê thứ 4: số mục xong trên tổng của 7 và 30 ngày, 3 thói quen có chuỗi dài nhất (AC-28): test `stats_repository_test`, `stats_flow_test`
- [x] Bảng thay thế "Xem dạng bảng" và mô tả tóm tắt cho mọi biểu đồ (AC-29): test `stats_flow_test`. Dùng TalkBack thật CHƯA thử
- [x] Đo hiệu năng: 50 thói quen × 3 năm (khoảng 54.000 kết quả) tính xong khoảng 0,4 giây trên máy phát triển (test `stats_repository_test`); CHƯA đo trên điện thoại (ngưỡng 1 giây)
- [x] Lỗi tìm ra khi viết test: truy vấn mục con đã đánh dấu bằng `IN (...)` vượt giới hạn biến của SQLite khi lịch sử dài; đã đổi sang phép nối bảng. Hàng ba thẻ chuỗi bị lỗi chiều cao vô hạn trong danh sách cuộn; đã sửa
- [x] Build APK release đạt (64,0 MB), không có quyền INTERNET
- [x] Đã thử máy thật (biên bản bên dưới): tab Thống kê và bảng thay thế, màn tiến độ, lịch tháng (chạm ngày, vuốt đổi tháng, khóa lùi trước tháng bắt đầu), nhập giá trị kiểu Số lượng từ lịch, biểu đồ theo ngày
- [ ] CHƯA thử: biểu đồ theo tuần và bảng của nó, cỡ chữ lớn (đổi cỡ chữ là đổi cài đặt máy nên cần người dùng làm hoặc cho phép), TalkBack, đo thời gian mở màn Thống kê trên máy, chạm ngày kiểu Có/Không đã bỏ qua, mục "Xem tiến độ" ở màn Hôm nay, kiểu Danh sách con và Thời gian
- [ ] Dữ liệu thử "Test nuoc" (Số lượng, mục tiêu 8, bắt đầu 1/11) còn trên máy; xóa khi máy rảnh

### G6 · Pomodoro và widget — trạng thái: todo
- [ ] Đồng hồ Pomodoro theo mốc thời gian, báo hết giờ, nối với thói quen kiểu Thời gian (AC-35 tới AC-38)
- [ ] Chọn cách làm widget (gói cầu nối và mã Kotlin), ghi D-xxx; widget Hôm nay đánh xong được, cập nhật được (AC-39, AC-40)
- [ ] Thử máy thật: tắt màn hình khi đang bấm giờ, widget sau 00:00

### G7 · Sao lưu, khóa PIN, xóa dữ liệu — trạng thái: todo
- [ ] Xuất và khôi phục file `.dailyloop`, đặt lại giờ nhắc sau khi khôi phục, xuất CSV (AC-42 tới AC-44)
- [ ] Khóa PIN; chuông báo thức và widget khi đang khóa (AC-41, AC-45 tới AC-47)
- [ ] Xóa toàn bộ dữ liệu (AC-52)
- [ ] Thử máy thật

### G8 · Khả năng tiếp cận, pháp lý, chuẩn bị phát hành — trạng thái: todo
- [ ] Rà TalkBack, cỡ chữ 200%, vùng chạm, tương phản (AC-49, AC-50)
- [ ] Màn Giới thiệu (AC-51); viết chính sách quyền riêng tư vi/en và đăng ở một trang công khai
- [ ] Đo NFR (SPEC mục 5b), ghi vào `docs/TESTING.md`; kiểm manifest (AC-53)
- [ ] SBOM, tự kiểm MASVS, hoàn tất các dòng áp dụng trong `docs/COMPLIANCE.md`; tra trùng tên "DailyLoop"
- [ ] Closed test 12 người trong 14 ngày (P-09), rồi `/release`

## Việc kế tiếp (tối đa 5, theo thứ tự)
1. Duyệt G3, G4, G5; thử máy thật G5 và nốt phần chưa thử của G4 (cần cài lại bản có sửa lần hoãn)
2. G6: Pomodoro và widget màn hình chính (AC-35 tới AC-41), sửa BUG-001 (qua nửa đêm)
3. Người dùng: chạy `bash scripts/backup.sh <thư mục ngoài ổ D>` (remote GitHub đã có, đã đẩy G1 tới G4)

## Lỗi đã biết (đang mở)
Mỗi lỗi: BUG-xxx · mô tả · cách tái hiện · mức độ (chặn / nặng / nhẹ) · cách tạm tránh.
- BUG-001 · Để app mở qua 00:00 thì màn Hôm nay vẫn coi ngày cũ là hôm nay (dải ngày, việc quá hạn, ngày tương lai) · mở app trước nửa đêm, chờ qua 00:00 · nhẹ · tắt hẳn app rồi mở lại. Sửa ở G6 cùng lúc widget đổi ngày (AC-40)

## Lỗi đã sửa đáng nhớ (nguồn cho bài học)
Mỗi lỗi: BUG-xxx · nguyên nhân gốc · cách sửa · làm sao tránh lần sau.
(Chưa có)

## Ý tưởng ngoài SPEC (chưa được duyệt, KHÔNG tự làm)
- Hộp nhập giá trị (và hộp đánh dấu mục con) ghi rõ ngày đang sửa khi mở từ lịch tháng; bảng thay thế đặt tiêu đề cột ở đầu bảng thay vì phụ đề của dòng đầu
- Bấm Back ở màn soạn khi đã nhập thì hỏi "Bỏ thay đổi?" (hiện tại thoát luôn, mất nội dung đang nhập)
- Bản iOS
- Sao lưu tự động lên Google Drive (cần đăng nhập, mở lại COMPLIANCE)
- Mẫu thói quen có sẵn và thử thách
- Widget cho từng thói quen (cỡ 1×1, 2×2)
- Mở khóa bằng vân tay

## Biên bản thử máy thật
Mỗi lần thử: ngày · máy và phiên bản hệ điều hành · bản app · đã thử gì · kết quả · lỗi phát hiện.
- 2026-11-03 · Galaxy A13 (SM-A135F, Android 14) · APK release G2 (60,1 MB, đủ kiến trúc) · Người dùng cho phép, Claude điều khiển qua adb: chuyển tab Thói quen; tạo "Uong nuoc" kiểu Số lượng, lưu khi chưa có mục tiêu thì hiện "Nhập mục tiêu lớn hơn 0", nhập 8 thì lưu được; mở lại thấy đúng dữ liệu; đổi lịch sang Các thứ trong tuần, lưu khi chưa chọn thứ thì hiện "Chọn ít nhất một thứ", chọn Th 2 và Th 6 thì danh sách hiện "Th 2, Th 6"; xóa có hộp xác nhận, thanh "Đã xóa · Hoàn tác" hiện, bấm Hoàn tác thì thói quen trở lại · Đạt · Không có lỗi trong logcat.
- 2026-11-03 · Galaxy A13 (SM-A135F, Android 14) · APK release G3 (61,4 MB) · Người dùng cho phép, Claude điều khiển qua adb: cài đè bản G2, màn chào 3 trang hiện một lần, bấm Tiếp tới Bắt đầu; màn Hôm nay có dải ngày Th 7 31 tới Th 6 6, chấm "Doc sach" thì có dấu xong và gạch ngang; chọn Th 4 thì tiêu đề "Thứ Tư, 4 tháng 11", chạm mục thì báo "Chỉ ghi được kết quả tới hôm nay"; nút + mở chọn Thói quen mới / Việc mới; tạo việc "Goi dien cho me" lúc 20:00, hiện trên mục đã xong; tab Việc lọc Hôm nay hiện "3 thg 11 · 20:00"; cài lại bản sửa lỗi thì dữ liệu còn nguyên · Đạt sau khi sửa 1 lỗi (bàn phím bật lên sau hộp chọn giờ) · Không có lỗi trong logcat.
- 2026-11-04 08:49–09:00 · Galaxy A13 (SM-A135F, Android 14) · APK release G4 (63,3 MB, đã có bản sửa dùng chung kết nối cơ sở dữ liệu cho nút Xong; CHƯA có bản sửa lần hoãn) · Người dùng cho phép, Claude điều khiển qua adb, luôn kiểm tra app đang ở trước khi chạm: thêm giờ nhắc 08:54 kiểu Thông báo thì app giải thích rồi mới xin quyền (AC-18), quyền cuối cùng đều được cấp (`dumpsys package`: thông báo, toàn màn hình; báo thức chính xác `appops allow`); `dumpsys alarm` có báo thức `RTC_WAKEUP` lúc 08:54 và 3 ngày kế tiếp, `exactAllowReason=permission`; tắt màn hình, tới 08:54 thông báo được đăng lúc 08:54:00.100 (lệch 0,1 giây), importance cao, 1 nút "Xong"; tắt tiến trình app (`am kill`, không còn pid), mở khay thông báo, bấm "Xong": thông báo biến mất, một tiến trình nền khởi động, mở app thấy mục đã xong (AC-19); thêm giờ nhắc 08:58 kiểu Chuông, tắt màn hình, tới 08:58 màn hình tự sáng (Dozing sang Awake) và hiện màn chuông toàn màn hình "Test chuong" với Xong, Hoãn 10 phút, Tắt (AC-20); thông báo chuông importance 5, cờ 0x86 (lặp âm thanh, giữ nguyên, ưu tiên cao), timeout 5 phút; bấm Hoãn thì có thêm báo thức lúc 09:08:36, app về màn Hôm nay, mục chưa xong · Đạt phần đã nêu · Lỗi: lần hoãn vẫn đổ chuông dù mục đã xóa (đã sửa trong code). Ghi chú: một lần chạm trúng hộp chọn ngày bất ngờ (ảnh chụp trước đó đã khác), đã hủy, không đổi ngày nào. Dọn: xóa 2 thói quen thử "Test nhac", "Test chuong", dừng app để hủy báo thức hoãn; không còn báo thức nào của app. Không đụng tới mục "Test" 07:59 của người dùng.
- 2026-11-04 10:14–10:18 · Galaxy A13 (SM-A135F, Android 14) · APK release G5 (64,0 MB, mã nguồn trùng commit ac53d58) · Người dùng cho phép, Claude điều khiển qua adb, kiểm tra app đang ở trước mỗi lần chạm: cài đè bản G4, mở app (trước đó màn hình đang ở Ví Gọn của người dùng), thanh dưới có 4 tab; tab Thống kê hiện "1 trên 4 xong" cho cả 7 và 30 ngày, khớp dữ liệu (3/11 xong 1 trên 2, 4/11 xong 0 trên 2), biểu đồ 7 và 30 cột, nhãn ngày đầu và cuối, mở "Xem dạng bảng" thấy từng ngày "x trên y xong", mục "Chuỗi dài nhất" hiện "Doc sach, 1 ngày"; màn tiến độ "Doc sach": 1 ngày, 1 ngày, 100/100, 100% ở cả 3 khoảng, lịch tháng 11 có ngày 3 đạt, ngày 4 chờ, ngày trước ngày bắt đầu không tô, ngày sau hôm nay màu xám; chạm ngày 4 thì đạt và chuỗi thành 2 ngay lập tức, chạm lại thì về như cũ; vuốt trái sang tháng 12, vuốt phải về tháng 11, nút lùi mờ ở tháng bắt đầu và chạm không lùi; tạo "Test nuoc" kiểu Số lượng mục tiêu 8, chọn ngày bắt đầu 1/11 (hộp chọn ngày không còn bật bàn phím), lịch hiện ngày 1 tới 3 chưa đạt (dấu x đỏ), nhập qua lịch 8, 5, 3 cho ngày 2, 3, 4: ngày 2 đạt, ngày 3 chưa đạt, ngày 4 chờ; chuỗi hiện tại 0, dài nhất 1, điểm 33, tỉ lệ 33% (khớp tính tay: 1 đạt trên 3 đơn vị, hôm nay chờ không tính); biểu đồ theo ngày có 3 cột 8, 5, 3 và vạch mục tiêu 8 · Đạt phần đã nêu · Dừng khi một bong bóng Zalo chiếm màn hình (người dùng đang dùng máy), chưa thử tiếp. Điểm cần cải thiện, không chặn: hộp nhập giá trị khi sửa một ngày từ lịch không ghi ngày đang sửa; ở bảng thay thế dòng "Xong / Tổng" nằm dưới dòng đầu như phụ đề lạc chỗ.
