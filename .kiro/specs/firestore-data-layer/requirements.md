# Tài liệu Yêu cầu

## Giới thiệu

Tính năng này xây dựng data layer hoàn chỉnh cho ứng dụng Flutter "An Tâm" — ứng dụng chăm sóc sức khỏe người cao tuổi kết nối người thân (con cái) với cha/mẹ. Hiện tại toàn bộ UI đang sử dụng dữ liệu giả (fake/mock data) được hardcode trực tiếp trong các màn hình. Mục tiêu là xây dựng các data models, repositories và providers chuẩn để thay thế fake data bằng dữ liệu thật từ Firestore, phục vụ ba màn hình chính: ChildHomeScreen, ScheduleScreen và ChatScreen.

## Bảng thuật ngữ

- **Data_Layer**: Tầng dữ liệu bao gồm models, repositories và providers trong kiến trúc Flutter.
- **Repository**: Lớp trung gian giữa data source (Firestore) và UI, đóng gói toàn bộ logic truy vấn dữ liệu.
- **Provider**: Lớp quản lý trạng thái (state management) sử dụng `ChangeNotifier`, cung cấp dữ liệu cho UI.
- **Model**: Lớp Dart đại diện cho một document trong Firestore, có khả năng serialize/deserialize từ `Map<String, dynamic>`.
- **FirestoreService**: Service cơ bản đã có tại `lib/src/services/firestore_service.dart`, cung cấp truy cập trực tiếp vào các collection Firestore.
- **Child_User**: Người dùng có role `child` — con cái theo dõi sức khỏe cha/mẹ.
- **Parent_User**: Người dùng có role `parent` — cha/mẹ cao tuổi được theo dõi.
- **CheckIn**: Bản ghi xác nhận uống thuốc của Parent_User cho một lần dùng thuốc cụ thể.
- **Medication**: Lịch dùng thuốc được Child_User tạo ra cho Parent_User.
- **Alert**: Thông báo/cảnh báo gửi đến người dùng (ví dụ: bỏ lỡ thuốc, SOS).
- **Reminder**: Lời nhắn từ Parent_User gửi đến Child_User hoặc ngược lại.
- **FamilyLink**: Liên kết gia đình giữa một Child_User và một Parent_User.
- **Message**: Tin nhắn chat giữa Child_User và Parent_User.
- **Compliance_Rate**: Tỷ lệ phần trăm số lần uống thuốc đúng hạn so với tổng số lần được lên lịch.
- **Weekly_Compliance**: Dữ liệu tuân thủ uống thuốc theo từng ngày trong tuần hiện tại.

---

## Yêu cầu

### Yêu cầu 1: Data Models — Serialize và Deserialize từ Firestore

**User Story:** Là một developer, tôi muốn có các Dart model class cho từng collection Firestore, để tôi có thể làm việc với dữ liệu có kiểu rõ ràng thay vì `Map<String, dynamic>` thô.

#### Tiêu chí chấp nhận

1. THE Data_Layer SHALL cung cấp model class `UserModel` với các trường: `id`, `name`, `email`, `role`, `parentId`, `createdAt`.
2. THE Data_Layer SHALL cung cấp model class `MedicationModel` với các trường: `id`, `parentId`, `childId`, `name`, `time`, `frequency`, `dosage`, `isActive`, `createdAt`.
3. THE Data_Layer SHALL cung cấp model class `CheckInModel` với các trường: `id`, `medicationId`, `parentId`, `status`, `timestamp`.
4. THE Data_Layer SHALL cung cấp model class `AlertModel` với các trường: `id`, `userId`, `type`, `title`, `message`, `isRead`, `timestamp`.
5. THE Data_Layer SHALL cung cấp model class `ReminderModel` với các trường: `id`, `fromUserId`, `toUserId`, `content`, `timestamp`.
6. THE Data_Layer SHALL cung cấp model class `MessageModel` với các trường: `id`, `senderId`, `receiverId`, `text`, `timestamp`.
7. THE Data_Layer SHALL cung cấp model class `FamilyLinkModel` với các trường: `id`, `childId`, `parentId`, `status`.
8. WHEN một Firestore document được đọc, THE Model SHALL chuyển đổi `DocumentSnapshot` thành model object thông qua factory constructor `fromFirestore`.
9. WHEN một model object cần được lưu vào Firestore, THE Model SHALL chuyển đổi thành `Map<String, dynamic>` thông qua method `toMap`.
10. FOR ALL model objects, việc chuyển đổi `fromFirestore` rồi `toMap` SHALL tạo ra một map tương đương với dữ liệu gốc (round-trip property).
11. IF một trường bắt buộc bị thiếu trong Firestore document, THEN THE Model SHALL trả về giá trị mặc định hợp lý thay vì ném exception.

