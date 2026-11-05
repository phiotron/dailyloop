# A003-dailyloop · Orbiday — APP.md

> Brief + trạng thái của app. **Chỉ phiên điều phối sửa file này**; phiên con ghi báo cáo vào `notes/`.
> App **đã code trước khi vào xưởng** (G1–G6 xong, 2026-11-03..04). Việc thử máy còn lại + biên bản: `docs/MANUAL-TESTS.md`.
> **Tên hiển thị: Orbiday** (tên cũ DailyLoop → Streakloom bị loại vì trùng trên store, chốt 2026-11-05). Tên nội bộ `dailyloop` giữ nguyên
> (mã app, bundle ID, tên repo, DB/kênh native, đuôi file sao lưu `.dailyloop`).

## Brief
- **Mã app / thư mục:** `A003-dailyloop` → `apps/A003-dailyloop/` — đã ghi trong `apps/REGISTRY.md`
- **Bundle ID** (không đổi): `com.phiotron.dailyloop` · **Repo:** https://github.com/phiotron/dailyloop (private; làm việc trên nhánh **`dev`**, `main` chỉ nhận code đã ổn định — WORKFLOW §7)
- **Tên hiển thị:** **Orbiday** — Play/App Store EN `Orbiday: Habits & To-Do`, VI `Orbiday: Thói Quen & Việc`. Chưa tra nhãn hiệu chính thức (WIPO/Cục SHTT/USPTO nhóm 9/42, nhãn ORBI của NETGEAR) và tên miền `orbiday.app/.io` — việc của người dùng.
- **Một câu mô tả:** Lập lịch thói quen và việc cần làm hằng ngày, nhắc đúng giờ, theo dõi chuỗi ngày và thống kê — offline, không tài khoản, không thu thập dữ liệu.
- **Người dùng mục tiêu:** người đi làm, sinh viên, người muốn xây thói quen sức khỏe/học tập; Việt Nam và quốc tế (vi/en).
- **Kiếm tiền:** miễn phí hoàn toàn bản 1 (không quảng cáo, không IAP, không SDK).
- **Nền tảng:** Android + iOS (iOS thêm 2026-11-04; build + test trên GitHub Actions macOS runner — fact xưởng `may-windows-build-ios`) ·
  **Stack:** Flutter 3.47.8, Riverpod 3, go_router, drift/SQLite.
- **Tài liệu tham chiếu:** `docs/SPEC.md` (AC-01..AC-53 — nguồn sự thật về hành vi), `docs/DECISIONS.md`, `docs/ARCHITECTURE.md`,
  `docs/TESTING.md`, `docs/SECURITY.md`, `docs/COMPLIANCE.md`, `docs/RELEASE.md`, `docs/RISKS.md`; thuật ngữ `CONTEXT.md`;
  mô tả gửi Claude Design `product.md` (30 màn SCR-01..30); mockup `design/hifi/` (khi có); store `store/`; thử máy `docs/MANUAL-TESTS.md`.

## MVP (đúng SPEC, F-01..F-14)
1. **Thói quen + lịch lặp** (F-01): 4 kiểu đánh giá (Có/Không, Số lượng, Thời gian, Danh sách con), 5 kiểu lịch lặp, lưu trữ/xóa có hoàn tác, sắp xếp.
2. **Màn Hôm nay + việc cần làm** (F-02, F-03, F-07, F-08): dải ngày, ghi kết quả một chạm, bỏ qua, quá hạn, danh mục, thanh điều hướng.
3. **Nhắc giờ** (F-04): thông báo + chuông báo thức (Android toàn màn hình; iOS thông báo time-sensitive), tối đa 5 giờ/mục.
4. **Chuỗi ngày, điểm, lịch tháng, thống kê** (F-05, F-06).
5. **Pomodoro + widget Hôm nay** (F-09, F-10) · **Sao lưu `.dailyloop`/CSV, khóa PIN, giao diện/ngôn ngữ/a11y, pháp lý** (F-11..F-14).
> Vượt "≤ 5 tính năng" vì app nhập khi đã code xong G1–G6; phần cắt đầu tiên nếu trễ: widget iOS (E), rồi PIN (F-12 + AC-41).

