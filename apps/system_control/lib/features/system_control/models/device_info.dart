library;

import 'package:equatable/equatable.dart';

enum DeviceType {
  bluetooth,
  wifi,
  network;

  String get displayName {
    switch (this) {
      case bluetooth:
        return '\u84DD\u7259';
      case wifi:
        return 'WiFi';
      case network:
        return '\u4EE5\u592A\u7F51';
    }
  }
}

enum DeviceStatus {
  enabled,
  disabled,
  unknown;

  String get displayName {
    switch (this) {
      case enabled:
        return '\u5DF2\u542F\u7528';
      case disabled:
        return '\u5DF2\u7981\u7528';
      case unknown:
        return '\u672A\u77E5';
    }
  }
}

class DeviceInfo extends Equatable {
  final String name;
  final DeviceType type;
  final DeviceStatus status;
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
