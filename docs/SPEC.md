# SPEC — DailyLoop (A003-dailyloop)

Đã duyệt: 2026-11-03
<!-- Khi người dùng duyệt, đổi thành: "Đã duyệt: YYYY-MM-DD". Chưa có dòng này thì Claude không viết code. -->

## 1. Vấn đề cần giải quyết
Người muốn sống có nề nếp (uống đủ nước, tập thể dục, đọc sách, uống thuốc đúng giờ) hay bỏ cuộc sau vài ngày, vì quên làm và không thấy mình đã tiến bộ tới đâu. Hiện họ dùng giấy dán, báo thức điện thoại và ghi chú rời rạc, nên không có chỗ nào gom thói quen lẫn việc cần làm của ngày, và cũng không đếm được chuỗi ngày liên tiếp. DailyLoop gom thói quen và việc cần làm vào màn "Hôm nay", nhắc đúng giờ, và cho thấy chuỗi ngày cùng thống kê. Chức năng tương đương HabitNow, nhưng tên, biểu tượng, icon và giao diện do mình tự thiết kế. Không sao chép chữ, hình hay mô tả store của HabitNow.

## 2. Người dùng và tình huống sử dụng trên điện thoại
- Người đi làm, sinh viên, người muốn xây thói quen sức khỏe hay học tập. Ở Việt Nam và nước khác (tiếng Việt, tiếng Anh).
- Buổi sáng: mở app hoặc nhìn widget để xem hôm nay cần làm gì.
- Trong ngày: nhận thông báo hoặc chuông, chấm "xong" bằng một chạm, thường cầm máy MỘT tay, có thể không có mạng.
- Cuối ngày hoặc cuối tuần: xem chuỗi ngày, lịch tháng và thống kê; chỉnh lại thói quen.

## 3. Tính năng bản đầu (MVP) và tiêu chí chấp nhận
Quy ước kiểm chứng: **[T]** = test tự động (`flutter test`), **[M]** = thử tay trên máy Android thật, ghi biên bản vào `docs/MANUAL-TESTS.md`.
"Ngày" luôn tính theo giờ địa phương của máy, từ 00:00 tới 23:59.

### F-01 · Tạo và quản lý thói quen
- AC-01: Tạo thói quen gồm tên (bắt buộc, tối đa 60 ký tự), danh mục, mô tả (tùy chọn, tối đa 300 ký tự), ngày bắt đầu (mặc định hôm nay), ngày kết thúc (tùy chọn), mức ưu tiên (thấp, thường, cao). Tên để trống thì không lưu được và hiện lỗi cạnh ô tên. [T]
- AC-02: Có 4 kiểu đánh giá: (a) **Có/Không**; (b) **Số lượng**: mục tiêu là số dương, có đơn vị (ví dụ "ly") và điều kiện "ít nhất", "đúng bằng" hoặc "nhiều nhất"; (c) **Thời gian**: mục tiêu tính bằng phút, có điều kiện như kiểu (b); (d) **Danh sách con**: 1 tới 20 mục con, đạt khi xong ít nhất N mục (N chọn được, mặc định là tất cả). [T]
- AC-03: Lịch lặp chọn được một trong các kiểu: mỗi ngày; các thứ cố định trong tuần; các ngày cố định trong tháng (1 tới 31; tháng không có ngày 31 thì bỏ qua); cứ N ngày một lần (N từ 2 tới 365); K lần mỗi tuần hoặc mỗi tháng, người dùng tự chọn ngày nào. Với một thói quen và một khoảng ngày bất kỳ, hàm tính "ngày đến hạn" trả đúng danh sách ngày, kể cả năm nhuận và ngày kết thúc. [T]
- AC-04: Sửa thói quen thì không làm mất các lần đã ghi trước đó. Đổi lịch lặp chỉ ảnh hưởng từ hôm nay trở đi. [T]
- AC-05: Lưu trữ (archive) thì thói quen biến khỏi màn Hôm nay nhưng vẫn còn trong mục "Đã lưu trữ" kèm toàn bộ lịch sử, và khôi phục được. Xóa thì hỏi xác nhận, xóa cả lịch sử, và có thanh "Đã xóa · Hoàn tác" trong 5 giây. [T]
- AC-06: Kéo để sắp xếp thứ tự thói quen trong danh sách, thứ tự được giữ sau khi tắt app. [M]

