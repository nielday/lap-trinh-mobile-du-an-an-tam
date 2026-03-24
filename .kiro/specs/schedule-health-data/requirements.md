# Tài liệu Yêu cầu: Schedule Health Data

## Giới thiệu

Feature này mở rộng data layer của ứng dụng Flutter "An Tâm" để thay thế toàn bộ dữ liệu hardcode còn lại trong `ScheduleScreen` bằng dữ liệu thật từ Firestore. Cụ thể gồm ba phần: (1) thẻ trạng thái cha/mẹ lấy từ `UserModel` với các field mới `status` và `lastUpdated`, (2) danh sách lịch khám từ collection mới `appointments`, và (3) chỉ số sức khỏe từ collection mới `health_metrics`. Kiến trúc tuân theo pattern đã có: Models → Repositories → Providers → UI.

---

## Bảng thuật ngữ

- **ScheduleScreen**: Màn hình lịch trình trong ứng dụng An Tâm, hiển thị trạng thái cha/mẹ, lịch khám, lịch thuốc và chỉ số sức khỏe.
- **AppointmentModel**: Model đại diện cho một lịch khám bác sĩ của cha/mẹ.
- **AppointmentRepository**: Repository truy cập collection `appointments` trong Firestore.
- **AppointmentProvider**: ChangeNotifier quản lý state danh sách lịch khám cho UI.
- **HealthMetricModel**: Model đại diện cho một bản ghi chỉ số sức khỏe (huyết áp, nhịp tim, đường huyết, cân nặng).
- **HealthMetricRepository**: Repository truy cập collection `health_metrics` trong Firestore.
- **HealthMetricProvider**: ChangeNotifier quản lý state chỉ số sức khỏe mới nhất cho UI.
- **UserModel**: Model người dùng đã có, sẽ được mở rộng thêm field `status` và `lastUpdated`.
- **UserRepository**: Repository đã có, sẽ được mở rộng để stream trạng thái cha/mẹ theo thời gian thực.
- **AuthProvider**: Provider đã có, cung cấp `parentId` cho các Provider khác qua `ChangeNotifierProxyProvider`.
- **parentId**: ID của tài khoản cha/mẹ được liên kết với tài khoản con hiện tại.

---

## Yêu cầu

### Yêu cầu 1: Mở rộng UserModel với trạng thái cha/mẹ

**User Story:** Là con cái, tôi muốn xem trạng thái hiện tại và thời điểm cập nhật gần nhất của cha/mẹ trên ScheduleScreen, để tôi biết cha/mẹ đang ổn hay cần chú ý.

#### Tiêu chí chấp nhận

1. THE **UserModel** SHALL có field `status` kiểu `String` với giá trị mặc định là chuỗi rỗng khi không có dữ liệu trong Firestore.
2. THE **UserModel** SHALL có field `lastUpdated` kiểu `DateTime?` được ánh xạ từ Firestore Timestamp field `lastUpdated`.
3. WHEN một `DocumentSnapshot` của collection `users` được truyền vào `UserModel.fromFirestore`, THE **UserModel** SHALL đọc `status` từ field `status` và `lastUpdated` từ field `lastUpdated` trong document data.
4. WHEN `UserModel.toMap()` được gọi, THE **UserModel** SHALL bao gồm `status` trong map trả về nhưng KHÔNG bao gồm `id` vì đó là document ID.
5. THE **UserRepository** SHALL có method `streamParentStatus(String parentId)` trả về `Stream<UserModel>` lắng nghe thay đổi real-time của document `users/{parentId}`.
6. IF document `users/{parentId}` không tồn tại, THEN THE **UserRepository** SHALL emit `UserNotFoundException` vào stream.
7. IF Firestore trả về lỗi `permission-denied`, THEN THE **UserRepository** SHALL emit `PermissionDeniedException` vào stream.

---

### Yêu cầu 2: AppointmentModel và AppointmentRepository

**User Story:** Là con cái, tôi muốn xem danh sách lịch khám sắp tới của cha/mẹ, để tôi có thể nhắc nhở và sắp xếp đưa đón.

#### Tiêu chí chấp nhận

