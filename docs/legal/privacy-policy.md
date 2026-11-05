# Chính sách quyền riêng tư — Orbiday (bản nháp để đăng)

> **Ghi chú nội bộ, KHÔNG đăng phần này** (script `build_web.py` chỉ lấy phần sau dòng `---` đầu tiên).
> - Soạn 2026-11-04 cho **Android + iOS** từ SPEC mục 5–6, D-002, D-007, D-009 và manifest thật (`AndroidManifest.xml`: `allowBackup=false`, không `INTERNET`;
>   quyền: `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`). Mẫu từ `apps/A002-vigon/docs/legal/privacy-policy.md`.
> - **Đối chiếu lại khi G7 + iOS xong** (viết theo SPEC, chưa thấy code): (1) PIN lưu băm có muối trong kho an toàn của hệ điều hành (AC-45) — nếu dùng Keychain trên iOS và
>   không đặt cờ xóa khi gỡ app thì mục Keychain có thể còn sau khi gỡ app (đoạn "Lưu ý trên iPhone" ở mục 2) → giữ đoạn đó nếu đúng, bỏ nếu code xóa được;
>   (2) file `.dailyloop`/CSV ghi vào thư mục tạm rồi mở bảng chia sẻ (AC-42); (3) widget iOS dùng App Group (vùng lưu chung local); (4) `ios/` có/không có
>   `PrivacyInfo.xcprivacy`; (5) màn Giới thiệu có liên kết tới chính sách này (AC-51).
> - **Chỗ người dùng phải điền** (đánh dấu `[ĐIỀN: …]` / `[FILL: …]`, hiện nổi bật trong bản HTML): ngày hiệu lực, tên nhà phát triển (đúng tên hiển thị trên Google Play/App Store; tài khoản cá nhân → họ tên thật), email liên hệ.
> - Không phải tư vấn pháp lý; luật sư nên đọc lại trước khi mở bán (COMPLIANCE D-07, D-09).
> - **Nơi đăng (người dùng tự đăng, Claude không đăng):** Google Sites (khuyên dùng: miễn phí, không cần repo) — tạo site với 3 trang `privacy`, `support`, `terms`, dán nội dung từ file HTML trong `web/`
>   hoặc dùng "Embed code" cho nguyên file; hoặc GitHub Pages bằng một repo **public riêng** chỉ chứa thư mục `web/` (repo `phiotron/dailyloop` đang private, không đưa code app lên).
>   URL phải mở được không cần đăng nhập, không phải PDF tải về, ổn định lâu dài (đổi URL phải sửa app và hai store). Sau khi đăng điền URL vào: `lib/src/app_info.dart` (phiên code),
>   Play Console → App content → Privacy policy, App Store Connect → App Privacy → Privacy Policy URL, và Support URL.
> - Sau khi sửa file này chạy `python docs/legal/build_web.py` để sinh lại `web/*.html`.
> - Tên app: **Orbiday** (chốt 2026-11-05, xem `store/name-check.md`). Định danh nội bộ giữ `.dailyloop` (đuôi file sao lưu) — nếu đoạn nào nhắc đuôi file thì giữ nguyên.

---

## Tiếng Việt

### Chính sách quyền riêng tư của Orbiday
Ngày hiệu lực: [ĐIỀN: ngày đăng, ví dụ 2026-12-01]

Orbiday là app lập lịch thói quen và việc cần làm hằng ngày cho điện thoại Android và iPhone. Chính sách này giải thích app lưu dữ liệu nào, lưu ở đâu và bạn kiểm soát chúng ra sao.

### 1. Chúng tôi không thu thập dữ liệu của bạn
Orbiday không có máy chủ, không có tài khoản người dùng, không có quảng cáo, không có công cụ phân tích, theo dõi hay báo lỗi của bên thứ ba. App không kết nối Internet (trên Android, app không có cả quyền truy cập Internet) nên không gửi dữ liệu đi. Nhà phát triển Orbiday không nhận, không xem và không chia sẻ bất kỳ dữ liệu nào bạn nhập vào app.

