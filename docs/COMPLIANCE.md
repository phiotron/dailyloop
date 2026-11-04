# COMPLIANCE — DailyLoop (A003-dailyloop)

Hồ sơ tuân thủ theo `D:/DemoChung/shared/standards/tieu-chuan-ban-app-toan-cau.md` (tài liệu gốc, cập nhật 28/10/2026; ghi "L<n>" là Lớp n trong tài liệu đó).
Không phải tư vấn pháp lý: trước khi mở bán ở nước nào cần luật sư địa phương xác nhận (tài liệu gốc, phần Tóm tắt).

## 1. Phạm vi (điền ở /spec, quyết định mục nào áp dụng)
- Thị trường định bán (ghi nhóm theo "Ma trận theo thị trường": A/B/C; nhóm D không được bán): Việt Nam và toàn cầu: nhóm A và nhóm B (gồm Việt Nam). Nhóm C (Trung Quốc đại lục, Nga) chưa mở. Nhóm D chặn trong Play Console.
- Có tài khoản người dùng: không
- Dữ liệu cá nhân thu thập (loại, mục đích, nơi lưu, bên nhận, thời gian giữ): nhà phát triển không thu thập. Người dùng tự ghi thói quen, việc cần làm, kết quả theo ngày, giờ nhắc, danh mục. Mọi thứ chỉ lưu trong SQLite trên máy, không có bên nhận, giữ tới khi người dùng xóa hoặc gỡ app. File sao lưu do người dùng tự xuất và giữ.
- Dữ liệu rủi ro cao (nhạy cảm, vị trí chính xác, trẻ em, sinh trắc học, hồ sơ hóa bằng AI): không gửi đi đâu. Tên thói quen do người dùng tự đặt có thể lộ thông tin sức khỏe (ví dụ uống thuốc), nhưng chỉ nằm trên máy. Cần luật sư xác nhận việc này có kéo theo D-07 không.
- Người dưới 18 tuổi có thể dùng: có (không nhắm tới trẻ em)
- Bán hàng số, thuê bao hoặc thanh toán trong app: không (miễn phí hoàn toàn)
- SDK bên thứ ba (analytics, quảng cáo, đăng nhập xã hội, AI): không có
- Gửi dữ liệu cho AI bên thứ ba, hoặc app có chatbot/nội dung do AI tạo: không
- Ngành có quy định riêng (y tế, tài chính, trẻ em, ô tô...): không (app thói quen và việc cần làm, không chẩn đoán hay tư vấn y tế)
- Doanh nghiệp siêu nhỏ (dưới 10 người và doanh thu không quá 2 triệu euro, miễn EAA khi cung cấp dịch vụ, L4): chưa rõ, chờ người dùng xác nhận phát hành dưới tên cá nhân hay công ty. Dù thế nào vẫn giữ mục tiêu WCAG 2.2 AA.

