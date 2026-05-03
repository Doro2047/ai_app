library;

import 'dart:async';
import 'dart:io';

import '../models/models.dart';
import 'adb_client.dart';

typedef InstallProgressCallback = void Function(int current, int total, String apkName);

class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class ApkInstallerRepository {
  final AdbClient _adbClient;

  ApkInstallerRepository({AdbClient? adbClient})
      : _adbClient = adbClient ?? AdbClient();

  AdbClient get adbClient => _adbClient;

  Future<void> initialize() async {
    await _adbClient.initialize();
  }

  bool get isAdbAvailable => _adbClient.isInitialized;

  String? get adbPath => _adbClient.adbPath;

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
      return [];
    }
  }

  Future<ApkFile> getApkInfo(String apkPath) async {
    final file = File(apkPath);
    if (!await file.exists()) {
      throw FileNotFoundException(apkPath);
    }

    final fileSize = await file.length();
    final fileName = apkPath.split(RegExp(r'[/\\]')).last;

    try {
      final apkInfo = await _adbClient.getApkInfo(apkPath);
      if (apkInfo != null) {
        return _parseApkInfo(apkInfo, apkPath, fileName, fileSize);
      }
    } catch (_) {
      // Return basic info when parsing fails
    }

    return ApkFile(
      path: apkPath,
      name: fileName,
      size: fileSize,
    );
  }

  ApkFile _parseApkInfo(String aaptOutput, String path, String name, int size) {
    String? packageName;
    String? version;

    final packageRegex = RegExp(r"package:\s*name='([^']+)'");
    final packageMatch = packageRegex.firstMatch(aaptOutput);
    if (packageMatch != null) {
      packageName = packageMatch.group(1);
    }

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
      if (cancelToken?.isCancelled ?? false) {
        break;
      }

      final apkFile = selectedFiles[i];

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

  String _extractErrorMessage(String output) {
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

    return output.trim().isEmpty ? 'Install failed' : output.trim();
  }
}

class FileNotFoundException implements Exception {
  final String path;

  const FileNotFoundException(this.path);

  @override
  String toString() => 'FileNotFoundException: $path';
}
