import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore database service
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get users => _db.collection('users');
  CollectionReference get medications => _db.collection('medications');
  CollectionReference get checkIns => _db.collection('checkIns');
  CollectionReference get alerts => _db.collection('alerts');
  CollectionReference get reminders => _db.collection('reminders');

  // Create user profile
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required String role, // 'child' or 'parent'
    String? parentId,
  }) async {
    try {
      await users.doc(userId).set({
        'name': name,
        'email': email,
        'role': role,
        'parentId': parentId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('User profile created: $userId');
    } catch (e) {
      debugPrint('Create user profile error: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<DocumentSnapshot> getUserProfile(String userId) async {
    try {
      return await users.doc(userId).get();
    } catch (e) {
      debugPrint('Get user profile error: $e');
      rethrow;
    }
  }

  // Create medication schedule
  Future<String> createMedication({
    required String parentId,
    required String childId,
    required String name,
    required String time,
    required String frequency,
    required int dosage,
  }) async {
    try {
      final doc = await medications.add({
        'parentId': parentId,
        'childId': childId,
        'name': name,
        'time': time,
        'frequency': frequency,
        'dosage': dosage,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Medication created: ${doc.id}');
      return doc.id;
    } catch (e) {
      debugPrint('Create medication error: $e');
      rethrow;
    }
  }

  // Get medications for parent
  Stream<QuerySnapshot> getMedicationsForParent(String parentId) {
    return medications
        .where('parentId', isEqualTo: parentId)
        .where('isActive', isEqualTo: true)
        .orderBy('time')
        .snapshots();
  }

  // Create check-in
  Future<void> createCheckIn({
    required String medicationId,
    required String parentId,
    required String status, // 'completed' or 'missed'
  }) async {
    try {
      await checkIns.add({
        'medicationId': medicationId,
        'parentId': parentId,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Check-in created for medication: $medicationId');
    } catch (e) {
      debugPrint('Create check-in error: $e');
      rethrow;
    }
  }

  // Get check-ins for today
  Stream<QuerySnapshot> getTodayCheckIns(String parentId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return checkIns
        .where('parentId', isEqualTo: parentId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Create alert
  Future<void> createAlert({
    required String userId,
    required String type, // 'sos', 'missed_medication', 'reminder'
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await alerts.add({
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        'metadata': metadata,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Alert created: $type for user $userId');
    } catch (e) {
      debugPrint('Create alert error: $e');
      rethrow;
    }
  }

  // Get unread alerts
  Stream<QuerySnapshot> getUnreadAlerts(String userId) {
    return alerts
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await alerts.doc(alertId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Mark alert as read error: $e');
      rethrow;
    }
  }
}
