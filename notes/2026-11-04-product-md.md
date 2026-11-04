# [A003-dailyloop] product.md cho Claude Design — báo cáo phiên con

Phiên con của phiên điều phối #1 · 2026-11-04 · phạm vi sửa: chỉ `product.md`, `CONTEXT.md`, báo cáo này.

## Đã làm / file đổi
- **`product.md`** (tiếng Anh, ~980 dòng, 10 mục đánh số như vigon): tổng quan + 4 persona + core jobs + 8 nguyên tắc (có "không đổ lỗi khi lỡ chuỗi") · ràng buộc (Android+iOS, bảng khác biệt nền tảng gồm chuông Android vs time-sensitive iOS, WCAG, 200 %, chữ VI dài nhất, định dạng ngày/giờ/số) · luật nghiệp vụ (4 cách theo dõi, 5 kiểu lặp, chuỗi/điểm/tỉ lệ, bỏ qua, quá hạn, lưu trữ/xóa, nhắc ≤ 5, Pomodoro, sao lưu/PIN/xóa) · IA + 14 route + sơ đồ điều hướng · **30 màn/hộp thoại/sheet SCR-01…30** (welcome, Hôm nay, picker, menu hàng, sheet nhập giá trị, sheet danh sách con, sheet tạo, Thói quen, Đã lưu trữ, chi tiết, soạn thói quen/việc, picker, khối nhắc + hộp quyền, xác nhận xóa, Việc, Thống kê, Pomodoro, Danh mục + sheet + hộp xóa, Cài đặt, sao lưu/khôi phục/CSV, cài/kiểm PIN, khóa + quên mã, xóa toàn bộ, Giới thiệu, chuông `/alarm`, thông báo, widget Android + iOS, mẫu dùng chung) · 16 luồng · dữ liệu mẫu (hôm nay giả 2026-11-04, 9 thói quen, 6 việc, thống kê, lịch) · mục 8: **21 điểm yếu UX hiện tại + 8 insight đối thủ** · mục 9 ngoài phạm vi · mục 10 deliverables (khung sáng/tối × Android/iOS, bảng tên file 1:1 route, design system + token + icon, xuất HTML). Đầu file ghi rõ: **bộ nhận diện + design system MỚI, giữ luồng + phạm vi SPEC, không thêm tính năng, không bắt chước app nào.**
- **`CONTEXT.md`** (glossary, cột "Tránh dùng"): Activity, Habit, Task, Subitem, Schedule, Due day, effectiveFrom, Entry, Evaluation (4 kiểu), Target, Unit, Condition, Achieved, Skip, Overdue, Unscheduled, Streak, Habit score, Success rate, Reminder (+ Notification/Alarm), Snooze, Pomodoro session, Credit, Category, Archive, Delete, Today, Day strip, Widget, PIN lock, Backup, CSV export, Wipe, Priority, Welcome.
- Nghiên cứu UX: 6 lượt WebSearch (Loop, Streaks, Habitify, HabitNow, TickTick, bài về "streak guilt"). Nguồn chủ yếu là trang so sánh/affiliate/bài của hãng đối thủ → chỉ rút insight định hướng, đã ghi chú trong mục 8.2. Không chép chữ/hình/bố cục.

## Cách kiểm (đã chạy)
- **Route:** đối chiếu 14 `path:` trong `lib/src/app.dart` với mục 4.1 — đủ cả 14 (script kiểm từng route có trong product.md); thêm màn không có route: welcome, khóa, G7, About.
- **Chữ `.arb`:** script so từng chuỗi EN và VI của `app_en.arb`/`app_vi.arb` với product.md: toàn bộ khớp, trừ các khóa có plural/placeholder được viết lại dạng mẫu (`streakDays`, `overdueDays`, `progress`, `moveActivitiesTo`…) — đã liệt kê ở "Appendix · Strings not spelled out above". Chữ G7 lấy từ `.arb` **làm việc dở của phiên G7 (chưa commit)** — nếu G7 đổi chữ thì cần rà lại SCR-21..25.
- **SPEC:** AC-01..AC-53 đều có chỗ: AC-01..06 SCR-08..12, 15 · AC-07..12 SCR-02..06 · AC-13..16 SCR-12, 16 · AC-17..22 SCR-14, 27, 28 · AC-23..29 SCR-10, 17 · AC-30..32 SCR-19, 20 · AC-33..34 SCR-07, 01 · AC-35..38 SCR-18 · AC-39..41 SCR-29 · AC-42..44 SCR-22 · AC-45..47 SCR-23, 24 · AC-48..50 mục 2 + SCR-21 · AC-51 SCR-26 · AC-52 SCR-25 · AC-53 không có UI (ghi ở nguyên tắc offline).
- Màn hiện có đối chiếu đọc từng file trong `lib/src/features/**`, `reminders/`, `pomodoro/`, `widget/`, layout widget Android.
- **Chưa làm:** không dựng/ chạy app, không gửi Claude Design (việc của người dùng sau khi duyệt).

