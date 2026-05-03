/// 链接验证仓库
///
/// 使用 dio 包验证书签链接有效性，支持并发请求。
library;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/link_validation_result.dart';

/// 进度回调
typedef ValidationProgressCallback = void Function(int completed, int total);

/// 结果回调
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
      validateStatus: (status) => true, // 接受所有状态码
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    ));

    // 设置连接和接收超时
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    return dio;
  }

  /// 验证单个链接
  Future<LinkValidationResult> validateLink(
    String url, {
    Duration? customTimeout,
  }) async {
    if (url.isEmpty) {
      return LinkValidationResult(
        url: url,
        isValid: false,
        error: 'URL 为空',
      );
    }

    // 过滤特殊协议
    if (url.startsWith('javascript:') ||
        url.startsWith('chrome://') ||
        url.startsWith('edge://') ||
        url.startsWith('file://') ||
        url.startsWith('data:')) {
      return LinkValidationResult(
        url: url,
        isValid: false,
        error: '不支持的协议',
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
          error = '连接超时';
          break;
        case DioExceptionType.sendTimeout:
          error = '发送超时';
          break;
        case DioExceptionType.receiveTimeout:
          error = '接收超时';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          error = 'HTTP 错误 $statusCode';
          return LinkValidationResult(
            url: url,
            statusCode: statusCode,
            statusText: e.response?.statusMessage ?? '',
            isValid: false,
            responseTime: stopwatch.elapsed,
            error: _getHttpErrorDescription(statusCode),
          );
        case DioExceptionType.cancel:
          error = '请求已取消';
          break;
        default:
          error = '连接错误: ${e.message ?? '未知'}';
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
        error: '未知错误: $e',
      );
    }
  }

  /// 获取 HTTP 错误描述
  String _getHttpErrorDescription(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '400 - 请求错误';
      case 401:
        return '401 - 未授权';
      case 403:
        return '403 - 禁止访问';
      case 404:
        return '404 - 页面未找到';
      case 405:
        return '405 - 方法不允许';
      case 500:
        return '500 - 服务器错误';
      case 502:
        return '502 - 网关错误';
      case 503:
        return '503 - 服务不可用';
      case 504:
        return '504 - 网关超时';
      default:
        return 'HTTP $statusCode 错误';
    }
  }

  /// 批量验证链接
  ///
  /// [urls] 要验证的 URL 列表
  /// [onProgress] 进度回调
  /// [onResult] 单个结果回调
  /// [cancelToken] 取消令牌
  ///
  /// 返回验证结果列表
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

    // 使用信号量控制并发数
    final semaphore = <Future<void>>[];

    for (int i = 0; i < total; i++) {
      // 检查取消
      if (cancelToken?.isCancelled == true) {
        debugPrint('链接验证已取消');
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

      // 控制并发：每 maxWorkers 个请求等待一批完成
      if (semaphore.length >= maxWorkers) {
        await Future.wait(semaphore);
        semaphore.clear();
      }
    }

    // 等待剩余的请求
    if (semaphore.isNotEmpty) {
      await Future.wait(semaphore);
    }

    return results;
  }
}

/// 取消令牌（简单实现）
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
