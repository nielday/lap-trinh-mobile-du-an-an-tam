import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/exceptions.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _appointments => _db.collection('appointments');

  Stream<List<AppointmentModel>> getUpcomingAppointments(String parentId) {
    return _appointments
        .where('parentId', isEqualTo: parentId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AppointmentModel.fromFirestore(d)).toList())
        .handleError((e) {
      debugPrint('getAppointments error: $e'); // Added debugPrint
      if (e is FirebaseException && e.code == 'permission-denied') {
        throw const PermissionDeniedException();
      }
      throw e;
    });
  }

  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      final ref = await _appointments.add(appointment.toMap());
      return ref.id;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi tạo lịch khám: ${e.message}');
    }
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    try {
      await _appointments.doc(id).update(data);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi cập nhật lịch khám: ${e.message}');
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      await _appointments.doc(id).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionDeniedException();
      throw Exception('Lỗi xóa lịch khám: ${e.message}');
    }
  }
}