### F-02 · Màn Hôm nay và ghi kết quả
- AC-07: Màn Hôm nay liệt kê các thói quen đến hạn hôm nay và các việc cần làm của hôm nay, sắp theo giờ nhắc rồi đến mức ưu tiên. Mục đã xong xếp xuống dưới. [T]
- AC-08: Có dải ngày ngang ở đầu màn hình (7 ngày quanh ngày đang chọn). Chạm một ngày thì hiện danh sách của ngày đó. Ngày đã qua thì sửa kết quả được. Ngày tương lai thì chỉ xem, không chấm được. [T]
- AC-09: Kiểu Có/Không: một chạm để đánh xong, chạm lại để bỏ. Kiểu Số lượng: có nút +1 và ô nhập số. Kiểu Thời gian: nhập số phút hoặc bấm giờ (F-09). Kiểu Danh sách con: đánh dấu từng mục. Trạng thái đạt hoặc chưa đạt tính đúng theo điều kiện ở AC-02. [T]
- AC-10: Đánh dấu một mục là "bỏ qua hôm nay" thì mục đó không tính là thất bại và không làm đứt chuỗi (F-05). [T]
- AC-11: Ngày không có mục nào thì hiện trạng thái trống, kèm nút "Thêm thói quen" và "Thêm việc". [M]
- AC-12: Chấm xong một mục thì lưu ngay xuống máy. Tắt app ngay sau đó, mở lại vẫn thấy kết quả. [T]

### F-03 · Việc cần làm
- AC-13: Tạo việc một lần gồm tên, danh mục, ngày (tùy chọn), giờ (tùy chọn), ưu tiên, ghi chú, danh sách mục con (tùy chọn). Việc không có ngày nằm ở mục "Chưa xếp lịch". [T]
- AC-14: Tạo việc lặp lại dùng chung các kiểu lịch lặp ở AC-03, chỉ có kiểu Có/Không, và không tính chuỗi. [T]
- AC-15: Việc một lần quá ngày mà chưa xong thì hiện ở đầu màn Hôm nay với nhãn "Quá hạn · <số ngày>", cho tới khi được đánh xong, đổi ngày hoặc xóa. [T]
- AC-16: Màn "Việc" liệt kê mọi việc, lọc được theo: hôm nay, sắp tới, quá hạn, chưa xếp lịch, đã xong. [T]

### F-04 · Nhắc giờ: thông báo và chuông báo thức
- AC-17: Mỗi thói quen hoặc việc có 0 tới 5 giờ nhắc. Mỗi giờ nhắc chọn được kiểu "Thông báo" hoặc "Chuông báo thức". Chỉ nhắc vào ngày mục đó đến hạn. [T]
- AC-18: Lần đầu đặt giờ nhắc, app hiện màn giải thích vì sao cần quyền rồi mới xin quyền thông báo (Android 13 trở lên). Người dùng từ chối thì app vẫn dùng bình thường, giờ nhắc có biểu tượng cảnh báo và nút mở Cài đặt hệ thống. [M]
- AC-19: Thông báo hiện đúng giờ đã đặt, lệch không quá 1 phút trên máy thật, khi app đã đóng và máy đang khóa màn hình. Thông báo có nút "Xong" để đánh xong ngay mà không mở app (cho kiểu Có/Không). [M]
- AC-20: Chuông báo thức hiện màn hình toàn màn hình trên màn khóa, phát âm thanh lặp lại cho tới khi bấm "Xong", "Hoãn 10 phút" hoặc "Tắt", và tự dừng sau tối đa 5 phút. Quyền báo thức chính xác hoặc quyền toàn màn hình mà chưa được cấp thì app giải thích và dẫn tới cài đặt hệ thống. Nếu vẫn không được cấp thì giờ nhắc đó chạy như thông báo thường. [M]
- AC-21: Khởi động lại máy, đổi giờ hay đổi múi giờ thì mọi giờ nhắc tự được đặt lại, không mất và không bị nhắc trùng. [T cho logic đặt lịch; M cho khởi động lại máy]
- AC-22: Đánh xong mục trước giờ nhắc thì giờ nhắc còn lại của mục đó trong ngày không báo nữa. [T]

