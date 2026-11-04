# [A003-dailyloop] Store & pháp lý 2 nền tảng — báo cáo phiên con

Phiên con của phiên điều phối #1 · 2026-11-04 · phạm vi sửa: chỉ `store/`, `docs/legal/`, `docs/COMPLIANCE.md`, báo cáo này. Không đăng/gửi/đăng ký gì lên store hay web; không nhập thông tin cá nhân.

## Kết luận nhanh (cần người dùng quyết SỚM)
**Tên "DailyLoop" đang trùng nặng, cùng loại app, trên cả hai store**: 3 app thói quen tên DailyLoop/Daily Loop trên Google Play (ByteNest Labs `com.dailyloop.app` — gần như cùng bộ tính năng, có cả chuông toàn màn hình; VikramDev `com.vikramji283.dailyloop`; Try Try Limited `com.dalop.dailyloop`, 10K+ lượt tải) và "DailyLoop – Build Routines" trên App Store (id6747970681). Có thêm đơn nhãn hiệu DAYLOOP (USPTO 99559611, nhóm 42, đang chờ xét). **Khuyến nghị đổi tên trước khi gửi `product.md` cho Claude Design và trước khi tạo app trên hai console.** Ba tên dự phòng đã tra thô trên Play: **Nhịp Ngày**, **Streakloom**, **Ngày Đều** (chi tiết, link bằng chứng và phương án "giữ tên" ở `store/name-check.md`). Chưa tra WIPO/Cục SHTT/tên miền (công cụ không đủ).