1. THE **AppointmentModel** SHALL có các field: `id` (String), `parentId` (String), `title` (String), `doctorName` (String), `date` (DateTime), `type` (String).
2. WHEN một `DocumentSnapshot` của collection `appointments` được truyền vào `AppointmentModel.fromFirestore`, THE **AppointmentModel** SHALL ánh xạ field `date` từ Firestore Timestamp sang `DateTime`.
3. IF `DocumentSnapshot` thiếu bất kỳ field nào, THEN THE **AppointmentModel** SHALL trả về giá trị mặc định hợp lý (String rỗng cho text, `DateTime.now()` cho date) mà KHÔNG ném exception.
4. WHEN `AppointmentModel.toMap()` được gọi, THE **AppointmentModel** SHALL trả về map chứa tất cả các field trừ `id`, với `date` được lưu dưới dạng Firestore Timestamp.
5. THE **AppointmentRepository** SHALL có method `getUpcomingAppointments(String parentId)` trả về `Stream<List<AppointmentModel>>`.
6. WHEN `getUpcomingAppointments(parentId)` được gọi, THE **AppointmentRepository** SHALL query collection `appointments` với điều kiện `parentId` khớp, `date` lớn hơn hoặc bằng thời điểm hiện tại, sắp xếp theo `date` tăng dần.
7. THE **AppointmentRepository** SHALL có method `createAppointment(AppointmentModel appointment)` trả về `Future<String>` là ID của document vừa tạo.
8. IF Firestore trả về lỗi `permission-denied` trong bất kỳ operation nào, THEN THE **AppointmentRepository** SHALL throw `PermissionDeniedException`.

---

### Yêu cầu 3: AppointmentProvider

**User Story:** Là con cái, tôi muốn ScheduleScreen tự động cập nhật khi có lịch khám mới, để tôi luôn thấy thông tin mới nhất mà không cần refresh thủ công.

#### Tiêu chí chấp nhận

1. THE **AppointmentProvider** SHALL extend `ChangeNotifier` và có các state: `appointments` (List<AppointmentModel>), `isLoading` (bool), `errorMessage` (String?).
2. THE **AppointmentProvider** SHALL có method `updateUser({String? parentId})` để cập nhật subscription khi `parentId` thay đổi.
3. WHEN `updateUser` được gọi với `parentId` hợp lệ, THE **AppointmentProvider** SHALL hủy subscription cũ, đặt `isLoading = true`, subscribe vào `AppointmentRepository.getUpcomingAppointments(parentId)` và gọi `notifyListeners()`.
4. WHEN `AppointmentRepository` emit danh sách mới, THE **AppointmentProvider** SHALL cập nhật `appointments`, đặt `isLoading = false` và gọi `notifyListeners()`.
5. WHEN `AppointmentRepository` emit lỗi, THE **AppointmentProvider** SHALL cập nhật `errorMessage` với thông báo lỗi, đặt `isLoading = false` và gọi `notifyListeners()`.
6. WHEN `updateUser` được gọi với `parentId = null` hoặc chuỗi rỗng, THE **AppointmentProvider** SHALL đặt `appointments = []`, `isLoading = false` và KHÔNG tạo Firestore subscription.
7. WHEN `dispose()` được gọi, THE **AppointmentProvider** SHALL hủy tất cả `StreamSubscription` đang active.

---

### Yêu cầu 4: HealthMetricModel và HealthMetricRepository

**User Story:** Là con cái, tôi muốn xem chỉ số sức khỏe mới nhất của cha/mẹ (huyết áp, nhịp tim, đường huyết, cân nặng), để tôi theo dõi tình trạng sức khỏe hàng ngày.

#### Tiêu chí chấp nhận

