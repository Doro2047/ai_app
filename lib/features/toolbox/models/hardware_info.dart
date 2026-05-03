/// 硬件信息数据模型
///
/// 对应 Python HardwareCollector 采集的各类硬件信息。
/// 包含计算机信息、系统信息、CPU、内存、磁盘、GPU、网络、实时状态和进程信息。
library;

import 'package:equatable/equatable.dart';

/// 计算机信息
class ComputerInfo extends Equatable {
  final String manufacturer;
  final String model;
  final String productName;
  final String serialNumber;
  final String biosVersion;
  final String biosDate;
  final String biosVendor;
  final String smbiosVersion;
  final String baseboardManufacturer;
  final String baseboardProduct;
  final String chipset;

  const ComputerInfo({
    this.manufacturer = '未知',
    this.model = '未知',
    this.productName = '未知',
    this.serialNumber = '未知',
    this.biosVersion = '未知',
    this.biosDate = '未知',
    this.biosVendor = '未知',
    this.smbiosVersion = '未知',
    this.baseboardManufacturer = '未知',
    this.baseboardProduct = '未知',
    this.chipset = '未知',
  });

  factory ComputerInfo.fromDict(Map<String, dynamic> data) {
    return ComputerInfo(
      manufacturer: data['manufacturer'] as String? ?? '未知',
      model: data['model'] as String? ?? '未知',
      productName: data['productName'] as String? ?? '未知',
      serialNumber: data['serialNumber'] as String? ?? '未知',
      biosVersion: data['biosVersion'] as String? ?? '未知',
      biosDate: data['biosDate'] as String? ?? '未知',
      biosVendor: data['biosVendor'] as String? ?? '未知',
      smbiosVersion: data['smbiosVersion'] as String? ?? '未知',
      baseboardManufacturer: data['baseboardManufacturer'] as String? ?? '未知',
      baseboardProduct: data['baseboardProduct'] as String? ?? '未知',
      chipset: data['chipset'] as String? ?? '未知',
    );
  }

  Map<String, dynamic> toDict() => {
        'manufacturer': manufacturer,
        'model': model,
        'productName': productName,
        'serialNumber': serialNumber,
        'biosVersion': biosVersion,
        'biosDate': biosDate,
        'biosVendor': biosVendor,
        'smbiosVersion': smbiosVersion,
        'baseboardManufacturer': baseboardManufacturer,
        'baseboardProduct': baseboardProduct,
        'chipset': chipset,
      };

  @override
  List<Object?> get props => [
        manufacturer, model, productName, serialNumber, biosVersion,
        biosDate, biosVendor, smbiosVersion, baseboardManufacturer,
        baseboardProduct, chipset,
      ];
}

/// 操作系统信息
class SystemInfo extends Equatable {
  final String osName;
  final String osVersion;
  final String osBuild;
  final String osEdition;
  final String osArchitecture;
  final String installDate;
  final String computerName;
  final String userName;
  final String systemDir;
  final String bootTime;
  final String kernelVersion;
  final String region;
  final String language;
  final String adminMode;

  const SystemInfo({
    this.osName = '未知',
    this.osVersion = '未知',
    this.osBuild = '未知',
    this.osEdition = '未知',
    this.osArchitecture = '未知',
    this.installDate = '未知',
    this.computerName = '未知',
    this.userName = '未知',
    this.systemDir = '未知',
    this.bootTime = '未知',
    this.kernelVersion = '未知',
    this.region = '未知',
    this.language = '未知',
    this.adminMode = '未知',
  });

  factory SystemInfo.fromDict(Map<String, dynamic> data) {
    return SystemInfo(
      osName: data['osName'] as String? ?? '未知',
      osVersion: data['osVersion'] as String? ?? '未知',
      osBuild: data['osBuild'] as String? ?? '未知',
      osEdition: data['osEdition'] as String? ?? '未知',
      osArchitecture: data['osArchitecture'] as String? ?? '未知',
      installDate: data['installDate'] as String? ?? '未知',
      computerName: data['computerName'] as String? ?? '未知',
      userName: data['userName'] as String? ?? '未知',
      systemDir: data['systemDir'] as String? ?? '未知',
      bootTime: data['bootTime'] as String? ?? '未知',
      kernelVersion: data['kernelVersion'] as String? ?? '未知',
      region: data['region'] as String? ?? '未知',
      language: data['language'] as String? ?? '未知',
      adminMode: data['adminMode'] as String? ?? '未知',
    );
  }

