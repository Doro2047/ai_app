library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class AdbClient {
  String? _adbPath;

  bool get isInitialized => _adbPath != null;

  String? get adbPath => _adbPath;

  Future<void> initialize() async {
    _adbPath = await _findAdbPath();
  }

  Future<String?> _findAdbPath() async {
    // 1. Try to find adb in PATH using 'where' command
    try {
      final result = await Process.run('where', ['adb'],
          runInShell: true);
      if (result.exitCode == 0 && result.stdout.toString().isNotEmpty) {
        final lines = result.stdout.toString()
            .trim()
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();
        if (lines.isNotEmpty) {
          final path = lines.first.trim();
          if (await File(path).exists()) {
            return path;
          }
        }
      }
    } catch (_) {
      // Ignore, try other methods
    }

    // 2. Try Android SDK platform-tools directory
    final commonPaths = [
      _fromEnv('ANDROID_HOME'),
      _fromEnv('ANDROID_SDK_ROOT'),
      _fromEnvLocalAppData(),
      r'C:\Program Files\Android\android-sdk',
      r'C:\Program Files (x86)\Android\android-sdk',
    ];

    for (final sdkPath in commonPaths.whereType<String>()) {
      final adbPath = '$sdkPath\\platform-tools\\adb.exe';
      if (await File(adbPath).exists()) {
        return adbPath;
      }
    }

    return null;
  }

  String? _fromEnv(String name) {
    final value = Platform.environment[name];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  String? _fromEnvLocalAppData() {
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return '$localAppData\\Android\\Sdk';
    }
    return null;
  }

  void setAdbPath(String path) {
    _adbPath = path;
  }

  Future<ShellResult> _runAdb(List<String> args,
      {int timeoutSeconds = 300}) async {
    if (_adbPath == null) {
      throw const AdbException('ADB not initialized. Call initialize() first.');
    }

    try {
      final process = await Process.start(
        _adbPath!,
        args,
        runInShell: true,
      );

      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      final stdoutFuture = process.stdout
          .transform(utf8.decoder)
          .forEach(stdoutBuffer.write);
      final stderrFuture = process.stderr
          .transform(utf8.decoder)
          .forEach(stderrBuffer.write);

      final exitCode = await process.exitCode
          .timeout(Duration(seconds: timeoutSeconds));

      await stdoutFuture;
      await stderrFuture;

      return ShellResult(
        stdoutBuffer.toString(),
        stderrBuffer.toString(),
        exitCode,
      );
    } on TimeoutException catch (_) {
      throw const AdbException('Command execution timeout');
    } catch (e) {
      throw AdbException('ADB command failed: $e');
    }
  }

  Future<List<String>> devices() async {
    final result = await _runAdb(['devices'], timeoutSeconds: 10);
    if (result.exitCode != 0) {
      throw AdbException('Failed to get device list: ${result.stderr}');
    }

    final lines = result.stdout
        .trim()
        .split('\n')
        .map((line) => line.trim())
        .where((line) =>
            line.isNotEmpty && !line.startsWith('List of devices'))
        .toList();

    return lines;
  }

  Future<ShellResult> install(
    String apkPath,
    String deviceSerial, {
    bool replace = true,
    bool allowTest = false,
    bool allowDowngrade = false,
    bool grantPermissions = true,
  }) async {
    final args = ['-s', deviceSerial, 'install'];

    if (replace) {
      args.add('-r');
    }
    if (allowTest) {
      args.add('-t');
    }
    if (allowDowngrade) {
      args.add('-d');
    }
    if (grantPermissions) {
      args.add('-g');
    }

    args.add(apkPath);

    return _runAdb(args, timeoutSeconds: 300);
  }

  Future<ShellResult> uninstall(
    String packageName,
    String deviceSerial, {
    bool keepData = false,
  }) async {
    final args = ['-s', deviceSerial, 'uninstall'];

    if (keepData) {
      args.add('-k');
    }

    args.add(packageName);

    return _runAdb(args, timeoutSeconds: 60);
  }

  Future<ShellResult> shell(String command, String deviceSerial) async {
    return _runAdb(
      ['-s', deviceSerial, 'shell', command],
      timeoutSeconds: 30,
    );
  }

  Future<ShellResult> push(
    String localPath,
    String remotePath,
    String deviceSerial,
  ) async {
    return _runAdb(
      ['-s', deviceSerial, 'push', localPath, remotePath],
      timeoutSeconds: 120,
    );
  }

  Future<String?> getApkInfo(String apkPath) async {
    try {
      final aaptPath = await _findAaptPath();
      if (aaptPath != null) {
        final result = await Process.run(
          aaptPath,
          ['dump', 'badging', apkPath],
          runInShell: true,
        );
        if (result.exitCode == 0) {
          return result.stdout.toString();
        }
      }
    } catch (_) {
      // Ignore errors
    }
    return null;
  }

  Future<String?> _findAaptPath() async {
    try {
      final result = await Process.run('where', ['aapt'],
          runInShell: true);
      if (result.exitCode == 0 && result.stdout.toString().isNotEmpty) {
        final lines = result.stdout.toString()
            .trim()
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();
        if (lines.isNotEmpty) {
          final path = lines.first.trim();
          if (await File(path).exists()) {
            return path;
          }
        }
      }
    } catch (_) {
      // Ignore errors
    }

    if (_adbPath != null) {
      final adbDir = _adbPath!.replaceAll(RegExp(r'[/\\][^/\\]+$'), '');
      final aaptPath = '$adbDir\\aapt.exe';
      if (await File(aaptPath).exists()) {
        return aaptPath;
      }
    }

    return null;
  }
}

class ShellResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  const ShellResult(this.stdout, this.stderr, this.exitCode);

  bool get isSuccess => exitCode == 0;

  String get output => stdout.trim();

  String get errorOutput => stderr.trim();
}

class AdbException implements Exception {
  final String message;

  const AdbException(this.message);

  @override
  String toString() => 'AdbException: $message';
}
