/// 进程 BLoC
///
/// 管理进程状态：启动、终止、状态检查。
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/bloc/feature_bloc_base.dart';

// ============================================================
// 事件定义
// ============================================================

@immutable
abstract class ProcessEvent {
  const ProcessEvent();
}

/// 启动进程
class ProcessLaunched extends ProcessEvent {
  final String programId;
  final String programName;
  final String programPath;
  const ProcessLaunched({
    required this.programId,
    required this.programName,
    required this.programPath,
  });
}

/// 终止进程
class ProcessTerminated extends ProcessEvent {
  final String programId;
  const ProcessTerminated(this.programId);
}

/// 检查进程状态
class ProcessStatusChecked extends ProcessEvent {
  const ProcessStatusChecked();
}

// ============================================================
// 状态定义
// ============================================================

/// 运行中的进程信息
class RunningProcess {
  final String programId;
  final String programName;
  final String programPath;
  final DateTime startedAt;
  final Process? process;

  const RunningProcess({
    required this.programId,
    required this.programName,
    required this.programPath,
    required this.startedAt,
    this.process,
  });
}

@immutable
class ProcessState {
  /// 运行中的进程列表
  final List<RunningProcess> runningProcesses;

  /// 最大并发进程数
  final int maxConcurrent;

  const ProcessState({
    this.runningProcesses = const [],
    this.maxConcurrent = 5,
  });

  /// 是否可以启动新进程
  bool get canLaunch => runningProcesses.length < maxConcurrent;

  /// 是否有指定程序正在运行
  bool isRunning(String programId) =>
      runningProcesses.any((p) => p.programId == programId);

  ProcessState copyWith({
    List<RunningProcess>? runningProcesses,
    int? maxConcurrent,
  }) {
    return ProcessState(
      runningProcesses: runningProcesses ?? this.runningProcesses,
      maxConcurrent: maxConcurrent ?? this.maxConcurrent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProcessState &&
        other.runningProcesses.length == runningProcesses.length &&
        other.maxConcurrent == maxConcurrent;
  }

  @override
  int get hashCode => Object.hash(runningProcesses.length, maxConcurrent);
}

// ============================================================
// BLoC 定义
// ============================================================

class ProcessBloc extends FeatureBlocBase<ProcessEvent, ProcessState> {
  ProcessBloc() : super(const ProcessState()) {
    on<ProcessLaunched>(_onProcessLaunched);
    on<ProcessTerminated>(_onProcessTerminated);
    on<ProcessStatusChecked>(_onProcessStatusChecked);
  }

  Future<void> _onProcessLaunched(
    ProcessLaunched event,
    Emitter<ProcessState> emit,
  ) async {
    if (!state.canLaunch) {
      debugPrint('已达到最大并发进程数 ${state.maxConcurrent}');
      return;
    }

    if (state.isRunning(event.programId)) {
      debugPrint('程序 ${event.programName} 已在运行中');
      return;
    }

    try {
      final process = await Process.start(event.programPath, []);
      final runningProcess = RunningProcess(
        programId: event.programId,
        programName: event.programName,
        programPath: event.programPath,
        startedAt: DateTime.now(),
        process: process,
      );

      final updatedProcesses = [...state.runningProcesses, runningProcess];
      emit(state.copyWith(runningProcesses: updatedProcesses));

      // 监听进程退出
      process.exitCode.then((exitCode) {
        if (!isClosed) {
          add(ProcessTerminated(event.programId));
        }
        debugPrint('进程 ${event.programName} 退出，退出码: $exitCode');
      });
    } catch (e) {
      debugPrint('启动进程失败: $e');
    }
  }

  Future<void> _onProcessTerminated(
    ProcessTerminated event,
    Emitter<ProcessState> emit,
  ) async {
    final processIndex = state.runningProcesses
        .indexWhere((p) => p.programId == event.programId);
    if (processIndex == -1) return;

    final process = state.runningProcesses[processIndex];
    try {
      process.process?.kill();
    } catch (e) {
      debugPrint('终止进程失败: $e');
    }

    final updatedProcesses = [...state.runningProcesses];
    updatedProcesses.removeAt(processIndex);
    emit(state.copyWith(runningProcesses: updatedProcesses));
  }

  void _onProcessStatusChecked(
    ProcessStatusChecked event,
    Emitter<ProcessState> emit,
  ) {
    // 检查并清理已退出的进程
    // dart:io Process 没有 killed 属性，通过 exitCode 检查
    // 简化处理：保留所有进程记录，由 exitCode 回调自动清理
  }

  @override
  Future<void> close() async {
    // 终止所有运行中的进程
    for (final process in state.runningProcesses) {
      try {
        process.process?.kill();
      } catch (e) {
        debugPrint('终止进程失败: $e');
      }
    }
    return super.close();
  }
}
