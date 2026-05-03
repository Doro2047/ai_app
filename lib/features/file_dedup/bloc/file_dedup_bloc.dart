/// 文件查重清理 BLoC
///
/// 管理批量文件查重清理工具的状态和事件。
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/error_handler.dart';
import '../../../shared/bloc/feature_bloc_base.dart';
import '../models/models.dart';
import '../repositories/file_dedup_repository.dart';

// ============================================================
// Events
// ============================================================

/// 文件查重事件基类
abstract class FileDedupEvent {
  const FileDedupEvent();
}

/// 选择目录
class FileDedupDirectoriesSelected extends FileDedupEvent {
  final List<String> directories;

  const FileDedupDirectoriesSelected(this.directories);
}

/// 配置变更
class FileDedupConfigChanged extends FileDedupEvent {
  final ScanConfig config;

  const FileDedupConfigChanged(this.config);
}

/// 开始扫描
class FileDedupScanStarted extends FileDedupEvent {
  const FileDedupScanStarted();
}

/// 取消扫描
class FileDedupScanCancelled extends FileDedupEvent {
  const FileDedupScanCancelled();
}

/// 扫描完成
class FileDedupScanComplete extends FileDedupEvent {
  final List<FileHashResult> files;
  final List<DuplicateGroup> groups;

  const FileDedupScanComplete(this.files, this.groups);
}

/// 文件选中/取消选中
class FileDedupFileSelected extends FileDedupEvent {
  final String hash;
  final String filePath;
  final bool isSelected;

  const FileDedupFileSelected(this.hash, this.filePath, this.isSelected);
}

/// 全选组内文件
class FileDedupSelectAll extends FileDedupEvent {
  final String hash;

  const FileDedupSelectAll(this.hash);
}

/// 取消选中组内所有文件
class FileDedupDeselectAll extends FileDedupEvent {
  final String hash;

  const FileDedupDeselectAll(this.hash);
}

/// 请求删除
class FileDedupDeleteRequested extends FileDedupEvent {
  const FileDedupDeleteRequested();
}

/// 确认删除
class FileDedupDeleteConfirmed extends FileDedupEvent {
  const FileDedupDeleteConfirmed();
}

// ============================================================
// State
// ============================================================

/// 文件查重状态
@immutable
class FileDedupState {
  /// 选择的目录列表
  final List<String> directories;

  /// 扫描配置
  final ScanConfig config;

  /// 扫描进度 (0.0 - 1.0)
  final double scanProgress;

  /// 当前正在扫描的文件
  final String currentScanningFile;

  /// 扫描结果列表
  final List<FileHashResult> results;

  /// 重复文件组列表
  final List<DuplicateGroup> duplicateGroups;

  /// 已选中的文件路径集合
  final Set<String> selectedFiles;

  /// 统计信息
  final ScanStatistics statistics;

  /// 是否正在扫描
  final bool isScanning;

  /// 是否正在删除
  final bool isDeleting;

  /// 扫描是否完成
  final bool isScanComplete;

  /// 错误信息
  final String? error;

  /// 日志消息列表
  final List<String> logs;

  /// 删除结果
  final (List<String> deletedSuccess, List<String> deletedFailed)? deleteResult;

  const FileDedupState({
    this.directories = const [],
    this.config = const ScanConfig(),
    this.scanProgress = 0.0,
    this.currentScanningFile = '',
    this.results = const [],
    this.duplicateGroups = const [],
    this.selectedFiles = const {},
    this.statistics = const ScanStatistics(),
    this.isScanning = false,
    this.isDeleting = false,
    this.isScanComplete = false,
    this.error,
    this.logs = const [],
    this.deleteResult,
  });

  /// 是否有选中的文件
  bool get hasSelectedFiles => selectedFiles.isNotEmpty;

  /// 是否有重复组
  bool get hasDuplicates => duplicateGroups.isNotEmpty;

  /// 选中的文件总数
  int get selectedFileCount => selectedFiles.length;

