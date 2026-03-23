import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInModel {
  final String id;
  final String medicationId;
  final String parentId;
  final String status; // 'completed' | 'missed'
  final DateTime? timestamp;

  const CheckInModel({
    required this.id,
    required this.medicationId,
    required this.parentId,
    required this.status,
    this.timestamp,
  });

  factory CheckInModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CheckInModel(
      id: doc.id,
      medicationId: data['medicationId'] as String? ?? '',
      parentId: data['parentId'] as String? ?? '',
      status: data['status'] as String? ?? 'missed',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'medicationId': medicationId,
        'parentId': parentId,
        'status': status,
      };
}