---

### Yêu cầu 2: MedicationRepository — Quản lý lịch thuốc

**User Story:** Là một Child_User, tôi muốn tạo, xem và cập nhật lịch thuốc cho cha/mẹ, để tôi có thể theo dõi việc uống thuốc của họ.

#### Tiêu chí chấp nhận

1. WHEN Child_User tạo một lịch thuốc mới, THE MedicationRepository SHALL lưu document vào collection `medications` với đầy đủ các trường theo schema đã định nghĩa.
2. WHEN Child_User yêu cầu danh sách thuốc của Parent_User, THE MedicationRepository SHALL trả về `Stream<List<MedicationModel>>` chỉ bao gồm các thuốc có `isActive = true`.
3. WHEN Child_User cập nhật thông tin một lịch thuốc, THE MedicationRepository SHALL cập nhật document tương ứng trong Firestore.
4. WHEN Child_User vô hiệu hóa một lịch thuốc, THE MedicationRepository SHALL cập nhật trường `isActive = false` thay vì xóa document.
5. WHEN Parent_User xác nhận đã uống thuốc, THE MedicationRepository SHALL tạo một `CheckInModel` mới với `status = 'completed'` trong collection `checkIns`.
6. WHEN hệ thống phát hiện Parent_User bỏ lỡ một lần uống thuốc, THE MedicationRepository SHALL tạo một `CheckInModel` với `status = 'missed'`.
7. WHEN Child_User yêu cầu lịch sử check-in của ngày hôm nay, THE MedicationRepository SHALL trả về `Stream<List<CheckInModel>>` được lọc theo `parentId` và timestamp trong ngày hiện tại.
8. IF kết nối Firestore thất bại khi tạo lịch thuốc, THEN THE MedicationRepository SHALL ném exception có thông báo lỗi mô tả rõ nguyên nhân.

---

### Yêu cầu 3: AlertRepository — Quản lý cảnh báo và thông báo

**User Story:** Là một Child_User, tôi muốn nhận và quản lý các cảnh báo về sức khỏe của cha/mẹ, để tôi có thể phản ứng kịp thời khi có vấn đề.

#### Tiêu chí chấp nhận

1. WHEN Child_User yêu cầu danh sách cảnh báo chưa đọc, THE AlertRepository SHALL trả về `Stream<List<AlertModel>>` được lọc theo `userId` và `isRead = false`, sắp xếp theo `timestamp` giảm dần.
2. WHEN Child_User đánh dấu một cảnh báo là đã đọc, THE AlertRepository SHALL cập nhật trường `isRead = true` và `readAt = serverTimestamp()` trong Firestore.
3. WHEN hệ thống cần tạo cảnh báo mới (ví dụ: bỏ lỡ thuốc), THE AlertRepository SHALL lưu document vào collection `alerts` với đầy đủ các trường bắt buộc.
4. WHEN Child_User yêu cầu tổng số cảnh báo chưa đọc, THE AlertRepository SHALL trả về `Stream<int>` đếm số lượng document có `isRead = false` thuộc về `userId` đó.
5. IF Child_User cố gắng đánh dấu đã đọc một cảnh báo không thuộc về mình, THEN THE AlertRepository SHALL ném exception `PermissionDeniedException`.

---

### Yêu cầu 4: ReminderRepository — Quản lý lời nhắn gia đình

**User Story:** Là một Child_User, tôi muốn xem các lời nhắn từ cha/mẹ và gửi lời nhắn cho họ, để chúng tôi có thể phối hợp các công việc hàng ngày.

#### Tiêu chí chấp nhận

1. WHEN Child_User yêu cầu danh sách reminders liên quan đến mình, THE ReminderRepository SHALL trả về `Stream<List<ReminderModel>>` bao gồm cả reminders mà `fromUserId` hoặc `toUserId` là userId của Child_User, sắp xếp theo `timestamp` giảm dần.
2. WHEN Child_User tạo một reminder mới gửi cho Parent_User, THE ReminderRepository SHALL lưu document vào collection `reminders` với `fromUserId` là userId của Child_User.
3. WHEN Child_User cập nhật nội dung một reminder, THE ReminderRepository SHALL cập nhật trường `content` trong Firestore.
4. WHEN Child_User xóa một reminder do mình tạo, THE ReminderRepository SHALL xóa document tương ứng khỏi Firestore.
5. IF Child_User cố gắng xóa reminder không do mình tạo, THEN THE ReminderRepository SHALL ném exception `PermissionDeniedException`.

