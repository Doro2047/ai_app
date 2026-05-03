class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  const AppException(this.message, {this.code, this.originalError});
  @override
  String toString() => message;
}

class UserException extends AppException {
  const UserException(super.message, {super.code, super.originalError});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.originalError});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.originalError});
}

class FileNotFoundException extends AppException {
  const FileNotFoundException(super.message, {super.code, super.originalError});
}
