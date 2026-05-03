/// 安装统计模型
///
/// 表示批量安装操作的统计信息。
library;

import 'package:equatable/equatable.dart';

/// 安装统计数据
class InstallStatistics extends Equatable {
  /// 总文件数
  final int totalFiles;

  /// 成功数
  final int successCount;

  /// 失败数
  final int failedCount;

  /// 跳过数
  final int skippedCount;

  /// 总耗时
  final Duration totalDuration;

  const InstallStatistics({
    this.totalFiles = 0,
    this.successCount = 0,
    this.failedCount = 0,
    this.skippedCount = 0,
    this.totalDuration = Duration.zero,
  });

  /// 完成率
  double get completionRate {
    if (totalFiles == 0) return 0.0;
    return (successCount + failedCount + skippedCount) / totalFiles;
  }

  /// 成功率
  double get successRate {
    final completed = successCount + failedCount;
    if (completed == 0) return 0.0;
    return successCount / completed;
  }

  /// 平均每个文件耗时
  Duration get averageDuration {
    final completed = successCount + failedCount;
    if (completed == 0) return Duration.zero;
    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ completed,
    );
  }

  /// 格式化的总耗时
  String get formattedTotalDuration {
    final minutes = totalDuration.inMinutes;
    final seconds = totalDuration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes分$seconds秒';
    }
    return '$seconds秒';
  }

  /// 格式化的平均耗时
  String get formattedAverageDuration {
    final seconds = averageDuration.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(1)}秒';
  }

  InstallStatistics copyWith({
    int? totalFiles,
    int? successCount,
    int? failedCount,
    int? skippedCount,
    Duration? totalDuration,
  }) {
    return InstallStatistics(
      totalFiles: totalFiles ?? this.totalFiles,
      successCount: successCount ?? this.successCount,
      failedCount: failedCount ?? this.failedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  Map<String, dynamic> toDict() {
    return {
      'totalFiles': totalFiles,
      'successCount': successCount,
      'failedCount': failedCount,
      'skippedCount': skippedCount,
      'totalDurationMs': totalDuration.inMilliseconds,
    };
  }

  factory InstallStatistics.fromDict(Map<String, dynamic> data) {
    return InstallStatistics(
      totalFiles: data['totalFiles'] as int? ?? 0,
      successCount: data['successCount'] as int? ?? 0,
      failedCount: data['failedCount'] as int? ?? 0,
      skippedCount: data['skippedCount'] as int? ?? 0,
      totalDuration: Duration(
        milliseconds: data['totalDurationMs'] as int? ?? 0,
      ),
    );
  }

  @override
  List<Object?> get props => [
        totalFiles,
        successCount,
        failedCount,
        skippedCount,
        totalDuration,
      ];
}
