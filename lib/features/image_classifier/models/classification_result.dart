/// 图像分类结果数据模型
///
/// 存储单张图片的分类推理结果，包含最可能的类别和概率分布。
library;

import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';

/// 图像分类结果
class ClassificationResult extends Equatable {
  /// 图片文件路径
  final String imagePath;

  /// 最可能的类别名称
  final String className;

  /// 最可能类别的置信度 (0.0 - 1.0)
  final double confidence;

  /// 所有类别的概率分布 (类别名 -> 概率)
  final Map<String, double> probabilities;

  /// 分类状态
  final String status;

  /// 错误信息（分类失败时）
  final String? error;

  const ClassificationResult({
    required this.imagePath,
    required this.className,
    required this.confidence,
    required this.probabilities,
    this.status = 'success',
    this.error,
  });

  /// 创建成功结果
  factory ClassificationResult.success({
    required String imagePath,
    required String className,
    required double confidence,
    required Map<String, double> probabilities,
  }) {
    return ClassificationResult(
      imagePath: imagePath,
      className: className,
      confidence: confidence,
      probabilities: probabilities,
      status: 'success',
    );
  }

  /// 创建失败结果
  factory ClassificationResult.failure({
    required String imagePath,
    required String error,
  }) {
    return ClassificationResult(
      imagePath: imagePath,
      className: 'Unknown',
      confidence: 0.0,
      probabilities: const {},
      status: 'error',
      error: error,
    );
  }

  /// 获取文件名
  String get fileName => File(imagePath).path.split(Platform.pathSeparator).last;

  /// 转换为字典（用于导出）
  Map<String, dynamic> toDict() {
    return {
      'image_path': imagePath,
      'file_name': fileName,
      'class_name': className,
      'confidence': confidence,
      'probabilities': probabilities,
      'status': status,
      if (error != null) 'error': error,
    };
  }

  /// 从字典创建
  factory ClassificationResult.fromDict(Map<String, dynamic> data) {
    return ClassificationResult(
      imagePath: data['image_path'] as String? ?? '',
      className: data['class_name'] as String? ?? 'Unknown',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      probabilities: (data['probabilities'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
          ) ??
          const {},
      status: data['status'] as String? ?? 'unknown',
      error: data['error'] as String?,
    );
  }

  /// 转换为 JSON 字符串
  String toJson() => jsonEncode(toDict());

  /// 从 JSON 字符串创建
  factory ClassificationResult.fromJson(String source) =>
      ClassificationResult.fromDict(jsonDecode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
        imagePath,
        className,
        confidence,
        probabilities,
        status,
        error,
      ];
}

/// Mock 分类结果生成器
///
/// 当模型不可用时，返回模拟的分类结果用于测试 UI。
class MockClassificationResult {
  /// Mock 类别列表
  static const List<String> _mockClasses = [
    'Golden Retriever',
    'Persian Cat',
    'Red Rose',
    'Sunflower',
    'Sports Car',
    'Mountain Landscape',
    'Ocean Beach',
    'City Skyline',
    'Abstract Art',
    'Portrait',
  ];

  /// 生成单个 Mock 结果
  static ClassificationResult generate(String imagePath) {
    final random = DateTime.now().millisecondsSinceEpoch % _mockClasses.length;
    final className = _mockClasses[random];
    final confidence = 0.7 + (random % 30) / 100;

    final probabilities = <String, double>{};
    for (var i = 0; i < 5 && i < _mockClasses.length; i++) {
      final idx = (random + i) % _mockClasses.length;
      probabilities[_mockClasses[idx]] =
          confidence - (i * 0.15);
    }

    return ClassificationResult.success(
      imagePath: imagePath,
      className: className,
      confidence: confidence,
      probabilities: probabilities,
    );
  }

  /// 生成批量 Mock 结果
  static List<ClassificationResult> generateBatch(
    List<String> imagePaths, {
    void Function(int current, int total, String path)? onProgress,
  }) {
    final results = <ClassificationResult>[];
    final total = imagePaths.length;

    for (var i = 0; i < total; i++) {
      final path = imagePaths[i];
      final result = generate(path);
      results.add(result);
      onProgress?.call(i + 1, total, path);
    }

    return results;
  }
}