  /// 选中的文件总大小
  int get selectedFileSize {
    int total = 0;
    for (final group in duplicateGroups) {
      for (int i = 0; i < group.selectedFiles.length; i++) {
        total += group.size;
      }
    }
    return total;
  }

  FileDedupState copyWith({
    List<String>? directories,
    ScanConfig? config,
    double? scanProgress,
    String? currentScanningFile,
    List<FileHashResult>? results,
    List<DuplicateGroup>? duplicateGroups,
    Set<String>? selectedFiles,
    ScanStatistics? statistics,
    bool? isScanning,
    bool? isDeleting,
    bool? isScanComplete,
    String? error,
    List<String>? logs,
    (List<String> deletedSuccess, List<String> deletedFailed)? deleteResult,
    bool clearError = false,
  }) {
    return FileDedupState(
      directories: directories ?? this.directories,
      config: config ?? this.config,
      scanProgress: scanProgress ?? this.scanProgress,
      currentScanningFile: currentScanningFile ?? this.currentScanningFile,
      results: results ?? this.results,
      duplicateGroups: duplicateGroups ?? this.duplicateGroups,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      statistics: statistics ?? this.statistics,
      isScanning: isScanning ?? this.isScanning,
      isDeleting: isDeleting ?? this.isDeleting,
      isScanComplete: isScanComplete ?? this.isScanComplete,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
      deleteResult: deleteResult ?? this.deleteResult,
    );
  }
}

// ============================================================
// BLoC
// ============================================================

/// 文件查重 BLoC
class FileDedupBloc extends FeatureBlocBase<FileDedupEvent, FileDedupState> {
  final FileDedupRepository _repository;
  Completer<void>? _cancelCompleter;

  FileDedupBloc({FileDedupRepository? repository})
      : _repository = repository ?? FileDedupRepository(),
        super(const FileDedupState()) {
    on<FileDedupDirectoriesSelected>(_onDirectoriesSelected);
    on<FileDedupConfigChanged>(_onConfigChanged);
    on<FileDedupScanStarted>(_onScanStarted);
    on<FileDedupScanCancelled>(_onScanCancelled);
    on<FileDedupScanComplete>(_onScanComplete);
    on<FileDedupFileSelected>(_onFileSelected);
    on<FileDedupSelectAll>(_onSelectAll);
    on<FileDedupDeselectAll>(_onDeselectAll);
    on<FileDedupDeleteRequested>(_onDeleteRequested);
    on<FileDedupDeleteConfirmed>(_onDeleteConfirmed);
  }

  void _addLog(Emitter<FileDedupState> emit, String message) {
    final newLogs = List<String>.from(state.logs)..add(message);
    emit(state.copyWith(logs: newLogs));
  }

  void _onDirectoriesSelected(
    FileDedupDirectoriesSelected event,
    Emitter<FileDedupState> emit,
  ) {
    emit(state.copyWith(
      directories: event.directories,
      config: state.config.copyWith(directories: event.directories),
      results: [],
      duplicateGroups: [],
      selectedFiles: {},
      statistics: const ScanStatistics(),
      isScanComplete: false,
      deleteResult: null,
      clearError: true,
    ));
    _addLog(emit, '已选择 ${event.directories.length} 个目录');
  }

  void _onConfigChanged(
    FileDedupConfigChanged event,
    Emitter<FileDedupState> emit,
  ) {
    emit(state.copyWith(
      config: event.config,
      isScanComplete: false,
      deleteResult: null,
    ));
    _addLog(emit, '扫描配置已更新');
  }

