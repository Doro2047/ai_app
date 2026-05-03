library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:shared_core/shared_core.dart';

import '../models/extension_rule.dart';
import '../models/file_preview.dart';
import '../models/file_scan_result.dart';
import '../repositories/extension_changer_repository.dart';

// ============================================================
// Events
// ============================================================

abstract class ExtensionChangerEvent extends Equatable {
  const ExtensionChangerEvent();

  @override
  List<Object?> get props => [];
}

class DirectorySelected extends ExtensionChangerEvent {
  final String directory;

  const DirectorySelected(this.directory);

  @override
  List<Object?> get props => [directory];
}

class RulesChanged extends ExtensionChangerEvent {
  final List<ExtensionRule> rules;

  const RulesChanged(this.rules);

  @override
  List<Object?> get props => [rules];
}

class RuleAdded extends ExtensionChangerEvent {
  final ExtensionRule rule;

  const RuleAdded(this.rule);

  @override
  List<Object?> get props => [rule];
}

class RuleRemoved extends ExtensionChangerEvent {
  final int index;

  const RuleRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class PreviewRequested extends ExtensionChangerEvent {
  const PreviewRequested();
}

class ExecuteRequested extends ExtensionChangerEvent {
  const ExecuteRequested();
}

class CancelRequested extends ExtensionChangerEvent {
  const CancelRequested();
}

class ScanRequested extends ExtensionChangerEvent {
  const ScanRequested();
}

// ============================================================
// States
// ============================================================

class ExtensionChangerState extends Equatable {
  final String directory;
  final List<FileScanResult> files;
  final List<ExtensionRule> rules;
  final List<FilePreview> previews;
  final bool isScanning;
  final bool isExecuting;
  final double progress;
  final String? error;
  final List<String> logs;

