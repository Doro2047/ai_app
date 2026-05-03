/// 链接验证结果模型
class LinkValidationResult {
  /// 被验证的 URL
  final String url;

  /// 页面标题
  final String title;

  /// HTTP 状态码
  final int? statusCode;

  /// HTTP 状态文本
  final String statusText;

  /// 链接是否有效
  final bool isValid;

  /// 响应时间
  final Duration? responseTime;

  /// 错误信息
  final String? error;

  const LinkValidationResult({
    required this.url,
    this.title = '',
    this.statusCode,
    this.statusText = '',
    this.isValid = false,
    this.responseTime,
    this.error,
  });

  /// 获取错误描述
  String get errorDescription {
    if (error != null && error!.isNotEmpty) return error!;
    if (statusCode != null) {
      switch (statusCode) {
        case 404:
          return '404 - 页面未找到';
        case 403:
          return '403 - 禁止访问';
        case 500:
          return '500 - 服务器错误';
        case 502:
          return '502 - 网关错误';
        case 503:
          return '503 - 服务不可用';
        default:
          return 'HTTP $statusCode $statusText';
      }
    }
    return '未知错误';
  }

  /// 转换为 Map
  Map<String, dynamic> toDict() {
    return {
      'url': url,
      'title': title,
      'statusCode': statusCode,
      'statusText': statusText,
      'isValid': isValid,
      'responseTimeMs': responseTime?.inMilliseconds,
      'error': error,
    };
  }

  /// 从 Map 创建
  factory LinkValidationResult.fromDict(Map<String, dynamic> data) {
    final responseTimeMs = data['responseTimeMs'] as int?;
    return LinkValidationResult(
      url: data['url'] as String,
      title: data['title'] as String? ?? '',
      statusCode: data['statusCode'] as int?,
      statusText: data['statusText'] as String? ?? '',
      isValid: data['isValid'] as bool? ?? false,
      responseTime: responseTimeMs != null
          ? Duration(milliseconds: responseTimeMs)
          : null,
      error: data['error'] as String?,
    );
  }

  @override
  String toString() {
    return 'LinkValidationResult(url: $url, isValid: $isValid, statusCode: $statusCode)';
  }
}
