/// 硬件信息仓库
///
/// 使用 Isolate 收集硬件信息，支持缓存和实时监控。
/// Windows 使用 WMI/PowerShell，Android 降级显示基本信息。
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:process_run/shell_run.dart';

import '../models/hardware_info.dart';

/// 硬件信息仓库
class HardwareRepository {
  HardwareInfo? _cachedInfo;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  Timer? _monitorTimer;

  /// 获取硬件信息（带缓存）
  Future<HardwareInfo> getHardwareInfo() async {
    if (_cachedInfo != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedInfo!;
    }

    final info = await _collectHardwareInfo();
    _cachedInfo = info;
    _cacheTime = DateTime.now();
    return info;
  }

  /// 获取实时状态
  Future<RealtimeStats> getRealtimeStats() async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return const RealtimeStats();
    }

    try {
      if (Platform.isWindows) {
        return await _collectWindowsRealtimeStats();
      }
      // 其他平台降级
      return const RealtimeStats();
    } catch (e) {
      debugPrint('获取实时状态失败: $e');
      return const RealtimeStats();
    }
  }

  /// 开始实时监控
  Stream<RealtimeStats> startMonitoring({Duration interval = const Duration(seconds: 2)}) async* {
    while (true) {
      try {
        final stats = await getRealtimeStats();
        yield stats;
      } catch (e) {
        debugPrint('监控数据获取失败: $e');
        yield const RealtimeStats();
      }
      await Future.delayed(interval);
    }
  }

  /// 停止监控
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  /// 清除缓存
  void clearCache() {
    _cachedInfo = null;
    _cacheTime = null;
  }

  // ============================================================
  // Windows 硬件信息采集
  // ============================================================

  Future<HardwareInfo> _collectHardwareInfo() async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return const HardwareInfo();
    }

    try {
      if (Platform.isWindows) {
        return await _collectWindowsHardwareInfo();
      }
      return const HardwareInfo();
    } catch (e) {
      debugPrint('采集硬件信息失败: $e');
      return const HardwareInfo();
    }
  }

  Future<HardwareInfo> _collectWindowsHardwareInfo() async {
    final shell = Shell();

    // 并行采集各类信息
    final results = await Future.wait([
      _collectComputerInfo(shell),
      _collectSystemInfo(shell),
      _collectCpuInfo(shell),
      _collectMemoryInfo(shell),
      _collectDiskInfo(shell),
      _collectGpuInfo(shell),
      _collectNetworkInfo(shell),
    ]);

    return HardwareInfo(
      computer: results[0] as ComputerInfo,
      system: results[1] as SystemInfo,
      cpu: results[2] as CpuInfo,
      memory: results[3] as MemoryInfo,
      disks: results[4] as List<DiskInfo>,
      gpus: results[5] as List<GpuInfo>,
      networks: results[6] as List<NetworkInfo>,
    );
  }

  Future<ComputerInfo> _collectComputerInfo(Shell shell) async {
    try {
      final result = await shell.run('''
        Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model | ConvertTo-Json
      ''');
      final data = _parseJsonOutput(result.outText);
      if (data == null) return const ComputerInfo();

      final biosResult = await shell.run('''
        Get-CimInstance Win32_BIOS | Select-Object SMBIOSBIOSVersion, ReleaseDate, Manufacturer, SMBIOSMajorVersion | ConvertTo-Json
      ''');
      final biosData = _parseJsonOutput(biosResult.outText);

      final boardResult = await shell.run('''
        Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product | ConvertTo-Json
      ''');
      final boardData = _parseJsonOutput(boardResult.outText);

      return ComputerInfo(
        manufacturer: data['Manufacturer']?.toString() ?? '未知',
        model: data['Model']?.toString() ?? '未知',
        productName: data['Model']?.toString() ?? '未知',
        serialNumber: data['SerialNumber']?.toString() ?? '未知',
        biosVersion: biosData?['SMBIOSBIOSVersion']?.toString() ?? '未知',
        biosDate: biosData?['ReleaseDate']?.toString() ?? '未知',
        biosVendor: biosData?['Manufacturer']?.toString() ?? '未知',
        smbiosVersion: biosData?['SMBIOSMajorVersion']?.toString() ?? '未知',
        baseboardManufacturer: boardData?['Manufacturer']?.toString() ?? '未知',
        baseboardProduct: boardData?['Product']?.toString() ?? '未知',
      );
    } catch (e) {
      debugPrint('采集计算机信息失败: $e');
      return const ComputerInfo();
    }
  }

  Future<SystemInfo> _collectSystemInfo(Shell shell) async {
    try {
      final result = await shell.run('''
        \$os = Get-CimInstance Win32_OperatingSystem
        [PSCustomObject]@{
          Caption = \$os.Caption
          Version = \$os.Version
          BuildNumber = \$os.BuildNumber
          OSArchitecture = \$os.OSArchitecture
          InstallDate = \$os.InstallDate
          CSName = \$os.CSName
          SystemDirectory = \$os.SystemDirectory
          LastBootUpTime = \$os.LastBootUpTime
        } | ConvertTo-Json
      ''');
      final data = _parseJsonOutput(result.outText);
      if (data == null) return const SystemInfo();

      return SystemInfo(
        osName: data['Caption']?.toString() ?? '未知',
        osVersion: data['Version']?.toString() ?? '未知',
        osBuild: data['BuildNumber']?.toString() ?? '未知',
        osArchitecture: data['OSArchitecture']?.toString() ?? '未知',
        installDate: data['InstallDate']?.toString() ?? '未知',
        computerName: data['CSName']?.toString() ?? '未知',
        userName: Platform.environment['USERNAME'] ?? '未知',
        systemDir: data['SystemDirectory']?.toString() ?? '未知',
        bootTime: data['LastBootUpTime']?.toString() ?? '未知',
      );
    } catch (e) {
      debugPrint('采集系统信息失败: $e');
      return const SystemInfo();
    }
  }

  Future<CpuInfo> _collectCpuInfo(Shell shell) async {
    try {
      final result = await shell.run('''
        Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, Manufacturer, Architecture, L2CacheSize, L3CacheSize | ConvertTo-Json
      ''');
      final data = _parseJsonOutput(result.outText);
      if (data == null) return const CpuInfo();

      return CpuInfo(
        name: data['Name']?.toString() ?? '未知',
        cores: data['NumberOfCores']?.toString() ?? '未知',
        threads: data['NumberOfLogicalProcessors']?.toString() ?? '未知',
        maxSpeed: data['MaxClockSpeed'] != null
            ? '${data['MaxClockSpeed']} MHz'
            : '未知',
        manufacturer: data['Manufacturer']?.toString() ?? '未知',
        architecture: data['Architecture']?.toString() ?? '未知',
        l2Cache: data['L2CacheSize'] != null
            ? '${data['L2CacheSize']} KB'
            : '未知',
        l3Cache: data['L3CacheSize'] != null
            ? '${data['L3CacheSize']} KB'
            : '未知',
        coreDescription: '${data['NumberOfCores'] ?? '?'} 核',
        threadDescription: '${data['NumberOfLogicalProcessors'] ?? '?'} 线程',
      );
    } catch (e) {
      debugPrint('采集CPU信息失败: $e');
      return const CpuInfo();
    }
  }

  Future<MemoryInfo> _collectMemoryInfo(Shell shell) async {
    try {
      final result = await shell.run('''
        \$os = Get-CimInstance Win32_OperatingSystem
        \$total = [math]::Round(\$os.TotalVisibleMemorySize / 1MB, 2)
        \$free = [math]::Round(\$os.FreePhysicalMemory / 1MB, 2)
        \$used = [math]::Round(\$total - \$free, 2)
        \$percent = [math]::Round((\$total - \$free) / \$total * 100, 1)
        [PSCustomObject]@{
          TotalGB = \$total
          FreeGB = \$free
          UsedGB = \$used
          UsedPercent = \$percent
        } | ConvertTo-Json
      ''');
      final data = _parseJsonOutput(result.outText);
      if (data == null) return const MemoryInfo();

      return MemoryInfo(
        total: '${data['TotalGB']} GB',
        available: '${data['FreeGB']} GB',
        used: '${data['UsedGB']} GB',
        usedPercent: '${data['UsedPercent']}%',
        capacity: '${data['TotalGB']} GB',
      );
    } catch (e) {
      debugPrint('采集内存信息失败: $e');
      return const MemoryInfo();
    }
  }

  Future<List<DiskInfo>> _collectDiskInfo(Shell shell) async {
    try {
      final result = await shell.run('''
        Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, Size, FreeSpace, FileSystem, VolumeSerialNumber | ConvertTo-Json
      ''');
      final data = _parseJsonListOutput(result.outText);
      if (data.isEmpty) return const [];

      return data.map((d) {
        final totalBytes = d['Size'] as int?;
        final freeBytes = d['FreeSpace'] as int?;
        final totalGB = totalBytes != null ? (totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2) : '0';
        final freeGB = freeBytes != null ? (freeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2) : '0';
        final usedGB = totalBytes != null && freeBytes != null
            ? ((totalBytes - freeBytes) / (1024 * 1024 * 1024)).toStringAsFixed(2)
            : '0';
        final usedPercent = totalBytes != null && totalBytes > 0 && freeBytes != null
            ? ((totalBytes - freeBytes) / totalBytes * 100).toStringAsFixed(1)
            : '0';

        return DiskInfo(
          drive: d['DeviceID']?.toString() ?? '未知',
          total: '$totalGB GB',
          free: '$freeGB GB',
          used: '$usedGB GB',
          usedPercent: '$usedPercent%',
          fileSystem: d['FileSystem']?.toString() ?? '未知',
          serial: d['VolumeSerialNumber']?.toString() ?? '未知',
        );
      }).toList();
    } catch (e) {
      debugPrint('采集磁盘信息失败: $e');
      return const [];
    }
  }

  Future<List<GpuInfo>> _collectGpuInfo(Shell shell) async {
    try {
      final result = await shell.run('''
        Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, AdapterRAM, VideoModeDescription | ConvertTo-Json
      ''');
      final data = _parseJsonListOutput(result.outText);
      if (data.isEmpty) return const [];

      return data.map((d) {
        final adapterRAM = d['AdapterRAM'] as int?;
        final memoryMB = adapterRAM != null ? (adapterRAM / (1024 * 1024)).toStringAsFixed(0) : '未知';

        return GpuInfo(
          name: d['Name']?.toString() ?? '未知',
          driverVersion: d['DriverVersion']?.toString() ?? '未知',
          memoryTotal: memoryMB != '未知' ? '$memoryMB MB' : '未知',
        );
      }).toList();
    } catch (e) {
      debugPrint('采集GPU信息失败: $e');
      return const [];
    }
  }

  Future<List<NetworkInfo>> _collectNetworkInfo(Shell shell) async {
    try {
      final result = await shell.run('''
        Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" | Select-Object Description, IPAddress, MACAddress, DefaultIPGateway, DNSServerSearchOrder, IPSubnet | ConvertTo-Json
      ''');
      final data = _parseJsonListOutput(result.outText);
      if (data.isEmpty) return const [];

      return data.map((d) {
        final ipList = d['IPAddress'] as List<dynamic>?;
        final ipv4 = ipList?.firstWhere(
              (ip) => ip is String && !ip.contains(':'),
              orElse: () => '未知',
            ) as String? ??
            '未知';
        final ipv6 = ipList?.firstWhere(
              (ip) => ip is String && ip.contains(':'),
              orElse: () => '未知',
            ) as String? ??
            '未知';
        final subnetList = d['IPSubnet'] as List<dynamic>?;
        final gatewayList = d['DefaultIPGateway'] as List<dynamic>?;
        final dnsList = d['DNSServerSearchOrder'] as List<dynamic>?;

        return NetworkInfo(
          interfaceName: d['Description']?.toString() ?? '未知',
          ipAddress: ipv4,
          macAddress: d['MACAddress']?.toString() ?? '未知',
          ipv6Address: ipv6,
          subnetMask: subnetList?.firstOrNull?.toString() ?? '未知',
          gateway: gatewayList?.firstOrNull?.toString() ?? '未知',
          dnsServers: dnsList?.join(', ') ?? '未知',
        );
      }).toList();
    } catch (e) {
      debugPrint('采集网络信息失败: $e');
      return const [];
    }
  }

  Future<RealtimeStats> _collectWindowsRealtimeStats() async {
    try {
      final shell = Shell();
      final result = await shell.run('''
        \$cpu = (Get-Counter '\\Processor(_Total)\\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
        \$os = Get-CimInstance Win32_OperatingSystem
        \$memTotal = \$os.TotalVisibleMemorySize
        \$memFree = \$os.FreePhysicalMemory
        \$memPercent = [math]::Round((\$memTotal - \$memFree) / \$memTotal * 100, 1)
        \$procCount = (Get-Process).Count
        \$bootTime = [Management.ManagementDateTimeConverter]::ToDateTime(\$os.LastBootUpTime)
        \$uptime = (Get-Date) - \$bootTime
        \$uptimeStr = "{0}天{1}时{2}分" -f \$uptime.Days, \$uptime.Hours, \$uptime.Minutes
        [PSCustomObject]@{
          CpuUsage = [math]::Round(\$cpu, 1)
          MemoryUsage = \$memPercent
          ProcessCount = \$procCount
          Uptime = \$uptimeStr
        } | ConvertTo-Json
      ''');
      final data = _parseJsonOutput(result.outText);
      if (data == null) return const RealtimeStats();

      return RealtimeStats(
        cpuUsage: (data['CpuUsage'] as num?)?.toDouble() ?? 0.0,
        memoryUsage: (data['MemoryUsage'] as num?)?.toDouble() ?? 0.0,
        runningProcesses: data['ProcessCount'] as int? ?? 0,
        uptime: data['Uptime']?.toString() ?? '未知',
      );
    } catch (e) {
      debugPrint('采集实时状态失败: $e');
      return const RealtimeStats();
    }
  }

  // ============================================================
  // JSON 解析辅助
  // ============================================================

  /// 解析 PowerShell JSON 输出为 Map
  Map<String, dynamic>? _parseJsonOutput(String output) {
    try {
      final cleaned = output.trim();
      if (cleaned.isEmpty) return null;
      // 简单 JSON 解析 - 使用 dart:convert
      return _simpleJsonDecode(cleaned);
    } catch (e) {
      debugPrint('JSON解析失败: $e');
      return null;
    }
  }

  /// 解析 PowerShell JSON 输出为 List
  List<Map<String, dynamic>> _parseJsonListOutput(String output) {
    try {
      final cleaned = output.trim();
      if (cleaned.isEmpty) return [];
      final result = _simpleJsonDecodeList(cleaned);
      return result;
    } catch (e) {
      debugPrint('JSON列表解析失败: $e');
      return [];
    }
  }

  /// 简单 JSON 解码（避免 import dart:convert 的额外依赖）
  static Map<String, dynamic>? _simpleJsonDecode(String json) {
    // 使用 dart:convert
    return _jsonDecode(json) as Map<String, dynamic>?;
  }

  static List<Map<String, dynamic>> _simpleJsonDecodeList(String json) {
    final decoded = _jsonDecode(json);
    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (decoded is Map) {
      return [Map<String, dynamic>.from(decoded)];
    }
    return [];
  }

  static dynamic _jsonDecode(String json) {
    return _jsonDecoder.convert(json);
  }

  static final _jsonDecoder = _SimpleJsonDecoder();
}

