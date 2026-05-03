library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/file_scan_result.dart';
import '../repositories/file_scanner_repository.dart';

// ============================================================
// Events
// ============================================================

abstract class FileScannerEvent {
  const FileScannerEvent();
}

class DirectorySelected extends FileScannerEvent {
  final List<String> directories;

  const DirectorySelected(this.directories);
}

class ScanStarted extends FileScannerEvent {
  const ScanStarted();
}

class ScanCancelled extends FileScannerEvent {
  const ScanCancelled();
}

class ScanCompleted extends FileScannerEvent {
  final List<FileScanResult> results;

  const ScanCompleted(this.results);
}

class FilterChanged extends FileScannerEvent {
  final String? fileType;
  final int? minSizeKB;
  final int? maxSizeKB;
  final String? extensionFilter;

  const FilterChanged({
    this.fileType,
    this.minSizeKB,
    this.maxSizeKB,
    this.extensionFilter,
  });
}

class ExportRequested extends FileScannerEvent {
  final String outputPath;

  const ExportRequested(this.outputPath);
}

class FilenameSearched extends FileScannerEvent {
  final String keyword;

  const FilenameSearched(this.keyword);
}

// ============================================================
// State
// ============================================================

@immutable
class FileScannerState {
  final List<String> directories;
  final bool isScanning;
  final double scanProgress;
  final List<FileScanResult> results;
  final List<FileScanResult> filteredResults;
  final ScanStatistics statistics;
  final String? error;
  final List<String> logs;
  final String? filterFileType;
  final int? filterMinSizeKB;
  final int? filterMaxSizeKB;
  final String? filterExtension;
  final bool isExporting;
  final String? exportPath;
  final String? searchKeyword;

  const FileScannerState({
    this.directories = const [],
    this.isScanning = false,
    this.scanProgress = 0.0,
    this.results = const [],
    this.filteredResults = const [],
    this.statistics = const ScanStatistics(),
    this.error,
    this.logs = const [],
    this.filterFileType,
    this.filterMinSizeKB,
    this.filterMaxSizeKB,
    this.filterExtension,
    this.isExporting = false,
    this.exportPath,
    this.searchKeyword,
  });

  bool get isScanComplete => results.isNotEmpty && !isScanning;

  FileScannerState copyWith({
    List<String>? directories,
    bool? isScanning,
    double? scanProgress,
    List<FileScanResult>? results,
    List<FileScanResult>? filteredResults,
    ScanStatistics? statistics,
    String? error,
    List<String>? logs,
    String? filterFileType,
    int? filterMinSizeKB,
    int? filterMaxSizeKB,
    String? filterExtension,
    bool? isExporting,
    String? exportPath,
    String? searchKeyword,
    bool clearError = false,
    bool clearFilterFileType = false,
    bool clearFilterMinSize = false,
    bool clearFilterMaxSize = false,
    bool clearFilterExtension = false,
    bool clearSearchKeyword = false,
  }) {
    return FileScannerState(
      directories: directories ?? this.directories,
      isScanning: isScanning ?? this.isScanning,
      scanProgress: scanProgress ?? this.scanProgress,
      results: results ?? this.results,
      filteredResults: filteredResults ?? this.filteredResults,
      statistics: statistics ?? this.statistics,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
      filterFileType: clearFilterFileType ? null : (filterFileType ?? this.filterFileType),
      filterMinSizeKB: clearFilterMinSize ? null : (filterMinSizeKB ?? this.filterMinSizeKB),
      filterMaxSizeKB: clearFilterMaxSize ? null : (filterMaxSizeKB ?? this.filterMaxSizeKB),
      filterExtension: clearFilterExtension ? null : (filterExtension ?? this.filterExtension),
      isExporting: isExporting ?? this.isExporting,
      exportPath: exportPath ?? this.exportPath,
      searchKeyword: clearSearchKeyword ? null : (searchKeyword ?? this.searchKeyword),
    );
  }
}

// ============================================================
// BLoC
// ============================================================

class FileScannerBloc extends Bloc<FileScannerEvent, FileScannerState> {
  final FileScannerRepository _repository;
  Completer<void>? _cancelCompleter;

  FileScannerBloc({FileScannerRepository? repository})
      : _repository = repository ?? FileScannerRepository(),
        super(const FileScannerState()) {
    on<DirectorySelected>(_onDirectorySelected);
    on<ScanStarted>(_onScanStarted);
    on<ScanCancelled>(_onScanCancelled);
    on<ScanCompleted>(_onScanCompleted);
    on<FilterChanged>(_onFilterChanged);
    on<ExportRequested>(_onExportRequested);
    on<FilenameSearched>(_onFilenameSearched);
  }

  void _addLog(Emitter<FileScannerState> emit, String message) {
    final newLogs = List<String>.from(state.logs)..add(message);
    emit(state.copyWith(logs: newLogs));
  }

