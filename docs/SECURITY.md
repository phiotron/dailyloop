# SECURITY & PRIVACY — DailyLoop (A003-dailyloop)

Điền trước khi phát hành. Là đầu vào cho chính sách quyền riêng tư và biểu mẫu khai báo của store.

## Quyền thiết bị
| Quyền | Dùng để làm gì | Xin khi nào | Nếu bị từ chối thì sao |
|-------|----------------|-------------|------------------------|

## Dữ liệu thu thập và lưu trữ
| Dữ liệu | Lưu ở đâu | Mã hóa? | Gửi đi đâu | Giữ bao lâu | Người dùng xóa được không |
|---------|-----------|---------|------------|-------------|---------------------------|
| Thói quen, việc, lịch sử, danh mục, giờ nhắc, cài đặt, trạng thái Pomodoro | SQLite `dailyloop.sqlite` trong bộ nhớ riêng của app | KHÔNG (D-011) | Không đi đâu | Tới khi người dùng xóa | Có: Cài đặt > Xóa toàn bộ dữ liệu (AC-52) |
| Mã PIN (muối 16 byte + mã băm SHA-256 20.000 vòng, không lưu mã) | Android Keystore / iOS Keychain (`first_unlock_this_device`) qua `flutter_secure_storage` | Có (bộ nhớ an toàn của hệ điều hành); mã băm không phải mã hóa dữ liệu | Không đi đâu, không nằm trong file sao lưu | Tới khi tắt PIN hoặc xóa dữ liệu | Có (tắt PIN, Xóa toàn bộ dữ liệu) |
| File sao lưu `.dailyloop` và CSV | File tạm trong thư mục tạm của app, rồi do người dùng chọn nơi lưu qua bảng chia sẻ | KHÔNG; mã băm chỉ phát hiện hỏng, không chống sửa cố ý | Chỉ nơi người dùng tự chọn | File tạm do hệ điều hành dọn; bản người dùng lưu thì tùy họ | Người dùng tự xóa bản đã lưu |
| Dữ liệu widget (tên mục hôm nay; chỉ số mục còn lại khi có PIN, AC-41) | SharedPreferences `dailyloop_widget` (Android) | KHÔNG | Không đi đâu | Ghi đè mỗi lần dữ liệu đổi | Có (Xóa toàn bộ dữ liệu làm trống) |

## Khóa PIN và sao lưu: giới hạn phải nói thật (D-011, D-012)
- PIN 4 số **chỉ chặn người cầm máy tò mò mở app**. Cơ sở dữ liệu và file sao lưu KHÔNG được mã hóa. Chỉ có 10.000 mã nên kẻ lấy được mã băm (máy root) dò hết gần như tức thì. Không ghi "mã hóa dữ liệu" ở bất cứ đâu (app, store, chính sách).
- Quên PIN: chỉ còn cách xóa toàn bộ dữ liệu (AC-47), nên người dùng cần xuất file sao lưu từ trước.
- Chưa có giới hạn số lần nhập sai PIN; chưa có FLAG_SECURE cho màn hình "gần đây"; chưa ẩn tên mục trong thông báo trên màn khóa (cần `reminder_service.dart`, xem D-011).
- File `.dailyloop` có mã băm toàn vẹn nhưng ai cũng sửa và tính lại được; app kiểm định dạng, phiên bản, mã băm, ràng buộc dữ liệu và không bao giờ chạy mã trong file.
- Android `allowBackup="false"`: Google không sao lưu cơ sở dữ liệu lên Drive. iOS: PIN dùng `first_unlock_this_device` nên không đồng bộ iCloud Keychain; cơ sở dữ liệu nằm trong thư mục app (có thể vào bản sao lưu iCloud/iTunes của thiết bị, người dùng tắt ở cài đặt iOS nếu muốn).

## Bí mật và khóa
- Khóa API, keystore, chứng chỉ: nơi cất NGOÀI repo là: {{...}}
- `.env` đã nằm trong `.gitignore`: [ ] đã kiểm tra
- Không có bí mật trong lịch sử git: [ ] đã kiểm tra (`git log -p` tìm thử)

## Rà soát trước phát hành
- [ ] Mọi kết nối mạng dùng HTTPS
- [ ] Dữ liệu nhạy cảm không nằm trong log
- [x] Không lưu mật khẩu/token dạng thô trên máy (dùng kho an toàn của hệ điều hành) — PIN: muối + mã băm trong Keystore/Keychain, test `test/data/pin_test.dart` (2026-11-04); chưa thử trên Keystore/Keychain thật
- [ ] Đầu vào người dùng được kiểm tra/làm sạch ở chỗ cần
- [ ] Thư viện bên thứ ba: đã chạy kiểm tra lỗ hổng ({{lệnh theo stack}}) và xử lý mục nghiêm trọng
- [ ] Chính sách quyền riêng tư đã viết và có đường dẫn công khai (nếu thu thập dữ liệu)
- [ ] Khai báo dữ liệu trên store khớp với bảng ở trên