/// 简单 JSON 解码器
class _SimpleJsonDecoder {
  dynamic convert(String json) {
    return _parseValue(json.trim(), 0).$1;
  }

  (dynamic, int) _parseValue(String s, int i) {
    while (i < s.length && (s[i] == ' ' || s[i] == '\n' || s[i] == '\r' || s[i] == '\t')) {
      i++;
    }
    if (i >= s.length) return (null, i);
    if (s[i] == '{') return _parseObject(s, i);
    if (s[i] == '[') return _parseArray(s, i);
    if (s[i] == '"') return _parseString(s, i);
    if (s[i] == 't' || s[i] == 'f') return _parseBool(s, i);
    if (s[i] == 'n') return _parseNull(s, i);
    return _parseNumber(s, i);
  }

  (Map<String, dynamic>, int) _parseObject(String s, int i) {
    final result = <String, dynamic>{};
    i++; // skip {
    while (i < s.length) {
      while (i < s.length && (s[i] == ' ' || s[i] == '\n' || s[i] == '\r' || s[i] == '\t' || s[i] == ',')) {
        i++;
      }
      if (i >= s.length || s[i] == '}') {
        i++;
        break;
      }
      final (key, ki) = _parseString(s, i);
      i = ki;
      while (i < s.length && (s[i] == ' ' || s[i] == ':')) {
        i++;
      }
      final (value, vi) = _parseValue(s, i);
      i = vi;
      result[key] = value;
    }
    return (result, i);
  }

