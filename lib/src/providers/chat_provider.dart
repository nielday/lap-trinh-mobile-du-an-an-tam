import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/exceptions.dart';
import '../models/message_model.dart';
import '../repositories/message_repository.dart';

class ChatProvider extends ChangeNotifier {
  final MessageRepository _repo = MessageRepository();

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _currentUserId;
  String? _otherUserId;

  StreamSubscription<List<MessageModel>>? _messageSub;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  void init(String currentUserId, String otherUserId) {
    if (_currentUserId == currentUserId && _otherUserId == otherUserId) return;

    _messageSub?.cancel();
    _currentUserId = currentUserId;
    _otherUserId = otherUserId;
    _messages = [];
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    _messageSub = _repo.getMessages(currentUserId, otherUserId).listen(
      (data) {
        _messages = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Lỗi tải tin nhắn: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> sendMessage(String text) async {
    if (_currentUserId == null || _otherUserId == null) return;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final message = MessageModel(
        id: '',
        senderId: _currentUserId!,
        receiverId: _otherUserId!,
        text: text,
      );
      await _repo.sendMessage(message);
    } on ValidationException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Lỗi gửi tin nhắn: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }
}
