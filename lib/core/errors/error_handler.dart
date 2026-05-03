import 'app_exception.dart';
import '../utils/app_logger.dart';

class ErrorHandler {
  ErrorHandler._();

  static String getUserMessage(dynamic error) {
    if (error is UserException) return error.message;
    if (error is NetworkException) return error.message;
    if (error is StorageException) return error.message;
    if (error is PermissionException) return error.message;
    if (error is AppException) return error.message;
    return '发生未知错误';
  }

  static bool isUserVisible(dynamic error) {
    return error is UserException || error is NetworkException;
  }

  static void handleError(dynamic error, {StackTrace? stackTrace}) {
    if (isUserVisible(error)) {
      AppLogger.logger.warning('User error: ${error.toString()}');
    } else {
      AppLogger.logger.severe('Internal error: ${error.toString()}', error, stackTrace);
    }
  }
}