### 2. Dữ liệu nằm trên điện thoại của bạn
Những gì bạn nhập (thói quen, việc cần làm, kết quả theo từng ngày, giờ nhắc, danh mục, ghi chú, cài đặt, trạng thái đồng hồ Pomodoro) chỉ được lưu trong vùng lưu trữ riêng của app trên điện thoại. App khác không đọc được vùng này.
- **Android:** app tắt tính năng sao lưu tự động của Android, nên dữ liệu không tự được đưa lên đám mây.
- **iPhone:** như mọi app khác, dữ liệu của Orbiday nằm trong bản sao lưu iPhone nếu bạn bật Sao lưu iCloud hoặc sao lưu iPhone bằng máy tính. Bản sao lưu đó do Apple và bạn quản lý theo chính sách của Apple; nhà phát triển không truy cập được.

Tên thói quen và việc do bạn tự đặt, nên có thể chứa thông tin riêng tư (ví dụ lịch uống thuốc). Thông tin đó cũng chỉ nằm trên máy của bạn như mọi dữ liệu khác của app.

Nếu bạn bật khóa bằng mã PIN, app chỉ lưu một giá trị băm có muối của mã PIN, không lưu mã PIN gốc, trong kho lưu trữ an toàn của hệ điều hành (Android Keystore hoặc Keychain của iPhone, không đồng bộ qua iCloud Keychain). Lưu ý trên iPhone: iOS có thể giữ mục Keychain này cả sau khi bạn gỡ app; nếu cài lại, app có thể hỏi mã PIN cũ. Khi đó bạn dùng "Quên mã" để xóa dữ liệu trong app và mã PIN.

### 3. Thông báo, báo thức và widget
- **Nhắc giờ và chuông báo thức** do hệ điều hành của điện thoại hiện ra từ lịch được lưu trên máy. Nội dung thông báo có tên mục của bạn và có thể hiện trên màn khóa. Khi bạn bật khóa PIN, tên mục bị ẩn khỏi thông báo trên màn khóa.
- **Widget "Hôm nay"** hiện các mục của hôm nay trên màn hình chính, dữ liệu lấy từ vùng lưu trữ riêng của app trên chính máy bạn (trên iPhone qua App Group, một vùng lưu trữ chung giữa app và widget của cùng nhà phát triển trên cùng máy). Khi bật khóa PIN, widget chỉ hiện số mục còn lại, không hiện tên mục.
- Không có dữ liệu nào trong các tính năng này được gửi cho nhà phát triển hay bên thứ ba.

### 4. Quyền trên điện thoại
Orbiday chỉ xin quyền khi bạn dùng tính năng cần quyền đó, và giải thích trước khi xin. App vẫn dùng được nếu bạn từ chối.
- **Thông báo** (Android 13 trở lên và iPhone): để hiện nhắc giờ và báo hết giờ Pomodoro.
- **Báo thức và lời nhắc chính xác** (Android, `SCHEDULE_EXACT_ALARM`): để nhắc đúng giờ bạn đặt. Android 14 trở lên do bạn tự bật trong cài đặt hệ thống.
- **Thông báo toàn màn hình** (Android, `USE_FULL_SCREEN_INTENT`): chỉ cho giờ nhắc kiểu "Chuông báo thức" do bạn chọn, để hiện màn hình chuông trên màn khóa. Trên iPhone, kiểu này dùng thông báo khẩn theo thời gian (time-sensitive) thay vì toàn màn hình.
- **Chạy khi khởi động máy** (Android, `RECEIVE_BOOT_COMPLETED`) và **rung** (`VIBRATE`): để đặt lại giờ nhắc sau khi bật lại máy và để chuông có rung.
- Orbiday **không** xin quyền vị trí, danh bạ, ảnh, camera, micro hay bộ nhớ. Khôi phục bản sao lưu dùng trình chọn file của hệ điều hành và chỉ đọc đúng file bạn chọn.

### 5. File sao lưu và CSV do bạn tự xuất
Khi bạn chọn "Xuất bản sao lưu" hoặc xuất CSV, app tạo file trong thư mục tạm của app rồi mở bảng chia sẻ của hệ điều hành để bạn chọn nơi gửi hoặc lưu (ví dụ app Tệp, Google Drive, email). Bạn quyết định file đi đâu. File sao lưu `.dailyloop` chứa toàn bộ dữ liệu của app (thói quen, việc, lịch sử, danh mục, giờ nhắc, cài đặt) và **không được mã hóa**; hãy cất ở nơi an toàn. Từ lúc đó, file chịu chính sách của dịch vụ bạn chọn. Hệ điều hành tự dọn thư mục tạm của app.

