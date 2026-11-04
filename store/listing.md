# Hồ sơ Google Play — DailyLoop (bản nháp, chưa nộp)

Bản nháp để dán vào Google Play Console ở phiên điều phối #3 (closed test có thể cần sớm hơn — xem `store/closed-test-plan.md`).
Người dùng duyệt tên và nội dung trước khi nộp. Bản App Store tương ứng: `store/app-store.md` (giữ hai bản thống nhất).
Soạn 2026-11-04 từ `docs/SPEC.md` (F-01..F-14), `AndroidManifest.xml` + manifest đã gộp của bản release (`build/.../processReleaseManifest`), D-007, D-009.
Không sao chép tên, icon, mô tả hay ảnh của app khác (SPEC mục 1, 7).

> ⚠ **Tên "DailyLoop" đang trùng nặng trên cả hai store** → đọc `store/name-check.md` TRƯỚC. Mọi chỗ tên dưới đây viết cho tên `DailyLoop`;
> nếu đổi tên, thay theo bảng "Tên" (các mô tả dài không chứa tên riêng ngoài dòng mở đầu và dòng cuối, dùng tìm–thay `DailyLoop`).

> **Chỗ người dùng phải điền** (đánh dấu `[...]`): tên nhà phát triển, email liên hệ, URL chính sách quyền riêng tư, website (nếu có).
> Phần mô tả mô tả đúng SPEC; các dòng liên quan G7 (PIN, sao lưu, xóa dữ liệu) và widget/chuông chưa thử máy thật → **đối chiếu lại với bản build thật trước khi nộp** (mục cuối "Kiểm trước khi nộp").

## Tên (≤ 30 ký tự)
| Phương án | Tiếng Anh (en-US) | Tiếng Việt (vi) | Ghi chú |
|---|---|---|---|
| **A — giữ tên (mặc định trong bản nháp)** | `DailyLoop: Habits & To-Do` (25) | `DailyLoop: Thói Quen & Việc` (27) | Trùng tên 3 app trên Play, 1 app trên App Store (`name-check.md`) |
| B — "Nhịp Ngày" | `Nhip Ngay: Habits & To-Do` (25) | `Nhịp Ngày: Thói Quen & Việc` (27) | Tra Play không thấy trùng |
| C — "Streakloom" | `Streakloom: Habits & To-Do` (26) | `Streakloom: Thói Quen & Việc` (28) | Tra Play không thấy trùng |
- Tên dưới icon trên máy: **DailyLoop** (hoặc tên mới) — `android:label` trong `AndroidManifest.xml`, ≤ 12 ký tự cho khỏi bị cắt.
- Play cho tên ≤ 30 ký tự; không ký hiệu/emoji gây hiểu nhầm, không "#1", "Best", "Free" (chính sách Metadata).

## Mô tả ngắn (≤ 80 ký tự)
- en: Habits and to-dos in one daily list. Reminders, streaks. Offline, no account. (77)
- vi: Thói quen và việc hằng ngày trong một danh sách. Nhắc giờ, chuỗi ngày, offline. (79)

## Mô tả đầy đủ (≤ 4.000 ký tự)

