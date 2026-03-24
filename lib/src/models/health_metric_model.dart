import 'package:cloud_firestore/cloud_firestore.dart';

class HealthMetricModel {
  final String id;
  final String parentId;
  final String bloodPressure;
  final int heartRate;
  final int bloodSugar;
  final double weight;
  final DateTime? recordedAt;

  const HealthMetricModel({
    required this.id,
    required this.parentId,
    required this.bloodPressure,
    required this.heartRate,
    required this.bloodSugar,
    required this.weight,
    this.recordedAt,
  });

  factory HealthMetricModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HealthMetricModel(
      id: doc.id,
      parentId: data['parentId'] as String? ?? '',
      bloodPressure: data['bloodPressure'] as String? ?? '',
      heartRate: (data['heartRate'] as num?)?.toInt() ?? 0,
      bloodSugar: (data['bloodSugar'] as num?)?.toInt() ?? 0,
      weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
      recordedAt: (data['recordedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'parentId': parentId,
        'bloodPressure': bloodPressure,
        'heartRate': heartRate,
        'bloodSugar': bloodSugar,
        'weight': weight,
      };
}