### F-05 · Chuỗi ngày và điểm thói quen
- AC-23: Mỗi thói quen hiện chuỗi hiện tại (số ngày đến hạn liên tiếp đã đạt, tính tới hôm qua, cộng thêm hôm nay nếu hôm nay đã đạt) và chuỗi dài nhất. Ngày không đến hạn và ngày "bỏ qua" không làm đứt chuỗi. Với kiểu "K lần mỗi tuần/tháng", chuỗi tính theo số tuần hoặc tháng liên tiếp đã đạt đủ K lần. [T]
- AC-24: Tỉ lệ thành công bằng số ngày đạt chia cho số ngày đến hạn đã qua, không tính ngày bỏ qua và hôm nay nếu chưa ghi. Hiện được cho 7 ngày, 30 ngày và từ đầu. [T]
- AC-25: Điểm thói quen từ 0 tới 100, tính theo công thức ghi trong DECISIONS (lần đạt gần đây có trọng số cao hơn). Cùng dữ liệu thì luôn ra cùng điểm. [T]

### F-06 · Lịch và thống kê
- AC-26: Mỗi thói quen có lịch tháng tô màu từng ngày: đạt, chưa đạt, bỏ qua, không đến hạn, tương lai. Vuốt ngang để sang tháng khác. Chạm một ngày đã qua thì sửa được kết quả ngày đó. [M]
- AC-27: Thói quen kiểu Số lượng hoặc Thời gian có biểu đồ cột giá trị theo ngày hoặc theo tuần, có đường mục tiêu. [M]
- AC-28: Màn Thống kê chung hiện số mục đã xong trên tổng số mục mỗi ngày trong 7 ngày và 30 ngày gần nhất, cùng 3 thói quen có chuỗi dài nhất. Số liệu khớp với dữ liệu ghi. [T]
- AC-29: Biểu đồ có bảng thay thế để trình đọc màn hình đọc được (xem AC-49). [M]

### F-07 · Danh mục
- AC-30: Lần mở đầu có sẵn danh mục mặc định (ví dụ: Sức khỏe, Thể thao, Học tập, Công việc, Tài chính, Nhà cửa, Tinh thần, Khác), mỗi danh mục có icon và màu, tên theo ngôn ngữ máy. [T]
- AC-31: Thêm, sửa tên, icon, màu, và xóa danh mục. Xóa danh mục đang dùng thì hỏi chuyển các mục sang danh mục khác. [T]
- AC-32: Lọc màn Hôm nay và danh sách thói quen theo danh mục. [T]

### F-08 · Mở app và điều hướng
- AC-33: Thanh điều hướng dưới có 4 mục: Hôm nay, Thói quen, Việc, Thống kê. Nút "+" nằm ở nửa dưới màn hình, mở chọn "Thói quen mới" hoặc "Việc mới". [M]
- AC-34: Lần mở đầu có màn chào ngắn (tối đa 3 trang, bỏ qua được), không xin quyền nào ở bước này. [M]

### F-09 · Đồng hồ hẹn giờ và Pomodoro
- AC-35: Đồng hồ Pomodoro có thời gian tập trung, nghỉ ngắn, nghỉ dài và số phiên trước nghỉ dài chỉnh được. Mặc định là 25, 5, 15 phút và 4 phiên. [T]
- AC-36: Đồng hồ vẫn đúng khi tắt màn hình hoặc chuyển app. Thời gian còn lại tính từ mốc bắt đầu đã lưu, không dựa vào vòng đếm chạy nền. Hết giờ thì có thông báo kèm âm thanh, lệch không quá 1 phút trên máy thật. [T cho phép tính; M cho tắt màn hình]
- AC-37: Mở đồng hồ từ một thói quen kiểu Thời gian. Bấm dừng hoặc hết giờ thì số phút được cộng vào kết quả hôm nay của thói quen đó. [T]
- AC-38: Tắt hẳn app khi đồng hồ đang chạy, mở lại thì đồng hồ tiếp tục đúng thời gian còn lại, hoặc báo đã hết giờ. [T]

### F-10 · Widget màn hình chính
- AC-39: Có widget danh sách "Hôm nay" (cỡ 4×2 trở lên) hiện tên các mục đến hạn và trạng thái xong. Chạm vào ô đánh dấu của mục Có/Không thì đánh xong luôn mà không mở app. Chạm vào tên mục thì mở app tại mục đó. [M]
- AC-40: Widget cập nhật trong vòng 5 giây sau khi có thay đổi trong app, và tự chuyển sang ngày mới sau 00:00 (cho phép trễ tối đa 15 phút). [M]
- AC-41: Khi bật khóa PIN, widget chỉ hiện số mục còn lại, không hiện tên mục. [M]