  Map<String, dynamic> toDict() => {
        'osName': osName, 'osVersion': osVersion, 'osBuild': osBuild,
        'osEdition': osEdition, 'osArchitecture': osArchitecture,
        'installDate': installDate, 'computerName': computerName,
        'userName': userName, 'systemDir': systemDir, 'bootTime': bootTime,
        'kernelVersion': kernelVersion, 'region': region,
        'language': language, 'adminMode': adminMode,
      };

  @override
  List<Object?> get props => [
        osName, osVersion, osBuild, osEdition, osArchitecture,
        installDate, computerName, userName, systemDir, bootTime,
        kernelVersion, region, language, adminMode,
      ];
}

/// CPU 信息
class CpuInfo extends Equatable {
  final String name;
  final String cores;
  final String threads;
  final String maxSpeed;
  final String manufacturer;
  final double currentUsage;
  final String currentSpeed;
  final String l2Cache;
  final String l3Cache;
  final String architecture;
  final String coreDescription;
  final String threadDescription;

  const CpuInfo({
    this.name = '未知',
    this.cores = '未知',
    this.threads = '未知',
    this.maxSpeed = '未知',
    this.manufacturer = '未知',
    this.currentUsage = 0.0,
    this.currentSpeed = '未知',
    this.l2Cache = '未知',
    this.l3Cache = '未知',
    this.architecture = '未知',
    this.coreDescription = '未知',
    this.threadDescription = '未知',
  });

  factory CpuInfo.fromDict(Map<String, dynamic> data) {
    return CpuInfo(
      name: data['name'] as String? ?? '未知',
      cores: data['cores']?.toString() ?? '未知',
      threads: data['threads']?.toString() ?? '未知',
      maxSpeed: data['maxSpeed'] as String? ?? '未知',
      manufacturer: data['manufacturer'] as String? ?? '未知',
      currentUsage: (data['currentUsage'] as num?)?.toDouble() ?? 0.0,
      currentSpeed: data['currentSpeed'] as String? ?? '未知',
      l2Cache: data['l2Cache'] as String? ?? '未知',
      l3Cache: data['l3Cache'] as String? ?? '未知',
      architecture: data['architecture'] as String? ?? '未知',
      coreDescription: data['coreDescription'] as String? ?? '未知',
      threadDescription: data['threadDescription'] as String? ?? '未知',
    );
  }

  Map<String, dynamic> toDict() => {
        'name': name, 'cores': cores, 'threads': threads,
        'maxSpeed': maxSpeed, 'manufacturer': manufacturer,
        'currentUsage': currentUsage, 'currentSpeed': currentSpeed,
        'l2Cache': l2Cache, 'l3Cache': l3Cache,
        'architecture': architecture, 'coreDescription': coreDescription,
        'threadDescription': threadDescription,
      };

  @override
  List<Object?> get props => [
        name, cores, threads, maxSpeed, manufacturer, currentUsage,
        currentSpeed, l2Cache, l3Cache, architecture,
        coreDescription, threadDescription,
      ];
}

/// 内存信息
class MemoryInfo extends Equatable {
  final String total;
  final String available;
  final String usedPercent;
  final String used;
  final String capacity;
  final String channels;
  final String frequency;
  final String timings;
  final List<String> modules;

  const MemoryInfo({
    this.total = '未知',
    this.available = '未知',
    this.usedPercent = '0%',
    this.used = '未知',
    this.capacity = '未知',
    this.channels = '未知',
    this.frequency = '未知',
    this.timings = '未知',
    this.modules = const [],
  });

