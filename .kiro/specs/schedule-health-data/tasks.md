# Kế hoạch triển khai: Schedule Health Data

## Tổng quan

Mở rộng data layer của ứng dụng An Tâm để thay thế toàn bộ dữ liệu hardcode trong `ScheduleScreen` bằng dữ liệu thật từ Firestore. Triển khai theo thứ tự: Models → Repositories → Providers → UI.

## Tasks

- [x] 1. Mở rộng UserModel và UserRepository
  - [x] 1.1 Thêm field `status` (String, mặc định `''`) và `lastUpdated` (DateTime?) vào `UserModel`
    - Cập nhật constructor, `fromFirestore` (đọc `status` và `lastUpdated` từ Timestamp), `toMap` (thêm `status`, bỏ `lastUpdated`)
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  - [ ]* 1.2 Viết property test cho UserModel.status round-trip
    - **Property 3: UserModel.status round-trip serialization**
    - **Validates: Requirements 1.1, 1.3, 1.4, 8.3**
  - [x] 1.3 Thêm method `streamParentStatus(String parentId)` vào `UserRepository`
    - Lắng nghe `users/{parentId}` real-time, emit `UserNotFoundException` nếu document không tồn tại, `PermissionDeniedException` nếu lỗi `permission-denied`
    - _Requirements: 1.5, 1.6, 1.7_

- [x] 2. Tạo AppointmentModel và AppointmentRepository
  - [x] 2.1 Tạo file `lib/src/models/appointment_model.dart`
    - Implement `AppointmentModel` với các field: `id`, `parentId`, `title`, `doctorName`, `date` (DateTime), `type`
    - `fromFirestore`: ánh xạ `date` từ Timestamp, trả về defaults khi thiếu field (không throw)
    - `toMap`: trả về tất cả field trừ `id`, `date` lưu dưới dạng Timestamp
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  - [ ]* 2.2 Viết property test cho AppointmentModel round-trip
    - **Property 1: AppointmentModel round-trip serialization**
    - **Validates: Requirements 2.2, 2.4, 8.1**
  - [ ]* 2.3 Viết property test: toMap không chứa key 'id'
    - **Property 4: toMap không chứa document ID**
    - **Validates: Requirements 1.4, 2.4, 4.4**
  - [ ]* 2.4 Viết property test: fromFirestore với map rỗng không ném exception
    - **Property 5: fromFirestore với map rỗng không ném exception**
    - **Validates: Requirements 2.3, 4.3, 8.4, 8.5**
  - [x] 2.5 Tạo file `lib/src/repositories/appointment_repository.dart`
    - Implement `getUpcomingAppointments(String parentId)` → `Stream<List<AppointmentModel>>`
    - Query: `where('parentId', ==, parentId)`, `where('date', >=, DateTime.now())`, `orderBy('date')`
    - Implement `createAppointment(AppointmentModel)` → `Future<String>` (trả về document ID)
    - Throw `PermissionDeniedException` khi Firestore trả về `permission-denied`
    - _Requirements: 2.5, 2.6, 2.7, 2.8_

- [x] 3. Tạo HealthMetricModel và HealthMetricRepository
  - [x] 3.1 Tạo file `lib/src/models/health_metric_model.dart`
    - Implement `HealthMetricModel` với các field: `id`, `parentId`, `bloodPressure` (String), `heartRate` (int), `bloodSugar` (int), `weight` (double), `recordedAt` (DateTime?)
    - `fromFirestore`: ánh xạ đúng kiểu dữ liệu, trả về defaults khi thiếu field (không throw)
    - `toMap`: trả về tất cả field trừ `id`
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  - [ ]* 3.2 Viết property test cho HealthMetricModel round-trip
    - **Property 2: HealthMetricModel round-trip serialization**
    - **Validates: Requirements 4.2, 4.4, 8.2**
  - [x] 3.3 Tạo file `lib/src/repositories/health_metric_repository.dart`
    - Implement `streamLatestMetric(String parentId)` → `Stream<HealthMetricModel?>`
    - Query: `where('parentId', ==, parentId)`, `orderBy('recordedAt', descending: true)`, `limit(1)`, emit `null` khi snapshot rỗng
    - Implement `createMetric(HealthMetricModel)` → `Future<String>`
    - Throw `PermissionDeniedException` khi Firestore trả về `permission-denied`
    - _Requirements: 4.5, 4.6, 4.7, 4.8, 4.9_

- [ ] 4. Checkpoint — Đảm bảo tất cả tests pass
  - Đảm bảo tất cả tests pass, hỏi user nếu có thắc mắc.

