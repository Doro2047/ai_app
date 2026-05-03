/// 系统时间控制 Repository
///
/// 平台条件分支实现：
/// - Windows: 使用 w32tm 命令执行时间同步
/// - Android: 功能降级，提示用户不支持设置系统时间
library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:process_run/shell.dart';

import '../models/models.dart';

class SystemControlRepository {
  final Logger _logger = Logger('SystemControlRepository');

  /// 同步时间（Windows 使用 w32tm，Android 提示不支持）
  Future<TimeSyncResult> syncTime(String server) async {
    if (Platform.isWindows) {
      return _syncTimeWindows(server);
    } else {
      return _syncTimeUnsupported(server);
    }
  }

  /// Windows 平台时间同步
  Future<TimeSyncResult> _syncTimeWindows(String server) async {
    final shell = Shell();
    final localTime = DateTime.now();

    try {
      // 配置 NTP 服务器
      await shell.run(
          'w32tm /config /manualpeerlist:$server /syncfromflags:manual /update');

      // 重新同步
      await shell.run('w32tm /resync');

      final serverTime = DateTime.now();
      final offset = serverTime.difference(localTime);

      _logger.info('时间同步成功: 服务器=$server, 偏移=${offset.inSeconds}s');

      return TimeSyncResult(
        serverName: server,
        localTime: _formatDateTime(localTime),
        serverTime: _formatDateTime(serverTime),
        offset: offset,
        success: true,
      );
    } catch (e) {
      _logger.warning('时间同步失败: 服务器=$server, 错误=$e');
      return TimeSyncResult(
        serverName: server,
        localTime: _formatDateTime(localTime),
        serverTime: _formatDateTime(DateTime.now()),
        offset: Duration.zero,
        success: false,
        error: '同步失败: $e\n请确保以管理员身份运行。',
      );
    }
  }

  /// Android 平台时间同步（不支持设置系统时间）
  Future<TimeSyncResult> _syncTimeUnsupported(String server) async {
    final localTime = DateTime.now();
    return TimeSyncResult(
      serverName: server,
      localTime: _formatDateTime(localTime),
      serverTime: _formatDateTime(localTime),
      offset: Duration.zero,
      success: false,
      error: 'Android 不支持设置系统时间，需要 root 权限。\n'
          '请在系统设置中手动同步网络时间。',
    );
  }

  /// 设置系统时间（仅 Windows 支持）
  Future<bool> setTime(DateTime dateTime) async {
    if (Platform.isWindows) {
      return _setTimeWindows(dateTime);
    } else {
      return _setTimeUnsupported();
    }
  }

  /// Windows 设置系统时间
  Future<bool> _setTimeWindows(DateTime dateTime) async {
    final shell = Shell();

    try {
      // 使用 PowerShell 设置日期和时间
      await shell.run(
          'powershell -Command "Set-Date -Date \'${dateTime.toString()}\'"');
      _logger.info('系统时间已设置: $dateTime');
      return true;
    } catch (e) {
      _logger.warning('设置系统时间失败: $e');
      return false;
    }
  }

  /// Android 设置系统时间（不支持）
  Future<bool> _setTimeUnsupported() async {
    _logger.warning('Android 不支持设置系统时间，需要 root 权限。');
    return false;
  }

  /// 获取 NTP 服务器列表
  Future<List<TimeServer>> getNtpServers() async {
    if (Platform.isWindows) {
      return _getNtpServersWindows();
    } else {
      return _getNtpServersDefault();
    }
  }

  /// Windows 获取配置的 NTP 服务器
  Future<List<TimeServer>> _getNtpServersWindows() async {
    final shell = Shell();
    try {
      final result = await shell.run('w32tm /query /configuration');
      final output = result.map((e) => e.outText).join('\n');

      // 尝试从输出中提取 NTP 服务器配置
      final servers = <TimeServer>[];
      final serverPattern = RegExp(r'NtpServer:\s*(.+)', caseSensitive: false);
      final match = serverPattern.firstMatch(output);

      if (match != null) {
        final serverString = match.group(1)?.trim() ?? '';
        final serverList =
            serverString.split(',').where((s) => s.isNotEmpty).toList();
        for (final server in serverList) {
          final host = server.split(',')[0].trim();
          if (host.isNotEmpty) {
            servers.add(TimeServer(
              name: host,
              host: host,
              status: ServerStatus.unknown,
            ));
          }
        }
      }

      // 如果未找到配置，返回常用服务器列表
      if (servers.isEmpty) {
        return TimeServer.commonServers;
      }

      return servers;
    } catch (e) {
      _logger.warning('获取 NTP 服务器配置失败: $e');
      return TimeServer.commonServers;
    }
  }

  /// 返回默认 NTP 服务器列表（Android 或 Windows 失败时）
  Future<List<TimeServer>> _getNtpServersDefault() async {
    return TimeServer.commonServers;
  }

  /// 测试时间同步
  Future<TimeSyncResult> testTimeSync(String server) async {
    if (Platform.isWindows) {
      return _testTimeSyncWindows(server);
    } else {
      return _testTimeSyncUnsupported(server);
    }
  }

  /// Windows 测试时间同步
  Future<TimeSyncResult> _testTimeSyncWindows(String server) async {
    final shell = Shell();
    final localTime = DateTime.now();

    try {
      final result = await shell.run('w32tm /stripchart /computer:$server /samples:1 /dataonly');
      final output = result.map((e) => e.outText).join('\n');

      // 解析输出获取服务器时间
      final timePattern = RegExp(
          r'(\d{2}:\d{2}:\d{2}\.\d{6})',
          caseSensitive: false);
      final match = timePattern.firstMatch(output);

      String serverTimeStr = _formatDateTime(localTime);
      if (match != null) {
        final serverTimeStrParsed = match.group(1)!;
        // 构建完整日期时间字符串
        final now = DateTime.now();
        serverTimeStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} $serverTimeStrParsed';
      }

      final serverTime = DateTime.now();
      final offset = serverTime.difference(localTime);

      return TimeSyncResult(
        serverName: server,
        localTime: _formatDateTime(localTime),
        serverTime: serverTimeStr,
        offset: offset,
        success: true,
      );
    } catch (e) {
      return TimeSyncResult(
        serverName: server,
        localTime: _formatDateTime(localTime),
        serverTime: _formatDateTime(DateTime.now()),
        offset: Duration.zero,
        success: false,
        error: '测试同步失败: $e',
      );
    }
  }

  /// Android 测试时间同步（不支持）
  Future<TimeSyncResult> _testTimeSyncUnsupported(String server) async {
    final localTime = DateTime.now();
    return TimeSyncResult(
      serverName: server,
      localTime: _formatDateTime(localTime),
      serverTime: _formatDateTime(localTime),
      offset: Duration.zero,
      success: false,
      error: 'Android 不支持 NTP 测试同步',
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
