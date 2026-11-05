# Orbiday — Product brief for Hi-Fi UI design

> **What this file is for:** the brief to send to **Claude Design** to produce Hi-Fi mockups (UX/UI optimised) for the
> mobile app **Orbiday** on **Android + iOS**. It says *what* each screen must do and *why*; *how it looks* is Claude
> Design's proposal, within the limits in §2 and §10.
>
> **Direction: NEW identity + NEW design system.** Use the name **Orbiday** (final brand name, chosen 2026-11-05; the earlier names "DailyLoop" and "Streakloom" were dropped because of store name clashes); everything else visual — logo, app icon
> concept, colour palette, typography, icon style, component shapes, motion — is **yours to propose**. The app that exists
> today is an unstyled Material 3 prototype (seed colour indigo); use it **only to understand the flows**, not as a visual
> starting point. **Keep every flow and the exact scope** of the spec (`docs/SPEC.md`, F-01..F-14 / AC-01..AC-53).
> Do **not** add features; ideas outside the spec go to §9 only. **Do not imitate any existing habit app** (names, logos,
> colours, layouts, icons) — the spec forbids copying HabitNow; §8.2 lists competitor *insights*, not looks to copy.
>
> Display name **Orbiday** (store EN: "Orbiday: Habits & To-Do"; store VI: "Orbiday: Thói Quen & Việc"). **Internal code name: `A003-dailyloop`**; Bundle ID `com.phiotron.dailyloop`; the backup file extension **`.dailyloop` stays** (and so do file names like `dailyloop-YYYYMMDD-HHMM.dailyloop`) — never show "DailyLoop" as the product name in any frame · Version 1.0 · Date 2026-11-04
> Glossary: `CONTEXT.md` (Activity, Habit, Task, Schedule, Entry, Evaluation, Skip, Overdue, Streak, Habit score,
> Reminder, Pomodoro session, Backup…). Use those words in layer names and labels.
> All UI copy below is the real copy from `lib/l10n/app_en.arb` and `app_vi.arb`. Where a design needs **new** copy
> (the G7 screens — backup, restore, CSV, PIN, lock, erase — already have copy in the `.arb` files as of 2026-11-04, work in progress; **About**, notification-with-PIN text and a few hints still have none), write it in the mockup marked
> `NEW:` so the developer adds it to both `.arb` files.
> **Naming note:** the `.arb` files already say **Orbiday** (`appTitle`, `permNotifBody`, `restoreFailed`). The text ".dailyloop" in the backup hints is the file extension and stays.

---

## Contents
1. Product overview
2. Design constraints
3. Business rules the designer must know
4. Information architecture and navigation
5. Screens, dialogs and sheets (SCR-01 … SCR-30)
6. Key flows
7. Sample data for mockups
8. Known UX weak points → design opportunities, and competitor insights
9. Out of scope / Future
10. Deliverables requested from Claude Design

---

## 1. Product overview

### 1.1 One line
**Orbiday** — plan the habits and to-dos of your day in one list, get reminded at the right time, and see your streaks
and progress. Free, fully offline, no account, no data collection.

### 1.2 Problem
People who want a steadier routine (drink enough water, exercise, read, take medicine on time) quit after a few days:
they forget, and they cannot see how far they have come. Today they juggle sticky notes, phone alarms and loose notes,
so nothing gathers the day's habits and tasks in one place or counts consecutive days. Orbiday puts habits and tasks on
one **Today** screen, reminds at the chosen times, and shows streaks, a score and statistics.

### 1.3 Target users (personas)

| Persona | Situation | What they need from the UI |
|---|---|---|
| **Mai, 28, office worker (Hà Nội)** | 6–8 habits (water, vitamins, reading, gym 3×/week) plus a few work tasks. Glances at the phone between meetings, **one hand**, sometimes on the bus with weak signal | Open → tap the circle → done. Reminder with a **Done** button; a widget she can tick without opening the app |
| **Khoa, 20, student (Đà Nẵng)** | Study blocks, English practice, sleep schedule; likes Pomodoro and numbers | Time and amount habits, Pomodoro that feeds the habit, clear weekly/30-day stats, no nagging |
| **Bác Tâm, 63, takes blood-pressure medicine** | Not tech-savvy, Vietnamese only, large system text, privacy-conscious (health habit names) | Big targets readable at 200 % text, plain words, a loud lock-screen **alarm** with Done/Snooze, PIN so family cannot read the list |
| **Sam, 33, expat (EN)** | English UI, iPhone, Focus modes on; habits that are "at most" (limit coffee) and "3 times a week" | Flexible schedules, time-sensitive reminders, correct date/number formats, widget on the home screen |

### 1.4 Core jobs (in priority order)
1. **Tick today's habit/task in one tap** — the reason the app exists (from the app, a widget or a notification).
2. **Get reminded on time** — notification or full-screen alarm (Android) / time-sensitive notification (iPhone).
3. **See progress** — current and longest streak, habit score, success rate, month calendar, charts.
4. **Set up once** — create habits/tasks with the right way to track and the right repeat pattern; categories.
5. **Focus** — Pomodoro timer, optionally crediting minutes to a Time habit.
6. **Keep data safe and private** — backup file, restore, CSV, optional PIN lock, wipe everything.

