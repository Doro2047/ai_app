/// ADB 命令客户端
///
/// 封装 ADB 命令执行，支持设备列表、安装、卸载等操作。
/// 使用 Dart Process 执行系统命令。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// ADB 命令客户端
class AdbClient {
  /// ADB 可执行文件路径
  String? _adbPath;

  /// 是否已初始化
  bool get isInitialized => _adbPath != null;

  /// ADB 路径
  String? get adbPath => _adbPath;

  /// 初始化 ADB 路径
  ///
  /// 按以下顺序查找：
  /// 1. 系统 PATH 中的 adb
  /// 2. Android SDK platform-tools 目录
  /// 3. 常见安装位置
  Future<void> initialize() async {
    _adbPath = await _findAdbPath();
  }

  /// 查找 ADB 可执行文件路径
  Future<String?> _findAdbPath() async {
    // 1. 尝试使用 where 查找 PATH 中的 adb
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
      // 忽略错误，继续尝试其他方法
    }

    // 2. 尝试 Android SDK platform-tools 目录
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

  /// 从环境变量获取路径
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

  /// 执行 ADB 命令
  Future<ShellResult> _runAdb(List<String> args,
      {int timeoutSeconds = 300}) async {
    if (_adbPath == null) {
      throw const AdbException('ADB 未初始化，请先调用 initialize()');
    }

    try {
      final process = await Process.start(
        _adbPath!,
        args,
        runInShell: true,
      );

      // 收集输出
      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();

      final stdoutFuture = process.stdout
          .transform(utf8.decoder)
          .forEach(stdoutBuffer.write);
      final stderrFuture = process.stderr
          .transform(utf8.decoder)
          .forEach(stderrBuffer.write);

      // 等待进程完成或超时
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
      throw const AdbException('命令执行超时');
    } catch (e) {
      throw AdbException('ADB 命令执行失败: $e');
    }
  }

  /// 获取设备列表
  ///
  /// 返回原始输出行列表，每行格式: "serial\tstate"
  Future<List<String>> devices() async {
    final result = await _runAdb(['devices'], timeoutSeconds: 10);
    if (result.exitCode != 0) {
      throw AdbException('获取设备列表失败: ${result.stderr}');
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

  /// 安装 APK
  ///
  /// [apkPath] APK 文件路径
  /// [deviceSerial] 设备序列号
  /// [replace] 覆盖安装
  /// [allowTest] 允许测试包
  /// [allowDowngrade] 允许降级安装
  /// [grantPermissions] 授予运行时权限
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

  /// 卸载应用
  ///
  /// [packageName] 包名
  /// [deviceSerial] 设备序列号
  /// [keepData] 保留应用数据
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

  /// 执行 shell 命令
  ///
  /// [command] shell 命令
  /// [deviceSerial] 设备序列号
  Future<ShellResult> shell(String command, String deviceSerial) async {
    return _runAdb(
      ['-s', deviceSerial, 'shell', command],
      timeoutSeconds: 30,
    );
  }

  /// 推送文件到设备
  ///
  /// [localPath] 本地文件路径
  /// [remotePath] 设备目标路径
  /// [deviceSerial] 设备序列号
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

  /// 获取 APK 包信息（使用 aapt）
  ///
  /// [apkPath] APK 文件路径
  Future<String?> getApkInfo(String apkPath) async {
    try {
      // 尝试查找 aapt
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
      // 忽略错误
    }
    return null;
  }

  /// 查找 aapt 可执行文件
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
      // 忽略错误
    }

    // 尝试在 adb 同目录查找
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

/// Shell 执行结果
class ShellResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  const ShellResult(this.stdout, this.stderr, this.exitCode);

  /// 是否成功
  bool get isSuccess => exitCode == 0;

  /// 输出文本
  String get output => stdout.trim();

  /// 错误文本
  String get errorOutput => stderr.trim();
}

/// ADB 异常
class AdbException implements Exception {
  final String message;

  const AdbException(this.message);

  @override
  String toString() => 'AdbException: $message';
}
