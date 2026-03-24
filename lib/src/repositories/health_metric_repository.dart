import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/exceptions.dart';
import '../models/health_metric_model.dart';

class HealthMetricRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _metrics => _db.collection('health_metrics');

  Stream<HealthMetricModel?> streamLatestMetric(String parentId) {
    return _metrics
        .where('parentId', isEqualTo: parentId)
        .orderBy('recordedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return HealthMetricModel.fromFirestore(snap.docs.first);
        })
        .handleError((e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        throw const PermissionDeniedException();
      }
      throw e;
    });
  }

  Future<String> createMetric(HealthMetricModel metric) async {
    try {
      final ref = await _metrics.add({
        ...metric.toMap(),
        'recordedAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi tạo chỉ số sức khỏe: ${e.message}');
    }
  }
}
