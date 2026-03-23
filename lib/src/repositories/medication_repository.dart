import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/exceptions.dart';
import '../models/check_in_model.dart';
import '../models/medication_model.dart';

class MedicationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _medications => _db.collection('medications');
  CollectionReference get _checkIns => _db.collection('checkIns');

  Future<String> createMedication(MedicationModel medication) async {
    try {
      final doc = await _medications.add({
        ...medication.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi tạo lịch thuốc: ${e.message}');
    }
  }

  Stream<List<MedicationModel>> getMedicationsForParent(String parentId) {
    return _medications
        .where('parentId', isEqualTo: parentId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => MedicationModel.fromFirestore(d)).toList();
          list.sort((a, b) => a.time.compareTo(b.time));
          return list;
        })
        .handleError((e) {
      debugPrint('getMedicationsForParent error: $e');
      throw e;
    });
  }

  Future<void> updateMedication(
      String id, Map<String, dynamic> data) async {
    try {
      await _medications.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi cập nhật lịch thuốc: ${e.message}');
    }
  }

  Future<void> deactivateMedication(String id) async {
    await updateMedication(id, {'isActive': false});
  }

  Future<void> deleteMedication(String id) async {
    try {
      await _medications.doc(id).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi xóa lịch thuốc: ${e.message}');
    }
  }

  Future<void> createCheckIn(CheckInModel checkIn) async {
    try {
      await _checkIns.add({
        ...checkIn.toMap(),
        'timestamp': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi tạo check-in: ${e.message}');
    }
  }

  Stream<List<CheckInModel>> getTodayCheckIns(String parentId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _checkIns
        .where('parentId', isEqualTo: parentId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CheckInModel.fromFirestore(d)).toList())
        .handleError((e) {
      debugPrint('getTodayCheckIns error: $e');
      throw e;
    });
  }

  /// Lấy check-ins trong tháng hiện tại để tính compliance rate
  Stream<List<CheckInModel>> getMonthCheckIns(String parentId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _checkIns
        .where('parentId', isEqualTo: parentId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CheckInModel.fromFirestore(d)).toList())
        .handleError((e) {
      debugPrint('getMonthCheckIns error: $e');
      throw e;
    });
  }
}