### F-11 · Sao lưu và khôi phục bằng file
- AC-42: "Xuất bản sao lưu" tạo một file `.dailyloop` (JSON có số phiên bản định dạng và mã kiểm tra toàn vẹn) rồi mở bảng chia sẻ của hệ điều hành. App không xin quyền bộ nhớ. [M]
- AC-43: "Khôi phục" chọn file qua trình chọn file của hệ điều hành, kiểm tra định dạng và tính toàn vẹn, hỏi xác nhận "Dữ liệu hiện tại sẽ bị thay thế", rồi khôi phục đủ thói quen, việc, lịch sử, danh mục, giờ nhắc và cài đặt, sau đó đặt lại toàn bộ giờ nhắc. File hỏng hoặc sai định dạng thì báo lỗi và giữ nguyên dữ liệu hiện có. [T]
- AC-44: Xuất lịch sử ra CSV (ngày, tên mục, loại, kết quả, giá trị) mở được bằng Excel hoặc Google Sheets mà chữ tiếng Việt không lỗi phông. [T]

### F-12 · Khóa bằng mã PIN
- AC-45: Bật khóa trong Cài đặt bằng PIN 4 số, nhập hai lần để xác nhận. PIN lưu dạng băm có muối trong bộ nhớ an toàn của hệ điều hành. [T]
- AC-46: Khi bật khóa, mở app hoặc quay lại app sau hơn 1 phút ở nền thì phải nhập PIN. Chuông báo thức (AC-20) vẫn hiện được trên màn khóa với các nút "Xong", "Hoãn", "Tắt" mà không cần PIN, nhưng muốn mở app từ chuông thì phải nhập PIN. Thông báo trên màn khóa ẩn tên mục. [M]
- AC-47: Màn khóa có nút "Quên mã", giải thích rằng chỉ xóa được toàn bộ dữ liệu để dùng lại, có xác nhận hai bước. [M]

### F-13 · Giao diện, ngôn ngữ, khả năng tiếp cận
- AC-48: Có giao diện sáng, tối và theo hệ thống. Có tiếng Việt và tiếng Anh, mặc định theo ngôn ngữ máy, đổi được trong Cài đặt. Mọi chuỗi giao diện nằm trong file dịch. Ngày đầu tuần (Thứ Hai hoặc Chủ Nhật) chỉnh được. [T]
- AC-49: Bật TalkBack thì đọc được tên mọi nút, tên và trạng thái từng mục (ví dụ "Uống nước, 5 trên 8 ly, chưa đạt"), và bảng thay thế của biểu đồ. [M]
- AC-50: Mọi vùng chạm tối thiểu 48×48 dp. Ở cỡ chữ hệ thống 200%, các màn chính không bị cắt chữ hay chồng chữ. Tương phản chữ đạt tối thiểu 4,5:1 (chữ thường) và 3:1 (chữ lớn, icon) ở cả giao diện sáng và tối. Trạng thái không chỉ phân biệt bằng màu mà có thêm icon hoặc chữ. [M]

### F-14 · Quyền riêng tư và thông tin pháp lý trong app
- AC-51: Màn "Giới thiệu" có phiên bản, liên kết chính sách quyền riêng tư, email báo lỗi bảo mật và danh sách giấy phép nguồn mở. [M]
- AC-52: "Xóa toàn bộ dữ liệu" trong Cài đặt xóa hết dữ liệu, hủy mọi giờ nhắc và làm trống widget, sau xác nhận hai bước. Mở lại app thì như mới cài. [T]
- AC-53: Manifest của bản phát hành không có quyền INTERNET. App không gửi dữ liệu đi đâu. Mỗi quyền có trong manifest phải có lý do trong mục 5. [T: kiểm manifest đã build]

