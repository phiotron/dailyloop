# Kế hoạch closed test — DailyLoop (Google Play cá nhân 12 tester × 14 ngày + TestFlight iOS)

Soạn 2026-11-04. Mục đích: (Android) đủ điều kiện xin quyền **production** cho tài khoản Play **cá nhân** (COMPLIANCE P-09); (iOS) có đường thử trước khi nộp App Store.
Mẫu: `apps/A002-vigon/store/closed-test-plan.md`. Fact xưởng: `memory/facts/tai-khoan-store.md` (Play cá nhân đã có; Apple Developer **chưa có** tới 2026-11-04).

> **Làm TRƯỚC khi tạo app trên Play Console:** chốt tên (xem `store/name-check.md` — "DailyLoop" trùng nặng) và có URL chính sách (`docs/legal/web/`). Tên gói `com.phiotron.dailyloop` không đổi được sau khi tạo app; tên hiển thị thì đổi được.

## A. Google Play — closed test

### Luật cần đạt (kiểm lại trong Play Console Help ngày bắt đầu — luật có thể đổi)
- Có một **closed test** đang chạy; khi bấm xin production phải có **ít nhất 12 tester đang opt-in**, đã opt-in **liên tục 14 ngày gần nhất** (Play Console Help "App testing requirements for new personal developer accounts").
- Đồng hồ 14 ngày chỉ chạy khi bản closed test **đã được Google duyệt** và **đủ 12 người opt-in**. Tester rời chương trình làm số người tụt dưới 12 → các ngày đó không tính. **Không pause/halt track** (có thể mất chuỗi ngày).
- Áp dụng **cho từng app** của tài khoản. Tester phải dùng tài khoản Google thật trên máy Android thật (máy ảo/tài khoản trùng không tính).
- Google xem cả **tương tác thật**: tester mở app vài lần trong tuần, có phản hồi. Không mua "dịch vụ tester ảo".
- Mục tiêu: **15–20 tester** (dư 3–8 người), giữ đủ **14 ngày + 2 ngày đệm**.
- **Dùng chung nhóm tester với Ví Gọn (A002)?** Được: một Google Group (ví dụ `phiotron-testers`) thêm vào track closed test của **cả hai app**; mỗi tester phải opt-in **riêng cho từng app** (mỗi app một link opt-in) và cài cả hai app. Người nào chịu cài cả hai thì tính cho cả hai app → đỡ tuyển; nhưng đừng bắt mỗi người dùng quá nhiều app (tương tác thật kém đi). Nên có ≥ 15 người cho mỗi app.

### Điều kiện trước khi đẩy bản closed test (đường găng)
| # | Việc | Ai | Ghi chú |
|---|---|---|---|
| 1 | **Chốt tên** (`name-check.md`) | Người dùng | Đổi sau khi gửi Claude Design = làm lại logo |
| 2 | Tài khoản Play cá nhân: xác minh danh tính + xác minh có thiết bị Android (nếu chưa) | Người dùng | Đã có theo fact xưởng; kiểm trạng thái xác minh |
| 3 | Host chính sách + trang hỗ trợ (`docs/legal/web/*.html`), lấy URL; điền email/tên/ngày | Người dùng | Play bắt khai Privacy policy + Data safety trước khi gửi duyệt bất kỳ track nào |
| 4 | Tạo upload keystore NGOÀI repo, `android/key.properties` | Người dùng | `docs/RELEASE.md` (hiện còn mẫu rỗng) — **không commit** |
| 5 | Build `flutter build appbundle` (bản `1.0.0+1`; mỗi lần đẩy build mới tăng số sau `+`), đã chạy thử bản release trên máy thật | Người dùng/phiên điều phối | Nên có G7 (sao lưu/PIN/xóa) trong build, vì mô tả nói có |
| 6 | Tạo app trong Play Console: ngôn ngữ mặc định en-US (+ vi-VN), App, Free | Người dùng | Nội dung `store/listing.md` |
| 7 | Điền đủ App content (privacy policy, ads, app access, content rating, target audience, Data safety, **khai báo full-screen intent/exact alarm nếu form hiện**…) | Người dùng | Trả lời sẵn ở `store/listing.md`; lời giải thích dán sẵn |
| 8 | Store listing tối thiểu: mô tả ngắn/dài, icon 512, ảnh bìa 1024×500, ≥ 2 ảnh điện thoại | Người dùng | Closed test dùng tạm ảnh chụp UI hiện tại; ảnh đẹp làm ở #3 |
| 9 | Có danh sách ≥ 15 tester đồng ý tham gia | Người dùng | Mục "Mời tester" |

