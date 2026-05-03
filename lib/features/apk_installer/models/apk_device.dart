/// APK 安装器设备模型
///
/// 表示一个连接的 Android 设备。
library;

import 'package:equatable/equatable.dart';

/// Android 设备信息
class ApkDevice extends Equatable {
  /// 设备唯一标识
  final String id;

  /// 设备显示名称
  final String name;

  /// ADB 序列号
  final String serialNumber;

  /// 设备状态 (online/offline/unauthorized)
  final String status;

  /// 设备型号
  final String model;

  /// Android 版本号
  final String androidVersion;

  const ApkDevice({
    required this.id,
    required this.name,
    required this.serialNumber,
    required this.status,
    this.model = '未知设备',
    this.androidVersion = '未知',
  });

  /// 是否在线
  bool get isOnline => status == 'online' || status == 'device';

  /// 创建在线设备实例
  factory ApkDevice.fromAdbOutput(String serial, String state) {
    return ApkDevice(
      id: serial,
      name: _extractDeviceName(serial),
      serialNumber: serial,
      status: state,
    );
  }

  static String _extractDeviceName(String serial) {
    // 尝试从序列号中提取可读名称
    if (serial.contains(':')) {
      // 网络地址格式
      final parts = serial.split(':');
      return '网络设备: ${parts[0]}';
    }
    // 其他格式，使用序列号前8位
    return serial.length > 8 ? '${serial.substring(0, 8)}...' : serial;
  }

  Map<String, dynamic> toDict() {
    return {
      'id': id,
      'name': name,
      'serialNumber': serialNumber,
      'status': status,
      'model': model,
      'androidVersion': androidVersion,
    };
  }

  factory ApkDevice.fromDict(Map<String, dynamic> data) {
    return ApkDevice(
      id: data['id'] as String,
      name: data['name'] as String,
      serialNumber: data['serialNumber'] as String,
      status: data['status'] as String,
      model: data['model'] as String? ?? '未知设备',
      androidVersion: data['androidVersion'] as String? ?? '未知',
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        serialNumber,
        status,
        model,
        androidVersion,
      ];
}
