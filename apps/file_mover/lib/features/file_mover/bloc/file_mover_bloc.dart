library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../file_scanner/models/file_scan_result.dart';
import '../models/move_preview.dart';
import '../models/move_rule.dart';
import '../repositories/file_mover_repository.dart';

// ============================================================
// Events
// ============================================================

abstract class FileMoverEvent extends Equatable {
  const FileMoverEvent();

  @override
  List<Object?> get props => [];
}

class SourceDirectorySelected extends FileMoverEvent {
  final String directory;

  const SourceDirectorySelected(this.directory);

  @override
  List<Object?> get props => [directory];
}

class TargetDirectorySelected extends FileMoverEvent {
  final String directory;

  const TargetDirectorySelected(this.directory);

  @override
  List<Object?> get props => [directory];
}

class RulesChanged extends FileMoverEvent {
  final List<MoveRule> rules;

  const RulesChanged(this.rules);

  @override
  List<Object?> get props => [rules];
}

class RuleAdded extends FileMoverEvent {
  final MoveRule rule;

  const RuleAdded(this.rule);

  @override
  List<Object?> get props => [rule];
}

class RuleRemoved extends FileMoverEvent {
  final int index;

  const RuleRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class PreviewRequested extends FileMoverEvent {
  const PreviewRequested();
}

class ExecuteRequested extends FileMoverEvent {
  const ExecuteRequested();
}

class CancelRequested extends FileMoverEvent {
  const CancelRequested();
}

class ScanRequested extends FileMoverEvent {
  const ScanRequested();
}

// ============================================================
// States
// ============================================================

class FileMoverState extends Equatable {
  final String sourceDirectory;
  final String targetDirectory;
  final List<FileScanResult> files;
  final List<MoveRule> rules;
  final List<MovePreview> previews;
  final bool isScanning;
  final bool isExecuting;
  final double progress;
  final String? error;
  final List<String> logs;

  const FileMoverState({
    this.sourceDirectory = '',
    this.targetDirectory = '',
    this.files = const [],
    this.rules = const [],
    this.previews = const [],
    this.isScanning = false,
    this.isExecuting = false,
    this.progress = 0.0,
    this.error,
    this.logs = const [],
  });

  bool get hasPreviews => previews.isNotEmpty;
  bool get hasFiles => files.isNotEmpty;
  bool get hasRules => rules.isNotEmpty;
  bool get hasSourceDirectory => sourceDirectory.isNotEmpty;

  int get successCount => previews.where((p) => p.status == MoveStatus.success).length;
  int get failedCount => previews.where((p) => p.status == MoveStatus.failed).length;
  int get pendingCount => previews.where((p) => p.status == MoveStatus.pending).length;

