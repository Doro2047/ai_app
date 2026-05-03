library;

import 'package:equatable/equatable.dart';

import '../models/models.dart';

class ClassifierLogEntry {
  final DateTime timestamp;
  final String message;
  final String level;

  const ClassifierLogEntry({
    required this.timestamp,
    required this.message,
    this.level = 'info',
  });

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  ClassifierLogEntry copyWith({String? message, String? level}) {
    return ClassifierLogEntry(
      timestamp: timestamp,
      message: message ?? this.message,
      level: level ?? this.level,
    );
  }
}

class ImageClassifierState extends Equatable {
  final ModelInfo? modelInfo;
  final List<String> images;
  final List<ClassificationResult> results;
  final ClassificationConfig config;
  final String? currentProcessingImage;
  final bool isModelLoading;
  final bool isClassifying;
  final double progress;
  final String progressText;
  final String? error;
  final List<ClassifierLogEntry> logs;
  final Map<String, dynamic> statistics;

  final String directory;
  final List<ClassificationRule> rules;
  final bool isScanning;
  final Map<String, List<String>> classifiedGroups;
  final List<String> ruleLogs;

  const ImageClassifierState({
    this.modelInfo,
    this.images = const [],
    this.results = const [],
    this.config = const ClassificationConfig(),
    this.currentProcessingImage,
    this.isModelLoading = false,
    this.isClassifying = false,
    this.progress = 0.0,
    this.progressText = '',
    this.error,
    this.logs = const [],
    this.statistics = const {},
    this.directory = '',
    this.rules = const [],
    this.isScanning = false,
    this.classifiedGroups = const {},
    this.ruleLogs = const [],
  });

  factory ImageClassifierState.initial() {
    return const ImageClassifierState();
  }

  int get processedCount => results.length;
  int get successCount => results.where((r) => r.status == 'success').length;
  int get errorCount => results.where((r) => r.status == 'error').length;

  @override
  List<Object?> get props => [
        modelInfo,
        images,
        results,
        config,
        currentProcessingImage,
        isModelLoading,
        isClassifying,
        progress,
        progressText,
        error,
        logs,
        statistics,
        directory,
        rules,
        isScanning,
        classifiedGroups,
        ruleLogs,
      ];

  ImageClassifierState copyWith({
    ModelInfo? modelInfo,
    List<String>? images,
    List<ClassificationResult>? results,
    ClassificationConfig? config,
    String? currentProcessingImage,
    bool? isModelLoading,
    bool? isClassifying,
    double? progress,
    String? progressText,
    String? error,
    List<ClassifierLogEntry>? logs,
    Map<String, dynamic>? statistics,
    bool clearError = false,
    String? directory,
    List<ClassificationRule>? rules,
    bool? isScanning,
    Map<String, List<String>>? classifiedGroups,
    List<String>? ruleLogs,
  }) {
    return ImageClassifierState(
      modelInfo: modelInfo ?? this.modelInfo,
      images: images ?? this.images,
      results: results ?? this.results,
      config: config ?? this.config,
      currentProcessingImage:
          currentProcessingImage ?? this.currentProcessingImage,
      isModelLoading: isModelLoading ?? this.isModelLoading,
      isClassifying: isClassifying ?? this.isClassifying,
      progress: progress ?? this.progress,
      progressText: progressText ?? this.progressText,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
      statistics: statistics ?? this.statistics,
      directory: directory ?? this.directory,
      rules: rules ?? this.rules,
      isScanning: isScanning ?? this.isScanning,
      classifiedGroups: classifiedGroups ?? this.classifiedGroups,
      ruleLogs: ruleLogs ?? this.ruleLogs,
    );
  }

  ImageClassifierState addLog(String message, {String level = 'info'}) {
    final newLogs = List<ClassifierLogEntry>.from(logs)
      ..add(ClassifierLogEntry(
        timestamp: DateTime.now(),
        message: message,
        level: level,
      ));

    if (newLogs.length > 500) {
      newLogs.removeRange(0, newLogs.length - 500);
    }

    return copyWith(logs: newLogs);
  }

  ImageClassifierState addRuleLog(String message) {
    final newLogs = List<String>.from(ruleLogs)..add(message);
    if (newLogs.length > 500) {
      newLogs.removeRange(0, newLogs.length - 500);
    }
    return copyWith(ruleLogs: newLogs);
  }
}