1. THE **HealthMetricModel** SHALL có các field: `id` (String), `parentId` (String), `bloodPressure` (String), `heartRate` (int), `bloodSugar` (int), `weight` (double), `recordedAt` (DateTime?).
2. WHEN một `DocumentSnapshot` của collection `health_metrics` được truyền vào `HealthMetricModel.fromFirestore`, THE **HealthMetricModel** SHALL ánh xạ đúng kiểu dữ liệu cho từng field, đặc biệt `heartRate` và `bloodSugar` là `int`, `weight` là `double`.
3. IF `DocumentSnapshot` thiếu bất kỳ field nào, THEN THE **HealthMetricModel** SHALL trả về giá trị mặc định (String rỗng cho `bloodPressure`, `0` cho `heartRate` và `bloodSugar`, `0.0` cho `weight`, `null` cho `recordedAt`) mà KHÔNG ném exception.
4. WHEN `HealthMetricModel.toMap()` được gọi, THE **HealthMetricModel** SHALL trả về map chứa tất cả các field trừ `id`.
5. THE **HealthMetricRepository** SHALL có method `streamLatestMetric(String parentId)` trả về `Stream<HealthMetricModel?>`.
6. WHEN `streamLatestMetric(parentId)` được gọi, THE **HealthMetricRepository** SHALL query collection `health_metrics` với điều kiện `parentId` khớp, sắp xếp theo `recordedAt` giảm dần, giới hạn 1 document.
7. WHEN collection `health_metrics` không có document nào cho `parentId`, THE **HealthMetricRepository** SHALL emit `null` vào stream.
8. THE **HealthMetricRepository** SHALL có method `createMetric(HealthMetricModel metric)` trả về `Future<String>` là ID của document vừa tạo.
9. IF Firestore trả về lỗi `permission-denied` trong bất kỳ operation nào, THEN THE **HealthMetricRepository** SHALL throw `PermissionDeniedException`.

---

### Yêu cầu 5: HealthMetricProvider

**User Story:** Là con cái, tôi muốn chỉ số sức khỏe trên ScheduleScreen tự động cập nhật khi cha/mẹ ghi nhận chỉ số mới, để tôi luôn thấy dữ liệu mới nhất.

#### Tiêu chí chấp nhận

1. THE **HealthMetricProvider** SHALL extend `ChangeNotifier` và có các state: `latestMetric` (HealthMetricModel?), `isLoading` (bool), `errorMessage` (String?).
2. THE **HealthMetricProvider** SHALL có method `updateUser({String? parentId})` để cập nhật subscription khi `parentId` thay đổi.
3. WHEN `updateUser` được gọi với `parentId` hợp lệ, THE **HealthMetricProvider** SHALL hủy subscription cũ, đặt `isLoading = true`, subscribe vào `HealthMetricRepository.streamLatestMetric(parentId)` và gọi `notifyListeners()`.
4. WHEN `HealthMetricRepository` emit `HealthMetricModel` mới, THE **HealthMetricProvider** SHALL cập nhật `latestMetric`, đặt `isLoading = false` và gọi `notifyListeners()`.
5. WHEN `HealthMetricRepository` emit `null`, THE **HealthMetricProvider** SHALL đặt `latestMetric = null`, `isLoading = false` và gọi `notifyListeners()`.
6. WHEN `HealthMetricRepository` emit lỗi, THE **HealthMetricProvider** SHALL cập nhật `errorMessage`, đặt `isLoading = false` và gọi `notifyListeners()`.
7. WHEN `updateUser` được gọi với `parentId = null` hoặc chuỗi rỗng, THE **HealthMetricProvider** SHALL đặt `latestMetric = null`, `isLoading = false` và KHÔNG tạo Firestore subscription.
8. WHEN `dispose()` được gọi, THE **HealthMetricProvider** SHALL hủy `StreamSubscription` đang active.

---

### Yêu cầu 6: Đăng ký Providers trong main.dart

**User Story:** Là developer, tôi muốn các Provider mới được đăng ký đúng cách trong dependency injection tree, để chúng tự động cập nhật khi user đăng nhập/đăng xuất.

#### Tiêu chí chấp nhận

