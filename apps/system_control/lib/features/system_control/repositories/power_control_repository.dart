library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:process_run/shell.dart';

enum PowerAction {
  shutdown,
  restart,
  sleep,
  hibernate,
  lock;

  String get displayName {
    switch (this) {
      case shutdown:
        return '\u5173\u673A';
      case restart:
        return '\u91CD\u542F';
      case sleep:
        return '\u7761\u7720';
      case hibernate:
        return '\u4F11\u7720';
      case lock:
        return '\u9501\u5B9A';
    }
  }

  String get confirmationMessage {
    switch (this) {
      case shutdown:
        return '\u786E\u5B9A\u8981\u5173\u673A\u5417\uFF1F\u672A\u4FDD\u5B58\u7684\u6570\u636E\u5C06\u4F1A\u4E22\u5931\u3002';
      case restart:
        return '\u786E\u5B9A\u8981\u91CD\u542F\u8BA1\u7B97\u673A\u5417\uFF1F\u672A\u4FDD\u5B58\u7684\u6570\u636E\u5C06\u4F1A\u4E22\u5931\u3002';
      case sleep:
        return '\u786E\u5B9A\u8981\u8BA9\u8BA1\u7B97\u673A\u8FDB\u5165\u7761\u7720\u72B6\u6001\u5417\uFF1F';
      case hibernate:
        return '\u786E\u5B9A\u8981\u4F11\u7720\u5417\uFF1F';
      case lock:
        return '\u786E\u5B9A\u8981\u9501\u5B9A\u8BA1\u7B97\u673A\u5417\uFF1F';
    }
  }
}

class PowerControlRepository {
  final Logger _logger = Logger('PowerControlRepository');

  Future<bool> executePowerAction(PowerAction action) async {
    if (Platform.isWindows) {
      return _executeWindows(action);
    } else {
      return _executeAndroid(action);
    }
  }

  Future<bool> shutdown() async {
    return executePowerAction(PowerAction.shutdown);
  }

  Future<bool> restart() async {
    return executePowerAction(PowerAction.restart);
  }

  Future<bool> sleep() async {
    return executePowerAction(PowerAction.sleep);
  }

  Future<bool> hibernate() async {
    return executePowerAction(PowerAction.hibernate);
  }

  Future<bool> lock() async {
    return executePowerAction(PowerAction.lock);
  }

  Future<bool> _executeWindows(PowerAction action) async {
    final shell = Shell();
    try {
      switch (action) {
        case PowerAction.shutdown:
          await shell.run('shutdown /s /t 0');
          break;
        case PowerAction.restart:
          await shell.run('shutdown /r /t 0');
          break;
        case PowerAction.sleep:
          await shell.run('rundll32 powrprof.dll,SetSuspendState Sleep');
          break;
        case PowerAction.hibernate:
          await shell.run('shutdown /h');
          break;
        case PowerAction.lock:
          await shell.run('rundll32 user32.dll,LockWorkStation');
          break;
      }
      _logger.info('Power action executed: ${action.displayName}');
      return true;
    } catch (e) {
      _logger.warning('Power action failed: ${action.displayName}, error=$e');
      return false;
    }
  }

  Future<bool> _executeAndroid(PowerAction action) async {
    _logger.warning('Android does not support ${action.displayName}');
    return false;
  }

  bool get isPowerActionSupported {
    return Platform.isWindows;
  }
}
