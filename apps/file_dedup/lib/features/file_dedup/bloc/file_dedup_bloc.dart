/// File dedup BLoC
///
/// Manages state and events for the batch file dedup cleaner tool.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import '../models/models.dart';
import '../repositories/file_dedup_repository.dart';

// ============================================================
// Events
// ============================================================

/// File dedup event base class
abstract class FileDedupEvent {
  const FileDedupEvent();
}

/// Select directories
class FileDedupDirectoriesSelected extends FileDedupEvent {
  final List<String> directories;

  const FileDedupDirectoriesSelected(this.directories);
}

/// Configuration changed
class FileDedupConfigChanged extends FileDedupEvent {
  final ScanConfig config;

  const FileDedupConfigChanged(this.config);
}

/// Start scanning
class FileDedupScanStarted extends FileDedupEvent {
  const FileDedupScanStarted();
}

/// Cancel scanning
class FileDedupScanCancelled extends FileDedupEvent {
  const FileDedupScanCancelled();
}

/// Scan complete
class FileDedupScanComplete extends FileDedupEvent {
  final List<FileHashResult> files;
  final List<DuplicateGroup> groups;

  const FileDedupScanComplete(this.files, this.groups);
}

/// File selected/deselected
class FileDedupFileSelected extends FileDedupEvent {
  final String hash;
  final String filePath;
  final bool isSelected;

  const FileDedupFileSelected(this.hash, this.filePath, this.isSelected);
}

/// Select all files in group
class FileDedupSelectAll extends FileDedupEvent {
  final String hash;

  const FileDedupSelectAll(this.hash);
}

/// Deselect all files in group
class FileDedupDeselectAll extends FileDedupEvent {
  final String hash;

  const FileDedupDeselectAll(this.hash);
}

/// Request deletion
class FileDedupDeleteRequested extends FileDedupEvent {
  const FileDedupDeleteRequested();
}

/// Confirm deletion
class FileDedupDeleteConfirmed extends FileDedupEvent {
  const FileDedupDeleteConfirmed();
}

// ============================================================
// State
// ============================================================

/// File dedup state
@immutable
class FileDedupState {
  /// Selected directory list
  final List<String> directories;

  /// Scan configuration
  final ScanConfig config;

  /// Scan progress (0.0 - 1.0)
  final double scanProgress;

  /// Currently scanning file
  final String currentScanningFile;

  /// Scan result list
  final List<FileHashResult> results;

  /// Duplicate file group list
  final List<DuplicateGroup> duplicateGroups;

  /// Set of selected file paths
  final Set<String> selectedFiles;

  /// Statistics
  final ScanStatistics statistics;

  /// Whether scanning is in progress
  final bool isScanning;

  /// Whether deletion is in progress
  final bool isDeleting;

  /// Whether scan is complete
  final bool isScanComplete;

  /// Error message
  final String? error;

  /// Log message list
  final List<String> logs;

  /// Deletion result
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

  /// Whether there are selected files
  bool get hasSelectedFiles => selectedFiles.isNotEmpty;

  /// Whether there are duplicate groups
  bool get hasDuplicates => duplicateGroups.isNotEmpty;

  /// Total number of selected files
  int get selectedFileCount => selectedFiles.length;

  /// Total size of selected files
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

/// File dedup BLoC
class FileDedupBloc extends Bloc<FileDedupEvent, FileDedupState> {
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
    _addLog(emit, 'Selected ${event.directories.length} directories');
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
    _addLog(emit, 'Scan configuration updated');
  }

  Future<void> _onScanStarted(
    FileDedupScanStarted event,
    Emitter<FileDedupState> emit,
  ) async {
    if (state.directories.isEmpty) {
      emit(state.copyWith(error: 'Please select directories to scan first'));
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
    _addLog(emit, 'Starting file scan...');

    try {
      final files = await _repository.scanFiles(
        state.directories,
        recursive: state.config.recursive,
        cancelToken: _cancelCompleter,
        onProgress: (current, total) {
          if (!isClosed) {
            emit(state.copyWith(
              scanProgress: total > 0 ? current / total : 0.0,
              currentScanningFile: 'Calculating hash: $current/$total',
            ));
          }
        },
      );

      if (_cancelCompleter?.isCompleted == true) {
        _addLog(emit, 'Scan cancelled');
        emit(state.copyWith(
          isScanning: false,
          scanProgress: 0.0,
        ));
        return;
      }

      // Find duplicate files
      final groups = _repository.findDuplicates(files);

      add(FileDedupScanComplete(files, groups));

      _addLog(emit, 'Scan complete: found ${files.length} files, ${groups.length} duplicate groups');
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(emit, 'Scan failed: $e');
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
    _addLog(emit, 'Cancelling scan...');
  }

  void _onScanComplete(
    FileDedupScanComplete event,
    Emitter<FileDedupState> emit,
  ) {
    // Calculate total size of all selected files
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

    // Update selected files set
    final newSelectedFiles = <String>{};
    for (final group in updatedGroups) {
      newSelectedFiles.addAll(group.selectedFiles);
    }

    // Recalculate statistics
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
      emit(state.copyWith(error: 'Please select files to delete first'));
      return;
    }
    // This event only triggers the confirmation dialog, actual deletion is in DeleteConfirmed
  }

  Future<void> _onDeleteConfirmed(
    FileDedupDeleteConfirmed event,
    Emitter<FileDedupState> emit,
  ) async {
    if (state.selectedFiles.isEmpty) {
      emit(state.copyWith(error: 'No files selected'));
      return;
    }

    emit(state.copyWith(
      isDeleting: true,
      clearError: true,
    ));
    _addLog(emit, 'Starting deletion of ${state.selectedFiles.length} files...');

    try {
      final pathsToDelete = state.selectedFiles.toList();
      final (success, failed) = await _repository.deleteFiles(pathsToDelete);

      // Remove deleted file groups
      final updatedGroups = state.duplicateGroups.map((group) {
        final remainingFiles = group.files
            .where((f) => !success.contains(f.path))
            .toList();

        if (remainingFiles.length <= 1) {
          // If the group has 0 or 1 files remaining, remove the group
          return null;
        }

        // Update selection state
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

      // Recalculate statistics
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

      _addLog(emit, 'Deletion complete: success ${success.length}, failed ${failed.length}');

      emit(state.copyWith(
        duplicateGroups: updatedGroups,
        selectedFiles: newSelectedFiles,
        statistics: statistics,
        isDeleting: false,
        deleteResult: (success, failed),
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(emit, 'Deletion failed: $e');
      emit(state.copyWith(
        isDeleting: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  /// Format file size
  // ignore: unused_element
  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
