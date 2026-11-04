# [A003-dailyloop] Chuyển DailyLoop vào Mobile App Studio + kế hoạch 3 phiên điều phối

## Context
DailyLoop (APP-002 bên `D:/DemoChung`) là app Flutter lập lịch thói quen + việc cần làm, nhắc giờ, chuỗi ngày,
thống kê, Pomodoro, widget. Đã xong code G1–G6 (169 test đạt, `flutter analyze` sạch, APK release build được; nhánh
`master` đã đẩy lên `phiotron/dailyloop`; chưa thử máy thật phần lớn G3–G6). Còn G7 (sao lưu/CSV, PIN, xoá dữ liệu) và
G8 (a11y, pháp lý, phát hành). Chưa có bộ thiết kế nào (UI là Material viết tay).

Người dùng muốn: chuyển app vào xưởng đúng cấu trúc, lên kế hoạch phase để phiên điều phối mở phiên con song song,
viết `product.md` gửi Claude Design làm mockup Hi-Fi, rồi áp UI và hoàn thiện — **xong trong 2–3 phiên điều phối**.
Mẫu đã có: A002-vigon vừa chuyển y hệt (`apps/A002-vigon/notes/2026-11-04-ke-hoach-3-phien.md`) → tái dùng.

**Đã chốt (popup):** chat này = phiên điều phối #1 · **Android + iOS** · widget iOS có (WidgetKit), kiểu "Chuông" trên iOS
→ thông báo time-sensitive có âm thanh + nút Xong/Hoãn · UI **thiết kế mới, giữ luồng & phạm vi SPEC** · phạm vi **đúng
SPEC**, G7 làm ở #1 · AC-21: **thêm bộ nhận đổi giờ/múi giờ** · đổi `master`→`main`, giữ repo `phiotron/dailyloop`,
**phiên con được push** (để CI iOS chạy) · **miễn phí hoàn toàn**.
**Mặc định không hỏi:** mã `A003-dailyloop` (A002 = vigon), bundle `com.phiotron.dailyloop` giữ nguyên, `product.md`
tiếng Anh (như vigon), không mang `lessons/` DemoChung sang (chỉ gộp lưu ý dễ vấp vào APP.md).

**Chống đụng chat Ví Gọn đang chạy:** chat đó có sửa CHƯA commit ở `TASKS.md` + `apps/REGISTRY.md`. Phiên này chỉ
**thêm dòng A003** bằng Edit (không ghi đè file), không commit repo xưởng giữa chừng; khi `/dong-phien` chỉ stage hunk
của A003 (tạo patch rồi `git apply --cached`), không commit hộ phần của A002. Điện thoại Galaxy A13 dùng chung → hỏi
trước khi adb, kiểm `mCurrentFocus` trước mỗi lần chạm.

---

## Phiên điều phối #1 — Chuyển + product.md + G7 + nền iOS (phiên này)

### Bước điều phối tự làm (tuần tự)
0. Người dùng xác nhận không còn Claude/Android Studio/terminal nào mở trong `D:/DemoChung/apps/APP-002-dailyloop`;
   chạy `android/gradlew --stop`.
