import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/exceptions.dart';
import '../models/alert_model.dart';

class AlertRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _alerts => _db.collection('alerts');

  Stream<List<AlertModel>> getUnreadAlerts(String userId) {
    return _alerts
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AlertModel.fromFirestore(d)).toList())
        .handleError((e) {
      debugPrint('getAlertsForUser error: $e');
      throw e;
    });
  }

  Stream<int> getUnreadCount(String userId) {
    return getUnreadAlerts(userId).map((list) => list.length);
  }

  Future<void> markAsRead(String alertId, String userId) async {
    try {
      final doc = await _alerts.doc(alertId).get();
      if (!doc.exists) throw const UserNotFoundException('Không tìm thấy cảnh báo');

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) throw const PermissionDeniedException();

      await _alerts.doc(alertId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi đánh dấu đã đọc: ${e.message}');
    }
  }

  Future<void> createAlert(AlertModel alert) async {
    try {
      await _alerts.add({
        ...alert.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi tạo cảnh báo: ${e.message}');
    }
  }
}
