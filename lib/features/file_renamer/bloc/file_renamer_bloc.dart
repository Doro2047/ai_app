library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/error_handler.dart';
import '../../../shared/bloc/feature_bloc_base.dart';
import '../models/rename_rule.dart';
import '../models/rename_preview.dart';
import '../repositories/file_renamer_repository.dart';

abstract class FileRenamerEvent extends Equatable {
  const FileRenamerEvent();

  @override
  List<Object?> get props => [];
}

class DirectorySelected extends FileRenamerEvent {
  final String directory;

  const DirectorySelected(this.directory);

  @override
  List<Object?> get props => [directory];
}

class RuleAdded extends FileRenamerEvent {
  final RenameRule rule;

  const RuleAdded(this.rule);

  @override
  List<Object?> get props => [rule];
}

class RuleRemoved extends FileRenamerEvent {
  final String ruleId;

  const RuleRemoved(this.ruleId);

  @override
  List<Object?> get props => [ruleId];
}

class RuleUpdated extends FileRenamerEvent {
  final RenameRule rule;

  const RuleUpdated(this.rule);

  @override
  List<Object?> get props => [rule];
}

class PreviewRequested extends FileRenamerEvent {
  const PreviewRequested();
}

class ExecuteRequested extends FileRenamerEvent {
  const ExecuteRequested();
}

class UndoRequested extends FileRenamerEvent {
  const UndoRequested();
}

class RecursiveToggled extends FileRenamerEvent {
  final bool isRecursive;

  const RecursiveToggled(this.isRecursive);

  @override
  List<Object?> get props => [isRecursive];
}

class ScanRequested extends FileRenamerEvent {
  const ScanRequested();
}

class FileRenamerState extends Equatable {
  final String directory;
  final bool isRecursive;
  final List<RenameRule> rules;
  final List<String> files;
  final List<RenamePreview> previews;
  final bool isExecuting;
  final bool isUndoAvailable;
  final List<RenamePreview> lastRenames;
  final String? error;
  final List<String> logs;

  const FileRenamerState({
    this.directory = '',
    this.isRecursive = true,
    this.rules = const [],
    this.files = const [],
    this.previews = const [],
    this.isExecuting = false,
    this.isUndoAvailable = false,
    this.lastRenames = const [],
    this.error,
    this.logs = const [],
  });

  bool get hasPreviews => previews.isNotEmpty;
  bool get hasFiles => files.isNotEmpty;
  bool get hasRules => rules.isNotEmpty;
  int get conflictCount => previews.where((p) => p.hasConflict).length;
  int get changedCount => previews.where((p) => p.hasChange).length;
  int get errorCount => previews.where((p) => p.error != null).length;