### English (en-US)
```
DailyLoop turns your habits and to-dos into one simple list for today. Open the app, tap the circle next to each item, and watch your streaks grow.

ONE LIST FOR TODAY
• Habits and one-off to-dos together, sorted by reminder time and priority.
• A day strip across the top: look back and fix a past day, or peek at tomorrow.
• Tap to complete, tap again to undo. Skip a day without breaking your streak.
• Overdue to-dos stay at the top, with the number of days late, until you finish or reschedule them.

HABITS THE WAY YOU WORK
• Four ways to track: Yes/No, Count (for example 8 glasses), Time (for example 30 minutes), or a checklist of up to 20 sub-items.
• Flexible repeat: every day, chosen weekdays, chosen days of the month, every N days, or K times per week or month.
• Edit a habit without losing its history. Archive it, or delete it with a few seconds to undo.
• Categories with icons and colors; add your own.

REMINDERS
• Up to 5 reminder times for each habit or to-do, only on the days it is due.
• Pick a normal notification (with a Done button) or an alarm.
• On Android the alarm appears full screen over the lock screen, rings until you tap Done, Snooze 10 minutes or Stop, and stops by itself after 5 minutes.
• Reminders are set up again after you restart your phone. Finish an item early and its later reminders that day stay quiet.
• The app explains each permission before asking for it and still works if you say no (reminders then arrive as ordinary notifications, possibly a little late).

STREAKS, SCORE AND STATS
• Current and longest streak, success rate for 7 days, 30 days and all time, and a 0–100 habit score.
• A month calendar for every habit, and bar charts with a goal line for Count and Time habits.
• Overall stats for the last 7 and 30 days. Every chart has a table view for screen readers.

FOCUS TIMER (POMODORO)
• Set focus, short break and long break lengths (default 25 / 5 / 15 minutes, long break after 4 sessions).
• Keeps the right time with the screen off or after you leave the app, and tells you when time is up with a notification and sound.
• Start it from a Time habit and the minutes are added to today for you.

HOME SCREEN WIDGET
• The "Today" widget (4×2 or larger) shows today's items and lets you tick Yes/No items without opening the app.

YOUR DATA STAYS YOURS
• No account, no ads, no analytics, no tracking. The app has no Internet permission and sends nothing anywhere.
• Optional 4-digit PIN lock. With the PIN on, the widget and lock-screen notifications hide item names. The PIN does not encrypt your data. If you forget it, the only way back in is to erase the app's data.
• Back up to a .dailyloop file that you keep yourself and restore it on a new phone. Export your history as CSV for Excel or Google Sheets. Backup files are not encrypted, so keep them somewhere safe.

COMFORTABLE TO USE
• English and Vietnamese, light and dark themes, Monday or Sunday as the first day of the week.
• Works with TalkBack and large text sizes.

Free. No in-app purchases.

DailyLoop is a personal organizer, not a medical device, and it cannot replace professional advice. Reminder timing can be affected by your phone's battery saver; for the most exact times, allow "Alarms & reminders" for DailyLoop in system settings.
```
Số ký tự: 3283 / 4000

