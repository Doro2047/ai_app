/// 文件移动器 BLoC
///
/// 管理批量文件移动工具的状态和事件。
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/bloc/feature_bloc_base.dart';
import '../../file_scanner/models/file_scan_result.dart';
import '../models/move_preview.dart';
import '../models/move_rule.dart';
import '../repositories/file_mover_repository.dart';

// ============================================================
// Events
// ============================================================

/// 文件移动器事件基类
abstract class FileMoverEvent extends Equatable {
  const FileMoverEvent();

  @override
  List<Object?> get props => [];
}

/// 选择源目录
class SourceDirectorySelected extends FileMoverEvent {
  final String directory;

  const SourceDirectorySelected(this.directory);

  @override
  List<Object?> get props => [directory];
}

/// 选择目标目录
class TargetDirectorySelected extends FileMoverEvent {
  final String directory;

  const TargetDirectorySelected(this.directory);

  @override
  List<Object?> get props => [directory];
}

/// 规则变更
class RulesChanged extends FileMoverEvent {
  final List<MoveRule> rules;

  const RulesChanged(this.rules);

  @override
  List<Object?> get props => [rules];
}

/// 添加规则
class RuleAdded extends FileMoverEvent {
  final MoveRule rule;

  const RuleAdded(this.rule);

  @override
  List<Object?> get props => [rule];
}

/// 删除规则
class RuleRemoved extends FileMoverEvent {
  final int index;

  const RuleRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

/// 请求预览
class PreviewRequested extends FileMoverEvent {
  const PreviewRequested();
}

/// 请求执行
class ExecuteRequested extends FileMoverEvent {
  const ExecuteRequested();
}

/// 取消操作
class CancelRequested extends FileMoverEvent {
  const CancelRequested();
}

/// 请求扫描
class ScanRequested extends FileMoverEvent {
  const ScanRequested();
}

// ============================================================
// States
// ============================================================

/// 文件移动器状态
class FileMoverState extends Equatable {
  /// 源目录
  final String sourceDirectory;

  /// 目标目录
  final String targetDirectory;

  /// 扫描到的文件列表
  final List<FileScanResult> files;

  /// 移动规则列表
  final List<MoveRule> rules;

  /// 预览结果列表
  final List<MovePreview> previews;

  /// 是否正在扫描
  final bool isScanning;

  /// 是否正在执行
  final bool isExecuting;

  /// 进度 (0.0 - 1.0)
  final double progress;

  /// 错误信息
  final String? error;

  /// 日志消息列表
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

  /// 是否有预览结果
  bool get hasPreviews => previews.isNotEmpty;

  /// 是否有文件
  bool get hasFiles => files.isNotEmpty;

  /// 是否有规则
  bool get hasRules => rules.isNotEmpty;

  /// 是否已选择源目录
  bool get hasSourceDirectory => sourceDirectory.isNotEmpty;

  /// 成功数量
  int get successCount => previews.where((p) => p.status == MoveStatus.success).length;

  /// 失败数量
  int get failedCount => previews.where((p) => p.status == MoveStatus.failed).length;

  /// 待处理数量
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

/// 文件移动器 BLoC
class FileMoverBloc extends FeatureBlocBase<FileMoverEvent, FileMoverState> {
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
    _addLog(state, emit, '已选择源目录: ${event.directory}');
  }

  void _onTargetDirectorySelected(
    TargetDirectorySelected event,
    Emitter<FileMoverState> emit,
  ) {
    emit(state.copyWith(
      targetDirectory: event.directory,
      clearError: true,
    ));
    _addLog(state, emit, '已选择目标目录: ${event.directory}');
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
    _addLog(state, emit, '添加规则: ${event.rule.matchType.displayName} "${event.rule.matchPattern}" -> ${event.rule.targetDirectory}');
  }

  void _onRuleRemoved(
    RuleRemoved event,
    Emitter<FileMoverState> emit,
  ) {
    if (event.index >= 0 && event.index < state.rules.length) {
      final removedRule = state.rules[event.index];
      final newRules = List<MoveRule>.from(state.rules)..removeAt(event.index);
      emit(state.copyWith(rules: newRules));
      _addLog(state, emit, '删除规则: ${removedRule.matchType.displayName} "${removedRule.matchPattern}"');
    }
  }

  Future<void> _onPreviewRequested(
    PreviewRequested event,
    Emitter<FileMoverState> emit,
  ) async {
    if (state.files.isEmpty) {
      emit(state.copyWith(error: '请先扫描目录获取文件列表'));
      return;
    }

    if (!state.hasRules && state.targetDirectory.isEmpty) {
      emit(state.copyWith(error: '请至少添加一个移动规则或选择目标目录'));
      return;
    }

    emit(state.copyWith(isScanning: true, clearError: true));
    _addLog(state, emit, '正在生成预览...');

    try {
      final previews = _repository.applyRules(
        state.files,
        state.rules,
        targetDirectory: state.targetDirectory,
      );

      final movedCount = previews.where((p) => p.hasChange).length;
      _addLog(state, emit, '预览完成: $movedCount/${previews.length} 个文件将被移动');

      emit(state.copyWith(
        previews: previews,
        isScanning: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isScanning: false,
        error: '预览失败: $e',
      ));
    }
  }

  Future<void> _onExecuteRequested(
    ExecuteRequested event,
    Emitter<FileMoverState> emit,
  ) async {
    if (state.previews.isEmpty) {
      emit(state.copyWith(error: '请先生成预览'));
      return;
    }

    final hasChanges = state.previews.any((p) => p.hasChange);
    if (!hasChanges) {
      emit(state.copyWith(error: '没有需要移动的文件'));
      return;
    }

    emit(state.copyWith(isExecuting: true, progress: 0.0, clearError: true));
    _addLog(state, emit, '开始执行批量文件移动...');

    try {
      final (successList, failedList) = await _repository.executeMove(
        state.previews,
        onProgress: (current, total) {
          emit(state.copyWith(
            progress: total > 0 ? current / total : 0.0,
          ));
        },
      );

      _addLog(state, emit, '文件移动完成: 成功 ${successList.length}, 失败 ${failedList.length}');

      // 更新预览列表中的状态
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
      _addLog(state, emit, '执行失败: $e');
      emit(state.copyWith(
        isExecuting: false,
        error: '执行失败: $e',
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
    _addLog(state, emit, '操作已取消');
  }

  Future<void> _onScanRequested(
    ScanRequested event,
    Emitter<FileMoverState> emit,
  ) async {
    if (state.sourceDirectory.isEmpty) {
      emit(state.copyWith(error: '请先选择源目录'));
      return;
    }

    emit(state.copyWith(isScanning: true, clearError: true));
    _addLog(state, emit, '正在扫描目录: ${state.sourceDirectory}');

    try {
      final files = await _repository.scanFiles(
        state.sourceDirectory,
        recursive: true,
      );
      _addLog(state, emit, '扫描完成: 发现 ${files.length} 个文件');

      emit(state.copyWith(
        files: files,
        isScanning: false,
        previews: [],
      ));
    } catch (e) {
      _addLog(state, emit, '扫描失败: $e');
      emit(state.copyWith(
        isScanning: false,
        error: '扫描失败: $e',
      ));
    }
  }
}