## Màn hình & luồng chính
Tab dưới: Hôm nay `/` · Thói quen `/habits` · Việc `/tasks` · Thống kê `/stats`. Soạn/chi tiết: `/habits/new`, `/habits/:id`,
`/habits/:id/edit`, `/habits/archived`, `/tasks/new`, `/tasks/:id`. Khác: `/pomodoro`, `/categories`, `/settings`, `/alarm` (chuông),
màn chào. G7 sẽ thêm: sao lưu/khôi phục, PIN (cài/khóa), xóa dữ liệu (trong Cài đặt).
Luồng nhanh nhất: mở app (hoặc widget) → chạm ô tròn của mục hôm nay → xong.

## Trạng thái
| Phiên điều phối | Ngày | Phiên con đã mở | Kết quả |
|---|---|---|---|
| #1 Nhập app + product.md + G7 + nền iOS | 2026-11-04..05 | A product.md · B nền iOS + CI · C G7 · D store & pháp lý (+ đổi tên ×2) | **Xong code/tài liệu; chờ người dùng duyệt product.md → Claude Design.** 218 test đạt, analyze sạch, CI Ubuntu + iOS macOS xanh |
| #2 Áp UI Hi-Fi + test 2 nền tảng | | F design system → G, H, I, J song song → K thử máy | |
| #3 Phát hành | | L ảnh store · M Android · N iOS | |

Kế hoạch 3 phiên: `notes/2026-11-04-ke-hoach-3-phien.md`. Báo cáo phiên con #1: `notes/2026-11-04-{product-md,ios-ci,g7,store-legal}.md`.

**Kết quả #1 (đã kiểm thật):** `flutter analyze` sạch · `flutter test` **218 đạt** (169 cũ + 44 G7 + 5 iOS) · APK release build được (phiên C) ·
GitHub Actions: CI Ubuntu xanh, iOS macOS simulator build xanh (run `41993235457`). Đã có: sao lưu `.dailyloop` + CSV, khóa PIN + chuông trên màn khóa,
xóa toàn bộ dữ liệu, receiver đổi giờ/múi giờ (AC-21), nền iOS + nhắc giờ iOS (D-010), 3 workflow, hồ sơ store + chính sách vi/en, `product.md` + `CONTEXT.md`.