## 2. Danh mục kiểm (Trạng thái: đạt / không áp dụng / chưa. "Bằng chứng": file:dòng, ảnh chụp, đường dẫn, lệnh đã chạy; ghi ngày kiểm)
| ID | Áp dụng khi | Yêu cầu | Nguồn | Trạng thái | Bằng chứng, ngày |
|----|-------------|---------|-------|------------|------------------|
| M-01 | Mọi app | Danh sách thị trường đã chốt; đã loại nước và vùng bị cấm vận toàn diện (rà danh sách OFAC, EU, Anh, LHQ hiện hành) và chặn theo địa lý nếu cần | Tóm tắt, L6, Ma trận | chưa | |
| D-01 | Có dữ liệu cá nhân | Kiểm kê dữ liệu (RoPA) và bản đồ luồng dữ liệu: loại, mục đích, căn cứ pháp lý, nơi lưu, bên nhận, thời gian giữ | L3 nền chung 1 | chưa | |
| D-02 | Có dữ liệu cá nhân | Chính sách quyền riêng tư; đường dẫn đặt trong Play Console và trong app | L3, L5 Google "Dữ liệu người dùng" | chưa | |
| D-03 | Có dữ liệu cá nhân | Đồng ý theo từng mục đích, không gộp, rút lại dễ như lúc cho; im lặng không coi là đồng ý (Luật VN 91/2025 Điều 9) | L3 nền chung 2 | không áp dụng | Nhà phát triển không nhận dữ liệu; mọi xử lý chỉ trên máy người dùng (D-002), 2026-11-03 |
| D-04 | Có SDK bên thứ ba | SDK analytics/quảng cáo/AI không khởi động trước khi có đồng ý ở nơi luật đòi (EU, Anh); dùng nền tảng quản lý đồng ý hỗ trợ iOS và Android | L3 "Điểm riêng của app mobile" | không áp dụng | Không có SDK bên thứ ba (D-002), 2026-11-03 |
| D-05 | Có tài khoản | Xóa tài khoản ngay trong app (Apple 5.1.1(v)) và qua một trang web ngoài (Google Play) | L3 nền chung 3, L5 | không áp dụng | Không có tài khoản; thay bằng "Xóa toàn bộ dữ liệu" AC-52, 2026-11-03 |
| D-06 | Có dữ liệu cá nhân | Quy trình quyền người dùng: truy cập, sửa, xóa, mang dữ liệu đi, rút đồng ý, phản đối quyết định tự động | L3 nền chung 3 | chưa | |
| D-07 | Dữ liệu rủi ro cao | Đánh giá tác động (DPIA/PIA); bán ở Việt Nam: nộp hồ sơ trong 60 ngày kể từ khi bắt đầu xử lý (Điều 21) | L3 nền chung 4 | chưa | Tên thói quen có thể lộ thông tin sức khỏe, chỉ nằm trên máy; cần luật sư xác nhận có phải lập DPIA hoặc nộp hồ sơ ở VN không |
| D-08 | Có dữ liệu cá nhân | Kịch bản xử lý vi phạm theo hạn ngắn nhất trong các thị trường đã chọn (ví dụ 72 giờ ở EU và Việt Nam; xem ma trận L3) | L3 nền chung 5 | chưa | |
| D-09 | Có dữ liệu cá nhân, bán ở VN | Chỉ định bộ phận hoặc nhân sự bảo vệ dữ liệu (Điều 33(2)); đại diện pháp lý ở nơi luật đòi (EU/Anh, Brazil, Trung Quốc, Hàn Quốc, Thổ Nhĩ Kỳ) | L3 nền chung 6 | chưa | Cần luật sư xác nhận khi nhà phát triển không nhận dữ liệu |
| D-10 | Dùng nhà cung cấp xử lý dữ liệu | Hợp đồng xử lý dữ liệu với cloud, analytics, push, thanh toán, AI; cơ chế chuyển dữ liệu ra nước ngoài hợp pháp (VN: hồ sơ trong 60 ngày từ lần chuyển đầu) | L3 nền chung 7, "Kiến trúc chuyển dữ liệu" | không áp dụng | Không dùng nhà cung cấp xử lý dữ liệu (D-002), 2026-11-03 |
| D-11 | Mọi app | Quyền hệ thống (vị trí, danh bạ, camera, micro, thông báo) chỉ xin khi cần cho tính năng, không ép bật để dùng app | L3 "Điểm riêng", L5 Apple 5.1.1 | chưa | Quyền thông báo, báo thức chính xác, toàn màn hình chỉ xin khi bật nhắc giờ (SPEC mục 5, AC-18, AC-20); kiểm ở G4 |
| D-12 | Người dưới 18 có thể dùng | Dùng tín hiệu tuổi của hệ điều hành (Declared Age Range của Apple, Play Age Signals của Google) và đối chiếu luật tuổi theo thị trường ở L3 | L3 "Điểm riêng", L5 | chưa | Chờ người dùng quyết có tích hợp Play Age Signals (SPEC mục 7) |
| D-13 | Gửi dữ liệu cho AI bên thứ ba | Nêu rõ nơi dữ liệu được chia sẻ, kể cả AI bên thứ ba, và xin phép rõ ràng trước khi chia sẻ (Apple 5.1.2(i)) | L3, L5 | không áp dụng | Không dùng AI, 2026-11-03 |
| S-01 | Mọi app | Tự kiểm theo 8 nhóm OWASP MASVS v2.1.0: STORAGE, CRYPTO, AUTH, NETWORK, PLATFORM, CODE, RESILIENCE, PRIVACY (ghi kết quả từng nhóm) | L2 "Tiêu chí kỹ thuật" | chưa | |
| S-02 | Có API/backend | Kiểm API theo OWASP ASVS 5.0.0; truyền tải mã hóa TLS 1.3 | L2 | không áp dụng | Không có API hay backend, 2026-11-03 |
| S-03 | Có đăng nhập | Đăng nhập theo OAuth 2.0/OIDC (RFC 9700) hoặc passkey (WebAuthn/FIDO2); có đăng nhập bên thứ ba trên iOS thì có thêm một lựa chọn tương đương theo Apple 4.8 | L2, L5 | không áp dụng | Không có đăng nhập, 2026-11-03 |
| S-04 | Mọi app | SBOM sinh tự động (SPDX hoặc CycloneDX) và rà giấy phép nguồn mở theo danh sách SPDX | L2 "Chuỗi cung ứng", L6 | chưa | |
| S-05 | Mọi app | Kênh tiếp nhận lỗ hổng công khai (ví dụ security.txt theo RFC 9116 hoặc email) và thủ tục xử lý | L2 | chưa | |
| S-06 | Bán ở EU | CRA: kế hoạch báo lỗ hổng đang bị khai thác và sự cố nghiêm trọng (cảnh báo sớm 24 giờ, thông báo 72 giờ, từ 11/09/2026); công bố thời hạn hỗ trợ cập nhật bảo mật (Recital 60: không dưới năm năm trừ khi tuổi thọ dự kiến ngắn hơn) | L2 CRA | chưa | Cần luật sư xác nhận app miễn phí có thuộc phạm vi CRA không (SPEC mục 7) |
| S-07 | Lưu, xử lý hoặc truyền dữ liệu thẻ | PCI DSS v4.0.1; gợi ý của tài liệu: dùng cổng thanh toán bên thứ ba (hosted page/redirect) để thu hẹp phạm vi | L2 | không áp dụng | Không xử lý dữ liệu thẻ, 2026-11-03 |
| A-01 | Mọi app | Mục tiêu thiết kế WCAG 2.2 mức AA; bán ở EU: chứng minh theo EN 301 549 v3.2.1; kiểm bằng VoiceOver và TalkBack; lưu tuyên bố accessibility cho từng bản phát hành | L4 | chưa | |
| C-01 | Bán hàng số/thuê bao | Hiển thị giá và điều kiện trước khi thanh toán; cho hủy ngay trong app; nhắc trước khi gia hạn | L4 "Bảo vệ người tiêu dùng" | không áp dụng | Miễn phí, không bán gì, 2026-11-03 |
| C-02 | Bán trực tuyến cho người tiêu dùng EU | Chức năng rút khỏi hợp đồng (Điều 11a Chỉ thị 2023/2673, áp dụng từ 19/06/2026) | L4 | không áp dụng | Không bán trực tuyến, 2026-11-03 |
| C-03 | Bán ở EU | Trách nhiệm sản phẩm (Chỉ thị 2024/2853, sản phẩm đưa ra thị trường sau 09/12/2026): công bố thời hạn cập nhật bảo mật, lưu hồ sơ kiểm thử và vòng đời | L4 | chưa | |
| P-01 | Phát hành iOS | Build bằng Xcode 26 trở lên với SDK iOS 26 trở lên (từ 28/04/2026) | L5 Apple | không áp dụng | v1 chỉ Android (D-001), 2026-11-03 |
| P-02 | Phát hành iOS | App privacy details khi nộp; tệp `PrivacyInfo.xcprivacy`; SDK phổ biến kèm privacy manifest và chữ ký | L5 Apple | không áp dụng | v1 chỉ Android (D-001), 2026-11-03 |
| P-03 | Phát hành iOS | `ITSAppUsesNonExemptEncryption` trong Info.plist (NO nếu không mã hóa hoặc chỉ mã hóa miễn trừ) | L5 Apple, L6 | không áp dụng | v1 chỉ Android (D-001), 2026-11-03 |
| P-04 | Phát hành iOS, có theo dõi | App Tracking Transparency (từ iOS 14.5; màn hình riêng cho EU từ iOS 27.2) | L5 Apple | không áp dụng | v1 chỉ Android, không theo dõi, 2026-11-03 |
| P-05 | Phát hành iOS | Bảng câu hỏi xếp hạng độ tuổi mới (Việt Nam: 00+, 12+, 16+, 18+ từ 18/06/2026) | L5 Apple | không áp dụng | v1 chỉ Android (D-001), 2026-11-03 |
| P-06 | Phát hành Android | targetSdk = API 36 cho app mới và bản cập nhật (từ 31/08/2026, gia hạn tới 01/11/2026) | L5 Google | chưa | |
| P-07 | Phát hành Android | Hỗ trợ trang bộ nhớ 16 KB (bắt buộc với bản cập nhật từ 01/02/2027) | L5 Google | chưa | |
| P-08 | Phát hành Android | Xác minh nhà phát triển (từ 30/09/2026 tại Brazil, Indonesia, Singapore, Thái Lan; toàn cầu năm 2027) | L5 Google | chưa | |
| P-09 | Tài khoản Play cá nhân mới | Closed test với ít nhất 12 người thử, liên tục tối thiểu 14 ngày | L5 Google | chưa | |
| P-10 | Phát hành Android | Khai báo Data safety khớp với dữ liệu SDK thực sự thu thập; xếp hạng nội dung | L5 Google | chưa | |
| P-11 | Bán hàng số trong app | Apple: quy tắc thanh toán trong app của App Store (mục 3.1.1, xem L5); Google: Play Billing trừ khi thuộc §3, 8, 9 | L5 | không áp dụng | Không bán hàng số, 2026-11-03 |
| P-12 | App cho trẻ em trên Play | Chương trình Families: khai báo đối tượng, chỉ SDK quảng cáo được chứng nhận cho Families, tuân thủ COPPA và GDPR | L5 Google | không áp dụng | Không nhắm tới trẻ em, 2026-11-03 |
| T-01 | Bán có thu phí | Thuế giá trị gia tăng theo nơi bán (Apple làm đại lý theo Schedule 2; xem L6) | L6 | không áp dụng | Miễn phí, 2026-11-03 |
| T-02 | Mọi app phát hành | Bản địa hóa và định dạng theo thị trường | L6 | chưa | |
| AI-01 | Có chatbot hoặc nội dung do AI tạo, bán ở EU | Nghĩa vụ minh bạch Điều 50 AI Act (từ 02/08/2026) | L7, Mốc | không áp dụng | Không có AI, 2026-11-03 |

## 3. Trước mỗi lần phát hành
- Kiểm lại trang Apple "Upcoming requirements" và bảng hạn chót của Google, vì đổi theo quý (L5 "Cách làm chung"); ghi ngày kiểm vào đây.
- Tài liệu tiêu chuẩn gốc cũ hơn 3 tháng so với ngày phát hành: kiểm lại các mốc ở bảng đầu tài liệu.
- Ngày kiểm lần cuối:
