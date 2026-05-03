/// 时间同步结果数据模型
library;

import 'package:equatable/equatable.dart';

/// 时间同步结果
class TimeSyncResult extends Equatable {
  /// 服务器名称
  final String serverName;

  /// 本地时间
  final String localTime;

  /// 服务器时间
  final String serverTime;

  /// 时间偏移量
  final Duration offset;

  /// 是否同步成功
  final bool success;

  /// 错误信息
  final String? error;

  const TimeSyncResult({
    required this.serverName,
    required this.localTime,
    required this.serverTime,
    required this.offset,
    this.success = false,
    this.error,
  });

  /// 偏移量的人类可读描述
  String get offsetDescription {
    final seconds = offset.inSeconds;
    if (seconds == 0) {
      return '无偏移';
    } else if (seconds > 0) {
      return '服务器快 ${seconds.abs()} 秒';
    } else {
      return '服务器慢 ${seconds.abs()} 秒';
    }
  }

  TimeSyncResult copyWith({
    String? serverName,
    String? localTime,
    String? serverTime,
    Duration? offset,
    bool? success,
    String? error,
    bool clearError = false,
  }) {
    return TimeSyncResult(
      serverName: serverName ?? this.serverName,
      localTime: localTime ?? this.localTime,
      serverTime: serverTime ?? this.serverTime,
      offset: offset ?? this.offset,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [serverName, localTime, serverTime, offset, success, error];
}