**Việc dở / bước tiếp:**
- **Người dùng:** duyệt `product.md` → gửi Claude Design (hướng: bộ nhận diện + design system MỚI cho Orbiday, giữ luồng + phạm vi SPEC) → lưu mockup vào `design/hifi/`.
- **Chưa làm / chưa xong (phiên #2):** widget iOS (WidgetKit + App Group `group.com.phiotron.dailyloop`, phiên con riêng); thông báo ẩn tên khi có PIN (AC-46); `integration_test` trên simulator; icon + màn khởi động iOS thật (chờ icon Orbiday); chỉnh mô tả AC-20/F-04 cho iOS (chuông chỉ là thông báo time-sensitive).
- **iOS còn thiếu (fact `ios-ma-hoa-va-sao-luu`):** loại DB khỏi iCloud/sao lưu hệ thống (`NSURLIsExcludedFromBackupKey` đặt lại mỗi lần mở app qua MethodChannel Swift nhỏ trong `AppDelegate.swift`; Android đã `allowBackup=false`); chính sách đã nói "đổi máy thì tự xuất file". Export compliance hiện `ITSAppUsesNonExemptEncryption=false` đúng vì app chỉ băm SHA-256, không mã hóa tự cài — nếu sau này mã hóa file sao lưu phải đổi thành `true` + khai ANSSI.
- **Chưa kiểm chứng trên máy thật:** phần native AC-21; G3–G7 Android (xem `docs/MANUAL-TESTS.md`); toàn bộ nhắc giờ iOS, ký/TestFlight (không có iPhone, chưa có tài khoản Apple).
- **Người dùng (cần làm):** Apple Developer (cá nhân) + App ID `com.phiotron.dailyloop` bật Time Sensitive Notifications + App Store Connect app "Orbiday" + 7 GitHub Secrets iOS (tên + cách lấy: `docs/RELEASE.md` mục iOS; Claude không tự tạo khóa); Play Console cá nhân + upload keystore ngoài repo + **closed test 12 tester × 14 ngày bắt đầu sớm**; host chính sách quyền riêng tư (`docs/legal/`, bản HTML đã sinh) rồi điền link + email liên hệ; tra nhãn hiệu/tên miền Orbiday; mượn iPhone thử chuông; cho phép thử máy thật Android (máy dùng chung).
- COMPLIANCE: còn các dòng "chưa" liệt kê trong `docs/COMPLIANCE.md` (mỗi dòng ghi ai làm).
- Phút macOS GitHub: mỗi run iOS ~5–6 phút (×10 quota repo private) — chỉ chạy khi đổi `main` hoặc chạy tay.

## Lệnh (đã chạy thật 2026-11-03/04; dùng đúng, không đoán)
Flutter 3.47.8 ở `C:/src/flutter`, **chưa có trong PATH**. Git Bash: `export PATH="/c/src/flutter/bin:$PATH"` trước mọi lệnh.
- Cài: `flutter pub get` (tự sinh file dịch từ `lib/l10n/*.arb`)
- Sinh mã sau khi sửa bảng trong `lib/src/data/database.dart`: `dart run build_runner build` (commit cả `*.g.dart`, D-004)
- Lint/typecheck: `flutter analyze` · Định dạng: `dart format lib test` (rồi chạy lại analyze — format có thể dời `// ignore: recursive_getters`) · Test: `flutter test`
- Chạy: `flutter run -d <id>` (`flutter devices`)
- Build thử Android: `flutter build apk --release` (**không** thêm `--target-platform android-arm64`: Galaxy A13 chạy 32-bit, L-011);
  cài `/c/Users/Admin/AppData/Local/Android/Sdk/platform-tools/adb.exe install -r build/app/outputs/flutter-apk/app-release.apk`
- Bản phát hành Play: `flutter build appbundle` (cần `android/key.properties` + keystore ngoài repo; chưa chạy)
- iOS: build + test trên GitHub Actions macOS runner (`.github/workflows/`, khi phiên con B xong) — Windows không build iOS cục bộ.

## Quy ước code
- `lib/src/data/` (drift, kho dữ liệu) · `lib/src/features/<tính năng>/` (màn hình) · `lib/src/ui/` (widget dùng chung) ·
  `lib/src/reminders/`, `lib/src/pomodoro/`, `lib/src/widget/` · `lib/src/providers.dart` · `lib/src/app.dart` (router, theme) ·
  `lib/l10n/` (.arb + mã sinh). Test phản chiếu ở `test/`.
- Thói quen và việc chung bảng `activities`; lịch lặp ở `schedules` có `effectiveFrom`; ngày = chữ `YYYY-MM-DD`; cài đặt ở bảng `settings` (D-005). Mọi chữ giao diện nằm trong `.arb`.
- "Hôm nay" luôn đọc từ `todayProvider`, không gọi giờ máy trực tiếp (BUG-001).

## Lưu ý dễ vấp
- **Widget test có DB:** tạo DB **bên trong** thân `testWidgets`, `closeStreamsSynchronously: true`, bọc thao tác DB trong `tester.runAsync` (xem `test/helpers.dart`). Trong test import `flutter_test` với `hide Evaluation`.
- **Hai chat chạy `flutter test` cùng lúc** → báo "did not complete": chờ lần kia xong rồi chạy lại. Các phiên con của app này cũng vậy → chạy test **nối tiếp**, không song song.
- **Máy thử Galaxy A13 (Android 14) chỉ chạy 32-bit.** Không tự dùng adb trên điện thoại khi chưa hỏi; máy dùng chung với app khác — kiểm `mCurrentFocus` trước mỗi lần chạm.
- Google Play chỉ cho `USE_EXACT_ALARM` với app báo thức/lịch → **không khai quyền đó**; dùng `SCHEDULE_EXACT_ALARM` do người dùng cấp (D-007).
- **Widget Android ghi thẳng vào `dailyloop.sqlite`, bảng `entries`:** đổi tên bảng/cột phải sửa `WidgetStore.kt` (D-009). Widget CHƯA chạy trên máy thật.
- Lệnh Bash có heredoc dài kèm dấu nháy dễ lỗi "unexpected EOF" → dùng công cụ Write.
- **Git (luật xưởng 2026-11-05, hết phút GitHub Actions):** thư mục app luôn ở `dev`; phiên con commit + push `dev`, không `git switch`. CI KHÔNG chạy trên `dev` → trước khi push tự chạy trên máy `flutter analyze` + `flutter test` (+ `flutter gen-l10n` nếu sửa `.arb`). Chỉ phiên điều phối merge `dev` → `main` (`git push origin dev:main`) sau khi tự chạy lại test; push `main` chỉ chạy job kiểm; build iOS chỉ khi tag `v*` hoặc chạy tay (`ios.yml`).

## Quyết định riêng của app (chi tiết: `docs/DECISIONS.md`)
- **D-001** Flutter; **2026-11-04: thêm iOS vào bản 1.** · **D-002** Chỉ lưu trên máy, không máy chủ, không SDK bên thứ ba.
- **D-003** Flutter 3.47.8, Riverpod 3 viết tay, go_router, l10n `.arb`. · **D-004** drift/SQLite, commit file sinh.
- **D-005** Mô hình dữ liệu: thói quen+việc chung bảng, lịch lặp có `effectiveFrom`. · **D-006** Việc cần làm ghi kết quả vào ngày của việc.
- **D-007** Nhắc giờ: flutter_local_notifications, lịch lăn 7 ngày. · **D-008** Chuỗi/điểm tính từ "đơn vị", biểu đồ tự vẽ. · **D-009** Pomodoro theo mốc thời gian; widget không gói ngoài; **D-010** iOS: chuông = thông báo time-sensitive, lịch lăn ≤ 64.
- **2026-11-04** Vào xưởng với mã `A003-dailyloop`; giữ repo `phiotron/dailyloop`, nhánh `main` (đã xóa `master`); phiên con push `dev` (từ 2026-11-05; CI chỉ ở `main`/tag).
- **2026-11-05** Đổi tên hiển thị DailyLoop → Streakloom → **Orbiday** (trùng tên trên store; xem `store/name-check.md`, `store/name-candidates.md`).
- **D-010..D-013** (iOS nhắc giờ + G7: PIN, sao lưu, gói đã chọn) — chi tiết `docs/DECISIONS.md`.
- **2026-11-04** UI bản 1 = **thiết kế mới** qua Claude Design (giữ nguyên luồng + phạm vi SPEC; không sao chép hình thức app nào).
- **2026-11-04** Widget iOS có (WidgetKit); kiểu "Chuông" trên iOS = thông báo time-sensitive + nút Xong/Hoãn. AC-21: thêm bộ nhận đổi giờ/múi giờ (Android). Phạm vi = đúng SPEC, G7 làm ở #1. Miễn phí hoàn toàn.
- **2026-11-04** Tài khoản Google Play và Apple đứng tên **cá nhân**.

## Retro (điền khi phát hành)
- Tổng phiên điều phối / phiên con:
- Chậm nhất ở đâu, vì sao:
- Thứ tái dùng được cho app sau:
- Cải tiến đề xuất cho Playbook:
