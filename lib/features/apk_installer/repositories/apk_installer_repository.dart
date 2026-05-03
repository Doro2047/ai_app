/// APK 安装器 Repository
///
/// 处理 APK 安装相关的业务逻辑，包括设备管理、APK 解析和批量安装。
library;

import 'dart:async';
import 'dart:io';

import '../models/models.dart';
import 'adb_client.dart';

/// 安装进度回调
typedef InstallProgressCallback = void Function(int current, int total, String apkName);

/// 取消令牌
class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

/// APK 安装器 Repository
class ApkInstallerRepository {
  final AdbClient _adbClient;

  ApkInstallerRepository({AdbClient? adbClient})
      : _adbClient = adbClient ?? AdbClient();

  /// ADB 客户端
  AdbClient get adbClient => _adbClient;

  /// 初始化 ADB
  Future<void> initialize() async {
    await _adbClient.initialize();
  }

  /// 检查 ADB 是否可用
  bool get isAdbAvailable => _adbClient.isInitialized;

  /// 获取 ADB 路径
  String? get adbPath => _adbClient.adbPath;

  /// 获取设备列表
  Future<List<ApkDevice>> listDevices() async {
    try {
      final rawDevices = await _adbClient.devices();
      final devices = <ApkDevice>[];

      for (int i = 0; i < rawDevices.length; i++) {
        final line = rawDevices[i];
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          final serial = parts[0];
          final state = parts[1];
          devices.add(ApkDevice.fromAdbOutput(serial, state));
        }
      }

      return devices;
    } catch (e) {
      // 如果 ADB 不可用，返回空列表
      return [];
    }
  }

  /// 获取 APK 文件信息
  Future<ApkFile> getApkInfo(String apkPath) async {
    final file = File(apkPath);
    if (!await file.exists()) {
      throw FileNotFoundException(apkPath);
    }

    final fileSize = await file.length();
    final fileName = apkPath.split(RegExp(r'[/\\]')).last;

    // 尝试使用 aapt 获取包信息
    try {
      final apkInfo = await _adbClient.getApkInfo(apkPath);
      if (apkInfo != null) {
        return _parseApkInfo(apkInfo, apkPath, fileName, fileSize);
      }
    } catch (_) {
      // 解析失败时返回基本信息
    }

    return ApkFile(
      path: apkPath,
      name: fileName,
      size: fileSize,
    );
  }

  /// 解析 APK 信息
  ApkFile _parseApkInfo(String aaptOutput, String path, String name, int size) {
    String? packageName;
    String? version;

    // 解析 package: name='com.example.app' versionCode='1' versionName='1.0'
    final packageRegex = RegExp(r"package:\s*name='([^']+)'");
    final packageMatch = packageRegex.firstMatch(aaptOutput);
    if (packageMatch != null) {
      packageName = packageMatch.group(1);
    }

    // 解析 versionName
    final versionRegex = RegExp(r"versionName='([^']+)'");
    final versionMatch = versionRegex.firstMatch(aaptOutput);
    if (versionMatch != null) {
      version = versionMatch.group(1);
    }

    return ApkFile(
      path: path,
      name: name,
      packageName: packageName,
      version: version,
      size: size,
    );
  }

  /// 安装单个 APK
  Future<ApkInstallResult> installApk(
    String apkPath,
    String deviceSerial, {
    bool replace = true,
    bool allowDowngrade = false,
    InstallProgressCallback? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await _adbClient.install(
        apkPath,
        deviceSerial,
        replace: replace,
        allowDowngrade: allowDowngrade,
      );

      stopwatch.stop();

      if (result.isSuccess && result.output.contains('Success')) {
        return ApkInstallResult.success(
          apkPath: apkPath,
          deviceSerial: deviceSerial,
          duration: stopwatch.elapsed,
        );
      } else {
        final errorMsg = result.errorOutput.isNotEmpty
            ? result.errorOutput
            : result.output;
        return ApkInstallResult.failure(
          apkPath: apkPath,
          deviceSerial: deviceSerial,
          error: _extractErrorMessage(errorMsg),
          duration: stopwatch.elapsed,
        );
      }
    } catch (e) {
      stopwatch.stop();
      return ApkInstallResult.failure(
        apkPath: apkPath,
        deviceSerial: deviceSerial,
        error: e.toString(),
        duration: stopwatch.elapsed,
      );
    }
  }

  /// 批量安装 APK
  Future<List<ApkInstallResult>> installMultiple(
    List<ApkFile> apkFiles,
    String deviceSerial, {
    bool replace = true,
    bool allowDowngrade = false,
    InstallProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    final results = <ApkInstallResult>[];
    final selectedFiles = apkFiles.where((f) => f.selected).toList();

    for (int i = 0; i < selectedFiles.length; i++) {
      // 检查是否取消
      if (cancelToken?.isCancelled ?? false) {
        break;
      }

      final apkFile = selectedFiles[i];

      // 进度回调
      onProgress?.call(i + 1, selectedFiles.length, apkFile.name);

      final result = await installApk(
        apkFile.path,
        deviceSerial,
        replace: replace,
        allowDowngrade: allowDowngrade,
      );

      results.add(result);
    }

    return results;
  }

  /// 从 ADB 输出中提取错误信息
  String _extractErrorMessage(String output) {
    // 常见错误模式
    final patterns = [
      RegExp(r'Failure \[([^\]]+)\]'),
      RegExp(r'ERROR:?\s*(.+)'),
      RegExp(r'adb:\s*(.+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(output);
      if (match != null) {
        return match.group(1)?.trim() ?? output.trim();
      }
    }

    return output.trim().isEmpty ? '安装失败' : output.trim();
  }
}

/// 文件不存在异常
class FileNotFoundException implements Exception {
  final String path;

  const FileNotFoundException(this.path);

  @override
  String toString() => 'FileNotFoundException: $path';
}
