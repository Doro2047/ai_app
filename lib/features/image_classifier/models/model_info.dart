/// 图像分类模型信息数据模型
///
/// 存储预训练模型的元数据，包括名称、路径、输入尺寸、类别标签等。
library;

import 'package:equatable/equatable.dart';

/// 图像分类模型信息
class ModelInfo extends Equatable {
  /// 模型显示名称
  final String name;

  /// 模型文件路径（ONNX/TFLite 等）
  final String path;

  /// 模型输入尺寸（如 224 表示 224x224）
  final int inputSize;

  /// 模型类别标签列表
  final List<String> labels;

  /// 模型在 ImageNet 上的 Top-1 精度（如 0.809 表示 80.9%）
  final double accuracy;

  /// 模型描述
  final String description;

  /// 模型类别（如 'ResNet', 'EfficientNet'）
  final String? category;

  /// 模型文件大小描述（如 '97 MB'）
  final String? size;

  /// 推理速度描述（如 '中等'）
  final String? speed;

  /// 参数量描述（如 '25.6M'）
  final String? params;

  /// 适用场景描述
  final String? useCase;

  /// 模型架构类型
  final InferenceBackend backend;

  const ModelInfo({
    required this.name,
    required this.path,
    required this.inputSize,
    required this.labels,
    required this.accuracy,
    this.description = '',
    this.category,
    this.size,
    this.speed,
    this.params,
    this.useCase,
    this.backend = InferenceBackend.onnx,
  });

  /// 获取精度百分比字符串
  String get accuracyPercent => '${(accuracy * 100).toStringAsFixed(1)}%';

  /// 检查模型是否已加载
  bool get isLoaded => path.isNotEmpty;

  @override
  List<Object?> get props => [
        name,
        path,
        inputSize,
        labels,
        accuracy,
        description,
        category,
        size,
        speed,
        params,
        useCase,
        backend,
      ];

  /// 创建副本并修改部分字段
  ModelInfo copyWith({
    String? name,
    String? path,
    int? inputSize,
    List<String>? labels,
    double? accuracy,
    String? description,
    String? category,
    String? size,
    String? speed,
    String? params,
    String? useCase,
    InferenceBackend? backend,
  }) {
    return ModelInfo(
      name: name ?? this.name,
      path: path ?? this.path,
      inputSize: inputSize ?? this.inputSize,
      labels: labels ?? this.labels,
      accuracy: accuracy ?? this.accuracy,
      description: description ?? this.description,
      category: category ?? this.category,
      size: size ?? this.size,
      speed: speed ?? this.speed,
      params: params ?? this.params,
      useCase: useCase ?? this.useCase,
      backend: backend ?? this.backend,
    );
  }
}

/// 推理后端类型
enum InferenceBackend {
  /// ONNX Runtime
  onnx('ONNX Runtime'),

  /// TensorFlow Lite
  tflite('TensorFlow Lite'),

  /// 远程 API 调用
  api('API Server'),

  /// Mock 模式（无真实模型）
  mock('Mock (模拟)'),
  ;

  /// 显示名称
  final String displayName;

  const InferenceBackend(this.displayName);
}