## Việc dở / rủi ro / chỗ SPEC mơ hồ cần người dùng quyết
1. **AC-32 (lọc Hôm nay theo danh mục):** SPEC đòi, nhưng app hiện chỉ lọc ở tab Thói quen. product.md ghi là hạng mục SPEC cần thiết kế; cần phiên #2 code thêm.
2. **Quên PIN "hai bước xác nhận" (AC-47/52):** G7 đang làm hộp giải thích + 2 xác nhận = 3 hộp. product.md mô tả theo cách đó và cho phép gộp.
3. **Tên mục trên màn chuông khi bật PIN:** SPEC ẩn tên trên *thông báo* màn khóa; code G7 vẫn hiện tên trên màn chuông. product.md thiết kế cả biến thể ẩn tên — cần chốt.
4. **Nút Xong trên thông báo khi bật PIN:** chưa rõ có cho phép không (đề xuất không) — đánh dấu "to confirm with G7".
5. **Chữ "NEW" chưa có:** About (AC-51, chưa có màn), nhắc "file sao lưu không mã hóa" gần nút xuất, chữ trạng thái "tất cả đã xong", thông báo khi PIN, nhãn "+N more" widget, ghi chú iPhone cho kiểu Chuông.
6. **Bảng xếp hạng "Chuỗi dài nhất" so sánh số thô giữa ngày/tuần/tháng** (31 ngày vs 6 tuần) — có thể sai ý; để dev quyết.
7. **Số thập phân VI hiện dấu chấm** (`2.5`) — lỗi định dạng, cần sửa ở code.
8. **Widget iOS cỡ small (chỉ số đếm) và `Open DailyLoop` khi PIN** là đề xuất của tôi; SPEC chỉ nói widget 4×2 Android. iOS < 17 không tick được trên widget.
9. Ý tưởng ngoài SPEC đã đưa vào mục 9 (không thiết kế trong khung chính): hỏi "Bỏ thay đổi?", ghi ngày trong hộp nhập từ lịch, bước +N tùy chỉnh, mục theo buổi trong ngày, sắp xếp danh mục.
10. Nguồn nghiên cứu đối thủ yếu (affiliate) — nên coi mục 8.2 là giả thuyết, không phải dữ liệu người dùng.
11. product.md dài (~980 dòng, ~13k từ): có thể quá dài cho một lần gửi; nếu Claude Design cắt ngữ cảnh, gửi mục 1–4 + 8–10 trước rồi từng nhóm màn.

## Đề xuất cải tiến xưởng
- **Mẫu `playbook/templates/product.md` dùng chung:** khung 10 mục (như vigon/dailyloop), phần cố định (nguyên tắc a11y/ràng buộc nền tảng, bảng khác biệt Android/iOS, bảng tên file `design/hifi/...`, mục deliverables/design system) chỉ cần điền `{{app}}`; riêng mục 2.2, 2.4, 10 gần như giống hệt giữa các app → tách thành "khối chuẩn" để tiết kiệm token và tránh lệch.
- **Script kiểm product.md ↔ `.arb`/route** (chạy như trên): nên đưa vào `playbook/` thành lệnh một dòng để mọi app có bước kiểm cuối.
- **Quy tắc thứ tự:** viết product.md **sau khi** phiên G7-tương-đương đã chốt chữ `.arb`, hoặc cho phiên con product.md đọc lại `.arb` lần cuối trước commit (đã làm ở đây; G7 chạy song song làm chữ đổi giữa chừng).
- Khi dùng "bộ nhận diện mới", product.md nên có sẵn mục "deliverables bắt buộc cho mapping token → Flutter" (đã đưa vào 10.3) để phiên F (áp design system) không phải hỏi lại.
