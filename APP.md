# A003-dailyloop · DailyLoop — APP.md

> Brief + trạng thái của app. **Chỉ phiên điều phối sửa file này**; phiên con ghi báo cáo vào `notes/`.
> App **nhập từ DemoChung** (APP-002, đã qua G1–G6 ở đó 2026-11-03..04). Lịch sử quy trình cũ (BACKLOG đầy đủ + biên bản thử
> máy G1–G6, RUNBOOK, retro mẫu, CLAUDE.md app, nhật ký phiên): `notes/archive-demochung/` — chỉ đọc.

## Brief
- **Mã app / thư mục:** `A003-dailyloop` → `apps/A003-dailyloop/` — đã ghi trong `apps/REGISTRY.md`
- **Bundle ID** (không đổi): `com.phiotron.dailyloop` · **Repo:** https://github.com/phiotron/dailyloop (private, nhánh `main`)
- **Một câu mô tả:** Lập lịch thói quen và việc cần làm hằng ngày, nhắc đúng giờ, theo dõi chuỗi ngày và thống kê — offline, không tài khoản, không thu thập dữ liệu.
- **Người dùng mục tiêu:** người đi làm, sinh viên, người muốn xây thói quen sức khỏe/học tập; Việt Nam và quốc tế (vi/en).
- **Kiếm tiền:** miễn phí hoàn toàn bản 1 (không quảng cáo, không IAP, không SDK).
- **Nền tảng:** Android + iOS (iOS thêm 2026-11-04; build + test trên GitHub Actions macOS runner — fact xưởng `may-windows-build-ios`) ·
  **Stack:** Flutter 3.47.8, Riverpod 3, go_router, drift/SQLite.
- **Tài liệu tham chiếu:** `docs/SPEC.md` (AC-01..AC-53 — nguồn sự thật về hành vi), `docs/DECISIONS.md`, `docs/ARCHITECTURE.md`,
  `docs/TESTING.md`, `docs/SECURITY.md`, `docs/COMPLIANCE.md`, `docs/RELEASE.md`, `docs/RISKS.md`; thuật ngữ `CONTEXT.md` (khi có);
  mô tả gửi Claude Design `product.md` (khi có); mockup `design/hifi/` (khi có); store `store/`.

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
| #1 Chuyển + product.md + G7 + nền iOS | 2026-11-04 | A product.md · B nền iOS + CI · C G7 (sao lưu/PIN/xóa/AC-21) · D store & pháp lý | đang chạy |
| #2 Áp UI Hi-Fi + test 2 nền tảng | | F design system → G, H, I, J song song → K thử máy | |
| #3 Phát hành | | L ảnh store · M Android · N iOS | |

Kế hoạch đầy đủ 3 phiên: `notes/2026-11-04-ke-hoach-3-phien.md`.
Đã có ở thời DemoChung: G1–G6 xong code, 169 test đạt, `flutter analyze` sạch, APK release build được. **Chưa thử máy thật:** phần lớn G3–G6
(widget, Pomodoro báo hết giờ, thông báo/chuông nhiều tình huống) — xem biên bản trong `notes/archive-demochung/BACKLOG.md`.

**Việc dở / bước tiếp:**
- Phiên #1: duyệt `product.md` → người dùng gửi Claude Design, lưu mockup vào `design/hifi/`.
- Người dùng: Apple Developer (cá nhân) + App ID `com.phiotron.dailyloop` + App Group (cho widget iOS) + khóa API → GitHub Secrets repo `phiotron/dailyloop`.
- Người dùng: Play Console cá nhân → **closed test 12 tester × 14 ngày** (bắt đầu sớm bằng build hiện tại); upload keystore ngoài repo (`docs/RELEASE.md`).
- Người dùng: đăng chính sách lên web lấy link; TalkBack + cỡ chữ lớn nhất; cho phép thử máy thật (Galaxy A13 dùng chung với chat khác).
- Mở từ SPEC/backlog cũ: thử máy thật G1–G6; dữ liệu thử "Test nuoc" còn trên máy (xóa khi máy rảnh); khai báo full-screen intent trong Play Console (G8).
- COMPLIANCE còn "chưa" ở các dòng áp dụng — D phiên con rà lại.
- Ý tưởng ngoài SPEC (KHÔNG tự làm): hỏi "Bỏ thay đổi?" khi Back ở màn soạn; hộp nhập ghi rõ ngày đang sửa từ lịch tháng; sao lưu Google Drive; mẫu thói quen/thử thách; widget từng thói quen; mở khóa vân tay.

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
- Chỉ push `main` khi cần (CI iOS); không đổi nhánh trong thư mục dùng chung.

## Quyết định riêng của app (chi tiết: `docs/DECISIONS.md`)
- **D-001** Flutter; **2026-11-04: thêm iOS vào bản 1.** · **D-002** Chỉ lưu trên máy, không máy chủ, không SDK bên thứ ba.
- **D-003** Flutter 3.47.8, Riverpod 3 viết tay, go_router, l10n `.arb`. · **D-004** drift/SQLite, commit file sinh.
- **D-005** Mô hình dữ liệu: thói quen+việc chung bảng, lịch lặp có `effectiveFrom`. · **D-006** Việc cần làm ghi kết quả vào ngày của việc.
- **D-007** Nhắc giờ: flutter_local_notifications, lịch lăn 7 ngày. · **D-008** Chuỗi/điểm tính từ "đơn vị", biểu đồ tự vẽ. · **D-009** Pomodoro theo mốc thời gian; widget không gói ngoài.
- **2026-11-04** Chuyển từ DemoChung vào xưởng, mã `A003-dailyloop`; giữ repo `phiotron/dailyloop`, đổi nhánh `master`→`main`; phiên con được push (CI iOS).
- **2026-11-04** UI bản 1 = **thiết kế mới** qua Claude Design (giữ nguyên luồng + phạm vi SPEC; không sao chép hình thức app nào).
- **2026-11-04** Widget iOS có (WidgetKit); kiểu "Chuông" trên iOS = thông báo time-sensitive + nút Xong/Hoãn. AC-21: thêm bộ nhận đổi giờ/múi giờ (Android). Phạm vi = đúng SPEC, G7 làm ở #1. Miễn phí hoàn toàn.
- **2026-11-04** Tài khoản Google Play và Apple đứng tên **cá nhân**.

## Retro (điền khi phát hành)
- Tổng phiên điều phối / phiên con:
- Chậm nhất ở đâu, vì sao:
- Thứ tái dùng được cho app sau:
- Cải tiến đề xuất cho Playbook:
