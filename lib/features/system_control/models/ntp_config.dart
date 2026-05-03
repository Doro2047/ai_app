/// NTP 配置数据模型
library;

import 'package:equatable/equatable.dart';

/// NTP 配置
class NtpConfig extends Equatable {
  /// NTP 服务器地址
  final String server;

  /// 端口号
  final int port;

  /// 超时时间
  final Duration timeout;

  /// 是否自动同步
  final bool autoSync;

  /// 同步间隔
  final Duration syncInterval;

  const NtpConfig({
    this.server = 'ntp.aliyun.com',
    this.port = 123,
    this.timeout = const Duration(seconds: 5),
    this.autoSync = false,
    this.syncInterval = const Duration(hours: 1),
  });

  NtpConfig copyWith({
    String? server,
    int? port,
    Duration? timeout,
    bool? autoSync,
    Duration? syncInterval,
  }) {
    return NtpConfig(
      server: server ?? this.server,
      port: port ?? this.port,
      timeout: timeout ?? this.timeout,
      autoSync: autoSync ?? this.autoSync,
      syncInterval: syncInterval ?? this.syncInterval,
    );
  }

  /// 默认配置
  static const NtpConfig defaultConfig = NtpConfig();

  @override
  List<Object?> get props => [server, port, timeout, autoSync, syncInterval];
}
