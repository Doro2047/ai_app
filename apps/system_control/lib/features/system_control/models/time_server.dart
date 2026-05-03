library;

import 'package:equatable/equatable.dart';

enum ServerStatus {
  online,
  offline,
  unknown;

  String get displayName {
    switch (this) {
      case online:
        return '\u5728\u7EBF';
      case offline:
        return '\u79BB\u7EBF';
      case unknown:
        return '\u672A\u77E5';
    }
  }
}

class TimeServer extends Equatable {
  final String name;
  final String host;
  final String description;
  final ServerStatus status;

  const TimeServer({
    required this.name,
    required this.host,
    this.description = '',
    this.status = ServerStatus.unknown,
  });

  static List<TimeServer> get commonServers => [
        const TimeServer(
          name: '\u963F\u91CC\u4E91 NTP',
          host: 'ntp.aliyun.com',
          description: '\u963F\u91CC\u4E91\u516C\u5171 NTP \u670D\u52A1\u5668',
        ),
        const TimeServer(
          name: '\u817E\u8BAF\u4E91 NTP',
          host: 'ntp.tencent.com',
          description: '\u817E\u8BAF\u4E91\u516C\u5171 NTP \u670D\u52A1\u5668',
        ),
        const TimeServer(
          name: '\u4E2D\u56FD NTP',
          host: 'cn.pool.ntp.org',
          description: '\u4E2D\u56FD NTP \u6C60',
        ),
        const TimeServer(
          name: 'Windows Time',
          host: 'time.windows.com',
          description: '\u5FAE\u8F6F\u65F6\u95F4\u670D\u52A1\u5668',
        ),
        const TimeServer(
          name: 'NIST',
          host: 'time.nist.gov',
          description: '\u7F8E\u56FD\u56FD\u5BB6\u6807\u51C6\u4E0E\u6280\u672F\u7814\u7A76\u9662',
        ),
        const TimeServer(
          name: 'Cloudflare NTP',
          host: 'time.cloudflare.com',
          description: 'Cloudflare \u516C\u5171 NTP \u670D\u52A1\u5668',
        ),
      ];

  TimeServer copyWith({
    String? name,
    String? host,
    String? description,
    ServerStatus? status,
  }) {
    return TimeServer(
      name: name ?? this.name,
      host: host ?? this.host,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [name, host, description, status];
}
