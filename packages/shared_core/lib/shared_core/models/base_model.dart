/// 基础模型类
abstract class BaseModel {
  const BaseModel();

  /// 将模型转换为 Map
  Map<String, dynamic> toJson();

  /// 从 Map 创建模型
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson 必须由子类实现');
  }
}

/// API 响应包装器
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? code;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.code,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: fromJson != null && json['data'] != null
          ? fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      code: json['code'] as int?,
    );
  }

  Map<String, dynamic> toJson({Map<String, dynamic> Function(T)? toJson}) {
    return {
      'success': success,
      'data': toJson != null && data != null ? toJson(data as T) : null,
      'message': message,
      'code': code,
    };
  }
}
