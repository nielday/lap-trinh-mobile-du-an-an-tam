import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyLinkModel {
  final String id;
  final String childId;
  final String parentId;
  final String status; // 'pending' | 'active'

  const FamilyLinkModel({
    required this.id,
    required this.childId,
    required this.parentId,
    required this.status,
  });

  factory FamilyLinkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FamilyLinkModel(
      id: doc.id,
      childId: data['childId'] as String? ?? '',
      parentId: data['parentId'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() => {
        'childId': childId,
        'parentId': parentId,
        'status': status,
      };
}
