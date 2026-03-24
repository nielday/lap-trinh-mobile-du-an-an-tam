# Tài liệu Thiết kế: Schedule Health Data

## Tổng quan

Feature này mở rộng data layer của ứng dụng Flutter "An Tâm" để thay thế toàn bộ dữ liệu hardcode trong `ScheduleScreen` bằng dữ liệu thật từ Firestore. Ba luồng dữ liệu mới được thêm vào:

1. **Trạng thái cha/mẹ** — mở rộng `UserModel` với `status` + `lastUpdated`, thêm `streamParentStatus` vào `UserRepository`.
2. **Lịch khám** — `AppointmentModel` + `AppointmentRepository` + `AppointmentProvider` từ collection `appointments`.
3. **Chỉ số sức khỏe** — `HealthMetricModel` + `HealthMetricRepository` + `HealthMetricProvider` từ collection `health_metrics`.

Kiến trúc tuân theo pattern đã có trong dự án: `Models (fromFirestore/toMap)` → `Repositories (stream-based, FirebaseException → domain exception)` → `Providers (ChangeNotifier, updateUser, StreamSubscription)` → `UI (ChangeNotifierProxyProvider)`.

---

## Kiến trúc

```mermaid
graph TD
    FS[(Firestore)]
    FS -->|users/{parentId}| UR[UserRepository]
    FS -->|appointments| AR[AppointmentRepository]
    FS -->|health_metrics| HR[HealthMetricRepository]

    UR -->|Stream<UserModel>| SS[ScheduleScreen]
    AR --> AP[AppointmentProvider]
    HR --> HP[HealthMetricProvider]

    AP -->|ChangeNotifierProxyProvider| SS
    HP -->|ChangeNotifierProxyProvider| SS

    AUTH[AuthProvider] -->|parentId| AP
    AUTH -->|parentId| HP

    subgraph main.dart
        AUTH
        AP
        HP
    end
```

Luồng dữ liệu:
- `AuthProvider` cung cấp `parentId` → `ChangeNotifierProxyProvider` gọi `updateUser(parentId:)` trên mỗi Provider.
- Mỗi Provider subscribe stream từ Repository tương ứng, cập nhật state và gọi `notifyListeners()`.
- `ScheduleScreen` dùng `context.watch` để rebuild khi state thay đổi.
- `UserRepository.streamParentStatus` được consume trực tiếp tại `ScheduleScreen` qua `StreamBuilder` (không cần Provider riêng vì chỉ dùng ở một nơi).

---

## Components và Interfaces

### UserModel (mở rộng)

Thêm hai field mới vào model hiện có:

```dart
final String status;       // '' mặc định
final DateTime? lastUpdated;
```

`fromFirestore` đọc thêm `status` và `lastUpdated` (Timestamp → DateTime).  
`toMap()` thêm `status`; `lastUpdated` không đưa vào map vì là server-managed field.

### AppointmentModel

```dart
class AppointmentModel {
  final String id;
  final String parentId;
  final String title;
  final String doctorName;
  final DateTime date;
  final String type;

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toMap(); // date → Timestamp, không có id
}
```

### HealthMetricModel

```dart
class HealthMetricModel {
  final String id;
  final String parentId;
  final String bloodPressure;  // '120/80'
  final int heartRate;
  final int bloodSugar;
  final double weight;
  final DateTime? recordedAt;

  factory HealthMetricModel.fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toMap(); // không có id
}
```

### AppointmentRepository

```dart
class AppointmentRepository {
  Stream<List<AppointmentModel>> getUpcomingAppointments(String parentId);
  Future<String> createAppointment(AppointmentModel appointment);
}
```

Query `getUpcomingAppointments`: `where('parentId', ==, parentId)`, `where('date', >=, DateTime.now())`, `orderBy('date')`.

### HealthMetricRepository

```dart
class HealthMetricRepository {
  Stream<HealthMetricModel?> streamLatestMetric(String parentId);
  Future<String> createMetric(HealthMetricModel metric);
}
```

Query `streamLatestMetric`: `where('parentId', ==, parentId)`, `orderBy('recordedAt', descending: true)`, `limit(1)`. Emit `null` khi snapshot rỗng.

### UserRepository (mở rộng)

```dart
Stream<UserModel> streamParentStatus(String parentId);
```

Lắng nghe `users/{parentId}` real-time. Emit `UserNotFoundException` nếu document không tồn tại, `PermissionDeniedException` nếu lỗi `permission-denied`.

### AppointmentProvider

