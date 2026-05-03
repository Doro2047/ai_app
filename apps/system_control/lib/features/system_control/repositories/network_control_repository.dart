library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:process_run/shell.dart';

import '../models/models.dart';

class NetworkControlRepository {
  final Logger _logger = Logger('NetworkControlRepository');

  Future<bool> toggleWifi(bool enabled) async {
    if (Platform.isWindows) {
      return _toggleWifiWindows(enabled);
    } else {
      return _toggleWifiAndroid(enabled);
    }
  }

  Future<bool> _toggleWifiWindows(bool enabled) async {
    final shell = Shell();
    try {
      if (enabled) {
        await shell.run('netsh interface set interface "Wi-Fi" admin=enable');
      } else {
        await shell.run('netsh interface set interface "Wi-Fi" admin=disable');
      }
      _logger.info('WiFi ${enabled ? "enabled" : "disabled"}');
      return true;
    } catch (e) {
      _logger.warning('Failed to toggle WiFi: $e');
      return false;
    }
  }

  Future<bool> _toggleWifiAndroid(bool enabled) async {
    _logger.info('Android WiFi control requires Platform Channel support');
    return false;
  }

  Future<bool> toggleBluetooth(bool enabled) async {
    if (Platform.isWindows) {
      return _toggleBluetoothWindows(enabled);
    } else {
      return _toggleBluetoothAndroid(enabled);
    }
  }

  Future<bool> _toggleBluetoothWindows(bool enabled) async {
    final shell = Shell();
    try {
      final script = enabled
          ? '''
            \$device = Get-PnpDevice -Class Bluetooth | Where-Object { \$_.Status -eq 'OK' } | Select-Object -First 1
            if (\$device) { Enable-PnpDevice -InstanceId \$device.InstanceId -Confirm:\$false }
          '''
          : '''
            \$device = Get-PnpDevice -Class Bluetooth | Where-Object { \$_.Status -eq 'OK' } | Select-Object -First 1
            if (\$device) { Disable-PnpDevice -InstanceId \$device.InstanceId -Confirm:\$false }
          ''';
      await shell.run('powershell -Command "$script"');
      _logger.info('Bluetooth ${enabled ? "enabled" : "disabled"}');
      return true;
    } catch (e) {
      _logger.warning('Failed to toggle Bluetooth: $e');
      return false;
    }
  }

  Future<bool> _toggleBluetoothAndroid(bool enabled) async {
    _logger.info('Android Bluetooth control requires Platform Channel support');
    return false;
  }

  Future<bool> toggleEthernet(bool enabled) async {
    if (Platform.isWindows) {
      return _toggleEthernetWindows(enabled);
    } else {
      return _toggleEthernetAndroid(enabled);
    }
  }

  Future<bool> _toggleEthernetWindows(bool enabled) async {
    final shell = Shell();
    try {
      final result = await shell.run('netsh interface show interface');
      final output = result.map((e) => e.outText).join('\n');

      String interfaceName = '\u4EE5\u592A\u7F51';
      final lines = output.split('\n');
      for (final line in lines) {
        if (line.contains('Ethernet') || line.contains('\u4EE5\u592A\u7F51')) {
          final parts = line.split(RegExp(r'\s{2,}'));
          if (parts.length >= 4) {
            interfaceName = parts.last.trim();
            break;
          }
        }
      }

      if (enabled) {
        await shell.run(
            'netsh interface set interface "$interfaceName" admin=enable');
      } else {
        await shell.run(
            'netsh interface set interface "$interfaceName" admin=disable');
      }
      _logger.info('Ethernet ${enabled ? "enabled" : "disabled"}');
      return true;
    } catch (e) {
      _logger.warning('Failed to toggle Ethernet: $e');
      return false;
    }
  }

  Future<bool> _toggleEthernetAndroid(bool enabled) async {
    _logger.info('Android does not support Ethernet control');
    return false;
  }

  Future<List<DeviceInfo>> getNetworkDevices() async {
    if (Platform.isWindows) {
      return _getNetworkDevicesWindows();
    } else {
      return _getNetworkDevicesAndroid();
    }
  }

