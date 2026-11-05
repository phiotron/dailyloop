# Hồ sơ App Store — Orbiday (bản nháp, chưa nộp)

Bản nháp để dán vào App Store Connect ở phiên điều phối #3 (phiên con N). Người dùng duyệt tên và nội dung trước khi nộp.
Nội dung khớp với Play (`store/listing.md`) và với SPEC; không hứa điều code không làm. Soạn 2026-11-04.
Không sao chép tên, icon, mô tả hay ảnh của app khác (SPEC mục 1, 7).

> **Tên thương hiệu đã chốt: Orbiday (2026-11-05)** — thay cho DailyLoop (App Store đã có "DailyLoop – Build Routines") và Streakloom (App Store đã có "Streakloom"); xem `store/name-check.md`, `store/name-candidates.md`. Định danh nội bộ giữ nguyên: `com.phiotron.dailyloop`, `A003-dailyloop`, đuôi `.dailyloop`.
> **Chỗ người dùng phải điền** (`[...]`): họ tên theo tài khoản Apple Developer (Seller/Copyright), email, số điện thoại (chỉ Apple thấy), URL chính sách, URL hỗ trợ.

## Trạng thái project iOS khi viết (QUAN TRỌNG — kiểm lại khi phiên con "nền iOS" xong)
Phiên này đọc `ios/` lúc **chưa commit, khung Flutter thô** (2026-11-04): `TARGETED_DEVICE_FAMILY = "1,2"` (iPhone **và iPad**), `CFBundleDisplayName = "Dailyloop"`,
`IPHONEOS_DEPLOYMENT_TARGET = 15.0`, hỗ trợ xoay ngang, **chưa có** `ITSAppUsesNonExemptEncryption`, `PrivacyInfo.xcprivacy`, entitlement time-sensitive, App Group/widget.
Tài liệu này viết cho cấu hình **mong muốn**; phiên điều phối/phiên con nền iOS cần đưa `ios/` về khớp, hoặc sửa lại các mục dưới theo thực tế:
| Điểm | Giả định trong hồ sơ | Nếu khác thì sửa |
|---|---|---|
| Thiết bị | **Chỉ iPhone** (`TARGETED_DEVICE_FAMILY = 1`), chỉ màn dọc (SPEC mục 5: chỉ màn dọc) | Nếu giữ iPad: thêm bộ ảnh iPad 13" 2064×2752 và thử bố cục iPad (`screenshots-spec.md`); bỏ dòng "Chỉ iPhone" ở bảng Thông tin chung |
| Tên hiển thị | `Orbiday` | `CFBundleDisplayName` trong `Info.plist` (phiên iOS đổi; khung thô ban đầu là "Dailyloop") |
| Mã hóa | `ITSAppUsesNonExemptEncryption = false` | Thêm vào `Info.plist`; nếu thiếu, App Store Connect hỏi lại mỗi build |
| Privacy manifest | `ios/Runner/PrivacyInfo.xcprivacy`: không tracking, không thu thập; các API "required reason" cần khai (ít nhất file timestamp/disk space do SQLite/drift; **UserDefaults `CA92.1`** nếu dùng App Group/SharedPreferences cho widget) | Xem báo cáo Privacy của Xcode Archive ở build ký đầu tiên |
| Thông báo | Entitlement `com.apple.developer.usernotifications.time-sensitive` bật trong App ID + `Runner.entitlements` | Không có → kiểu "Chuông" chỉ là thông báo thường |
| Widget | WidgetKit extension + App Group (`group.com.phiotron.dailyloop` hoặc theo App ID người dùng tạo) | Nếu widget iOS bị cắt khỏi v1 (APP.md: phần cắt đầu tiên): xóa dòng widget ở mô tả/ảnh |
| Số thông báo | iOS chỉ giữ **tối đa 64** thông báo cục bộ đang chờ; lịch lăn 7 ngày/100 lần của Android (D-007) phải bị chặn ở 64 trên iOS | Việc của phiên code — xem rủi ro trong `notes/2026-11-04-store-legal.md` |
| Chuỗi mô tả quyền (`NS…UsageDescription`) | Không cần: thông báo xin lúc chạy không cần chuỗi; chọn/chia sẻ file dùng trình chọn/bảng chia sẻ hệ thống | Nếu App Store Connect báo ITMS-90683 thì thêm chuỗi, nói đúng lý do |

