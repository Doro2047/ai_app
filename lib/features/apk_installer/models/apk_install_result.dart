/// APK 安装结果模型
///
/// 表示单次 APK 安装的结果。
library;

import 'package:equatable/equatable.dart';

/// APK 安装结果
class ApkInstallResult extends Equatable {
  /// APK 文件路径
  final String apkPath;

  /// 设备序列号
  final String deviceSerial;

  /// 是否安装成功
  final bool success;

  /// 错误信息 (如果失败)
  final String? error;

  /// 安装耗时
  final Duration duration;

  const ApkInstallResult({
    required this.apkPath,
    required this.deviceSerial,
    required this.success,
    this.error,
    this.duration = Duration.zero,
  });

  /// APK 文件名
  String get apkName => apkPath.split(RegExp(r'[/\\]')).last;

  /// 格式化的耗时
  String get formattedDuration {
    final seconds = duration.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(1)}s';
  }

  /// 显示状态文本
  String get statusText {
    if (success) {
      return '安装成功';
    }
    return error ?? '安装失败';
  }

  Map<String, dynamic> toDict() {
    return {
      'apkPath': apkPath,
      'deviceSerial': deviceSerial,
      'success': success,
      'error': error,
      'durationMs': duration.inMilliseconds,
    };
  }

  factory ApkInstallResult.fromDict(Map<String, dynamic> data) {
    return ApkInstallResult(
      apkPath: data['apkPath'] as String,
      deviceSerial: data['deviceSerial'] as String,
      success: data['success'] as bool,
      error: data['error'] as String?,
      duration: Duration(milliseconds: data['durationMs'] as int? ?? 0),
    );
  }

  factory ApkInstallResult.success({
    required String apkPath,
    required String deviceSerial,
    Duration duration = Duration.zero,
  }) {
    return ApkInstallResult(
      apkPath: apkPath,
      deviceSerial: deviceSerial,
      success: true,
      duration: duration,
    );
  }

  factory ApkInstallResult.failure({
    required String apkPath,
    required String deviceSerial,
    required String error,
    Duration duration = Duration.zero,
  }) {
    return ApkInstallResult(
      apkPath: apkPath,
      deviceSerial: deviceSerial,
      success: false,
      error: error,
      duration: duration,
    );
  }

  @override
  List<Object?> get props => [
        apkPath,
        deviceSerial,
        success,
        error,
        duration,
      ];
}
