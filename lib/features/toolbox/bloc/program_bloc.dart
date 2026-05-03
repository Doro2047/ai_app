/// 程序 BLoC
///
/// 管理程序列表状态：加载、添加、更新、删除、启动、扫描。
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:process_run/shell_run.dart';

import '../../../shared/bloc/feature_bloc_base.dart';
import '../models/program.dart';
import '../repositories/program_repository.dart';

// ============================================================
// 事件定义
// ============================================================

@immutable
abstract class ProgramEvent {
  const ProgramEvent();
}

/// 加载程序列表
class ProgramsLoaded extends ProgramEvent {
  const ProgramsLoaded();
}

/// 添加程序
class ProgramAdded extends ProgramEvent {
  final ProgramInfo program;
  const ProgramAdded(this.program);
}

/// 更新程序
class ProgramUpdated extends ProgramEvent {
  final ProgramInfo program;
  const ProgramUpdated(this.program);
}

/// 删除程序
class ProgramDeleted extends ProgramEvent {
  final String programId;
  const ProgramDeleted(this.programId);
}

/// 启动程序
class ProgramLaunched extends ProgramEvent {
  final String programId;
  const ProgramLaunched(this.programId);
}

/// 扫描目录
class ProgramsScanned extends ProgramEvent {
  final String directory;
  const ProgramsScanned(this.directory);
}

// ============================================================
// 状态定义
// ============================================================

@immutable
class ProgramState {
  /// 所有程序列表
  final List<ProgramInfo> programs;

  /// 过滤后的程序列表
  final List<ProgramInfo> filteredPrograms;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  /// 正在运行的程序 ID 集合
  final Set<String> runningProgramIds;

  const ProgramState({
    this.programs = const [],
    this.filteredPrograms = const [],
    this.isLoading = false,
    this.error,
    this.runningProgramIds = const {},
  });

  ProgramState copyWith({
    List<ProgramInfo>? programs,
    List<ProgramInfo>? filteredPrograms,
    bool? isLoading,
    String? error,
    Set<String>? runningProgramIds,
  }) {
    return ProgramState(
      programs: programs ?? this.programs,
      filteredPrograms: filteredPrograms ?? this.filteredPrograms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      runningProgramIds: runningProgramIds ?? this.runningProgramIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgramState &&
        _listEquals(other.programs, programs) &&
        _listEquals(other.filteredPrograms, filteredPrograms) &&
        other.isLoading == isLoading &&
        other.error == error &&
        _setEquals(other.runningProgramIds, runningProgramIds);
  }

  @override
  int get hashCode => Object.hash(
        programs.length,
        filteredPrograms.length,
        isLoading,
        error,
        runningProgramIds.length,
      );

  static bool _listEquals(List<ProgramInfo> a, List<ProgramInfo> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}

// ============================================================
// BLoC 定义
// ============================================================

class ProgramBloc extends FeatureBlocBase<ProgramEvent, ProgramState> {
  final ProgramRepository _repository;

  ProgramBloc({required ProgramRepository repository})
      : _repository = repository,
        super(const ProgramState()) {
    on<ProgramsLoaded>(_onProgramsLoaded);
    on<ProgramAdded>(_onProgramAdded);
    on<ProgramUpdated>(_onProgramUpdated);
    on<ProgramDeleted>(_onProgramDeleted);
    on<ProgramLaunched>(_onProgramLaunched);
    on<ProgramsScanned>(_onProgramsScanned);
  }

  Future<void> _onProgramsLoaded(
    ProgramsLoaded event,
    Emitter<ProgramState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final programs = _repository.getAll();
      emit(state.copyWith(
        programs: programs,
        filteredPrograms: programs,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onProgramAdded(
    ProgramAdded event,
    Emitter<ProgramState> emit,
  ) async {
    try {
      final newProgram = await _repository.add(event.program);
      final updatedPrograms = [...state.programs, newProgram];
      emit(state.copyWith(
        programs: updatedPrograms,
        filteredPrograms: updatedPrograms,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onProgramUpdated(
    ProgramUpdated event,
    Emitter<ProgramState> emit,
  ) async {
    try {
      await _repository.update(event.program);
      final updatedPrograms = state.programs
          .map((p) => p.id == event.program.id ? event.program : p)
          .toList();
      emit(state.copyWith(
        programs: updatedPrograms,
        filteredPrograms: updatedPrograms,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onProgramDeleted(
    ProgramDeleted event,
    Emitter<ProgramState> emit,
  ) async {
    try {
      await _repository.remove(event.programId);
      final updatedPrograms =
          state.programs.where((p) => p.id != event.programId).toList();
      emit(state.copyWith(
        programs: updatedPrograms,
        filteredPrograms: updatedPrograms,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onProgramLaunched(
    ProgramLaunched event,
    Emitter<ProgramState> emit,
  ) async {
    try {
      final program = _repository.get(event.programId);
      if (program == null) return;

      // 标记为运行中
      final runningIds = {...state.runningProgramIds, event.programId};
      emit(state.copyWith(runningProgramIds: runningIds));

      // 启动程序
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final shell = Shell();
        await shell.run('"${program.path}"');
      }

      // 递增使用次数
      await _repository.incrementUseCount(event.programId);

      // 更新列表中的程序信息
      final updatedProgram = _repository.get(event.programId);
      if (updatedProgram != null) {
        final updatedPrograms = state.programs
            .map((p) => p.id == event.programId ? updatedProgram : p)
            .toList();
        final runningIdsAfter = state.runningProgramIds.difference({event.programId});
        emit(state.copyWith(
          programs: updatedPrograms,
          filteredPrograms: updatedPrograms,
          runningProgramIds: runningIdsAfter,
        ));
      }
    } catch (e) {
      // 启动失败，移除运行标记
      final runningIds = state.runningProgramIds.difference({event.programId});
      emit(state.copyWith(
        runningProgramIds: runningIds,
        error: '启动程序失败: $e',
      ));
      debugPrint('启动程序失败: $e');
    }
  }

  Future<void> _onProgramsScanned(
    ProgramsScanned event,
    Emitter<ProgramState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final foundPrograms = await _repository.scanDirectory(event.directory);
      for (final program in foundPrograms) {
        await _repository.add(program);
      }
      final allPrograms = _repository.getAll();
      emit(state.copyWith(
        programs: allPrograms,
        filteredPrograms: allPrograms,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// 根据分类和搜索条件过滤程序
  List<ProgramInfo> filterPrograms(String categoryId, String searchText) {
    return _repository.getProgramsByCategory(
      categoryId,
      searchText: searchText,
    );
  }
}
