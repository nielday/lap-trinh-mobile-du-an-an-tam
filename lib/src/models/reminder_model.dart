import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String content;
  final DateTime? timestamp;

  const ReminderModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    this.timestamp,
  });

  factory ReminderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReminderModel(
      id: doc.id,
      fromUserId: data['fromUserId'] as String? ?? '',
      toUserId: data['toUserId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'content': content,
      };
}
