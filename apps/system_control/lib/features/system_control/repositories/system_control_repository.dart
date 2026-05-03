library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:process_run/shell.dart';

import '../models/models.dart';

class SystemControlRepository {
  final Logger _logger = Logger('SystemControlRepository');

  Future<TimeSyncResult> syncTime(String server) async {
    if (Platform.isWindows) {
      return _syncTimeWindows(server);
    } else {
      return _syncTimeUnsupported(server);
    }
  }

  Future<TimeSyncResult> _syncTimeWindows(String server) async {
    final shell = Shell();
    final localTime = DateTime.now();

    try {
      await shell.run(
          'w32tm /config /manualpeerlist:$server /syncfromflags:manual /update');

      await shell.run('w32tm /resync');

      final serverTime = DateTime.now();
      final offset = serverTime.difference(localTime);

      _logger.info('Time sync success: server=$server, offset=${offset.inSeconds}s');

      return TimeSyncResult(
        serverName: server,
        localTime: _formatDateTime(localTime),
        serverTime: _formatDateTime(serverTime),
        offset: offset,
        success: true,
      );
    } catch (e) {
      _logger.warning('Time sync failed: server=$server, error=$e');
      return TimeSyncResult(
        serverName: server,
        localTime: _formatDateTime(localTime),
        serverTime: _formatDateTime(DateTime.now()),
        offset: Duration.zero,
        success: false,
        error: 'Sync failed: $e\nPlease run as administrator.',
      );
    }
  }

  Future<TimeSyncResult> _syncTimeUnsupported(String server) async {
    final localTime = DateTime.now();
    return TimeSyncResult(
      serverName: server,
      localTime: _formatDateTime(localTime),
      serverTime: _formatDateTime(localTime),
      offset: Duration.zero,
      success: false,
      error: 'Android does not support setting system time. '
          'Please sync network time in system settings manually.',
    );
  }

  Future<bool> setTime(DateTime dateTime) async {
    if (Platform.isWindows) {
      return _setTimeWindows(dateTime);
    } else {
      return _setTimeUnsupported();
    }
  }

  Future<bool> _setTimeWindows(DateTime dateTime) async {
    final shell = Shell();

    try {
      await shell.run(
          'powershell -Command "Set-Date -Date \'${dateTime.toString()}\'"');
      _logger.info('System time set: $dateTime');
      return true;
    } catch (e) {
      _logger.warning('Failed to set system time: $e');
      return false;
    }
  }

  Future<bool> _setTimeUnsupported() async {
    _logger.warning('Android does not support setting system time.');
    return false;
  }

  Future<List<TimeServer>> getNtpServers() async {
    if (Platform.isWindows) {
      return _getNtpServersWindows();
    } else {
      return _getNtpServersDefault();
    }
  }

  Future<List<TimeServer>> _getNtpServersWindows() async {
    final shell = Shell();
    try {
      final result = await shell.run('w32tm /query /configuration');
      final output = result.map((e) => e.outText).join('\n');

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

      if (servers.isEmpty) {
        return TimeServer.commonServers;
      }

      return servers;
    } catch (e) {
      _logger.warning('Failed to get NTP server config: $e');
      return TimeServer.commonServers;
    }
  }

  Future<List<TimeServer>> _getNtpServersDefault() async {
    return TimeServer.commonServers;
  }

  Future<TimeSyncResult> testTimeSync(String server) async {
    if (Platform.isWindows) {
      return _testTimeSyncWindows(server);
    } else {
      return _testTimeSyncUnsupported(server);
    }
  }

  Future<TimeSyncResult> _testTimeSyncWindows(String server) async {
    final shell = Shell();
    final localTime = DateTime.now();

    try {
      final result = await shell.run('w32tm /stripchart /computer:$server /samples:1 /dataonly');
      final output = result.map((e) => e.outText).join('\n');

      final timePattern = RegExp(
          r'(\d{2}:\d{2}:\d{2}\.\d{6})',
          caseSensitive: false);
      final match = timePattern.firstMatch(output);

      String serverTimeStr = _formatDateTime(localTime);
      if (match != null) {
        final serverTimeStrParsed = match.group(1)!;
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
        error: 'Test sync failed: $e',
      );
    }
  }

  Future<TimeSyncResult> _testTimeSyncUnsupported(String server) async {
    final localTime = DateTime.now();
    return TimeSyncResult(
      serverName: server,
      localTime: _formatDateTime(localTime),
      serverTime: _formatDateTime(localTime),
      offset: Duration.zero,
      success: false,
      error: 'Android does not support NTP test sync',
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