### Lịch đề xuất (bắt đầu 2026-11-04; điều chỉnh theo thực tế)
| Ngày (dự kiến) | Mốc |
|---|---|
| 04–07/11 | Bước 1, 3, 4, 9 song song: chốt tên, host chính sách, tạo keystore, gom tester |
| 08–10/11 | Bước 5–8: build AAB (sau khi G7 + sửa tên vào build), tạo app, điền App content, tạo track **Closed testing**, thêm Google Group, gửi duyệt |
| 10–14/11 | Google duyệt bản closed test (vài giờ tới vài ngày; lần đầu của tài khoản có thể lâu hơn). Duyệt xong: gửi link opt-in, nhắc cài trong ngày |
| **Ngày 0** (≈ 14/11) | Đủ ≥ 12 người opt-in → bắt đầu đếm. Ghi ngày này vào "Nhật ký" |
| Ngày 3, 7, 11 | Gửi tin nhắc (mẫu dưới). Kiểm số opt-in trong Play Console (Testing → Closed testing → Testers) |
| Giữa kỳ (phiên #2) | Đẩy build UI mới vào **cùng track** (tăng versionCode) — không tạo track mới, không pause track cũ |
| **Ngày 14** (≈ 28/11) | Kiểm: ≥ 12 người opt-in suốt 14 ngày. Đợi thêm 1–2 ngày đệm |
| ≈ 29/11–01/12 | Dashboard → "Apply for production" → điền form (câu trả lời mẫu dưới) |
| ≈ 01/12–08/12 | Google xét đơn (thường tới ~7 ngày). Được duyệt → phiên #3 đẩy bản production (+ ảnh store mới) |
Nếu đơn bị từ chối: đọc lý do, kéo dài test thêm 14 ngày với tương tác nhiều hơn, rồi xin lại. Nếu Google từ chối quyền full-screen intent/exact alarm: xem `store/listing.md` mục Rủi ro (không chặn closed test).

### Mời tester
**Khuyên dùng: Google Group** (thêm/bớt người không phải sửa Play Console).
1. groups.google.com → Create group, tên ví dụ `phiotron-testers` (nếu đã tạo cho A002 thì dùng lại). Chỉ người được mời tham gia; chỉ quản lý thấy danh sách thành viên (giữ riêng tư email tester).
2. Mời tester vào nhóm (Members → Add members, hoặc gửi link nhóm để họ bấm Join).
3. Play Console → Testing → Closed testing → track → Testers → **Google Groups** → nhập email nhóm → Save.
4. Copy **link opt-in** ("Join on the web") ở tab Testers, gửi cho tester.
5. Tester mở link **bằng đúng tài khoản Google đang dùng trên điện thoại Android** → "Become a tester" → bấm link tải trên Google Play → cài.

**Thay thế: danh sách email** (Testers → Email lists → Create list, dán email Gmail từng người) — hợp khi < 20 người và ổn định.
Lưu danh sách tester (tên + email) ở chỗ riêng của người dùng, **không commit vào repo** (dữ liệu cá nhân của người khác).

Nguồn tester: người thân, đồng nghiệp, bạn bè dùng Android; nhóm cộng đồng dev Việt Nam hỗ trợ test chéo (chỉ nhận người thật dùng thật). Mỗi người cần: máy Android (ưu tiên Android 13+ để thử xin quyền thông báo; có người dùng Samsung/Xiaomi/Oppo để thử nhắc giờ), tài khoản Google, đồng ý ở lại ≥ 16 ngày.

### Mẫu tin nhắn (người dùng tự gửi; Claude không gửi)
**Lời mời (vi):**
> Chào bạn, mình đang làm app thói quen và việc hằng ngày "[tên app]" (miễn phí, không quảng cáo, chạy offline, không cần tài khoản). Google bắt app mới phải có ít nhất 12 người thử trong 14 ngày liền mới được phát hành. Bạn giúp mình nhé:
> 1) Vào link [link nhóm] bấm tham gia; 2) mở [link opt-in] bằng đúng Gmail trên điện thoại Android, bấm "Become a tester"; 3) cài app từ Google Play. Bạn chỉ cần **giữ tham gia và giữ app trên máy ít nhất 16 ngày (tới [ngày])**, mở app đánh dấu vài thói quen mỗi ngày, thử đặt giờ nhắc 1–2 lần. App không gửi dữ liệu nào đi. Góp ý (nhất là giờ nhắc có đúng giờ không, trên máy hãng nào) gửi mình qua [email/Zalo] hoặc nút "Gửi phản hồi" trên trang Play. Cảm ơn bạn!