### 6. Liên kết ra ngoài
Màn "Giới thiệu" có thể mở trình duyệt (để xem chính sách này) hoặc app email (để báo lỗi bảo mật). Các app đó hoạt động theo chính sách riêng của chúng.

### 7. Dữ liệu cửa hàng ứng dụng có thể thu thập
Khi bạn tải app qua Google Play hoặc App Store, Google hoặc Apple có thể thu thập thông tin về việc cài đặt và sự cố app theo chính sách của họ và cài đặt trên máy bạn (ví dụ tùy chọn chia sẻ dữ liệu phân tích với nhà phát triển trên iPhone). Nhà phát triển chỉ thấy số liệu tổng hợp, ẩn danh trong Play Console và App Store Connect và không thể dùng chúng để nhận ra bạn.

### 8. Quyền của bạn
Vì dữ liệu chỉ nằm trên máy bạn, bạn tự thực hiện mọi quyền ngay trong app: xem và sửa từng thói quen, việc, kết quả; xuất toàn bộ dữ liệu ra file (sao lưu hoặc CSV); xóa toàn bộ dữ liệu (cả mã PIN, giờ nhắc và widget) trong Cài đặt → "Xóa toàn bộ dữ liệu"; hoặc gỡ app. Gỡ app sẽ xóa dữ liệu trên máy, trừ các file bạn đã tự xuất, bản sao lưu iPhone/iCloud bạn đã tạo trước đó, và mục mã PIN trong Keychain mà iOS có thể giữ lại (mục 2).

### 9. Trẻ em
Orbiday không nhắm tới trẻ em và không thu thập dữ liệu của bất kỳ ai, kể cả trẻ em. Người từ 13 tuổi trở lên có thể dùng app; nếu bạn dưới tuổi trưởng thành ở nơi bạn sống, hãy hỏi người giám hộ.

### 10. Bảo mật
Dữ liệu được bảo vệ bằng cơ chế cách ly app của Android và iOS, cùng khóa PIN tùy chọn. Khóa PIN giúp ngăn người khác mở app trên máy bạn, nhưng không mã hóa dữ liệu. Ảnh xem trước của app trong màn đa nhiệm có thể hiện thông tin đang mở. Nếu bạn phát hiện lỗ hổng bảo mật, hãy gửi email tới địa chỉ ở mục 12.

### 11. Thay đổi chính sách
Nếu Orbiday thay đổi cách xử lý dữ liệu (ví dụ thêm tính năng cần Internet), chúng tôi sẽ cập nhật chính sách này và ngày hiệu lực trước khi phát hành bản có thay đổi.

### 12. Liên hệ
[ĐIỀN: tên nhà phát triển, đúng như tên hiển thị trên Google Play và App Store], nhà phát triển Orbiday. Email: [ĐIỀN: email liên hệ]

---

## English

### Orbiday Privacy Policy
Effective date: [FILL: publishing date, e.g. 2026-12-01]

Orbiday is a daily habit and to-do planner for Android phones and iPhone. This policy explains what data the app stores, where it is stored, and how you control it.

### 1. We do not collect your data
Orbiday has no server, no user accounts, no ads, and no third-party analytics, tracking or crash reporting tools. The app does not connect to the Internet (on Android it does not even have the Internet permission), so it does not send data anywhere. The Orbiday developer does not receive, view, or share any data you enter in the app.

### 2. Your data stays on your phone
What you enter (habits, to-dos, daily results, reminder times, categories, notes, settings, Pomodoro timer state) is stored only in the app's private storage on your phone. Other apps cannot read it.
- **Android:** the app turns off Android's automatic backup, so your data is not uploaded to the cloud on its own.
- **iPhone:** like any other app, Orbiday's data is included in your iPhone backup if you turn on iCloud Backup or back up your iPhone to a computer. Those backups are managed by Apple and you under Apple's policies; the developer cannot access them.

