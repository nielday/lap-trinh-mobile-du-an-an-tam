import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service để giám sát và tạo alerts tự động khi phát hiện missed medications/appointments
class AlertMonitoringService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Timer? _monitoringTimer;
  String? _currentParentId;
  String? _currentChildId;

  /// Bắt đầu giám sát cho một cặp parent-child
  void startMonitoring({required String parentId, required String childId}) {
    if (_currentParentId == parentId && _currentChildId == childId) {
      return; // Đã đang monitor rồi
    }

    stopMonitoring();
    
    _currentParentId = parentId;
    _currentChildId = childId;

    // Kiểm tra ngay lập tức
    _checkForMissedTasks();

    // Sau đó kiểm tra mỗi 5 phút
    _monitoringTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkForMissedTasks(),
    );

    debugPrint('AlertMonitoringService: Started monitoring for parent=$parentId, child=$childId');
  }

  /// Dừng giám sát
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _currentParentId = null;
    _currentChildId = null;
    debugPrint('AlertMonitoringService: Stopped monitoring');
  }

  /// Kiểm tra các công việc bị bỏ lỡ
  Future<void> _checkForMissedTasks() async {
    if (_currentParentId == null || _currentChildId == null) return;

    try {
      await _checkMissedMedications();
      await _checkMissedAppointments();
    } catch (e) {
      debugPrint('AlertMonitoringService: Error checking missed tasks: $e');
    }
  }

  /// Kiểm tra thuốc bị bỏ lỡ
  Future<void> _checkMissedMedications() async {
    final parentId = _currentParentId!;
    final childId = _currentChildId!;

    // Lấy tất cả medications của parent
    final medsSnapshot = await _db
        .collection('medications')
        .where('parentId', isEqualTo: parentId)
        .get();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    for (final medDoc in medsSnapshot.docs) {
      final medId = medDoc.id;
      final medData = medDoc.data();
      final medName = medData['name'] as String? ?? 'Thuốc';
      final medTime = medData['time'] as String? ?? '00:00';

      // Parse thời gian thuốc
      final timeParts = medTime.split(':');
      if (timeParts.length != 2) continue;
      
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

      // Chỉ kiểm tra nếu đã quá giờ ít nhất 30 phút
      if (now.isBefore(scheduledTime.add(const Duration(minutes: 30)))) {
        continue;
      }

      // Kiểm tra xem đã có check-in chưa
      final checkInSnapshot = await _db
          .collection('checkIns')
          .where('medicationId', isEqualTo: medId)
          .where('parentId', isEqualTo: parentId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('timestamp', isLessThan: Timestamp.fromDate(todayEnd))
          .limit(1)
          .get();

      if (checkInSnapshot.docs.isEmpty) {
        // Chưa có check-in, kiểm tra xem đã tạo alert chưa
        final existingAlertSnapshot = await _db
            .collection('alerts')
            .where('userId', isEqualTo: childId)
            .where('type', isEqualTo: 'missed_medication')
            .where('message', isEqualTo: 'Bố/Mẹ chưa uống "$medName" lúc $medTime')
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
            .limit(1)
            .get();

        if (existingAlertSnapshot.docs.isEmpty) {
          // Tạo alert mới
          await _createMissedMedicationAlert(
            childId: childId,
            medicationName: medName,
            scheduledTime: medTime,
          );
        }
      }
    }
  }

  /// Kiểm tra lịch khám bị bỏ lỡ
  Future<void> _checkMissedAppointments() async {
    final parentId = _currentParentId!;
    final childId = _currentChildId!;

    final now = DateTime.now();

    // Lấy các appointments đã quá hạn nhưng chưa hoàn thành
    final apptsSnapshot = await _db
        .collection('appointments')
        .where('parentId', isEqualTo: parentId)
        .where('status', isEqualTo: 'pending')
        .get();

    for (final apptDoc in apptsSnapshot.docs) {
      final apptData = apptDoc.data();
      final apptTitle = apptData['title'] as String? ?? 'Lịch khám';
      final apptDate = (apptData['date'] as Timestamp?)?.toDate();

      if (apptDate == null) continue;

      // Chỉ kiểm tra nếu đã quá hạn ít nhất 1 giờ
      if (now.isBefore(apptDate.add(const Duration(hours: 1)))) {
        continue;
      }

      // Kiểm tra xem đã tạo alert chưa
      final todayStart = DateTime(now.year, now.month, now.day);
      final existingAlertSnapshot = await _db
          .collection('alerts')
          .where('userId', isEqualTo: childId)
          .where('type', isEqualTo: 'missed_appointment')
          .where('message', isEqualTo: 'Bố/Mẹ chưa đi khám "$apptTitle"')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .limit(1)
          .get();

      if (existingAlertSnapshot.docs.isEmpty) {
        // Tạo alert mới
        await _createMissedAppointmentAlert(
          childId: childId,
          appointmentTitle: apptTitle,
          scheduledDate: apptDate,
        );
      }
    }
  }

  /// Tạo alert cho thuốc bị bỏ lỡ
  Future<void> _createMissedMedicationAlert({
    required String childId,
    required String medicationName,
    required String scheduledTime,
  }) async {
    try {
      await _db.collection('alerts').add({
        'userId': childId,
        'type': 'missed_medication',
        'title': 'Bỏ lỡ uống thuốc',
        'message': 'Bố/Mẹ chưa uống "$medicationName" lúc $scheduledTime',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('AlertMonitoringService: Created missed medication alert for $medicationName');
    } catch (e) {
      debugPrint('AlertMonitoringService: Error creating missed medication alert: $e');
    }
  }

  /// Tạo alert cho lịch khám bị bỏ lỡ
  Future<void> _createMissedAppointmentAlert({
    required String childId,
    required String appointmentTitle,
    required DateTime scheduledDate,
  }) async {
    try {
      await _db.collection('alerts').add({
        'userId': childId,
        'type': 'missed_appointment',
        'title': 'Bỏ lỡ lịch khám',
        'message': 'Bố/Mẹ chưa đi khám "$appointmentTitle"',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('AlertMonitoringService: Created missed appointment alert for $appointmentTitle');
    } catch (e) {
      debugPrint('AlertMonitoringService: Error creating missed appointment alert: $e');
    }
  }

  void dispose() {
    stopMonitoring();
  }
}
