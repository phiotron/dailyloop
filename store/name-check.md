# Tra trùng tên "DailyLoop" — kết quả (2026-11-04)

> **Cập nhật 2026-11-04:** người dùng đã loại cả DailyLoop và **Streakloom** (App Store đã có app "Streakloom" của Austin Michie, id6767362848). Ứng viên tên tiếng Anh mới và kết quả tra: [`store/name-candidates.md`](name-candidates.md) (khuyến nghị #1 Orbiday). Bảng "Tên dự phòng" bên dưới là bản cũ — Streakloom không còn dùng được.

## Kết luận (đọc phần này là đủ)
**"DailyLoop" đang bị trùng nặng, cùng loại app, trên cả hai store.** Đã có **ít nhất 3 app thói quen/việc hằng ngày tên DailyLoop / Daily Loop trên
Google Play** và **1 app tên "DailyLoop – Build Routines" trên App Store** (dạng thói quen, miễn phí, iPhone). Một trong số đó
(ByteNest Labs) còn có đúng bộ tính năng như app mình: thói quen + việc + nhắc + chuông toàn màn hình + chuỗi ngày.
- **Rủi ro cao nhất:** nhầm lẫn thương hiệu/khiếu nại (người dùng cài nhầm, đánh giá lẫn lộn, bên kia gửi khiếu nại "tên gây nhầm lẫn"
  hoặc báo vi phạm nhãn hiệu cho Google/Apple khiến app bị gỡ sau khi đã mất 14 ngày closed test). Play **cho phép** nhiều app trùng tên
  (đã có 3 app cùng tên) nên Play Console sẽ không chặn; App Store Connect chỉ chặn trùng **nguyên tên** (đang là
  "DailyLoop – Build Routines"), nên tên như "DailyLoop: Habits & To-Do" nhiều khả năng vẫn tạo được — nhưng "tạo được" ≠ "an toàn".
- **Khuyến nghị của phiên này: ĐỔI TÊN thương hiệu** trước khi tạo app trên Play Console/App Store Connect (đổi sau khi tạo app còn
  làm được tên hiển thị nhưng tên gói `com.phiotron.dailyloop` thì không đổi được; tên gói không hiện với người dùng nên không sao).
  Nếu người dùng vẫn muốn giữ "DailyLoop" → xem mục "Nếu giữ DailyLoop" (giảm rủi ro, không loại bỏ).
- **Chưa tra được** (cần người dùng hoặc luật sư): cơ sở dữ liệu nhãn hiệu chính thức (WIPO Global Brand Database, Cục Sở hữu trí tuệ VN,
  USPTO, EUIPO) — công cụ của phiên này chỉ tìm được qua trang tổng hợp, không đủ để kết luận "không có nhãn hiệu".
  Cũng chưa kiểm tên miền (dailyloop.com/.app/.vn…). Đây không phải tư vấn pháp lý.
- Ảnh hưởng tới các phiên khác: tên hiển thị `DailyLoop` đang nằm trong `product.md`, mockup Claude Design (phiên #2), `android:label`
  (`AndroidManifest.xml`), iOS `CFBundleDisplayName` (đang là "Dailyloop" ở khung iOS thô). **Quyết tên SỚM, trước khi gửi Claude Design**
  để khỏi làm lại logo/mockup. Mọi chỗ tên trong `store/` và `docs/legal/` viết sao cho **đổi một lần** (xem "Cách đổi tên" dưới).

## Bằng chứng (tra 2026-11-04; có thể đã đổi — mở lại link khi quyết)
### Google Play (tìm "DailyLoop" trong Play Store web)
| App | Nhà phát triển | Gói | Loại / ghi chú |
|---|---|---|---|
| **DailyLoop: Habits & Reminders** | ByteNest Labs | `com.dailyloop.app` | Thói quen + việc + nhắc + chuông kiểu cuộc gọi toàn màn hình + vườn ảo + thách đấu bạn bè. 10+ lượt tải, có quảng cáo. **Trùng nặng nhất** (cùng tên, cùng loại, cùng tính năng nhắc toàn màn hình) |
| **DailyLoop – habits & routines** | VikramDev | `com.vikramji283.dailyloop` | Lịch thói quen, nhắc, chuỗi ngày, thống kê, có "Tasks & Events". 100+ lượt tải, khai Data safety "không thu thập" như mình. Danh mục Productivity |
| **Daily Loop** | Try Try Limited | `com.dalop.dailyloop` | Thói quen offline, nhắc, chuỗi. 10K+ lượt tải, có quảng cáo. Danh mục Personalization |
| Daily Loop – Daily App Check | Dalgureum Lab | `dev.dalgureum.dailyloop` | Tên gần giống, khác loại (kiểm tra app hằng ngày) |
- Tên gần: Dayloop – Hábitos Diarios (Codeamus), HabitLoop (Adobix Tech và vài app khác), LoopQue: Smart Reminders.
- Link tra: `https://play.google.com/store/search?q=DailyLoop&c=apps`

### App Store
| App | Nhà phát triển | Ghi chú |
|---|---|---|
| **DailyLoop – Build Routines** (id6747970681) | 圣财 卢 | Thói quen/routine, miễn phí, chỉ iPhone, hạng mục Utilities, 4+, "Data Not Collected". Link: `https://apps.apple.com/us/app/dailyloop-build-routines/id6747970681`. Trùng nguyên tên + cùng loại |
- Tên gần: Dayloop: Photo Journal / Dayloop: Timelapse Diario (khác loại), HabitLoop (nhiều app), TaskLoop, Busy Loop.

### Nhãn hiệu / web
- Không thấy đăng ký nhãn hiệu "DAILYLOOP"/"DAILY LOOP" qua trang tổng hợp, nhưng có đơn **DAYLOOP** (USPTO serial 99559611, OptimAIze LLC,
  nộp 2025-12-21, nhóm 42 — phần mềm, đang chờ xét). Khác một chữ cái, cùng ngành, dễ bị viện dẫn "gần giống".
- Không có kết luận về tên miền. Cần kiểm trực tiếp trước khi quyết.

## Tên dự phòng (≤ 30 ký tự, đã tra thô trên Google Play web và web; App Store chỉ tra được qua tìm kiếm web, không xác nhận đầy đủ)
| # | Tên (hiện trên store) | Số ký tự | Tra Play 2026-11-04 | Ghi chú |
|---|---|---|---|---|
| 1 | **Nhịp Ngày: Thói Quen & Việc** | 27 | Không có app trùng "Nhịp Ngày" (chỉ có app khác tên, ví dụ "Nhịp sinh học…") | Hợp thị trường Việt Nam ("nhịp" = loop/rhythm của ngày). Tên tiếng Anh cho store EN: `Nhip Ngay: Habits & To-Do` (25) hoặc giữ nguyên bản có dấu |
| 2 | **Streakloom: Habits & To-Do** | 26 | Không có kết quả "Streakloom" | Tên ghép tự đặt, tiếng Anh, dễ đăng ký nhãn hiệu hơn từ thông dụng. Chưa tra App Store/nhãn hiệu |
| 3 | **Ngày Đều: Thói Quen & Việc** | 26 | Không có app tên "Ngày Đều" | Nghĩa "ngày nào cũng đều đặn"; hơi chung → dễ trùng sau này, tra lại trước khi dùng |
- **Đã loại** (có app trùng trên Play): Streakwell, Dayrhythm, Dayweave, Daynest, HabitRail, Streakly.
- Mọi tên: kiểm lại **ngay trước khi tạo app** (tên bị chiếm hằng ngày) và tra WIPO/Cục SHTT. Ghi tên chốt vào `APP.md` (phiên điều phối).
- Tên dưới icon (`android:label`, `CFBundleDisplayName`) nên ngắn: "Nhịp Ngày" / "Streakloom" / "DailyLoop".

## Nếu giữ DailyLoop (phương án giảm rủi ro)
1. Dùng tên **dài có mô tả**: Play `DailyLoop: Habits & To-Do` / App Store `DailyLoop – Habits & Tasks` (khác "Build Routines"), icon và màu **khác hẳn**
   icon 3 app trên (người dùng xem icon của họ trên Play/App Store trước khi chốt icon mình).
2. Nhà phát triển khác nhau nên không thể nhầm là "cùng một app"; nhưng không có gì ngăn họ khiếu nại. Chấp nhận rủi ro bị gỡ/đổi tên bắt buộc.
3. Không dùng `dailyloop` trong tên miền/trang chính sách trước khi tra tên miền; không ghi "official".
4. Quyết định ghi vào `docs/DECISIONS.md` (phiên điều phối) kèm lý do chấp nhận rủi ro.

## Cách đổi tên (một lần)
Chỗ phải đổi khi chốt tên mới (phiên điều phối / code làm, phiên này không đổi code):
- `store/listing.md`, `store/app-store.md`: mục "Tên" (bảng có sẵn ô thay) · `docs/legal/*`: dòng đầu và chữ "DailyLoop" (tìm–thay)
- `AndroidManifest.xml` `android:label` · iOS `CFBundleDisplayName` · chuỗi trong `lib/l10n/*.arb` ("appName", màn chào, Giới thiệu)
- `product.md`, mockup Claude Design, icon/feature graphic · tiêu đề tab trình duyệt của trang chính sách
- Giữ nguyên: bundle ID `com.phiotron.dailyloop`, tên repo, tên thư mục `A003-dailyloop` (không hiện với người dùng).
