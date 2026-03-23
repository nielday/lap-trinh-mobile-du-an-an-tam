# Kế hoạch Triển khai: Firestore Data Layer

## Tổng quan

Xây dựng tầng dữ liệu hoàn chỉnh theo kiến trúc **Models → Repositories → Providers → UI** cho ứng dụng Flutter "An Tâm". Thay thế toàn bộ fake/mock data trong ChildHomeScreen, ScheduleScreen và ChatScreen bằng dữ liệu thật từ Firestore thông qua Provider pattern.

## Nhiệm vụ

- [x] 1. Tạo cấu trúc thư mục và custom exceptions
  - Tạo thư mục `lib/src/models/`, `lib/src/repositories/`
  - Tạo file `lib/src/core/exceptions.dart` với `PermissionDeniedException`, `UserNotFoundException`, `ValidationException`
  - _Yêu cầu: 2.8, 3.5, 4.5, 5.4, 6.6_

- [x] 2. Implement Data Models
  - [x] 2.1 Implement UserModel và MedicationModel
    - Tạo `lib/src/models/user_model.dart` với factory `fromFirestore` và method `toMap`
    - Tạo `lib/src/models/medication_model.dart` với factory `fromFirestore` và method `toMap`
    - Xử lý null-safety: trường thiếu trả về giá trị mặc định, không ném exception
    - _Yêu cầu: 1.1, 1.2, 1.8, 1.9, 1.11_

  - [ ]* 2.2 Viết property test cho UserModel và MedicationModel
    - **Property 1: Model serialization round-trip** — `fromFirestore` rồi `toMap` phải tương đương dữ liệu gốc
    - **Property 2: Model graceful default khi thiếu fields** — document rỗng không ném exception
    - **Validates: Yêu cầu 1.8, 1.9, 1.10, 1.11**

  - [x] 2.3 Implement CheckInModel, AlertModel, ReminderModel
    - Tạo `lib/src/models/check_in_model.dart`
    - Tạo `lib/src/models/alert_model.dart`
    - Tạo `lib/src/models/reminder_model.dart`
    - _Yêu cầu: 1.3, 1.4, 1.5, 1.8, 1.9, 1.11_

  - [ ]* 2.4 Viết property test cho CheckInModel, AlertModel, ReminderModel
    - **Property 1: Model serialization round-trip** cho 3 model trên
    - **Property 2: Model graceful default khi thiếu fields** cho 3 model trên
    - **Validates: Yêu cầu 1.8, 1.9, 1.10, 1.11**

  - [x] 2.5 Implement MessageModel và FamilyLinkModel
    - Tạo `lib/src/models/message_model.dart`
    - Tạo `lib/src/models/family_link_model.dart`
    - _Yêu cầu: 1.6, 1.7, 1.8, 1.9, 1.11_

  - [ ]* 2.6 Viết property test cho MessageModel và FamilyLinkModel
    - **Property 1: Model serialization round-trip** cho MessageModel và FamilyLinkModel
    - **Property 2: Model graceful default khi thiếu fields** cho MessageModel và FamilyLinkModel
    - **Validates: Yêu cầu 1.8, 1.9, 1.10, 1.11**

- [ ] 3. Checkpoint — Đảm bảo tất cả model tests pass
  - Đảm bảo tất cả tests pass, hỏi người dùng nếu có thắc mắc.

- [x] 4. Implement MedicationRepository
  - [x] 4.1 Implement MedicationRepository với CRUD và streams
    - Tạo `lib/src/repositories/medication_repository.dart` implement `IMedicationRepository`
    - Implement `createMedication`, `getMedicationsForParent` (chỉ `isActive = true`), `updateMedication`, `deactivateMedication`
    - Implement `createCheckIn`, `getTodayCheckIns` (lọc theo ngày hiện tại)
    - Bắt `FirebaseException` và wrap thành domain exception
    - _Yêu cầu: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_

  - [ ]* 4.2 Viết property test cho getMedicationsForParent
    - **Property 3: getMedicationsForParent chỉ trả về active medications**
    - **Validates: Yêu cầu 2.2, 2.4**

  - [ ]* 4.3 Viết property test cho CheckIn
    - **Property 4: CheckIn creation preserves status**
    - **Property 5: getTodayCheckIns chỉ trả về check-ins trong ngày**
    - **Validates: Yêu cầu 2.5, 2.6, 2.7**