```dart
class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> appointments;
  bool isLoading;
  String? errorMessage;

  void updateUser({String? parentId});
  @override void dispose();
}
```

### HealthMetricProvider

```dart
class HealthMetricProvider extends ChangeNotifier {
  HealthMetricModel? latestMetric;
  bool isLoading;
  String? errorMessage;

  void updateUser({String? parentId});
  @override void dispose();
}
```

### ScheduleScreen (cập nhật)

- Thêm `context.watch<AppointmentProvider>()` và `context.watch<HealthMetricProvider>()`.
- Thêm `StreamBuilder<UserModel>` cho thẻ trạng thái cha/mẹ (dùng `UserRepository` inject qua `context.read<UserRepository>()`).
- Thay thế hardcode bằng dữ liệu thật, hiển thị `--` khi `latestMetric == null`.
- Hiển thị thời gian tương đối từ `lastUpdated` (ví dụ: "Cập nhật 5 phút trước").

---

## Data Models

### Firestore Collection: `users`

| Field         | Type      | Mô tả                              |
|---------------|-----------|------------------------------------|
| name          | String    | Tên người dùng                     |
| email         | String    | Email                              |
| role          | String    | 'child' hoặc 'parent'              |
| parentId      | String?   | ID cha/mẹ liên kết (chỉ child)     |
| status        | String    | Trạng thái hiện tại (mới thêm)     |
| lastUpdated   | Timestamp | Thời điểm cập nhật trạng thái (mới)|
| createdAt     | Timestamp | Thời điểm tạo tài khoản            |

### Firestore Collection: `appointments`

| Field      | Type      | Mô tả                          |
|------------|-----------|--------------------------------|
| parentId   | String    | ID cha/mẹ sở hữu lịch khám     |
| title      | String    | Tên lịch khám                  |
| doctorName | String    | Tên bác sĩ                     |
| date       | Timestamp | Ngày giờ khám                  |
| type       | String    | Loại khám (ví dụ: 'general')   |

Index Firestore cần thiết: `parentId ASC, date ASC`.

### Firestore Collection: `health_metrics`

| Field         | Type      | Mô tả                          |
|---------------|-----------|--------------------------------|
| parentId      | String    | ID cha/mẹ                      |
| bloodPressure | String    | Huyết áp, ví dụ '120/80'       |
| heartRate     | int       | Nhịp tim (bpm)                 |
| bloodSugar    | int       | Đường huyết (mg/dL)            |
| weight        | double    | Cân nặng (kg)                  |
| recordedAt    | Timestamp | Thời điểm ghi nhận             |

Index Firestore cần thiết: `parentId ASC, recordedAt DESC`.

---

## Xử lý lỗi

| Tình huống | Hành vi |
|---|---|
| `permission-denied` từ Firestore | Repository throw/emit `PermissionDeniedException` |
| Document không tồn tại (`streamParentStatus`) | Repository emit `UserNotFoundException` |
| Field thiếu trong DocumentSnapshot | Model trả về giá trị mặc định, không throw |
| Stream lỗi trong Provider | Cập nhật `errorMessage`, `isLoading = false`, `notifyListeners()` |
| `latestMetric == null` | UI hiển thị `--` cho tất cả chỉ số |
| `appointments` rỗng | UI hiển thị "Chưa có lịch khám nào." |
| `errorMessage != null` | UI hiển thị thông báo lỗi thân thiện |

Các Provider không re-throw exception ra UI — lỗi được capture vào `errorMessage` để UI xử lý gracefully.

---

## Chiến lược kiểm thử

### Unit Tests (ví dụ cụ thể và edge cases)

- `AppointmentModel.fromFirestore` với document đầy đủ → kiểm tra từng field.
- `AppointmentModel.fromFirestore` với document rỗng → không throw, trả về defaults.
- `HealthMetricModel.fromFirestore` với document rỗng → không throw, trả về defaults.
- `UserModel.fromFirestore` với `status` và `lastUpdated` → ánh xạ đúng.
- `AppointmentProvider.updateUser(parentId: null)` → `appointments` rỗng, không subscribe.
- `HealthMetricProvider.updateUser(parentId: '')` → `latestMetric = null`, không subscribe.

### Property-Based Tests