---

### Yêu cầu 5: MessageRepository — Quản lý tin nhắn chat

**User Story:** Là một Child_User, tôi muốn gửi và nhận tin nhắn với cha/mẹ trong thời gian thực, để chúng tôi có thể liên lạc dễ dàng ngay trong ứng dụng.

#### Tiêu chí chấp nhận

1. WHEN Child_User yêu cầu lịch sử tin nhắn với Parent_User, THE MessageRepository SHALL trả về `Stream<List<MessageModel>>` bao gồm các messages mà `senderId` hoặc `receiverId` là userId của một trong hai bên, sắp xếp theo `timestamp` tăng dần.
2. WHEN Child_User gửi một tin nhắn mới, THE MessageRepository SHALL lưu document vào collection `messages` với `senderId` là userId của người gửi và `timestamp = serverTimestamp()`.
3. WHILE Child_User đang xem màn hình chat, THE MessageRepository SHALL cung cấp stream real-time để UI tự động cập nhật khi có tin nhắn mới.
4. IF nội dung tin nhắn rỗng hoặc chỉ chứa khoảng trắng, THEN THE MessageRepository SHALL ném exception `ValidationException` trước khi ghi vào Firestore.
5. IF kết nối Firestore thất bại khi gửi tin nhắn, THEN THE MessageRepository SHALL ném exception có thông báo lỗi mô tả rõ nguyên nhân.

---

### Yêu cầu 6: UserRepository — Quản lý thông tin người dùng và liên kết gia đình

**User Story:** Là một Child_User, tôi muốn xem thông tin của cha/mẹ và quản lý liên kết gia đình, để ứng dụng biết tôi đang theo dõi ai.

#### Tiêu chí chấp nhận

1. WHEN Child_User yêu cầu thông tin profile của mình, THE UserRepository SHALL trả về `Future<UserModel>` từ collection `users` theo `userId`.
2. WHEN Child_User yêu cầu thông tin của Parent_User được liên kết, THE UserRepository SHALL trả về `Future<UserModel>` của Parent_User dựa trên trường `parentId` trong profile của Child_User.
3. WHEN Child_User tạo liên kết gia đình mới với Parent_User, THE UserRepository SHALL lưu document vào collection `familyLinks` với `status = 'pending'`.
4. WHEN Parent_User chấp nhận liên kết gia đình, THE UserRepository SHALL cập nhật `status = 'active'` trong document `familyLinks` tương ứng và cập nhật trường `parentId` trong profile của Child_User.
5. WHEN Child_User yêu cầu trạng thái liên kết gia đình hiện tại, THE UserRepository SHALL trả về `Stream<FamilyLinkModel?>` theo `childId`.
6. IF Child_User yêu cầu thông tin một user không tồn tại trong Firestore, THEN THE UserRepository SHALL ném exception `UserNotFoundException`.

---

### Yêu cầu 7: MedicationProvider — State management cho lịch thuốc

**User Story:** Là một developer, tôi muốn có Provider quản lý trạng thái lịch thuốc, để ChildHomeScreen và ScheduleScreen có thể hiển thị dữ liệu thật từ Firestore.

#### Tiêu chí chấp nhận

1. THE MedicationProvider SHALL expose `List<MedicationModel> medications` là danh sách thuốc đang active của Parent_User được liên kết.
2. THE MedicationProvider SHALL expose `List<CheckInModel> todayCheckIns` là danh sách check-in trong ngày hôm nay.
3. THE MedicationProvider SHALL expose `double complianceRate` là tỷ lệ tuân thủ uống thuốc trong tháng hiện tại, tính bằng `(số checkIn completed) / (tổng số checkIn) * 100`.
4. THE MedicationProvider SHALL expose `List<Map<String, dynamic>> weeklyCompliance` là dữ liệu tuân thủ theo từng ngày trong tuần hiện tại (T2 đến CN), mỗi phần tử chứa `day`, `status` (`completed`, `missed`, `pending`, `upcoming`).
5. WHEN MedicationProvider được khởi tạo với một `parentId` hợp lệ, THE MedicationProvider SHALL tự động subscribe vào các stream từ MedicationRepository và cập nhật state.
6. WHEN dữ liệu từ Firestore thay đổi, THE MedicationProvider SHALL gọi `notifyListeners()` để UI tự động rebuild.
7. THE MedicationProvider SHALL expose `bool isLoading` và `String? errorMessage` để UI xử lý trạng thái loading và lỗi.
8. IF MedicationRepository ném exception, THEN THE MedicationProvider SHALL cập nhật `errorMessage` và gọi `notifyListeners()` thay vì để exception lan ra UI.

