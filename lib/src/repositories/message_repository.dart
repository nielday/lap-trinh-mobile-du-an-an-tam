import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/exceptions.dart';
import '../models/message_model.dart';

class MessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _messages => _db.collection('messages');

  Stream<List<MessageModel>> getMessages(String userId1, String userId2) {
    // Lấy tất cả messages liên quan đến cặp user này
    // Dùng composite query: lọc theo senderId rồi merge
    final sentStream = _messages
        .where('senderId', isEqualTo: userId1)
        .where('receiverId', isEqualTo: userId2)
        .snapshots();

    return sentStream.asyncMap((sentSnap) async {
      final receivedSnap = await _messages
          .where('senderId', isEqualTo: userId2)
          .where('receiverId', isEqualTo: userId1)
          .get();

      final allDocs = <String, DocumentSnapshot>{};
      for (final doc in sentSnap.docs) {
        allDocs[doc.id] = doc;
      }
      for (final doc in receivedSnap.docs) {
        allDocs[doc.id] = doc;
      }

      final result = allDocs.values
          .map((d) => MessageModel.fromFirestore(d))
          .toList()
        ..sort((a, b) {
          final ta = a.timestamp ?? DateTime(0);
          final tb = b.timestamp ?? DateTime(0);
          return ta.compareTo(tb); // tăng dần
        });

      return result;
    }).handleError((e) {
      debugPrint('getMessages error: $e');
    });
  }

  Future<void> sendMessage(MessageModel message) async {
    if (message.text.trim().isEmpty) {
      throw const ValidationException('Nội dung tin nhắn không được để trống');
    }

    try {
      await _messages.add({
        ...message.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi gửi tin nhắn: ${e.message}');
    }
  }
}
