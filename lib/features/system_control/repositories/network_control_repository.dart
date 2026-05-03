/// 网络设备控制 Repository
///
/// 平台条件分支实现：
/// - Windows: 使用 netsh 和 PowerShell 命令
/// - Android: 功能降级，提示用户手动操作
library;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:process_run/shell.dart';

import '../models/models.dart';

class NetworkControlRepository {
  final Logger _logger = Logger('NetworkControlRepository');

  /// 切换 WiFi 状态
  Future<bool> toggleWifi(bool enabled) async {
    if (Platform.isWindows) {
      return _toggleWifiWindows(enabled);
    } else {
      return _toggleWifiAndroid(enabled);
    }
  }

  /// Windows 切换 WiFi
  Future<bool> _toggleWifiWindows(bool enabled) async {
    final shell = Shell();
    try {
      if (enabled) {
        await shell.run('netsh interface set interface "Wi-Fi" admin=enable');
      } else {
        await shell.run('netsh interface set interface "Wi-Fi" admin=disable');
      }
      _logger.info('WiFi 已${enabled ? '启用' : '禁用'}');
      return true;
    } catch (e) {
      _logger.warning('切换 WiFi 状态失败: $e');
      return false;
    }
  }

  /// Android 切换 WiFi（功能降级）
  Future<bool> _toggleWifiAndroid(bool enabled) async {
    _logger.info('Android WiFi 控制需要 Platform Channel 支持');
    return false;
  }

  /// 切换蓝牙状态
  Future<bool> toggleBluetooth(bool enabled) async {
    if (Platform.isWindows) {
      return _toggleBluetoothWindows(enabled);
    } else {
      return _toggleBluetoothAndroid(enabled);
    }
  }

  /// Windows 切换蓝牙
  Future<bool> _toggleBluetoothWindows(bool enabled) async {
    final shell = Shell();
    try {
      // 使用 PowerShell 获取蓝牙设备并启用/禁用
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
      _logger.info('蓝牙已${enabled ? '启用' : '禁用'}');
      return true;
    } catch (e) {
      _logger.warning('切换蓝牙状态失败: $e');
      return false;
    }
  }

  /// Android 切换蓝牙（功能降级）
  Future<bool> _toggleBluetoothAndroid(bool enabled) async {
    _logger.info('Android 蓝牙控制需要 Platform Channel 支持');
    return false;
  }

  /// 切换以太网状态
  Future<bool> toggleEthernet(bool enabled) async {
    if (Platform.isWindows) {
      return _toggleEthernetWindows(enabled);
    } else {
      return _toggleEthernetAndroid(enabled);
    }
  }

  /// Windows 切换以太网
  Future<bool> _toggleEthernetWindows(bool enabled) async {
    final shell = Shell();
    try {
      // 获取以太网接口名称
      final result = await shell.run('netsh interface show interface');
      final output = result.map((e) => e.outText).join('\n');

      String interfaceName = '以太网';
      // 尝试检测实际以太网接口名称
      final lines = output.split('\n');
      for (final line in lines) {
        if (line.contains('Ethernet') || line.contains('以太网')) {
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
      _logger.info('以太网已${enabled ? '启用' : '禁用'}');
      return true;
    } catch (e) {
      _logger.warning('切换以太网状态失败: $e');
      return false;
    }
  }

  /// Android 切换以太网（不支持）
  Future<bool> _toggleEthernetAndroid(bool enabled) async {
    _logger.info('Android 不支持以太网控制');
    return false;
  }

  /// 获取网络设备列表
  Future<List<DeviceInfo>> getNetworkDevices() async {
    if (Platform.isWindows) {
      return _getNetworkDevicesWindows();
    } else {
      return _getNetworkDevicesAndroid();
    }
  }

  /// Windows 获取网络设备列表
  Future<List<DeviceInfo>> _getNetworkDevicesWindows() async {
    final shell = Shell();
    final devices = <DeviceInfo>[];

    try {
      // 获取网络接口信息
      final result = await shell.run('netsh interface show interface');
      final output = result.map((e) => e.outText).join('\n');

      final lines = output.split('\n');
      for (final line in lines) {
        if (line.contains('Wi-Fi') || line.contains('WLAN')) {
          final enabled = !line.contains('已禁用') && !line.contains('disable');
          devices.add(DeviceInfo(
            name: 'Wi-Fi',
            type: DeviceType.wifi,
            status: enabled ? DeviceStatus.enabled : DeviceStatus.disabled,
            description: '无线网络连接',
          ));
        } else if (line.contains('以太网') || line.contains('Ethernet')) {
          final enabled = !line.contains('已禁用') && !line.contains('disable');
          devices.add(DeviceInfo(
            name: '以太网',
            type: DeviceType.network,
            status: enabled ? DeviceStatus.enabled : DeviceStatus.disabled,
            description: '有线网络连接',
          ));
        }
      }

      // 如果未检测到设备，添加默认设备
      if (devices.isEmpty) {
        devices.add(const DeviceInfo(
          name: 'Wi-Fi',
          type: DeviceType.wifi,
          status: DeviceStatus.unknown,
          description: '无线网络连接',
        ));
        devices.add(const DeviceInfo(
          name: '以太网',
          type: DeviceType.network,
          status: DeviceStatus.unknown,
          description: '有线网络连接',
        ));
      }

      // 获取蓝牙状态
      try {
        final btResult = await shell.run(
            'powershell -Command "Get-PnpDevice -Class Bluetooth | Where-Object { \$_.Status -eq \'OK\' } | Select-Object -First 1"');
        final btOutput = btResult.map((e) => e.outText).join('\n');
        final btEnabled = btOutput.contains('OK');
        devices.add(DeviceInfo(
          name: '蓝牙',
          type: DeviceType.bluetooth,
          status: btEnabled ? DeviceStatus.enabled : DeviceStatus.disabled,
          description: '蓝牙设备连接',
        ));
      } catch (e) {
        devices.add(const DeviceInfo(
          name: '蓝牙',
          type: DeviceType.bluetooth,
          status: DeviceStatus.unknown,
          description: '蓝牙设备连接',
        ));
      }
    } catch (e) {
      _logger.warning('获取网络设备列表失败: $e');
      // 返回默认设备列表
      devices.addAll([
        const DeviceInfo(
          name: 'Wi-Fi',
          type: DeviceType.wifi,
          status: DeviceStatus.unknown,
          description: '无线网络连接',
        ),
        const DeviceInfo(
          name: '蓝牙',
          type: DeviceType.bluetooth,
          status: DeviceStatus.unknown,
          description: '蓝牙设备连接',
        ),
        const DeviceInfo(
          name: '以太网',
          type: DeviceType.network,
          status: DeviceStatus.unknown,
          description: '有线网络连接',
        ),
      ]);
    }

    return devices;
  }

  /// Android 获取网络设备列表（有限信息）
  Future<List<DeviceInfo>> _getNetworkDevicesAndroid() async {
    return [
      const DeviceInfo(
        name: 'Wi-Fi',
        type: DeviceType.wifi,
        status: DeviceStatus.unknown,
        description: '无线网络连接（Android 平台）',
      ),
      const DeviceInfo(
        name: '蓝牙',
        type: DeviceType.bluetooth,
        status: DeviceStatus.unknown,
        description: '蓝牙设备连接（Android 平台）',
      ),
      const DeviceInfo(
        name: '移动数据',
        type: DeviceType.network,
        status: DeviceStatus.unknown,
        description: '移动数据网络（Android 平台）',
      ),
    ];
  }
}
