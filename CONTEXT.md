# A003-dailyloop · DailyLoop — CONTEXT (glossary)

> Chỉ là bảng thuật ngữ nghiệp vụ. Không ghi chi tiết kỹ thuật ở đây.
> Thuật ngữ chuẩn dùng tiếng Anh trong code; cột VI là chữ hiển thị/tài liệu. Chữ hiển thị thật nằm ở `lib/l10n/*.arb`.

## Thuật ngữ

| Term (code) | VI | Định nghĩa | Tránh dùng |
|---|---|---|---|
| **Activity** | Mục | Thứ xuất hiện trên màn Hôm nay: một **Habit** hoặc một **Task**. Cùng có tên, danh mục, ưu tiên, lịch, giờ nhắc. | "item" lẫn lộn với "mục con" (dùng *Subitem*), "entry" |
| **Habit** | Thói quen | Mục **lặp lại**, có cách theo dõi (**Evaluation**), có chuỗi/điểm/tỉ lệ, lưu trữ được. | "routine", "goal" |
| **Task** | Việc (cần làm) | Mục thường làm **một lần** (có thể lặp lại, chỉ Có/Không), ngày/giờ tùy chọn, có thể quá hạn, **không** có chuỗi, không lưu trữ (chỉ xóa). | "todo", "reminder" (để dành cho **Reminder**) |
| **Subitem** | Mục con | Một dòng trong **Checklist** (thói quen) hoặc việc con của một Task (chỉ để đánh dấu, không quyết định xong). 1–20 mục. | "subtask" dùng chữ "Việc con" trong UI Task |
| **Schedule** | Lịch lặp | Quy tắc ngày nào một mục **đến hạn**: mỗi ngày · các thứ trong tuần · các ngày trong tháng · cứ N ngày · K lần mỗi tuần/tháng (Task thêm "Không lặp lại"). | "frequency", "recurrence" |
| **Due day** | Ngày đến hạn | Ngày mà Schedule nói mục phải làm. Là đơn vị tính chuỗi (với "K lần": tuần/tháng là đơn vị). | "scheduled day" |
| **effectiveFrom** | Hiệu lực từ ngày | Ngày một dòng lịch bắt đầu có hiệu lực. Đổi lịch = thêm dòng mới từ hôm nay; ngày cũ giữ lịch cũ nên lịch sử không đổi. | "version", "revision" |
| **Entry** | Kết quả ngày | Kết quả của một mục trong **một ngày** (tối đa một dòng/mục/ngày): giá trị hoặc đã/không bỏ qua. Lưu ngay khi chấm. | "log", "record" (dùng "ghi kết quả" cho hành động) |
| **Evaluation** | Cách theo dõi | Cách một Habit đo kết quả: **Yes/No** (Có hoặc không) · **Quantity** (Số lượng) · **Timer/Duration** (Thời gian, phút) · **Checklist** (Danh sách con). Task luôn là Yes/No. Trong code: `yesNo`, `quantity`, `duration`, `checklist`. | "type", "mode" |
| **Target** | Mục tiêu | Số cần đạt của Quantity (đơn vị tùy ý) hoặc Time (phút). | "goal" (trùng nghĩa rộng) |
| **Unit** | Đơn vị | Chữ đi kèm số lượng (ly, trang, km…), tối đa 20 ký tự. Time luôn là "phút". | "measure" |
| **Condition** | Điều kiện | **At least** (Ít nhất) · **Exactly** (Đúng bằng) · **At most** (Nhiều nhất): cách so giá trị với Target. At most mà chưa ghi gì thì vẫn **đạt**. | "operator", "comparison" |
| **Achieved** | Đạt | Kết quả **tính ra** từ giá trị và Condition (không lưu). Hiện là "Đạt"; ngược lại "Chưa đạt". Không dùng "thất bại". | "success/fail", "completed" (với Habit), "missed" trên UI |
| **Skip** | Bỏ qua | Người dùng đánh dấu một ngày của Habit là "bỏ qua": không tính đạt cũng không tính lỡ, **không đứt Streak**, hoàn tác được. | "pause", "freeze", "cancel" |
| **Overdue** | Quá hạn | Chỉ với **Task** một lần: ngày đã qua mà chưa xong; nằm đầu màn Hôm nay với nhãn "Quá hạn · N ngày" cho tới khi xong, đổi ngày hoặc xóa. Habit **không** có quá hạn. | "late", "missed task" |
| **Unscheduled** | Chưa xếp lịch | Task một lần không có ngày. Kết quả ghi vào ngày đánh xong. | "inbox", "someday" |
| **Streak** | Chuỗi ngày | Số **đơn vị đến hạn** liên tiếp đã đạt tới hôm qua (+ hôm nay nếu đã đạt). Ngày không đến hạn và ngày Skip không làm đứt. Hiện kèm đơn vị: ngày/tuần/tháng. Có **chuỗi hiện tại** và **chuỗi dài nhất**. | "combo", "chain" (trừ khi nói thân mật); không dùng ngôn ngữ "mất chuỗi" |
| **Habit score** | Điểm (thói quen) | 0–100, đạt gần đây trọng số cao hơn (D-008); cùng dữ liệu cho cùng điểm. Là chỉ số "êm" đi cùng Streak. | "rating", "level", "XP" |
| **Success rate** | Tỉ lệ thành công | Đơn vị đạt ÷ đơn vị đã kết thúc (bỏ Skip, bỏ hôm nay nếu chưa ghi), cho 7 ngày, 30 ngày, từ đầu. Chưa có dữ liệu thì "Chưa có". | "completion %", "accuracy" |
| **Reminder** | Giờ nhắc | Một giờ trong ngày mà mục sẽ nhắc; 0–5 giờ/mục; chỉ vào ngày đến hạn; xong trước giờ thì các giờ còn lại của ngày không nhắc. Có hai kiểu. | "alert", "notification" (là kiểu), "push" (không có máy chủ) |
| **Notification** (kind) | Thông báo | Kiểu Reminder thường; có nút **Xong** cho Có/Không và Việc. | "banner" |
| **Alarm** (kind) | Chuông báo thức | Kiểu Reminder có âm lặp: **Android** hiện màn **toàn màn hình** (Xong / Hoãn 10 phút / Tắt, tự dừng sau 5 phút); **iOS** là thông báo **time-sensitive** có nút Xong/Hoãn, không có màn toàn màn hình. | "ringer", "wake-up" |
| **Snooze** | Hoãn 10 phút | Hẹn lại một Alarm sau 10 phút; hủy nếu mục đã xong hoặc bị xóa. | "postpone" |
| **Pomodoro session** | Phiên Pomodoro | Một lần chạy đồng hồ gồm các giai đoạn **Focus → Short break → Long break** (mặc định 25/5/15 phút, nghỉ dài sau 4 phiên). Tính theo mốc bắt đầu đã lưu. Có thể liên kết một Habit kiểu Time để cộng phút. | "timer" (nghĩa rộng), "round" |
| **Credit** | Cộng phút | Đưa số phút của phiên Focus vào Entry hôm nay của Habit Time đã liên kết: dừng giữa chừng cộng số phút đã chạy; hết giờ cộng đủ một lần; nghỉ không cộng. | "log time" |
| **Category** | Danh mục | Nhóm có tên, **icon** và **màu** để lọc Hôm nay/Thói quen. 8 mặc định theo ngôn ngữ; thêm/sửa/xóa được; xóa khi đang dùng thì chuyển mục sang danh mục khác hoặc "Không có danh mục". | "tag", "folder", "group" |
| **Archive** | Lưu trữ | Ẩn một Habit khỏi Hôm nay nhưng giữ cả lịch sử trong "Đã lưu trữ"; khôi phục được. Khác **Delete**. | "hide", "delete", "pause" |
| **Delete** | Xóa | Xóa mục kèm toàn bộ lịch sử, sau xác nhận; có thanh "Đã xóa · Hoàn tác" 5 giây. | "remove" (dùng cho mục con/giờ nhắc) |
| **Today** | Hôm nay | Ngày hiện tại theo giờ địa phương của máy, 00:00–23:59; luôn lấy từ một nguồn giờ duy nhất. Cũng là tên màn hình chính. | "now", "current day" |
| **Day strip** | Dải ngày | Hàng 7 ngày ngang ở đầu màn Hôm nay (3 ngày trước, 3 ngày sau ngày đang chọn). Ngày quá khứ sửa được, **ngày tương lai chỉ xem**. | "week bar", "date picker" (là hộp riêng) |
| **Widget** | Widget "Hôm nay" | Danh sách mục đến hạn trên màn hình chính (Android 4×2 trở lên; iOS small/medium/large); chạm ô để đánh xong mục Có/Không. Bật PIN thì chỉ hiện "Còn N mục". | "tile", "glance" |
| **PIN lock** | Khóa PIN | Khóa tùy chọn 4 số: hỏi khi mở app và khi quay lại sau hơn 1 phút ở nền; ẩn tên mục trên thông báo/màn khóa/widget. Quên PIN chỉ có cách xóa toàn bộ dữ liệu. | "passcode", "password", "biometric" (ngoài phạm vi) |
| **Backup** | Bản sao lưu | File `.dailyloop` (JSON, có số phiên bản và mã toàn vẹn, **không mã hóa**) chia sẻ qua bảng chia sẻ của hệ điều hành. **Restore** thay toàn bộ dữ liệu sau xác nhận; file hỏng thì giữ nguyên dữ liệu. | "export" (nghĩa rộng), "cloud sync" |
| **CSV export** | Xuất CSV | File lịch sử (ngày, tên mục, loại, kết quả, giá trị) mở được bằng Excel/Sheets, chữ Việt không lỗi. Không dùng để khôi phục. | "report" |
| **Wipe** | Xóa toàn bộ dữ liệu | Xóa hết dữ liệu, hủy giờ nhắc, làm trống widget, sau xác nhận hai bước; app như mới cài. | "reset" (dễ hiểu là chỉ cài đặt) |
| **Priority** | Ưu tiên | Thấp / Thường / Cao; dùng để sắp xếp (sau giờ nhắc) và có thể hiện dấu "Cao". | "importance", "urgency" |
| **Welcome** | Màn chào | ≤ 3 trang, bỏ qua được, **không xin quyền nào**; chỉ lần mở đầu (và sau khi xóa toàn bộ dữ liệu). | "onboarding" trong tài liệu (UI dùng "Welcome") |
