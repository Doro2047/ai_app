/// 电源控制 Repository
///
/// 平台条件分支实现：
/// - Windows: 使用 shutdown 和 rundll32 命令
/// - Android: 所有方法返回 false，提示不可用
library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:process_run/shell.dart';

/// 电源操作类型
enum PowerAction {
  shutdown,
  restart,
  sleep,
  hibernate,
  lock;

  String get displayName {
    switch (this) {
      case shutdown:
        return '关机';
      case restart:
        return '重启';
      case sleep:
        return '睡眠';
      case hibernate:
        return '休眠';
      case lock:
        return '锁定';
    }
  }

  String get confirmationMessage {
    switch (this) {
      case shutdown:
        return '确定要关机吗？未保存的数据将会丢失。';
      case restart:
        return '确定要重启计算机吗？未保存的数据将会丢失。';
      case sleep:
        return '确定要让计算机进入睡眠状态吗？';
      case hibernate:
        return '确定要休眠吗？';
      case lock:
        return '确定要锁定计算机吗？';
    }
  }
}

class PowerControlRepository {
  final Logger _logger = Logger('PowerControlRepository');

  /// 执行电源操作
  Future<bool> executePowerAction(PowerAction action) async {
    if (Platform.isWindows) {
      return _executeWindows(action);
    } else {
      return _executeAndroid(action);
    }
  }

  /// 关机
  Future<bool> shutdown() async {
    return executePowerAction(PowerAction.shutdown);
  }

  /// 重启
  Future<bool> restart() async {
    return executePowerAction(PowerAction.restart);
  }

  /// 睡眠
  Future<bool> sleep() async {
    return executePowerAction(PowerAction.sleep);
  }

  /// 休眠
  Future<bool> hibernate() async {
    return executePowerAction(PowerAction.hibernate);
  }

  /// 锁定
  Future<bool> lock() async {
    return executePowerAction(PowerAction.lock);
  }

  /// Windows 电源操作
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
      _logger.info('电源操作已执行: ${action.displayName}');
      return true;
    } catch (e) {
      _logger.warning('电源操作执行失败: ${action.displayName}, 错误=$e');
      return false;
    }
  }

  /// Android 电源操作（不可用）
  Future<bool> _executeAndroid(PowerAction action) async {
    _logger.warning('Android 不支持 ${action.displayName} 操作');
    return false;
  }

  /// 检查平台是否支持电源操作
  bool get isPowerActionSupported {
    return Platform.isWindows;
  }
}
