import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final UserRepository _userRepository = UserRepository();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UserModel>? _userSub;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  String? get parentId => _userModel?.parentId;

  /// parentId hiệu quả để dùng cho medications/appointments/health_metrics:
  /// - Nếu role = 'parent' → dùng uid của chính họ
  /// - Nếu role = 'child' và có parentId → dùng parentId liên kết
  /// - Fallback: dùng uid (để test CRUD không cần liên kết)
  String? get effectiveParentId {
    final uid = _user?.uid;
    if (uid == null) return null;
    
    // Wait until Firestore user profile is completely loaded
    // This prevents permission-denied race conditions
    if (_userModel == null) return null;

    // Tái cấu trúc theo yêu cầu của hệ thống: CON CÁI là trung tâm dữ liệu chủ. BỐ MẸ là người liên kết!
    if (_userModel!.role == 'child') return uid;
    
    if (_userModel!.role == 'parent') {
      if (_userModel!.parentId != null && _userModel!.parentId!.isNotEmpty) {
        return _userModel!.parentId;
      }
    }
    // Fallback: dùng uid của chính user (test mode / chưa liên kết)
    return uid;
  }

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _userSub?.cancel();
      _userSub = null;
      if (user != null) {
        _userSub = _userRepository.streamUser(user.uid).listen((model) {
          _userModel = model;
          notifyListeners();
        }, onError: (e) {
          debugPrint('Stream user model error: $e');
        });
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  // (Bỏ _loadUserModel và thay thế bằng stream trực tiếp ở constructor)

  // Hàm này giờ không cần làm gì vì _userModel tự cập nhật theo stream!
  Future<void> reloadUserModel() async {
    // Không cần body vì _userSub tự lo!
  }

  // Sign in anonymously (For Parents)
  Future<bool> signInAsParentAnonymously() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final String dummyEmail = 'parent_test_123@antam.com';
      final String dummyPassword = 'antamParent123!';

      UserCredential? credential;
      bool isNewUser = false;

      try {
        credential = await _authService.signUpWithEmail(
          email: dummyEmail,
          password: dummyPassword,
        );
        isNewUser = true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Parent already exists from a previous testing session, just log them back in!
          credential = await _authService.signInWithEmail(
            email: dummyEmail,
            password: dummyPassword,
          );
        } else {
          rethrow;
        }
      }
      
      if (credential != null && credential.user != null) {
        if (isNewUser) {
          await _firestoreService.createUserProfile(
            userId: credential.user!.uid,
            name: 'Phụ huynh',
            email: dummyEmail,
            role: 'parent',
          );
        }

        _user = credential.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up with email
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      if (credential != null && credential.user != null) {
        await _firestoreService.createUserProfile(
          userId: credential.user!.uid,
          name: name,
          email: email,
          role: role,
        );

        _user = credential.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with email
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (credential != null && credential.user != null) {
        _user = credential.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle(String role) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _authService.signInWithGoogle();

      if (credential != null && credential.user != null) {
        if (credential.additionalUserInfo?.isNewUser ?? false) {
          await _firestoreService.createUserProfile(
            userId: credential.user!.uid,
            name: credential.user!.displayName ?? 'Người dùng',
            email: credential.user!.email ?? '',
            role: role,
          );
        }

        _user = credential.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _userModel = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Đăng xuất thất bại';
      notifyListeners();
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authService.getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