### Tiếng Việt (vi)
```
DailyLoop gom thói quen và việc cần làm của bạn vào một danh sách gọn cho hôm nay. Mở app, chạm vào ô tròn bên cạnh mỗi mục, và xem chuỗi ngày của bạn dài ra.

MỘT DANH SÁCH CHO HÔM NAY
• Thói quen và việc cần làm một lần nằm chung, xếp theo giờ nhắc rồi mức ưu tiên.
• Dải ngày ở đầu màn hình: xem lại và sửa kết quả ngày đã qua, hoặc xem trước ngày mai.
• Chạm để đánh xong, chạm lại để bỏ. Bỏ qua một ngày mà không làm đứt chuỗi.
• Việc quá hạn ở lại đầu danh sách, kèm số ngày trễ, cho tới khi bạn làm xong hoặc dời ngày.

THÓI QUEN THEO CÁCH CỦA BẠN
• Bốn kiểu theo dõi: Có/Không, Số lượng (ví dụ 8 ly nước), Thời gian (ví dụ 30 phút), hoặc danh sách con tối đa 20 mục.
• Lịch lặp linh hoạt: mỗi ngày, các thứ trong tuần, các ngày trong tháng, cứ N ngày một lần, hoặc K lần mỗi tuần hay mỗi tháng.
• Sửa thói quen mà không mất lịch sử. Lưu trữ lại, hoặc xóa kèm vài giây để hoàn tác.
• Danh mục có icon và màu, tự thêm theo ý bạn.

NHẮC GIỜ
• Tối đa 5 giờ nhắc cho mỗi thói quen hoặc việc, chỉ vào những ngày mục đó đến hạn.
• Chọn thông báo thường (có nút Xong) hoặc chuông báo thức.
• Trên Android, chuông hiện toàn màn hình trên màn khóa, kêu cho tới khi bạn bấm Xong, Hoãn 10 phút hoặc Tắt, và tự dừng sau 5 phút.
• Giờ nhắc tự được đặt lại sau khi khởi động lại máy. Đánh xong mục sớm thì các lần nhắc sau trong ngày của mục đó không báo nữa.
• App giải thích từng quyền trước khi xin và vẫn dùng được nếu bạn từ chối (khi đó nhắc giờ chạy như thông báo thường, có thể trễ một chút).

CHUỖI NGÀY, ĐIỂM VÀ THỐNG KÊ
• Chuỗi hiện tại và chuỗi dài nhất, tỉ lệ thành công 7 ngày, 30 ngày và từ đầu, cùng điểm thói quen từ 0 đến 100.
• Lịch tháng cho từng thói quen, và biểu đồ cột có đường mục tiêu cho thói quen kiểu Số lượng và Thời gian.
• Thống kê chung 7 ngày và 30 ngày gần nhất. Mọi biểu đồ đều có bảng thay thế cho trình đọc màn hình.

ĐỒNG HỒ TẬP TRUNG (POMODORO)
• Chỉnh thời gian tập trung, nghỉ ngắn, nghỉ dài (mặc định 25 / 5 / 15 phút, nghỉ dài sau 4 phiên).
• Vẫn đúng giờ khi tắt màn hình hoặc rời app, và báo hết giờ bằng thông báo kèm âm thanh.
• Bấm giờ từ thói quen kiểu Thời gian thì số phút được cộng vào hôm nay cho bạn.

WIDGET MÀN HÌNH CHÍNH
• Widget "Hôm nay" (cỡ 4×2 trở lên) hiện các mục hôm nay và cho chạm đánh xong mục Có/Không mà không cần mở app.

DỮ LIỆU CỦA BẠN VẪN LÀ CỦA BẠN
• Không tài khoản, không quảng cáo, không công cụ phân tích, không theo dõi. App không có quyền Internet và không gửi gì đi đâu.
• Khóa bằng mã PIN 4 số (tùy chọn). Khi bật PIN, widget và thông báo trên màn khóa ẩn tên mục. PIN không mã hóa dữ liệu. Quên mã thì chỉ có cách xóa dữ liệu của app.
• Sao lưu ra file .dailyloop do bạn tự giữ và khôi phục khi đổi máy. Xuất lịch sử ra CSV để mở bằng Excel hoặc Google Sheets. File sao lưu không được mã hóa, hãy cất ở nơi an toàn.

DỄ DÙNG
• Tiếng Việt và tiếng Anh, giao diện sáng và tối, chọn Thứ Hai hoặc Chủ Nhật làm ngày đầu tuần.
• Dùng được với TalkBack và cỡ chữ lớn.

Miễn phí. Không mua trong app.

DailyLoop là công cụ sắp xếp cá nhân, không phải thiết bị y tế và không thay thế lời khuyên chuyên môn. Giờ nhắc có thể bị chế độ tiết kiệm pin của máy làm trễ; để đúng giờ nhất, hãy cho phép "Báo thức và lời nhắc" cho DailyLoop trong cài đặt hệ thống.
```
Số ký tự: 3223 / 4000

### Từ khóa (Play không có ô từ khóa; đã lồng vào tên và mô tả — dùng tự nhiên, không nhồi)
habit tracker, daily planner, to-do list, routine, streak, reminder, Pomodoro, widget, offline · thói quen, việc cần làm, nhắc giờ, chuỗi ngày, hẹn giờ Pomodoro, không cần mạng.

## Phân loại và giá
- Danh mục: **Productivity** (Năng suất). Thẻ (tags) gợi ý khi Play hỏi, chọn từ danh sách của Play: Habit tracker / To-do list / Planner / Productivity.
- Loại: **App** (không phải Game). Giá: **miễn phí**, không mua trong app, không quảng cáo.
- Quốc gia: theo COMPLIANCE M-01 (nhóm A và B, gồm Việt Nam); không mở Nga và Trung Quốc đại lục (nhóm C chưa mở); nhóm D không bán.
- Ngôn ngữ cửa hàng: mặc định **en-US**, thêm **vi** (app có cả hai ngôn ngữ — AC-48). Hoặc mặc định vi nếu thị trường chính là Việt Nam.
- Liên hệ (công khai trên trang store): email **[email liên hệ — người dùng điền]**, website [tuỳ chọn], điện thoại [bỏ trống].
- Tên nhà phát triển trên Play = tên đã xác minh khi tạo tài khoản cá nhân → dùng đúng tên đó trong chính sách (`docs/legal/`).

