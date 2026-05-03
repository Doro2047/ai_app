/// 扩展名修改器 BLoC
///
/// 管理批量扩展名修改工具的状态和事件。
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/error_handler.dart';
import '../../../shared/bloc/feature_bloc_base.dart';
import '../../file_scanner/models/file_scan_result.dart';
import '../models/extension_rule.dart';
import '../models/file_preview.dart';
import '../repositories/extension_changer_repository.dart';

// ============================================================
// Events
// ============================================================

/// 扩展名修改器事件基类
abstract class ExtensionChangerEvent extends Equatable {
  const ExtensionChangerEvent();

  @override
  List<Object?> get props => [];
}

/// 选择目录
class DirectorySelected extends ExtensionChangerEvent {
  final String directory;

  const DirectorySelected(this.directory);

  @override
  List<Object?> get props => [directory];
}

/// 规则变更
class RulesChanged extends ExtensionChangerEvent {
  final List<ExtensionRule> rules;

  const RulesChanged(this.rules);

  @override
  List<Object?> get props => [rules];
}

/// 添加规则
class RuleAdded extends ExtensionChangerEvent {
  final ExtensionRule rule;

  const RuleAdded(this.rule);

  @override
  List<Object?> get props => [rule];
}

/// 删除规则
class RuleRemoved extends ExtensionChangerEvent {
  final int index;

  const RuleRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

/// 请求预览
class PreviewRequested extends ExtensionChangerEvent {
  const PreviewRequested();
}

/// 请求执行
class ExecuteRequested extends ExtensionChangerEvent {
  const ExecuteRequested();
}

/// 取消操作
class CancelRequested extends ExtensionChangerEvent {
  const CancelRequested();
}

/// 请求扫描
class ScanRequested extends ExtensionChangerEvent {
  const ScanRequested();
}

// ============================================================
// States
// ============================================================

/// 扩展名修改器状态
class ExtensionChangerState extends Equatable {
  /// 当前选择的目录
  final String directory;

  /// 扫描到的文件列表
  final List<FileScanResult> files;

  /// 当前扩展名修改规则列表
  final List<ExtensionRule> rules;

  /// 预览结果列表
  final List<FilePreview> previews;

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

  /// 是否有预览结果
  bool get hasPreviews => previews.isNotEmpty;

  /// 是否有文件
  bool get hasFiles => files.isNotEmpty;

  /// 是否有规则
  bool get hasRules => rules.isNotEmpty;

  /// 成功数量
  int get successCount => previews.where((p) => p.status == ExtensionChangeStatus.success).length;

  /// 失败数量
  int get failedCount => previews.where((p) => p.status == ExtensionChangeStatus.failed).length;

  /// 待处理数量
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

/// 扩展名修改器 BLoC
class ExtensionChangerBloc extends FeatureBlocBase<ExtensionChangerEvent, ExtensionChangerState> {
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
    _addLog(state, emit, '已选择目录: ${event.directory}');
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
    _addLog(state, emit, '添加规则: ${event.rule.originalExtension} -> ${event.rule.newExtension}');
  }

  void _onRuleRemoved(
    RuleRemoved event,
    Emitter<ExtensionChangerState> emit,
  ) {
    if (event.index >= 0 && event.index < state.rules.length) {
      final removedRule = state.rules[event.index];
      final newRules = List<ExtensionRule>.from(state.rules)..removeAt(event.index);
      emit(state.copyWith(rules: newRules));
      _addLog(state, emit, '删除规则: ${removedRule.originalExtension} -> ${removedRule.newExtension}');
    }
  }

  Future<void> _onPreviewRequested(
    PreviewRequested event,
    Emitter<ExtensionChangerState> emit,
  ) async {
    if (state.files.isEmpty) {
      emit(state.copyWith(error: '请先扫描目录获取文件列表'));
      return;
    }

    if (state.rules.isEmpty) {
      emit(state.copyWith(error: '请至少添加一个扩展名修改规则'));
      return;
    }

    emit(state.copyWith(isScanning: true, clearError: true));
    _addLog(state, emit, '正在生成预览...');

    try {
      final previews = _repository.applyRules(state.files, state.rules);

      final changedCount = previews.where((p) => p.hasChange).length;
      _addLog(state, emit, '预览完成: $changedCount/${previews.length} 个文件将被修改扩展名');

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
      emit(state.copyWith(error: '请先生成预览'));
      return;
    }

    final hasChanges = state.previews.any((p) => p.hasChange);
    if (!hasChanges) {
      emit(state.copyWith(error: '没有需要修改扩展名的文件'));
      return;
    }

    emit(state.copyWith(isExecuting: true, progress: 0.0, clearError: true));
    _addLog(state, emit, '开始执行批量扩展名修改...');

    try {
      final (successList, failedList) = await _repository.executeRename(
        state.previews,
        onProgress: (current, total) {
          emit(state.copyWith(
            progress: total > 0 ? current / total : 0.0,
          ));
        },
      );

      _addLog(state, emit, '扩展名修改完成: 成功 ${successList.length}, 失败 ${failedList.length}');

      // 更新预览列表中的状态
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
      _addLog(state, emit, '执行失败: $e');
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
    _addLog(state, emit, '操作已取消');
  }

  Future<void> _onScanRequested(
    ScanRequested event,
    Emitter<ExtensionChangerState> emit,
  ) async {
    if (state.directory.isEmpty) {
      emit(state.copyWith(error: '请先选择目录'));
      return;
    }

    emit(state.copyWith(isScanning: true, clearError: true));
    _addLog(state, emit, '正在扫描目录: ${state.directory}');

    try {
      final recursive = state.rules.any((r) => r.recursive);
      final files = await _repository.scanFiles(
        state.directory,
        recursive: recursive,
      );
      _addLog(state, emit, '扫描完成: 发现 ${files.length} 个文件');

      emit(state.copyWith(
        files: files,
        isScanning: false,
        previews: [],
      ));
    } catch (e) {
      ErrorHandler.handleError(e, stackTrace: StackTrace.current);
      _addLog(state, emit, '扫描失败: $e');
      emit(state.copyWith(
        isScanning: false,
        error: ErrorHandler.getUserMessage(e),
      ));
    }
  }
}
