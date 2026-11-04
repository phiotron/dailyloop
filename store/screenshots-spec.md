# Quy cách ảnh chụp, icon và ảnh bìa store — DailyLoop (Google Play + App Store)

Soạn 2026-11-04. **Chụp thật ở phiên điều phối #3 (phiên con "ảnh store") với UI mới** của phiên #2 (Claude Design) — chưa chụp bây giờ vì UI sẽ đổi.
Mẫu: `apps/A002-vigon/store/screenshots-spec.md`. Kiểm lại bảng kích thước của Google/Apple ngày chụp (đổi theo năm); ghi ngày kiểm ở cuối file.

## 1. Kích thước và số lượng bắt buộc
### Google Play
| Thành phần | Bắt buộc | Quy cách |
|---|---|---|
| Ảnh chụp điện thoại | **2–8 ảnh** mỗi ngôn ngữ (en-US và vi-VN mỗi ngôn ngữ một bộ nếu chữ trong ảnh khác nhau) | PNG hoặc JPEG 24-bit, **không kênh alpha**, ≤ 8 MB; cạnh 320–3840 px; cạnh dài ≤ 2 × cạnh ngắn. Muốn đủ điều kiện được Play gợi ý/quảng bá: **≥ 4 ảnh, ≥ 1080 px** cạnh ngắn |
| Kích thước chọn | | **1080 × 2160** (2:1) hoặc 1080 × 1920 (9:16) nếu thêm dải chữ chú thích |
| Icon | Có | 512 × 512 PNG 32-bit, ≤ 1 MB |
| Ảnh bìa (feature graphic) | Có | 1024 × 500 PNG hoặc JPEG, không alpha |
| Máy tính bảng 7"/10", Chromebook, Wear, TV | Không bắt buộc | Bản 1 chỉ nhắm điện thoại (SPEC mục 5: màn dọc, ≥ 360 dp) → bỏ. **Lưu ý:** targetSdk 36 làm Android bỏ qua khóa màn dọc trên màn hình lớn/gập → test bố cục máy tính bảng ở phiên #2; nếu xấu thì giữ nguyên không đăng ảnh tablet, Play vẫn cho cài |
| Video quảng bá | Không | Bỏ |

### App Store (iPhone)
| Thành phần | Bắt buộc | Quy cách |
|---|---|---|
| iPhone **6.9"** | **Có — 1 đến 10 ảnh** mỗi localization | Dọc **1320 × 2868** (chọn cỡ này), hoặc 1290 × 2796 / 1260 × 2736. PNG/JPEG, không alpha, RGB |
| iPhone 6.5" | Chỉ khi không có bộ 6.9" | **Bỏ** — có 6.9" là đủ, App Store Connect tự thu nhỏ cho máy nhỏ hơn |
| iPad 13" | **Chỉ khi app hỗ trợ iPad** | **Phải kiểm `ios/`**: khung iOS thô lúc viết (2026-11-04) đặt `TARGETED_DEVICE_FAMILY = "1,2"` (có iPad). Khuyến nghị: **đặt iPhone-only (`= 1`)** để khỏi phải chụp/thử bố cục iPad (SPEC: chỉ màn dọc). Nếu giữ iPad thì BẮT BUỘC thêm bộ ảnh iPad 13" **2064 × 2752** (cỡ 2048 × 2732 cũng được) và thử bố cục |
| Icon App Store | Có | 1024 × 1024 PNG, không alpha, không bo góc |
| App Preview (video) | Không | Bỏ |

Thứ tự ảnh: 3 ảnh đầu hiện ngay trong kết quả tìm kiếm → đặt 3 ảnh mạnh nhất (Hôm nay, Tạo thói quen, Nhắc giờ) lên đầu.

## 2. Bộ ảnh — 8 khung (cùng nội dung cho hai store, mỗi ngôn ngữ một bộ)
Chú thích phải **đúng tính năng thật** (SPEC). Hai chỗ khác nhau giữa nền tảng được tô đậm.
| # | Màn | Trạng thái cần dựng (dữ liệu mẫu ở mục 3) | Chú thích vi | Chú thích en |
|---|---|---|---|---|
| 1 | **Hôm nay**, giao diện sáng | Dải ngày đang ở 24/11, ~6 thói quen + 2 việc, vài mục đã xong, 1 việc "Quá hạn · 1 ngày" | Một danh sách cho cả ngày | One list for your whole day |
| 2 | **Tạo thói quen** | Chọn kiểu theo dõi (Có/Không, Số lượng, Thời gian, Danh sách con) và lịch lặp "Thứ 2–6"; đủ thấy 4 kiểu | Theo dõi theo cách của bạn | Track it your way |
| 3 | **Nhắc giờ** | **Android:** màn chuông toàn màn hình trên màn khóa ("Uống nước", nút Xong / Hoãn 10 phút / Tắt). **iOS:** màn đặt giờ nhắc với kiểu "Chuông" và các giờ nhắc (iOS không có màn toàn màn hình → không dựng khung chuông) | Nhắc đúng giờ, chạm là xong | Reminded right on time |
| 4 | **Chuỗi ngày + lịch tháng** | Chi tiết "Đọc sách": chuỗi 34, dài nhất 34, lịch tháng 11 có ô đạt/bỏ qua/chưa đạt, điểm ~85 | Giữ chuỗi ngày của bạn | Keep your streak going |
| 5 | **Thống kê** | Tab Thống kê: biểu đồ 7/30 ngày, 3 thói quen chuỗi dài nhất; hoặc biểu đồ cột "Uống nước" có đường mục tiêu 8 ly | Thấy rõ tiến bộ mỗi tuần | See your progress |
| 6 | **Pomodoro** | Đồng hồ đang chạy "Đọc sách" ở 17:42 còn lại của phiên 25 phút, "Phiên 2/4" | Tập trung với Pomodoro | Focus with Pomodoro |
| 7 | **Widget "Hôm nay"** | Màn hình chính **thật** (launcher mặc định, hình nền trung tính) có widget 4×2 hiện 4–5 mục, vài mục đã tick. **iOS:** chỉ dựng nếu widget iOS có trong bản 1 (APP.md: phần cắt đầu tiên); nếu widget iOS không tick được thì chú thích en/vi chỉ nói "xem hôm nay ngay trên màn hình chính" | Xem hôm nay ngay trên màn hình chính (Android: tick không cần mở app) | Today at a glance on your home screen |
| 8 | **Riêng tư + sao lưu**, giao diện tối | Cài đặt: "Khóa bằng mã PIN", "Xuất bản sao lưu", "Xuất CSV", "Xóa toàn bộ dữ liệu"; chủ đề tối | Dữ liệu chỉ ở trên máy bạn | Your data stays on your phone |
Play dùng 8 ảnh; App Store 7–8 ảnh (bỏ khung 7 nếu widget iOS không có). Chú thích (nếu dùng) đặt trong dải màu nền thương hiệu phía trên ảnh màn hình (màu và phông lấy từ design system của phiên #2), không thêm khung máy của hãng (tránh hình iPhone/Android có thương hiệu),
không chữ "Số 1", "Tốt nhất", "Miễn phí" trong ảnh, giá, hay so sánh/nhắc tên app khác. Ảnh phải là **UI thật của app** (App Review 2.3.3). Không chú thích hứa điều app không làm ("đồng bộ đám mây", "mã hóa", "AI").

## 3. Kịch bản dữ liệu mẫu (không dùng dữ liệu thật của ai)
Ngày trên máy chụp: **2026-11-24 (Thứ Ba)**. Nạp bằng file sao lưu mẫu `.dailyloop` cho mỗi ngôn ngữ rồi khôi phục vào máy/simulator chụp (cần G7 xong; sinh file mẫu bằng test hoặc script ở phiên ảnh store — ghi rõ khi giao việc).
Không dùng tên người thật, không email, không thương hiệu (ví dụ không tên ứng dụng, ngân hàng, hãng thuốc). Tránh ví dụ y tế (thuốc, huyết áp): dùng nước, đọc sách, vận động.

**Bộ tiếng Việt**
| Mục | Kiểu | Lịch | Trạng thái 24/11 | Ghi chú |
|---|---|---|---|---|
| Uống nước | Số lượng, ít nhất 8 ly | Mỗi ngày | 5/8 ly | Chuỗi 12 ngày, dài nhất 21; nhắc 07:30 / 10:30 / 15:00 |
| Đọc sách | Thời gian, ít nhất 30 phút | Mỗi ngày | 20/30 phút (đang chạy Pomodoro) | Chuỗi 34 ngày; lịch tháng nhiều ô xanh, 1 ô bỏ qua, 1 ô chưa đạt |
| Tập thể dục | Có/Không | Mỗi ngày | Xong | Chuỗi 6 |
| Học tiếng Anh | Danh sách con (3 mục: Từ vựng, Nghe, Viết) đạt khi xong 2 | Thứ 2–6 | 2/3 mục → đạt | |
| Viết nhật ký | Có/Không | Mỗi ngày | Chưa xong | Nhắc 21:30 kiểu Chuông |
| Dọn bàn làm việc | Có/Không | Cứ 3 ngày một lần | Chưa xong | |
| Việc: Gửi báo cáo tuần | Việc 1 lần | 24/11 14:00 | Chưa xong | Ưu tiên cao |
| Việc: Mua quà sinh nhật | Việc 1 lần | 23/11 | **Quá hạn · 1 ngày** | |
**Bộ tiếng Anh:** dịch tương ứng — Drink water (5/8 glasses), Read (20/30 min), Exercise, Study English (Vocabulary, Listening, Writing), Journal, Tidy desk, Task: Send weekly report 14:00, Task: Buy birthday gift (Overdue · 1 day).
Danh mục: Sức khỏe, Học tập, Công việc, Tinh thần (có màu/icon). Ngày đầu tuần: Thứ Hai.
Kiểm trước khi chụp: không thông báo thật, giờ trên thanh trạng thái 9:41, pin đầy, sóng đầy, không thanh "Test nước" cũ (APP.md: dữ liệu thử còn trên máy Galaxy A13 → khôi phục sạch bằng bản sao lưu mẫu hoặc xóa dữ liệu trước).

## 4. Cách chụp (máy làm việc là Windows, không có iPhone)
- **Android:** máy thật Galaxy A13 (1080 × 2408) bản release, hoặc emulator Pixel 1080 × 2400; bật Demo mode thanh trạng thái (`adb shell settings put global sysui_demo_allowed 1` + lệnh demo) **chỉ khi người dùng cho phép dùng adb** (máy dùng chung; kiểm `mCurrentFocus` trước mỗi lần chạm). Cắt hoặc ghép vào khung 1080 × 2160 / 1080 × 1920 có dải chú thích (lần trước ở app khác bị cắt mất nút → ghép khung, không cắt). Khung 3 (màn chuông) chụp khi màn hình khóa bằng `adb exec-out screencap -p`.
- **iOS:** iOS Simulator trên GitHub Actions macOS runner, máy **iPhone 6.9"** (ví dụ "iPhone 17 Pro Max", 1320 × 2868): `xcrun simctl status_bar booted override --time 9:41 --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3`, khôi phục file mẫu (hoặc test tích hợp nạp dữ liệu mẫu), chụp `xcrun simctl io booted screenshot <file>.png`, tải về bằng artifact của workflow. Widget iOS trên simulator: thêm widget thủ công qua workflow/test UI (khó tự động) — nếu không làm được, bỏ khung 7 của iOS.
- Đặt tên: `store/screenshots/<platform>-<lang>/<nn>-<man>.png`, ví dụ `store/screenshots/ios-en/01-today.png`, `store/screenshots/android-vi/03-alarm.png`.

## 5. Brief icon + ảnh bìa (để người dùng nhờ Claude Design)
> Gửi nguyên đoạn tiếng Anh dưới đây cho Claude Design cùng `product.md`. **Chốt tên app trước** (`store/name-check.md`) rồi thay `[APP NAME]`.

```
Design the app icon and the Google Play feature graphic for "[APP NAME]", a free, offline habit-and-to-do planner for Android and iPhone.

Concept: "loop" = a daily rhythm that closes. Idea to explore: a single continuous ring or looping stroke that almost closes, with a small check mark or a dot where it closes, suggesting "one more day done". Calm, friendly, motivating; not childish, not corporate. One strong, simple shape that reads at 48 px.
Avoid: clock faces, bells, calendar grids, checklists with lines, flames (streak clichés), gradients with many colors, text/letters in the icon, and anything resembling other habit apps. Before finalizing, look at the icons that appear when searching "DailyLoop" and "habit tracker" on Google Play and make ours clearly different (different silhouette AND dominant color).
Palette: use the app's design system colors (primary + one accent) from the Hi-Fi mockups; icon needs strong contrast between the symbol and its background.

Deliverables
1. App icon, master 1024x1024 PNG, square, NO transparency, NO rounded corners (stores round it themselves), full-bleed background. Used for App Store (1024), Google Play (export 512x512 PNG 32-bit, keep a 10% margin of safe area) and as the Android adaptive-icon source.
2. Android adaptive icon layers: foreground 432x432 (symbol inside the central 264x264 safe circle) on a separate solid/simple background layer; plus a monochrome (single-color, transparent) version of the symbol for Android 13+ themed icons.
3. iOS: same master, also a dark-appearance variant and a tinted/monochrome variant (iOS 18+) if the symbol allows it.
4. Google Play feature graphic 1024x500 (PNG/JPEG, no alpha): the icon symbol plus the app name and ONE short tagline ("One list for your whole day"), large type, generous space; keep everything important inside the central 924x400 area (Play crops/overlays edges). Optional: one softly cropped phone screenshot of the Today screen on the right. No device brand frames, no badges, no "free", "#1", "best", prices, ratings, or store logos.
5. Make sure it looks right at 29, 40, 48, 60, 120 px and in light and dark launcher backgrounds. Export every PNG in sRGB.
```
Kích thước/độ an toàn khớp quy định hiện hành đã biết (Play icon 512 + feature graphic 1024×500; Apple icon 1024; Android adaptive 108 dp, vùng an toàn 66 dp — kiểm lại khi nhận file).
Sau khi có file: đặt vào `store/brand/` (icon-1024.png, icon-512.png, feature-1024x500.png, adaptive-foreground.png, adaptive-background.png, monochrome.png); việc đưa icon vào `android/`/`ios/` là của phiên code (không phải phiên store).

## 6. Kiểm sau khi chụp
- Kích thước đúng bảng mục 1 (`python -c "from PIL import Image; print(Image.open('x.png').size, Image.open('x.png').mode)"` — mode phải là RGB, không RGBA); không kênh alpha.
- Chữ trong ảnh khớp ngôn ngữ của trang store; ngày và số theo ngôn ngữ (AC-48).
- Không lộ nội dung không có trong app thật; không chú thích hứa điều app không làm; khung 3 Android/iOS khác nhau đúng như bảng; khung widget iOS khớp bản thật.
- Tên app trong ảnh khớp tên chốt (`name-check.md`).

Ngày kiểm bảng kích thước lần cuối: 2026-11-04 (dựa vào tài liệu mẫu A002 đã tổng hợp cùng ngày; chưa mở trang chính thức của Apple "Screenshot specifications" và Play Console Help "Add preview assets" — kiểm lại khi chụp).
