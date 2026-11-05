# [A003-dailyloop] Kế hoạch 3 phiên điều phối (cập nhật 2026-11-05)

> Tên hiển thị **Orbiday** (mã nội bộ `A003-dailyloop`). Phiên #1 đã xong code/tài liệu — kết quả ở `APP.md` mục Trạng thái.
> Mục tiêu: app xong trong 2–3 phiên điều phối; bản 1 Android + iOS, miễn phí, đúng SPEC.

## Phiên #1 — ĐÃ XONG (2026-11-04..05)
Nhập app (mã A003, nhánh `main`, dọn quy trình cũ) · A product.md + CONTEXT.md · B nền iOS + CI (iOS macOS xanh) · C G7 (sao lưu, PIN, xóa dữ liệu, AC-21; 218 test) · D store + pháp lý + tra tên (DailyLoop → Streakloom → **Orbiday**).
Còn chờ người dùng: duyệt `product.md` → Claude Design → `design/hifi/`.

## Quy tắc cho #2, #3 (rút từ #1 + fact xưởng)
- Phiên con **không hỏi người dùng tại chỗ**: câu hỏi/báo xong → `SendMessage` về phiên chính (brief ghi tên phiên chính).
- Phiên giữ dependency (F) được sửa luôn `android/` gradle + manifest + `ios/` Info.plist/Podfile mà gói đòi, và **build release Android + iOS simulator xanh** trước khi báo xong.
- Không tự tạo keystore/chứng chỉ/API key/secrets — hướng dẫn người dùng tự làm.
- Chạy `flutter test` nối tiếp, không song song giữa các phiên; xem `get_usage` trước khi mở nhiều phiên con (≤ 4 cùng lúc).
- Ảnh/mockup: theo WORKFLOW §3 luật 7 (không để ảnh nằm lại ngữ cảnh).

## Phiên điều phối #2 — Áp UI Hi-Fi + test 2 nền tảng (bắt đầu khi có `design/hifi/`)
| Phiên con | Phạm vi | Thứ tự |
|---|---|---|
| F. Design system: token → ThemeData sáng/tối, `lib/src/ui/` widget chung, icon/splash/logo, **toàn bộ chữ mới vào `.arb`** | `lib/src/app.dart` (theme), `lib/src/ui/`, `lib/l10n/`, `assets/`, `pubspec.*` | trước, một mình |
| G. Hôm nay + Việc + màn chào + Pomodoro | `features/today|tasks|welcome|pomodoro/` | sau F, song song |
| H. Thói quen (danh sách, soạn, chi tiết, nhắc giờ), danh mục | `features/habits|categories/` | sau F, song song |
| I. Thống kê + Cài đặt + sao lưu/PIN + giới thiệu + chuông | `features/stats|settings|backup|lock/`, `reminders/alarm_screen.dart` | sau F, song song |
| J. Widget Android + iOS theo mockup (+ E nếu chưa xong) | `android/…/widget*`, `ios/` widget ext, `lib/src/widget/` | sau F, song song |
| K. Thử máy thật Android (adb, hỏi trước) + iOS simulator CI; a11y (TalkBack, cỡ chữ 200%) | chỉ `notes/`; sửa nhỏ ghi rõ file | sau G–J |
Cổng: `flutter analyze` sạch, `flutter test` đạt (cập nhật widget test theo UI mới), CI iOS xanh, người dùng duyệt UI.

## Phiên điều phối #3 — Phát hành
- L. Ảnh chụp store từ UI mới (`store/`). M. Android: AAB ký → closed test → production khi đủ 14 ngày.
  N. iOS: GitHub Actions → TestFlight → App Review.
- Chạy `playbook/checklists/release-android.md`, `release-ios.md`; tag `v1.0.0`; retro trong `APP.md`, `METRICS.md`,
  1–3 cải tiến Playbook. Thời gian chờ store không tính phiên.

---