## Độ tuổi, đối tượng và các khai báo "App content" (Play Console → Policy → App content)
| Mục | Trả lời đề xuất | Ghi chú |
|---|---|---|
| Privacy policy | URL công khai của `docs/legal/web/privacy-policy.html` đã host | CHƯA đăng — người dùng host; cũng điền vào `AppInfo.privacyPolicyUrl` (phiên code) |
| Ads | **No**, app không chứa quảng cáo | |
| App access | **All functionality is available without special access** | Không đăng nhập; PIN do người dùng tự bật, mặc định tắt |
| Content rating (IARC) | Danh mục bảng hỏi: **Utility, Productivity, Communication, or Other** (không phải game). Mọi câu bạo lực, tình dục, ngôn từ, ma túy, cờ bạc: **No**. Người dùng tương tác/chia sẻ nội dung với nhau: **No**. Chia sẻ vị trí: **No**. Mua hàng số: **No**. Trình duyệt web không giới hạn: **No** | Kết quả dự kiến: mức thấp nhất (Everyone / PEGI 3 / IARC 3+) |
| Target audience | Nhóm tuổi: **13–15, 16–17, 18+**. Không chọn nhóm dưới 13 → không vào chương trình Families. "Hấp dẫn trẻ em": **No** | COMPLIANCE P-12 không áp dụng; Play Age Signals chưa tích hợp ở bản 1 (D-12, đề xuất) |
| News app / Government app | No / No | |
| Financial features | App không có tính năng tài chính → chọn mục kiểu "My app doesn't provide any financial features" | Câu chữ danh sách đổi theo thời gian — đọc kỹ khi điền |
| Health apps (Health apps declaration) | **No** — DailyLoop là app thói quen/việc nói chung, không đo/chẩn đoán/tư vấn sức khỏe, không dùng Health Connect | Nếu danh sách tính năng có mục kiểu "Activity and fitness tracking"/"Nutrition" mà Play đòi chọn vì mô tả có "uống nước/tập thể dục" làm ví dụ → đọc kỹ; mô tả đã tránh ví dụ y khoa (thuốc) có chủ đích |
| Advertising ID | **No** (không dùng) | App không khai `AD_ID`; không SDK quảng cáo. Kiểm manifest đã gộp: không có `com.google.android.gms.permission.AD_ID` |
| Data safety | Xem mục dưới | |
| Full-screen intent / Exact alarm (Permissions declaration) | Xem mục "Quyền nhạy cảm" | Điền nếu Play Console hiện biểu mẫu khai báo cho các quyền này; tên biểu mẫu có thể đổi |

## Data safety (khai trong Play Console)
Đi theo đúng thứ tự form:
1. "Does your app collect or share any of the required user data types?" → **No**.
   (Play định nghĩa "collect" = truyền dữ liệu ra khỏi máy. App **không có quyền INTERNET**, không SDK bên thứ ba, không mã gọi mạng → không truyền gì.)
2. Vì trả lời No, Play bỏ qua các câu về loại dữ liệu, mã hóa khi truyền và yêu cầu xóa. Trang store sẽ hiện "No data collected" và "No data shared with third parties".
3. Nếu form vẫn hỏi thêm: mã hóa khi truyền → không áp dụng (không truyền); yêu cầu xóa dữ liệu → người dùng tự xóa trong app (Cài đặt → Xóa toàn bộ dữ liệu, AC-52) hoặc gỡ app.
- Hành động do người dùng chủ động (chọn đích trong bảng chia sẻ để gửi file `.dailyloop`/CSV; chọn file khi khôi phục) không tính là app thu thập/chia sẻ.
- Widget và thông báo chỉ đọc/ghi dữ liệu cục bộ trên máy (SharedPreferences + SQLite trong bộ nhớ riêng của app, D-009).
- Đối chiếu nguồn: `docs/SECURITY.md` (bản đồ dữ liệu — hiện còn là mẫu rỗng, xem COMPLIANCE), manifest bản release (không có INTERNET), SBOM (chưa có — việc sau).
- Sai lệch phải khai lại trước khi phát hành bản đó: thêm SDK crash/analytics, đồng bộ đám mây, quyền INTERNET.

## Quyền khai báo và lý do — đã kiểm theo manifest THẬT
Nguồn: `android/app/src/main/AndroidManifest.xml` + manifest đã gộp `build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml` (đọc 2026-11-04).
Quyền có trong bản release: `SCHEDULE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, `POST_NOTIFICATIONS`, và `<package>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (quyền nội bộ AndroidX, không hiện với người dùng, không cần khai).
**Không có:** `INTERNET`, `USE_EXACT_ALARM` (D-007), `WAKE_LOCK`, `FOREGROUND_SERVICE*`, bộ nhớ/vị trí/danh bạ/camera/micro, `AD_ID`. App không có dịch vụ chạy nền liên tục.