## Đã làm / file đổi (tất cả mới, trừ COMPLIANCE sửa)
| File | Nội dung |
|---|---|
| `store/name-check.md` | Kết luận ở đầu; bằng chứng Play/App Store/nhãn hiệu; 3 tên dự phòng ≤ 30 ký tự; phương án giữ tên; danh sách chỗ phải đổi khi đổi tên |
| `store/listing.md` | Play en+vi: tên (3 phương án), mô tả ngắn (77/79 ký tự), mô tả dài (3283/3223 ký tự), từ khóa, danh mục, IARC/độ tuổi, App content, Data safety "không thu thập", **bảng quyền theo manifest THẬT** + lời giải thích Play Console dán sẵn cho `SCHEDULE_EXACT_ALARM` và `USE_FULL_SCREEN_INTENT` (không `USE_EXACT_ALARM`, D-007), What's new, checklist kiểm trước khi nộp |
| `store/app-store.md` | iOS en+vi: tên, subtitle (27/29), keywords (100/96), promo text (154/164), mô tả (3362/3377), age rating, App Privacy "Data Not Collected", export compliance, **review notes về time-sensitive**, thông tin liên hệ, **bảng trạng thái project iOS cần khớp** |
| `store/closed-test-plan.md` | Play 12 tester × 14 ngày: luật, lịch (D0 ≈ 14/11, D14 ≈ 28/11), cách tuyển (Google Group dùng chung được với A002), thư mời/nhắc vi+en, checklist theo dõi, nhật ký, mẫu form production; phần TestFlight (cần Apple Developer, chưa có) |
| `store/screenshots-spec.md` | Kích thước Play (điện thoại 2–8, 1080×2160; icon 512; feature 1024×500) và App Store (6.9" 1320×2868; iPad chỉ nếu bật), 8 khung + chú thích vi/en, dữ liệu mẫu ngày 2026-11-24, cách chụp, **brief icon + feature graphic (tiếng Anh) cho Claude Design** |
| `docs/legal/privacy-policy.md` (+ `web/privacy-policy.html`) | Chính sách vi/en cho Android + iOS: không thu thập, dữ liệu trên máy, thông báo/chuông/widget, quyền, sao lưu `.dailyloop` + CSV không mã hóa, sao lưu iPhone/iCloud, PIN, quyền người dùng, trẻ em ≥ 13 |
| `docs/legal/terms-of-use.md` (+ `web/terms-of-use.html`) | Điều khoản **tùy chọn** (nhắc giờ không đảm bảo, không phải tư vấn y tế, trách nhiệm sao lưu); khuyến nghị dùng EULA chuẩn của Apple |
| `docs/legal/support.md` (+ `web/support.html`) | Trang hỗ trợ (Support URL của App Store): FAQ nhắc giờ, chuyển máy, quên PIN, CSV, widget |
| `docs/legal/build_web.py` | Sinh `web/*.html` từ các `.md` (chỉ lấy phần sau dòng `---` đầu tiên; tô vàng chỗ `[ĐIỀN: …]`; in danh sách chỗ còn trống — hiện 16) |
| `docs/COMPLIANCE.md` | Cập nhật theo kết quả; thêm mục 1b (bản đồ dữ liệu), 1c (quy trình lỗ hổng/sự cố), 4 (còn lại + ai làm) |

## COMPLIANCE — kết quả
- **Đạt mới:** D-01 (bản đồ dữ liệu), D-08 (kịch bản sự cố — bản nháp), P-06 (targetSdk 36), P-07 (16 KB: zipalign + LOAD align các `.so` 64-bit, APK 2026-11-04). P-04 → không áp dụng.
- **Chuyển sang chưa vì iOS vào v1:** P-01, P-02, P-03, P-05 (kèm việc cụ thể).
- **Còn "chưa" (21 dòng), ai làm:** người dùng — M-01, D-02 (host chính sách), P-05, P-08, P-09, P-10; luật sư — D-07, D-09, S-06, C-03; phiên code/CI — D-11, S-05, P-01..P-03; phiên sau — S-01 (MASVS), S-04 (SBOM), A-01, T-02, D-06, D-12 (quyết định). Chi tiết bảng mục 4 của COMPLIANCE.
- Nguồn tiêu chuẩn: `D:/DemoChung/shared/standards/tieu-chuan-ban-app-toan-cau.md` **còn đọc được** (2026-11-04) → giữ tham chiếu, đã ghi rõ "nguồn ngoài xưởng" + đề xuất chép sang `reference/`. Các mốc ngày trong bảng lấy từ file đó (cập nhật 28/10/2026); **chưa** mở trang Apple/Google chính thức để kiểm lại.

## Cách kiểm (đã chạy)
- Đếm ký tự bằng Python (`len`, Unicode): mọi trường ở bảng trên nằm trong giới hạn (tên ≤ 30: 25–28; mô tả ngắn ≤ 80: 77/79; keywords ≤ 100: 100/96 — **EN keywords đúng 100, sát trần**; subtitle ≤ 30: 27/29; promo ≤ 170: 154/164; mô tả dài ≤ 4000). Số hiển thị ngay trong file bên cạnh từng trường.
- Quyền: đọc `AndroidManifest.xml` nguồn + manifest đã gộp + `aapt2 dump badging` trên `build/app/outputs/flutter-apk/app-release.apk` (build 2026-11-04 14:45): `SCHEDULE_EXACT_ALARM, USE_FULL_SCREEN_INTENT, RECEIVE_BOOT_COMPLETED, VIBRATE, POST_NOTIFICATIONS` + quyền nội bộ AndroidX; **không** INTERNET, USE_EXACT_ALARM, WAKE_LOCK, FOREGROUND_SERVICE*, AD_ID. targetSdk 36. Zipalign 16 KB đạt.
- Tên: tra trực tiếp trang tìm kiếm Play Store và trang App Store trong trình duyệt tích hợp + WebSearch (không đăng ký gì).
- HTML: mở `web/privacy-policy.html` trong trình duyệt tích hợp, bố cục điện thoại đọc tốt; chạy `python docs/legal/build_web.py` OK.
- Nội dung store đối chiếu SPEC F-01..F-14: không hứa tính năng ngoài SPEC; chuông toàn màn hình + tick-widget chỉ Android; iOS = thông báo time-sensitive; "tuỳ chọn khác" như đồng bộ đám mây, mã hóa, AI không xuất hiện.

## Việc dở và việc người dùng phải làm
**Người dùng (theo thứ tự đường găng):**
1. **Quyết tên** (name-check) → báo phiên điều phối để đổi `product.md`/mockup/`android:label`/`CFBundleDisplayName`.
2. Điền chỗ `[ĐIỀN: …]` (email liên hệ, tên nhà phát triển đúng tên trên Play/App Store, ngày hiệu lực; Điều khoản: luật áp dụng — hỏi luật sư), chạy `python docs/legal/build_web.py`, **host** 3 trang HTML (Google Sites/GitHub Pages public riêng — gợi ý ở đầu `privacy-policy.md`), lấy URL → điền vào app (phiên code), Play Console, App Store Connect.
3. Keystore upload ngoài repo → AAB → tạo app trên Play Console → điền App content/Data safety/khai báo quyền theo `store/listing.md` → closed test (gom ≥ 15 tester; có thể chung nhóm với A002) — `store/closed-test-plan.md`.
4. Đăng ký Apple Developer (cá nhân, 99 USD) → App ID `com.phiotron.dailyloop` (+ time-sensitive + App Groups) → khóa API vào GitHub Secrets → record app trong App Store Connect.
5. (Tùy) tra WIPO/Cục SHTT/tên miền cho tên chốt; nhờ Claude Design làm icon + feature graphic bằng brief ở `screenshots-spec.md` mục 5.

**Phiên điều phối / phiên con khác (thấy khi đối chiếu code, không sửa vì ngoài phạm vi):**
- **iOS (`ios/` khung thô lúc đọc):** `TARGETED_DEVICE_FAMILY = "1,2"` (có iPad) → khuyến nghị `1` (không thì phải chụp/thử iPad); `CFBundleDisplayName = "Dailyloop"`; thiếu `ITSAppUsesNonExemptEncryption=false`, `PrivacyInfo.xcprivacy`, entitlement time-sensitive, App Group; cho phép xoay ngang trong khi SPEC chỉ màn dọc. Bảng ở đầu `store/app-store.md` liệt kê để đối chiếu.
- **iOS giới hạn 64 thông báo chờ** vs lịch lăn 7 ngày/100 lần (D-007) — thấy `test/data/reminder_ios_limit_test.dart` chưa commit nên có vẻ đã được xử lý; kiểm khi commit.
- **Pomodoro xin quyền thông báo không có màn giải thích trước** (`lib/src/features/pomodoro/pomodoro_screen.dart:79`, SPEC mục 5 + AC-18) — ghi ở COMPLIANCE D-11.
- **Chính sách viết theo SPEC cho phần G7/iOS (chưa thấy code hoàn chỉnh):** PIN trong Keychain còn sau khi gỡ app (iOS), liên kết chính sách trong Giới thiệu, thư mục tạm cho file xuất. Khi G7 + iOS xong cần đối chiếu lại (đã đánh dấu ở ghi chú đầu `privacy-policy.md`). Ngoài ra `docs/SECURITY.md` và `docs/RELEASE.md` vẫn là mẫu rỗng (ngoài phạm vi phiên này).
- Ảnh thật chưa chụp (đúng kế hoạch: #3 với UI mới). `store/brand/` chưa có icon/ảnh bìa.

## Rủi ro
1. **Trùng tên / khiếu nại nhãn hiệu** (trên) — rủi ro cao nhất; hậu quả xấu nhất: bị gỡ sau 14 ngày closed test.
2. **Google từ chối `USE_FULL_SCREEN_INTENT` / `SCHEDULE_EXACT_ALARM`** vì DailyLoop không phải app báo thức chính. Đã thiết kế sẵn lùi: chuông → thông báo nổi thường, nhắc giờ không chính xác tuyệt đối (AC-20, D-007). Không chặn closed test; nếu bị từ chối phải gỡ quyền ở bản kế (phiên code) và sửa dòng mô tả. Form khai báo thật chưa thấy khi soạn — lời giải thích viết sẵn dựa chính sách Play đã tra ở D-007, **cần chỉnh theo câu hỏi thật trên màn hình**.
3. **Mô tả nói những gì chưa thử máy** (widget, Pomodoro khi tắt màn hình, PIN/sao lưu G7, VoiceOver/TalkBack): checklist "Kiểm trước khi nộp" ở cuối `listing.md` và `app-store.md`; câu về TalkBack/VoiceOver chỉ giữ nếu thử được.
4. **Play có thể bắt khai "Health apps"** nếu thấy ví dụ nước/vận động — mô tả đã tránh ví dụ y tế; điền thật theo câu hỏi hiện hành.
5. **Android 16 / targetSdk 36 bỏ qua khóa màn dọc trên máy tính bảng/gập** — test bố cục ở phiên #2; ảnh tablet không bắt buộc.
6. App Review iOS có thể hỏi về time-sensitive notifications (đã chuẩn bị ghi chú) và về việc không có đăng nhập (không cần).
7. Phụ thuộc đã tra từ trang web công cộng ngày 2026-11-04 (danh sách app, số lượt tải) có thể đổi.

## Đề xuất cải tiến xưởng
- **Bộ hồ sơ store dùng chung (`playbook/templates/store/`):** hai app (A002, A003) đã có cấu trúc gần như giống hệt — `listing.md`, `app-store.md`, `closed-test-plan.md`, `screenshots-spec.md`, `privacy-policy.md` + khối "App content/Data safety không thu thập/IARC/Age Rating/Export compliance" chỉ đổi tên, tính năng và quyền. Tách khối chuẩn (luật closed test, bảng kích thước ảnh, câu trả lời form production, mẫu mời tester, thư mục `web/` + `build_web.py`) để phiên con chỉ điền phần riêng của app → tiết kiệm ~60% công và hết lệch giữa app.
- **Bước "tra tên" đưa lên TRƯỚC khi tạo `APP.md`/`product.md`** (đầu `Playbook` giai đoạn Khởi động): đây là lần thứ hai app bị phát hiện trùng muộn; thêm checklist: Play + App Store + WIPO + tên miền + 3 tên dự phòng.
- **Một nhóm tester Google dùng chung cho cả xưởng** (`phiotron-testers`) + file danh sách tester ở ngoài repo; mỗi app một link opt-in. Ghi vào `memory/facts`.
- **Script `build_web.py` → `tool/` cấp xưởng** (đã tổng quát: nhận danh sách trang); thêm bước kiểm "còn `[ĐIỀN]`" trước khi cho đăng. Tương tự script đếm ký tự store (đã dùng ở đây) nên thành lệnh một dòng.
- **Chép tiêu chuẩn `tieu-chuan-ban-app-toan-cau.md` vào `reference/`** (đang nằm ngoài xưởng ở DemoChung; COMPLIANCE của cả hai app trỏ vào đó).
- Quy tắc song song: các phiên con cùng thư mục thấy file của nhau chưa commit (`ios/`, `lib/` G7) — tiện cho đối chiếu nhưng dễ nhầm; nên ghi vào brief mẫu "đọc, đừng sửa, đừng stage".
