import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/exceptions.dart';
import '../models/reminder_model.dart';

class ReminderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _reminders => _db.collection('reminders');

  Stream<List<ReminderModel>> getRemindersForUser(String userId) {
    // Firestore không hỗ trợ OR query trực tiếp trên 2 fields khác nhau,
    // nên dùng 2 queries riêng và merge kết quả
    final fromStream = _reminders
        .where('fromUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    // Combine 2 streams bằng cách merge và deduplicate theo id
    return fromStream.asyncMap((fromSnap) async {
      final toSnap = await _reminders
          .where('toUserId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final allDocs = <String, DocumentSnapshot>{};
      for (final doc in fromSnap.docs) {
        allDocs[doc.id] = doc;
      }
      for (final doc in toSnap.docs) {
        allDocs[doc.id] = doc;
      }

      final result = allDocs.values
          .map((d) => ReminderModel.fromFirestore(d))
          .toList()
        ..sort((a, b) {
          final ta = a.timestamp ?? DateTime(0);
          final tb = b.timestamp ?? DateTime(0);
          return tb.compareTo(ta);
        });

      return result;
    }).handleError((e) {
      debugPrint('getRemindersForUser error: $e');
      throw e;
    });
  }

  Future<void> createReminder(ReminderModel reminder) async {
    try {
      await _reminders.add({
        ...reminder.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi tạo reminder: ${e.message}');
    }
  }

  Future<void> updateReminder(String id, String content) async {
    try {
      await _reminders.doc(id).update({'content': content});
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi cập nhật reminder: ${e.message}');
    }
  }

  Future<void> deleteReminder(String id, String requestingUserId) async {
    try {
      final doc = await _reminders.doc(id).get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      if (data['fromUserId'] != requestingUserId) {
        throw const PermissionDeniedException();
      }

      await _reminders.doc(id).delete();
    } on PermissionDeniedException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi xóa reminder: ${e.message}');
    }
  }
}