## Tra trùng tên
Đã chốt Orbiday (xem `store/name-check.md`, `store/name-candidates.md`): tra 2026-11-04 thấy không có app tên Orbiday trên App Store (US, VN) và Google Play. Còn phải tra nhãn hiệu (nhóm 9/42, nhãn "ORBI…" của NETGEAR). App Store Connect kiểm trùng **nguyên tên** khi tạo app: nếu "Orbiday: Habits & To-Do" bị giữ, thử `Orbiday – Habits & Tasks`.

## Thông tin chung (App Information)
| Trường | Giá trị |
|---|---|
| Bundle ID | `com.phiotron.dailyloop` (người dùng tạo App ID trên developer.apple.com; bật Notifications time-sensitive và App Groups nếu có widget) |
| SKU | `dailyloop-ios-1` (chỉ nội bộ) |
| Ngôn ngữ chính | English (U.S.). Thêm bản địa hóa Vietnamese |
| Danh mục chính | **Productivity** · Danh mục phụ: **Lifestyle** (không chọn Health & Fitness để khỏi bị coi là app sức khỏe) |
| Giá | Miễn phí. Không In-App Purchase, không thuê bao, không quảng cáo |
| Phân phối | Mọi quốc gia/vùng trừ **Trung Quốc đại lục** (cần số ICP) và **Nga** (nhóm C, COMPLIANCE M-01); nhóm D theo M-01 khi chốt |
| Thiết bị | Chỉ iPhone (xem bảng trên). Không bật "iPhone and iPad Apps on Apple Silicon Macs" / "Apple Vision Pro" (chưa thử) |
| Copyright | `© 2026 [họ tên người đăng ký Apple Developer]` |
| Seller | Tài khoản **cá nhân** → hiện **họ tên thật**. Chính sách quyền riêng tư dùng đúng tên này |
| Trader status (EU, DSA) | App miễn phí, không kinh doanh → người dùng cân nhắc khai **không phải trader**; khai là trader thì địa chỉ/điện thoại/email hiện công khai ở EU. Người dùng tự quyết (việc pháp lý) |

## URL bắt buộc
| URL | Bắt buộc? | Nội dung | Trạng thái |
|---|---|---|---|
| Privacy Policy URL | Có | `docs/legal/web/privacy-policy.html` (vi/en) | CHƯA đăng — người dùng host |
| Support URL | Có | `docs/legal/web/support.html` (email liên hệ, câu hỏi thường gặp: nhắc giờ không kêu, quên PIN, chuyển máy bằng file `.dailyloop`, xuất CSV) | CHƯA đăng — cùng site với chính sách |
| Marketing URL | Không | Bỏ trống | — |

Cùng đường dẫn chính sách phải điền vào app (`AppInfo.privacyPolicyUrl`, AC-51) — việc của phiên code.

## Tên, phụ đề, từ khóa (đã đếm ký tự)
| Ngôn ngữ | Tên (≤ 30) | Số ký tự |
|---|---|---|
| English (U.S.) | `Orbiday: Habits & To-Do` | 23 |
| Vietnamese | `Orbiday: Thói Quen & Việc` | 25 |
Từ khóa và phụ đề dưới đây **không lặp** chữ trong tên (Apple đã đánh chỉ mục tên: orbiday, habits, to-do).

