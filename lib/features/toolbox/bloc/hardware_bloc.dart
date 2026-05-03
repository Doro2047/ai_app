/// 硬件信息 BLoC
///
/// 管理硬件信息状态：获取硬件信息、实时监控等。
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/bloc/feature_bloc_base.dart';
import '../models/hardware_info.dart';
import '../repositories/hardware_repository.dart';

// ============================================================
// 事件定义
// ============================================================

@immutable
abstract class HardwareEvent {
  const HardwareEvent();
}

/// 请求硬件信息
class HardwareInfoRequested extends HardwareEvent {
  const HardwareInfoRequested();
}

/// 刷新实时状态
class RealtimeStatsRefreshed extends HardwareEvent {
  const RealtimeStatsRefreshed();
}

/// 切换实时监控
class RealtimeMonitoringToggled extends HardwareEvent {
  const RealtimeMonitoringToggled();
}

// ============================================================
// 状态定义
// ============================================================

@immutable
class HardwareState {
  /// 硬件信息
  final HardwareInfo hardwareInfo;

  /// 实时状态
  final RealtimeStats realtimeStats;

  /// 是否正在监控
  final bool isMonitoring;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  const HardwareState({
    this.hardwareInfo = const HardwareInfo(),
    this.realtimeStats = const RealtimeStats(),
    this.isMonitoring = false,
    this.isLoading = false,
    this.error,
  });

  HardwareState copyWith({
    HardwareInfo? hardwareInfo,
    RealtimeStats? realtimeStats,
    bool? isMonitoring,
    bool? isLoading,
    String? error,
  }) {
    return HardwareState(
      hardwareInfo: hardwareInfo ?? this.hardwareInfo,
      realtimeStats: realtimeStats ?? this.realtimeStats,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HardwareState &&
        other.hardwareInfo == hardwareInfo &&
        other.realtimeStats == realtimeStats &&
        other.isMonitoring == isMonitoring &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        hardwareInfo,
        realtimeStats,
        isMonitoring,
        isLoading,
        error,
      );
}

// ============================================================
// BLoC 定义
// ============================================================

class HardwareBloc extends FeatureBlocBase<HardwareEvent, HardwareState> {
  final HardwareRepository _repository;
  StreamSubscription<RealtimeStats>? _monitorSubscription;

  HardwareBloc({required HardwareRepository repository})
      : _repository = repository,
        super(const HardwareState()) {
    on<HardwareInfoRequested>(_onHardwareInfoRequested);
    on<RealtimeStatsRefreshed>(_onRealtimeStatsRefreshed);
    on<RealtimeMonitoringToggled>(_onRealtimeMonitoringToggled);
  }

  Future<void> _onHardwareInfoRequested(
    HardwareInfoRequested event,
    Emitter<HardwareState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final info = await _repository.getHardwareInfo();
      emit(state.copyWith(
        hardwareInfo: info,
        realtimeStats: info.realtimeStats,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRealtimeStatsRefreshed(
    RealtimeStatsRefreshed event,
    Emitter<HardwareState> emit,
  ) async {
    try {
      final stats = await _repository.getRealtimeStats();
      emit(state.copyWith(realtimeStats: stats));
    } catch (e) {
      debugPrint('刷新实时状态失败: $e');
    }
  }

  Future<void> _onRealtimeMonitoringToggled(
    RealtimeMonitoringToggled event,
    Emitter<HardwareState> emit,
  ) async {
    if (state.isMonitoring) {
      // 停止监控
      await _monitorSubscription?.cancel();
      _monitorSubscription = null;
      emit(state.copyWith(isMonitoring: false));
    } else {
      // 开始监控
      emit(state.copyWith(isMonitoring: true));
      _monitorSubscription = _repository.startMonitoring().listen(
        (stats) {
          if (!isClosed) {
            add(const RealtimeStatsRefreshed());
          }
        },
        onError: (error) {
          debugPrint('监控错误: $error');
        },
      );
    }
  }

  @override
  Future<void> close() async {
    await _monitorSubscription?.cancel();
    _repository.stopMonitoring();
    return super.close();
  }
}