  FileMoverState copyWith({
    String? sourceDirectory,
    String? targetDirectory,
    List<FileScanResult>? files,
    List<MoveRule>? rules,
    List<MovePreview>? previews,
    bool? isScanning,
    bool? isExecuting,
    double? progress,
    String? error,
    List<String>? logs,
    bool clearError = false,
  }) {
    return FileMoverState(
      sourceDirectory: sourceDirectory ?? this.sourceDirectory,
      targetDirectory: targetDirectory ?? this.targetDirectory,
      files: files ?? this.files,
      rules: rules ?? this.rules,
      previews: previews ?? this.previews,
      isScanning: isScanning ?? this.isScanning,
      isExecuting: isExecuting ?? this.isExecuting,
      progress: progress ?? this.progress,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props => [
    sourceDirectory, targetDirectory, files, rules, previews,
    isScanning, isExecuting, progress, error, logs,
  ];
}

// ============================================================
// BLoC
// ============================================================

class FileMoverBloc extends Bloc<FileMoverEvent, FileMoverState> {
  final FileMoverRepository _repository;

  FileMoverBloc({
    FileMoverRepository? repository,
  })  : _repository = repository ?? FileMoverRepository(),
        super(const FileMoverState()) {
    on<SourceDirectorySelected>(_onSourceDirectorySelected);
    on<TargetDirectorySelected>(_onTargetDirectorySelected);
    on<RulesChanged>(_onRulesChanged);
    on<RuleAdded>(_onRuleAdded);
    on<RuleRemoved>(_onRuleRemoved);
    on<PreviewRequested>(_onPreviewRequested);
    on<ExecuteRequested>(_onExecuteRequested);
    on<CancelRequested>(_onCancelRequested);
    on<ScanRequested>(_onScanRequested);
  }

  void _addLog(FileMoverState currentState, Emitter<FileMoverState> emit, String message) {
    final newLogs = List<String>.from(currentState.logs)..add(message);
    emit(currentState.copyWith(logs: newLogs));
  }

  void _onSourceDirectorySelected(
    SourceDirectorySelected event,
    Emitter<FileMoverState> emit,
  ) {
    emit(state.copyWith(
      sourceDirectory: event.directory,
      files: [],
      previews: [],
      clearError: true,
    ));
    _addLog(state, emit, 'Source directory selected: ${event.directory}');
  }

  void _onTargetDirectorySelected(
    TargetDirectorySelected event,
    Emitter<FileMoverState> emit,
  ) {
    emit(state.copyWith(
      targetDirectory: event.directory,
      clearError: true,
    ));
    _addLog(state, emit, 'Target directory selected: ${event.directory}');
  }

  void _onRulesChanged(
    RulesChanged event,
    Emitter<FileMoverState> emit,
  ) {
    emit(state.copyWith(rules: event.rules));
  }

  void _onRuleAdded(
    RuleAdded event,
    Emitter<FileMoverState> emit,
  ) {
    final newRules = List<MoveRule>.from(state.rules)..add(event.rule);
    emit(state.copyWith(rules: newRules));
    _addLog(state, emit, 'Rule added: ${event.rule.matchType.displayName} "${event.rule.matchPattern}" -> ${event.rule.targetDirectory}');
  }

  void _onRuleRemoved(
    RuleRemoved event,
    Emitter<FileMoverState> emit,
  ) {
    if (event.index >= 0 && event.index < state.rules.length) {
      final removedRule = state.rules[event.index];
      final newRules = List<MoveRule>.from(state.rules)..removeAt(event.index);
      emit(state.copyWith(rules: newRules));
      _addLog(state, emit, 'Rule removed: ${removedRule.matchType.displayName} "${removedRule.matchPattern}"');
    }
  }

  Future<void> _onPreviewRequested(
    PreviewRequested event,
    Emitter<FileMoverState> emit,
  ) async {
    if (state.files.isEmpty) {
      emit(state.copyWith(error: 'Please scan directory first'));
      return;
    }

    if (!state.hasRules && state.targetDirectory.isEmpty) {
      emit(state.copyWith(error: 'Please add at least one rule or select target directory'));
      return;
    }

    emit(state.copyWith(isScanning: true, clearError: true));
    _addLog(state, emit, 'Generating preview...');

    try {
      final previews = _repository.applyRules(
        state.files,
        state.rules,
        targetDirectory: state.targetDirectory,
      );

      final movedCount = previews.where((p) => p.hasChange).length;
      _addLog(state, emit, 'Preview complete: $movedCount/${previews.length} files will be moved');

      emit(state.copyWith(
        previews: previews,
        isScanning: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isScanning: false,
        error: 'Preview failed: $e',
      ));
    }
  }

  Future<void> _onExecuteRequested(
    ExecuteRequested event,
    Emitter<FileMoverState> emit,
  ) async {
    if (state.previews.isEmpty) {
      emit(state.copyWith(error: 'Please generate preview first'));
      return;
    }

    final hasChanges = state.previews.any((p) => p.hasChange);
    if (!hasChanges) {
      emit(state.copyWith(error: 'No files to move'));
      return;
    }

    emit(state.copyWith(isExecuting: true, progress: 0.0, clearError: true));
    _addLog(state, emit, 'Starting batch file move...');

    try {
      final (successList, failedList) = await _repository.executeMove(
        state.previews,
        onProgress: (current, total) {
          emit(state.copyWith(
            progress: total > 0 ? current / total : 0.0,
          ));
        },
      );

      _addLog(state, emit, 'File move complete: ${successList.length} succeeded, ${failedList.length} failed');

      final updatedPreviews = <MovePreview>[];
      for (final preview in state.previews) {
        final successItem = successList.where((s) => s.originalPath == preview.originalPath).firstOrNull;
        final failedItem = failedList.where((f) => f.originalPath == preview.originalPath).firstOrNull;

        if (successItem != null) {
          updatedPreviews.add(preview.copyWith(status: MoveStatus.success));
        } else if (failedItem != null) {
          updatedPreviews.add(preview.copyWith(
            status: MoveStatus.failed,
            error: failedItem.error,
          ));
        } else {
          updatedPreviews.add(preview);
        }
      }

      emit(state.copyWith(
        previews: updatedPreviews,
        isExecuting: false,
        progress: 1.0,
      ));
    } catch (e) {
      _addLog(state, emit, 'Execution failed: $e');
      emit(state.copyWith(
        isExecuting: false,
        error: 'Execution failed: $e',
      ));
    }
  }

  void _onCancelRequested(
    CancelRequested event,
    Emitter<FileMoverState> emit,
  ) {
    emit(state.copyWith(
      isScanning: false,
      isExecuting: false,
      progress: 0.0,
    ));
    _addLog(state, emit, 'Operation cancelled');
  }

  Future<void> _onScanRequested(
    ScanRequested event,
    Emitter<FileMoverState> emit,
  ) async {
    if (state.sourceDirectory.isEmpty) {
      emit(state.copyWith(error: 'Please select source directory first'));
      return;
    }

    emit(state.copyWith(isScanning: true, clearError: true));
    _addLog(state, emit, 'Scanning directory: ${state.sourceDirectory}');

    try {
      final files = await _repository.scanFiles(
        state.sourceDirectory,
        recursive: true,
      );
      _addLog(state, emit, 'Scan complete: ${files.length} files found');

      emit(state.copyWith(
        files: files,
        isScanning: false,
        previews: [],
      ));
    } catch (e) {
      _addLog(state, emit, 'Scan failed: $e');
      emit(state.copyWith(
        isScanning: false,
        error: 'Scan failed: $e',
      ));
    }
  }
}