## English (U.S.) — localization chính
- **Name** (≤ 30): `Orbiday: Habits & To-Do` (23)
- **Subtitle** (≤ 30): `Reminders, streaks, offline` (27)
- **Keywords** (≤ 100 ký tự, dấu phẩy không cách): `routine,planner,tracker,checklist,pomodoro,timer,widget,goals,daily,schedule,focus,task,productivity` (100)
- **Promotional Text** (≤ 170; đổi được không cần duyệt lại): `Your habits and to-dos in one list for today. Tap to complete, get reminded on time, see your streaks. No account, no ads: your data stays on your iPhone.` (154)

**Description** (≤ 4.000):
```
Orbiday turns your habits and to-dos into one simple list for today. Open the app, tap the circle next to each item, and watch your streaks grow.

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
• Pick a normal notification or an "Alarm" reminder. Notifications have Done and Snooze buttons, so you can finish an item without opening the app.
• "Alarm" reminders are sent as time-sensitive notifications: they can break through Focus and Scheduled Summary and play a sound. You can turn this off for Orbiday in iPhone Settings. (iPhone does not allow a full-screen alarm.)
• Finish an item early and its later reminders that day stay quiet.
• The app explains why it needs notifications before asking, and works without them.

STREAKS, SCORE AND STATS
• Current and longest streak, success rate for 7 days, 30 days and all time, and a 0–100 habit score.
• A month calendar for every habit, and bar charts with a goal line for Count and Time habits.
• Overall stats for the last 7 and 30 days. Every chart has a table view for VoiceOver.

FOCUS TIMER (POMODORO)
• Set focus, short break and long break lengths (default 25 / 5 / 15 minutes, long break after 4 sessions).
• Keeps the right time with the screen off or after you leave the app, and tells you when time is up with a notification and sound.
• Start it from a Time habit and the minutes are added to today for you.

HOME SCREEN WIDGET
• The "Today" widget shows today's items and their status. Tap an item to open it in the app.

YOUR DATA STAYS YOURS
• No account, no ads, no analytics, no tracking. Orbiday has no server and never connects to the Internet, so the developer never receives your data.
• Your data is stored only in the app on your iPhone. If you use iPhone backup (iCloud or a computer), it includes the app's data like any other app.
• Optional 4-digit PIN lock. With the PIN on, the widget and lock-screen notifications hide item names. The PIN does not encrypt your data. If you forget it, the only way back in is to erase the app's data.
• Back up to a .dailyloop file that you keep yourself (for example in Files) and restore it on a new iPhone. Export your history as CSV for Numbers, Excel or Google Sheets. Backup files are not encrypted, so keep them somewhere safe.

COMFORTABLE TO USE
• English and Vietnamese, light and dark themes, Monday or Sunday as the first day of the week.
• Works with VoiceOver and large text sizes.

Free. No in-app purchases.

Orbiday is a personal organizer, not a medical device, and it cannot replace professional advice.
```
Số ký tự: 3354 / 4000

- **What's New**: App Store Connect **không cho nhập** ở bản 1.0 → dùng cho TestFlight "What to Test" và giữ cho 1.0.1: `First release: habits and to-dos in one daily list, reminders, streaks and stats, Pomodoro timer, widget, PIN lock, backup and CSV export.`

### Khác với bản Play có chủ đích
- **Không có chuông toàn màn hình trên iOS** → "Chuông" = thông báo time-sensitive có âm thanh + nút Xong/Hoãn (APP.md "Quyết định riêng", SPEC mục 4). Mô tả nói rõ, không hứa full-screen.
- **Widget iOS chỉ hiện danh sách (chạm tên mở app)**; việc chạm ô đánh dấu để hoàn thành không mở app là của widget Android (AC-39 viết cho Android). Nếu widget iOS làm được thao tác tick (iOS 17+ interactive widget) thì sửa dòng này sau khi thử trên simulator/máy.
- "VoiceOver" thay "TalkBack"; "không kết nối Internet" thay "không có quyền Internet"; nêu sao lưu iPhone có chứa dữ liệu (Android tắt `allowBackup`).

