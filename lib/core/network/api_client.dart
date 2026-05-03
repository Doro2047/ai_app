import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import '../constants/app_constants.dart';

/// API 客户端 - 基于 Dio 封装
class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger('ApiClient');

  void init({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.fine('Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.fine('Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.warning('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