  (List<dynamic>, int) _parseArray(String s, int i) {
    final result = <dynamic>[];
    i++; // skip [
    while (i < s.length) {
      while (i < s.length && (s[i] == ' ' || s[i] == '\n' || s[i] == '\r' || s[i] == '\t' || s[i] == ',')) {
        i++;
      }
      if (i >= s.length || s[i] == ']') {
        i++;
        break;
      }
      final (value, vi) = _parseValue(s, i);
      i = vi;
      result.add(value);
    }
    return (result, i);
  }

  (String, int) _parseString(String s, int i) {
    i++; // skip opening "
    final buf = StringBuffer();
    while (i < s.length && s[i] != '"') {
      if (s[i] == '\\' && i + 1 < s.length) {
        i++;
        switch (s[i]) {
          case 'n': buf.write('\n');
          case 'r': buf.write('\r');
          case 't': buf.write('\t');
          case '\\': buf.write('\\');
          case '"': buf.write('"');
          default: buf.write(s[i]);
        }
      } else {
        buf.write(s[i]);
      }
      i++;
    }
    i++; // skip closing "
    return (buf.toString(), i);
  }

  (dynamic, int) _parseNumber(String s, int i) {
    final start = i;
    bool isDouble = false;
    while (i < s.length && (s[i].contains(RegExp(r'[0-9.eE+-]')))) {
      if (s[i] == '.' || s[i] == 'e' || s[i] == 'E') isDouble = true;
      i++;
    }
    final numStr = s.substring(start, i);
    if (isDouble) {
      return (double.tryParse(numStr) ?? 0.0, i);
    }
    return (int.tryParse(numStr) ?? 0, i);
  }

  (bool, int) _parseBool(String s, int i) {
    if (s.substring(i).startsWith('true')) {
      return (true, i + 4);
    }
    return (false, i + 5);
  }

  (Null, int) _parseNull(String s, int i) {
    return (null, i + 4);
  }
}