1. **Cấp mã:** thêm dòng `A003-dailyloop` vào `apps/REGISTRY.md` ngay (DailyLoop · thói quen + việc hằng ngày, nhắc
   giờ, chuỗi ngày — offline · `com.phiotron.dailyloop` · 🔨 · `phiotron/dailyloop` · "Flutter; vi/en; Android+iOS;
   chuyển từ DemoChung APP-002 (đã qua G1–G6)").
2. **Di chuyển:** `mv "D:/DemoChung/apps/APP-002-dailyloop" "D:/Mobile App/apps/A003-dailyloop"` (cùng ổ → đổi tên
   nguyên khối). Không sửa gì khác ở DemoChung. Nếu bị khoá → dừng, báo người dùng.
3. **Git:** `git branch -m master main`, `git push -u origin main`, đặt default branch trên GitHub
   (`gh repo edit phiotron/dailyloop --default-branch main`), xoá `origin/master` sau khi người dùng xác nhận.
4. **Đưa vào khung xưởng** (như commit `0bff35e` của vigon):
   - Tạo `APP.md` từ `playbook/templates/APP.md`: brief, MVP (F-01..F-14 tóm tắt từ `docs/SPEC.md`), màn & route
     (từ `lib/src/app.dart`), trạng thái 3 phiên, việc dở (các `[ ]` của `docs/BACKLOG.md`), quyết định D-001..D-009
     (D-001 sửa thành **thêm iOS**), mục **Lệnh** + **Lưu ý dễ vấp** (từ `CLAUDE.md` app: PATH Flutter, 32-bit L-011,
     không `USE_EXACT_ALARM`, widget ghi thẳng bảng `entries` ↔ `WidgetStore.kt`, test drift trong `runAsync`,
     `hide Evaluation`, không tự adb).
   - Chuyển vào `notes/archive-demochung/`: `CLAUDE.md` app, `docs/BACKLOG.md`, `docs/PROMPTS.md`, `docs/RUNBOOK.md`,
     `RETROSPECTIVE.md`, `memory/sessions/`. Xoá `docs/plans/`, `docs/audits/` mẫu rỗng, `.claude/commands/`,
     `.claude/agents/`, file rác `.fuse_hidden*`. **Bắt buộc** gỡ hook trong `.claude/settings.json` (trỏ
     `../../.claude/hooks/*.sh` → sẽ lỗi ở chỗ mới).
   - Giữ tham chiếu: `docs/SPEC.md` (AC nguồn sự thật), `ARCHITECTURE`, `TESTING`, `SECURITY`, `COMPLIANCE`, `RISKS`,
     `RELEASE`, `DECISIONS`. Tạo `design/`, `store/`, `notes/`.
   - `grep -rn "DemoChung\|\.\./\.\./\|APP-002"` → sửa tham chiếu còn sót. `export PATH="/c/src/flutter/bin:$PATH"`;
     `flutter analyze` + `flutter test` vẫn 169 đạt.
   - Commit `[A003-dailyloop] move into Mobile App Studio framework` (`git add` file cụ thể), push.
5. **File cấp xưởng:** thêm dòng A003 vào bảng app + "Đang làm" + việc người dùng trong `TASKS.md` (chỉ dòng A003).
6. Lưu kế hoạch này vào `apps/A003-dailyloop/notes/2026-11-04-ke-hoach-3-phien.md`.
7. Mở **4 phiên con song song** (`start_session`, `use_worktree: false`, cwd `apps/A003-dailyloop`, tên
   `[A003-dailyloop] …`, brief theo `playbook/templates/BRIEF-phien-con.md`).

### Phiên con #1 (song song, tập file không chồng nhau)
| Phiên con | Phạm vi file | Kết quả |
|---|---|---|
| **A. product.md + CONTEXT.md** | chỉ `product.md`, `CONTEXT.md` | Nghiên cứu nhanh UX đối thủ (HabitNow, Habitify, Loop, TickTick, Streaks): điểm mạnh/khe hở — **không sao chép hình thức** của app nào. Viết `product.md` (EN) theo cấu trúc `apps/A002-vigon/product.md`: tổng quan, persona, nguyên tắc (offline, riêng tư, đánh dấu xong ≤ 1 chạm), ràng buộc (Material 3 thích ứng iOS, sáng/tối, cỡ chữ 200%, vùng chạm 48dp, dọc, 360×800 + iPhone), luật nghiệp vụ cho designer (4 kiểu đánh giá, 5 kiểu lịch lặp, chuỗi/điểm, bỏ qua, quá hạn), IA + route, **từng màn SCR-xx** (mục đích, thành phần, trạng thái trống/lỗi/khoá, tương tác, chữ thật từ `.arb` EN + ghi chú VI dài nhất) gồm cả màn G7 (sao lưu, PIN, xoá dữ liệu) theo SPEC, widget Android + iOS, chuông/thông báo, luồng chính, dữ liệu mẫu, điểm UX yếu, ngoài phạm vi, **deliverables** (frame, tên file 1:1 route, trang design system, xuất HTML). Hướng: **bộ nhận diện + design system mới**. `CONTEXT.md` theo mẫu `A001-subnest/CONTEXT.md`: Activity, Habit, Task, Schedule, effectiveFrom, Entry, Evaluation (Yes/No, Quantity, Timer, Checklist), Unit, Skip, Overdue, Streak, Score, Reminder (Notification/Alarm), Pomodoro session, Category, Backup… |
| **B. Nền iOS + CI** | `ios/`, `.github/workflows/`, `lib/src/reminders/reminder_service.dart` (nhánh nền tảng), `docs/DECISIONS.md` (thêm D-010) | `flutter create --platforms ios --org com.phiotron .`; Info.plist (tên, `ITSAppUsesNonExemptEncryption=false`), `PrivacyInfo.xcprivacy`; kiểm từng plugin hỗ trợ iOS. Kiểu "Chuông" trên iOS → thông báo `timeSensitive` + âm thanh dài + action Xong/Hoãn; lịch lăn tôn trọng giới hạn 64 thông báo chờ (D-010). Workflow: test + build iOS simulator không ký trên macOS runner; workflow release đọc secrets (không bí mật trong repo). **Không** đổi `pubspec.*` (cần gói thì ghi notes). Push để CI chạy; ghi rõ phần CHƯA kiểm chứng (chưa có Apple account/iPhone). |
| **C. G7: sao lưu, PIN, xoá dữ liệu, AC-21** | `pubspec.yaml/lock` (**chỉ phiên này** đổi dependency), `lib/src/features/backup|lock|settings/`, `lib/src/data/backup*`, `lib/src/data/settings_repository.dart`, `lib/l10n/*.arb`, `android/` (receiver đổi giờ + manifest), test tương ứng | AC-41..47, AC-52: file `.dailyloop` (JSON có mã băm, khôi phục thay toàn bộ trong 1 giao dịch, đặt lại nhắc giờ sau khôi phục — gọi API reminder có sẵn, **không sửa** `reminder_service.dart`), CSV, PIN băm có muối + màn khoá phủ app, nối widget ẩn tên khi có PIN, chuông khi đang khoá, xoá toàn bộ. AC-21: receiver `TIMEZONE_CHANGED`/`TIME_SET` đặt lại lịch. Chọn gói hỗ trợ cả iOS (secure storage → Keychain, share/chọn file). `flutter analyze` + `flutter test` đạt. UI tạm theo style hiện tại (sẽ áp mockup ở #2). |
| **D. Store & pháp lý 2 nền tảng** | `store/`, `docs/legal/`, `docs/COMPLIANCE.md` | Tra trùng tên "DailyLoop" trên Google Play + App Store, đề xuất tên dự phòng. Listing Play + App Store EN/VI (tên ≤ 30, phụ đề, keyword, mô tả), Data safety / App Privacy "không thu thập", độ tuổi, khai báo full-screen intent + exact alarm cho Play. Chính sách quyền riêng tư vi/en. Kế hoạch closed test 12 tester × 14 ngày. Spec ảnh chụp (chụp thật ở #3). |

Sau B: **E. Widget iOS (WidgetKit)** — `ios/` (widget extension, App Group), `lib/src/widget/` — chạy cuối #1 nếu B xong
sớm, không thì đầu #2. Đọc DB qua App Group container; nút đánh dấu bằng App Intent (iOS 17+).

### Điều phối kiểm và đóng #1
- Đọc kỹ `product.md` (đủ màn, đủ trạng thái, đúng SPEC) → **người dùng duyệt trước khi gửi Claude Design**.
- Kiểm thật: diff B + kết quả CI GitHub Actions; C chạy `flutter analyze`/`flutter test`; D đủ file.
- Gộp `notes/` vào `APP.md`; `/dong-phien` (session log `memory/sessions/2026-11-04-A003-dailyloop.md`,
  METRICS "nhập từ DemoChung, đã qua G1–G6").

### Việc của người dùng giữa #1 và #2 (ghi TASKS)
- Gửi `product.md` cho Claude Design → lưu link + export HTML/ảnh theo màn vào `apps/A003-dailyloop/design/hifi/`.
- Apple Developer (dùng chung việc xưởng) → App ID `com.phiotron.dailyloop` + App Group → secrets repo.
- Play Console: tạo app, upload keystore ngoài repo, **bắt đầu closed test 14 ngày sớm** bằng build hiện tại.
- Cho phép thử máy thật G3–G7 trên Galaxy A13 (khi máy rảnh khỏi phiên Ví Gọn).

---

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

## Kiểm chứng
- Sau chuyển: `D:/DemoChung/apps/APP-002-dailyloop` không còn; DemoChung khác không đổi; `git -C apps/A003-dailyloop
  status` sạch, nhánh `main` theo `origin/main`; `grep DemoChung` chỉ còn trong `notes/archive-demochung/`;
  `.claude/settings.json` không còn hook; `flutter analyze` sạch + `flutter test` 169 đạt.
- Repo xưởng: `git diff` chỉ thêm dòng A003, phần chưa commit của A002 còn nguyên.
- Cuối #1: `product.md` được người dùng duyệt; B có run CI thật (link) hoặc ghi rõ CHƯA kiểm chứng; C test đạt + số
  test mới; D đủ listing 2 store; APP.md/TASKS/REGISTRY đúng trạng thái.