---

### Yêu cầu 8: AlertProvider — State management cho cảnh báo

**User Story:** Là một developer, tôi muốn có Provider quản lý trạng thái cảnh báo, để ChildHomeScreen hiển thị đúng số lượng và nội dung cảnh báo chưa đọc.

#### Tiêu chí chấp nhận

1. THE AlertProvider SHALL expose `List<AlertModel> unreadAlerts` là danh sách cảnh báo chưa đọc của người dùng hiện tại.
2. THE AlertProvider SHALL expose `int unreadCount` là số lượng cảnh báo chưa đọc.
3. WHEN AlertProvider được khởi tạo với một `userId` hợp lệ, THE AlertProvider SHALL tự động subscribe vào stream từ AlertRepository.
4. WHEN Child_User gọi `markAsRead(alertId)`, THE AlertProvider SHALL gọi AlertRepository để cập nhật Firestore và cập nhật state local.
5. THE AlertProvider SHALL expose `bool isLoading` và `String? errorMessage` để UI xử lý trạng thái loading và lỗi.

---

### Yêu cầu 9: ChatProvider — State management cho tin nhắn

**User Story:** Là một developer, tôi muốn có Provider quản lý trạng thái chat, để ChatScreen hiển thị tin nhắn thật từ Firestore và hỗ trợ gửi tin nhắn mới.

#### Tiêu chí chấp nhận

1. THE ChatProvider SHALL expose `List<MessageModel> messages` là danh sách tin nhắn giữa Child_User và Parent_User, sắp xếp theo `timestamp` tăng dần.
2. WHEN ChatProvider được khởi tạo với `currentUserId` và `otherUserId`, THE ChatProvider SHALL tự động subscribe vào stream từ MessageRepository.
3. WHEN Child_User gọi `sendMessage(text)`, THE ChatProvider SHALL gọi MessageRepository để lưu tin nhắn và cập nhật state.
4. WHILE ChatProvider đang gửi tin nhắn, THE ChatProvider SHALL cập nhật `isSending = true` để UI có thể hiển thị trạng thái loading.
5. IF MessageRepository ném `ValidationException` khi gửi tin nhắn rỗng, THEN THE ChatProvider SHALL cập nhật `errorMessage` mà không thay đổi danh sách tin nhắn.
6. THE ChatProvider SHALL expose `bool isLoading` và `String? errorMessage` để UI xử lý trạng thái loading và lỗi.

---

### Yêu cầu 10: ReminderProvider — State management cho lời nhắn

**User Story:** Là một developer, tôi muốn có Provider quản lý trạng thái reminders, để ChildHomeScreen hiển thị đúng các lời nhắn từ cha/mẹ.

#### Tiêu chí chấp nhận

1. THE ReminderProvider SHALL expose `List<ReminderModel> reminders` là danh sách reminders liên quan đến người dùng hiện tại.
2. WHEN ReminderProvider được khởi tạo với một `userId` hợp lệ, THE ReminderProvider SHALL tự động subscribe vào stream từ ReminderRepository.
3. WHEN Child_User gọi `addReminder(content, toUserId)`, THE ReminderProvider SHALL gọi ReminderRepository để lưu reminder mới và cập nhật state.
4. WHEN Child_User gọi `deleteReminder(reminderId)`, THE ReminderProvider SHALL gọi ReminderRepository để xóa reminder và cập nhật state.
5. THE ReminderProvider SHALL expose `bool isLoading` và `String? errorMessage` để UI xử lý trạng thái loading và lỗi.

---

### Yêu cầu 11: Tích hợp Provider vào màn hình ChildHomeScreen

**User Story:** Là một Child_User, tôi muốn ChildHomeScreen hiển thị dữ liệu thật từ Firestore thay vì fake data, để tôi có thể theo dõi tình trạng sức khỏe thực tế của cha/mẹ.

#### Tiêu chí chấp nhận

