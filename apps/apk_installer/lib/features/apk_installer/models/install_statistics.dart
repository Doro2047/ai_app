library;

import 'package:equatable/equatable.dart';

class InstallStatistics extends Equatable {
  final int totalFiles;
  final int successCount;
  final int failedCount;
  final int skippedCount;
  final Duration totalDuration;

  const InstallStatistics({
    this.totalFiles = 0,
    this.successCount = 0,
    this.failedCount = 0,
    this.skippedCount = 0,
    this.totalDuration = Duration.zero,
  });

  double get completionRate {
    if (totalFiles == 0) return 0.0;
    return (successCount + failedCount + skippedCount) / totalFiles;
  }

  double get successRate {
    final completed = successCount + failedCount;
    if (completed == 0) return 0.0;
    return successCount / completed;
  }

  Duration get averageDuration {
    final completed = successCount + failedCount;
    if (completed == 0) return Duration.zero;
    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ completed,
    );
  }

  String get formattedTotalDuration {
    final minutes = totalDuration.inMinutes;
    final seconds = totalDuration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String get formattedAverageDuration {
    final seconds = averageDuration.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(1)}s';
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
