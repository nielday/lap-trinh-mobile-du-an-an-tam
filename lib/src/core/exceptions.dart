// Custom exceptions for An Tâm data layer

class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException(
      [this.message = 'Không có quyền thực hiện thao tác này']);

  @override
  String toString() => 'PermissionDeniedException: $message';
}

class UserNotFoundException implements Exception {
  final String message;
  const UserNotFoundException(
      [this.message = 'Không tìm thấy người dùng']);

  @override
  String toString() => 'UserNotFoundException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