1. THE **AppointmentProvider** SHALL được đăng ký trong `MultiProvider` của `main.dart` bằng `ChangeNotifierProxyProvider<AuthProvider, AppointmentProvider>`.
2. WHEN `AuthProvider` thay đổi `parentId`, THE **AppointmentProvider** SHALL tự động gọi `updateUser(parentId: auth.parentId)` thông qua callback `update` của `ChangeNotifierProxyProvider`.
3. THE **HealthMetricProvider** SHALL được đăng ký trong `MultiProvider` của `main.dart` bằng `ChangeNotifierProxyProvider<AuthProvider, HealthMetricProvider>`.
4. WHEN `AuthProvider` thay đổi `parentId`, THE **HealthMetricProvider** SHALL tự động gọi `updateUser(parentId: auth.parentId)` thông qua callback `update` của `ChangeNotifierProxyProvider`.
5. THE **main.dart** SHALL import đầy đủ các file mới: `appointment_provider.dart`, `health_metric_provider.dart`.

---

### Yêu cầu 7: Cập nhật ScheduleScreen với real data

**User Story:** Là con cái, tôi muốn ScheduleScreen hiển thị dữ liệu thật từ Firestore thay vì dữ liệu cứng, để tôi thấy thông tin chính xác về cha/mẹ.

#### Tiêu chí chấp nhận

1. WHEN `ScheduleScreen` được render, THE **ScheduleScreen** SHALL đọc `AppointmentProvider` và `HealthMetricProvider` từ context bằng `context.watch`.
2. WHEN `AppointmentProvider.isLoading == true` hoặc `HealthMetricProvider.isLoading == true`, THE **ScheduleScreen** SHALL hiển thị `CircularProgressIndicator` cho phần tương ứng.
3. WHEN `AppointmentProvider.appointments` rỗng, THE **ScheduleScreen** SHALL hiển thị thông báo "Chưa có lịch khám nào." thay vì danh sách rỗng.
4. WHEN `AppointmentProvider.appointments` có dữ liệu, THE **ScheduleScreen** SHALL render danh sách `_AppointmentCard` với `title`, `doctorName`, và `date` được format từ `AppointmentModel`.
5. WHEN `HealthMetricProvider.latestMetric` là `null`, THE **ScheduleScreen** SHALL hiển thị `--` cho tất cả các chỉ số sức khỏe.
6. WHEN `HealthMetricProvider.latestMetric` có dữ liệu, THE **ScheduleScreen** SHALL hiển thị `bloodPressure`, `heartRate`, `bloodSugar`, `weight` từ `HealthMetricModel`.
7. WHEN `UserRepository.streamParentStatus` emit `UserModel` mới, THE **ScheduleScreen** SHALL hiển thị `name` và `status` của cha/mẹ trong thẻ trạng thái.
8. WHEN `UserModel.lastUpdated` có giá trị, THE **ScheduleScreen** SHALL hiển thị thời gian tương đối (ví dụ: "Cập nhật 5 phút trước") thay vì hardcode.
9. IF `AppointmentProvider.errorMessage` không null, THEN THE **ScheduleScreen** SHALL hiển thị thông báo lỗi thân thiện cho người dùng.

---

### Yêu cầu 8: Tính toàn vẹn dữ liệu và round-trip serialization

**User Story:** Là developer, tôi muốn đảm bảo các model mới serialize/deserialize chính xác, để dữ liệu không bị mất hoặc biến đổi khi đọc/ghi Firestore.

#### Tiêu chí chấp nhận

1. FOR ALL `AppointmentModel` hợp lệ, việc gọi `fromFirestore` rồi `toMap()` SHALL trả về map tương đương với dữ liệu gốc (ngoại trừ field `id`).
2. FOR ALL `HealthMetricModel` hợp lệ, việc gọi `fromFirestore` rồi `toMap()` SHALL trả về map tương đương với dữ liệu gốc (ngoại trừ field `id`).
3. FOR ALL `UserModel` sau khi thêm field `status` và `lastUpdated`, việc gọi `fromFirestore` rồi `toMap()` SHALL bảo toàn giá trị `status` (ngoại trừ `id` và `lastUpdated` vì đây là server-managed field).
4. WHEN `AppointmentModel.fromFirestore` nhận document với map rỗng, THE **AppointmentModel** SHALL không ném exception và SHALL trả về model với giá trị mặc định.
5. WHEN `HealthMetricModel.fromFirestore` nhận document với map rỗng, THE **HealthMetricModel** SHALL không ném exception và SHALL trả về model với giá trị mặc định.