## 4. Ngoài phạm vi (cố ý KHÔNG làm ở bản đầu)
- (Đổi 2026-11-04) Bản iOS đã được đưa vào v1, xem D-001 và D-010. Chuông toàn màn hình chỉ có trên Android; iOS dùng thông báo time-sensitive.
- Tài khoản, đăng nhập, máy chủ, đồng bộ đám mây (HabitNow có sao lưu đám mây ở bản Premium; mình chỉ có file sao lưu).
- Gói Premium, quảng cáo, mua trong app, analytics, SDK báo crash.
- Mẫu thói quen có sẵn và thử thách (challenges), chia sẻ lên mạng xã hội, bạn bè, bảng xếp hạng.
- Đồng hồ thông minh (Wear OS), đồng bộ Google Calendar, nhắc theo vị trí, AI gợi ý thói quen.
- Mở khóa bằng vân tay hoặc khuôn mặt.

## 5. Ràng buộc mobile
- Hệ điều hành: Android. minSdk theo mặc định của Flutter 3.47.8 (minSdk 24 ở APP-001, xác nhận lại khi khởi tạo). targetSdk theo yêu cầu hiện hành của Google Play (P-06).
- Offline: toàn bộ app chạy không cần mạng, không có tính năng nào gọi mạng. Dữ liệu ghi xuống máy ngay khi chấm hoặc lưu.
- Quyền thiết bị (chỉ xin khi người dùng bật tính năng cần quyền đó, và giải thích trước; L-010):
  - Thông báo (`POST_NOTIFICATIONS`, Android 13 trở lên): để nhắc giờ và báo hết giờ Pomodoro. Xin khi người dùng đặt giờ nhắc đầu tiên hoặc bấm giờ lần đầu.
  - Báo thức chính xác (`SCHEDULE_EXACT_ALARM` hoặc `USE_EXACT_ALARM`, chọn ở G4 sau khi tra chính sách Google Play hiện hành): để nhắc đúng giờ.
  - Thông báo toàn màn hình (`USE_FULL_SCREEN_INTENT`): chỉ dùng cho chuông báo thức. Android 14 trở lên có thể phải xin người dùng cấp trong cài đặt.
  - Chạy khi khởi động máy (`RECEIVE_BOOT_COMPLETED`): để đặt lại giờ nhắc sau khi bật lại máy. Không cần hỏi người dùng.
  - Rung (`VIBRATE`): cho chuông báo thức.
  - KHÔNG xin quyền bộ nhớ, vị trí, danh bạ, camera hay micro.
- Màn hình: chiều rộng nhỏ nhất 360 dp, chỉ màn hình dọc.
- Pin: không có vòng lặp chạy nền. Nhắc giờ dùng lịch báo thức của hệ thống, Pomodoro tính theo mốc thời gian (AC-36). Không dùng dịch vụ chạy nền liên tục (foreground service), trừ khi G6 chứng minh là cần, khi đó phải ghi D-xxx và khai báo với Google Play.

## 5b. Yêu cầu phi chức năng
Ngưỡng dưới đây là đề xuất của Claude, người dùng chỉnh khi duyệt. Máy đo chuẩn: Galaxy A13 (SM-A135F, Android 14) đã dùng cho APP-001.
- Hiệu năng: mở nguội tới màn Hôm nay ≤ 2 giây (trung vị 5 lần, bản release). Chấm một mục thấy đổi trạng thái ≤ 100 ms. Với 50 thói quen và 3 năm lịch sử, màn Thống kê mở ≤ 1 giây, cuộn danh sách không có khung hình nào trên 32 ms trong Flutter DevTools (bản profile).
- Nhắc giờ: 20 lần nhắc thử trên máy thật thì 20 lần đến đúng giờ, lệch không quá 1 phút, kể cả khi máy khóa màn hình hơn 30 phút.
- Pin và bộ nhớ: không có tác vụ nền ngoài báo thức hệ thống và cập nhật widget. Không mở app trong 24 giờ, chỉ có 10 lần nhắc, thì app tiêu hao ≤ 1% pin theo màn pin của Android. Bộ nhớ ≤ 200 MB.
- Dung lượng: APK cho một kiến trúc ≤ 30 MB.
- Khả năng truy cập: mục tiêu WCAG 2.2 AA (AC-49, AC-50).
- Ổn định: tỉ lệ người dùng không crash ≥ 99,5% theo Android vitals của Play Console, xem mỗi tuần trong tháng đầu sau phát hành.
- Toàn vẹn dữ liệu: mọi lần ghi nằm trong một giao dịch cơ sở dữ liệu. Tắt app đột ngột thì không mất kết quả đã chấm (AC-12).

