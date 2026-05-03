/// 系统控制 BLoC
///
/// 管理系统时间同步、设备控制和电源操作的状态和事件。
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/error_handler.dart';
import '../../../shared/bloc/feature_bloc_base.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

// ============================================================
// Events
// ============================================================

/// 系统控制事件基类
abstract class SystemControlEvent extends Equatable {
  const SystemControlEvent();

  @override
  List<Object?> get props => [];
}

/// 请求时间同步
class SystemControlTimeSyncRequested extends SystemControlEvent {
  final String server;

  const SystemControlTimeSyncRequested(this.server);

  @override
  List<Object?> get props => [server];
}

/// 请求设置时间
class SystemControlTimeSet extends SystemControlEvent {
  final DateTime dateTime;

  const SystemControlTimeSet(this.dateTime);

  @override
  List<Object?> get props => [dateTime];
}

/// 刷新 NTP 服务器列表
class SystemControlNtpServersRefreshed extends SystemControlEvent {
  const SystemControlNtpServersRefreshed();
}

/// 切换 WiFi 状态
class SystemControlWifiToggled extends SystemControlEvent {
  final bool enabled;

  const SystemControlWifiToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// 切换蓝牙状态
class SystemControlBluetoothToggled extends SystemControlEvent {
  final bool enabled;

  const SystemControlBluetoothToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// 刷新网络设备列表
class SystemControlNetworkDevicesRefreshed extends SystemControlEvent {
  const SystemControlNetworkDevicesRefreshed();
}

/// 执行电源操作
class SystemControlPowerAction extends SystemControlEvent {
  final PowerAction action;

  const SystemControlPowerAction(this.action);

  @override
  List<Object?> get props => [action];
}

/// 刷新设备信息
class SystemControlDeviceInfoRefreshed extends SystemControlEvent {
  const SystemControlDeviceInfoRefreshed();
}

/// 测试时间同步
class SystemControlTimeTestRequested extends SystemControlEvent {
  final String server;

  const SystemControlTimeTestRequested(this.server);

  @override
  List<Object?> get props => [server];
}

// ============================================================
// State
// ============================================================

/// 系统控制状态
class SystemControlState extends Equatable {
  /// 本地时间
  final DateTime localTime;

  /// NTP 服务器列表
  final List<TimeServer> ntpServers;

  /// 选中的服务器
  final String selectedServer;

  /// 时间同步结果列表
  final List<TimeSyncResult> syncResults;

  /// 设备列表
  final List<DeviceInfo> devices;

  /// WiFi 是否启用
  final bool wifiEnabled;

  /// 蓝牙是否启用
  final bool bluetoothEnabled;

  /// 以太网是否启用
  final bool ethernetEnabled;

  /// 是否正在同步时间
  final bool isSyncing;

  /// 是否正在切换设备状态
  final bool isToggling;

  /// 是否正在执行电源操作
  final bool isPowerActionExecuting;

  /// 错误信息
  final String? error;

  /// 日志消息
  final List<String> logs;

  /// 是否显示自动同步
  final bool autoSyncEnabled;

  SystemControlState({
    DateTime? localTime,
    this.ntpServers = const [],
    this.selectedServer = 'ntp.aliyun.com',
    this.syncResults = const [],
    this.devices = const [],
    this.wifiEnabled = true,
    this.bluetoothEnabled = true,
    this.ethernetEnabled = true,
    this.isSyncing = false,
    this.isToggling = false,
    this.isPowerActionExecuting = false,
    this.error,
    this.logs = const [],
    this.autoSyncEnabled = false,
  }) : localTime = localTime ?? DateTime.now();

  /// 最新同步结果
  TimeSyncResult? get latestSyncResult =>
      syncResults.isNotEmpty ? syncResults.last : null;

  /// 是否有错误
  bool get hasError => error != null;

  /// 设备状态文本
  String get deviceStatusText {
    final statuses = [
      if (wifiEnabled) 'WiFi: 已启用' else 'WiFi: 已禁用',
      if (bluetoothEnabled) '蓝牙: 已启用' else '蓝牙: 已禁用',
      if (ethernetEnabled) '以太网: 已启用' else '以太网: 已禁用',
    ];
    return statuses.join(', ');
  }

  SystemControlState copyWith({
    DateTime? localTime,
    List<TimeServer>? ntpServers,
    String? selectedServer,
    List<TimeSyncResult>? syncResults,
    List<DeviceInfo>? devices,
    bool? wifiEnabled,
    bool? bluetoothEnabled,
    bool? ethernetEnabled,
    bool? isSyncing,
    bool? isToggling,
    bool? isPowerActionExecuting,
    String? error,
    List<String>? logs,
    bool? autoSyncEnabled,
    bool clearError = false,
  }) {
    return SystemControlState(
      localTime: localTime ?? this.localTime,
      ntpServers: ntpServers ?? this.ntpServers,
      selectedServer: selectedServer ?? this.selectedServer,
      syncResults: syncResults ?? this.syncResults,
      devices: devices ?? this.devices,
      wifiEnabled: wifiEnabled ?? this.wifiEnabled,
      bluetoothEnabled: bluetoothEnabled ?? this.bluetoothEnabled,
      ethernetEnabled: ethernetEnabled ?? this.ethernetEnabled,
      isSyncing: isSyncing ?? this.isSyncing,
      isToggling: isToggling ?? this.isToggling,
      isPowerActionExecuting: isPowerActionExecuting ?? this.isPowerActionExecuting,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
    );
  }

  @override
  List<Object?> get props => [
        localTime,
        ntpServers,
        selectedServer,
        syncResults,
        devices,
        wifiEnabled,
        bluetoothEnabled,
        ethernetEnabled,
        isSyncing,
        isToggling,
        isPowerActionExecuting,
        error,
        logs,
        autoSyncEnabled,
      ];
}

// ============================================================
// BLoC
// ============================================================

/// 系统控制 BLoC
class SystemControlBloc extends FeatureBlocBase<SystemControlEvent, SystemControlState> {
  final SystemControlRepository _systemControlRepo;
  final NetworkControlRepository _networkRepo;
  final PowerControlRepository _powerRepo;

  SystemControlBloc({
    SystemControlRepository? systemControlRepo,
    NetworkControlRepository? networkRepo,
    PowerControlRepository? powerRepo,
  })  : _systemControlRepo = systemControlRepo ?? SystemControlRepository(),
        _networkRepo = networkRepo ?? NetworkControlRepository(),
        _powerRepo = powerRepo ?? PowerControlRepository(),
        super(SystemControlState(localTime: DateTime.now())) {
    on<SystemControlTimeSyncRequested>(_onTimeSyncRequested);
    on<SystemControlTimeSet>(_onTimeSet);
    on<SystemControlNtpServersRefreshed>(_onNtpServersRefreshed);
    on<SystemControlWifiToggled>(_onWifiToggled);
    on<SystemControlBluetoothToggled>(_onBluetoothToggled);
    on<SystemControlNetworkDevicesRefreshed>(_onNetworkDevicesRefreshed);
    on<SystemControlPowerAction>(_onPowerAction);
    on<SystemControlDeviceInfoRefreshed>(_onDeviceInfoRefreshed);
    on<SystemControlTimeTestRequested>(_onTimeTestRequested);
  }

  void _addLog(SystemControlState currentState, Emitter<SystemControlState> emit, String message) {
    final newLogs = List<String>.from(currentState.logs)..add(message);
    // 保持最多 100 条日志
    if (newLogs.length > 100) {
      newLogs.removeRange(0, newLogs.length - 100);
    }
    emit(currentState.copyWith(logs: newLogs));
  }

  Future<void> _onTimeSyncRequested(
    SystemControlTimeSyncRequested event,
    Emitter<SystemControlState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true, clearError: true));
    _addLog(state, emit, '正在同步时间: 服务器=${event.server}');