  const ExtensionChangerState({
    this.directory = '',
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

  int get successCount => previews.where((p) => p.status == ExtensionChangeStatus.success).length;
  int get failedCount => previews.where((p) => p.status == ExtensionChangeStatus.failed).length;
  int get pendingCount => previews.where((p) => p.status == ExtensionChangeStatus.pending).length;

  ExtensionChangerState copyWith({
    String? directory,
    List<FileScanResult>? files,
    List<ExtensionRule>? rules,
    List<FilePreview>? previews,
    bool? isScanning,
    bool? isExecuting,
    double? progress,
    String? error,
    List<String>? logs,
    bool clearError = false,
  }) {
    return ExtensionChangerState(
      directory: directory ?? this.directory,
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
    directory, files, rules, previews,
    isScanning, isExecuting, progress, error, logs,
  ];
}

// ============================================================
// BLoC
// ============================================================

class ExtensionChangerBloc extends Bloc<ExtensionChangerEvent, ExtensionChangerState> {
  final ExtensionChangerRepository _repository;

  ExtensionChangerBloc({
    ExtensionChangerRepository? repository,
  })  : _repository = repository ?? ExtensionChangerRepository(),
        super(const ExtensionChangerState()) {
    on<DirectorySelected>(_onDirectorySelected);
    on<RulesChanged>(_onRulesChanged);
    on<RuleAdded>(_onRuleAdded);
    on<RuleRemoved>(_onRuleRemoved);
    on<PreviewRequested>(_onPreviewRequested);
    on<ExecuteRequested>(_onExecuteRequested);
    on<CancelRequested>(_onCancelRequested);
    on<ScanRequested>(_onScanRequested);
  }

  void _addLog(ExtensionChangerState currentState, Emitter<ExtensionChangerState> emit, String message) {
    final newLogs = List<String>.from(currentState.logs)..add(message);
    emit(currentState.copyWith(logs: newLogs));
  }

  void _onDirectorySelected(
    DirectorySelected event,
    Emitter<ExtensionChangerState> emit,
  ) {
    emit(state.copyWith(
      directory: event.directory,
      files: [],
      previews: [],
      clearError: true,
    ));
    _addLog(state, emit, 'Directory selected: ${event.directory}');
  }

  void _onRulesChanged(
    RulesChanged event,
    Emitter<ExtensionChangerState> emit,
  ) {
    emit(state.copyWith(rules: event.rules));
  }

  void _onRuleAdded(
    RuleAdded event,
    Emitter<ExtensionChangerState> emit,
  ) {
    final newRules = List<ExtensionRule>.from(state.rules)..add(event.rule);
    emit(state.copyWith(rules: newRules));
    _addLog(state, emit, 'Rule added: ${event.rule.originalExtension} -> ${event.rule.newExtension}');
  }

  void _onRuleRemoved(
    RuleRemoved event,
    Emitter<ExtensionChangerState> emit,
  ) {
    if (event.index >= 0 && event.index < state.rules.length) {
      final removedRule = state.rules[event.index];
      final newRules = List<ExtensionRule>.from(state.rules)..removeAt(event.index);
      emit(state.copyWith(rules: newRules));
      _addLog(state, emit, 'Rule removed: ${removedRule.originalExtension} -> ${removedRule.newExtension}');
    }
  }

  Future<void> _onPreviewRequested(
    PreviewRequested event,
    Emitter<ExtensionChangerState> emit,
  ) async {
    if (state.files.isEmpty) {
      emit(state.copyWith(error: 'Please scan directory first'));
      return;
    }

    if (state.rules.isEmpty) {
      emit(state.copyWith(error: 'Please add at least one extension rule'));
      return;
    }

    emit(state.copyWith(isScanning: true, clearError: true));
    _addLog(state, emit, 'Generating preview...');

    try {
      final previews = _repository.applyRules(state.files, state.rules);

      final changedCount = previews.where((p) => p.hasChange).length;
      _addLog(state, emit, 'Preview complete: $changedCount/${previews.length} files will be renamed');

      emit(state.copyWith(
        previews: previews,
        isScanning: false,
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      emit(state.copyWith(
        isScanning: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onExecuteRequested(
    ExecuteRequested event,
    Emitter<ExtensionChangerState> emit,
  ) async {
    if (state.previews.isEmpty) {
      emit(state.copyWith(error: 'Please generate preview first'));
      return;
    }

    final hasChanges = state.previews.any((p) => p.hasChange);
    if (!hasChanges) {
      emit(state.copyWith(error: 'No files need extension change'));
      return;
    }

    emit(state.copyWith(isExecuting: true, progress: 0.0, clearError: true));
    _addLog(state, emit, 'Starting batch extension rename...');

    try {
      final (successList, failedList) = await _repository.executeRename(
        state.previews,
        onProgress: (current, total) {
          emit(state.copyWith(
            progress: total > 0 ? current / total : 0.0,
          ));
        },
      );

      _addLog(state, emit, 'Rename complete: ${successList.length} succeeded, ${failedList.length} failed');

      final updatedPreviews = <FilePreview>[];
      for (final preview in state.previews) {
        final successItem = successList.where((s) => s.originalPath == preview.originalPath).firstOrNull;
        final failedItem = failedList.where((f) => f.originalPath == preview.originalPath).firstOrNull;

        if (successItem != null) {
          updatedPreviews.add(preview.copyWith(status: ExtensionChangeStatus.success));
        } else if (failedItem != null) {
          updatedPreviews.add(preview.copyWith(
            status: ExtensionChangeStatus.failed,
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
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, 'Execution failed: $e');
      emit(state.copyWith(
        isExecuting: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  void _onCancelRequested(
    CancelRequested event,
    Emitter<ExtensionChangerState> emit,
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
    Emitter<ExtensionChangerState> emit,
  ) async {
    if (state.directory.isEmpty) {
      emit(state.copyWith(error: 'Please select a directory first'));
      return;
    }

    emit(state.copyWith(isScanning: true, clearError: true));
    _addLog(state, emit, 'Scanning directory: ${state.directory}');

    try {
      final recursive = state.rules.any((r) => r.recursive);
      final files = await _repository.scanFiles(
        state.directory,
        recursive: recursive,
      );
      _addLog(state, emit, 'Scan complete: ${files.length} files found');

      emit(state.copyWith(
        files: files,
        isScanning: false,
        previews: [],
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, 'Scan failed: $e');
      emit(state.copyWith(
        isScanning: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }
}
