library;

import 'package:equatable/equatable.dart';

class ApkInstallResult extends Equatable {
  final String apkPath;
  final String deviceSerial;
  final bool success;
  final String? error;
  final Duration duration;

  const ApkInstallResult({
    required this.apkPath,
    required this.deviceSerial,
    required this.success,
    this.error,
    this.duration = Duration.zero,
  });

  String get apkName => apkPath.split(RegExp(r'[/\\]')).last;

  String get formattedDuration {
    final seconds = duration.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(1)}s';
  }

  String get statusText {
    if (success) {
      return 'Success';
    }
    return error ?? 'Failed';
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