| Quyền | Loại | Dùng để làm gì (nói với người dùng) | Khi nào xin | Từ chối thì sao |
|---|---|---|---|---|
| `POST_NOTIFICATIONS` | Runtime (Android 13+) | Hiện nhắc giờ và báo hết giờ Pomodoro | Lần đầu đặt giờ nhắc hoặc bấm giờ (AC-18), sau màn giải thích | App dùng bình thường; giờ nhắc có biểu tượng cảnh báo + nút mở Cài đặt |
| `SCHEDULE_EXACT_ALARM` | Đặc biệt (Android 12+; Android 14+ tắt sẵn với app mới cài, người dùng bật ở "Báo thức và lời nhắc") | Nhắc **đúng giờ** do người dùng đặt (kể cả khi máy ở chế độ chờ) | Khi đặt giờ nhắc, có màn giải thích dẫn tới cài đặt | Giờ nhắc vẫn chạy nhưng không chính xác (có thể trễ) và app cảnh báo |
| `USE_FULL_SCREEN_INTENT` | Đặc biệt (Android 14+ có thể phải người dùng cấp) | Chỉ cho giờ nhắc kiểu **"Chuông báo thức"** do người dùng chọn: hiện màn hình chuông trên màn khóa với nút Xong/Hoãn/Tắt | Khi chọn kiểu Chuông, có màn giải thích | Giờ nhắc đó chạy như thông báo nổi thường (AC-20) |
| `RECEIVE_BOOT_COMPLETED` | Thường (tự cấp) | Đặt lại giờ nhắc sau khi bật lại máy hoặc cập nhật app | Không hỏi | — |
| `VIBRATE` | Thường (tự cấp) | Rung cho chuông báo thức và thông báo | Không hỏi | — |
Widget "Hôm nay" không cần quyền. Quyền không xin: bộ nhớ (xuất file qua bảng chia sẻ, khôi phục qua trình chọn file hệ thống — AC-42, AC-43).

### Lời giải thích sẵn để dán vào Play Console (tiếng Anh — form chỉ nhận tiếng Anh)
Dán nguyên văn nếu Play Console hiện biểu mẫu; **đọc câu hỏi thật trên màn hình và chỉnh cho khớp**, không bịa số liệu. Chưa thấy form thật khi viết (2026-11-04) — tên biểu mẫu và câu hỏi dưới đây dựa trên chính sách Google Play hiện hành đã tra ở D-007.

**Exact alarms (`SCHEDULE_EXACT_ALARM`) — "What is the core functionality of your app that requires exact alarms?"**
```
DailyLoop is a habit and to-do planner. Each habit or to-do can have up to five user-set reminder times (for example "drink water at 10:30"). The user picks the exact time and the app must deliver the reminder at that time, including when the phone is idle, because a late reminder defeats the purpose (taking a task or habit at a set moment of the day). We use setExactAndAllowWhileIdle / setAlarmClock only for these user-created reminders and for the Pomodoro end-of-timer alert. We do NOT declare USE_EXACT_ALARM. Android 14+ requires the user to grant SCHEDULE_EXACT_ALARM; before asking, the app shows a screen explaining why, and if the user declines, reminders still work as inexact notifications and the app shows a warning icon. No alarms are scheduled for anything other than user-created reminders and the timer.
```
**Full-screen intent (`USE_FULL_SCREEN_INTENT`) — "Describe how your app uses full-screen intent"**
```
DailyLoop offers an optional "Alarm" reminder style that the user chooses per reminder. When such a reminder fires, the app shows a full-screen alarm screen over the lock screen with Done, Snooze (10 minutes) and Stop buttons, and rings until the user acts or 5 minutes pass. It is used ONLY for these user-created alarm-style reminders (the same way an alarm clock behaves), never for advertising, promotions or marketing. It is off by default: reminders default to normal notifications. Android 14+ may require the user to allow full-screen notifications in system settings; the app explains why before sending the user there. If the permission is not granted, the reminder is shown as a normal heads-up notification instead.
```
**Receiver / boot (`RECEIVE_BOOT_COMPLETED`)** — không cần biểu mẫu; nếu hỏi: `Re-schedules the user's reminders after the device restarts or the app is updated. No other work is done at boot.`