- [x] 5. Implement AlertRepository
  - [x] 5.1 Implement AlertRepository với streams và markAsRead
    - Tạo `lib/src/repositories/alert_repository.dart` implement `IAlertRepository`
    - Implement `getUnreadAlerts` (lọc `isRead = false`, sắp xếp theo timestamp giảm dần)
    - Implement `getUnreadCount` trả về `Stream<int>`
    - Implement `markAsRead` với kiểm tra ownership, ném `PermissionDeniedException` nếu không phải của mình
    - Implement `createAlert`
    - _Yêu cầu: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ]* 5.2 Viết property test cho AlertRepository
    - **Property 6: getUnreadAlerts chỉ trả về alerts chưa đọc và unreadCount nhất quán**
    - **Property 7: markAsRead cập nhật isRead thành true**
    - **Validates: Yêu cầu 3.1, 3.2, 3.4**

- [x] 6. Implement ReminderRepository
  - [x] 6.1 Implement ReminderRepository với CRUD
    - Tạo `lib/src/repositories/reminder_repository.dart` implement `IReminderRepository`
    - Implement `getRemindersForUser` (lọc `fromUserId == userId` OR `toUserId == userId`, sắp xếp giảm dần)
    - Implement `createReminder`, `updateReminder`, `deleteReminder`
    - Kiểm tra ownership trong `deleteReminder`, ném `PermissionDeniedException` nếu không phải của mình
    - _Yêu cầu: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [ ]* 6.2 Viết property test cho ReminderRepository
    - **Property 8: getRemindersForUser trả về đúng reminders của user**
    - **Property 9: Reminder CRUD round-trip**
    - **Validates: Yêu cầu 4.1, 4.2, 4.3, 4.4**

- [x] 7. Implement MessageRepository
  - [x] 7.1 Implement MessageRepository với stream real-time
    - Tạo `lib/src/repositories/message_repository.dart` implement `IMessageRepository`
    - Implement `getMessages` (lọc cả hai chiều senderId/receiverId, sắp xếp timestamp tăng dần)
    - Implement `sendMessage` với validation: ném `ValidationException` nếu text rỗng hoặc chỉ whitespace
    - _Yêu cầu: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ]* 7.2 Viết property test cho MessageRepository
    - **Property 10: sendMessage từ chối tin nhắn whitespace-only**
    - **Property 11: getMessages trả về đúng conversation và đúng thứ tự**
    - **Validates: Yêu cầu 5.1, 5.4**

- [x] 8. Implement UserRepository
  - [x] 8.1 Implement UserRepository với family link management
    - Tạo `lib/src/repositories/user_repository.dart` implement `IUserRepository`
    - Implement `getUserById` (ném `UserNotFoundException` nếu không tồn tại)
    - Implement `getLinkedParent` dựa trên `parentId` trong profile
    - Implement `createFamilyLink` với `status = 'pending'`
    - Implement `acceptFamilyLink` cập nhật `status = 'active'` và `parentId` trong user profile
    - Implement `getFamilyLinkForChild` trả về `Stream<FamilyLinkModel?>`
    - _Yêu cầu: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

  - [ ]* 8.2 Viết property test cho UserRepository
    - **Property 12: Family link status transitions** — pending → active, không có transition khác
    - **Validates: Yêu cầu 6.3, 6.4**

- [ ] 9. Checkpoint — Đảm bảo tất cả repository tests pass
  - Đảm bảo tất cả tests pass, hỏi người dùng nếu có thắc mắc.

