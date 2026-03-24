const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Cloud Function chạy mỗi 5 phút để kiểm tra missed medications và appointments
 * Tạo alerts tự động cho child users
 */
exports.checkMissedTasks = functions.pubsub
  .schedule('every 5 minutes')
  .timeZone('Asia/Ho_Chi_Minh')
  .onRun(async (context) => {
    console.log('Starting missed tasks check...');
    
    try {
      await checkMissedMedications();
      await checkMissedAppointments();
      console.log('Missed tasks check completed successfully');
    } catch (error) {
      console.error('Error checking missed tasks:', error);
    }
    
    return null;
  });

/**
 * Kiểm tra thuốc bị bỏ lỡ
 */
async function checkMissedMedications() {
  const db = admin.firestore();
  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const todayEnd = new Date(todayStart);
  todayEnd.setDate(todayEnd.getDate() + 1);

  // Lấy tất cả medications
  const medicationsSnapshot = await db.collection('medications').get();
  
  console.log(`Checking ${medicationsSnapshot.size} medications...`);

  for (const medDoc of medicationsSnapshot.docs) {
    const medData = medDoc.data();
    const medId = medDoc.id;
    const medName = medData.name || 'Thuốc';
    const medTime = medData.time || '00:00';
    const parentId = medData.parentId;

    if (!parentId) continue;

    // Parse thời gian thuốc
    const timeParts = medTime.split(':');
    if (timeParts.length !== 2) continue;
    
    const hour = parseInt(timeParts[0]);
    const minute = parseInt(timeParts[1]);
    const scheduledTime = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute);

    // Chỉ kiểm tra nếu đã quá giờ ít nhất 30 phút
    const missedThreshold = new Date(scheduledTime);
    missedThreshold.setMinutes(missedThreshold.getMinutes() + 30);
    
    if (now < missedThreshold) {
      continue;
    }

    // Kiểm tra xem đã có check-in chưa
    const checkInSnapshot = await db.collection('checkIns')
      .where('medicationId', '==', medId)
      .where('parentId', '==', parentId)
      .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(todayStart))
      .where('timestamp', '<', admin.firestore.Timestamp.fromDate(todayEnd))
      .limit(1)
      .get();

    if (checkInSnapshot.empty) {
      // Chưa có check-in, tìm child user để gửi alert
      const childUser = await findChildUserByParentId(parentId);
      
      if (childUser) {
        // Kiểm tra xem đã tạo alert chưa
        const alertMessage = `Bố/Mẹ chưa uống "${medName}" lúc ${medTime}`;
        const existingAlertSnapshot = await db.collection('alerts')
          .where('userId', '==', childUser.id)
          .where('type', '==', 'missed_medication')
          .where('message', '==', alertMessage)
          .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(todayStart))
          .limit(1)
          .get();

        if (existingAlertSnapshot.empty) {
          // Tạo alert mới
          await db.collection('alerts').add({
            userId: childUser.id,
            type: 'missed_medication',
            title: 'Bỏ lỡ uống thuốc',
            message: alertMessage,
            isRead: false,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          });
          console.log(`Created missed medication alert for ${medName}`);
        }
      }
    }
  }
}

/**
 * Kiểm tra lịch khám bị bỏ lỡ
 */
