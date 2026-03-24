import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/check_in_model.dart';
import '../models/medication_model.dart';
import '../repositories/medication_repository.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationRepository _repo = MedicationRepository();

  List<MedicationModel> _medications = [];
  List<CheckInModel> _todayCheckIns = [];
  List<CheckInModel> _monthCheckIns = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentParentId;

  StreamSubscription<List<MedicationModel>>? _medicationSub;
  StreamSubscription<List<CheckInModel>>? _todayCheckInSub;
  StreamSubscription<List<CheckInModel>>? _monthCheckInSub;

  List<MedicationModel> get medications => _medications;
  List<CheckInModel> get todayCheckIns => _todayCheckIns;
  List<CheckInModel> get monthCheckIns => _monthCheckIns;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get complianceRate {
    if (_monthCheckIns.isEmpty) return 0.0;
    final completed =
        _monthCheckIns.where((c) => c.status == 'completed').length;
    return (completed / _monthCheckIns.length) * 100;
  }

  List<Map<String, dynamic>> get weeklyCompliance {
    final now = DateTime.now();
    // Tìm thứ 2 của tuần hiện tại
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final dayStart = day;
      final dayEnd = day.add(const Duration(days: 1));

      final dayCheckIns = _monthCheckIns.where((c) {
        final ts = c.timestamp;
        if (ts == null) return false;
        return ts.isAfter(dayStart) && ts.isBefore(dayEnd);
      }).toList();

      String status;
      if (day.isAfter(now)) {
        status = 'upcoming';
      } else if (dayCheckIns.any((c) => c.status == 'completed')) {
        status = 'completed';
      } else if (dayCheckIns.any((c) => c.status == 'missed')) {
        status = 'missed';
      } else if (day.day == now.day &&
          day.month == now.month &&
          day.year == now.year) {
        status = 'pending';
      } else {
        status = 'missed';
      }

      const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      return {'day': labels[i], 'status': status};
    });
  }

  void updateUser({String? parentId}) {
    if (_currentParentId == parentId) return;
    _currentParentId = parentId;

    _cancelSubscriptions();
    _medications = [];
    _todayCheckIns = [];
    _monthCheckIns = [];
    _errorMessage = null;

    if (parentId == null || parentId.isEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _medicationSub = _repo.getMedicationsForParent(parentId).listen(
      (data) {
        _medications = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Lỗi tải lịch thuốc: $e';
        _isLoading = false;
        notifyListeners();
      },
    );

    _todayCheckInSub = _repo.getTodayCheckIns(parentId).listen(
      (data) {
        _todayCheckIns = data;
        notifyListeners();
      },
      onError: (e) => debugPrint('todayCheckIns error: $e'),
    );

    _monthCheckInSub = _repo.getMonthCheckIns(parentId).listen(
      (data) {
        _monthCheckIns = data;
        notifyListeners();
      },
      onError: (e) => debugPrint('monthCheckIns error: $e'),
    );
  }

  void _cancelSubscriptions() {
    _medicationSub?.cancel();
    _todayCheckInSub?.cancel();
    _monthCheckInSub?.cancel();
    _medicationSub = null;
    _todayCheckInSub = null;
    _monthCheckInSub = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