- [x] 10. Implement MedicationProvider
  - [x] 10.1 Implement MedicationProvider với stream subscriptions
    - Tạo `lib/src/providers/medication_provider.dart` extend `ChangeNotifier`
    - Expose `medications`, `todayCheckIns`, `isLoading`, `errorMessage`
    - Implement `updateUser(parentId)` để subscribe/unsubscribe streams khi parentId thay đổi
    - Bắt exception từ repository, cập nhật `errorMessage`, gọi `notifyListeners()`
    - Implement `dispose()` để cancel tất cả `StreamSubscription`
    - _Yêu cầu: 7.1, 7.2, 7.5, 7.6, 7.7, 7.8, 14.3_

  - [x] 10.2 Implement computed properties complianceRate và weeklyCompliance
    - Tính `complianceRate`: `(số completed / tổng) * 100` từ checkIns tháng hiện tại, trả về `0.0` nếu rỗng
    - Tính `weeklyCompliance`: 7 phần tử T2-CN với status `completed`/`missed`/`pending`/`upcoming`
    - _Yêu cầu: 7.3, 7.4_

  - [ ]* 10.3 Viết property test cho MedicationProvider
    - **Property 13: Provider phản ánh đúng dữ liệu từ Repository**
    - **Property 14: complianceRate tính đúng từ checkIns**
    - **Property 15: weeklyCompliance phủ đúng 7 ngày trong tuần**
    - **Property 16: Provider dispose hủy tất cả stream subscriptions**
    - **Property 17: Provider khởi tạo ở trạng thái rỗng khi không có parentId**
    - **Validates: Yêu cầu 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.8, 14.3, 14.5**

- [x] 11. Implement AlertProvider, ReminderProvider và ChatProvider
  - [x] 11.1 Implement AlertProvider
    - Tạo `lib/src/providers/alert_provider.dart` extend `ChangeNotifier`
    - Expose `unreadAlerts`, `unreadCount`, `isLoading`, `errorMessage`
    - Implement `updateUser(userId)`, `markAsRead(alertId)`, `dispose()`
    - _Yêu cầu: 8.1, 8.2, 8.3, 8.4, 8.5, 14.3_

  - [ ]* 11.2 Viết property test cho AlertProvider
    - **Property 13: Provider phản ánh đúng dữ liệu từ Repository** (cho AlertProvider)
    - **Property 16: Provider dispose hủy tất cả stream subscriptions** (cho AlertProvider)
    - **Property 17: Provider khởi tạo ở trạng thái rỗng khi không có userId** (cho AlertProvider)
    - **Validates: Yêu cầu 8.1, 8.3, 14.3, 14.5**

  - [x] 11.3 Implement ReminderProvider
    - Tạo `lib/src/providers/reminder_provider.dart` extend `ChangeNotifier`
    - Expose `reminders`, `isLoading`, `errorMessage`
    - Implement `updateUser(userId)`, `addReminder(content, toUserId)`, `deleteReminder(reminderId)`, `dispose()`
    - _Yêu cầu: 10.1, 10.2, 10.3, 10.4, 10.5, 14.3_

  - [ ]* 11.4 Viết property test cho ReminderProvider
    - **Property 13: Provider phản ánh đúng dữ liệu từ Repository** (cho ReminderProvider)
    - **Property 16: Provider dispose hủy tất cả stream subscriptions** (cho ReminderProvider)
    - **Validates: Yêu cầu 10.1, 10.2, 14.3**

  - [x] 11.5 Implement ChatProvider
    - Tạo `lib/src/providers/chat_provider.dart` extend `ChangeNotifier`
    - Expose `messages`, `isLoading`, `isSending`, `errorMessage`
    - Implement `init(currentUserId, otherUserId)` để subscribe stream
    - Implement `sendMessage(text)`: set `isSending = true`, gọi repository, bắt `ValidationException` → cập nhật `errorMessage`
    - Implement `dispose()` để cancel subscription
    - _Yêu cầu: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

  - [ ]* 11.6 Viết property test cho ChatProvider
    - **Property 13: Provider phản ánh đúng dữ liệu từ Repository** (cho ChatProvider)
    - **Validates: Yêu cầu 9.1, 9.2**

