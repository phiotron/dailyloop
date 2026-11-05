# TESTING — DailyLoop (A003-dailyloop)

## Nguyên tắc
- Mỗi AC trong SPEC phải được kiểm chứng bằng ĐÚNG MỘT trong hai cách: test tự động, hoặc kiểm tra tay có ghi biên bản trong `docs/MANUAL-TESTS.md`. Ghi rõ ở cột "Cách kiểm chứng" của SPEC.
- Logic nghiệp vụ, xử lý dữ liệu, định dạng, tính toán: BẮT BUỘC có test tự động.
- Lỗi đã sửa: nếu khả thi, thêm test chặn lỗi quay lại trước khi coi là xong.
- Không báo "test đạt" khi chưa chạy lệnh test trong phiên và đọc kết quả.

## Các tầng
| Tầng | Kiểm cái gì | Công cụ | Khi nào chạy |
|------|-------------|---------|--------------|
| Lint + typecheck | Lỗi cú pháp, kiểu | {{điền theo stack}} | Mỗi giai đoạn, mỗi commit (CI) |
| Unit | Hàm, logic | {{...}} | Mỗi giai đoạn |
| Component/màn hình | Giao diện chính hoạt động đúng | {{...}} | Mỗi giai đoạn có UI |
| Tay trên máy thật | Cảm ứng, quyền, offline, hiệu năng, bàn phím, xoay màn hình | Người dùng | Cuối mỗi giai đoạn (Cổng 3) và trước phát hành |

## Ma trận thử máy thật (tối thiểu trước phát hành)
- [ ] Ít nhất 1 máy Android thật (ghi đời máy, phiên bản)
- [ ] Ít nhất 1 máy iOS thật nếu SPEC có iOS
- [ ] Màn hình nhỏ nhất theo SPEC
- [ ] Mất mạng giữa chừng; mạng yếu
- [ ] Từ chối từng quyền thiết bị; thu hồi quyền khi đang dùng
- [ ] Thoát app và mở lại (trạng thái, dữ liệu còn đúng)
- [ ] Có cuộc gọi/thông báo chen ngang
- [ ] Chạy lâu 10–15 phút: không giật, không nóng máy bất thường

## Bảng truy vết: mỗi AC phải có bằng chứng kiểm chứng
Cập nhật khi viết test hoặc khi thử tay. Một AC chưa có dòng ở đây hoặc cột "Kết quả lần cuối" trống nghĩa là CHƯA được kiểm chứng.
| AC (SPEC) | Cách | Test hoặc biên bản (tên test / mục trong MANUAL-TESTS) | Kết quả lần cuối (ngày, lệnh hoặc máy, đạt/hỏng) |
|-----------|------|----------------------------------------------------|-----------------------------------------------------|
| AC-01 | tự động / tay | | |
| AC-21 | tự động (logic) + tay (máy thật) | `test/data/time_change_test.dart` (tính lại lịch theo giờ máy mới, không trùng, chữ theo ngôn ngữ; manifest + Kotlin khai đúng). Phần native `TimeChangeReceiver.kt` (D-013) | Logic: đạt 2026-11-04 `flutter test`. Native đổi múi giờ / chỉnh giờ / khởi động lại: **CHƯA thử máy thật** |
| AC-41 | tự động (dữ liệu) + tay (widget thật) | `test/features/lock_flow_test.dart` nhóm "widget ẩn tên khi có PIN" (3 test), `test/data/home_widget_test.dart` | Dữ liệu widget: đạt 2026-11-04. Hiển thị widget thật: **CHƯA thử máy thật** |
| AC-42 | tay (bảng chia sẻ) + tự động (nội dung file) | `test/data/backup_test.dart` (định dạng, mã băm), `test/features/data_flow_test.dart` "Xuất bản sao lưu" | Nội dung file: đạt 2026-11-04. Bảng chia sẻ thật Android/iOS: **CHƯA thử máy thật** |
| AC-43 | tự động | `test/data/backup_test.dart` (khứ hồi y nguyên, thay toàn bộ, file hỏng / sai định dạng / bị sửa / bản mới hơn / sai ràng buộc quay lui, đặt lại giờ nhắc), `test/features/data_flow_test.dart` (xác nhận, file hỏng, hủy chọn) | đạt 2026-11-04 `flutter test` |
| AC-44 | tự động | `test/data/backup_test.dart` nhóm "xuất CSV", `test/features/data_flow_test.dart` "Xuất CSV" | đạt 2026-11-04. Mở bằng Excel / Google Sheets thật: chưa thử |
| AC-45 | tự động | `test/data/pin_test.dart` (muối, băm, không lưu mã), `test/features/lock_flow_test.dart` (đặt hai lần, đổi, tắt) | đạt 2026-11-04. Keystore / Keychain thật: chưa thử |
| AC-46 | tự động (khóa, chuông) + tay | `test/data/pin_test.dart` (khóa lại > 1 phút), `test/features/lock_flow_test.dart` (màn khóa, chuông Xong/Hoãn/Tắt không cần PIN, mở app cần PIN) | Đạt 2026-11-04 trừ: Snooze thật (cần plugin), thông báo ẩn tên trên màn khóa **chưa làm** (D-011), thử máy thật chưa |
| AC-47 | tự động | `test/features/lock_flow_test.dart` "quên mã" (giải thích, hai bước, xóa dữ liệu + PIN) | đạt 2026-11-04 |
| AC-52 | tự động | `test/data/backup_test.dart` (xóa sạch, id về 1), `test/features/data_flow_test.dart` (hai bước, hủy lịch nhắc + Pomodoro, widget trống, màn chào) | đạt 2026-11-04 |

## Yêu cầu phi chức năng (SPEC mục 5b): đo bằng gì
| Yêu cầu | Cách đo | Kết quả lần cuối |
|---------|---------|------------------|
| | | |

## Lệnh
Xem mục "Lệnh" trong `CLAUDE.md` của app (một nơi duy nhất).
