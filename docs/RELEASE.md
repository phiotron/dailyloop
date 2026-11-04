# RELEASE — DailyLoop (A003-dailyloop)

## Định danh
- Bundle ID / package name:
- Phiên bản hiện tại (versionName / versionCode / buildNumber):
- Store: Google Play [ ] · App Store [ ] · phân phối nội bộ [ ]

## Ký ứng dụng
- Nơi cất keystore/chứng chỉ (NGOÀI repo, có sao lưu): {{...}}
- Người giữ mật khẩu: {{...}}
- KHÔNG ghi mật khẩu vào file này.

## iOS (TestFlight / App Store) — CHƯA KIỂM CHỨNG (chưa có tài khoản Apple, chưa có iPhone)
Build + ký + tải lên chạy trên GitHub Actions macOS (`.github/workflows/release-ios.yml`, chạy tay `workflow_dispatch`); Windows không build iOS. Build thử không ký ở `ios.yml`. Chi tiết và lệnh: `notes/2026-11-04-ios-ci.md`.
- **Apple Developer cá nhân** → App ID `com.phiotron.dailyloop` với khả năng **Time Sensitive Notifications** bật sẵn (D-010). Khi làm widget iOS: thêm **App Group** `group.com.phiotron.dailyloop` và App ID + profile cho extension.
- Tạo app "DailyLoop" trong App Store Connect (bundle id trên) trước lần tải lên đầu.
- **GitHub Secrets** (repo `phiotron/dailyloop` › Settings › Secrets and variables › Actions) — KHÔNG ghi giá trị vào repo hay file này:
  | Tên secret | Nội dung |
  |---|---|
  | `IOS_TEAM_ID` | Team ID 10 ký tự (developer.apple.com › Membership) |
  | `IOS_DIST_CERT_P12_BASE64` | chứng chỉ Apple Distribution xuất `.p12`, mã hóa base64 |
  | `IOS_DIST_CERT_PASSWORD` | mật khẩu đặt khi xuất `.p12` |
  | `IOS_PROFILE_BASE64` | provisioning profile "App Store" cho `com.phiotron.dailyloop`, base64 |
  | `ASC_KEY_ID` · `ASC_ISSUER_ID` | App Store Connect API key (vai trò App Manager) |
  | `ASC_KEY_P8_BASE64` | file `AuthKey_<ID>.p8`, base64 (chỉ tải được một lần) |
- Số build iOS = số lần chạy workflow (`github.run_number`); tên phiên bản lấy từ `pubspec.yaml` hoặc ô nhập khi chạy.
- Trước khi nộp: icon 1024×1024 không alpha (hiện còn icon mặc định Flutter), ảnh iPhone 6.9" và 6.5", nhãn App Privacy "không thu thập dữ liệu", chính sách quyền riêng tư (`docs/legal/`), mô tả giờ nhắc iOS ngắn hơn Android (không có chuông toàn màn hình).

## Hồ sơ store
- Tên, mô tả ngắn, mô tả dài, từ khóa:
- Ảnh chụp màn hình (kích thước từng loại thiết bị theo yêu cầu store hiện hành):
- Phân loại độ tuổi, danh mục:
- Đường dẫn chính sách quyền riêng tư:

## Lịch sử phát hành
| Phiên bản | Ngày | Nội dung | Ghi chú |
|-----------|------|----------|---------|

## Sau phát hành
- Theo dõi crash tại: {{công cụ / console của store}}
- Nơi nhận phản hồi người dùng:
- Mốc rà soát: sau 1 ngày, 1 tuần → ghi kết quả vào BACKLOG
