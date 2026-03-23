# 📈 Báo Cáo Tiến Độ Dự Án "An Tâm"
*Cập nhật lần cuối: 23/03/2026*

Dự án "An Tâm" (ứng dụng hỗ trợ theo dõi sức khỏe và lịch trình gia đình/người thân) đã và đang được phát triển theo đúng cấu trúc chuẩn. Dưới đây là danh sách chi tiết các chức năng đã lập trình thành công trên source code:

## 1. Cấu trúc Dự án & UI/UX Design System
- Tổ chức thư mục chuẩn theo Clean Architecture kết hợp Feature-first (`lib/src/features/...`).
- **Theme & UI System:** Định nghĩa chuẩn bảng màu (`app_colors.dart`) và fonts/typography (`app_text_styles.dart`).
- **Common Widgets:** Đã tạo các thư viện UI dùng chung như nút bấm chuẩn (`PrimaryButton`), ảnh đại diện linh vật (`MascotAvatar`).

## 2. Hệ thống Xác thực & Tài khoản (Auth)
*Toàn bộ luồng đăng nhập/đăng ký đã hoàn thiện giao diện và tích hợp API Firebase.*
- **Màn hình Chọn Vai trò (`role_selection_screen.dart`):** Phân loại trải nghiệm người dùng ngay từ đầu.
- **Luồng Đăng ký / Đăng nhập (`register_screen.dart`, `login_screen.dart`):** Validate form, Firebase Email/Password auth.
- **Tính năng Đăng nhập Google (`auth_service.dart`):** Tích hợp package `google_sign_in` và `Firebase auth`.
- **Màn hình Welcome Người thân (`child_auth_screen.dart`).**
- **Quên Mật khẩu (`forgot_password_screen.dart`):** Gửi email reset password từ Firebase.
- **Pháp lý:** Đã dựng các màn hình Chính sách quyền riêng tư (`privacy_policy_screen.dart`) và Điều khoản sử dụng (`terms_screen.dart`).
- Quản lý phiên đăng nhập/đăng xuất (thông qua `AuthProvider` & `SettingsScreen`).

## 3. Giao diện Chính (Home Dashboard)
- Màn hình **Child Home Screen (`child_home_screen.dart`)**: Tích hợp thanh toán trạng thái cảm xúc, tổng quan nhanh (viên thuốc, nhịp tim) và điều hướng Bottom Navigation Bar.

## 4. Quản lý Lịch trình & Nhắc nhở (Schedule System)
*Module có tính phức tạp nhất của phiên bản hiện tại đã được tách nhỏ thành nhiều màn hình chi tiết, tối ưu hoá UI thao tác.*
- **Dashboard Lịch trình chung (`schedule_screen.dart`):** Hiển thị tổng quan các Lịch trình, Lịch khám, Lịch sử...
- **Chi tiết Lịch trình Hàng ngày (`daily_schedule_screen.dart`):** Form hiển thị tasks chi tiết của ngày hôm đó (uống thuốc, đo huyết áp, sinh hoạt).
- **Thêm Nhắc nhở/Task mới (`add_schedule_screen.dart`):** Chứa các picker chọn ngày/giờ mượt mà để nhập dữ liệu.
- **Lịch Khám & Di chuyển (`appointment_schedule_screen.dart`):** Quản lý chuyên biệt các cuộc hẹn với bác sĩ.
- **Thêm Lịch Khám mới (`add_appointment_screen.dart`).**
- **Lịch sử Tuân thủ (`history_schedule_screen.dart`):** Nơi xem lại hiệu suất và các task đã hoàn thành trong quá khứ.

## 5. Tương tác & Chat
- **Màn hình Nhắn tin (`chat_screen.dart`):** Bước đầu cấu trúc giao diện để liên lạc giữa các tài khoản kết nối.

## 6. Dịch vụ Backend (Firebase)
- `auth_service.dart`: Quản lý session, các API login, signout, reset email.
- `firestore_service.dart`: Logic Database khởi tạo Profile người dùng lên Cloud Firestore.
- Có sử dụng `Provider` cho State Management trên toàn App (`AuthProvider`).

---

### 🚀 Gợi ý các bước phát triển tiếp theo:
1. **Lịch trình -> Firestore:** Đẩy và tải dữ liệu Real-time (Lịch trình, Lịch khám) lên/từ Database thay vì dùng dữ liệu UI tĩnh.
2. **Chat logic:** Kết nối Firebase Cloud Firestore cho màn hình Chat để gửi/nhận tin nhắn thật.
3. **Màn hình Parent/Doctor:** Vẽ các luồng UI riêng biệt cho màn hình Home của Người cao tuổi hoặc Bác sĩ tuỳ theo lựa chọn ở bước đăng nhập.
4. **Push Notifications:** Thêm Firebase Cloud Messaging (FCM) để chuông điện thoại reo lên khi tới giờ uống thuốc.