    try {
      final result = await _systemControlRepo.syncTime(event.server);
      final newResults = List<TimeSyncResult>.from(state.syncResults)..add(result);

      if (result.success) {
        _addLog(state, emit, '时间同步成功: 偏移=${result.offsetDescription}');
      } else {
        _addLog(state, emit, '时间同步失败: ${result.error}');
        emit(state.copyWith(error: result.error));
      }

      emit(state.copyWith(
        syncResults: newResults,
        localTime: DateTime.now(),
        isSyncing: false,
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '时间同步异常: $e');
      emit(state.copyWith(
        isSyncing: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onTimeSet(
    SystemControlTimeSet event,
    Emitter<SystemControlState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true, clearError: true));
    _addLog(state, emit, '正在设置系统时间: ${event.dateTime}');

    try {
      final success = await _systemControlRepo.setTime(event.dateTime);
      if (success) {
        _addLog(state, emit, '系统时间设置成功');
        emit(state.copyWith(
          localTime: DateTime.now(),
          isSyncing: false,
        ));
      } else {
        _addLog(state, emit, '系统时间设置失败');
        emit(state.copyWith(
          isSyncing: false,
          error: '设置系统时间失败，请确保以管理员身份运行。',
        ));
      }
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '设置系统时间异常: $e');
      emit(state.copyWith(
        isSyncing: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onNtpServersRefreshed(
    SystemControlNtpServersRefreshed event,
    Emitter<SystemControlState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true, clearError: true));
    _addLog(state, emit, '正在刷新 NTP 服务器列表');

    try {
      final servers = await _systemControlRepo.getNtpServers();
      _addLog(state, emit, 'NTP 服务器列表已刷新: ${servers.length} 个服务器');
      emit(state.copyWith(
        ntpServers: servers,
        isSyncing: false,
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '刷新 NTP 服务器列表失败: $e');
      emit(state.copyWith(
        isSyncing: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onWifiToggled(
    SystemControlWifiToggled event,
    Emitter<SystemControlState> emit,
  ) async {
    emit(state.copyWith(isToggling: true, clearError: true));
    _addLog(state, emit, '正在切换 WiFi: ${event.enabled ? '启用' : '禁用'}');

    try {
      final success = await _networkRepo.toggleWifi(event.enabled);
      if (success) {
        _addLog(state, emit, 'WiFi 状态已切换');
        emit(state.copyWith(
          wifiEnabled: event.enabled,
          isToggling: false,
        ));
      } else {
        _addLog(state, emit, '切换 WiFi 失败');
        emit(state.copyWith(
          isToggling: false,
          error: '切换 WiFi 失败，请确保以管理员身份运行。',
        ));
      }
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '切换 WiFi 异常: $e');
      emit(state.copyWith(
        isToggling: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onBluetoothToggled(
    SystemControlBluetoothToggled event,
    Emitter<SystemControlState> emit,
  ) async {
    emit(state.copyWith(isToggling: true, clearError: true));
    _addLog(state, emit, '正在切换蓝牙: ${event.enabled ? '启用' : '禁用'}');

    try {
      final success = await _networkRepo.toggleBluetooth(event.enabled);
      if (success) {
        _addLog(state, emit, '蓝牙状态已切换');
        emit(state.copyWith(
          bluetoothEnabled: event.enabled,
          isToggling: false,
        ));
      } else {
        _addLog(state, emit, '切换蓝牙失败');
        emit(state.copyWith(
          isToggling: false,
          error: '切换蓝牙失败，请确保以管理员身份运行。',
        ));
      }
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '切换蓝牙异常: $e');
      emit(state.copyWith(
        isToggling: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onNetworkDevicesRefreshed(
    SystemControlNetworkDevicesRefreshed event,
    Emitter<SystemControlState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true, clearError: true));
    _addLog(state, emit, '正在刷新网络设备列表');

    try {
      final devices = await _networkRepo.getNetworkDevices();
      _addLog(state, emit, '网络设备列表已刷新: ${devices.length} 个设备');
      emit(state.copyWith(
        devices: devices,
        isSyncing: false,
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '刷新网络设备列表失败: $e');
      emit(state.copyWith(
        isSyncing: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onPowerAction(
    SystemControlPowerAction event,
    Emitter<SystemControlState> emit,
  ) async {
    emit(state.copyWith(isPowerActionExecuting: true, clearError: true));
    _addLog(state, emit, '正在执行电源操作: ${event.action.displayName}');

    try {
      final success = await _powerRepo.executePowerAction(event.action);
      if (success) {
        _addLog(state, emit, '电源操作已执行: ${event.action.displayName}');
        emit(state.copyWith(isPowerActionExecuting: false));
      } else {
        _addLog(state, emit, '电源操作执行失败: ${event.action.displayName}');
        emit(state.copyWith(
          isPowerActionExecuting: false,
          error: '执行${event.action.displayName}失败，请确保以管理员身份运行。',
        ));
      }
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '电源操作执行异常: $e');
      emit(state.copyWith(
        isPowerActionExecuting: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onDeviceInfoRefreshed(
    SystemControlDeviceInfoRefreshed event,
    Emitter<SystemControlState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true, clearError: true));
    _addLog(state, emit, '正在刷新设备信息');

    try {
      final devices = await _networkRepo.getNetworkDevices();

      // 更新设备状态
      bool wifiEnabled = true;
      bool bluetoothEnabled = true;
      bool ethernetEnabled = true;

      for (final device in devices) {
        switch (device.type) {
          case DeviceType.wifi:
            wifiEnabled = device.status == DeviceStatus.enabled;
            break;
          case DeviceType.bluetooth:
            bluetoothEnabled = device.status == DeviceStatus.enabled;
            break;
          case DeviceType.network:
            ethernetEnabled = device.status == DeviceStatus.enabled;
            break;
        }
      }

      emit(state.copyWith(
        devices: devices,
        wifiEnabled: wifiEnabled,
        bluetoothEnabled: bluetoothEnabled,
        ethernetEnabled: ethernetEnabled,
        isSyncing: false,
      ));
      _addLog(state, emit, '设备信息已刷新');
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '刷新设备信息失败: $e');
      emit(state.copyWith(
        isSyncing: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onTimeTestRequested(
    SystemControlTimeTestRequested event,
    Emitter<SystemControlState> emit,
  ) async {
    emit(state.copyWith(isSyncing: true, clearError: true));
    _addLog(state, emit, '正在测试时间同步: 服务器=${event.server}');

    try {
      final result = await _systemControlRepo.testTimeSync(event.server);
      final newResults = List<TimeSyncResult>.from(state.syncResults)..add(result);

      if (result.success) {
        _addLog(state, emit, '时间测试成功: 偏移=${result.offsetDescription}');
      } else {
        _addLog(state, emit, '时间测试失败: ${result.error}');
        emit(state.copyWith(error: result.error));
      }

      emit(state.copyWith(
        syncResults: newResults,
        isSyncing: false,
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '时间测试异常: $e');
      emit(state.copyWith(
        isSyncing: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }
}
