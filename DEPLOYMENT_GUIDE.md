# HƯỚNG DẪN DEPLOY FIREBASE CLOUD FUNCTIONS

## 📋 Yêu cầu

1. **Node.js 18+** đã cài đặt
2. **Firebase CLI** đã cài đặt
   ```bash
   npm install -g firebase-tools
   ```
3. **Firebase project** đã được tạo và cấu hình

---

## 🚀 BƯỚC 1: Cài đặt Dependencies

```bash
cd functions
npm install
cd ..
```

---

## 🔐 BƯỚC 2: Đăng nhập Firebase

```bash
firebase login
```

---

## 🎯 BƯỚC 3: Chọn Firebase Project

```bash
firebase use --add
```

Chọn project của bạn từ danh sách.

---

## 📊 BƯỚC 4: Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

**Lưu ý**: Indexes có thể mất vài phút để build. Kiểm tra trạng thái tại:
https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore/indexes

---

## ☁️ BƯỚC 5: Deploy Cloud Functions

```bash
firebase deploy --only functions
```

**Functions sẽ được deploy:**
1. `checkMissedTasks` - Chạy mỗi 5 phút, kiểm tra missed medications/appointments
2. `onCheckInCreated` - Trigger khi có check-in mới, tự động dismiss alerts
3. `onAppointmentUpdated` - Trigger khi appointment completed, tự động dismiss alerts

---

## ✅ BƯỚC 6: Kiểm tra Deployment

### Xem logs realtime:
```bash
firebase functions:log
```

### Kiểm tra trong Firebase Console:
1. Mở https://console.firebase.google.com
2. Chọn project
3. Vào **Functions** → Xem danh sách functions đã deploy
4. Vào **Firestore** → **Indexes** → Xem indexes đang build

---

## 🧪 BƯỚC 7: Test Functions

### Test locally với emulator:
```bash
firebase emulators:start --only functions,firestore
```

### Test trên production:
1. Tạo medication với thời gian đã qua 30 phút
2. Không check-in
3. Đợi 5 phút
4. Kiểm tra collection `alerts` trong Firestore
5. Xem logs: `firebase functions:log`

---

## 📱 BƯỚC 8: Cập nhật App Flutter

### Xóa AlertMonitoringService khỏi app (không cần nữa):

File: `lib/src/features/home/presentation/child_home_screen.dart`

**XÓA:**
```dart
import '../../../services/alert_monitoring_service.dart';

final AlertMonitoringService _alertMonitoring = AlertMonitoringService();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _startMonitoring();
  });
}

void _startMonitoring() async {
  // ... code
}

@override
void dispose() {
  _alertMonitoring.dispose();
  super.dispose();
}
```

**GIỮ LẠI:**
- AlertProvider (vẫn cần để hiển thị alerts)
- UI hiển thị alerts

---

## 🔧 Troubleshooting

### Lỗi: "Billing account not configured"
**Giải pháp**: Firebase Cloud Functions yêu cầu Blaze plan (pay-as-you-go)
1. Vào https://console.firebase.google.com
2. Chọn project → **Upgrade to Blaze plan**
3. Thêm billing account

**Lưu ý**: Free tier rất hào phóng:
- 2 triệu function invocations/tháng miễn phí
- App này dùng ~8,640 invocations/tháng (mỗi 5 phút)
- Hoàn toàn trong free tier!

### Lỗi: "Index not found"
**Giải pháp**: Đợi indexes build xong (5-10 phút)
```bash
firebase deploy --only firestore:indexes
```

### Lỗi: "Permission denied"
**Giải pháp**: Kiểm tra Firestore Rules
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow Cloud Functions to read/write
    match /{document=**} {
      allow read, write: if request.auth != null || request.auth.token.admin == true;
    }
  }
}
```

---

## 📊 Monitoring

### Xem function execution:
```bash
firebase functions:log --only checkMissedTasks
```

### Xem metrics trong Console:
1. Firebase Console → Functions
2. Click vào function name
3. Xem **Invocations**, **Execution time**, **Errors**

---

## 💰 Chi phí ước tính

**Với app này:**
- checkMissedTasks: 12 lần/giờ × 24 giờ × 30 ngày = 8,640 invocations/tháng
- onCheckInCreated: ~100 invocations/tháng (ước tính)
- onAppointmentUpdated: ~20 invocations/tháng (ước tính)

**Tổng**: ~8,760 invocations/tháng

**Chi phí**: $0 (trong free tier 2 triệu invocations)

---

## 🎉 Hoàn thành!

Sau khi deploy xong:
1. ✅ Alerts tự động hoạt động 24/7
2. ✅ Không cần app mở
3. ✅ Tự động dismiss alerts khi hoàn thành
4. ✅ Performance tối ưu với indexes
5. ✅ Scalable và reliable

---

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra logs: `firebase functions:log`
2. Kiểm tra Firestore indexes: Firebase Console → Firestore → Indexes
3. Kiểm tra billing: Firebase Console → Settings → Usage and billing