- [x] 12. Cập nhật AuthProvider và đăng ký Providers trong main.dart
  - [x] 12.1 Cập nhật AuthProvider để expose parentId
    - Thêm field `String? parentId` vào `AuthProvider`
    - Sau khi đăng nhập, fetch UserModel từ Firestore để lấy `parentId`
    - _Yêu cầu: 14.2_

  - [x] 12.2 Đăng ký MultiProvider trong main.dart
    - Thay `ChangeNotifierProvider` đơn lẻ bằng `MultiProvider` trong `main.dart`
    - Đăng ký `UserRepository` với `Provider`
    - Đăng ký `MedicationProvider`, `AlertProvider`, `ReminderProvider` với `ChangeNotifierProxyProvider<AuthProvider, XProvider>`
    - `ChatProvider` được cung cấp cục bộ tại `ChatScreen`
    - _Yêu cầu: 14.1, 14.2, 14.3, 14.4, 14.5_

- [x] 13. Tích hợp Providers vào ChildHomeScreen
  - [x] 13.1 Kết nối MedicationProvider, AlertProvider, ReminderProvider vào ChildHomeScreen
    - Chuyển `ChildHomeScreen` thành `StatelessWidget` đọc từ Provider qua `context.watch`
    - Thay `_buildWeeklyComplianceSection` dùng `weeklyCompliance` từ `MedicationProvider`
    - Thay `_buildAlertsSection` dùng `unreadAlerts` từ `AlertProvider`
    - Thay `_buildRemindersSection` dùng `reminders` từ `ReminderProvider`
    - Thay `_buildStatusSection` dùng `medications` và `todayCheckIns` từ `MedicationProvider`
    - _Yêu cầu: 11.1, 11.4, 11.5, 11.6_

  - [x] 13.2 Thêm loading indicator và error handling vào ChildHomeScreen
    - Hiển thị `CircularProgressIndicator` khi `MedicationProvider.isLoading = true`
    - Hiển thị thông báo lỗi thân thiện khi `errorMessage != null`
    - _Yêu cầu: 11.2, 11.3_

- [x] 14. Tích hợp MedicationProvider vào ScheduleScreen
  - Chuyển `ScheduleScreen` đọc `medications`, `todayCheckIns`, `complianceRate` từ `MedicationProvider`
  - Thay danh sách thuốc hardcode bằng `medications` từ Provider
  - Xác định trạng thái `taken`/`pending` dựa trên `todayCheckIns`
  - Hiển thị `complianceRate` trong phần "Tóm tắt hôm nay"
  - Hiển thị loading indicator khi `isLoading = true`
  - _Yêu cầu: 12.1, 12.2, 12.3, 12.4, 12.5_

- [x] 15. Tích hợp ChatProvider vào ChatScreen
  - [x] 15.1 Refactor ChatScreen để dùng ChatProvider
    - Chuyển `ChatScreen` thành `StatefulWidget` với `ChangeNotifierProvider` cục bộ cho `ChatProvider`
    - Khởi tạo `ChatProvider` với `currentUserId` và `otherUserId` trong `initState`
    - Thay mock `_messages` bằng `chatProvider.messages` từ Provider
    - _Yêu cầu: 13.1, 13.2_

  - [x] 15.2 Implement gửi tin nhắn và auto-scroll
    - Kết nối nút gửi với `chatProvider.sendMessage(text)`, xóa input field sau khi gửi
    - Vô hiệu hóa nút gửi khi `chatProvider.isSending = true`
    - Auto-scroll xuống cuối khi có tin nhắn mới trong stream
    - Hiển thị `SnackBar` khi `chatProvider.errorMessage != null`
    - _Yêu cầu: 13.3, 13.4, 13.5, 13.6_

- [ ] 16. Checkpoint cuối — Đảm bảo tất cả tests pass
  - Đảm bảo tất cả tests pass, hỏi người dùng nếu có thắc mắc.

## Ghi chú

- Các task đánh dấu `*` là tùy chọn, có thể bỏ qua để triển khai MVP nhanh hơn
- Mỗi task tham chiếu yêu cầu cụ thể để đảm bảo traceability
- Property tests dùng generator ngẫu nhiên với tối thiểu 100 iterations mỗi property
- `ChatProvider` được cung cấp cục bộ tại `ChatScreen` vì cần `otherUserId` — thông tin chỉ có khi mở màn hình chat