**Invite (en):**
> Hi! I'm building "[app name]", a free, ad-free, fully offline habit and to-do planner (no account needed). Google requires new apps to be tested by at least 12 people for 14 days in a row before release. Could you help? 1) Join [group link]; 2) open [opt-in link] with the Google account on your Android phone and tap "Become a tester"; 3) install from Google Play. Please **stay in the test and keep the app installed for at least 16 days (until [date])**, tick off a few habits each day and try setting a reminder once or twice. The app sends no data anywhere. Feedback (especially whether reminders arrive on time, and on which phone brand): [email] or "Send feedback" on the Play page. Thank you!

**Nhắc ngày 3 / 7 / 11 (vi):**
> Nhắc nhẹ: [tên app] đang ở ngày [n]/14 của đợt thử. Bạn đừng bấm "Leave the program" và đừng gỡ app tới [ngày] nhé. Mở app đánh dấu 1–2 thói quen giúp mình; thử đặt một giờ nhắc xem có kêu đúng giờ không. Có lỗi gì cứ nhắn mình. Cảm ơn!

**Khi có build mới (vi):**
> [tên app] vừa có bản mới [mô tả ngắn]. Vào Google Play → [tên app] → Cập nhật. Bạn thử [màn/tính năng] rồi góp ý giúp mình nhé.

### Theo dõi trong 14 ngày — checklist
- [ ] Mỗi lần nhắc: xem số tester opt-in; < 14 người thì mời thêm ngay.
- [ ] Gom góp ý vào `notes/<ngày>-closed-test-feedback.md` (tóm tắt, **không** chép email/tên tester). Lỗi thật → mở việc sửa ở phiên #2.
- [ ] Play Console → Quality → Android vitals (crash/ANR) và Pre-launch report (Google tự chạy app trên máy thật): xem hằng tuần; mục tiêu ≥ 99,5% không crash (SPEC 5b).
- [ ] Hỏi riêng 3–5 tester về **nhắc giờ** (đúng giờ? hãng máy? tiết kiệm pin?) — đây là rủi ro lớn nhất (SPEC mục 7) và là tương tác thật để kể trong form production.
- [ ] Ghi số liệu cho form production: số tester, số build đã đẩy, số góp ý, thay đổi đã làm.
- [ ] Không pause track, không xóa tester khỏi nhóm giữa kỳ, không gỡ bản khỏi track.

### Nhật ký (điền khi chạy)
| Ngày | Số opt-in | Build (versionCode) | Việc / góp ý chính |
|---|---|---|---|
| | | | |

### Câu trả lời mẫu cho form "Apply for production"
Form bằng tiếng Anh; câu hỏi có thể đổi. **Thay mọi `[...]` bằng số liệu thật** — không bịa số, Google đối chiếu với dữ liệu track.
- **How did you recruit users for your closed test?**
  `I invited friends, family and colleagues who use Android phones and keep daily routines or to-do lists, through a Google Group. [N] testers joined; all used their own phones and Google accounts.`
- **How easy was it to recruit testers?** → chọn mức đúng thực tế.
- **Describe the engagement you received from testers during your closed test.**
  `Testers created habits and to-dos, ticked them off daily, tried reminders and alarms, the Pomodoro timer, the home screen widget, backup/restore and the PIN lock over [14+] days. I sent reminders on days 3, 7 and 11 and released [K] updated builds that testers installed through Play.`
- **Provide a summary of the feedback you received and how you collected it.**
  `Feedback came through Play private feedback and direct messages. Main points: [vd: nhắc giờ trễ trên máy hãng X khi bật tiết kiệm pin, chữ nhỏ ở màn Y, lỗi Z khi khôi phục].`
- **Who is the intended audience of your app?**
  `Teenagers (13+) and adults in Vietnam and worldwide who want a simple, private way to build daily habits and keep a to-do list, in Vietnamese or English.`
