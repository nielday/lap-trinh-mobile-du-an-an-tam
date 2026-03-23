import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';
import '../repositories/alert_repository.dart';

class AlertProvider extends ChangeNotifier {
  final AlertRepository _repo = AlertRepository();

  List<AlertModel> _unreadAlerts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  StreamSubscription<List<AlertModel>>? _alertSub;

  List<AlertModel> get unreadAlerts => _unreadAlerts;
  int get unreadCount => _unreadAlerts.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateUser({String? userId}) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    
    _alertSub?.cancel();
    _alertSub = null;
    _unreadAlerts = [];
    _errorMessage = null;

    if (userId == null || userId.isEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _alertSub = _repo.getUnreadAlerts(userId).listen(
      (data) {
        _unreadAlerts = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Lỗi tải cảnh báo: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markAsRead(String alertId, String userId) async {
    try {
      await _repo.markAsRead(alertId, userId);
    } catch (e) {
      _errorMessage = 'Lỗi đánh dấu đã đọc: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    super.dispose();
  }
}
