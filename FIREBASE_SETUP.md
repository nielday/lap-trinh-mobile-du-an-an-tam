# Firebase Setup Guide - An Tâm

## Bước 1: Chuẩn bị file google-services.json

Bạn đã có file `google-services.json` từ Firebase Console. Hãy đặt nó vào:
```
android/app/google-services.json
```

## Bước 2: Cài đặt dependencies

Chạy lệnh sau để cài đặt các package Firebase:
```bash
flutter pub get
```

## Bước 3: Cấu trúc Firestore Database

Tạo các collections sau trong Firebase Console:

### Collection: `users`
```json
{
  "userId": {
    "name": "string",
    "email": "string",
    "role": "child | parent",
    "parentId": "string (optional)",
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  }
}
```

### Collection: `medications`
```json
{
  "medicationId": {
    "parentId": "string",
    "childId": "string",
    "name": "string",
    "time": "string (HH:mm)",
    "frequency": "string (daily, weekly)",
    "dosage": "number",
    "isActive": "boolean",
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  }
}
```

### Collection: `checkIns`
```json
{
  "checkInId": {
    "medicationId": "string",
    "parentId": "string",
    "status": "completed | missed",
    "timestamp": "timestamp"
  }
}
```

### Collection: `alerts`
```json
{
  "alertId": {
    "userId": "string",
    "type": "sos | missed_medication | reminder",
    "title": "string",
    "message": "string",
    "metadata": "object (optional)",
    "isRead": "boolean",
    "timestamp": "timestamp",
    "readAt": "timestamp (optional)"
  }
}
```

### Collection: `reminders`
```json
{
  "reminderId": {
    "parentId": "string",
    "childId": "string",
    "title": "string",
    "description": "string",
    "dueDate": "timestamp",
    "isCompleted": "boolean",
    "createdAt": "timestamp"
  }
}
```

## Bước 4: Firestore Rules (Security)

Vào Firebase Console > Firestore Database > Rules và thêm:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
    
    // Medications collection
    match /medications/{medicationId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
    
    // CheckIns collection
    match /checkIns/{checkInId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
    }
    
    // Alerts collection
    match /alerts/{alertId} {
      allow read: if isAuthenticated() && 
                     resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
                       resource.data.userId == request.auth.uid;
    }
    
    // Reminders collection
    match /reminders/{reminderId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
  }
}
```

## Bước 5: Firebase Authentication Setup

1. Vào Firebase Console > Authentication
2. Bật các phương thức đăng nhập:
   - Email/Password
   - Google (optional)
   - Facebook (optional)

## Bước 6: Test kết nối

Chạy app:
```bash
flutter run
```

Kiểm tra console log để xem Firebase đã khởi tạo thành công:
```
Firebase initialized successfully
```

## Services đã tạo

### 1. FirebaseService
- `initialize()`: Khởi tạo Firebase

### 2. AuthService
- `signUpWithEmail()`: Đăng ký
- `signInWithEmail()`: Đăng nhập
- `signOut()`: Đăng xuất
- `sendPasswordResetEmail()`: Quên mật khẩu
- `getErrorMessage()`: Lấy thông báo lỗi tiếng Việt

### 3. FirestoreService
- `createUserProfile()`: Tạo profile người dùng
- `getUserProfile()`: Lấy thông tin người dùng
- `createMedication()`: Tạo lịch uống thuốc
- `getMedicationsForParent()`: Lấy danh sách thuốc
- `createCheckIn()`: Tạo check-in
- `getTodayCheckIns()`: Lấy check-in hôm nay
- `createAlert()`: Tạo cảnh báo
- `getUnreadAlerts()`: Lấy cảnh báo chưa đọc
- `markAlertAsRead()`: Đánh dấu đã đọc

## Sử dụng trong code

```dart
// Authentication
final authService = AuthService();
await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

// Firestore
final firestoreService = FirestoreService();
await firestoreService.createUserProfile(
  userId: 'user123',
  name: 'Nguyễn Văn A',
  email: 'user@example.com',
  role: 'child',
);
```

## Troubleshooting

### Lỗi: "Default FirebaseApp is not initialized"
- Kiểm tra file `google-services.json` đã đặt đúng vị trí
- Chạy `flutter clean` và `flutter pub get`

### Lỗi: "Multidex"
- Đã cấu hình `multiDexEnabled = true` trong build.gradle.kts

### Lỗi kết nối
- Kiểm tra internet
- Kiểm tra Firebase project đã enable các service chưa