Habit and to-do names are chosen by you, so they may contain private information (for example a medication schedule). That information also stays only on your phone, like all other data in the app.

If you turn on the PIN lock, the app stores only a salted hash of your PIN, never the PIN itself, in the operating system's secure storage (Android Keystore or the iPhone Keychain, not synced through iCloud Keychain). Note for iPhone: iOS may keep this Keychain item even after you delete the app; if you reinstall, the app may ask for your old PIN. In that case, use "Forgot PIN" to delete the app's data and the PIN.

### 3. Notifications, alarms and the widget
- **Reminders and alarms** are shown by your phone's operating system from a schedule stored on your phone. A notification contains the item's name and may appear on the lock screen. When you turn on the PIN lock, item names are hidden from lock-screen notifications.
- The **"Today" widget** shows today's items on your home screen, using data from the app's private storage on the same device (on iPhone through an App Group, a storage area shared between the app and its widget on the same device). With the PIN lock on, the widget shows only the number of items left, not their names.
- None of the data used by these features is sent to the developer or to any third party.

### 4. Phone permissions
Orbiday asks for a permission only when you use a feature that needs it, and explains why first. The app still works if you say no.
- **Notifications** (Android 13 and later, and iPhone): to show reminders and the Pomodoro end-of-timer alert.
- **Exact alarms and reminders** (Android, `SCHEDULE_EXACT_ALARM`): to remind you at the exact time you set. On Android 14 and later you turn it on yourself in system settings.
- **Full-screen notifications** (Android, `USE_FULL_SCREEN_INTENT`): only for reminders you set to the "Alarm" style, to show the alarm screen over the lock screen. On iPhone this style uses time-sensitive notifications instead of a full-screen screen.
- **Run at startup** (Android, `RECEIVE_BOOT_COMPLETED`) and **vibrate** (`VIBRATE`): to set your reminders up again after the phone restarts and to vibrate with alarms.
- Orbiday does **not** request location, contacts, photos, camera, microphone or storage permissions. Restoring a backup uses the system file picker and reads only the file you pick.

### 5. Backup and CSV files you export
When you choose "Export backup" or export CSV, the app creates the file in its temporary folder and opens your phone's share sheet so you can choose where to send or save it (for example the Files app, Google Drive or email). You decide where the file goes. A `.dailyloop` backup file contains all of the app's data (habits, to-dos, history, categories, reminders, settings) and is **not encrypted**; keep it somewhere safe. From then on, the file is subject to the policy of the service you chose. The operating system clears the app's temporary folder on its own.

### 6. Links to other apps
The "About" screen can open your browser (to show this policy) or your email app (to report a security issue). Those apps follow their own policies.

### 7. Data the app stores may collect
When you install the app from Google Play or the App Store, Google or Apple may collect information about installs and app crashes under their own policies and your device settings (for example, the option on iPhone to share analytics with app developers). The developer sees only aggregated, anonymous figures in Play Console and App Store Connect and cannot use them to identify you.

### 8. Your rights
Because your data is only on your phone, you exercise every right directly in the app: view and edit each habit, to-do and result; export all data to a file (backup or CSV); delete all data (including the PIN, reminders and widget) in Settings → "Delete all data"; or uninstall the app. Uninstalling removes the data on the phone, except files you have exported yourself, iPhone/iCloud backups you made earlier, and the PIN Keychain item that iOS may keep (section 2).

### 9. Children
Orbiday is not directed at children and does not collect data from anyone, including children. People aged 13 and over may use the app; if you are under the age of majority where you live, please ask a parent or guardian.

### 10. Security
Your data is protected by the Android and iOS app sandbox and the optional PIN lock. The PIN lock stops other people from opening the app on your phone, but it does not encrypt the data. The app preview in the multitasking screen may show the information that was open. If you find a security vulnerability, please email the address in section 12.

### 11. Changes to this policy
If Orbiday changes how it handles data (for example by adding a feature that needs the Internet), we will update this policy and its effective date before releasing that version.

### 12. Contact
[FILL: developer name, exactly as shown on Google Play and the App Store], developer of Orbiday. Email: [FILL: contact email]