### 1.5 Design principles
1. **Offline & private by design.** No sign-in, no cloud, no "sync" anything. Reassure quietly ("Your data stays on this
   phone"), never nag.
2. **Mark done in ≤ 1 tap** (AC-09). For Yes/No habits and tasks the circle on the row is the whole interaction. Amount,
   Time and Checklist habits need one more step (sheet) — make that step as light as possible. Every decision on
   Today is judged against this.
3. **One-handed.** Primary actions (circle, **+**, Save, sheet buttons) live in the lower two thirds of the screen; the
   **+** button is in the lower half (AC-33). No gesture is the only path to anything.
4. **No blame when a streak breaks.** Missing a day is a data point, not a failure: neutral words ("Not done"), no red
   walls, no "you lost your streak" messages, no guilt notifications. Show streak **with** score and success rate so one
   miss does not erase the picture. Skipping a day is a first-class, neutral action (AC-10).
5. **Calm and clear.** Numbers and state are the hero; colour is used sparingly. No gamification (badges, levels),
   no dark patterns.
6. **Never rely on colour alone** (AC-50): every state (done, not done, skipped, overdue, future) has an icon **and** a word.
7. **Forgiving.** Deleting a habit/task confirms, then offers **Undo** for 5 s; archive is reversible; wiping data or
   restoring always confirms; a corrupt backup file changes nothing.
8. **Same app on both platforms.** One layout; only OS-owned behaviour differs (§2.2).

---

## 2. Design constraints

### 2.1 Platforms, frames, orientation
- **Android** (Material 3) and **iOS** (adaptive Material 3, not Cupertino widgets). One shared layout.
- **Base frames:** Android **360 × 800 dp** (smallest supported width) and iPhone 15/16 **393 × 852 pt**. The layout
  must also hold at 412 × 915 and iPhone SE-class 375 × 667 for the lock/alarm/PIN screens.
- **Portrait only** (locked on both). No tablet or landscape layouts.
- **Safe areas:** status bar, Android gesture bar (edge-to-edge), iPhone Dynamic Island and Home indicator. Bottom
  navigation, **+** button, sheet buttons and PIN keypad sit above the Home indicator / gesture bar.

### 2.2 Platform differences (only where the OS decides)

| Topic | iPhone | Android |
|---|---|---|
| Back | Visible back arrow in app bar **+ swipe from left edge**. No hardware back, so **every pushed screen and full-screen dialog needs a visible back/close control** | Back arrow + system Back/gesture (predictive back); Back on a tab root exits |
| Share backup / CSV | iOS share sheet | Android Sharesheet (show both as **system chrome placeholders**, do not design them) |
| Pick a file to restore | Files document picker | System file picker (SAF); app asks **no storage permission** (AC-42) |
| **Reminder kind "Alarm"** | **No full-screen alarm and no `/alarm` screen.** An "Alarm" reminder arrives as a **time-sensitive notification** (breaks through Focus), longer sound, with **Done / Snooze 10 min** buttons | **Full-screen alarm** over the lock screen (SCR-27), repeating sound until Done/Snooze/Dismiss or 5 min; falls back to a heads-up notification if the full-screen permission is missing |
| Permission dialogs | "Allow notifications" is the OS dialog. **No** "exact alarms" and **no** "full-screen" explanation dialogs (those two are Android-only, SCR-14) | App's explain-first dialog, then OS dialog; then "Alarms & reminders" and full-screen settings pages |
| Notification actions | Long-press / pull-down actions: **Done** (Yes/No & tasks), Snooze 10 min (alarm kind) | Visible action buttons |
| Home-screen widget | WidgetKit (small / medium / large), tick via interactive widget on iOS 17+ (older: tap opens app) | App widget, resizable, minimum 4×2 |
| PIN storage | Keychain | Keystore |
| Screen reader | VoiceOver | TalkBack |
| App bar title | Left-aligned on both | Left-aligned |
| Date / time pickers | Material pickers on both (consistency) | Material |
| Haptics | Light haptic on wrong PIN, on tick | Same |

### 2.3 Theme and visual identity (yours to propose)
- Deliver **Light and Dark** (and "System", follows device). Every main frame in both.
- **Brand name — Orbiday** = *orbit* + *day* ("the orbit of your day"). The idea of a circle / a repeating cycle / a day going around is a **free source of inspiration for the logo and icon — not mandatory**. The logo, icon and palette must look **clearly different from "Orbi" (NETGEAR, Wi-Fi) and from the old "DailyLoop" and "Streakloom" apps/names** (the reasons for the renames: `store/name-check.md`) and from any benchmarked habit app. Never show "DailyLoop" or "Streakloom" as the product name in any frame.
- **Propose a full identity:** logo/wordmark (the name is written **Orbiday**, one word, capital O only), app-icon concept (the
  icon image itself is **not final**), brand colours, neutral ramp, semantic colours (done, not done, skipped, overdue,
  warning), typography, icon style, corner radii, elevation, motion. The brand idea hinted by the name is a **loop /
  daily cycle** — free to use or ignore; avoid generic clip-art (checkmark in a circle as the whole logo, calendars,
  tomatoes, flames) and anything resembling a benchmarked app.
- **Typography:** must cover **full Vietnamese diacritics**, be bundled (no runtime download), and offer
  **tabular figures** for streaks, times, counters and the Pomodoro clock. Say which fonts you chose and their licence.
- **Contrast** ≥ 4.5:1 text / 3:1 large text and icons, in **both** themes (AC-50) — including text on category
  colours, the selected day, calendar cells, progress bars and disabled states. Provide a contrast table.
- **Category colours and icons are stored in user data** (colour as an ARGB int, icon as a string key, both in backup
  files). You may restyle the *glyphs* and re-pick colour *values*, but **each of the 23 icon keys and 16 colour slots
  must map 1:1** to a design (lists in §3.8). Give an explicit old → new mapping for any colour you change.
- **No bottom bar replacement:** navigation is the **4-tab bottom navigation** (Today, Habits, Tasks, Statistics) of
  AC-33; a floating **+** sits in the lower half. Do not add or remove tabs.
- Icons: any consistent set that covers every glyph used (list in §10.3). Material Symbols Rounded is acceptable but not
  required; a custom set is welcome if complete.

### 2.4 Accessibility (WCAG 2.2 AA target; AC-49, AC-50)
- **Touch targets ≥ 48 × 48 dp / 44 × 44 pt**; the Today circle, **+1** and ⋮ buttons included. Prefer 56 dp for
  the circle.
- **Text scale up to 200 %** without clipping or overlap on all main screens (Today, Habit editor, Habit detail,
  Settings, Lock/PIN, Alarm, dialogs). Rules to design for ≥ 130 %: the row's secondary line wraps (up to 3 lines),
  the day strip switches to a 2-line cell or scrolls, chips wrap, segmented controls stack vertically, bottom buttons
  stay pinned and the area above scrolls.
- Every control has a spoken label; list items read as sentences, e.g. **"Drink water, 5 of 8 glasses, not done"**
  (AC-49). Charts have a table alternative ("Show as table"). Calendar cells read "November 3, 2026, Done".
- State is never colour-only: done = check + word, not done = open circle + word, skipped = skip icon + word,
  overdue = badge text "Overdue · 2 days", future = lock/dimmed + word.
- Visible 2 px focus ring for keyboard / switch access. Respect **reduce motion**.

### 2.5 Languages and copy length
- **Vietnamese and English**, follows the device by default, switchable in Settings (AC-48). App name "Orbiday" is
  the same in both. **Design in English, then check Vietnamese** — VI is often 30–100 % longer for short labels.
- Longest / riskiest VI strings (real, from `app_vi.arb`):

| Key | EN | VI | Where it bites |
|---|---|---|---|
| `permNotifBody` | Orbiday uses notifications only to remind you at the times you set. Without them, reminders will not appear. You can still use the rest of the app. | Orbiday chỉ dùng thông báo để nhắc bạn đúng giờ đã đặt. Không cho phép thì sẽ không có nhắc giờ, các phần khác của app vẫn dùng bình thường. | Permission explain dialog |
| `permExactBody` | To remind you at the exact minute, Android needs the "Alarms & reminders" permission. Without it, reminders may arrive a few minutes late. | Để nhắc đúng từng phút, Android cần quyền "Báo thức và lời nhắc". Không có quyền này thì nhắc có thể trễ vài phút. | Permission dialog |
| `permFullBody` | Alarms can fill the screen like a clock alarm. Without this permission, alarms appear as a pop-up notification instead. | Chuông báo thức có thể hiện toàn màn hình như đồng hồ báo thức. Không có quyền này thì chuông hiện dạng thông báo nổi. | Permission dialog |
| `welcomeBody1` | Track yes-or-no habits, amounts, time or checklists, on the days you choose. | Theo dõi thói quen kiểu có hoặc không, số lượng, thời gian hay danh sách con, vào đúng những ngày bạn chọn. | Welcome page 1 |
| `checklistRequired` | Add 1 to 20 items, none empty | Thêm 1 tới 20 mục, không để mục trống | Inline error |
| `timesInvalid` | At most 7 times a week or 31 times a month | Tối đa 7 lần mỗi tuần hoặc 31 lần mỗi tháng | Inline error |
| `moveActivitiesTo` | 3 items use this category. Move them to: | 3 mục đang dùng danh mục này. Chuyển sang: | Delete-category dialog |
| `deleteHabitConfirm` | Delete this habit and all its history? | Xóa thói quen này cùng toàn bộ lịch sử? | Confirm dialog |
| `emptyHabits` | No habits yet. Tap + to create your first one. | Chưa có thói quen nào. Bấm + để tạo thói quen đầu tiên. | Empty state |
| `warnNotifications` | Notifications are off, reminders will not appear | Thông báo đang tắt, nhắc giờ sẽ không hiện | Warning row + button |
| `repeatTimesPerPeriod` | Times per week or month | Số lần mỗi tuần hoặc tháng | Dropdown |
| `everyNLabel` | Every how many days (2–365) | Cứ mấy ngày một lần (2–365) | Text-field label |
| `pomodoroSessions` | Sessions before long break | Số phiên trước nghỉ dài | Stepper row + 2 buttons |
| `pomodoroHabit` | Add minutes to habit | Cộng phút vào thói quen | Section title |
| `overdueDays` | Overdue · 2 days | Quá hạn · 2 ngày | Row badge |
| `dayPending` | Today, not done yet | Hôm nay, chưa xong | Calendar legend / a11y |
| `noEndDate` | No end date | Không có ngày kết thúc | Editor row |
| `languageSystem` / `themeSystem` | Device language / System default | Theo máy / Theo hệ thống | Settings radios |
| `widgetLeft` | 3 left | Còn 3 mục | Widget header (tight!) |

### 2.6 Number, date and time formatting
- Dates are local calendar days, `YYYY-MM-DD` internally; **"Today" is the device's local day, 00:00–23:59**.
- Date formats follow the **UI language** (`intl`): app-bar title for a non-today day — EN `Tuesday, November 3`,
  VI `Thứ Ba, 3 tháng 11`; short date EN `Nov 3`, VI `3 thg 11`; with year EN `Nov 3, 2026`, VI `3 thg 11, 2026`; month header
  EN `November 2026`, VI `tháng 11 2026`. Day-strip weekday: EN `Mon…Sun`, VI `Th 2…Th 7, CN`. First weekday = Monday or
  Sunday from Settings (AC-48).
- Time follows the **device**: 24 h (`18:30`) by default in Vietnam, 12 h (`6:30 PM`) in en-US. Design both.
- Numbers: counters are integers or one-decimal values (`2.5 of 3 km`). **VI uses a decimal comma** (`2,5 trên 3 km`);
  the prototype wrongly shows a dot (§8.1 item 16) — design for the comma. Streaks: `12 days` / `12 ngày`, `6 weeks`,
  `3 months`; score `87/100`; rates are whole percents `92%`; "no data" shows `None yet` / `Chưa có`.
- Pluralisation: EN `1 day` / `2 days`; VI has no plural.
- Large values: targets up to thousands (e.g. 2000 ml) and habit names up to 60 characters — truncate with ellipsis in
  rows (2 lines max at large text), never in the editor or detail title (wrap).

---

## 3. Business rules the designer must know

### 3.1 Activity = Habit or Task
Both live in one list and share name (≤ 60 chars, required), category (optional), description (habit only, ≤ 300),
priority (Low / Normal / High), schedule, reminders (0–5).
- **Habit:** repeats; has a **way to track** (evaluation) and **streak/score**; can be archived.
- **Task:** one-off (or repeating, yes/no only, **no streak**); optional date and time; optional subtasks; cannot be archived,
  only deleted. A one-off task with **no date** lives in "Unscheduled".

### 3.2 The four ways to track a habit (AC-02)
| Way (UI label) | Goal | Marking done on Today |
|---|---|---|
| **Yes or no** | — | 1 tap on the circle; tap again to undo |
| **Amount** | number > 0, free-text **unit** (e.g. "glasses"), condition **At least / Exactly / At most** | **+1** button and/or tap row → sheet with number field ("Record") |
| **Time** | minutes > 0, same conditions | Tap row → sheet (minutes), or run a timer (Pomodoro, SCR-18) which **adds minutes** |
| **Checklist** | 1–20 items, done when **at least N** items are ticked (default: all) | Tap row → sheet with checkboxes |

"Achieved" is **computed** from the recorded value and the condition, not stored. *At most* with nothing recorded counts as
**achieved** (e.g. "at most 2 coffees": 0 recorded = within limit) — design the row so this reads naturally, not as a
bug ("0 of 2 cups" + done check).

### 3.3 Five repeat patterns (AC-03, AC-14)
1. **Every day**
2. **On days of the week** (pick ≥ 1 weekday chips)
3. **On days of the month** (pick ≥ 1 of 1–31; months without that day skip it)
4. **Every N days** (N = 2–365; counted from the start date)
5. **Times per week or month** (K = 1–7 per week or 1–31 per month; the user chooses which days — the habit shows on
   every day until K is reached)

Tasks add a 6th, **Does not repeat** (default for tasks). Start date (default today) and optional end date. Changing the
schedule of an existing item only affects **from today onwards**; past results stay (AC-04) — no UI needed, but copy must
not suggest history changes.

### 3.4 Streak, habit score, success rate (AC-23..25)
- The unit is "a due day". **Current streak** = consecutive due days achieved up to yesterday, **plus today if already
  achieved**. **Longest streak** = best ever. Days when the habit is not scheduled, and **skipped** days, neither break nor
  extend the streak. A missed due day resets the streak to 0.
- For *Times per week/month* habits the unit is a **week or month**: streak counts consecutive weeks/months with ≥ K
  ticks (`6 weeks`).
- **Success rate** = achieved due days ÷ due days that are over, excluding skipped days and today-if-not-yet-recorded; shown
  for **7 days, 30 days, All time**; `None yet` when there is no data.
- **Habit score 0–100:** a recency-weighted consistency measure (recent days count more); same data → same score.
  Slow to drop after one miss — **use it as the "calm" headline** next to the streak.
- Tasks have no streak/score.

### 3.5 Skip and Overdue
- **Skip** (habits only, per day): "Skip this day" — counts as neither done nor failed; no streak break; the row shows a skip
  icon + "Skipped"; reversible ("Undo skip"). Hidden for future days.
- **Overdue** (one-off tasks): a task whose day has passed and is not done stays **at the top of Today** with the badge
  `Overdue · N days` until it is done, re-dated, or deleted. Habits are never "overdue" — a missed habit day is just
  "Not done" in history.
- **Past days** are editable (from the day strip or the habit's month calendar); **future days are read-only** — rows show
  the message "You can only record days up to today" when tapped.

### 3.6 Today list order (AC-07)
Due habits + tasks of the selected day, sorted by **reminder/task time, then priority**; **done items sink to the
bottom**; overdue tasks pinned on top. Archived habits are never shown.

### 3.7 Archive, delete, undo (AC-05)
- **Archive** (habits): leaves Today and the main list, stays in **Archived** with full history, restorable.
  Snackbar "Archived · Undo".
- **Delete** (habit or task): confirm dialog → deletes with all history → snackbar **"Deleted · Undo" for 5 s**
  (survives the editor closing).
- Changing a habit's goal recomputes old days against the **new** goal (known v1 behaviour; no UI).

### 3.8 Categories (AC-30..32)
- 8 defaults, names follow the language: **Health, Sport, Study, Work, Finance, Home, Mind, Other** (VI: Sức khỏe, Thể thao,
  Học tập, Công việc, Tài chính, Nhà cửa, Tinh thần, Khác), each with icon and colour (below). A habit/task may have **no
  category** ("No category", grey).
- Add / rename / re-icon / re-colour / delete. Deleting a category in use asks where to move its items (another category
  or "No category"). Name ≤ 40 chars.
- Default seeds (key · icon key · colour): health · `favorite` · `#C62828`; sport · `fitness_center` · `#E65100`; study ·
  `school` · `#283593`; work · `work` · `#1565C0`; finance · `savings` · `#2E7D32`; home · `home` · `#5D4037`; mind ·
  `self_improvement` · `#6A1B9A`; other · `more_horiz` · `#455A64`.
- **23 icon keys (stored):** favorite, fitness_center, directions_run, self_improvement, spa, local_drink, restaurant,
  bedtime, medication, school, menu_book, language, work, computer, savings, home, cleaning_services, family_restroom, pets,
  music_note, brush, nature, more_horiz.
- **16 colour slots (stored ARGB):** `#C62828 #AD1457 #6A1B9A #4527A0 #283593 #1565C0 #0277BD #00838F #00695C #2E7D32 #558B2F
  #E65100 #BF360C #5D4037 #455A64 #616161`. Icons on them are white (≥ 3:1). Today and the Habits list can be filtered by category (AC-32).

### 3.9 Reminders (AC-17..22)
- 0–5 reminder times per item (max 5), each **Notification** or **Alarm**; fire only on due days. Marking the item done
  before a reminder cancels the remaining reminders of that day (AC-22). **Done** on a notification works for Yes/No habits
  and tasks only (not Amount/Time/Checklist).
- First time a reminder is set: an **explanation dialog before the OS permission** (AC-18). Denied → the app stays usable;
  the reminder block shows a **warning row + "Open settings"** button (SCR-14).
- Android alarm needs two extra permissions (exact alarms; full-screen) — also explained first, also denied-safe
  (falls back to a normal notification). iPhone: only notification permission.
- Reminders are rescheduled automatically after reboot, time-zone change, restore (no UI).

### 3.10 Pomodoro (AC-35..38)
Phases **Focus → Short break → … → Long break** (defaults 25 / 5 / 15 min, long break after 4 sessions; all adjustable).
Time is computed from a saved start time, so it stays right if the screen is off or the app is killed; when a phase ends a
sound notification fires. A **Time** habit can be linked: stopping a Focus phase early adds the minutes run (rounded), finishing adds
the full length once; breaks add nothing. Reopening a dead timer shows the correct remaining time or "Finished".

### 3.11 Backup, CSV, PIN, wipe (AC-42..47, AC-52)
- **Backup** = a `.dailyloop` file (JSON with format version and integrity code, **not encrypted**) shared through the OS
  share sheet. **Restore** = pick a file → validate (format + integrity) → confirm "Your current data will be replaced" →
  replaces habits, tasks, history, categories, reminders and settings in one step, then re-schedules all reminders.
  A bad file → error message, **nothing changes**.
- **CSV** export of history (date, item name, type, result, value), UTF-8 for Excel/Sheets with correct Vietnamese.
- **PIN:** optional 4-digit PIN (enter twice). Required on app start and when returning after > 1 minute in the
  background. **Alarm** (Android) still shows over the lock screen with Done / Snooze / Dismiss with no PIN; opening the app
  from it needs the PIN. With PIN on: **notification text, lock-screen text and widgets hide item names**; the widget
  shows only the count left. **Forgot PIN** can only erase all data (explanation, then a two-step confirmation). A **Change PIN** action exists in Settings while PIN is on.
- **Wipe:** "Erase all data" (Settings) after a two-step confirmation: deletes everything, cancels reminders, empties the widget;
  reopening shows the app as freshly installed (welcome screen).

---

## 4. Information architecture and navigation

### 4.1 Routes (as in `lib/src/app.dart`)

| Route | Screen | Params | SCR |
|---|---|---|---|
| *(first launch overlay)* | Welcome (3 pages) | — | SCR-01 |
| `/` (tab 1) | Today | selected day kept in memory | SCR-02 |
| `/habits` (tab 2) | Habits list | category filter in memory | SCR-08 |
| `/tasks` (tab 3) | Tasks | filter in memory | SCR-16 |
| `/stats` (tab 4) | Statistics | — | SCR-17 |
| `/habits/new` | New habit | — | SCR-11 |
| `/habits/:id` | Habit detail ("progress") | `id` | SCR-10 |
| `/habits/:id/edit` | Edit habit | `id` | SCR-11 |
| `/habits/archived` | Archived habits | — | SCR-09 |
| `/tasks/new` | New task | `date=YYYY-MM-DD` (optional, pre-fills the date) | SCR-12 |
| `/tasks/:id` | Edit task | `id` | SCR-12 |
| `/pomodoro` | Pomodoro | `habit=<id>` (optional link) | SCR-18 |
| `/categories` | Categories | — | SCR-19 |
| `/settings` | Settings | — | SCR-21 |
| `/alarm` | Full-screen alarm (**Android only**) | opened by the alarm notification | SCR-27 |
| *(v1 "G7", routes decided by the developer; design as full screens/overlays)* | Backup & restore, CSV, PIN setup/check, Lock overlay, Wipe, About | — | SCR-22 … SCR-26 |

Overlays and sheets (no route): SCR-03 date picker, SCR-04 row menu, SCR-05 value sheet, SCR-06 checklist sheet, SCR-07 create
sheet, SCR-13 editor pickers, SCR-14 reminder block & permission dialogs, SCR-15 shared confirm/undo patterns, SCR-20 category
editor + delete dialog, SCR-28 notifications, SCR-29 widget, SCR-30 shared patterns.

### 4.2 Navigation map

```
App start ─► [Welcome SCR-01] (first launch only; skippable; no permission asked)
          ─► [Lock overlay SCR-24] (if PIN on; also after >1 min in background)
          └─ Forgot PIN ─► explain + 2 confirmations (SCR-24) ─► fresh app (Welcome)

Bottom navigation (4 tabs, each keeps its own state)
 ├─ Today "/" (SCR-02)
 │    ├─ day strip (7 days) ─► same screen, other day      ├─ "Back to today"
 │    ├─ calendar icon ─► date picker (SCR-03)            ├─ timer icon ─► Pomodoro /pomodoro (SCR-18)
 │    ├─ gear ─► Settings /settings (SCR-21)               ├─ [+] ─► Create sheet (SCR-07) ─► /habits/new | /tasks/new?date=
 │    ├─ circle on a row ─► marks done (Yes/No, tasks) | value sheet (SCR-05) | checklist sheet (SCR-06)
 │    ├─ [+1] on Amount rows ─► adds 1
 │    └─ ⋮ on a row (SCR-04) ─► Skip / Undo skip · View progress ─► /habits/:id · Edit ─► /habits/:id/edit | /tasks/:id
 ├─ Habits "/habits" (SCR-08)
 │    ├─ category chips (filter)   ├─ drag handle (reorder)   ├─ archive icon ─► /habits/archived (SCR-09)
 │    ├─ category icon ─► /categories (SCR-19) ─► category sheet / delete dialog (SCR-20)
 │    ├─ [+] ─► /habits/new (SCR-11)
 │    └─ tap row ─► /habits/:id (SCR-10) ─► edit ─► /habits/:id/edit ; timer icon (Time habits) ─► /pomodoro?habit=
 ├─ Tasks "/tasks" (SCR-16)
 │    ├─ filter chips: Today · Upcoming · Overdue · Unscheduled · Done
 │    ├─ [+] ─► Create sheet (SCR-07)      └─ circle ─► done ; ⋮ ─► Edit ─► /tasks/:id (SCR-12)
 └─ Statistics "/stats" (SCR-17)
      ├─ gear ─► Settings   └─ tap a top-streak habit ─► /habits/:id

Settings "/settings" (SCR-21)
 ├─ Theme · Language · First day of week                      (instant)
 ├─ Security: PIN lock switch ─► PIN setup / check (SCR-23) ; Change PIN (when on)
 ├─ Data: Export backup · Restore from file ─► file picker ─► confirm (SCR-22) · Export history as CSV · Erase all data ─► 2 dialogs (SCR-25)
 └─ About (SCR-26)

Reminder fires ─► notification (SCR-28) ─ Done (no app) / tap ─► app at the item   ·   Android alarm ─► /alarm (SCR-27)
Widget (SCR-29) ─ tick (no app) / tap name ─► /habits/:id or /tasks/:id
```
Back from any pushed screen returns to the previous one; Back on a tab root exits (Android). Pushed screens
(editors, detail, Pomodoro, categories, Settings, Alarm) **cover the bottom navigation**.

---

## 5. Screens, dialogs and sheets

Format per screen: **Purpose · Entry · Components · States · Interactions · Copy (EN | VI) · Accessibility**.
Copy tables list each string once; `{braces}` are placeholders. **NEW:** = no copy exists yet.

### SCR-01 · Welcome (first launch overlay) — AC-34
**Purpose:** a short, skippable intro; **asks for no permission**. Covers the app until finished; never shown again (shown
again after "Erase all data").
**Components:** Skip (top end) · swipeable pager of **3 pages** (illustration slot + title + body) · page dots · primary button
(**Next** → **Get started** on the last page).
**States:** page 1/2/3 · text 200 % (page scrolls, button pinned) · dark · VI (long bodies) · loading (blank surface for a
moment while the setting is read — no flash).
**Interactions:** swipe or Next; Skip or Get started → Today. Illustrations replace the prototype's single Material icon; propose
3 on-brand illustrations (habits · plan your day · private on this phone).
**Copy:**
| Element | EN | VI |
|---|---|---|
| Page 1 | Build habits that stick — Track yes-or-no habits, amounts, time or checklists, on the days you choose. | Xây thói quen bền vững — Theo dõi thói quen kiểu có hoặc không, số lượng, thời gian hay danh sách con, vào đúng những ngày bạn chọn. |
| Page 2 | Plan your day — Habits and tasks for the day are together on the Today screen. | Sắp xếp ngày của bạn — Thói quen và việc cần làm trong ngày nằm chung ở màn Hôm nay. |
| Page 3 | Your data stays on this phone — No account and no internet needed. Export a backup file whenever you want. | Dữ liệu ở lại trên máy — Không cần tài khoản, không cần mạng. Bạn tự xuất file sao lưu khi muốn. |
| Buttons | Skip · Next · Get started | Bỏ qua · Tiếp · Bắt đầu |
**A11y:** page titles are headings; dots announce "page N of 3" (NEW); Skip reachable first.

---

### SCR-02 · Today — `/` (tab 1) — F-02, AC-07..12
**Purpose:** see what is due today and mark it in one tap. The home of the app.
**Components (top → bottom):**
1. **App bar:** title **Today** (or the long date of another selected day, e.g. "Tuesday, November 3"). Actions:
   *Back to today* (only on another day) · *Pick a day* (calendar) · *Pomodoro* (timer) · *Settings* (gear). Four icons are too
   many (§8.1 item 1) — propose a clearer split (e.g. date control in the header; Pomodoro/Settings grouped) without removing
   any destination.
2. **Day strip:** 7 days centred on the selected day (3 before, 3 after); weekday + day number; **selected** filled; **today**
   outlined when not selected; min 56 dp high; swipe/paging to move is allowed (propose). Each day may show a tiny progress
   mark (data exists per day) — optional.
3. *(Spec AC-32)* **Category filter** chips above the list (All + each category) — **not yet in the prototype, required by the spec**.
4. **List** of rows (SCR-04 anatomy). Order per §3.6. Optional time-of-day grouping headers are a *proposal* (§9), not required.
5. **+** floating button in the **lower half**, above the bottom navigation → SCR-07.
6. **Bottom navigation** (Today selected).
**Row anatomy** (one component, reused on Tasks): leading **state circle** (≥ 48 dp: open / done ✓ / skipped) · **name** (struck
through and dimmed when settled) · secondary line (joined with " · "): `Overdue · N days` (error colour) · date (Tasks tab) ·
time (`09:00`) · progress (`5 of 8 glasses`, `20 of 30 minutes`, `2 of 4 items`) · `Skipped` · trailing **+1** button
(Amount habits on editable days) · **⋮** menu. Category colour/icon marker is allowed; priority marker for **High** is
allowed (icon + word, not colour only). Quantity/Time/Checklist rows should show a **progress indicator** (ring or bar).
**States to design:**
| State | What shows |
|---|---|
| Normal day, mixed items | Open Yes/No, Amount 5/8, Time 0/30, Checklist 2/4, a task with time, done items at the bottom |
| **Overdue task on top** | Row with `Overdue · 2 days` in error style + icon, above everything |
| Item **skipped** | Skip icon + "Skipped", struck/dimmed |
| *At most* habit, nothing recorded | Reads as within limit, done-state, calm |
| **All done** | A friendly (not childish) completion state above/within the list — no confetti required |
| **Empty day** | Message "Nothing planned for today" + two buttons **Add habit** / **Add task** (AC-11); **+** also visible |
| **Past day** | Editable; app-bar shows that day's date + *Back to today* |
| **Future day** | Read-only: rows dimmed with a "future" cue; tapping a circle shows snackbar "You can only record days up to today"; no +1 |
| Filtered by category, none match | Empty text (NEW: "Nothing in this category today") |
| Loading | List is local (ms): neutral skeleton or nothing, no spinner |
| Long name (60 chars) | 2-line ellipsis |
| Text 200 % | Strip becomes 2-line cells; secondary line wraps; circle stays ≥ 48 dp |
| Many items (40) | Scrolls; last row clears the **+** (88 dp bottom padding) |
| VI | Longest labels |
**Interactions:** tap circle/row (Yes/No, task) toggles done; tap row (Amount/Time) → SCR-05; tap row (Checklist) → SCR-06;
**+1** adds 1 immediately (item updates ≤ 100 ms); ⋮ → SCR-04; day-strip tap changes day; calendar icon → SCR-03. Results are
written immediately (AC-12).
**Copy:**
| Element | EN | VI |
|---|---|---|
| Title | Today | Hôm nay |
| Icon tooltips | Back to today · Pick a day · Pomodoro · Settings | Về hôm nay · Chọn ngày · Pomodoro · Cài đặt |
| Tab labels | Today · Habits · Tasks · Statistics | Hôm nay · Thói quen · Việc · Thống kê |
| **+** tooltip | Create | Tạo mới |
| Empty | Nothing planned for today | Hôm nay chưa có việc nào |
| Empty buttons | Add habit · Add task | Thêm thói quen · Thêm việc |
| Chips | All + category names | Tất cả + tên danh mục |
| Row states | Done · Not done · Skipped | Đạt · Chưa đạt · Đã bỏ qua |
| Progress | `{value} of {target}` + unit / minutes · `{done} of {total} items` | `{value} trên {target}` + đơn vị / phút · `{done} trên {total} mục` |
| Overdue | Overdue · 1 day / Overdue · {n} days | Quá hạn · {n} ngày |
| +1 | Add 1 | Thêm 1 |
| Future tap | You can only record days up to today | Chỉ ghi được kết quả tới hôm nay |
| NEW: all-done | NEW: "All done for today" (suggested) | NEW: "Hôm nay đã xong hết" (suggested) |
**A11y:** row = one node "Drink water, 5 of 8 glasses, not done" with actions (toggle, add 1, menu); day cells "Wednesday,
November 4, 2026, selected"; reduce-motion for completion animation.

### SCR-03 · Date picker (Today, editors)
Material single-date picker on both platforms, range 2000 → 2100, restyled by tokens only. Opened from the Today calendar icon
(sets the viewed day) and from the editors (start / end / task date). Copy: system **Cancel / OK**.

### SCR-04 · Row menu (⋮)
**Purpose:** secondary actions of a row. **Components:** popup menu / bottom sheet of 2–3 items.
**Items:** **Skip this day** / **Undo skip** (habits, editable days only) · **View progress** (habits) · **Edit** (all).
Tasks have no skip and no progress. Skip must also be reachable without a gesture (it is — keep it in this menu or promote it, §8.1
item 5). **Copy:** Skip this day / Undo skip / View progress / Edit — VI: Bỏ qua ngày này / Bỏ dấu bỏ qua / Xem tiến độ / Sửa.

### SCR-05 · Value sheet (Amount / Time) — bottom sheet, AC-09
**Purpose:** set the day's value for an Amount or Time habit.
**Components:** drag handle · item name (title) · numeric field (label **Record**, suffix = unit or `minutes`, helper
`Target: 8`) · primary **Save** (full width, ≥ 48 dp) · keyboard-aware (sheet rises above the keyboard; Save stays visible).
**States:** empty (value 0 → empty field) · prefilled (e.g. 5) · decimal (`2.5`; VI decimal comma) · long unit (20 chars) ·
condition variants (At least / Exactly / At most) — show the target with its condition text (NEW if you add it) · text 200 %.
**Interactions:** type → Save (also keyboard "done") → value replaces the day's value; sheet closes. Accepts digits, `.` and `,`.
**Copy:** Record / Ghi kết quả · Target: {n} / Mục tiêu: {n} · minutes / phút · Save / Lưu.
*(Date-in-title when editing a past day from the calendar is a §9 proposal — leave room.)*

### SCR-06 · Checklist sheet — bottom sheet, AC-09
**Components:** handle · item name · one **checkbox row per subitem** (title, ≥ 56 dp) · optional counter "2 of 4 items" (existing
string) · closing by drag/back. Ticks save immediately (no Save button). For **tasks with subtasks** the ticks are only notes: they do not
decide whether the task is done.
**States:** none ticked · partial · all · long item titles (wrap) · 20 items (scrolls) · text 200 %.
**Copy:** `{done} of {total} items` / `{done} trên {total} mục`.

### SCR-07 · Create sheet (the "+" menu) — AC-33
**Purpose:** choose what to create. **Components:** handle · two big rows: **New habit** (icon) / **New task** (icon). From Today it
passes the **selected day** to the new task (`?date=`). Replaceable by an expanding FAB menu — either way two choices, in the lower
half. **Copy:** New habit / Thói quen mới · New task / Việc mới.

---

### SCR-08 · Habits — `/habits` (tab 2) — F-01, AC-05, AC-06, AC-32
**Purpose:** manage the list of habits: filter, reorder, open.
**Components:** app bar "Habits" with **Archived** (box icon) and **Categories** (category icon) actions · horizontally scrollable
**category chips** (All + each) · reorderable list · **+** (New habit).
**Row:** category avatar (40 dp) · name · schedule summary (e.g. "Every day", "Every 3 days", "3 times a week", "Day 1, 15 of each
month", weekday names) · **drag handle** (tooltip "Drag to reorder") — tap row opens SCR-10. The order set here is the user's order
(kept after restart; ties inside Today's sort).
**States:** list of 8 · dragging (lifted row) · filtered · **empty** ("No habits yet. Tap + to create your first one.") · empty filtered
("No habits in this category") · 40+ habits (scroll, 88 dp bottom padding) · long names · text 200 % (handle and chips stay 48 dp) · VI.
**Reorder without drag:** provide a non-drag path for screen readers ("Move up / Move down" actions — NEW copy).
**Copy:** Habits / Thói quen · Archived / Đã lưu trữ · Categories / Danh mục · All / Tất cả · New habit / Thói quen mới ·
Drag to reorder / Kéo để sắp xếp · schedule summaries: Every day / Every {n} days / {k} times a week / {k} times a month / Day {days}
of each month — VI: Mỗi ngày / Cứ {n} ngày một lần / {k} lần mỗi tuần / {k} lần mỗi tháng / Ngày {days} hằng tháng.

### SCR-09 · Archived habits — `/habits/archived`
**Components:** app bar "Archived" + back · rows like SCR-08 without handle, trailing text button **Restore** · tap row opens
SCR-10 (history intact, stays on the screen). **States:** list · **empty** ("No archived habits") · long names.
**Copy:** Archived / Đã lưu trữ · Restore / Khôi phục · No archived habits / Chưa có thói quen nào được lưu trữ.

### SCR-10 · Habit detail ("progress") — `/habits/:id` — F-05, F-06
**Purpose:** see how a habit is going and correct past days.
**Components (scrolling page):**
1. App bar: habit name · **Timer** icon (Time habits only → `/pomodoro?habit=`; tooltip "Start timer") · **Edit** icon.
2. **Streak cards (3):** *Current streak* (`12 days`; weeks/months for K-times habits) · *Longest streak* · *Score* (`87/100`).
   Decide the hero (§1.5.4: score + streak together, no loss language).
3. **Success rate:** 7 days · 30 days · All time (`92%`, or `None yet`).
4. **Calendar:** month header with ‹ › (swipe horizontally too); weekday row (starts on the chosen first weekday); 6 cell states —
   **Done / Not done / Skipped / Today not done yet / Not scheduled / Upcoming** — each with colour **and** icon, today outlined;
   legend (Done, Not done, Skipped); cannot go back before the start-date month; tapping a past day or today opens the same
   record flow (toggle for Yes/No, SCR-05, SCR-06); future days not tappable.
5. **Chart** (Amount and Time habits only): segmented **By day** (last 30 days) / **By week** (last 8 weeks); bars with a
   **goal line**; max value label; first/last labels; **Show as table** expander (screen-reader alternative, AC-29).
**States:** brand-new habit (no data: streak 0, rates "None yet", empty calendar, empty chart — design a gentle empty state) ·
Yes/No habit (no chart) · Amount habit with data · Time habit (timer icon) · Checklist habit (no chart) · K-times habit (streak in
weeks) · *At most* habit · archived habit (opened from Archived) · loading (centred progress, brief) · item deleted → returns to the list ·
text 200 % (cards stack vertically).
**Copy:** Current streak / Chuỗi hiện tại · Longest streak / Chuỗi dài nhất · Score / Điểm · Success rate / Tỉ lệ thành công · 7 days
/ 7 ngày · 30 days / 30 ngày · All time / Từ đầu · None yet / Chưa có · Calendar / Lịch · Previous month / Tháng trước · Next month /
Tháng sau · Done / Not done / Skipped (Đạt / Chưa đạt / Đã bỏ qua) · Not scheduled / Không đến hạn · Upcoming / Sắp tới · Today, not
done yet / Hôm nay, chưa xong · By day / Theo ngày · By week / Theo tuần · Show as table / Xem dạng bảng · Date / Value / Ngày / Giá
trị · Week of {date} / Tuần từ {date} · Chart, {count} bars, highest value {max} · Start timer / Bấm giờ · Edit / Sửa.
**A11y:** each streak card is one node ("Current streak, 12 days"); calendar cells "November 3, 2026, Done"; chart announces the summary
sentence, table alternative lists each bar.

---

### SCR-11 · Habit editor — `/habits/new`, `/habits/:id/edit` — AC-01..04, 17
**Purpose:** create or change a habit. **One long form today** — progressive disclosure welcome (§8.1 item 6), same fields and order.
**Fields (top → bottom) and rules:**
| # | Field | Control today | Rules / copy |
|---|---|---|---|
| 1 | **Name** | text, counter 60 | required; error "Enter a name" / "At most 60 characters" |
| 2 | **Description (optional)** | multi-line, counter 300 | |
| 3 | **Category** | dropdown | "No category" + each category — prefer chips/avatars |
| 4 | **Priority** | dropdown | Low / Normal / High |
| 5 | **How to track** | 4 radios | Yes or no · Amount · Time · Checklist |
| 5a | Amount/Time: **condition** | dropdown | At least / Exactly / At most |
| 5b | **Target** | number | "Enter a target greater than 0"; suffix `minutes` for Time |
| 5c | Amount: **Unit** | text, 20 chars | "Unit (e.g. glasses)" |
| 5d | Checklist: **Items** | 1–20 text fields (60 chars), remove ⊖, **Add item** | "Item {n}"; error "Add 1 to 20 items, none empty" |
| 5e | Checklist: **Done when at least** | dropdown | "all items" or "{n} items" |
| 6 | **Repeat** | dropdown (5 patterns) | Every day · On days of the week · On days of the month · Every N days · Times per week or month |
| 6a | Weekday chips | 7 chips (order from week-start) | error "Pick at least one day" |
| 6b | Month-day chips | 1–31 chips | error "Pick at least one day" |
| 6c | Every N days | number | label "Every how many days (2–365)"; error "Enter a number from 2 to 365" |
| 6d | Times per period | number + "per week / per month" | error "At most 7 times a week or 31 times a month" |
| 7 | **Start date** | date row | default today; |
| 8 | **End date** | date row, clear ✕ | "No end date"; error "End date is before start date" |
| 9 | **Reminders** | SCR-14 block | 0–5 |
**App bar:** back · title **New habit** / **Edit habit** · (editing) overflow ⋮: **Archive**, **Delete** (confirm, SCR-15). **Save**
button **pinned at the bottom** (≥ 52 dp), full width.
**Validation behaviour:** tapping Save with an error shows the message at the field and scrolls to it (do the same in the mock).
**States:** new (defaults: Yes/No, Every day, start today, Normal) · each tracking type · each repeat pattern · checklist 1/20 items ·
errors (name, target, items, weekdays, interval, times, end date) · edit mode (prefilled, overflow menu) · reminders with warnings ·
text 200 % · VI · dark · keyboard open (Save stays reachable).
**Copy:** New habit / Thói quen mới · Edit habit / Sửa thói quen · Name / Tên · Description (optional) / Mô tả (không bắt buộc) ·
Category / Danh mục · No category / Không có danh mục · Priority / Ưu tiên · Low · Normal · High / Thấp · Thường · Cao · How to track /
Cách theo dõi · Yes or no · Amount · Time · Checklist / Có hoặc không · Số lượng · Thời gian · Danh sách con · Target / Mục tiêu · Unit
(e.g. glasses) / Đơn vị (ví dụ: ly) · minutes / phút · At least · Exactly · At most / Ít nhất · Đúng bằng · Nhiều nhất · Items / Các mục ·
Add item / Thêm mục · Item {n} / Mục {n} · Remove item / Bỏ mục · Done when at least / Đạt khi xong ít nhất · all items / tất cả các mục ·
{n} items / {n} mục · Repeat / Lặp lại · patterns (see §3.3; VI: Mỗi ngày · Các thứ trong tuần · Các ngày trong tháng · Cứ N ngày một lần ·
Số lần mỗi tuần hoặc tháng) · Times / Số lần · per week / per month / mỗi tuần / mỗi tháng · Start date / Ngày bắt đầu · End date / Ngày
kết thúc · No end date / Không có ngày kết thúc · Clear / Bỏ · Save / Lưu · Archive / Lưu trữ · Delete / Xóa.
**A11y:** each error is announced and focuses its field; radio groups and chips expose selected state.

### SCR-12 · Task editor — `/tasks/new[?date=]`, `/tasks/:id` — AC-13, AC-14
Same screen as SCR-11 with these differences: title **New task / Edit task**; **no** description, **no** "How to track" (always Yes/No), **no
Archive**; field "**Subtasks (optional)**" (0–20, "Add item") instead of tracking; **Repeat** adds **"Does not repeat"** (default); the date row
is labelled **Date** (not Start date) for one-off tasks and may be **cleared** (→ "Unscheduled"); a **Time** row appears when a date exists
("No time" / clear ✕); End date only for repeating tasks; reminders as SCR-14. Delete confirm text: "Delete this task?".
**States:** new from Today (date pre-filled = selected day) · new without date · repeating task · edit overdue task (date in the past) ·
unscheduled · with subtasks · errors (name, date required for repeating: "Pick a start date").
**Copy:** New task / Việc mới · Edit task / Sửa việc · Subtasks (optional) / Việc con (không bắt buộc) · Does not repeat / Không lặp lại ·
Date / Ngày · Time / Giờ · No time / Không đặt giờ · Unscheduled / Chưa xếp lịch · Pick a start date / Chọn ngày bắt đầu · Delete this task? / Xóa
việc này?

### SCR-13 · Editor pickers
Material **time picker** (task time, reminder time; 12/24 h by device) and **date picker** (SCR-03) restyled by tokens; first the keyboard focus
is dropped so the picker closes cleanly. Schedule widgets (weekday chips, month-day grid 1–31, number fields) are part of SCR-11; design the
31-chip grid (wraps, 48 dp targets, selected state without colour alone).

### SCR-14 · Reminder block and permission dialogs — AC-17, 18, 20
**Reminder block (inside the editors):** list of 0–5 rows: **time** (tap → time picker) · kind dropdown **Notification | Alarm** (icon
differs: bell / alarm clock) · remove ⊖ ("Remove reminder"); **Add reminder** button (hidden at 5). On iPhone the "Alarm" option should carry a small note
that it arrives as a time-sensitive notification (NEW: "On iPhone, alarms arrive as time-sensitive notifications.").
**Warning rows** (below, each with an **Open settings** button; only when ≥ 1 reminder exists): *Notifications are off, reminders will not
appear* · *Reminders may be a few minutes late* (Android, exact alarms missing) · *Alarms will show as a pop-up notification* (Android,
full-screen missing and an Alarm reminder exists). Warning = icon + text, never colour only.
**Explain-first dialogs** (shown the first time; **Not now** / **Allow**): *Allow notifications?* · *Remind on time?* (Android) · *Show alarms on
the lock screen?* (Android). Choosing Allow opens the OS prompt / system settings; choosing Not now keeps the reminder saved (with the warning row).
**States:** 0 reminders · 1 · 5 (Add hidden) · each kind · permission denied (warning rows) · Android vs iPhone variants · text 200 % · VI.
**Copy:** Reminders / Giờ nhắc · Add reminder / Thêm giờ nhắc · Remove reminder / Bỏ giờ nhắc · Notification / Thông báo · Alarm / Chuông báo
thức · Not now / Để sau · Allow / Cho phép · Open settings / Mở cài đặt · dialog titles/bodies: see `permNotifTitle/Body`, `permExactTitle/Body`,
`permFullTitle/Body` (EN/VI in §2.5) — titles: Allow notifications? / Remind on time? / Show alarms on the lock screen? — Cho phép thông báo? / Nhắc đúng giờ? /
Hiện chuông trên màn hình khóa? · warnings: see above (VI: Thông báo đang tắt, nhắc giờ sẽ không hiện · Nhắc có thể trễ vài phút · Chuông sẽ hiện dạng
thông báo nổi).

### SCR-15 · Delete / archive confirmations and undo (editors)
- **Delete habit/task dialog:** body "Delete this habit and all its history?" / "Delete this task?" · **Cancel** · **Delete** (destructive style). (The
  prototype has no title — add one if you like, NEW.) After confirming: editor closes → snackbar **"Deleted · Undo"** (5 s).
- **Archive** (habit): no dialog → editor closes → snackbar **"Archived · Undo"**.
- Snackbar details in SCR-30.

---

### SCR-16 · Tasks — `/tasks` (tab 3) — F-03, AC-15, AC-16
**Components:** app bar "Tasks" · **filter chips:** Today · Upcoming · Overdue · Unscheduled · Done (single-select; remembered while the app runs) ·
list of rows (SCR-02 anatomy, with the **date** shown in the secondary line; overdue tasks `Overdue · N days`) · **+** → SCR-07.
**States:** each filter with items · **empty** per filter ("No tasks here") — design a distinct friendly empty state per filter (NEW copy optional) · Overdue
filter with 3 items · Done filter (struck rows) · Unscheduled (no date line) · repeating tasks · tasks with subtasks (secondary line "1 of 3 items") · 40+ items ·
text 200 % (chips scroll) · VI.
**Interactions:** circle toggles done (a task done after its day still records on its own day); tap row → toggles too — **editing is via ⋮ → Edit**
(prototype behaviour); consider whether a tap should open the editor (§8.1 item 11).
**Copy:** Tasks / Việc · Today · Upcoming · Overdue · Unscheduled · Done / Hôm nay · Sắp tới · Quá hạn · Chưa xếp lịch · Đã xong · No tasks here / Không có
việc nào · Create / Tạo mới.

### SCR-17 · Statistics — `/stats` (tab 4) — F-06, AC-28, AC-29
**Purpose:** overall consistency across everything, last 7 and 30 days, plus the best streaks.
**Components:** app bar "Statistics" + Settings gear · **Last 7 days** block: headline `37 of 47 done` + bar chart (one bar per day: done vs a faint "total"
ghost bar) + first/last date labels + **Show as table** · **Last 30 days** block (same) · **Longest streaks**: up to 3 rows (rank 1–3, habit name, streak
in days/weeks/months) → tap opens SCR-10.
**States:** with data (§7) · **empty** ("Add habits or tasks to see statistics") · streaks block empty ("No streaks yet") · only a few days of data (bars sparse) ·
a habit streak in weeks mixed with days (§8.1 item 17) · 30-day chart with 30 bars at 360 dp (labels thin out) · text 200 % · dark · VI.
**Copy:** Statistics / Thống kê · Last 7 days / 7 ngày gần nhất · Last 30 days / 30 ngày gần nhất · {done} of {total} done / {done} trên {total} xong · Longest
streaks / Chuỗi dài nhất · No streaks yet / Chưa có chuỗi nào · Show as table / Xem dạng bảng · Done / Total / Xong / Tổng · Add habits or tasks to see statistics /
Thêm thói quen hoặc việc để xem thống kê · Chart, {count} bars, highest value {max}.
**A11y:** each chart is one sentence + table; the three streak rows are single nodes ("1, Take medicine, 31 days").

### SCR-18 · Pomodoro — `/pomodoro[?habit=id]` — F-09, AC-35..38
**Components:** app bar "Pomodoro" + back · when running: line **"{Phase} · Session {n}"** (Focus / Short break / Long break) · **big countdown** `mm:ss`
(tabular figures; a progress ring is welcome) · controls · *(idle only)* "Add minutes to habit" dropdown listing **Time** habits ("Not linked" first;
hidden if there are none) · "Durations (minutes)" with 4 **steppers**: Focus, Short break, Long break, Sessions before long break (− value +).
**Control states:**
| State | Display | Buttons |
|---|---|---|
| Idle | Focus length (e.g. `25:00`) | **Start** |
| Focus running | `18:42` | **Stop** |
| Break running | `04:10` | **Skip break**, **Stop** |
| Phase finished | "Finished" | **Next phase**, **Stop** |
| Credited | snackbar "Added {minutes} min" | — |
| Opened from a Time habit (`?habit=`) | habit pre-selected in the dropdown | — |
| Notification permission asked at Start (OS dialog; iPhone & Android 13+) | | |
**Other states:** app killed and reopened (timer resumes at the correct remaining time, or shows "Finished") · screen off (nothing special) · stepper at bounds
(disable) · text 200 % (steppers wrap under their label, buttons stack) · long habit names in the dropdown · VI.
**Copy:** Pomodoro · Start / Stop / Next phase / Skip break (Bắt đầu / Dừng / Giai đoạn kế tiếp / Bỏ qua nghỉ) · Focus / Short break / Long break (Tập trung / Nghỉ
ngắn / Nghỉ dài) · Session {n} / Phiên {n} · Finished / Đã hết giờ · Durations (minutes) / Thời gian (phút) · Sessions before long break / Số phiên trước nghỉ dài · Add
minutes to habit / Cộng phút vào thói quen · Not linked / Không liên kết · Added {minutes} min / Đã cộng {minutes} phút · end notification: **Time is up — This phase has
ended.** / **Hết giờ — Giai đoạn đã kết thúc.**
**A11y:** the countdown is a live region updated sparingly (e.g. every minute) not every second; steppers have labels "− Focus" / "+ Focus".

---

### SCR-19 · Categories — `/categories` — F-07
**Components:** app bar "Categories" + back · list: avatar (40 dp, category colour, white glyph) · name (localised for defaults) · tap opens SCR-20 · **+** "Add category"
(88 dp bottom padding). The spec lists **rename / re-icon / re-colour / delete** only — no reordering is required (the prototype has none).
**States:** 8 defaults · 20 categories (scroll) · long name (40 chars) · text 200 % · VI. Reached today only from the Habits tab icon — also from Settings? (proposal, §8.1 item 9).
**Copy:** Categories / Danh mục · Add category / Thêm danh mục.

### SCR-20 · Category editor sheet and delete dialog — AC-31
**Sheet (keyboard-aware, scrolls):** title **Add category / Edit category** · **Name** (≤ 40; error "Enter a name") · **Icon** grid (23 icons, ≥ 48 dp; selected
shows the icon filled in the chosen colour) · **Color** grid (16 swatches ≥ 48 dp; selected = ring + ✓, labelled with the hex, e.g. "Color #c62828") · buttons **Delete category**
(edit only, text style, start) and **Save** (end). Default categories keep their localised name unless renamed.
**Delete dialog:** title "Delete this category?" · body `{count}` plural: *No item uses this category.* / *1 item uses this category. Move it to:* / *{n} items use this category.
Move them to:* · if count > 0: list of the **other categories** (avatar + name) and **No category**; if count = 0: a **Delete** option · **Cancel**. Choosing a target deletes and moves.
**States:** add · edit default · name error · long name · keyboard open · delete with 0 / 1 / 37 items · only 2 categories left.
**Copy:** Add category / Thêm danh mục · Edit category / Sửa danh mục · Name / Tên · Enter a name / Nhập tên · Icon / Biểu tượng · Color / Màu · Delete category / Xóa danh mục ·
Save / Lưu · Delete this category? / Xóa danh mục này? · No item uses this category. / Không có mục nào dùng danh mục này. · {n} items use this category. Move them to: / {n} mục
đang dùng danh mục này. Chuyển sang: · No category / Không có danh mục · Cancel / Hủy · Delete / Xóa.
**A11y:** icon buttons need real names (the prototype exposes the raw key like "directions_run") — provide human labels (NEW copy) or accept the keys; swatches announce "Color N, selected".

---

### SCR-21 · Settings — `/settings` — AC-48, F-11..F-14
**Purpose:** appearance, language, week start, security and data. One scrolling list in **sections**. Reached from the gear on Today and Statistics.
**Order and components (as built in the G7 working tree, 2026-11-04):**
| # | Item | Control | Behaviour |
|---|---|---|---|
| 1 | **Theme** | 3 radios: System default / Light / Dark | instant |
| 2 | **Language** | 3 radios: Device language / Tiếng Việt / English | instant; labels "Tiếng Việt", "English" are never translated |
| 3 | **First day of week** | 2 radios: Monday / Sunday | instant |
| 4 | **Security** (section) · **PIN lock** | row: lock icon + title + subtitle **Off / On** + **switch** | switch (or row tap) On → SCR-23 setup; Off → SCR-23 check |
| 4b | **Change PIN** | row, **only when PIN is on** | SCR-23 check, then setup |
| 5 | **Data** (section) · **Export backup** | row + subtitle "Creates a .dailyloop file to keep or move to another device" | SCR-22 → share sheet |
| 6 | **Restore from file** | row + subtitle "Pick a .dailyloop file you exported earlier" | SCR-22 |
| 7 | **Export history as CSV** | row + subtitle "Opens in Excel or Google Sheets" | SCR-22 → share sheet |
| 8 | **Erase all data** | row in destructive colour **and** wording + subtitle "Deletes habits, tasks, history, reminders, settings and the PIN" | SCR-25 |
| 9 | **About** *(spec AC-51; not built yet)* | row › | SCR-26 |
Each radio option is its own line so 200 % text never clips (AC-50) — you may use segmented controls on normal text but they must stack at ≥ 130 %. Opportunity: a **Categories** entry here (§8.1 item 9).
**States:** top and bottom halves · PIN on (with Change PIN) / off · VI (longest labels) · text 200 % · dark · iPhone vs Android (identical apart from system chrome).
**Copy (existing):** Settings / Cài đặt · Theme / Giao diện · System default / Theo hệ thống · Light / Sáng · Dark / Tối · Language / Ngôn ngữ · Device language / Theo máy · First day of week / Ngày đầu tuần · Monday / Thứ Hai · Sunday / Chủ Nhật ·
Security / Bảo mật · PIN lock / Khóa bằng mã PIN · Off / Đang tắt · On / Đang bật · Change PIN / Đổi mã PIN · Data / Dữ liệu · Export backup / Xuất bản sao lưu · Creates a .dailyloop file to keep or move to another device / Tạo file .dailyloop để cất giữ hoặc chuyển sang máy khác ·
Restore from file / Khôi phục từ file · Pick a .dailyloop file you exported earlier / Chọn file .dailyloop đã xuất trước đó · Export history as CSV / Xuất lịch sử ra CSV · Opens in Excel or Google Sheets / Mở được bằng Excel hoặc Google Sheets ·
Erase all data / Xóa toàn bộ dữ liệu · Deletes habits, tasks, history, reminders, settings and the PIN / Xóa thói quen, việc, lịch sử, giờ nhắc, cài đặt và mã PIN.
**NEW:** a one-line "Data is stored only on this phone. Export a backup regularly." under the **Data** header (the spec says backup files are **not encrypted** — say so near Export backup, e.g. NEW "Backup files are not encrypted. Keep them somewhere safe."); **About**.
**A11y:** radios and switch announce state (+ the PIN warning); destructive row announced normally (colour + wording).

### SCR-22 · Backup, restore and CSV (from Settings) — AC-42..44
- **Export backup:** creates `dailyloop-YYYYMMDD-HHMM.dailyloop` (JSON) → OS share sheet (**placeholder**; anchored to the row on iPad). Optional brief progress state (local, < 1 s). No storage permission. Failure → snackbar "Could not export the file".
- **Export history as CSV:** `dailyloop-YYYYMMDD-HHMM.csv`; columns carry the localised words **Habit / Task**, **Done / Not done / Skipped** → share sheet.
- **Restore from file:** OS file picker (placeholder) → file validated **before** anything changes:
  - invalid → **snackbar** "The backup file is damaged, in the wrong format or made by a newer Orbiday. Your current data was left untouched." (3 lines at 360 dp / VI) — no dialog;
  - valid → **confirm dialog**: title **Restore**, body "Your current data will be replaced by the contents of the backup file.", **Cancel** · **Restore** → (brief progress) → snackbar "Data restored"; filters reset; reminders re-scheduled.
- **States:** each action default · exporting · system picker · invalid file · valid-file confirm · restoring · success · very large history (still quick) · export error · VI.
- **Copy:** Export backup / Xuất bản sao lưu · Restore from file / Khôi phục từ file · Restore / Khôi phục · Confirm / Xác nhận · Cancel / Hủy · Data restored / Đã khôi phục dữ liệu · The backup file is damaged… / File sao lưu hỏng, sai định dạng hoặc do bản Orbiday mới hơn tạo ra. Dữ liệu hiện tại được giữ nguyên. · Could not export the file / Không xuất được file · restore-confirm VI: Dữ liệu hiện tại sẽ bị thay thế bằng nội dung của file sao lưu.
- **NEW (spec AC-42):** a reminder that backups are **not encrypted** near the export action.

### SCR-23 · PIN setup, change and turn-off (full-screen dialogs from Settings) — AC-45
**Setup (also step 2 of Change PIN):** full-screen with an app bar **PIN lock** and a visible **close/back** control (cancel = PIN not enabled) · title **Set a 4-digit PIN** · warning paragraph (see copy — "The PIN only keeps curious people out of the app; it does not encrypt your data…") · **4 progress dots** · error line · **PIN pad** (3 × 4, keys ≥ 64 dp: 1–9, blank, 0, backspace) · after the 4th digit → title becomes **Enter the PIN again** → match = saved, switch on, screen closes; mismatch → "The two entries do not match", back to step 1.
**Check (turn off / first step of Change PIN):** same screen, title **Enter your current PIN**; correct → proceeds (PIN off, or setup); wrong → "Wrong PIN" (light haptic, dots clear).
**States:** idle · 2 digits · confirm step · mismatch · wrong · text 200 % (keys stay ≥ 48 dp; the area above scrolls, pad pinned) · iPhone SE height · dark · VI.
**Copy (existing):** PIN lock / Khóa bằng mã PIN · Set a 4-digit PIN / Đặt mã PIN 4 số · Enter the PIN again / Nhập lại mã PIN · Enter your current PIN / Nhập mã PIN hiện tại · The two entries do not match / Hai lần nhập không khớp · Wrong PIN / Sai mã PIN ·
`pinWarning` EN: "The PIN only keeps curious people out of the app; it does not encrypt your data. If you forget it, the only way back in is to erase all data." · VI: "PIN chỉ ngăn người tò mò mở app, không mã hóa dữ liệu. Quên mã thì chỉ còn cách xóa toàn bộ dữ liệu để dùng lại." ·
Turn off PIN lock / Tắt khóa PIN · Change PIN / Đổi mã PIN.
**A11y:** keys "Digit N" / "Số N"; backspace "Delete last digit" / "Xóa số cuối"; dots = live region "{n} of 4 digits entered" / "Đã nhập {n} trên 4 số"; error announced.

### SCR-24 · Lock screen and Forgot PIN — AC-46, AC-47
**Lock overlay (covers the whole app, including the Welcome screen):** lock icon or logo · title **Enter PIN** · 4 dots · fixed-height error line ("Wrong PIN") · PIN pad · text button **Forgot PIN**. Correct PIN → returns to the exact screen that was open. Wrong → clears, light haptic, unlimited retries.
While the app checks whether a PIN is set: blank surface-coloured screen (no flash of content). Content behind is hidden from screen readers; the app-switcher preview must not leak names (note for dev).
**Forgot PIN (as built):** (1) dialog titled **Forgot PIN** with the explanation (`forgotPinBody`) and **Cancel** / **Erase all data**; (2) confirm dialog **Erase all data** — "All habits, tasks, history, reminders and settings will be erased from this device. This cannot be undone." — **Cancel** / **Delete**;
(3) final confirm **Erase all data** — "Really erase everything? Export a backup first if you still need your data." — **Cancel** / **Erase all data**. After: data wiped, PIN off, app returns to the first screen (Welcome) + snackbar "All data erased". Cancel at any step returns to the lock screen.
*(The spec says "two-step confirmation"; the build shows explanation + 2 confirmations = 3 dialogs. Design all three, each reusable.)*
**Locked alarm (Android, PIN on):** the alarm screen (SCR-27) still appears over the lock with **Done / Snooze 10 min / Dismiss** and **no PIN**, plus a fourth text button **Open app (PIN required)** that goes to this PIN screen. The prototype still shows the item name there — the spec hides names on locked notifications; **design a hidden-name variant** (NEW: "Time for your reminder") and flag the choice.
**States:** idle · 2 digits · wrong PIN · each Forgot dialog · locked alarm · secure-storage error (looks the same; only Forgot PIN works) · text 200 % · dark · iPhone SE · VI.
**Copy (existing):** Enter PIN / Nhập mã PIN · Wrong PIN / Sai mã PIN · Forgot PIN / Quên mã · `forgotPinBody` EN: "If you forgot the PIN, the only option is to erase all data on this device and start over. Data you exported to a backup file can be restored." · VI: "Quên mã thì chỉ có thể xóa toàn bộ dữ liệu trên máy để dùng lại app. Dữ liệu đã xuất ra file sao lưu thì khôi phục lại được." ·
Open app (PIN required) / Mở app (cần mã PIN) · Erase all data / Xóa toàn bộ dữ liệu · Delete / Xóa · Cancel / Hủy.
**Hidden-name rule:** with PIN on, nothing on this screen, in notifications or in widgets shows habit or task names (AC-41, AC-46).

### SCR-25 · Erase all data (from Settings) — AC-52
Two dialogs in a row: (1) title **Erase all data**, body "All habits, tasks, history, reminders and settings will be erased from this device. This cannot be undone.", **Cancel** · **Delete**; (2) title **Erase all data**, body "Really erase everything? Export a backup first if you still need your data.", **Cancel** · **Erase all data** (destructive-filled).
Result: database, settings and PIN cleared, reminders cancelled, widget emptied, router back to the first screen — the **Welcome** screen shows again (as if newly installed); snackbar "All data erased".
VI: Xóa toàn bộ dữ liệu · Toàn bộ thói quen, việc, lịch sử, giờ nhắc và cài đặt sẽ bị xóa khỏi máy này. Không hoàn tác được. · Chắc chắn xóa hết? Hãy xuất bản sao lưu trước nếu còn cần dữ liệu. · Xóa · Hủy · Đã xóa toàn bộ dữ liệu.
Note: the dialogs have a title, a body and one filled action; the destructive level should be visible in step 2 (colour **and** the word).

### SCR-26 · About — AC-51 (**NEW screen; no prototype**)
**Components:** logo/wordmark "Orbiday" · "Version {version}" · one reassuring privacy line ("Your data is stored only on this phone. Orbiday does not send it anywhere.") · rows: **Privacy policy** (opens the browser; **disabled with subtitle
"Web page coming soon"** while no URL exists — design the disabled state so it does not look broken), **Report a security issue** (subtitle "Contact email: {email}", opens the mail app), **Open source licenses** (OS-style licence list).
**States:** policy enabled / pending · "Could not open it. You can write to {target} yourself." snackbar · VI. Placeholder email in mocks: `hello@example.com`.
All NEW copy; VI suggestions: Giới thiệu · Phiên bản {version} · Dữ liệu chỉ lưu trên máy này. Orbiday không gửi dữ liệu đi đâu. · Chính sách quyền riêng tư · Đang chuẩn bị trang web · Báo lỗi bảo mật · Email liên hệ: {email} · Giấy phép nguồn mở.
Also state clearly (one line, quiet): free, no ads, no purchases — it is a differentiator (§8.2).

---

### SCR-27 · Alarm — `/alarm` (**Android only**, full-screen over the lock screen) — AC-20, AC-46
**Purpose:** a clock-alarm-like screen when an **Alarm** reminder fires. Sound repeats until a button is pressed or 5 min pass.
**Components:** big alarm icon (or brand mark) · current **time** (large) · "Time for" · **item name** (headline) · primary **Done** (only for Yes/No habits and tasks; ≥ 56 dp) · **Snooze 10 min** (tonal) · **Dismiss** (outlined) · *(PIN on only)* text button **Open app (PIN required)**.
Background uses a strong brand surface; contrast ≥ 4.5:1. After any button: closes (or returns to Today).
**States:** Yes/No habit (3 buttons) · Amount/Time/Checklist habit (**no Done**; only Snooze + Dismiss) · long name (3 lines, then ellipsis) · **PIN on** (the screen still shows without a PIN; extra **Open app (PIN required)** button → PIN screen; name hidden variant — NEW "Time for your reminder", see SCR-24) ·
no full-screen permission (this screen never shows; heads-up notification instead, SCR-28) · text 200 % (buttons stack, time shrinks) · dark.
**Copy:** Time for / Tới giờ · Done / Xong · Snooze 10 min / Hoãn 10 phút · Dismiss / Tắt · Open app (PIN required) / Mở app (cần mã PIN).
**A11y:** name is a heading; buttons large and reachable one-handed at the bottom; sound is not the only cue.

### SCR-28 · Notifications (Android + iPhone) — AC-17, AC-19, AC-46 (system-owned container, designed content)
- **Reminder notification:** title = **item name**; body empty today — propose NEW subtle body (e.g. time or "Reminder"); channel "Reminders". Action **Done** (Yes/No & tasks only; marks done without opening the app); tap → opens the app at the item.
- **Alarm notification (heads-up fallback on Android / the iPhone representation):** same title; channel "Alarms"; actions **Done** (Yes/No & tasks), **Snooze 10 min**, **Dismiss**; iPhone: **time-sensitive** interruption level, longer sound.
- **Pomodoro end:** title **Time is up**, body **This phase has ended.**; sound.
- **PIN on:** title/body hide the item name — NEW: "Orbiday" / "You have a reminder" (VI: "Orbiday" / "Bạn có một lời nhắc"); Done action is not offered (cannot verify) — to confirm with G7.
- **Frames:** Android lock-screen and shade, expanded with actions; iPhone lock screen and expanded; the small-icon/status-bar icon (Android, monochrome); notification category icon. Show a stack of 3 reminders too.
**Copy:** Reminders / Nhắc giờ (channel) · Alarms / Chuông báo thức (channel) · Done / Xong · Snooze 10 min / Hoãn 10 phút · Dismiss / Tắt · Time is up / Hết giờ · This phase has ended. / Giai đoạn đã kết thúc.

### SCR-29 · Home-screen widget "Today" — AC-39..41
**Purpose:** see the day's list and tick without opening the app. Updates within 5 s of a change and switches to the new day after midnight.
**Android widget (resizable; min 4×2):** header **Today** (start) + summary (end): `3 left` / `All done` / `Nothing planned for today` · scrollable list of rows: **tick box** (Yes/No habits and tasks tick right in the widget; Amount/Time/Checklist rows show a
**non-ticking** indicator and tapping the name opens the app) · name (struck when done; **skipped** = skip icon) · tap on the **name** opens `/habits/:id` or `/tasks/:id`. Sizes to design: **4×2 (≈ 3 rows), 4×3, 4×4**; light/dark follows the system.
**iPhone widget (WidgetKit):** **small** (count left + a ring; no list), **medium** (≈ 4 rows), **large** (≈ 8 rows); tapping a circle ticks (iOS 17+ interactive; earlier: opens the app); tap name → opens the item. Lock-screen widgets are out of scope (§9).
**States for each size:** list with some done · all done · empty ("Nothing planned for today") · more rows than fit (truncate: "+N more" NEW) · **PIN on** (no names: only the summary `3 left`, plus a lock mark and "Open Orbiday" — NEW copy; rows hidden, AC-41) ·
widget not yet loaded / app never opened (placeholder) · dark · VI (`Còn 3 mục`, `Đã xong hết`) · long names (1 line, ellipsis) · large system text.
**Copy:** Today / Hôm nay · {n} left / Còn {n} mục · All done / Đã xong hết · Nothing planned for today / Hôm nay chưa có việc nào.
**A11y:** each row = "Drink water, not done" button; header reads the summary.

### SCR-30 · Shared patterns: dialogs, sheets, snackbars, empty states
- **Dialog:** title (optional), body, **Cancel** + action; destructive actions use a distinct style plus the word (Delete). Tap outside / Back = Cancel. Used by: delete confirms, permission explain, category delete (list dialog), PIN/wipe.
- **Bottom sheets:** drag handle, keyboard-aware, ≥ 48 dp actions: create, value, checklist, category editor.
- **Snackbar** (floating, above the **+** and the bottom navigation, never covering the primary action permanently): "Deleted · Undo" (5 s, survives navigation), "Archived · Undo", "Added {minutes} min", "You can only record days up to today", "Data restored", "All data erased", "Could not export the file", the restore-failed message. Design 1-line and 2-line (VI) variants and a 200 % variant.
- **Empty states** (all texts exist): Today, Habits, Habits filtered, Archived, Tasks (per filter), Statistics, Statistics streaks. One illustration style, one tone: friendly, not childish, never blaming.
- **Loading:** local database — no network spinners; skeleton or nothing for ≤ 100 ms. Only Habit detail / editor show a short centred progress.

### Appendix · Strings not spelled out above (so the copy list is complete)
Inline errors and small labels, EN | VI: Once / Một lần (schedule summary of a one-off task) · At most 60 characters / Tối đa 60 ký tự · Enter a target greater than 0 / Nhập mục tiêu lớn hơn 0 · Pick at least one day / Chọn ít nhất một thứ (weekdays) or
Chọn ít nhất một ngày (month days) · Enter a number from 2 to 365 / Nhập số từ 2 tới 365 · End date / Ngày kết thúc · End date is before start date / Ngày kết thúc trước ngày bắt đầu · Undo / Hoàn tác · No habits in this category / Danh mục này chưa có thói quen ·
Delete this task? / Xóa việc này? · No tasks here / Không có việc nào · Alarms will show as a pop-up notification / Chuông sẽ hiện dạng thông báo nổi · Value / Giá trị · Chart, {count} bars, highest value {max} / Biểu đồ, {count} cột, giá trị cao nhất {max} ·
Short break / Nghỉ ngắn · {n} left / Còn {n} mục · Digit {d} / Số {d} · Item {n} / Mục {n} · {n} items / {n} mục · Overdue · {n} days / Quá hạn · {n} ngày · Streak units: 1 day / {n} days · 1 week / {n} weeks · 1 month / {n} months — VI: {n} ngày / {n} tuần / {n} tháng ·
`{value} of {target}` / `{value} trên {target}` · plural category dialog: see SCR-20.

---

## 6. Key flows (step by step — prototype these)

**F1 · Mark a Yes/No habit done (target: 1 tap)** — Today → tap the circle of **Take blood-pressure medicine** → circle turns to ✓, row dims and sinks → tap again to undo. From the widget: tap the box. From the notification: **Done**.

**F2 · Record an Amount** — Today → **+1** on **Drink water** (5 → 6 of 8 glasses) · or tap the row → value sheet → type `8` → **Save** → row shows ✓ and "8 of 8 glasses".

**F3 · Record Time / Checklist** — tap **Read** row → sheet → `20` → Save (✓). Tap **Evening routine** → tick items (2 of 4 → 3 of 4 reaches the ≥ 3 goal → ✓) → close the sheet.

**F4 · Skip a day** — Today → ⋮ on **Morning run** → **Skip this day** → row shows the skip icon + "Skipped", streak untouched → ⋮ → **Undo skip**.

**F5 · Create a habit** — Today **+** → **New habit** → name "Drink water" → category Health → How to track **Amount** → condition At least · target 8 · unit "glasses" → Repeat **Every day** → add reminders 09:00, 12:00, 15:00, 18:00 (Notification) → first-time **explain dialog → Allow → OS prompt** → **Save** → back on Today, habit visible. *(Edge: tap Save with empty name → error at the name field.)*

**F6 · Create a task and handle overdue** — **+** → **New task** → "Call dentist" → date today → time 17:00 → **Save**. Two days later it appears on top with `Overdue · 2 days` → tap its circle (done) or ⋮ → Edit → change the date.

**F7 · Past and future days** — tap **Mon 2** in the day strip → app bar shows "Monday, November 2" + *Back to today* → tap a row (editable). Tap **Fri 6** → rows dimmed; tapping a circle shows "You can only record days up to today".

**F8 · Review progress and fix a past day** — Habits tab → tap **Drink water** → detail (streak 12 days, score 87/100, rates, calendar) → tap **Oct 22** (Not done) in the calendar → value sheet → enter 8 → Save → calendar cell turns ✓, streak/score update. Amount habit: By day ↔ By week; Show as table.

**F9 · Pomodoro for a Time habit** — Habit detail of **Read** → timer icon → Pomodoro with the habit pre-linked → Start → (OS notification permission once) → countdown → Stop at 12:00 elapsed → "Added 12 min" → Today shows "12 of 20 minutes". Also Today → timer icon (no link) → durations editable → Start → phase finished → **Next phase**.

**F10 · Alarm (Android)** — Reminder kind **Alarm** at 07:30 for **Take blood-pressure medicine** → phone locked → full-screen alarm → **Done** (marks done) / **Snooze 10 min** / **Dismiss**. (iPhone: time-sensitive notification with the same actions.)

**F11 · Categories** — Habits tab → category icon → Categories → **+** → name "Reading", icon `menu_book`, colour → Save. Edit a category in use → Delete category → "3 items use this category. Move them to:" → pick **Study**.

**F12 · Backup / restore / CSV** — Settings → **Export backup** → share sheet → save to Files/Drive. **Restore from file** → file picker → (bad file: snackbar, nothing changed) / (good file: dialog **Restore** "Your current data will be replaced by the contents of the backup file." → Restore → "Data restored"). **Export history as CSV** → share sheet.

**F13 · PIN on / lock / off / forgot** — Settings → **PIN lock** switch on → set a 4-digit PIN → enter again → on. Background > 1 min → return → Lock screen → enter PIN → same screen. Off: switch → Enter your current PIN → off. Change: Settings → **Change PIN** → current PIN → new PIN twice. Forgot: Lock → **Forgot PIN** → explanation → confirm → final confirm → fresh app (Welcome).

**F14 · Erase all data** — Settings → **Erase all data** → Delete → Erase all data → Welcome + "All data erased".

**F15 · Delete a habit with undo** — Habit detail → Edit → ⋮ → **Delete** → confirm → editor and detail close → snackbar **"Deleted · Undo"** (5 s) → Undo restores it with history. Archive path: ⋮ → **Archive** → "Archived · Undo"; Habits → Archived → **Restore**.

**F16 · Widget** — Home screen → Today widget shows "3 left" → tick **Drink water**'s box (Yes/No only) → "2 left" within 5 s; tap **Evening routine** name → app opens at the habit's detail. With PIN on the widget shows only "2 left".

---

## 7. Sample data for mockups
Language EN for base frames (VI for checks). Mock **today = Wednesday 4 November 2026** (week starts Monday). Day strip = the 7 days centred on Wed 4 = **Sun 1 … Sat 7**. Colours are **your** call; use the 8 default categories (with their stored colours as placeholders until you propose new ones).

**Habits** (name · category · how to track · schedule · reminders · state):
| # | Habit | Category | Tracking | Schedule | Reminders | Streak (cur / best) · score | Today (Wed 4) |
|---|---|---|---|---|---|---|---|
| 1 | Drink water / Uống nước | Health | Amount · at least **8 glasses** | Every day | 09:00, 12:00, 15:00, 18:00 (Notification) | 12 days / 21 days · 87/100 | **5 of 8 glasses** (not done) |
| 2 | Morning run / Chạy bộ | Sport | Amount · at least **3 km** | On Mon, Wed, Fri, Sat | 06:00 Alarm | 5 days / 9 days · 74/100 | due; **Skipped** (rain) — use also an un-skipped variant `0 of 3 km`, and `2.5 of 3 km` |
| 3 | Read before bed / Đọc sách | Study | Time · at least **20 minutes** | Every day | 21:00 Notification | 8 days / 14 days · 81/100 | **0 of 20 minutes**; Pomodoro-linked |
| 4 | Take blood-pressure medicine / Uống thuốc huyết áp | Health | Yes or no · priority **High** | Every day | 07:30 **Alarm** | 31 days / 31 days · 96/100 | **Done** ✓ (sinks to the bottom) |
| 5 | Evening routine / Thói quen buổi tối | Home | Checklist (Prepare tomorrow's bag · Tidy the desk · Stretch 5 min · Phone away from bed), done when **at least 3 of 4** | Every day | 21:30 Notification | 3 days / 10 days · 69/100 | **2 of 4 items** |
| 6 | Coffee limit / Giới hạn cà phê | Health | Amount · **at most 2 cups** | Every day | — | 17 days / 17 days · 90/100 | **1 of 2 cups** (within limit → achieved) |
| 7 | Study English / Học tiếng Anh | Study | Yes or no | **3 times a week** | 19:00 Notification | **6 weeks** / 9 weeks · 78/100 | due until 3 ticks; 2 ticks this week |
| 8 | Review budget / Xem lại ngân sách | Finance | Yes or no | Days 1 and 15 of each month | — | 4 months / 4 months | not due today |
| 9 | Water the plants / Tưới cây | Home | Yes or no | Every 3 days | — | 3 days / 6 days | not due today (due Nov 6) |
Long-name stress habit (60 chars): "Practise Vietnamese–English translation exercises before bed" / "Luyện dịch Việt–Anh cho các bài tập trước khi đi ngủ hằng ngày".
An archived habit: **Cold showers / Tắm nước lạnh** (Mind), archived Oct 12.
A **brand-new** habit with no data and a habit whose goal was edited are optional states.

**Tasks:**
| Task | Date / time | Priority | Notes | State |
|---|---|---|---|---|
| Call the dentist / Gọi nha sĩ | Nov 2 (2 days ago) | Normal | | **Overdue · 2 days** |
| Submit expense report / Nộp báo cáo chi phí | Today 17:00 | High | reminder 16:30 Notification | open |
| Buy a birthday gift / Mua quà sinh nhật | Tomorrow (Nov 5) | Normal | subtasks: Pick a gift · Buy a card · Wrap it | upcoming (1 of 3 items) |
| Renew passport / Gia hạn hộ chiếu | no date | Low | | Unscheduled |
| Pay the electricity bill / Đóng tiền điện | Monthly on day 5 (repeating task) | Normal | | upcoming |
| Book flights / Đặt vé máy bay | Today | Normal | | **Done** |
Filter counts for the Tasks tab: Today 3 (1 done) · Upcoming 2 · Overdue 1 · Unscheduled 1 · Done 1.

**Today (Wed 4) list, fully sorted** (overdue first, then by time, then priority; settled = done or skipped sink to the bottom): Call the dentist (overdue) · Drink water (09:00 reminder, 5/8) · Submit expense report (17:00, High) · Study English (19:00) · Read before bed (21:00, 0/20) · Evening routine (21:30, 2/4) · Coffee limit (1 of 2 cups) · [settled:] Morning run (Skipped) · Take blood-pressure medicine (Done) · Book flights (Done).

**Drink water — calendar (October–November 2026):** Oct 1–21 ✓ except Oct 22 ✗ (Not done; streak reset), Oct 23–Nov 3 ✓, Nov 4 pending, Nov 5+ upcoming. Success rate: 7 days 100 %, 30 days 97 %, All time 94 %. By-day chart: values mostly 8, dips to 5 on Oct 22 (so 5 of 8) and 10 on a few days. By-week chart: 8 weeks of totals vs 56.
**Run** (K km): 2.5 km, 3.0 km, 3.2 km… decimals present. **Read:** minutes 20, 25, 15, 30, 0 …

**Statistics (Oct 29 – Nov 4, 7 days):** done/total per day = 5/6, 6/6, 4/7, 6/7, 7/7, 6/6, 3/8 → **37 of 47 done**. **Last 30 days:** e.g. **152 of 190 done**. **Longest streaks:** 1 Take blood-pressure medicine 31 days · 2 Drink water 21 days · 3 Study English 6 weeks (shows the mixed-unit issue, §8.1 item 17).
**Pomodoro:** defaults 25 / 5 / 15 min, 4 sessions; running example `Focus · Session 2`, `18:42`; linked habit "Read before bed"; credited snackbar "Added 12 min".
**Reminders:** Drink water has 4 reminders; one habit at the maximum of 5 (07:00, 09:00, 12:00, 15:00, 18:00); one with a denied-permission warning.
**Backup file name:** `dailyloop-20261104-1830.dailyloop`. **CSV:** `dailyloop-20261104-1830.csv`. **Version:** 1.0.0 (1). **Email placeholder:** `hello@example.com`.
**Widgets:** the 6 non-done rows above as list; header `Today · 6 left`; also `All done`, `Nothing planned for today`, PIN-on `6 left`.
**Stress cases:** 40 habits; 200 % text; habit name 60 chars; unit 20 chars; checklist with 20 items; category name 40 chars; 20 categories; value `2000 ml` target; K-times habit streak `52 weeks`; no-category item; archived habit with years of history.

---

## 8. Known UX weak points → design opportunities, and competitor insights

### 8.1 Weak points of the current prototype (solve within the spec; changes in behaviour = proposals)
1. **Today app bar is crowded:** up to 4 icons (back to today, pick a day, Pomodoro, settings); Pomodoro is reachable only from here or from a Time habit. Propose a calmer header (date control + overflow) keeping every destination.
2. **Day strip is plain and re-centres on every tap**; no hint of how each day went. Show per-day completion cues (data exists), keep 7 days around the selected day (AC-08).
3. **Rows are text-heavy:** progress is only text (`5 of 8 glasses`); no visual progress; the state circle, ⋮ and +1 compete. Design a row where state, progress and the primary action read at a glance.
4. **+1 only adds 1** — useless for 2000 ml / km / pages; the value sheet is the fallback. Making the sheet faster is in scope; a custom step is a **§9 proposal**.
5. **Skip is hidden in ⋮** (AC-10) — keep it reachable without a gesture; consider promoting it.
6. **Editor is a very long form** (up to ~20 controls) with dropdowns for everything. Use progressive disclosure, chips/segments for category, priority and repeat — **same fields, same order, same rules**; Save pinned.
7. **Category chosen by dropdown** though categories have colour and icon — show them.
8. **Habit detail:** three equal streak cards; the score is unexplained; calendar legend is small; the day-edit sheet does not say *which* date is being edited (a §9 proposal: show the date in the sheet).
9. **Categories is hidden** behind an icon on the Habits tab; consider an extra entry in Settings (no new feature).
10. **Today does not filter by category** though AC-32 requires it — design the chips (spec item, not new).
11. **Tasks tab:** tapping the row toggles done while editing needs ⋮ → Edit — easy to mis-tap; define tap vs edit clearly (propose).
12. **Pomodoro screen is bare** (big text + buttons + 4 steppers): no progress ring, no session dots, steppers have no direct entry.
13. **Statistics** is two bar charts + top 3: no summary insight, no empty/low-data guidance, the "ghost" total bar meaning is not explained.
14. **Welcome** uses one generic Material icon per page.
15. **Alarm screen** is functional but unbranded; PIN-on variant needed.
16. **VI decimals** show a dot (`2.5`) instead of a comma.
17. **Longest streaks mixes units** (31 days vs 6 weeks vs 4 months) and ranks them by the raw number — flag for the developer; design the row to show the unit prominently.
18. **Warnings/errors are red text only** in places — pair with icons and keep calm tone.
19. **Overdue** is only error-coloured text — add icon and a calm, non-alarming style.
20. **Priority** (Low/Normal/High) affects the sort but is invisible anywhere — a small High marker (icon + word) is allowed.
21. **No dark-mode or 200 %-text design exists** for the prototype; everything must be designed fresh.

### 8.2 Competitor insights (quick desk research, 2026-11-04 — secondary sources, not user testing; no look-and-feel to copy)
Sources skimmed: reviews/comparisons of Loop Habit Tracker, Streaks, Habitify, HabitNow, TickTick and articles on streak-guilt. Many are affiliate/vendor pages; treat as directional.
1. **Speed and simplicity win loyalty** (Loop is praised for being usable within minutes; Habitify is criticised for feature overload and analytics beginners ignore) → keep Today to "tick and go"; push advanced options behind progressive disclosure in the editor and detail.
2. **Caps and paywalls are the most repeated complaint** (habit limits of roughly 3–24 in the other apps' free tiers; a "free app pretending to be free" sentiment) → Orbiday is free with no limits: design lists for 40+ habits and say "free, no ads, no purchases" once, quietly (About/Welcome), never as a banner.
3. **Grouping is a gap** (reviewers miss categories/folders in Loop, HabitNow, TickTick) → category chips on Today and Habits are a real differentiator; make them fast and visible.
4. **Widgets and notification actions are the daily surface** (praised in Streaks; Loop lets you act from the notification) but stale-state bugs get complaints → design the widget and the notification as first-class screens with a clear done/not-done state, and keep the app and widget visually consistent.
5. **A streak reset feels like shame; forgiveness and rate-based progress are widely recommended** (secondary sources, evidence is weak) → lead with score + streak + success rate, use neutral language and icons for "Not done", never send "you'll lose your streak" nudges, and treat Skip as normal.
6. **History you can edit is valued** (Loop's calendar view for correcting past entries) → make the month calendar the obvious place to fix a day, with clear state icons (AC-26).
7. **Habits + tasks in one app can feel cluttered if tasks dominate** (TickTick users) → one Today list with a clear visual difference between a recurring habit and a one-off task (shape/icon), overdue pinned but calm, tasks never get streaks.
8. **Privacy/offline is a trust differentiator** (Loop's open/offline stance is a headline strength; Orbiday adds PIN-hidden names) → surface it as calm reassurance in Welcome page 3, About and the backup warning, not as marketing.

---

## 9. Out of scope / Future (do not design in the main frames)
Not in the v1 spec — listed so the layout can leave room, nothing more. Put any frame for these on a separate "Future" page.
- Premium / Pro tier, ads, in-app purchases, analytics, crash SDKs, habit limits.
- Accounts, sign-in, servers, cloud sync, Google Drive / iCloud backup, encrypted backups.
- Habit templates and challenges, social sharing, friends, leaderboards, badges / levels / coins.
- Smartwatch (Wear OS / Apple Watch), Google/Apple Calendar sync, location reminders, AI habit suggestions, health-app integrations.
- Fingerprint / Face ID unlock; PIN attempt limit or back-off.
- Search; reports/export other than CSV; tablet / landscape; lock-screen widgets (iOS), per-habit widgets, Dynamic Island / Live Activities for Pomodoro.
- **Ideas already noted by the product owner as "not yet":** "Discard changes?" prompt on Back from the editors; editing a past day from the calendar showing the **date** in the input sheet; a custom **+N step** for Amount habits;
  time-of-day sections in Today (Morning/Afternoon/Evening).
- Reordering categories; per-habit colours independent of category; habit notes per day.

---

## 10. Deliverables requested from Claude Design

### 10.1 Frames
For **each platform** (Android 360 × 800 dp; iPhone 15/16 393 × 852 pt) × **both themes** (light, dark):
- Every screen **SCR-01 … SCR-30** with the states listed in §5 (at minimum: default, empty, error, the special states named per screen).
- **Vietnamese variants** (light only is fine) of: SCR-02, 05, 08, 10, 11, 14, 17, 21, 24, 27, 29.
- **200 % text variants** (one platform, light): SCR-02, 10, 11, 14, 21, 23/24, 27 and the dialogs/sheets (05, 06, 20).
- **Stress variants:** SCR-02 with 40 items and with 60-char names; SCR-08 with 40 habits; SCR-11 with a 20-item checklist; SCR-10 with a 52-week streak; SCR-17 30-day chart.
- **Platform-specific frames** only where §2.2 differs: iPhone back-swipe affordance, share-sheet/file-picker **placeholders**, reminder block without Android-only warnings, iPhone alarm-as-notification, widget sizes.
- **Prototype** links for flows F1–F16 (§6).
- A **brand sheet:** logo + wordmark (light/dark), app-icon concept in the two platforms' shapes (rounded square for iOS, adaptive/themed for Android), splash screen.

### 10.2 File naming (1:1 with routes)
`design/hifi/<platform>/<theme>/<NN>_<slug>__<state>.png` (+ the HTML export of the same frame), where `<platform>` = `android|ios`, `<theme>` = `light|dark`, `<NN>` = SCR number, `<state>` =
`default|empty|error|overdue|skipped|future|past|filtered|loading|locked|long-text|many-items|text-200|vi|…`. Overlays use `<route-slug>~<overlay>`.

| SCR | Route / owner | Slug |
|---|---|---|
| 01 | first-launch overlay | `welcome` (`__page-1..3`) |
| 02 | `/` | `today` |
| 03 | date picker | `today~date-picker` |
| 04 | row menu | `today~row-menu` |
| 05 | value sheet | `today~value` |
| 06 | checklist sheet | `today~checklist` |
| 07 | create sheet | `today~create` |
| 08 | `/habits` | `habits` |
| 09 | `/habits/archived` | `habits-archived` |
| 10 | `/habits/:id` | `habit-detail` |
| 11 | `/habits/new`, `/habits/:id/edit` | `habit-new`, `habit-edit` |
| 12 | `/tasks/new`, `/tasks/:id` | `task-new`, `task-edit` |
| 13 | editor pickers | `habit-new~time-picker`, `habit-new~schedule` |
| 14 | reminder block + dialogs | `habit-new~reminders`, `habit-new~perm-notif`, `~perm-exact`, `~perm-full` |
| 15 | delete/archive confirms | `habit-edit~delete`, `habit-edit~archive-undo` |
| 16 | `/tasks` | `tasks` (`__today|upcoming|overdue|unscheduled|done`) |
| 17 | `/stats` | `stats` |
| 18 | `/pomodoro` | `pomodoro` (`__idle|focus|break|finished`) |
| 19 | `/categories` | `categories` |
| 20 | category sheet / dialog | `categories~edit`, `categories~delete` |
| 21 | `/settings` | `settings` (`__top`, `__bottom`) |
| 22 | from `/settings` | `settings~backup`, `settings~restore`, `settings~csv` |
| 23 | from `/settings` | `settings~pin-setup`, `settings~pin-check` |
| 24 | overlay | `lock`, `lock~forgot-1`, `lock~forgot-2`, `lock~forgot-3` |
| 25 | from `/settings` | `settings~delete-all-1`, `settings~delete-all-2` |
| 26 | About | `about` |
| 27 | `/alarm` (Android only) | `alarm` |
| 28 | notifications | `notification~reminder`, `~alarm`, `~pomodoro`, `~locked` |
| 29 | widget | `widget~small|medium|large` (iOS), `widget~4x2|4x3|4x4` (Android) |
| 30 | shared | `shared~dialog`, `shared~snackbar`, `shared~empty` |

### 10.3 Design system page
- **Tokens** as JSON + CSS variables: colour (light/dark): brand, neutrals/surfaces (≥ 5 steps), text roles, semantic **done / not-done / skipped / overdue / warning / error**, focus ring, the 16 category colours (**with
  the old → new mapping** if you change any), widget/notification surfaces; type scale (≥ 10 styles; tabular-figure styles for counts, times, Pomodoro); spacing scale; radius scale; elevation/shadow; sizes
  (`tap-min` 48, row height, button heights, keypad key); motion durations/easing. **Name tokens so they map to Flutter** `ColorScheme` + a `ThemeExtension` (done/skipped/overdue/warning/category colours) + `TextTheme`.
- **Component sheet** (each with states: default, pressed, focused, disabled, error, selected; light + dark): **Today row** (all tracking types + states + settled + overdue + future), state circle, +1 button, progress indicators (ring/bar), day strip cell, bottom
  navigation, **+** button/menu, filter chips, app bar, list rows (habit, task, category, archived), streak/score cards, success-rate cell, month calendar cell (6 states + legend), bar chart + goal line, table alternative, segmented control, form fields (text, counter,
  number with suffix, dropdown/menu, chips, date/time rows), schedule chips (weekday, month-day), checklist-item editor row, reminder row + warning row, bottom sheet, dialog (normal/destructive/list), snackbar, PIN pad + dots, stepper, empty-state block, widget rows, notification layouts.
- **Icon list:** a final glyph for **each of the 23 category icon keys** and every action icon: tabs (today, habits, tasks, statistics), add, calendar, timer, settings, edit, more (⋮), archive, category, drag handle, check/state, skip, +1,
  alarm/notification/snooze/dismiss, warning, streak, score, trophy/longest, delete, remove-item, add-reminder, lock, backup/restore/CSV, info.
- **Motion notes** (150–250 ms): tick (circle → check), progress change, row sink when done, day-strip change, sheet open/close, snackbar in/out, PIN error shake — all with a **reduce-motion** variant.
- **Illustration guidance** for Welcome, empty states and the About/Lock screens (a coherent style, light/dark, no stock clip-art).
- **Accessibility annex:** contrast table, target sizes, a 200 % checklist.

### 10.4 Format
claude.ai link + exported HTML/PNG per frame (so the developer can read exact colours, spacing and fonts). Save exports into `apps/A003-dailyloop/design/hifi/` using §10.2 names; tokens JSON in `design/hifi/tokens.json`.