## 5c. Thị trường và tiêu chuẩn bán app
Đã điền mục 1 của `docs/COMPLIANCE.md`: Việt Nam và toàn cầu (nhóm A và B, chưa mở nhóm C), miễn phí, không tài khoản, không SDK, dữ liệu chỉ nằm trên máy. Các mục cần xây tính năng: F-04 và D-11 (xin quyền đúng lúc), F-13 và A-01 (khả năng tiếp cận, ngôn ngữ), F-14 (chính sách quyền riêng tư, xóa dữ liệu, kênh báo lỗ hổng, giấy phép nguồn mở, không có quyền INTERNET).

## 6. Dữ liệu
- Lưu ở đâu: SQLite trong bộ nhớ riêng của app trên máy. Không có máy chủ, không đồng bộ. Chỉ sao lưu khi người dùng tự xuất file (F-11).
- Dữ liệu nhạy cảm: tên thói quen có thể lộ thông tin sức khỏe (ví dụ "Uống thuốc huyết áp"), nhưng chỉ nằm trên máy. Các lớp bảo vệ:
  - Bộ nhớ riêng của app.
  - Khóa PIN tùy chọn.
  - Khi bật khóa thì ẩn tên mục trên màn khóa và widget (AC-41, AC-46).
  - `allowBackup=false` để dữ liệu không tự lên đám mây mà người dùng không biết.
  - App ghi rõ rằng file sao lưu không được mã hóa.
- Thu thập dữ liệu: nhà phát triển KHÔNG thu thập gì. Data safety khai "không thu thập, không chia sẻ". Vẫn cần chính sách quyền riêng tư công khai.

## 7. Rủi ro và điều chưa biết
- Pháp lý: làm chức năng giống HabitNow là được, nhưng tên, icon, giao diện, chữ trong app và mô tả store không được sao chép. Phải rà lại trước khi phát hành. Tên "DailyLoop" chưa được tra trùng nhãn hiệu hay trùng tên trên Google Play, cần tra trước khi phát hành.
- Nhắc giờ trên Android là phần rủi ro nhất:
  - Chế độ tiết kiệm pin (Doze) và trình tối ưu pin của từng hãng (Samsung, Xiaomi, Oppo) có thể làm trễ hoặc chặn báo thức.
  - Google Play giới hạn ai được dùng `USE_EXACT_ALARM` và `USE_FULL_SCREEN_INTENT`.
  - Phải tra chính sách Google Play và tài liệu Android hiện hành ở G4 (CHƯA kiểm chứng), và thử trên máy thật (L-003).
  - Nếu không được dùng thông báo toàn màn hình, chuông báo thức chỉ còn là thông báo có âm thanh.
- Widget phải viết thêm mã Android gốc (Kotlin) qua gói cầu nối, và cập nhật widget bị Android giới hạn tần suất. Chưa kiểm chứng gói nào chạy tốt với Flutter 3.47.8.
- Lịch lặp và chuỗi ngày có nhiều trường hợp biên: năm nhuận, ngày 31, đổi múi giờ, đổi ngày đầu tuần, sửa lịch giữa chừng. Cần nhiều test tự động.
- Mất máy là mất dữ liệu nếu người dùng chưa xuất file. Quên PIN là không vào lại được (AC-47).
- Tài khoản Google Play cá nhân mới phải closed test với 12 người trong 14 ngày (P-09).
- Người dưới 18 tuổi có thể dùng; app không thu dữ liệu và không có tương tác xã hội. Người dùng cần quyết có tích hợp Play Age Signals hay không (D-12).
- Bán ở EU: chưa rõ app miễn phí của cá nhân có thuộc phạm vi CRA không, cần luật sư xác nhận (S-06).
- Phạm vi lớn: 14 tính năng, chia thành 8 giai đoạn (xem APP.md).

## 8. Tiêu chí hoàn thành bản đầu
- F-01 tới F-14 đạt toàn bộ AC, có biên bản thử trên ít nhất một máy Android thật (Galaxy A13). Nhắc giờ phải thử thêm trên một máy của hãng khác nếu có.
- `flutter analyze` không lỗi, `flutter test` đạt.
- `docs/COMPLIANCE.md` không còn dòng "chưa" ở các mục áp dụng cho Android và các thị trường mở bán.
- Đã closed test theo P-09 và sửa xong lỗi chặn trước khi mở bán.
