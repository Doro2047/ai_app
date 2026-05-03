library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';

// ============================================================
// Events
// ============================================================

abstract class SystemControlEvent extends Equatable {
  const SystemControlEvent();

  @override
  List<Object?> get props => [];
}

class SystemControlTimeSyncRequested extends SystemControlEvent {
  final String server;

  const SystemControlTimeSyncRequested(this.server);

  @override
  List<Object?> get props => [server];
}

class SystemControlTimeSet extends SystemControlEvent {
  final DateTime dateTime;

  const SystemControlTimeSet(this.dateTime);

  @override
  List<Object?> get props => [dateTime];
}

class SystemControlNtpServersRefreshed extends SystemControlEvent {
  const SystemControlNtpServersRefreshed();
}

class SystemControlWifiToggled extends SystemControlEvent {
  final bool enabled;

  const SystemControlWifiToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SystemControlBluetoothToggled extends SystemControlEvent {
  final bool enabled;

  const SystemControlBluetoothToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SystemControlNetworkDevicesRefreshed extends SystemControlEvent {
  const SystemControlNetworkDevicesRefreshed();
}

class SystemControlPowerAction extends SystemControlEvent {
  final PowerAction action;

  const SystemControlPowerAction(this.action);

  @override
  List<Object?> get props => [action];
}

class SystemControlDeviceInfoRefreshed extends SystemControlEvent {
  const SystemControlDeviceInfoRefreshed();
}

class SystemControlTimeTestRequested extends SystemControlEvent {
  final String server;

  const SystemControlTimeTestRequested(this.server);

  @override
  List<Object?> get props => [server];
}

// ============================================================
// State
// ============================================================

class SystemControlState extends Equatable {
  final DateTime localTime;
  final List<TimeServer> ntpServers;
  final String selectedServer;
  final List<TimeSyncResult> syncResults;
  final List<DeviceInfo> devices;
  final bool wifiEnabled;
  final bool bluetoothEnabled;
  final bool ethernetEnabled;
  final bool isSyncing;
  final bool isToggling;
  final bool isPowerActionExecuting;
  final String? error;
  final List<String> logs;
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

  TimeSyncResult? get latestSyncResult =>
      syncResults.isNotEmpty ? syncResults.last : null;

  bool get hasError => error != null;

  String get deviceStatusText {
    final statuses = [
      if (wifiEnabled) 'WiFi: \u5DF2\u542F\u7528' else 'WiFi: \u5DF2\u7981\u7528',
      if (bluetoothEnabled) '\u84DD\u7259: \u5DF2\u542F\u7528' else '\u84DD\u7259: \u5DF2\u7981\u7528',
      if (ethernetEnabled) '\u4EE5\u592A\u7F51: \u5DF2\u542F\u7528' else '\u4EE5\u592A\u7F51: \u5DF2\u7981\u7528',
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

class SystemControlBloc extends Bloc<SystemControlEvent, SystemControlState> {
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
    _addLog(state, emit, '\u6B63\u5728\u540C\u6B65\u65F6\u95F4: \u670D\u52A1\u5668=${event.server}');

    try {
      final result = await _systemControlRepo.syncTime(event.server);
      final newResults = List<TimeSyncResult>.from(state.syncResults)..add(result);

      if (result.success) {
        _addLog(state, emit, '\u65F6\u95F4\u540C\u6B65\u6210\u529F: \u504F\u79FB=${result.offsetDescription}');
      } else {
        _addLog(state, emit, '\u65F6\u95F4\u540C\u6B65\u5931\u8D25: ${result.error}');
        emit(state.copyWith(error: result.error));
      }

      emit(state.copyWith(
        syncResults: newResults,
        localTime: DateTime.now(),
        isSyncing: false,
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '\u65F6\u95F4\u540C\u6B65\u5F02\u5E38: $e');
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
    _addLog(state, emit, '\u6B63\u5728\u8BBE\u7F6E\u7CFB\u7EDF\u65F6\u95F4: ${event.dateTime}');

    try {
      final success = await _systemControlRepo.setTime(event.dateTime);
      if (success) {
        _addLog(state, emit, '\u7CFB\u7EDF\u65F6\u95F4\u8BBE\u7F6E\u6210\u529F');
        emit(state.copyWith(
          localTime: DateTime.now(),
          isSyncing: false,
        ));
      } else {
        _addLog(state, emit, '\u7CFB\u7EDF\u65F6\u95F4\u8BBE\u7F6E\u5931\u8D25');
        emit(state.copyWith(
          isSyncing: false,
          error: '\u8BBE\u7F6E\u7CFB\u7EDF\u65F6\u95F4\u5931\u8D25\uFF0C\u8BF7\u786E\u4FDD\u4EE5\u7BA1\u7406\u5458\u8EAB\u4EFD\u8FD0\u884C\u3002',
        ));
      }
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '\u8BBE\u7F6E\u7CFB\u7EDF\u65F6\u95F4\u5F02\u5E38: $e');
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
    _addLog(state, emit, '\u6B63\u5728\u5237\u65B0 NTP \u670D\u52A1\u5668\u5217\u8868');

    try {
      final servers = await _systemControlRepo.getNtpServers();
      _addLog(state, emit, 'NTP \u670D\u52A1\u5668\u5217\u8868\u5DF2\u5237\u65B0: ${servers.length} \u4E2A\u670D\u52A1\u5668');
      emit(state.copyWith(
        ntpServers: servers,
        isSyncing: false,
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '\u5237\u65B0 NTP \u670D\u52A1\u5668\u5217\u8868\u5931\u8D25: $e');
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
    _addLog(state, emit, '\u6B63\u5728\u5207\u6362 WiFi: ${event.enabled ? "\u542F\u7528" : "\u7981\u7528"}');

    try {
      final success = await _networkRepo.toggleWifi(event.enabled);
      if (success) {
        _addLog(state, emit, 'WiFi \u72B6\u6001\u5DF2\u5207\u6362');
        emit(state.copyWith(
          wifiEnabled: event.enabled,
          isToggling: false,
        ));
      } else {
        _addLog(state, emit, '\u5207\u6362 WiFi \u5931\u8D25');
        emit(state.copyWith(
          isToggling: false,
          error: '\u5207\u6362 WiFi \u5931\u8D25\uFF0C\u8BF7\u786E\u4FDD\u4EE5\u7BA1\u7406\u5458\u8EAB\u4EFD\u8FD0\u884C\u3002',
        ));
      }
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '\u5207\u6362 WiFi \u5F02\u5E38: $e');
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
    _addLog(state, emit, '\u6B63\u5728\u5207\u6362\u84DD\u7259: ${event.enabled ? "\u542F\u7528" : "\u7981\u7528"}');

    try {
      final success = await _networkRepo.toggleBluetooth(event.enabled);
      if (success) {
        _addLog(state, emit, '\u84DD\u7259\u72B6\u6001\u5DF2\u5207\u6362');
        emit(state.copyWith(
          bluetoothEnabled: event.enabled,
          isToggling: false,
        ));
      } else {
        _addLog(state, emit, '\u5207\u6362\u84DD\u7259\u5931\u8D25');
        emit(state.copyWith(
          isToggling: false,
          error: '\u5207\u6362\u84DD\u7259\u5931\u8D25\uFF0C\u8BF7\u786E\u4FDD\u4EE5\u7BA1\u7406\u5458\u8EAB\u4EFD\u8FD0\u884C\u3002',
        ));
      }
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '\u5207\u6362\u84DD\u7259\u5F02\u5E38: $e');
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
    _addLog(state, emit, '\u6B63\u5728\u5237\u65B0\u7F51\u7EDC\u8BBE\u5907\u5217\u8868');

    try {
      final devices = await _networkRepo.getNetworkDevices();
      _addLog(state, emit, '\u7F51\u7EDC\u8BBE\u5907\u5217\u8868\u5DF2\u5237\u65B0: ${devices.length} \u4E2A\u8BBE\u5907');
      emit(state.copyWith(
        devices: devices,
        isSyncing: false,
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '\u5237\u65B0\u7F51\u7EDC\u8BBE\u5907\u5217\u8868\u5931\u8D25: $e');
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
    _addLog(state, emit, '\u6B63\u5728\u6267\u884C\u7535\u6E90\u64CD\u4F5C: ${event.action.displayName}');

    try {
      final success = await _powerRepo.executePowerAction(event.action);
      if (success) {
        _addLog(state, emit, '\u7535\u6E90\u64CD\u4F5C\u5DF2\u6267\u884C: ${event.action.displayName}');
        emit(state.copyWith(isPowerActionExecuting: false));
      } else {
        _addLog(state, emit, '\u7535\u6E90\u64CD\u4F5C\u6267\u884C\u5931\u8D25: ${event.action.displayName}');
        emit(state.copyWith(
          isPowerActionExecuting: false,
          error: '\u6267\u884C${event.action.displayName}\u5931\u8D25\uFF0C\u8BF7\u786E\u4FDD\u4EE5\u7BA1\u7406\u5458\u8EAB\u4EFD\u8FD0\u884C\u3002',
        ));
      }
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '\u7535\u6E90\u64CD\u4F5C\u6267\u884C\u5F02\u5E38: $e');
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
    _addLog(state, emit, '\u6B63\u5728\u5237\u65B0\u8BBE\u5907\u4FE1\u606F');

    try {
      final devices = await _networkRepo.getNetworkDevices();

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
      _addLog(state, emit, '\u8BBE\u5907\u4FE1\u606F\u5DF2\u5237\u65B0');
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '\u5237\u65B0\u8BBE\u5907\u4FE1\u606F\u5931\u8D25: $e');
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
    _addLog(state, emit, '\u6B63\u5728\u6D4B\u8BD5\u65F6\u95F4\u540C\u6B65: \u670D\u52A1\u5668=${event.server}');

    try {
      final result = await _systemControlRepo.testTimeSync(event.server);
      final newResults = List<TimeSyncResult>.from(state.syncResults)..add(result);

      if (result.success) {
        _addLog(state, emit, '\u65F6\u95F4\u6D4B\u8BD5\u6210\u529F: \u504F\u79FB=${result.offsetDescription}');
      } else {
        _addLog(state, emit, '\u65F6\u95F4\u6D4B\u8BD5\u5931\u8D25: ${result.error}');
        emit(state.copyWith(error: result.error));
      }

      emit(state.copyWith(
        syncResults: newResults,
        isSyncing: false,
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '\u65F6\u95F4\u6D4B\u8BD5\u5F02\u5E38: $e');
      emit(state.copyWith(
        isSyncing: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }
}
