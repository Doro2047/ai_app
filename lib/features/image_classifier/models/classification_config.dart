/// 图像分类配置数据模型
///
/// 存储分类推理的配置参数，如 Top K、置信度阈值、批量大小等。
library;

import 'package:equatable/equatable.dart';

/// 图像分类配置
class ClassificationConfig extends Equatable {
  /// Top K 结果数量（返回概率最高的 K 个类别）
  final int topK;

  /// 置信度阈值（低于此阈值的结果将被过滤）
  final double threshold;

  /// 批量处理大小（每次推理的图片数量）
  final int batchSize;

  const ClassificationConfig({
    this.topK = 5,
    this.threshold = 0.5,
    this.batchSize = 4,
  });

  /// 默认配置
  static const ClassificationConfig defaults = ClassificationConfig();

  @override
  List<Object?> get props => [topK, threshold, batchSize];

  /// 创建副本并修改部分字段
  ClassificationConfig copyWith({
    int? topK,
    double? threshold,
    int? batchSize,
  }) {
    return ClassificationConfig(
      topK: topK ?? this.topK,
      threshold: threshold ?? this.threshold,
      batchSize: batchSize ?? this.batchSize,
    );
  }
}

/// 支持推理的图片文件扩展名
class ImageExtensions {
  ImageExtensions._();

  /// 支持的图片扩展名列表
  static const Set<String> supported = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.tiff',
    '.tif',
  };

  /// 检查是否为支持的图片文件
  static bool isImage(String filePath) {
    final lower = filePath.toLowerCase();
    return supported.any((ext) => lower.endsWith(ext));
  }
}