- [x] 5. Tạo AppointmentProvider
  - [x] 5.1 Tạo file `lib/src/providers/appointment_provider.dart`
    - Extend `ChangeNotifier`, state: `appointments` (List), `isLoading` (bool), `errorMessage` (String?)
    - Implement `updateUser({String? parentId})`: hủy subscription cũ, đặt `isLoading = true`, subscribe `AppointmentRepository.getUpcomingAppointments`
    - Khi `parentId` null/rỗng: đặt `appointments = []`, `isLoading = false`, không tạo subscription
    - Xử lý stream data → cập nhật `appointments`, `isLoading = false`, `notifyListeners()`
    - Xử lý stream error → cập nhật `errorMessage`, `isLoading = false`, `notifyListeners()`
    - Override `dispose()` để hủy `StreamSubscription`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

- [x] 6. Tạo HealthMetricProvider
  - [x] 6.1 Tạo file `lib/src/providers/health_metric_provider.dart`
    - Extend `ChangeNotifier`, state: `latestMetric` (HealthMetricModel?), `isLoading` (bool), `errorMessage` (String?)
    - Implement `updateUser({String? parentId})`: hủy subscription cũ, đặt `isLoading = true`, subscribe `HealthMetricRepository.streamLatestMetric`
    - Khi `parentId` null/rỗng: đặt `latestMetric = null`, `isLoading = false`, không tạo subscription
    - Xử lý stream data (kể cả `null`) → cập nhật `latestMetric`, `isLoading = false`, `notifyListeners()`
    - Xử lý stream error → cập nhật `errorMessage`, `isLoading = false`, `notifyListeners()`
    - Override `dispose()` để hủy `StreamSubscription`
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_

- [x] 7. Đăng ký Providers trong main.dart
  - [x] 7.1 Cập nhật `lib/main.dart`
    - Import `appointment_provider.dart` và `health_metric_provider.dart`
    - Thêm `ChangeNotifierProxyProvider<AuthProvider, AppointmentProvider>` vào `MultiProvider`
    - Thêm `ChangeNotifierProxyProvider<AuthProvider, HealthMetricProvider>` vào `MultiProvider`
    - Callback `update` gọi `provider.updateUser(parentId: auth.parentId)`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 8. Cập nhật ScheduleScreen với real data
  - [x] 8.1 Thêm helper function `_formatRelativeTime(DateTime? dt)` vào `schedule_screen.dart`
    - Trả về chuỗi thời gian tương đối (ví dụ: "Cập nhật 5 phút trước", "Cập nhật 2 giờ trước")
    - Trả về `''` khi `dt == null`
    - _Requirements: 7.8_
  - [ ]* 8.2 Viết property test cho format thời gian tương đối
    - **Property 6: Format thời gian tương đối**
    - **Validates: Requirements 7.8**
  - [x] 8.3 Cập nhật `_buildStatusCard()` dùng `StreamBuilder<UserModel>`
    - Inject `UserRepository` qua `context.read<UserRepository>()`, lấy `parentId` từ `AuthProvider`
    - Hiển thị `name` và `status` từ `UserModel`, thời gian tương đối từ `lastUpdated`
    - _Requirements: 7.1, 7.7, 7.8_
  - [x] 8.4 Cập nhật `_buildUpcomingAppointments()` dùng `AppointmentProvider`
    - `context.watch<AppointmentProvider>()`, hiển thị `CircularProgressIndicator` khi `isLoading`
    - Hiển thị "Chưa có lịch khám nào." khi `appointments` rỗng
    - Render `_AppointmentCard` với `title`, `doctorName`, `date` được format từ `AppointmentModel`
    - Hiển thị thông báo lỗi thân thiện khi `errorMessage != null`
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.9_
  - [x] 8.5 Cập nhật `_buildHealthMetrics()` dùng `HealthMetricProvider`
    - `context.watch<HealthMetricProvider>()`, hiển thị `CircularProgressIndicator` khi `isLoading`
    - Hiển thị `--` cho tất cả chỉ số khi `latestMetric == null`
    - Hiển thị `bloodPressure`, `heartRate`, `bloodSugar`, `weight` từ `HealthMetricModel`
    - _Requirements: 7.1, 7.2, 7.5, 7.6_

- [ ] 9. Checkpoint cuối — Đảm bảo tất cả tests pass
  - Đảm bảo tất cả tests pass, hỏi user nếu có thắc mắc.

## Ghi chú

- Tasks đánh dấu `*` là optional — có thể bỏ qua để MVP nhanh hơn
- Mỗi task tham chiếu requirements cụ thể để đảm bảo traceability
- Property tests dùng thư viện `fast_check` (Dart), mỗi property chạy tối thiểu 100 iterations
- `ScheduleScreen` consume `UserRepository.streamParentStatus` trực tiếp qua `StreamBuilder` (không cần Provider riêng)
