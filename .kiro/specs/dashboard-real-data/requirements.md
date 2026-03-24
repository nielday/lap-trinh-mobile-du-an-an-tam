# Requirements Document

## Introduction

Dashboard Real Data Integration là tính năng thay thế toàn bộ fake/hardcoded data trong child_home_screen.dart bằng real data từ Firebase thông qua các providers đã có sẵn (AuthProvider, MedicationProvider, ReminderProvider, AlertProvider). Feature này đảm bảo dashboard hiển thị dữ liệu thực tế của người dùng, cải thiện trải nghiệm và độ chính xác của ứng dụng.

## Glossary

- **Dashboard**: Màn hình chính (child_home_screen.dart) hiển thị tổng quan thông tin người dùng
- **Provider**: Lớp quản lý state theo Provider pattern (AuthProvider, MedicationProvider, ReminderProvider, AlertProvider)
- **Firebase**: Backend database (Firestore) lưu trữ dữ liệu thực tế
- **Check-in**: Bản ghi xác nhận uống thuốc (CheckInModel)
- **Compliance_Rate**: Tỷ lệ tuân thủ uống thuốc đúng giờ (phần trăm)
- **Widget_Type**: Loại widget (StatelessWidget hoặc StatefulWidget)
- **Bottom_Navbar**: Thanh điều hướng ở cuối màn hình

## Requirements

### Requirement 1: Display User Information

**User Story:** Là một người dùng, tôi muốn thấy tên thật của mình trên dashboard, để biết tôi đang đăng nhập đúng tài khoản.

#### Acceptance Criteria

1. WHEN the Dashboard loads, THE Dashboard SHALL retrieve user data from AuthProvider
2. WHEN AuthProvider.user.displayName is available, THE Dashboard SHALL display the displayName in the header greeting
3. WHEN AuthProvider.user.displayName is null or empty, THE Dashboard SHALL display a default greeting text
4. THE Dashboard SHALL display Vietnamese text correctly without garbled characters

### Requirement 2: Display Medication Data

**User Story:** Là một người dùng, tôi muốn thấy danh sách thuốc và lịch uống thuốc thực tế từ Firebase, để theo dõi việc uống thuốc của mình.

#### Acceptance Criteria

1. WHEN the Dashboard loads, THE Dashboard SHALL retrieve medications from MedicationProvider.medications
2. WHEN the Dashboard loads, THE Dashboard SHALL retrieve today check-ins from MedicationProvider.todayCheckIns
3. WHEN medications list is empty, THE Dashboard SHALL display an empty state message
4. WHEN medications list is not empty, THE Dashboard SHALL display medication cards with real data (name, time, status)
5. THE Dashboard SHALL use Provider.of or Consumer to access MedicationProvider data

### Requirement 3: Display Reminders

**User Story:** Là một người dùng, tôi muốn thấy lời nhắn thực tế từ người thân, để không bỏ lỡ các thông báo quan trọng.

#### Acceptance Criteria

1. WHEN the Dashboard loads, THE Dashboard SHALL retrieve reminders from ReminderProvider.reminders
2. WHEN reminders list is empty, THE Dashboard SHALL display an empty state message
3. WHEN reminders list is not empty, THE Dashboard SHALL display reminder cards with real data (content, timestamp)
4. THE Dashboard SHALL use Provider.of or Consumer to access ReminderProvider data

### Requirement 4: Display Alerts

**User Story:** Là một người dùng, tôi muốn thấy cảnh báo thực tế về việc uống thuốc, để kịp thời xử lý các vấn đề.

#### Acceptance Criteria

1. WHEN the Dashboard loads, THE Dashboard SHALL retrieve alerts from AlertProvider.unreadAlerts
2. WHEN alerts list is empty, THE Dashboard SHALL display an empty state message
3. WHEN alerts list is not empty, THE Dashboard SHALL display alert cards with real data (title, message, timestamp)
4. THE Dashboard SHALL use Provider.of or Consumer to access AlertProvider data

### Requirement 5: Display Compliance Rate

**User Story:** Là một người dùng, tôi muốn thấy tỷ lệ tuân thủ uống thuốc thực tế, để đánh giá mức độ tuân thủ của mình.

#### Acceptance Criteria

1. WHEN the Dashboard loads, THE Dashboard SHALL retrieve compliance rate from MedicationProvider.complianceRate
2. THE Dashboard SHALL display the compliance rate as a percentage with format "XX%"
3. WHEN compliance rate is 0, THE Dashboard SHALL display "0%"
4. THE Dashboard SHALL display the current month and year in format "Tháng MM/YYYY"

### Requirement 6: Display Weekly Compliance Status

**User Story:** Là một người dùng, tôi muốn thấy trạng thái tuân thủ theo từng ngày trong tuần, để biết những ngày nào tôi đã uống thuốc đúng giờ.

#### Acceptance Criteria

1. WHEN the Dashboard loads, THE Dashboard SHALL retrieve weekly compliance data from MedicationProvider.weeklyCompliance
2. THE Dashboard SHALL display 7 day status icons (T2, T3, T4, T5, T6, T7, CN)
3. WHEN a day status is "completed", THE Dashboard SHALL display a green check icon
4. WHEN a day status is "missed", THE Dashboard SHALL display a red close icon
5. WHEN a day status is "pending", THE Dashboard SHALL display an orange clock icon
6. WHEN a day status is "upcoming", THE Dashboard SHALL display a navy circle icon

### Requirement 7: Preserve Widget Type

**User Story:** Là một developer, tôi muốn giữ nguyên widget type hiện tại, để tránh breaking changes và compile errors.

#### Acceptance Criteria

1. THE Dashboard SHALL maintain the current Widget_Type (StatelessWidget or StatefulWidget)
2. IF the current widget is StatelessWidget, THE Dashboard SHALL remain StatelessWidget
3. IF the current widget is StatefulWidget, THE Dashboard SHALL remain StatefulWidget

### Requirement 8: Preserve Bottom Navigation Bar

**User Story:** Là một người dùng, tôi muốn bottom navbar luôn hiển thị khi chuyển tab, để dễ dàng điều hướng giữa các màn hình.

#### Acceptance Criteria

1. THE Bottom_Navbar SHALL remain visible at all times
2. WHEN user navigates to Schedule screen, THE Bottom_Navbar SHALL use Navigator.push
3. WHEN user navigates to Settings screen, THE Bottom_Navbar SHALL use Navigator.push
4. THE Bottom_Navbar SHALL NOT use IndexedStack pattern

### Requirement 9: Code Compilation

**User Story:** Là một developer, tôi muốn code compile thành công không lỗi, để có thể chạy ứng dụng ngay lập tức.

#### Acceptance Criteria

1. WHEN the implementation is complete, THE Dashboard SHALL compile without syntax errors
2. WHEN the implementation is complete, THE Dashboard SHALL compile without type errors
3. WHEN the implementation is complete, THE Dashboard SHALL compile without import errors

### Requirement 10: No New Files

**User Story:** Là một developer, tôi muốn chỉ sửa file child_home_screen.dart, để giữ codebase đơn giản và tránh tạo file không cần thiết.

#### Acceptance Criteria

1. THE implementation SHALL modify only the file lib/src/features/home/presentation/child_home_screen.dart
2. THE implementation SHALL NOT create any new files
3. THE implementation SHALL NOT modify any other existing files