  void _onDirectorySelected(
    DirectorySelected event,
    Emitter<FileScannerState> emit,
  ) {
    emit(state.copyWith(
      directories: event.directories,
      results: [],
      filteredResults: [],
      statistics: const ScanStatistics(),
      isScanning: false,
      scanProgress: 0.0,
      clearError: true,
      clearFilterFileType: true,
      clearFilterMinSize: true,
      clearFilterMaxSize: true,
      clearFilterExtension: true,
    ));
    _addLog(emit, 'Selected ${event.directories.length} directories');
  }

  Future<void> _onScanStarted(
    ScanStarted event,
    Emitter<FileScannerState> emit,
  ) async {
    if (state.directories.isEmpty) {
      emit(state.copyWith(error: 'Please select directories to scan'));
      return;
    }

    _cancelCompleter = Completer<void>();

    final config = ScanConfig(
      directories: state.directories,
      recursive: true,
      includeHidden: false,
    );

    emit(state.copyWith(
      isScanning: true,
      scanProgress: 0.0,
      results: [],
      filteredResults: [],
      statistics: const ScanStatistics(),
      clearError: true,
      clearFilterFileType: true,
      clearFilterMinSize: true,
      clearFilterMaxSize: true,
      clearFilterExtension: true,
    ));
    _addLog(emit, 'Starting file scan...');

    try {
      final results = await _repository.scanDirectoryWithIsolate(
        config,
        onProgress: (current, total) {
          if (!isClosed) {
            emit(state.copyWith(
              scanProgress: total > 0 ? current / total : 0.0,
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

      add(ScanCompleted(results));
    } catch (e) {
      _addLog(emit, 'Scan failed: $e');
      emit(state.copyWith(
        isScanning: false,
        error: 'Scan failed: $e',
      ));
    }
  }

  void _onScanCancelled(
    ScanCancelled event,
    Emitter<FileScannerState> emit,
  ) {
    _cancelCompleter?.complete();
    _addLog(emit, 'Cancelling scan...');
  }

  void _onScanCompleted(
    ScanCompleted event,
    Emitter<FileScannerState> emit,
  ) {
    final stats = _repository.calculateStatistics(event.results);

    _addLog(emit, 'Scan complete: ${event.results.length} files found, total size ${stats.totalSizeFormatted}');

    emit(state.copyWith(
      isScanning: false,
      scanProgress: 1.0,
      results: event.results,
      filteredResults: event.results,
      statistics: stats,
    ));
  }

  void _onFilterChanged(
    FilterChanged event,
    Emitter<FileScannerState> emit,
  ) {
    if (state.results.isEmpty) return;

    final filtered = _repository.filterResults(
      state.results,
      fileType: event.fileType ?? state.filterFileType,
      minSizeKB: event.minSizeKB ?? state.filterMinSizeKB,
      maxSizeKB: event.maxSizeKB ?? state.filterMaxSizeKB,
      extensionFilter: event.extensionFilter ?? state.filterExtension,
    );

    final stats = _repository.calculateStatistics(filtered);

    emit(state.copyWith(
      filteredResults: filtered,
      statistics: stats,
      filterFileType: event.fileType,
      filterMinSizeKB: event.minSizeKB,
      filterMaxSizeKB: event.maxSizeKB,
      filterExtension: event.extensionFilter,
    ));
  }

  Future<void> _onExportRequested(
    ExportRequested event,
    Emitter<FileScannerState> emit,
  ) async {
    if (state.filteredResults.isEmpty) {
      emit(state.copyWith(error: 'No data to export'));
      return;
    }

    emit(state.copyWith(isExporting: true, clearError: true));
    _addLog(emit, 'Exporting scan results...');

    try {
      final path = await _repository.exportToCsv(
        state.filteredResults,
        event.outputPath,
      );
      _addLog(emit, 'Export successful: $path');
      emit(state.copyWith(
        isExporting: false,
        exportPath: path,
      ));
    } catch (e) {
      _addLog(emit, 'Export failed: $e');
      emit(state.copyWith(
        isExporting: false,
        error: 'Export failed: $e',
      ));
    }
  }

  void _onFilenameSearched(
    FilenameSearched event,
    Emitter<FileScannerState> emit,
  ) {
    if (state.results.isEmpty) return;

    if (event.keyword.isEmpty) {
      final filtered = _repository.filterResults(
        state.results,
        fileType: state.filterFileType,
        minSizeKB: state.filterMinSizeKB,
        maxSizeKB: state.filterMaxSizeKB,
        extensionFilter: state.filterExtension,
      );
      final stats = _repository.calculateStatistics(filtered);
      emit(state.copyWith(
        filteredResults: filtered,
        statistics: stats,
        clearSearchKeyword: true,
      ));
      return;
    }

    var baseResults = _repository.filterResults(
      state.results,
      fileType: state.filterFileType,
      minSizeKB: state.filterMinSizeKB,
      maxSizeKB: state.filterMaxSizeKB,
      extensionFilter: state.filterExtension,
    );

    final searchResults = _repository.searchByFilename(
      baseResults,
      event.keyword,
    );

    final stats = _repository.calculateStatistics(searchResults);

    emit(state.copyWith(
      filteredResults: searchResults,
      statistics: stats,
      searchKeyword: event.keyword,
    ));
  }
}
