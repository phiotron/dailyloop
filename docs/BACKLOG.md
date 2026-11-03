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
- [ ] CI `.github/workflows/ci.yml` CHƯA chạy (repo chưa có remote)

### G2 · Thói quen và lịch lặp — trạng thái: done (chờ người dùng duyệt)
- [x] Hàm tính ngày đến hạn `DueCalculator` cho mọi kiểu lịch lặp, kể cả năm nhuận, ngày 31, N ngày, K lần/tuần, ngày kết thúc, đổi lịch giữa chừng (AC-03, AC-04): test `schedule_test`
- [x] Hàm "đạt mục tiêu" cho 4 kiểu đánh giá (AC-02; dùng ở G3 cho AC-09): test `schedule_test`
- [x] Tạo, sửa, lưu trữ/khôi phục, xóa có hoàn tác 5 giây, kéo sắp xếp thói quen; kiểm nhập liệu: tên, mô tả, mục tiêu, mục con, lịch, ngày (AC-01, AC-02, AC-04 tới AC-06): test `activity_repository_test`, `habits_flow_test`
- [x] Quản lý danh mục (thêm, sửa tên/icon/màu, xóa có chuyển mục) và lọc theo danh mục (AC-31, AC-32): test `activity_repository_test`, `habits_flow_test`
- [x] Màn soạn tự cuộn tới dòng báo lỗi bị khuất (lỗi tìm ra khi viết test); không tràn ở cỡ chữ 200%: test `habits_flow_test`
- [x] Làm sớm một phần AC-33: thanh điều hướng dưới có Hôm nay và Thói quen (Việc thêm ở G3, Thống kê ở G5)
- [x] Thử máy thật (biên bản bên dưới): tạo, báo lỗi, sửa lịch, xóa và hoàn tác
- [ ] CHƯA thử trên máy thật: lưu trữ/khôi phục, kéo sắp xếp, màn Danh mục, chọn ngày, cỡ chữ lớn, TalkBack

### G3 · Màn Hôm nay và việc cần làm — trạng thái: todo
- [ ] Màn Hôm nay, dải ngày, ghi kết quả theo từng kiểu, bỏ qua, trạng thái trống (AC-07 tới AC-12)
- [ ] Việc một lần, việc lặp, quá hạn, chưa xếp lịch, màn Việc có bộ lọc (AC-13 tới AC-16)
- [ ] Thanh điều hướng dưới, nút "+", màn chào (AC-33, AC-34)
- [ ] Thử máy thật

### G4 · Nhắc giờ và chuông báo thức — trạng thái: todo
- [ ] Tra chính sách Google Play và tài liệu Android hiện hành về `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`; chọn thư viện; ghi D-xxx
- [ ] Đặt, hủy, đặt lại giờ nhắc khi khởi động máy, đổi giờ hoặc đổi múi giờ (AC-17, AC-21, AC-22)
- [ ] Xin quyền đúng lúc, xử lý khi bị từ chối (AC-18)
- [ ] Thông báo có nút "Xong" (AC-19); chuông toàn màn hình, hoãn, tự dừng sau 5 phút (AC-20)
- [ ] Thử máy thật: 20 lần nhắc, máy khóa màn hình hơn 30 phút, khởi động lại máy (NFR mục 5b)

### G5 · Chuỗi ngày, điểm, lịch và thống kê — trạng thái: todo
- [ ] Chuỗi hiện tại, chuỗi dài nhất, tỉ lệ thành công, công thức điểm (ghi D-xxx) (AC-23 tới AC-25)
- [ ] Lịch tháng từng thói quen, biểu đồ cột, thống kê chung, bảng thay thế cho trình đọc màn hình (AC-26 tới AC-29)
- [ ] Đo hiệu năng với 50 thói quen và 3 năm dữ liệu giả (NFR)
- [ ] Thử máy thật

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
1. Người dùng duyệt G1 và G2 (bản G2 đã cài trên Galaxy A13, có sẵn thói quen thử "Doc sach")
2. G3: màn Hôm nay (dải ngày, chấm kết quả, bỏ qua), việc cần làm, tab Việc, màn chào
3. Người dùng: tạo remote git cho APP-002 và chạy `bash scripts/backup.sh <thư mục ngoài ổ D>`

## Lỗi đã biết (đang mở)
Mỗi lỗi: BUG-xxx · mô tả · cách tái hiện · mức độ (chặn / nặng / nhẹ) · cách tạm tránh.
(Chưa có)

## Lỗi đã sửa đáng nhớ (nguồn cho bài học)
Mỗi lỗi: BUG-xxx · nguyên nhân gốc · cách sửa · làm sao tránh lần sau.
(Chưa có)

## Ý tưởng ngoài SPEC (chưa được duyệt, KHÔNG tự làm)
- Bản iOS
- Sao lưu tự động lên Google Drive (cần đăng nhập, mở lại COMPLIANCE)
- Mẫu thói quen có sẵn và thử thách
- Widget cho từng thói quen (cỡ 1×1, 2×2)
- Mở khóa bằng vân tay

## Biên bản thử máy thật
Mỗi lần thử: ngày · máy và phiên bản hệ điều hành · bản app · đã thử gì · kết quả · lỗi phát hiện.
- 2026-11-03 · Galaxy A13 (SM-A135F, Android 14) · APK release G2 (60,1 MB, đủ kiến trúc) · Người dùng cho phép, Claude điều khiển qua adb: chuyển tab Thói quen; tạo "Uong nuoc" kiểu Số lượng, lưu khi chưa có mục tiêu thì hiện "Nhập mục tiêu lớn hơn 0", nhập 8 thì lưu được; mở lại thấy đúng dữ liệu; đổi lịch sang Các thứ trong tuần, lưu khi chưa chọn thứ thì hiện "Chọn ít nhất một thứ", chọn Th 2 và Th 6 thì danh sách hiện "Th 2, Th 6"; xóa có hộp xác nhận, thanh "Đã xóa · Hoàn tác" hiện, bấm Hoàn tác thì thói quen trở lại · Đạt · Không có lỗi trong logcat.
