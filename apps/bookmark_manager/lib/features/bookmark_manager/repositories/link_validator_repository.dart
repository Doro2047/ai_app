library;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/link_validation_result.dart';

typedef ValidationProgressCallback = void Function(int completed, int total);
typedef ValidationResultCallback = void Function(LinkValidationResult result);

class LinkValidatorRepository {
  final Dio _dio;
  final int maxConcurrency;
  final Duration timeout;

  LinkValidatorRepository({
    Dio? dio,
    this.maxConcurrency = 10,
    this.timeout = const Duration(seconds: 10),
  }) : _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    final dio = Dio(BaseOptions(
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => true,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    ));

    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    return dio;
  }

  Future<LinkValidationResult> validateLink(
    String url, {
    Duration? customTimeout,
  }) async {
    if (url.isEmpty) {
      return LinkValidationResult(
        url: url,
        isValid: false,
        error: 'URL is empty',
      );
    }

    if (url.startsWith('javascript:') ||
        url.startsWith('chrome://') ||
        url.startsWith('edge://') ||
        url.startsWith('file://') ||
        url.startsWith('data:')) {
      return LinkValidationResult(
        url: url,
        isValid: false,
        error: 'Unsupported protocol',
      );
    }

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.head(
        url,
        options: Options(
          receiveTimeout: customTimeout ?? timeout,
          sendTimeout: customTimeout ?? timeout,
        ),
      );

      stopwatch.stop();

      final statusCode = response.statusCode;
      final isValid = statusCode != null && statusCode < 400;

      return LinkValidationResult(
        url: url,
        statusCode: statusCode,
        statusText: response.statusMessage ?? '',
        isValid: isValid,
        responseTime: stopwatch.elapsed,
      );
    } on DioException catch (e) {
      stopwatch.stop();

      String error;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          error = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          error = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          error = 'Receive timeout';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          error = 'HTTP Error $statusCode';
          return LinkValidationResult(
            url: url,
            statusCode: statusCode,
            statusText: e.response?.statusMessage ?? '',
            isValid: false,
            responseTime: stopwatch.elapsed,
            error: _getHttpErrorDescription(statusCode),
          );
        case DioExceptionType.cancel:
          error = 'Request cancelled';
          break;
        default:
          error = 'Connection error: ${e.message ?? 'unknown'}';
      }

      return LinkValidationResult(
        url: url,
        isValid: false,
        responseTime: stopwatch.elapsed,
        error: error,
      );
    } catch (e) {
      stopwatch.stop();
      return LinkValidationResult(
        url: url,
        isValid: false,
        responseTime: stopwatch.elapsed,
        error: 'Unknown error: $e',
      );
    }
  }

  String _getHttpErrorDescription(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '400 - Bad Request';
      case 401:
        return '401 - Unauthorized';
      case 403:
        return '403 - Forbidden';
      case 404:
        return '404 - Not Found';
      case 405:
        return '405 - Method Not Allowed';
      case 500:
        return '500 - Server Error';
      case 502:
        return '502 - Bad Gateway';
      case 503:
        return '503 - Service Unavailable';
      case 504:
        return '504 - Gateway Timeout';
      default:
        return 'HTTP $statusCode Error';
    }
  }

  Future<List<LinkValidationResult>> validateLinks(
    List<String> urls, {
    ValidationProgressCallback? onProgress,
    ValidationResultCallback? onResult,
    CancellationToken? cancelToken,
    int? concurrency,
  }) async {
    final results = <LinkValidationResult>[];
    final total = urls.length;
    int completed = 0;

    if (total == 0) return results;

    final maxWorkers = concurrency ?? maxConcurrency;

    final semaphore = <Future<void>>[];

    for (int i = 0; i < total; i++) {
      if (cancelToken?.isCancelled == true) {
        debugPrint('Link validation cancelled');
        break;
      }

      final url = urls[i];

      final future = validateLink(url).then((result) {
        results.add(result);
        completed++;

        onProgress?.call(completed, total);
        onResult?.call(result);
      });

      semaphore.add(future);

      if (semaphore.length >= maxWorkers) {
        await Future.wait(semaphore);
        semaphore.clear();
      }
    }

    if (semaphore.isNotEmpty) {
      await Future.wait(semaphore);
    }

    return results;
  }
}

class CancellationToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void reset() {
    _isCancelled = false;
  }
}
