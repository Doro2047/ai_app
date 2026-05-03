class LinkValidationResult {
  final String url;
  final String title;
  final int? statusCode;
  final String statusText;
  final bool isValid;
  final Duration? responseTime;
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

  String get errorDescription {
    if (error != null && error!.isNotEmpty) return error!;
    if (statusCode != null) {
      switch (statusCode) {
        case 404:
          return '404 - Page Not Found';
        case 403:
          return '403 - Forbidden';
        case 500:
          return '500 - Server Error';
        case 502:
          return '502 - Bad Gateway';
        case 503:
          return '503 - Service Unavailable';
        default:
          return 'HTTP $statusCode $statusText';
      }
    }
    return 'Unknown Error';
  }

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
