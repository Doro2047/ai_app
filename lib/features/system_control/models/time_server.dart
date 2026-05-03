/// 时间服务器数据模型
library;

import 'package:equatable/equatable.dart';

/// 时间服务器状态
enum ServerStatus {
  online,
  offline,
  unknown;

  String get displayName {
    switch (this) {
      case online:
        return '在线';
      case offline:
        return '离线';
      case unknown:
        return '未知';
    }
  }
}

/// 时间服务器
class TimeServer extends Equatable {
  /// 服务器名称
  final String name;

  /// 服务器地址
  final String host;

  /// 服务器描述
  final String description;

  /// 服务器状态
  final ServerStatus status;

  const TimeServer({
    required this.name,
    required this.host,
    this.description = '',
    this.status = ServerStatus.unknown,
  });

  /// 常用 NTP 服务器列表
  static List<TimeServer> get commonServers => [
        const TimeServer(
          name: '阿里云 NTP',
          host: 'ntp.aliyun.com',
          description: '阿里云公共 NTP 服务器',
        ),
        const TimeServer(
          name: '腾讯云 NTP',
          host: 'ntp.tencent.com',
          description: '腾讯云公共 NTP 服务器',
        ),
        const TimeServer(
          name: '中国 NTP',
          host: 'cn.pool.ntp.org',
          description: '中国 NTP 池',
        ),
        const TimeServer(
          name: 'Windows Time',
          host: 'time.windows.com',
          description: '微软时间服务器',
        ),
        const TimeServer(
          name: 'NIST',
          host: 'time.nist.gov',
          description: '美国国家标准与技术研究院',
        ),
        const TimeServer(
          name: 'Cloudflare NTP',
          host: 'time.cloudflare.com',
          description: 'Cloudflare 公共 NTP 服务器',
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
