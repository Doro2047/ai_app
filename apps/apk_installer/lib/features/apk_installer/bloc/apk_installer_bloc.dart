library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';

// ============================================================
// Events
// ============================================================

abstract class ApkInstallerEvent extends Equatable {
  const ApkInstallerEvent();

  @override
  List<Object?> get props => [];
}

class ApkInstallerDevicesRefreshed extends ApkInstallerEvent {
  const ApkInstallerDevicesRefreshed();
}

class ApkInstallerDeviceSelected extends ApkInstallerEvent {
  final String deviceId;

  const ApkInstallerDeviceSelected(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class ApkInstallerFilesAdded extends ApkInstallerEvent {
  final List<String> filePaths;

  const ApkInstallerFilesAdded(this.filePaths);

  @override
  List<Object?> get props => [filePaths];
}

class ApkInstallerFileRemoved extends ApkInstallerEvent {
  final String filePath;

  const ApkInstallerFileRemoved(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ApkInstallerFilesCleared extends ApkInstallerEvent {
  const ApkInstallerFilesCleared();
}

class ApkInstallerReplaceToggled extends ApkInstallerEvent {
  final bool value;

  const ApkInstallerReplaceToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class ApkInstallerDowngradeToggled extends ApkInstallerEvent {
  final bool value;

  const ApkInstallerDowngradeToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class ApkInstallerInstallStarted extends ApkInstallerEvent {
  const ApkInstallerInstallStarted();
}

class ApkInstallerInstallCancelled extends ApkInstallerEvent {
  const ApkInstallerInstallCancelled();
}

class ApkInstallerInstallCompleted extends ApkInstallerEvent {
  final List<ApkInstallResult> results;

  const ApkInstallerInstallCompleted(this.results);

  @override
  List<Object?> get props => [results];
}

// ============================================================
// States
// ============================================================

class ApkInstallerState extends Equatable {
  final List<ApkDevice> devices;
  final String? selectedDeviceId;
  final List<ApkFile> apkFiles;
  final double installProgress;
  final String? currentInstallingApk;
  final List<ApkInstallResult> installResults;
  final InstallStatistics statistics;
  final bool isInstalling;
  final bool isDevicesLoading;
  final String? error;
  final List<String> logs;
  final bool replace;
  final bool allowDowngrade;
  final CancelToken? cancelToken;

  const ApkInstallerState({
    this.devices = const [],
    this.selectedDeviceId,
    this.apkFiles = const [],
    this.installProgress = 0.0,
    this.currentInstallingApk,
    this.installResults = const [],
    this.statistics = const InstallStatistics(),
    this.isInstalling = false,
    this.isDevicesLoading = false,
    this.error,
    this.logs = const [],
    this.replace = true,
    this.allowDowngrade = false,
    this.cancelToken,
  });

  ApkDevice? get selectedDevice {
    if (selectedDeviceId == null) return null;
    return devices.firstWhere(
      (d) => d.serialNumber == selectedDeviceId,
      orElse: () => const ApkDevice(
        id: '',
        name: '',
        serialNumber: '',
        status: 'offline',
      ),
    );
  }

  List<ApkFile> get selectedApkFiles =>
      apkFiles.where((f) => f.selected).toList();

  bool get canInstall =>
      selectedDeviceId != null && selectedApkFiles.isNotEmpty && !isInstalling;

  bool get isDeviceOnline => selectedDevice?.isOnline ?? false;

  ApkInstallerState copyWith({
    List<ApkDevice>? devices,
    String? selectedDeviceId,
    List<ApkFile>? apkFiles,
    double? installProgress,
    String? currentInstallingApk,
    List<ApkInstallResult>? installResults,
    InstallStatistics? statistics,
    bool? isInstalling,
    bool? isDevicesLoading,
    String? error,
    List<String>? logs,
    bool? replace,
    bool? allowDowngrade,
    CancelToken? cancelToken,
    bool clearError = false,
  }) {
    return ApkInstallerState(
      devices: devices ?? this.devices,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      apkFiles: apkFiles ?? this.apkFiles,
      installProgress: installProgress ?? this.installProgress,
      currentInstallingApk: currentInstallingApk ?? this.currentInstallingApk,
      installResults: installResults ?? this.installResults,
      statistics: statistics ?? this.statistics,
      isInstalling: isInstalling ?? this.isInstalling,
      isDevicesLoading: isDevicesLoading ?? this.isDevicesLoading,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
      replace: replace ?? this.replace,
      allowDowngrade: allowDowngrade ?? this.allowDowngrade,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  @override
  List<Object?> get props => [
        devices,
        selectedDeviceId,
        apkFiles,
        installProgress,
        currentInstallingApk,
        installResults,
        statistics,
        isInstalling,
        isDevicesLoading,
        error,
        logs,
        replace,
        allowDowngrade,
        cancelToken,
      ];
}

// ============================================================
// BLoC
// ============================================================

class ApkInstallerBloc extends Bloc<ApkInstallerEvent, ApkInstallerState> {
  final ApkInstallerRepository _repository;

  ApkInstallerBloc({
    ApkInstallerRepository? repository,
  })  : _repository = repository ?? ApkInstallerRepository(),
        super(const ApkInstallerState()) {
    on<ApkInstallerDevicesRefreshed>(_onDevicesRefreshed);
    on<ApkInstallerDeviceSelected>(_onDeviceSelected);
    on<ApkInstallerFilesAdded>(_onFilesAdded);
    on<ApkInstallerFileRemoved>(_onFileRemoved);
    on<ApkInstallerFilesCleared>(_onFilesCleared);
    on<ApkInstallerReplaceToggled>(_onReplaceToggled);
    on<ApkInstallerDowngradeToggled>(_onDowngradeToggled);
    on<ApkInstallerInstallStarted>(_onInstallStarted);
    on<ApkInstallerInstallCancelled>(_onInstallCancelled);
    on<ApkInstallerInstallCompleted>(_onInstallCompleted);
  }

  void _addLog(Emitter<ApkInstallerState> emit, String message) {
    final newLogs = List<String>.from(state.logs)..add(message);
    emit(state.copyWith(logs: newLogs));
  }

  Future<void> _onDevicesRefreshed(
    ApkInstallerDevicesRefreshed event,
    Emitter<ApkInstallerState> emit,
  ) async {
    if (!_repository.isAdbAvailable) {
      await _repository.initialize();
    }

    emit(state.copyWith(
      isDevicesLoading: true,
      clearError: true,
    ));
    _addLog(emit, 'Refreshing device list...');

    try {
      final devices = await _repository.listDevices();
      emit(state.copyWith(
        devices: devices,
        isDevicesLoading: false,
      ));

      if (devices.isEmpty) {
        _addLog(emit, 'No connected devices found');
      } else {
        _addLog(emit, 'Found ${devices.length} device(s)');
        if (state.selectedDeviceId == null ||
            !devices.any((d) =>
                d.serialNumber == state.selectedDeviceId && d.isOnline)) {
          final firstOnline = devices.firstWhere(
            (d) => d.isOnline,
            orElse: () => devices.first,
          );
          emit(state.copyWith(selectedDeviceId: firstOnline.serialNumber));
          _addLog(emit, 'Selected device: ${firstOnline.name}');
        }
      }
    } catch (e) {
      emit(state.copyWith(
        isDevicesLoading: false,
        error: 'Failed to refresh device list: $e',
      ));
      _addLog(emit, 'Failed to refresh device list: $e');
    }
  }

  void _onDeviceSelected(
    ApkInstallerDeviceSelected event,
    Emitter<ApkInstallerState> emit,
  ) {
    final device = state.devices.firstWhere(
      (d) => d.serialNumber == event.deviceId,
      orElse: () => const ApkDevice(
        id: '',
        name: '',
        serialNumber: '',
        status: 'offline',
      ),
    );

    emit(state.copyWith(
      selectedDeviceId: event.deviceId,
      clearError: true,
    ));
    _addLog(emit, 'Selected device: ${device.name}');
  }

  Future<void> _onFilesAdded(
    ApkInstallerFilesAdded event,
    Emitter<ApkInstallerState> emit,
  ) async {
    _addLog(emit, 'Parsing ${event.filePaths.length} APK file(s)...');

    final newFiles = <ApkFile>[];

    for (final path in event.filePaths) {
      try {
        final apkFile = await _repository.getApkInfo(path);
        newFiles.add(apkFile);
      } catch (e) {
        final name = path.split(RegExp(r'[/\\]')).last;
        newFiles.add(ApkFile(path: path, name: name));
      }
    }

    final existingPaths =
        state.apkFiles.map((f) => f.path).toSet();
    final uniqueNewFiles = newFiles
        .where((f) => !existingPaths.contains(f.path))
        .toList();

    if (uniqueNewFiles.isNotEmpty) {
      final updatedFiles = List<ApkFile>.from(state.apkFiles)
        ..addAll(uniqueNewFiles);

      emit(state.copyWith(
        apkFiles: updatedFiles,
        clearError: true,
      ));
      _addLog(emit,
          'Added ${uniqueNewFiles.length} APK file(s), total ${updatedFiles.length}');
    } else {
      _addLog(emit, 'Selected files already exist in the list');
    }
  }

  void _onFileRemoved(
    ApkInstallerFileRemoved event,
    Emitter<ApkInstallerState> emit,
  ) {
    final updatedFiles = state.apkFiles
        .where((f) => f.path != event.filePath)
        .toList();

    emit(state.copyWith(apkFiles: updatedFiles));
    final name = event.filePath.split(RegExp(r'[/\\]')).last;
    _addLog(emit, 'Removed: $name');
  }

  void _onFilesCleared(
    ApkInstallerFilesCleared event,
    Emitter<ApkInstallerState> emit,
  ) {
    emit(state.copyWith(
      apkFiles: [],
      installResults: [],
      statistics: const InstallStatistics(),
      installProgress: 0.0,
      currentInstallingApk: null,
    ));
    _addLog(emit, 'File list cleared');
  }

  void _onReplaceToggled(
    ApkInstallerReplaceToggled event,
    Emitter<ApkInstallerState> emit,
  ) {
    emit(state.copyWith(replace: event.value));
    _addLog(emit, 'Replace install: ${event.value ? "ON" : "OFF"}');
  }

  void _onDowngradeToggled(
    ApkInstallerDowngradeToggled event,
    Emitter<ApkInstallerState> emit,
  ) {
    emit(state.copyWith(allowDowngrade: event.value));
    _addLog(emit, 'Allow downgrade: ${event.value ? "ON" : "OFF"}');
  }

  Future<void> _onInstallStarted(
    ApkInstallerInstallStarted event,
    Emitter<ApkInstallerState> emit,
  ) async {
    if (state.selectedDeviceId == null) {
      emit(state.copyWith(error: 'Please select a target device first'));
      return;
    }

    if (state.selectedApkFiles.isEmpty) {
      emit(state.copyWith(error: 'Please add APK files first'));
      return;
    }

    final cancelToken = CancelToken();
    emit(state.copyWith(
      isInstalling: true,
      installProgress: 0.0,
      installResults: [],
      statistics: const InstallStatistics(),
      currentInstallingApk: null,
      clearError: true,
      cancelToken: cancelToken,
    ));

    _addLog(emit,
        'Starting install of ${state.selectedApkFiles.length} APK(s) to ${state.selectedDevice?.name}...');

    try {
      final results = await _repository.installMultiple(
        state.selectedApkFiles,
        state.selectedDeviceId!,
        replace: state.replace,
        allowDowngrade: state.allowDowngrade,
        cancelToken: cancelToken,
        onProgress: (current, total, apkName) {
          if (!emit.isDone) {
            emit(state.copyWith(
              installProgress: total > 0 ? current / total : 0.0,
              currentInstallingApk: apkName,
            ));
          }
        },
      );

      if (!emit.isDone) {
        final successCount = results.where((r) => r.success).length;
        final failedCount = results.where((r) => !r.success).length;
        final totalDuration = results.fold<Duration>(
          Duration.zero,
          (prev, r) => prev + r.duration,
        );

        final stats = InstallStatistics(
          totalFiles: state.selectedApkFiles.length,
          successCount: successCount,
          failedCount: failedCount,
          totalDuration: totalDuration,
        );

        emit(state.copyWith(
          isInstalling: false,
          installResults: results,
          installProgress: 1.0,
          currentInstallingApk: null,
          statistics: stats,
          cancelToken: null,
        ));

        _addLog(emit,
            'Install complete: Success $successCount, Failed $failedCount, Duration ${stats.formattedTotalDuration}');
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(
          isInstalling: false,
          error: 'Install error: $e',
          currentInstallingApk: null,
          cancelToken: null,
        ));
        _addLog(emit, 'Install error: $e');
      }
    }
  }

  void _onInstallCancelled(
    ApkInstallerInstallCancelled event,
    Emitter<ApkInstallerState> emit,
  ) {
    state.cancelToken?.cancel();
    emit(state.copyWith(
      isInstalling: false,
      installProgress: 0.0,
      currentInstallingApk: null,
      cancelToken: null,
    ));
    _addLog(emit, 'Install cancelled by user');
  }

  void _onInstallCompleted(
    ApkInstallerInstallCompleted event,
    Emitter<ApkInstallerState> emit,
  ) {
    final successCount = event.results.where((r) => r.success).length;
    final failedCount = event.results.where((r) => !r.success).length;
    final totalDuration = event.results.fold<Duration>(
      Duration.zero,
      (prev, r) => prev + r.duration,
    );

    emit(state.copyWith(
      installResults: event.results,
      statistics: InstallStatistics(
        totalFiles: state.selectedApkFiles.length,
        successCount: successCount,
        failedCount: failedCount,
        totalDuration: totalDuration,
      ),
      isInstalling: false,
      installProgress: 1.0,
      currentInstallingApk: null,
    ));
  }
}