  factory MemoryInfo.fromDict(Map<String, dynamic> data) {
    return MemoryInfo(
      total: data['total'] as String? ?? '未知',
      available: data['available'] as String? ?? '未知',
      usedPercent: data['usedPercent'] as String? ?? '0%',
      used: data['used'] as String? ?? '未知',
      capacity: data['capacity'] as String? ?? '未知',
      channels: data['channels'] as String? ?? '未知',
      frequency: data['frequency'] as String? ?? '未知',
      timings: data['timings'] as String? ?? '未知',
      modules: (data['modules'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toDict() => {
        'total': total, 'available': available, 'usedPercent': usedPercent,
        'used': used, 'capacity': capacity, 'channels': channels,
        'frequency': frequency, 'timings': timings, 'modules': modules,
      };

  @override
  List<Object?> get props => [
        total, available, usedPercent, used, capacity, channels,
        frequency, timings, modules,
      ];
}

/// 磁盘信息
class DiskInfo extends Equatable {
  final String drive;
  final String total;
  final String free;
  final String usedPercent;
  final String used;
  final String model;
  final String diskType;
  final String fileSystem;
  final String serial;
  final String partitions;

  const DiskInfo({
    this.drive = '未知',
    this.total = '未知',
    this.free = '未知',
    this.usedPercent = '0%',
    this.used = '未知',
    this.model = '未知',
    this.diskType = '未知',
    this.fileSystem = '未知',
    this.serial = '未知',
    this.partitions = '未知',
  });

  factory DiskInfo.fromDict(Map<String, dynamic> data) {
    return DiskInfo(
      drive: data['drive'] as String? ?? '未知',
      total: data['total'] as String? ?? '未知',
      free: data['free'] as String? ?? '未知',
      usedPercent: data['usedPercent'] as String? ?? '0%',
      used: data['used'] as String? ?? '未知',
      model: data['model'] as String? ?? '未知',
      diskType: data['diskType'] as String? ?? '未知',
      fileSystem: data['fileSystem'] as String? ?? '未知',
      serial: data['serial'] as String? ?? '未知',
      partitions: data['partitions'] as String? ?? '未知',
    );
  }

  Map<String, dynamic> toDict() => {
        'drive': drive, 'total': total, 'free': free,
        'usedPercent': usedPercent, 'used': used, 'model': model,
        'diskType': diskType, 'fileSystem': fileSystem,
        'serial': serial, 'partitions': partitions,
      };

  @override
  List<Object?> get props => [
        drive, total, free, usedPercent, used, model,
        diskType, fileSystem, serial, partitions,
      ];
}

/// GPU 信息
class GpuInfo extends Equatable {
  final String name;
  final String driverVersion;
  final String memoryTotal;
  final String memoryUsed;
  final String memoryType;
  final String streams;
  final String memoryFree;
  final String busWidth;
  final double usagePercent;

  const GpuInfo({
    this.name = '未知',
    this.driverVersion = '未知',
    this.memoryTotal = '未知',
    this.memoryUsed = '未知',
    this.memoryType = '未知',
    this.streams = '未知',
    this.memoryFree = '未知',
    this.busWidth = '未知',
    this.usagePercent = 0.0,
  });

  factory GpuInfo.fromDict(Map<String, dynamic> data) {
    return GpuInfo(
      name: data['name'] as String? ?? '未知',
      driverVersion: data['driverVersion'] as String? ?? '未知',
      memoryTotal: data['memoryTotal'] as String? ?? '未知',
      memoryUsed: data['memoryUsed'] as String? ?? '未知',
      memoryType: data['memoryType'] as String? ?? '未知',
      streams: data['streams'] as String? ?? '未知',
      memoryFree: data['memoryFree'] as String? ?? '未知',
      busWidth: data['busWidth'] as String? ?? '未知',
      usagePercent: (data['usagePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toDict() => {
        'name': name, 'driverVersion': driverVersion,
        'memoryTotal': memoryTotal, 'memoryUsed': memoryUsed,
        'memoryType': memoryType, 'streams': streams,
        'memoryFree': memoryFree, 'busWidth': busWidth,
        'usagePercent': usagePercent,
      };

  @override
  List<Object?> get props => [
        name, driverVersion, memoryTotal, memoryUsed, memoryType,
        streams, memoryFree, busWidth, usagePercent,
      ];
}

/// 网络信息
class NetworkInfo extends Equatable {
  final String interfaceName;
  final String ipAddress;
  final String macAddress;
  final String bytesSent;
  final String bytesRecv;
  final String ipv6Address;
  final String subnetMask;
  final String gateway;
  final String dnsServers;
  final String adapterType;
  final String speed;
  final String status;

  const NetworkInfo({
    this.interfaceName = '未知',
    this.ipAddress = '未知',
    this.macAddress = '未知',
    this.bytesSent = '未知',
    this.bytesRecv = '未知',
    this.ipv6Address = '未知',
    this.subnetMask = '未知',
    this.gateway = '未知',
    this.dnsServers = '未知',
    this.adapterType = '未知',
    this.speed = '未知',
    this.status = '未知',
  });

  factory NetworkInfo.fromDict(Map<String, dynamic> data) {
    return NetworkInfo(
      interfaceName: data['interface'] as String? ?? data['interfaceName'] as String? ?? '未知',
      ipAddress: data['ipAddress'] as String? ?? '未知',
      macAddress: data['macAddress'] as String? ?? '未知',
      bytesSent: data['bytesSent'] as String? ?? '未知',
      bytesRecv: data['bytesRecv'] as String? ?? '未知',
      ipv6Address: data['ipv6Address'] as String? ?? '未知',
      subnetMask: data['subnetMask'] as String? ?? '未知',
      gateway: data['gateway'] as String? ?? '未知',
      dnsServers: data['dnsServers'] as String? ?? '未知',
      adapterType: data['adapterType'] as String? ?? '未知',
      speed: data['speed'] as String? ?? '未知',
      status: data['status'] as String? ?? '未知',
    );
  }

  Map<String, dynamic> toDict() => {
        'interface': interfaceName, 'ipAddress': ipAddress,
        'macAddress': macAddress, 'bytesSent': bytesSent,
        'bytesRecv': bytesRecv, 'ipv6Address': ipv6Address,
        'subnetMask': subnetMask, 'gateway': gateway,
        'dnsServers': dnsServers, 'adapterType': adapterType,
        'speed': speed, 'status': status,
      };

  @override
  List<Object?> get props => [
        interfaceName, ipAddress, macAddress, bytesSent, bytesRecv,
        ipv6Address, subnetMask, gateway, dnsServers, adapterType,
        speed, status,
      ];
}

/// 实时系统状态
class RealtimeStats extends Equatable {
  final double cpuUsage;
  final double memoryUsage;
  final String diskReadSpeed;
  final String diskWriteSpeed;
  final String networkUploadSpeed;
  final String networkDownloadSpeed;
  final int runningProcesses;
  final String uptime;

  const RealtimeStats({
    this.cpuUsage = 0.0,
    this.memoryUsage = 0.0,
    this.diskReadSpeed = '0 B/s',
    this.diskWriteSpeed = '0 B/s',
    this.networkUploadSpeed = '0 B/s',
    this.networkDownloadSpeed = '0 B/s',
    this.runningProcesses = 0,
    this.uptime = '未知',
  });

  factory RealtimeStats.fromDict(Map<String, dynamic> data) {
    return RealtimeStats(
      cpuUsage: (data['cpuUsage'] as num?)?.toDouble() ?? 0.0,
      memoryUsage: (data['memoryUsage'] as num?)?.toDouble() ?? 0.0,
      diskReadSpeed: data['diskReadSpeed'] as String? ?? '0 B/s',
      diskWriteSpeed: data['diskWriteSpeed'] as String? ?? '0 B/s',
      networkUploadSpeed: data['networkUploadSpeed'] as String? ?? '0 B/s',
      networkDownloadSpeed: data['networkDownloadSpeed'] as String? ?? '0 B/s',
      runningProcesses: data['runningProcesses'] as int? ?? 0,
      uptime: data['uptime'] as String? ?? '未知',
    );
  }

  Map<String, dynamic> toDict() => {
        'cpuUsage': cpuUsage, 'memoryUsage': memoryUsage,
        'diskReadSpeed': diskReadSpeed, 'diskWriteSpeed': diskWriteSpeed,
        'networkUploadSpeed': networkUploadSpeed,
        'networkDownloadSpeed': networkDownloadSpeed,
        'runningProcesses': runningProcesses, 'uptime': uptime,
      };

  RealtimeStats copyWith({
    double? cpuUsage,
    double? memoryUsage,
    String? diskReadSpeed,
    String? diskWriteSpeed,
    String? networkUploadSpeed,
    String? networkDownloadSpeed,
    int? runningProcesses,
    String? uptime,
  }) {
    return RealtimeStats(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      diskReadSpeed: diskReadSpeed ?? this.diskReadSpeed,
      diskWriteSpeed: diskWriteSpeed ?? this.diskWriteSpeed,
      networkUploadSpeed: networkUploadSpeed ?? this.networkUploadSpeed,
      networkDownloadSpeed: networkDownloadSpeed ?? this.networkDownloadSpeed,
      runningProcesses: runningProcesses ?? this.runningProcesses,
      uptime: uptime ?? this.uptime,
    );
  }

  @override
  List<Object?> get props => [
        cpuUsage, memoryUsage, diskReadSpeed, diskWriteSpeed,
        networkUploadSpeed, networkDownloadSpeed,
        runningProcesses, uptime,
      ];
}

/// 进程信息
class ProcessInfo extends Equatable {
  final int pid;
  final String name;
  final double cpuPercent;
  final double memoryPercent;
  final double memoryMb;
  final String status;

  const ProcessInfo({
    required this.pid,
    this.name = '未知',
    this.cpuPercent = 0.0,
    this.memoryPercent = 0.0,
    this.memoryMb = 0.0,
    this.status = '未知',
  });

  factory ProcessInfo.fromDict(Map<String, dynamic> data) {
    return ProcessInfo(
      pid: data['pid'] as int? ?? 0,
      name: data['name'] as String? ?? '未知',
      cpuPercent: (data['cpuPercent'] as num?)?.toDouble() ?? 0.0,
      memoryPercent: (data['memoryPercent'] as num?)?.toDouble() ?? 0.0,
      memoryMb: (data['memoryMb'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? '未知',
    );
  }

  Map<String, dynamic> toDict() => {
        'pid': pid, 'name': name, 'cpuPercent': cpuPercent,
        'memoryPercent': memoryPercent, 'memoryMb': memoryMb,
        'status': status,
      };

  @override
  List<Object?> get props => [pid, name, cpuPercent, memoryPercent, memoryMb, status];
}

/// 硬件信息聚合模型
class HardwareInfo extends Equatable {
  final ComputerInfo computer;
  final SystemInfo system;
  final CpuInfo cpu;
  final MemoryInfo memory;
  final List<DiskInfo> disks;
  final List<GpuInfo> gpus;
  final List<NetworkInfo> networks;
  final RealtimeStats realtimeStats;

  const HardwareInfo({
    this.computer = const ComputerInfo(),
    this.system = const SystemInfo(),
    this.cpu = const CpuInfo(),
    this.memory = const MemoryInfo(),
    this.disks = const [],
    this.gpus = const [],
    this.networks = const [],
    this.realtimeStats = const RealtimeStats(),
  });

  factory HardwareInfo.fromDict(Map<String, dynamic> data) {
    return HardwareInfo(
      computer: data['computer'] != null
          ? ComputerInfo.fromDict(data['computer'] as Map<String, dynamic>)
          : const ComputerInfo(),
      system: data['system'] != null
          ? SystemInfo.fromDict(data['system'] as Map<String, dynamic>)
          : const SystemInfo(),
      cpu: data['cpu'] != null
          ? CpuInfo.fromDict(data['cpu'] as Map<String, dynamic>)
          : const CpuInfo(),
      memory: data['memory'] != null
          ? MemoryInfo.fromDict(data['memory'] as Map<String, dynamic>)
          : const MemoryInfo(),
      disks: (data['disks'] as List<dynamic>?)
              ?.map((e) => DiskInfo.fromDict(e as Map<String, dynamic>))
              .toList() ??
          const [],
      gpus: (data['gpus'] as List<dynamic>?)
              ?.map((e) => GpuInfo.fromDict(e as Map<String, dynamic>))
              .toList() ??
          const [],
      networks: (data['networks'] as List<dynamic>?)
              ?.map((e) => NetworkInfo.fromDict(e as Map<String, dynamic>))
              .toList() ??
          const [],
      realtimeStats: data['realtimeStats'] != null
          ? RealtimeStats.fromDict(data['realtimeStats'] as Map<String, dynamic>)
          : const RealtimeStats(),
    );
  }

  Map<String, dynamic> toDict() => {
        'computer': computer.toDict(),
        'system': system.toDict(),
        'cpu': cpu.toDict(),
        'memory': memory.toDict(),
        'disks': disks.map((e) => e.toDict()).toList(),
        'gpus': gpus.map((e) => e.toDict()).toList(),
        'networks': networks.map((e) => e.toDict()).toList(),
        'realtimeStats': realtimeStats.toDict(),
      };

  HardwareInfo copyWith({
    ComputerInfo? computer,
    SystemInfo? system,
    CpuInfo? cpu,
    MemoryInfo? memory,
    List<DiskInfo>? disks,
    List<GpuInfo>? gpus,
    List<NetworkInfo>? networks,
    RealtimeStats? realtimeStats,
  }) {
    return HardwareInfo(
      computer: computer ?? this.computer,
      system: system ?? this.system,
      cpu: cpu ?? this.cpu,
      memory: memory ?? this.memory,
      disks: disks ?? this.disks,
      gpus: gpus ?? this.gpus,
      networks: networks ?? this.networks,
      realtimeStats: realtimeStats ?? this.realtimeStats,
    );
  }

  @override
  List<Object?> get props => [
        computer, system, cpu, memory, disks, gpus, networks, realtimeStats,
      ];
}