  Future<List<DeviceInfo>> _getNetworkDevicesWindows() async {
    final shell = Shell();
    final devices = <DeviceInfo>[];

    try {
      final result = await shell.run('netsh interface show interface');
      final output = result.map((e) => e.outText).join('\n');

      final lines = output.split('\n');
      for (final line in lines) {
        if (line.contains('Wi-Fi') || line.contains('WLAN')) {
          final enabled = !line.contains('\u5DF2\u7981\u7528') && !line.contains('disable');
          devices.add(DeviceInfo(
            name: 'Wi-Fi',
            type: DeviceType.wifi,
            status: enabled ? DeviceStatus.enabled : DeviceStatus.disabled,
            description: '\u65E0\u7EBF\u7F51\u7EDC\u8FDE\u63A5',
          ));
        } else if (line.contains('\u4EE5\u592A\u7F51') || line.contains('Ethernet')) {
          final enabled = !line.contains('\u5DF2\u7981\u7528') && !line.contains('disable');
          devices.add(DeviceInfo(
            name: '\u4EE5\u592A\u7F51',
            type: DeviceType.network,
            status: enabled ? DeviceStatus.enabled : DeviceStatus.disabled,
            description: '\u6709\u7EBF\u7F51\u7EDC\u8FDE\u63A5',
          ));
        }
      }

      if (devices.isEmpty) {
        devices.add(const DeviceInfo(
          name: 'Wi-Fi',
          type: DeviceType.wifi,
          status: DeviceStatus.unknown,
          description: '\u65E0\u7EBF\u7F51\u7EDC\u8FDE\u63A5',
        ));
        devices.add(const DeviceInfo(
          name: '\u4EE5\u592A\u7F51',
          type: DeviceType.network,
          status: DeviceStatus.unknown,
          description: '\u6709\u7EBF\u7F51\u7EDC\u8FDE\u63A5',
        ));
      }

      try {
        final btResult = await shell.run(
            'powershell -Command "Get-PnpDevice -Class Bluetooth | Where-Object { \$_.Status -eq \'OK\' } | Select-Object -First 1"');
        final btOutput = btResult.map((e) => e.outText).join('\n');
        final btEnabled = btOutput.contains('OK');
        devices.add(DeviceInfo(
          name: '\u84DD\u7259',
          type: DeviceType.bluetooth,
          status: btEnabled ? DeviceStatus.enabled : DeviceStatus.disabled,
          description: '\u84DD\u7259\u8BBE\u5907\u8FDE\u63A5',
        ));
      } catch (e) {
        devices.add(const DeviceInfo(
          name: '\u84DD\u7259',
          type: DeviceType.bluetooth,
          status: DeviceStatus.unknown,
          description: '\u84DD\u7259\u8BBE\u5907\u8FDE\u63A5',
        ));
      }
    } catch (e) {
      _logger.warning('Failed to get network devices: $e');
      devices.addAll([
        const DeviceInfo(
          name: 'Wi-Fi',
          type: DeviceType.wifi,
          status: DeviceStatus.unknown,
          description: '\u65E0\u7EBF\u7F51\u7EDC\u8FDE\u63A5',
        ),
        const DeviceInfo(
          name: '\u84DD\u7259',
          type: DeviceType.bluetooth,
          status: DeviceStatus.unknown,
          description: '\u84DD\u7259\u8BBE\u5907\u8FDE\u63A5',
        ),
        const DeviceInfo(
          name: '\u4EE5\u592A\u7F51',
          type: DeviceType.network,
          status: DeviceStatus.unknown,
          description: '\u6709\u7EBF\u7F51\u7EDC\u8FDE\u63A5',
        ),
      ]);
    }

    return devices;
  }

  Future<List<DeviceInfo>> _getNetworkDevicesAndroid() async {
    return [
      const DeviceInfo(
        name: 'Wi-Fi',
        type: DeviceType.wifi,
        status: DeviceStatus.unknown,
        description: '\u65E0\u7EBF\u7F51\u7EDC\u8FDE\u63A5 (Android)',
      ),
      const DeviceInfo(
        name: '\u84DD\u7259',
        type: DeviceType.bluetooth,
        status: DeviceStatus.unknown,
        description: '\u84DD\u7259\u8BBE\u5907\u8FDE\u63A5 (Android)',
      ),
      const DeviceInfo(
        name: '\u79FB\u52A8\u6570\u636E',
        type: DeviceType.network,
        status: DeviceStatus.unknown,
        description: '\u79FB\u52A8\u6570\u636E\u7F51\u7EDC (Android)',
      ),
    ];
  }
}
