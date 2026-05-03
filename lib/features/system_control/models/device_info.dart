/// 设备信息数据模型
library;

import 'package:equatable/equatable.dart';

/// 设备类型
enum DeviceType {
  bluetooth,
  wifi,
  network;

  String get displayName {
    switch (this) {
      case bluetooth:
        return '蓝牙';
      case wifi:
        return 'WiFi';
      case network:
        return '以太网';
    }
  }
}

/// 设备状态
enum DeviceStatus {
  enabled,
  disabled,
  unknown;

  String get displayName {
    switch (this) {
      case enabled:
        return '已启用';
      case disabled:
        return '已禁用';
      case unknown:
        return '未知';
    }
  }
}

/// 设备信息
class DeviceInfo extends Equatable {
  /// 设备名称
  final String name;

  /// 设备类型
  final DeviceType type;

  /// 设备状态
  final DeviceStatus status;

  /// 设备描述
  final String description;

  const DeviceInfo({
    required this.name,
    required this.type,
    this.status = DeviceStatus.unknown,
    this.description = '',
  });

  DeviceInfo copyWith({
    String? name,
    DeviceType? type,
    DeviceStatus? status,
    String? description,
  }) {
    return DeviceInfo(
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [name, type, status, description];
}
