library;

import 'package:equatable/equatable.dart';

class NtpConfig extends Equatable {
  final String server;
  final int port;
  final Duration timeout;
  final bool autoSync;
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

  static const NtpConfig defaultConfig = NtpConfig();

  @override
  List<Object?> get props => [server, port, timeout, autoSync, syncInterval];
}