Dùng thư viện [`fast_check`](https://pub.dev/packages/fast_check) (Dart). Mỗi property test chạy tối thiểu 100 iterations.

Tag format cho mỗi test: `// Feature: schedule-health-data, Property N: <mô tả>`


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: AppointmentModel round-trip serialization

*For any* valid `AppointmentModel` (với mọi giá trị `title`, `doctorName`, `date`, `type`, `parentId`), việc gọi `toMap()` rồi dùng map đó để tạo lại model qua `fromFirestore` phải cho ra model có các field tương đương với model gốc (ngoại trừ `id`).

**Validates: Requirements 2.2, 2.4, 8.1**

---

### Property 2: HealthMetricModel round-trip serialization

*For any* valid `HealthMetricModel` (với mọi giá trị `bloodPressure`, `heartRate`, `bloodSugar`, `weight`, `parentId`), việc gọi `toMap()` rồi dùng map đó để tạo lại model qua `fromFirestore` phải cho ra model có các field tương đương với model gốc (ngoại trừ `id` và `recordedAt` vì là server-managed).

**Validates: Requirements 4.2, 4.4, 8.2**

---

### Property 3: UserModel.status round-trip serialization

*For any* `UserModel` với bất kỳ giá trị `status` nào (kể cả chuỗi rỗng), việc gọi `toMap()` rồi dùng map đó để tạo lại model qua `fromFirestore` phải bảo toàn giá trị `status` chính xác.

**Validates: Requirements 1.1, 1.3, 1.4, 8.3**

---

### Property 4: toMap không chứa document ID

*For any* `AppointmentModel`, `HealthMetricModel`, hoặc `UserModel`, kết quả của `toMap()` không được chứa key `'id'`.

**Validates: Requirements 1.4, 2.4, 4.4**

---

### Property 5: fromFirestore với map rỗng không ném exception

*For any* model trong số `AppointmentModel`, `HealthMetricModel`, `UserModel`, khi `fromFirestore` nhận một `DocumentSnapshot` với data là map rỗng `{}`, phải trả về model với giá trị mặc định mà không ném exception.

**Validates: Requirements 2.3, 4.3, 8.4, 8.5**

---

### Property 6: Format thời gian tương đối

*For any* `DateTime` trong quá khứ, hàm format thời gian tương đối phải trả về chuỗi không rỗng mô tả khoảng cách thời gian (ví dụ: "Cập nhật X phút trước", "Cập nhật X giờ trước"). Với `DateTime` càng gần hiện tại, giá trị số trong chuỗi phải nhỏ hơn hoặc bằng so với `DateTime` xa hơn.

**Validates: Requirements 7.8**

---

## Chiến lược kiểm thử (chi tiết)

### Unit Tests

Tập trung vào các ví dụ cụ thể và edge cases:

- `AppointmentModel.fromFirestore` với document đầy đủ → kiểm tra từng field mapping.
- `AppointmentModel.fromFirestore` với document rỗng → không throw, trả về defaults.
- `HealthMetricModel.fromFirestore` với document rỗng → không throw, trả về defaults.
- `UserModel.fromFirestore` với `status` và `lastUpdated` → ánh xạ đúng.
- `AppointmentProvider.updateUser(parentId: null)` → `appointments = []`, `isLoading = false`.
- `AppointmentProvider.updateUser(parentId: '')` → `appointments = []`, `isLoading = false`.
- `HealthMetricProvider.updateUser(parentId: null)` → `latestMetric = null`, `isLoading = false`.
- `AppointmentProvider` nhận stream data → cập nhật `appointments`, `isLoading = false`.
- `AppointmentProvider` nhận stream error → cập nhật `errorMessage`, `isLoading = false`.
- `HealthMetricProvider` nhận `null` từ stream → `latestMetric = null`, `isLoading = false`.
- `UserRepository.streamParentStatus` với document không tồn tại → emit `UserNotFoundException`.

### Property-Based Tests

Dùng thư viện [`fast_check`](https://pub.dev/packages/fast_check) cho Dart. Mỗi property test chạy tối thiểu **100 iterations**.

Tag format: `// Feature: schedule-health-data, Property N: <mô tả>`

| Property | Test | Generator |
|---|---|---|
| P1 | AppointmentModel round-trip | Random String cho title/doctorName/type, random DateTime cho date |
| P2 | HealthMetricModel round-trip | Random String cho bloodPressure, random int cho heartRate/bloodSugar, random double cho weight |
| P3 | UserModel.status round-trip | Random String cho status (kể cả rỗng, unicode) |
| P4 | toMap không chứa id | Random model instances |
| P5 | fromFirestore với map rỗng | Fixed input (map rỗng) — chạy 1 lần nhưng đặt trong property test framework |
| P6 | Format thời gian tương đối | Random DateTime trong khoảng [1 phút, 1 năm] trước hiện tại |

Mỗi correctness property trong tài liệu này phải được implement bởi **đúng một** property-based test.
