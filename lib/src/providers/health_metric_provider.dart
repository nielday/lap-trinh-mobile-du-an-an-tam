import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/health_metric_model.dart';
import '../repositories/health_metric_repository.dart';

class HealthMetricProvider extends ChangeNotifier {
  final HealthMetricRepository _repo = HealthMetricRepository();

  HealthMetricModel? _latestMetric;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentParentId;

  StreamSubscription<HealthMetricModel?>? _sub;

  HealthMetricModel? get latestMetric => _latestMetric;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateUser({String? parentId}) {
    if (_currentParentId == parentId) return;
    _currentParentId = parentId;
    _sub?.cancel();

    if (parentId == null || parentId.isEmpty) {
      _latestMetric = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _sub = _repo.streamLatestMetric(parentId).listen(
      (data) {
        _latestMetric = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Lỗi tải chỉ số sức khỏe: $e';
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
