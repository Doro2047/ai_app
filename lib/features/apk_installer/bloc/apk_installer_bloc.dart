/// APK 安装器 BLoC
///
/// 管理 APK 批量安装工具的完整状态流。
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/bloc/feature_bloc_base.dart';
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

/// 刷新设备列表
class ApkInstallerDevicesRefreshed extends ApkInstallerEvent {
  const ApkInstallerDevicesRefreshed();
}

/// 选择设备
class ApkInstallerDeviceSelected extends ApkInstallerEvent {
  final String deviceId;

  const ApkInstallerDeviceSelected(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

/// 添加文件
class ApkInstallerFilesAdded extends ApkInstallerEvent {
  final List<String> filePaths;

  const ApkInstallerFilesAdded(this.filePaths);

  @override
  List<Object?> get props => [filePaths];
}

/// 移除文件
class ApkInstallerFileRemoved extends ApkInstallerEvent {
  final String filePath;

  const ApkInstallerFileRemoved(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// 清空文件列表
class ApkInstallerFilesCleared extends ApkInstallerEvent {
  const ApkInstallerFilesCleared();
}

/// 切换覆盖安装
class ApkInstallerReplaceToggled extends ApkInstallerEvent {
  final bool value;

  const ApkInstallerReplaceToggled(this.value);

  @override
  List<Object?> get props => [value];
}

/// 切换允许降级
class ApkInstallerDowngradeToggled extends ApkInstallerEvent {
  final bool value;

  const ApkInstallerDowngradeToggled(this.value);

  @override
  List<Object?> get props => [value];
}

/// 开始安装
class ApkInstallerInstallStarted extends ApkInstallerEvent {
  const ApkInstallerInstallStarted();
}

/// 取消安装
class ApkInstallerInstallCancelled extends ApkInstallerEvent {
  const ApkInstallerInstallCancelled();
}

/// 安装完成
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
  /// 设备列表
  final List<ApkDevice> devices;

  /// 选中的设备 ID
  final String? selectedDeviceId;

  /// APK 文件列表
  final List<ApkFile> apkFiles;

  /// 安装进度 (0.0 - 1.0)
  final double installProgress;

  /// 当前正在安装的 APK
  final String? currentInstallingApk;

  /// 安装结果列表
  final List<ApkInstallResult> installResults;

  /// 安装统计
  final InstallStatistics statistics;

  /// 是否正在安装
  final bool isInstalling;

  /// 是否正在加载设备
  final bool isDevicesLoading;

  /// 错误信息
  final String? error;

  /// 日志消息
  final List<String> logs;

  /// 是否覆盖安装
  final bool replace;

  /// 是否允许降级
  final bool allowDowngrade;

  /// 取消令牌
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

  /// 选中的设备
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

  /// 选中的 APK 文件
  List<ApkFile> get selectedApkFiles =>
      apkFiles.where((f) => f.selected).toList();

  /// 是否可以开始安装
  bool get canInstall =>
      selectedDeviceId != null && selectedApkFiles.isNotEmpty && !isInstalling;

  /// 选中的设备是否在线
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

class ApkInstallerBloc extends FeatureBlocBase<ApkInstallerEvent, ApkInstallerState> {
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
    // 检查 ADB 是否初始化
    if (!_repository.isAdbAvailable) {
      await _repository.initialize();
    }

    emit(state.copyWith(
      isDevicesLoading: true,
      clearError: true,
    ));
    _addLog(emit, '正在刷新设备列表...');

    try {
      final devices = await _repository.listDevices();
      emit(state.copyWith(
        devices: devices,
        isDevicesLoading: false,
      ));

      if (devices.isEmpty) {
        _addLog(emit, '未发现已连接的设备');
      } else {
        _addLog(emit, '发现 ${devices.length} 个设备');
        // 如果当前选中的设备不在线，选择第一个在线设备
        if (state.selectedDeviceId == null ||
            !devices.any((d) =>
                d.serialNumber == state.selectedDeviceId && d.isOnline)) {
          final firstOnline = devices.firstWhere(
            (d) => d.isOnline,
            orElse: () => devices.first,
          );
          emit(state.copyWith(selectedDeviceId: firstOnline.serialNumber));
          _addLog(emit, '已选择设备: ${firstOnline.name}');
        }
      }
    } catch (e) {
      emit(state.copyWith(
        isDevicesLoading: false,
        error: '刷新设备列表失败: $e',
      ));
      _addLog(emit, '刷新设备列表失败: $e');
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
    _addLog(emit, '已选择设备: ${device.name}');
  }

  Future<void> _onFilesAdded(
    ApkInstallerFilesAdded event,
    Emitter<ApkInstallerState> emit,
  ) async {
    _addLog(emit, '正在解析 ${event.filePaths.length} 个 APK 文件...');

    final newFiles = <ApkFile>[];

    for (final path in event.filePaths) {
      try {
        final apkFile = await _repository.getApkInfo(path);
        newFiles.add(apkFile);
      } catch (e) {
        // 解析失败时使用基本信息
        final name = path.split(RegExp(r'[/\\]')).last;
        newFiles.add(ApkFile(path: path, name: name));
      }
    }

    // 去重：跳过已存在的文件
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
          '已添加 ${uniqueNewFiles.length} 个 APK 文件，当前共 ${updatedFiles.length} 个');
    } else {
      _addLog(emit, '所选文件已存在于列表中');
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
    _addLog(emit, '已移除: $name');
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
    _addLog(emit, '已清空文件列表');
  }

  void _onReplaceToggled(
    ApkInstallerReplaceToggled event,
    Emitter<ApkInstallerState> emit,
  ) {
    emit(state.copyWith(replace: event.value));
    _addLog(emit, '覆盖安装: ${event.value ? "开启" : "关闭"}');
  }

  void _onDowngradeToggled(
    ApkInstallerDowngradeToggled event,
    Emitter<ApkInstallerState> emit,
  ) {
    emit(state.copyWith(allowDowngrade: event.value));
    _addLog(emit, '允许降级: ${event.value ? "开启" : "关闭"}');
  }

  Future<void> _onInstallStarted(
    ApkInstallerInstallStarted event,
    Emitter<ApkInstallerState> emit,
  ) async {
    if (state.selectedDeviceId == null) {
      emit(state.copyWith(error: '请先选择目标设备'));
      return;
    }

    if (state.selectedApkFiles.isEmpty) {
      emit(state.copyWith(error: '请先添加 APK 文件'));
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
        '开始安装 ${state.selectedApkFiles.length} 个 APK 到 ${state.selectedDevice?.name}...');

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
        // 计算统计
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
            '安装完成: 成功 $successCount, 失败 $failedCount, 总耗时 ${stats.formattedTotalDuration}');
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(
          isInstalling: false,
          error: '安装过程出错: $e',
          currentInstallingApk: null,
          cancelToken: null,
        ));
        _addLog(emit, '安装过程出错: $e');
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
    _addLog(emit, '安装已用户取消');
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