## Vietnamese — localization phụ
- **Name** (≤ 30): `Orbiday: Thói Quen & Việc` (25)
- **Subtitle** (≤ 30): `Nhắc giờ, chuỗi ngày, offline` (29)
- **Keywords** (≤ 100): `lịch,mục tiêu,kế hoạch,nhắc nhở,pomodoro,routine,habit,todo,widget,năng suất,tập trung,công việc` (96)
  (Apple đếm theo ký tự; nếu App Store Connect báo quá dài thì bỏ từ cuối.)
- **Promotional Text** (≤ 170): `Thói quen và việc cần làm trong một danh sách hôm nay. Chạm là xong, nhắc đúng giờ, xem chuỗi ngày. Không tài khoản, không quảng cáo: dữ liệu ở trên iPhone của bạn.` (164)

**Description** (≤ 4.000):
```
Orbiday gom thói quen và việc cần làm của bạn vào một danh sách gọn cho hôm nay. Mở app, chạm vào ô tròn bên cạnh mỗi mục, và xem chuỗi ngày của bạn dài ra.

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
• Chọn thông báo thường hoặc nhắc kiểu "Chuông". Thông báo có nút Xong và Hoãn, nên bạn đánh xong mục mà không cần mở app.
• Nhắc kiểu "Chuông" được gửi dưới dạng thông báo khẩn theo thời gian (time-sensitive): có thể vượt qua chế độ Tập trung và Bản tóm tắt theo lịch, và phát âm thanh. Bạn tắt được trong Cài đặt iPhone. (iPhone không cho phép chuông toàn màn hình.)
• Đánh xong mục sớm thì các lần nhắc sau trong ngày của mục đó không báo nữa.
• App giải thích vì sao cần quyền thông báo trước khi xin, và vẫn dùng được nếu bạn từ chối.

CHUỖI NGÀY, ĐIỂM VÀ THỐNG KÊ
• Chuỗi hiện tại và chuỗi dài nhất, tỉ lệ thành công 7 ngày, 30 ngày và từ đầu, cùng điểm thói quen từ 0 đến 100.
• Lịch tháng cho từng thói quen, và biểu đồ cột có đường mục tiêu cho thói quen kiểu Số lượng và Thời gian.
• Thống kê chung 7 ngày và 30 ngày gần nhất. Mọi biểu đồ đều có bảng thay thế cho VoiceOver.

ĐỒNG HỒ TẬP TRUNG (POMODORO)
• Chỉnh thời gian tập trung, nghỉ ngắn, nghỉ dài (mặc định 25 / 5 / 15 phút, nghỉ dài sau 4 phiên).
• Vẫn đúng giờ khi tắt màn hình hoặc rời app, và báo hết giờ bằng thông báo kèm âm thanh.
• Bấm giờ từ thói quen kiểu Thời gian thì số phút được cộng vào hôm nay cho bạn.

WIDGET MÀN HÌNH CHÍNH
• Widget "Hôm nay" hiện các mục hôm nay và trạng thái của chúng. Chạm vào một mục để mở nó trong app.

DỮ LIỆU CỦA BẠN VẪN LÀ CỦA BẠN
• Không tài khoản, không quảng cáo, không công cụ phân tích, không theo dõi. Orbiday không có máy chủ và không bao giờ kết nối Internet, nên nhà phát triển không nhận dữ liệu của bạn.
• Dữ liệu chỉ lưu trong app trên iPhone của bạn. Nếu bạn dùng sao lưu iPhone (iCloud hoặc máy tính), bản sao lưu đó chứa dữ liệu của app như mọi app khác.
• Khóa bằng mã PIN 4 số (tùy chọn). Khi bật PIN, widget và thông báo trên màn khóa ẩn tên mục. PIN không mã hóa dữ liệu. Quên mã thì chỉ có cách xóa dữ liệu của app.
• Sao lưu ra file .dailyloop do bạn tự giữ (ví dụ trong app Tệp) và khôi phục khi đổi iPhone. Xuất lịch sử ra CSV để mở bằng Numbers, Excel hoặc Google Sheets. File sao lưu không được mã hóa, hãy cất ở nơi an toàn.

DỄ DÙNG
• Tiếng Việt và tiếng Anh, giao diện sáng và tối, chọn Thứ Hai hoặc Chủ Nhật làm ngày đầu tuần.
• Dùng được với VoiceOver và cỡ chữ lớn.

Miễn phí. Không mua trong app.

Orbiday là công cụ sắp xếp cá nhân, không phải thiết bị y tế và không thay thế lời khuyên chuyên môn.
```
Số ký tự: 3371 / 4000