async function checkMissedAppointments() {
  const db = admin.firestore();
  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());

  // Lấy các appointments đã quá hạn nhưng chưa hoàn thành
  const appointmentsSnapshot = await db.collection('appointments')
    .where('status', '==', 'pending')
    .get();

  console.log(`Checking ${appointmentsSnapshot.size} appointments...`);

  for (const apptDoc of appointmentsSnapshot.docs) {
    const apptData = apptDoc.data();
    const apptTitle = apptData.title || 'Lịch khám';
    const apptDate = apptData.date?.toDate();
    const parentId = apptData.parentId;

    if (!apptDate || !parentId) continue;

    // Chỉ kiểm tra nếu đã quá hạn ít nhất 1 giờ
    const missedThreshold = new Date(apptDate);
    missedThreshold.setHours(missedThreshold.getHours() + 1);
    
    if (now < missedThreshold) {
      continue;
    }

    // Tìm child user để gửi alert
    const childUser = await findChildUserByParentId(parentId);
    
    if (childUser) {
      // Kiểm tra xem đã tạo alert chưa
      const alertMessage = `Bố/Mẹ chưa đi khám "${apptTitle}"`;
      const existingAlertSnapshot = await db.collection('alerts')
        .where('userId', '==', childUser.id)
        .where('type', '==', 'missed_appointment')
        .where('message', '==', alertMessage)
        .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(todayStart))
        .limit(1)
        .get();

      if (existingAlertSnapshot.empty) {
        // Tạo alert mới
        await db.collection('alerts').add({
          userId: childUser.id,
          type: 'missed_appointment',
          title: 'Bỏ lỡ lịch khám',
          message: alertMessage,
          isRead: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Created missed appointment alert for ${apptTitle}`);
      }
    }
  }
}

/**
 * Tìm child user dựa trên parentId
 * Logic: parentId trong medications/appointments chính là childId
 * Nhưng cần tìm child user có role='child' để gửi alert
 */
async function findChildUserByParentId(parentId) {
  const db = admin.firestore();
  
  // parentId trong system này chính là childId
  // Kiểm tra xem có user nào với uid = parentId và role = 'child'
  const userDoc = await db.collection('users').doc(parentId).get();
  
  if (userDoc.exists && userDoc.data().role === 'child') {
    return { id: userDoc.id, ...userDoc.data() };
  }
  
  // Nếu không tìm thấy, tìm parent user có parentId field = parentId này
  // Rồi lấy child từ đó
  const parentSnapshot = await db.collection('users')
    .where('parentId', '==', parentId)
    .where('role', '==', 'parent')
    .limit(1)
    .get();
  
  if (!parentSnapshot.empty) {
    // Có parent liên kết, parentId chính là childId
    const childDoc = await db.collection('users').doc(parentId).get();
    if (childDoc.exists) {
      return { id: childDoc.id, ...childDoc.data() };
    }
  }
  
  return null;
}

/**
 * Trigger khi có check-in mới được tạo
 * Tự động xóa alert missed_medication tương ứng nếu có
 */
exports.onCheckInCreated = functions.firestore
  .document('checkIns/{checkInId}')
  .onCreate(async (snap, context) => {
    const checkInData = snap.data();
    const medicationId = checkInData.medicationId;
    const parentId = checkInData.parentId;
    
    if (!medicationId || !parentId) return null;
    
    try {
      // Lấy thông tin medication
      const medDoc = await admin.firestore()
        .collection('medications')
        .doc(medicationId)
        .get();
      
      if (!medDoc.exists) return null;
      
      const medData = medDoc.data();
      const medName = medData.name || 'Thuốc';
      const medTime = medData.time || '00:00';
      
      // Tìm child user
      const childUser = await findChildUserByParentId(parentId);
      
      if (childUser) {
        // Xóa alert missed_medication tương ứng
        const alertMessage = `Bố/Mẹ chưa uống "${medName}" lúc ${medTime}`;
        const alertsSnapshot = await admin.firestore()
          .collection('alerts')
          .where('userId', '==', childUser.id)
          .where('type', '==', 'missed_medication')
          .where('message', '==', alertMessage)
          .where('isRead', '==', false)
          .get();
        
        const batch = admin.firestore().batch();
        alertsSnapshot.docs.forEach(doc => {
          batch.update(doc.ref, { isRead: true });
        });
        await batch.commit();
        
        console.log(`Auto-dismissed missed medication alert for ${medName}`);
      }
    } catch (error) {
      console.error('Error in onCheckInCreated:', error);
    }
    
    return null;
  });

/**
 * Trigger khi appointment được cập nhật thành completed
 * Tự động xóa alert missed_appointment tương ứng nếu có
 */
exports.onAppointmentUpdated = functions.firestore
  .document('appointments/{appointmentId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    
    // Chỉ xử lý khi status chuyển sang completed
    if (beforeData.status !== 'completed' && afterData.status === 'completed') {
      const apptTitle = afterData.title || 'Lịch khám';
      const parentId = afterData.parentId;
      
      if (!parentId) return null;
      
      try {
        // Tìm child user
        const childUser = await findChildUserByParentId(parentId);
        
        if (childUser) {
          // Xóa alert missed_appointment tương ứng
          const alertMessage = `Bố/Mẹ chưa đi khám "${apptTitle}"`;
          const alertsSnapshot = await admin.firestore()
            .collection('alerts')
            .where('userId', '==', childUser.id)
            .where('type', '==', 'missed_appointment')
            .where('message', '==', alertMessage)
            .where('isRead', '==', false)
            .get();
          
          const batch = admin.firestore().batch();
          alertsSnapshot.docs.forEach(doc => {
            batch.update(doc.ref, { isRead: true });
          });
          await batch.commit();
          
          console.log(`Auto-dismissed missed appointment alert for ${apptTitle}`);
        }
      } catch (error) {
        console.error('Error in onAppointmentUpdated:', error);
      }
    }
    
    return null;
  });
