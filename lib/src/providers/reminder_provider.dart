import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../repositories/reminder_repository.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _repo = ReminderRepository();

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  StreamSubscription<List<ReminderModel>>? _reminderSub;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateUser({String? userId}) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;

    _reminderSub?.cancel();
    _reminderSub = null;
    _reminders = [];
    _errorMessage = null;

    if (userId == null || userId.isEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _reminderSub = _repo.getRemindersForUser(userId).listen(
      (data) {
        _reminders = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Lỗi tải lời nhắn: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addReminder(String content, String toUserId) async {
    if (_currentUserId == null) return;
    try {
      final reminder = ReminderModel(
        id: '',
        fromUserId: _currentUserId!,
        toUserId: toUserId,
        content: content,
      );
      await _repo.createReminder(reminder);
    } catch (e) {
      _errorMessage = 'Lỗi tạo lời nhắn: $e';
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    if (_currentUserId == null) return;
    try {
      await _repo.deleteReminder(reminderId, _currentUserId!);
    } catch (e) {
      _errorMessage = 'Lỗi xóa lời nhắn: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _reminderSub?.cancel();
    super.dispose();
  }
}
