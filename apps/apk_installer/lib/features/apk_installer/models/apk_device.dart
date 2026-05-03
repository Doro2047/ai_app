library;

import 'package:equatable/equatable.dart';

class ApkDevice extends Equatable {
  final String id;
  final String name;
  final String serialNumber;
  final String status;
  final String model;
  final String androidVersion;

  const ApkDevice({
    required this.id,
    required this.name,
    required this.serialNumber,
    required this.status,
    this.model = 'Unknown',
    this.androidVersion = 'Unknown',
  });

  bool get isOnline => status == 'online' || status == 'device';

  factory ApkDevice.fromAdbOutput(String serial, String state) {
    return ApkDevice(
      id: serial,
      name: _extractDeviceName(serial),
      serialNumber: serial,
      status: state,
    );
  }

  static String _extractDeviceName(String serial) {
    if (serial.contains(':')) {
      final parts = serial.split(':');
      return 'Network: ${parts[0]}';
    }
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
      model: data['model'] as String? ?? 'Unknown',
      androidVersion: data['androidVersion'] as String? ?? 'Unknown',
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
