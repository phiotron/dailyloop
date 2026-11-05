# MANUAL-TESTS — Orbiday (A003-dailyloop)

Danh sách việc kiểm tay trên máy thật + biên bản các lần đã thử. Mỗi AC mang nhãn **[M]** trong `docs/SPEC.md` được ghi kết quả ở đây.
Cách ghi: ngày · máy + phiên bản hệ điều hành · bản app · đã thử gì · kết quả · lỗi phát hiện.
**Quy tắc máy thử:** Galaxy A13 (SM-A135F, Android 14, 32-bit) là máy dùng chung với app khác → chỉ dùng adb khi người dùng cho phép trong phiên; kiểm `mCurrentFocus` trước mỗi lần chạm; không build APK chỉ arm64.

## Việc thử máy còn lại (CHƯA thử)
**Android**
- G1: mở app, đổi giao diện sáng/tối, đổi ngôn ngữ vi/en, nút Back, xoay máy.
- G2: lưu trữ/khôi phục thói quen, kéo sắp xếp (AC-06), màn Danh mục, chọn ngày, cỡ chữ lớn nhất, TalkBack.
- G3: kiểu Số lượng / Thời gian / Danh sách con ở màn Hôm nay, "bỏ qua ngày này", việc quá hạn, các bộ lọc của màn Việc, cỡ chữ lớn, TalkBack.
- G4 (nhắc giờ): âm thanh chuông (máy phải ở chế độ chuông), nút Xong và Tắt trên màn chuông, chuông tự tắt sau 5 phút, chuông khi máy có khóa PIN, khởi động lại máy, 20 lần nhắc đo độ lệch (SPEC mục 5b), thử trên một máy hãng khác, **đổi giờ/múi giờ khi app tắt (AC-21 — receiver mới ở G7)**.
- G5: biểu đồ theo tuần + bảng, cỡ chữ lớn, TalkBack, đo thời gian mở màn Thống kê, chạm ngày kiểu Có/Không đã bỏ qua, "Xem tiến độ" ở màn Hôm nay, kiểu Danh sách con và Thời gian.
- G6: thêm widget vào màn hình chính; chạm ô đánh dấu; chạm tên; thêm/xóa mục trong app và đếm giây tới khi widget đổi (AC-40: 5 giây); chờ qua 00:00; Pomodoro: tắt màn hình rồi nghe thông báo hết giờ (AC-36); tắt hẳn app lúc đang chạy rồi mở lại (AC-38). Giả định "Kotlin ghi được vào `app_flutter/dailyloop.sqlite` bảng `entries`" chưa kiểm chứng.
- G7: sao lưu → khôi phục trên máy thật (chọn file, chia sẻ), CSV mở bằng Excel, PIN (đặt/đổi/tắt/quên), màn khóa + chuông khi khóa, widget ẩn tên khi có PIN (AC-41), thông báo ẩn tên (AC-46, chưa làm xong), xóa toàn bộ dữ liệu.
- Dọn dữ liệu thử "Test nuoc" (Số lượng, mục tiêu 8) còn trên máy.
**iOS (không có iPhone → cần mượn máy hoặc người thử TestFlight):** chuông time-sensitive, nút Xong/Hoãn/Tắt khi app đóng, 64 thông báo chờ, chia sẻ/chọn file sao lưu, Keychain (PIN), widget iOS (khi có).

## Biên bản đã có (thử trên Galaxy A13, người dùng cho phép, điều khiển qua adb)
- **2026-11-03 · APK release G2:** tạo thói quen kiểu Số lượng (kiểm lỗi "Nhập mục tiêu lớn hơn 0", lưu mục tiêu 8), lịch các thứ trong tuần (lỗi "Chọn ít nhất một thứ"), xóa có hộp xác nhận + "Hoàn tác". **Đạt**, không lỗi trong logcat.
- **2026-11-03 · APK release G3:** màn chào 3 trang hiện một lần; màn Hôm nay + dải ngày, chấm xong có gạch ngang; ngày tương lai chỉ xem ("Chỉ ghi được kết quả tới hôm nay"); nút + chọn Thói quen/Việc mới; tạo việc có giờ; lọc "Hôm nay" ở màn Việc; cài đè giữ nguyên dữ liệu. **Đạt.**
- **2026-11-04 · APK release G4:** thêm giờ nhắc kiểu Thông báo — app giải thích rồi mới xin quyền (AC-18); `dumpsys alarm` có báo thức chính xác và 3 ngày kế tiếp; thông báo + nút Xong hoạt động khi tắt màn hình (đã sửa dùng chung kết nối DB cho nút Xong). **Đạt một phần** — phần CHƯA thử ở mục trên; lỗi lần hoãn đã sửa sau đó.
- **2026-11-04 · APK release G5:** tab Thống kê "1 trên 4 xong" cho 7 và 30 ngày, khớp dữ liệu; biểu đồ 7/30 cột, "Xem dạng bảng", "Chuỗi dài nhất"; màn tiến độ thói quen. **Đạt** phần đã thử.

## Lỗi đã sửa đáng nhớ
- **BUG-001** — màn Hôm nay giữ ngày cũ khi app mở qua 00:00. Nguyên nhân: "hôm nay" chỉ đọc một lần lúc dựng provider. Sửa: `todayProvider` có bộ hẹn giờ tới 00:00 và làm mới khi quay lại app. **Quy tắc:** mọi chỗ cần "hôm nay" đọc từ `todayProvider`, không gọi giờ máy trực tiếp.

## Ý tưởng ngoài SPEC (chưa duyệt, KHÔNG tự làm)
Hộp nhập giá trị ghi rõ ngày đang sửa khi mở từ lịch tháng (bảng thay thế đặt tiêu đề cột ở đầu bảng) · Back ở màn soạn khi đã nhập thì hỏi "Bỏ thay đổi?" · sao lưu tự động lên Google Drive (cần đăng nhập, mở lại COMPLIANCE) · mẫu thói quen có sẵn và thử thách · widget cho từng thói quen (1×1, 2×2) · mở khóa vân tay/khuôn mặt.