  FileRenamerState copyWith({
    String? directory,
    bool? isRecursive,
    List<RenameRule>? rules,
    List<String>? files,
    List<RenamePreview>? previews,
    bool? isExecuting,
    bool? isUndoAvailable,
    List<RenamePreview>? lastRenames,
    String? error,
    List<String>? logs,
    bool clearError = false,
  }) {
    return FileRenamerState(
      directory: directory ?? this.directory,
      isRecursive: isRecursive ?? this.isRecursive,
      rules: rules ?? this.rules,
      files: files ?? this.files,
      previews: previews ?? this.previews,
      isExecuting: isExecuting ?? this.isExecuting,
      isUndoAvailable: isUndoAvailable ?? this.isUndoAvailable,
      lastRenames: lastRenames ?? this.lastRenames,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props => [
    directory, isRecursive, rules, files, previews,
    isExecuting, isUndoAvailable, lastRenames, error, logs,
  ];
}

class FileRenamerBloc extends FeatureBlocBase<FileRenamerEvent, FileRenamerState> {
  final FileRenamerRepository _repository;

  FileRenamerBloc({
    FileRenamerRepository? repository,
  })  : _repository = repository ?? FileRenamerRepository(),
        super(const FileRenamerState()) {
    on<DirectorySelected>(_onDirectorySelected);
    on<RuleAdded>(_onRuleAdded);
    on<RuleRemoved>(_onRuleRemoved);
    on<RuleUpdated>(_onRuleUpdated);
    on<PreviewRequested>(_onPreviewRequested);
    on<ExecuteRequested>(_onExecuteRequested);
    on<UndoRequested>(_onUndoRequested);
    on<RecursiveToggled>(_onRecursiveToggled);
    on<ScanRequested>(_onScanRequested);
  }

  void _addLog(FileRenamerState currentState, Emitter<FileRenamerState> emit, String message) {
    final newLogs = List<String>.from(currentState.logs)..add(message);
    emit(currentState.copyWith(logs: newLogs));
  }

  void _onDirectorySelected(
    DirectorySelected event,
    Emitter<FileRenamerState> emit,
  ) {
    emit(state.copyWith(
      directory: event.directory,
      files: [],
      previews: [],
      isUndoAvailable: false,
      lastRenames: [],
      clearError: true,
    ));
    _addLog(state, emit, '已选择目录: ${event.directory}');
  }

  void _onRuleAdded(
    RuleAdded event,
    Emitter<FileRenamerState> emit,
  ) {
    final newRules = List<RenameRule>.from(state.rules)..add(event.rule);
    emit(state.copyWith(rules: newRules));
    _addLog(state, emit, '添加规则: ${event.rule.type.displayName}');
  }

  void _onRuleRemoved(
    RuleRemoved event,
    Emitter<FileRenamerState> emit,
  ) {
    final newRules = state.rules.where((r) => r.id != event.ruleId).toList();
    emit(state.copyWith(rules: newRules));
    _addLog(state, emit, '删除规则');
  }

  void _onRuleUpdated(
    RuleUpdated event,
    Emitter<FileRenamerState> emit,
  ) {
    final newRules = state.rules.map((r) {
      return r.id == event.rule.id ? event.rule : r;
    }).toList();
    emit(state.copyWith(rules: newRules));
    _addLog(state, emit, '更新规则: ${event.rule.type.displayName}');
  }

  Future<void> _onPreviewRequested(
    PreviewRequested event,
    Emitter<FileRenamerState> emit,
  ) async {
    if (state.files.isEmpty) {
      emit(state.copyWith(error: '请先扫描目录获取文件列表'));
      return;
    }

    if (state.rules.isEmpty) {
      emit(state.copyWith(error: '请至少添加一条重命名规则'));
      return;
    }

    emit(state.copyWith(clearError: true));
    _addLog(state, emit, '正在生成预览...');

    try {
      final previews = _repository.generatePreview(state.files, state.rules);
      final conflictCount = previews.where((p) => p.hasConflict).length;
      final changedCount = previews.where((p) => p.hasChange).length;

      if (conflictCount > 0) {
        _addLog(state, emit, '检测到 $conflictCount 个名称冲突');
      }
      _addLog(state, emit, '预览完成: $changedCount/${previews.length} 个文件将被重命名');

      emit(state.copyWith(previews: previews));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      emit(state.copyWith(error: ErrorHandler.getUserMessage(e)));
    }
  }

  Future<void> _onExecuteRequested(
    ExecuteRequested event,
    Emitter<FileRenamerState> emit,
  ) async {
    if (state.previews.isEmpty) {
      emit(state.copyWith(error: '请先生成预览'));
      return;
    }

    final hasChanges = state.previews.any((p) => p.hasChange);
    if (!hasChanges) {
      emit(state.copyWith(error: '没有需要重命名的文件'));
      return;
    }

    emit(state.copyWith(isExecuting: true, clearError: true));
    _addLog(state, emit, '开始执行批量重命名...');

    try {
      final results = await _repository.executeRename(state.previews);
      final errorCount = results.where((p) => p.error != null).length;
      final successCount = results.where((p) => p.error == null && p.hasChange).length;

      _addLog(state, emit, '重命名完成: 成功 $successCount, 失败 $errorCount');

      emit(state.copyWith(
        previews: results,
        isExecuting: false,
        isUndoAvailable: successCount > 0,
        lastRenames: List<RenamePreview>.from(state.previews),
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '执行失败: $e');
      emit(state.copyWith(
        isExecuting: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  Future<void> _onUndoRequested(
    UndoRequested event,
    Emitter<FileRenamerState> emit,
  ) async {
    if (!state.isUndoAvailable || state.lastRenames.isEmpty) {
      emit(state.copyWith(error: '没有可撤销的操作'));
      return;
    }

    emit(state.copyWith(isExecuting: true, clearError: true));
    _addLog(state, emit, '正在撤销重命名...');

    try {
      final results = await _repository.undoRename(state.lastRenames);
      final errorCount = results.where((p) => p.error != null).length;

      _addLog(state, emit, '撤销完成: 失败 $errorCount');

      emit(state.copyWith(
        previews: [],
        isExecuting: false,
        isUndoAvailable: false,
        lastRenames: [],
        files: [],
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '撤销失败: $e');
      emit(state.copyWith(
        isExecuting: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }

  void _onRecursiveToggled(
    RecursiveToggled event,
    Emitter<FileRenamerState> emit,
  ) {
    emit(state.copyWith(isRecursive: event.isRecursive));
    _addLog(state, emit, '递归扫描: ${event.isRecursive ? "开启" : "关闭"}');
  }

  Future<void> _onScanRequested(
    ScanRequested event,
    Emitter<FileRenamerState> emit,
  ) async {
    if (state.directory.isEmpty) {
      emit(state.copyWith(error: '请先选择目录'));
      return;
    }

    emit(state.copyWith(clearError: true));
    _addLog(state, emit, '正在扫描目录: ${state.directory}');

    try {
      final files = await _repository.scanFiles(
        state.directory,
        recursive: state.isRecursive,
      );
      _addLog(state, emit, '扫描完成: 发现 ${files.length} 个文件');

      emit(state.copyWith(
        files: files,
        previews: [],
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '扫描失败: $e');
      emit(state.copyWith(error: ErrorHandler.getUserMessage(e)));
    }
  }
}
