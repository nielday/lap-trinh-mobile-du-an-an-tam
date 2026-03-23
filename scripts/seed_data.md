# Hướng dẫn tạo dữ liệu mẫu trên Firebase Console

## 1. Bật Authentication

Vào Firebase Console → Authentication → Sign-in method → Bật:
- Email/Password
- Google

## 2. Tạo Firestore Database

Vào Firebase Console → Firestore Database → Create database → Start in test mode

## 3. Cấu trúc Collections

### Collection: `users`
```
users/
  {userId}/
    name: "Nguyễn Văn A"
    email: "user@example.com"
    role: "child"          // hoặc "parent"
    parentId: "{parentUserId}"  // chỉ có nếu role = "child"
    createdAt: timestamp
    updatedAt: timestamp
```

### Collection: `medications`
```
medications/
  {medicationId}/
    parentId: "{parentUserId}"
    childId: "{childUserId}"
    name: "Thuốc huyết áp"
    time: "08:00"
    frequency: "daily"     // daily, weekly, custom
    dosage: 1              // số viên
    isActive: true
    createdAt: timestamp
    updatedAt: timestamp
```

### Collection: `checkIns`
```
checkIns/
  {checkInId}/
    medicationId: "{medicationId}"
    parentId: "{parentUserId}"
    status: "completed"    // hoặc "missed"
    timestamp: timestamp
```

### Collection: `alerts`
```
alerts/
  {alertId}/
    userId: "{userId}"
    type: "missed_medication"  // sos, missed_medication, reminder
    title: "Cảnh báo uống thuốc"
    message: "Chưa uống thuốc huyết áp buổi sáng"
    isRead: false
    timestamp: timestamp
```

### Collection: `reminders`
```
reminders/
  {reminderId}/
    fromUserId: "{parentUserId}"
    toUserId: "{childUserId}"
    title: "Nhắc nhở"
    message: "Con nhớ mua thuốc cho bố nhé"
    createdAt: timestamp
```

### Collection: `messages`
```
messages/
  {messageId}/
    senderId: "{userId}"
    receiverId: "{userId}"
    text: "Con ăn cơm chưa?"
    timestamp: timestamp
    isRead: false
```

### Collection: `familyLinks`
```
familyLinks/
  {linkId}/
    childId: "{childUserId}"
    parentId: "{parentUserId}"
    status: "active"
    createdAt: timestamp
```

## 4. Deploy Security Rules

Cài Firebase CLI:
```
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```
