import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _repo = AppointmentRepository();

  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentParentId;

  StreamSubscription<List<AppointmentModel>>? _sub;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateUser({String? parentId}) {
    if (_currentParentId == parentId) return;
    _currentParentId = parentId;
    _sub?.cancel();

    if (parentId == null || parentId.isEmpty) {
      _appointments = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _sub = _repo.getUpcomingAppointments(parentId).listen(
      (data) {
        _appointments = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Lỗi tải lịch khám: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