1. WHEN ChildHomeScreen được render, THE ChildHomeScreen SHALL đọc dữ liệu từ MedicationProvider, AlertProvider và ReminderProvider thông qua `context.watch` hoặc `Consumer`.
2. WHEN MedicationProvider có `isLoading = true`, THE ChildHomeScreen SHALL hiển thị loading indicator thay vì danh sách thuốc.
3. WHEN MedicationProvider có `errorMessage != null`, THE ChildHomeScreen SHALL hiển thị thông báo lỗi thân thiện với người dùng.
4. THE ChildHomeScreen SHALL hiển thị `weeklyCompliance` từ MedicationProvider trong phần "Lịch sử tuân thủ" thay vì dữ liệu hardcode.
5. THE ChildHomeScreen SHALL hiển thị `unreadAlerts` từ AlertProvider trong phần "Cảnh báo & Thông báo" thay vì dữ liệu hardcode.
6. THE ChildHomeScreen SHALL hiển thị `reminders` từ ReminderProvider trong phần "Lời nhắn" thay vì dữ liệu hardcode.

---

### Yêu cầu 12: Tích hợp Provider vào màn hình ScheduleScreen

**User Story:** Là một Child_User, tôi muốn ScheduleScreen hiển thị lịch thuốc thật của cha/mẹ, để tôi có thể theo dõi và quản lý lịch uống thuốc chính xác.

#### Tiêu chí chấp nhận

1. WHEN ScheduleScreen được render, THE ScheduleScreen SHALL đọc dữ liệu từ MedicationProvider thông qua `context.watch` hoặc `Consumer`.
2. THE ScheduleScreen SHALL hiển thị danh sách `medications` từ MedicationProvider trong phần "Thứ tự thuốc hôm nay" thay vì dữ liệu hardcode.
3. THE ScheduleScreen SHALL hiển thị `todayCheckIns` từ MedicationProvider để xác định trạng thái `taken`/`pending` của từng thuốc.
4. THE ScheduleScreen SHALL hiển thị `complianceRate` từ MedicationProvider trong phần "Tóm tắt hôm nay".
5. WHEN MedicationProvider có `isLoading = true`, THE ScheduleScreen SHALL hiển thị loading indicator.

---

### Yêu cầu 13: Tích hợp Provider vào màn hình ChatScreen

**User Story:** Là một Child_User, tôi muốn ChatScreen hiển thị tin nhắn thật và cho phép gửi tin nhắn đến cha/mẹ, để chúng tôi có thể liên lạc thực sự qua ứng dụng.

#### Tiêu chí chấp nhận

1. WHEN ChatScreen được render với `currentUserId` và `otherUserId`, THE ChatScreen SHALL khởi tạo ChatProvider và subscribe vào stream tin nhắn từ Firestore.
2. THE ChatScreen SHALL hiển thị danh sách `messages` từ ChatProvider thay vì mock data hardcode.
3. WHEN Child_User nhấn nút gửi với nội dung hợp lệ, THE ChatScreen SHALL gọi `chatProvider.sendMessage(text)` và xóa nội dung input field.
4. WHILE ChatProvider có `isSending = true`, THE ChatScreen SHALL vô hiệu hóa nút gửi để tránh gửi trùng lặp.
5. WHEN có tin nhắn mới trong stream, THE ChatScreen SHALL tự động cuộn xuống cuối danh sách tin nhắn.
6. IF ChatProvider có `errorMessage != null`, THE ChatScreen SHALL hiển thị snackbar thông báo lỗi.

---

### Yêu cầu 14: Đăng ký Providers trong dependency injection

**User Story:** Là một developer, tôi muốn tất cả các Providers được đăng ký đúng cách trong widget tree, để các màn hình có thể truy cập dữ liệu mà không cần khởi tạo thủ công.

#### Tiêu chí chấp nhận

1. THE Data_Layer SHALL đăng ký MedicationProvider, AlertProvider, ReminderProvider, ChatProvider và UserRepository trong `MultiProvider` tại root của ứng dụng hoặc tại điểm phù hợp trong widget tree.
2. WHEN người dùng đăng nhập thành công, THE Data_Layer SHALL khởi tạo các Providers với `userId` và `parentId` tương ứng từ AuthProvider.
3. WHEN người dùng đăng xuất, THE Data_Layer SHALL hủy các stream subscriptions trong tất cả Providers để tránh memory leak.
4. THE Data_Layer SHALL sử dụng `ChangeNotifierProvider` hoặc `ChangeNotifierProxyProvider` để đảm bảo các Providers được rebuild khi AuthProvider thay đổi.
5. IF AuthProvider chưa có thông tin `parentId` (chưa liên kết gia đình), THEN THE Data_Layer SHALL khởi tạo các Providers ở trạng thái rỗng mà không ném exception.