**Rủi ro:** Google có thể coi DailyLoop không phải "app báo thức chính" và **từ chối** full-screen intent / exact alarm. Hệ quả đã thiết kế sẵn: chuông thành thông báo nổi thường (AC-20), nhắc giờ không chính xác tuyệt đối (D-007). Nếu bị từ chối: gỡ quyền khỏi manifest ở bản kế tiếp (phiên code) và sửa dòng "Chuông toàn màn hình" trong mô tả. Quyết định này không chặn closed test.

## Tài khoản nhà phát triển cá nhân — điều cần biết
- **Tên hiển thị trên Play** = tên người dùng đặt khi tạo tài khoản (đã xác minh danh tính). Chính sách quyền riêng tư và màn Giới thiệu dùng cùng tên đó.
- **Email liên hệ hiện công khai** trên trang store. Tài khoản cá nhân không bán gì thì Play không hiện địa chỉ nhà; nếu sau này bán hàng/IAP thì có thể phải hiện địa chỉ (khai "trader" theo EU DSA).
- **Bắt buộc closed test ≥ 12 tester trong 14 ngày liên tục** trước khi xin production — `store/closed-test-plan.md`.
- **Xác minh nhà phát triển (developer verification)**: Google mở rộng dần theo nước (COMPLIANCE P-08); làm theo thông báo trong Play Console.
- Tài khoản cá nhân mới thường phải xác nhận có thiết bị Android thật qua app Play Console.

## Đồ họa store
- Icon 512×512 PNG 32-bit ≤ 1 MB: CHƯA có (UI/icon mới từ Claude Design ở phiên #2). Brief: `store/screenshots-spec.md` mục 5.
- Ảnh bìa (feature graphic) 1024×500: CHƯA có. Brief cùng nơi.
- Ảnh chụp màn hình điện thoại 2–8 ảnh (≥ 4 ảnh và ≥ 1080 px cạnh ngắn để đủ điều kiện được đề xuất): quy cách + kịch bản `store/screenshots-spec.md`; **chụp thật ở phiên #3 với UI mới**. Closed test không bắt ảnh đẹp: dùng tạm ảnh chụp UI hiện tại.

## Bản phát hành đầu tiên — "What's new" (≤ 500 ký tự)
- en: `First release: habits and to-dos in one daily list, reminders and alarms, streaks and stats, Pomodoro timer, home screen widget, PIN lock, backup and CSV export.`
- vi: `Bản đầu tiên: thói quen và việc trong một danh sách hằng ngày, nhắc giờ và chuông báo thức, chuỗi ngày và thống kê, đồng hồ Pomodoro, widget màn hình chính, khóa PIN, sao lưu và xuất CSV.`

## Kiểm trước khi nộp (đối chiếu mô tả với bản build thật)
- [ ] G7 đã vào bản build: Cài đặt có "Xuất bản sao lưu" (file `.dailyloop`), "Khôi phục", "Xuất CSV", khóa PIN, "Xóa toàn bộ dữ liệu" (AC-42..47, AC-52); khi bật PIN widget chỉ hiện số mục (AC-41) và thông báo màn khóa ẩn tên (AC-46).
- [ ] Widget "Hôm nay" chạy được trên máy thật (AC-39, AC-40 — chưa thử máy khi viết, APP.md).
- [ ] Chuông toàn màn hình + nút Xong/Hoãn/Tắt chạy trên máy thật (đã thử 2026-11-04 theo D-007); Pomodoro báo hết giờ khi tắt màn hình (AC-36 [M] chưa thử).
- [ ] Manifest bản **release** vẫn không có `INTERNET`, `USE_EXACT_ALARM`, `AD_ID` (`aapt2 dump permissions app-release.apk`) — AC-53.
- [ ] Tên, icon, màu, chữ trong ảnh store khớp UI thật (phiên #2); không nhắc tên app khác.
- [ ] Câu "Giờ nhắc có thể bị tiết kiệm pin làm trễ" giữ nguyên (nói thật về rủi ro, D-007/RISKS).
