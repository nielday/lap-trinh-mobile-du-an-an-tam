import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  final String id;
  final String parentId;
  final String childId;
  final String name;
  final String time; // 'HH:mm'
  final String frequency; // 'daily' | 'weekly' | ...
  final int dosage;
  final bool isActive;
  final String type; // 'Thuốc' | 'Bữa ăn' | 'Hoạt động'
  final DateTime? createdAt;

  const MedicationModel({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.name,
    required this.time,
    required this.frequency,
    required this.dosage,
    required this.isActive,
    this.type = 'Thuốc',
    this.createdAt,
  });

  factory MedicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MedicationModel(
      id: doc.id,
      parentId: data['parentId'] as String? ?? '',
      childId: data['childId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      time: data['time'] as String? ?? '08:00',
      frequency: data['frequency'] as String? ?? 'daily',
      dosage: (data['dosage'] as num?)?.toInt() ?? 1,
      isActive: data['isActive'] as bool? ?? true,
      type: data['type'] as String? ?? 'Thuốc',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'parentId': parentId,
        'childId': childId,
        'name': name,
        'time': time,
        'frequency': frequency,
        'dosage': dosage,
        'isActive': isActive,
        'type': type,
      };
}