- **Describe how your app provides value to users.**
  `DailyLoop puts habits and to-dos in one list for today, reminds users at the times they choose, and shows streaks and stats. It works fully offline with no account and no data collection, so personal routines never leave the phone.`
- **How many installs do you expect in your first year?** → mức thấp, thực tế (ví dụ "0–10K").
- **What changes did you make based on closed testing?**
  `[liệt kê thay đổi thật, vd: redesigned the home screen (build [k]); fixed [lỗi] reported by testers; added a battery-optimization hint for reminders].`
- **How did you decide that your app is ready for production?**
  `All planned features passed [N] automated tests and manual checks on real devices; no crashes or ANRs in Android vitals during the test; tester issues were fixed and verified in build [k].`

## B. iOS — TestFlight (không có luật 12 tester/14 ngày)
Apple **không** đòi số tester/ngày. TestFlight để thử trước khi nộp; nộp thẳng App Store vẫn được (Apple review từng build).
| # | Việc | Ai | Ghi chú |
|---|---|---|---|
| 1 | Đăng ký **Apple Developer Program (cá nhân)**, 99 USD/năm; có thể mất 1–2 ngày hoặc lâu hơn | Người dùng | **Chưa có** (2026-11-04) — đường găng của iOS; làm sớm |
| 2 | Tạo App ID `com.phiotron.dailyloop` + bật **Push/Notifications time-sensitive** và **App Groups** (nếu có widget) + App Group; tạo record app trong App Store Connect (tên, SKU `dailyloop-ios-1`) | Người dùng | `store/app-store.md` |
| 3 | Tạo khóa API App Store Connect → GitHub Secrets repo `phiotron/dailyloop` | Người dùng | APP.md "Việc dở"; workflow CI do phiên con "nền iOS" |
| 4 | CI build + ký + upload lên TestFlight (`release-ios.yml`) | Phiên điều phối #3 / CI | Windows không build iOS cục bộ |
| 5 | **Tester nội bộ** (tối đa 100; phải là thành viên App Store Connect, mời bằng Apple ID): không cần Beta App Review, thấy build sau ~vài phút | Người dùng | Phù hợp nhất nếu chỉ vài người quen có iPhone |
| 6 | **Tester ngoài** (tối đa 10.000, mời bằng email hoặc **link công khai**): build đầu cần **Beta App Review** (~1–2 ngày); build có "What to Test" | Người dùng | Dùng lời mời mẫu (iOS) dưới đây |
| 7 | Điền App Review notes, ảnh, privacy → nộp App Store | #3 | `store/app-store.md` |
Giới hạn: người dùng không có iPhone → thử iOS bằng simulator trên GitHub Actions (xem `docs/RELEASE.md` mục iOS khi có). **Simulator không thử được thông báo time-sensitive thật, widget thật trên màn hình chính khóa, hay độ trễ nhắc giờ** → rất nên có ít nhất 3–5 tester iPhone qua TestFlight để thử nhắc giờ/chuông/Pomodoro/widget (đây là rủi ro lớn nhất của iOS: giới hạn 64 thông báo chờ, Tập trung/Không làm phiền). Build TestFlight hết hạn sau 90 ngày.

**Lời mời TestFlight (vi):**
> Chào bạn, mình có bản thử app "[tên app]" cho iPhone (miễn phí, offline, không tài khoản). Bạn cài app **TestFlight** từ App Store, rồi mở link [link TestFlight] và bấm "Cài đặt". Bạn thử đặt vài thói quen + giờ nhắc (nhớ cho phép thông báo), xem nhắc có tới đúng giờ không, thử widget và đồng hồ Pomodoro. Góp ý trong TestFlight (chụp ảnh màn hình → Gửi phản hồi) hoặc nhắn mình. Cảm ơn!

**TestFlight invite (en):**
> Hi! I have a test build of "[app name]" for iPhone (free, offline, no account). Install **TestFlight** from the App Store, open [TestFlight link] and tap "Install". Please create a few habits with reminder times (allow notifications), check that reminders arrive on time, and try the widget and the Pomodoro timer. Send feedback from TestFlight (take a screenshot → Send Feedback) or message me. Thank you!

**"What to Test" (en, dùng với What's New bản đầu):** `Create habits and to-dos, set reminder times (try the Alarm style), complete items from notifications, try the Pomodoro timer and the Today widget, export and restore a backup.`