- **What's New** (TestFlight / bản sau): `Bản đầu tiên: thói quen và việc trong một danh sách hằng ngày, nhắc giờ, chuỗi ngày và thống kê, đồng hồ Pomodoro, widget, khóa PIN, sao lưu và xuất CSV.`

## Age Rating (bảng câu hỏi mới của Apple: 4+, 9+, 13+, 16+, 18+)
Trả lời đề xuất (mọi câu theo tần suất chọn **None**, mọi câu có/không chọn **No**):
| Nhóm câu hỏi | Trả lời | Lý do |
|---|---|---|
| Bạo lực (hoạt hình, thực tế, kéo dài), kinh dị, tình dục/khỏa thân, ngôn từ thô tục, ma túy/rượu/thuốc lá, chủ đề người lớn | None | App chỉ có thói quen/việc do người dùng tự nhập |
| Chủ đề y tế/sức khỏe, thông tin y khoa | None / No | Không chẩn đoán, không tư vấn y tế |
| Cờ bạc mô phỏng/thật, cuộc thi, loot box | None / No | Không có |
| Nội dung do người dùng tạo được chia sẻ / nhắn tin / chat | No | Nội dung chỉ nằm trên máy |
| Truy cập web không giới hạn | No | Không có WebView; liên kết chính sách mở Safari bên ngoài |
| Quảng cáo | No | Không có |
| Kiểm soát trong app (parental controls, xác minh tuổi) | No | Không có |
| Khả năng khác (tài khoản, mạng, vị trí, camera) | No | Không có |
Kết quả dự kiến: **4+** ở mọi vùng (Việt Nam theo thang riêng, dự kiến mức thấp nhất). Không chọn "Made for Kids". Kiểm lại câu chữ thật của bảng hỏi khi điền; ghi kết quả vào COMPLIANCE P-05.

## App Privacy (nhãn quyền riêng tư)
- "Do you or your third-party partners collect data from this app?" → **No, we do not collect data from this app.** Nhãn: **Data Not Collected**.
- Lý do (Apple: "thu thập" = dữ liệu truyền ra khỏi máy để nhà phát triển hoặc đối tác truy cập lâu hơn thời gian phục vụ yêu cầu tức thời):
  - Không có máy chủ; `pubspec.yaml` chỉ có gói chạy trên máy (`drift`/SQLite, `flutter_local_notifications`, `timezone`, `flutter_timezone`, `go_router`, `riverpod`, `intl`); không có `http`/`dio`/WebView/SDK analytics/quảng cáo/crash (kiểm 2026-11-04, `docs/DECISIONS.md` D-002). Gói thêm ở G7 (chia sẻ file, chọn file, lưu trữ an toàn) cũng chạy cục bộ — **rà lại `pubspec.yaml` khi G7 xong**.
  - File sao lưu/CSV chỉ rời máy khi người dùng tự chọn đích trong bảng chia sẻ; nhà phát triển không nhận.
  - Sao lưu iCloud/iPhone do Apple và người dùng kiểm soát → không tính là "thu thập".
  - Không theo dõi (tracking), không IDFA → **không cần App Tracking Transparency**.
