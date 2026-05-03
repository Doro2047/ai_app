import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class AppLogger {
  AppLogger._();

  static const int _maxLogSizeBytes = 5 * 1024 * 1024;
  static const String _logFileName = 'app.log';
  static const String _oldLogFileName = 'app.log.old';

  static File? _logFile;
  static IOSink? _sink;

  static Future<void> init() async {
    Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;

    try {
      final dir = await getApplicationSupportDirectory();
      _logFile = File('${dir.path}/$_logFileName');
      await _rotateIfNeeded();
      _sink = _logFile!.openWrite(mode: FileMode.append);
    } catch (_) {}

    Logger.root.onRecord.listen((record) {
      final line =
          '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}';
      // ignore: avoid_print
      print(line);
      _writeToFile(line);
    });
  }

  static void _writeToFile(String line) {
    try {
      _sink?.writeln(line);
    } catch (_) {}
  }

  static Future<void> _rotateIfNeeded() async {
    try {
      if (_logFile == null || !await _logFile!.exists()) return;
      final length = await _logFile!.length();
      if (length < _maxLogSizeBytes) return;

      final dir = _logFile!.parent;
      final oldFile = File('${dir.path}/$_oldLogFileName');
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
      await _logFile!.rename('${dir.path}/$_oldLogFileName');
      _logFile = File('${dir.path}/$_logFileName');
    } catch (_) {}
  }

  static Future<String?> getLogFilePath() async {
    try {
      if (_logFile != null) return _logFile!.path;
      final dir = await getApplicationSupportDirectory();
      return '${dir.path}/$_logFileName';
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearLogs() async {
    try {
      await _sink?.flush();
      await _sink?.close();
      _sink = null;

      final dir = await getApplicationSupportDirectory();
      final logFile = File('${dir.path}/$_logFileName');
      final oldFile = File('${dir.path}/$_oldLogFileName');

      if (await logFile.exists()) {
        await logFile.delete();
      }
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      _logFile = logFile;
      _sink = _logFile!.openWrite(mode: FileMode.append);
    } catch (_) {}
  }

  static Logger get logger => Logger('AppLogger');
}