  Future<void> _onScanStarted(
    FileDedupScanStarted event,
    Emitter<FileDedupState> emit,
  ) async {
    if (state.directories.isEmpty) {
      emit(state.copyWith(error: '请先选择要扫描的目录'));
      return;
    }

    _cancelCompleter = Completer<void>();
    emit(state.copyWith(
      isScanning: true,
      scanProgress: 0.0,
      results: [],
      duplicateGroups: [],
      selectedFiles: {},
      statistics: const ScanStatistics(),
      isScanComplete: false,
      deleteResult: null,
      clearError: true,
    ));
    _addLog(emit, '开始扫描文件...');

    try {
      final files = await _repository.scanFiles(
        state.directories,
        recursive: state.config.recursive,
        cancelToken: _cancelCompleter,
        onProgress: (current, total) {
          if (!isClosed) {
            emit(state.copyWith(
              scanProgress: total > 0 ? current / total : 0.0,
              currentScanningFile: '正在计算哈希: $current/$total',
            ));
          }
        },
      );

      if (_cancelCompleter?.isCompleted == true) {
        _addLog(emit, '扫描已取消');
        emit(state.copyWith(
          isScanning: false,
          scanProgress: 0.0,
        ));
        return;
      }

      // 查找重复文件
      final groups = _repository.findDuplicates(files);

      add(FileDedupScanComplete(files, groups));

      _addLog(emit, '扫描完成: 发现 ${files.length} 个文件, ${groups.length} 组重复文件');
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(emit, '扫描失败: $e');
      emit(state.copyWith(
        isScanning: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  void _onScanCancelled(
    FileDedupScanCancelled event,
    Emitter<FileDedupState> emit,
  ) {
    _cancelCompleter?.complete();
    _addLog(emit, '正在取消扫描...');
  }

  void _onScanComplete(
    FileDedupScanComplete event,
    Emitter<FileDedupState> emit,
  ) {
    // 计算所有选中文件的总大小
    int totalSelectedSize = 0;
    final allSelectedPaths = <String>{};
    for (final group in event.groups) {
      totalSelectedSize += group.spaceSavings;
      allSelectedPaths.addAll(group.selectedFiles);
    }

    final statistics = ScanStatistics(
      totalFiles: event.files.length,
      scannedFiles: event.files.length,
      duplicateGroups: event.groups.length,
      duplicateFiles: event.groups.fold(0, (sum, g) => sum + g.files.length - 1),
      duplicateSize: totalSelectedSize,
      skippedFiles: 0,
    );

    emit(state.copyWith(
      isScanning: false,
      scanProgress: 1.0,
      results: event.files,
      duplicateGroups: event.groups,
      selectedFiles: allSelectedPaths,
      statistics: statistics,
      isScanComplete: true,
    ));
  }

  void _onFileSelected(
    FileDedupFileSelected event,
    Emitter<FileDedupState> emit,
  ) {
    final updatedGroups = state.duplicateGroups.map((group) {
      if (group.hash == event.hash) {
        return group.copyWithFileSelection(
          filePath: event.filePath,
          isSelected: event.isSelected,
        );
      }
      return group;
    }).toList();

    // 更新选中文件集合
    final newSelectedFiles = <String>{};
    for (final group in updatedGroups) {
      newSelectedFiles.addAll(group.selectedFiles);
    }

    // 重新计算统计
    int totalSelectedSize = 0;
    for (final group in updatedGroups) {
      totalSelectedSize += group.spaceSavings;
    }

    final statistics = state.statistics.copyWith(
      duplicateSize: totalSelectedSize,
    );

    emit(state.copyWith(
      duplicateGroups: updatedGroups,
      selectedFiles: newSelectedFiles,
      statistics: statistics,
    ));
  }

  void _onSelectAll(
    FileDedupSelectAll event,
    Emitter<FileDedupState> emit,
  ) {
    final updatedGroups = state.duplicateGroups.map((group) {
      if (group.hash == event.hash) {
        return group.selectAllButFirst();
      }
      return group;
    }).toList();

    final newSelectedFiles = <String>{};
    for (final group in updatedGroups) {
      newSelectedFiles.addAll(group.selectedFiles);
    }

    int totalSelectedSize = 0;
    for (final group in updatedGroups) {
      totalSelectedSize += group.spaceSavings;
    }

    emit(state.copyWith(
      duplicateGroups: updatedGroups,
      selectedFiles: newSelectedFiles,
      statistics: state.statistics.copyWith(duplicateSize: totalSelectedSize),
    ));
  }

  void _onDeselectAll(
    FileDedupDeselectAll event,
    Emitter<FileDedupState> emit,
  ) {
    final updatedGroups = state.duplicateGroups.map((group) {
      if (group.hash == event.hash) {
        return group.deselectAll();
      }
      return group;
    }).toList();

    final newSelectedFiles = <String>{};
    for (final group in updatedGroups) {
      newSelectedFiles.addAll(group.selectedFiles);
    }

    int totalSelectedSize = 0;
    for (final group in updatedGroups) {
      totalSelectedSize += group.spaceSavings;
    }

    emit(state.copyWith(
      duplicateGroups: updatedGroups,
      selectedFiles: newSelectedFiles,
      statistics: state.statistics.copyWith(duplicateSize: totalSelectedSize),
    ));
  }

  void _onDeleteRequested(
    FileDedupDeleteRequested event,
    Emitter<FileDedupState> emit,
  ) {
    if (state.selectedFiles.isEmpty) {
      emit(state.copyWith(error: '请先选择要删除的文件'));
      return;
    }
    // 该事件仅用于触发确认对话框，实际删除在 DeleteConfirmed 中处理
  }

  Future<void> _onDeleteConfirmed(
    FileDedupDeleteConfirmed event,
    Emitter<FileDedupState> emit,
  ) async {
    if (state.selectedFiles.isEmpty) {
      emit(state.copyWith(error: '没有选中的文件'));
      return;
    }

    emit(state.copyWith(
      isDeleting: true,
      clearError: true,
    ));
    _addLog(emit, '开始删除 ${state.selectedFiles.length} 个文件...');

    try {
      final pathsToDelete = state.selectedFiles.toList();
      final (success, failed) = await _repository.deleteFiles(pathsToDelete);

      // 移除已删除的文件组
      final updatedGroups = state.duplicateGroups.map((group) {
        final remainingFiles = group.files
            .where((f) => !success.contains(f.path))
            .toList();

        if (remainingFiles.length <= 1) {
          // 如果组内只剩 0 或 1 个文件，移除该组
          return null;
        }

        // 更新选中状态
        final newSelected = <String>{};
        for (final path in group.selectedFiles) {
          if (!success.contains(path)) {
            newSelected.add(path);
          }
        }

        return DuplicateGroup(
          hash: group.hash,
          size: group.size,
          files: remainingFiles,
          selectedFiles: newSelected,
        );
      }).whereType<DuplicateGroup>().toList();

      // 重新计算统计
      int totalSelectedSize = 0;
      final newSelectedFiles = <String>{};
      for (final group in updatedGroups) {
        totalSelectedSize += group.spaceSavings;
        newSelectedFiles.addAll(group.selectedFiles);
      }

      int totalDuplicateFiles = 0;
      for (final group in updatedGroups) {
        totalDuplicateFiles += group.files.length - 1;
      }

      final statistics = ScanStatistics(
        totalFiles: state.statistics.totalFiles - success.length,
        scannedFiles: state.statistics.scannedFiles - success.length,
        duplicateGroups: updatedGroups.length,
        duplicateFiles: totalDuplicateFiles,
        duplicateSize: totalSelectedSize,
        skippedFiles: state.statistics.skippedFiles,
      );

      _addLog(emit, '删除完成: 成功 ${success.length}, 失败 ${failed.length}');

      emit(state.copyWith(
        duplicateGroups: updatedGroups,
        selectedFiles: newSelectedFiles,
        statistics: statistics,
        isDeleting: false,
        deleteResult: (success, failed),
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(emit, '删除失败: $e');
      emit(state.copyWith(
        isDeleting: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  /// 格式化文件大小
  // ignore: unused_element
  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