- `ios/Runner/PrivacyInfo.xcprivacy` phải khớp: `NSPrivacyTracking = false`, `NSPrivacyTrackingDomains` rỗng, `NSPrivacyCollectedDataTypes` rỗng (xem bảng trạng thái ở đầu file).
- Sai lệch phải khai lại trước khi nộp bản đó: thêm SDK crash/analytics/đồng bộ đám mây.

## Export compliance (mã hóa)
- `ITSAppUsesNonExemptEncryption = NO` trong `Info.plist` (xem bảng đầu file; hiện CHƯA có).
- Lý do: app không tự mã hóa dữ liệu và không kết nối mạng. Băm có muối của PIN (hàm băm xác thực) và mã kiểm tra toàn vẹn của file `.dailyloop` (checksum, không phải mã hóa) thuộc diện miễn trừ; Keychain là mã hóa của hệ điều hành. **File sao lưu không được mã hóa.** Không cần ERN/CCATS, không cần báo cáo năm.
- Nếu sau này thêm mã hóa file sao lưu bằng mật khẩu (AES) → xem lại mục này (có thể vẫn miễn trừ nhưng phải trả lời lại).

## Thông tin cho App Review
- Sign-in required: **No** (không có tài khoản).
- Liên hệ: họ tên + email `[email liên hệ]` + số điện thoại `[của người dùng]` (chỉ Apple thấy).
- Notes (dán nguyên, tiếng Anh):
  ```
  Orbiday is a fully offline habit and to-do planner. There is no account, no server and no network access; all data stays on the device.
  To try it: tap + > New habit, enter a name, set a reminder time two minutes from now, and allow notifications when asked. The app explains why notifications are needed before the system prompt appears.
  Reminders: each habit or to-do can have up to 5 reminder times. The "Alarm" style is delivered as a TIME-SENSITIVE notification (entitlement com.apple.developer.usernotifications.time-sensitive) with Done and Snooze buttons. iOS does not allow third-party full-screen alarms, so we use time-sensitive notifications only for reminders the user explicitly sets to the Alarm style; normal reminders use standard notifications. The user can turn time-sensitive delivery off in Settings > Notifications > Orbiday.
  Timer: Pomodoro (the clock icon on the home screen) ends with a local notification at the end time; the remaining time is computed from a saved start time, so it stays correct if the app is closed.
  Widget: long-press the home screen > + > Orbiday > "Today". It shows today's items (data is shared with the app through an App Group on this device only).
  PIN lock: Settings > Lock with PIN (4 digits, entered twice). It only hides the app UI, items names in the widget and lock-screen notifications; data is not encrypted, and the app says so.
  Backup: Settings > Export backup creates a .dailyloop file and opens the iOS share sheet (Save to Files). Settings > Restore opens the Files picker.
  The app is free, has no in-app purchases and no ads.
  ```
  (Đối chiếu lại đường đi màn hình/chữ nút với bản build thật trước khi dán; G7 và UI mới ở phiên #2 có thể đổi tên mục. Câu về widget/PIN theo SPEC.)

## Ảnh chụp và icon
- Kích thước, số lượng, kịch bản dữ liệu mẫu: `store/screenshots-spec.md`. Chụp ở phiên điều phối #3 với UI mới (iPhone 6.9" 1320 × 2868).
- Icon App Store 1024×1024: CHƯA có (Claude Design phiên #2) — PNG vuông, **không trong suốt, không bo góc**.
- App Preview (video): không làm ở bản 1.

## Kiểm trước khi nộp
- [ ] `ios/` khớp bảng trạng thái ở đầu file (iPhone-only, tên, mã hóa, privacy manifest, entitlement, App Group, giới hạn 64 thông báo).
- [ ] Mô tả khớp widget iOS thật (có/không tick được) và chuông time-sensitive thật (thử trên simulator CI/TestFlight).
- [ ] Notes cho App Review khớp đường đi màn hình thật.
- [ ] Tên/phụ đề/từ khóa đã đếm lại sau khi đổi tên.
