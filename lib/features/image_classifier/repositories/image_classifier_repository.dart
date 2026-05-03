/// 图像分类器 Repository 层
///
/// 提供模型加载、图片分类推理等核心功能。
/// 支持三种推理后端：ONNX Runtime（推荐）、TensorFlow Lite、API Server。
/// 当模型不可用时，回退到 Mock 模式。
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../models/models.dart';

/// 分类进度回调
typedef ClassificationProgressCallback = void Function(
  int current,
  int total,
  String imagePath,
);

/// 取消令牌
class CancelToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() {
    _cancelled = true;
  }

  void reset() {
    _cancelled = false;
  }
}

/// 图像分类器 Repository
///
/// 封装模型加载和推理逻辑，支持多种后端。
class ImageClassifierRepository {
  /// 当前使用的推理后端
  InferenceBackend _backend = InferenceBackend.mock;

  /// 当前加载的模型信息
  ModelInfo? _currentModel;

  /// 模型是否已加载
  bool _isModelLoaded = false;

  /// 是否正在加载模型
  bool _isLoading = false;

  /// 获取当前后端
  InferenceBackend get backend => _backend;

  /// 获取当前模型信息
  ModelInfo? get currentModel => _currentModel;

  /// 获取模型加载状态
  bool get isModelLoaded => _isModelLoaded;

  /// 获取模型加载状态（加载中）
  bool get isLoading => _isLoading;

  // ============================================================
  // 方案 A: ONNX Runtime 相关方法
  // ============================================================

  /// 加载 ONNX 模型
  ///
  /// 使用 onnx_runtime_flutter 包加载 ONNX 格式模型。
  /// TODO: 集成 onnx_runtime_flutter 包后实现具体推理逻辑。
  Future<bool> loadOnnxModel(String modelPath) async {
    try {
      _isLoading = true;
      _notifyModelLoading(modelPath, '正在加载 ONNX 模型...');

      final file = File(modelPath);
      if (!await file.exists()) {
        throw FileSystemException('模型文件不存在', modelPath);
      }

      // TODO: 实现 ONNX Runtime 模型加载
      // final session = OrtSession.fromFile(file);
      // 解析模型元数据获取 inputSize 和 labels

      _backend = InferenceBackend.onnx;
      _currentModel = ModelInfo(
        name: p.basenameWithoutExtension(modelPath),
        path: modelPath,
        inputSize: 224, // ONNX 模型默认输入尺寸
        labels: _defaultLabels(),
        accuracy: 0.0,
        description: 'ONNX 模型',
        backend: InferenceBackend.onnx,
      );
      _isModelLoaded = true;

      _notifyModelLoaded('ONNX 模型加载成功');
      return true;
    } catch (e) {
      _notifyModelLoading(modelPath, 'ONNX 模型加载失败: $e');
      _backend = InferenceBackend.mock;
      _isModelLoaded = false;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// ONNX 推理单张图片
  Future<ClassificationResult> classifyOnnx(
    String imagePath, {
    ClassificationConfig config = const ClassificationConfig(),
  }) async {
    // TODO: 实现 ONNX Runtime 推理
    // 1. 预处理图片（resize, normalize）
    // 2. 创建输入 Tensor
    // 3. 运行 session.run()
    // 4. 解析输出，获取 Top K 结果
    // 5. 映射类别标签
    return MockClassificationResult.generate(imagePath);
  }

  // ============================================================
  // 方案 B: TensorFlow Lite 相关方法
  // ============================================================

  /// 加载 TFLite 模型
  ///
  /// 使用 tflite_flutter 包加载 TFLite 格式模型。
  /// TODO: 集成 tflite_flutter 包后实现具体推理逻辑。
  Future<bool> loadTfliteModel(String modelPath) async {
    try {
      _isLoading = true;
      _notifyModelLoading(modelPath, '正在加载 TFLite 模型...');

      final file = File(modelPath);
      if (!await file.exists()) {
        throw FileSystemException('模型文件不存在', modelPath);
      }

      // TODO: 实现 TFLite 模型加载
      // final interpreter = Interpreter.fromFile(file);
      // 获取模型输入输出信息

      _backend = InferenceBackend.tflite;
      _currentModel = ModelInfo(
        name: p.basenameWithoutExtension(modelPath),
        path: modelPath,
        inputSize: 224,
        labels: _defaultLabels(),
        accuracy: 0.0,
        description: 'TFLite 模型',
        backend: InferenceBackend.tflite,
      );
      _isModelLoaded = true;

      _notifyModelLoaded('TFLite 模型加载成功');
      return true;
    } catch (e) {
      _notifyModelLoading(modelPath, 'TFLite 模型加载失败: $e');
      _backend = InferenceBackend.mock;
      _isModelLoaded = false;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// TFLite 推理单张图片
  Future<ClassificationResult> classifyTflite(
    String imagePath, {
    ClassificationConfig config = const ClassificationConfig(),
  }) async {
    // TODO: 实现 TFLite 推理
    return MockClassificationResult.generate(imagePath);
  }

  // ============================================================
  // 方案 C: API Server 相关方法
  // ============================================================

  /// 通过 API Server 推理
  ///
  /// 将图片发送到后端 API 进行推理。
  /// TODO: 实现 HTTP 请求逻辑。
  Future<ClassificationResult> classifyApi(
    String imagePath, {
    String? apiEndpoint,
    ClassificationConfig config = const ClassificationConfig(),
  }) async {
    // TODO: 实现 API 调用
    // final response = await http.post(
    //   Uri.parse(apiEndpoint ?? 'http://localhost:8000/classify'),
    //   body: {'image': File(imagePath).readAsBytes()},
    // );
    return MockClassificationResult.generate(imagePath);
  }

  // ============================================================
  // 统一推理接口
  // ============================================================

  /// 加载模型（自动检测格式）
  ///
  /// 根据文件扩展名自动选择推理后端。
  Future<bool> loadModel(String modelPath) async {
    final ext = p.extension(modelPath).toLowerCase();

    switch (ext) {
      case '.onnx':
        return loadOnnxModel(modelPath);
      case '.tflite':
        return loadTfliteModel(modelPath);
      case '.pt':
      case '.pth':
        // PyTorch 模型需要转换为 ONNX 或通过 API 调用
        _notifyModelLoading(
          modelPath,
          'PyTorch 模型需要通过 API 调用或转换为 ONNX 格式',
        );
        _backend = InferenceBackend.mock;
        _isModelLoaded = false;
        return false;
      default:
        // 未知格式，尝试作为 ONNX 加载
        return loadOnnxModel(modelPath);
    }
  }

  /// 推理单张图片（根据后端自动路由）
  Future<ClassificationResult> classify(
    String imagePath, {
    ClassificationConfig config = const ClassificationConfig(),
  }) async {
    if (!_isModelLoaded) {
      return ClassificationResult.failure(
        imagePath: imagePath,
        error: '模型未加载，请先加载模型',
      );
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      return ClassificationResult.failure(
        imagePath: imagePath,
        error: '图片文件不存在',
      );
    }

    switch (_backend) {
      case InferenceBackend.onnx:
        return classifyOnnx(imagePath, config: config);
      case InferenceBackend.tflite:
        return classifyTflite(imagePath, config: config);
      case InferenceBackend.api:
        return classifyApi(imagePath, config: config);
      case InferenceBackend.mock:
        // Mock 模式添加模拟延迟
        await Future.delayed(const Duration(milliseconds: 50));
        return MockClassificationResult.generate(imagePath);
    }
  }

  /// 批量推理图片（使用 Isolate，不阻塞 UI）
  ///
  /// 支持进度回调和取消操作。
  Future<List<ClassificationResult>> classifyBatch(
    List<String> imagePaths, {
    ClassificationConfig config = const ClassificationConfig(),
    ClassificationProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (!_isModelLoaded) {
      return [
        for (final path in imagePaths)
          ClassificationResult.failure(
            imagePath: path,
            error: '模型未加载，请先加载模型',
          ),
      ];
    }

    final results = <ClassificationResult>[];
    final total = imagePaths.length;

    for (var i = 0; i < total; i++) {
      // 检查取消
      if (cancelToken?.isCancelled == true) {
        return results;
      }

      final path = imagePaths[i];
      try {
        final result = await classify(path, config: config);
        results.add(result);
      } catch (e) {
        results.add(
          ClassificationResult.failure(
            imagePath: path,
            error: e.toString(),
          ),
        );
      }

      onProgress?.call(i + 1, total, path);
    }

    return results;
  }

  /// 使用 Isolate 进行批量推理（不阻塞 UI 线程）
  ///
  /// 将推理任务放入后台 Isolate 执行。
  Future<List<ClassificationResult>> classifyBatchWithIsolate(
    List<String> imagePaths, {
    ClassificationConfig config = const ClassificationConfig(),
    void Function(int current, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (!_isModelLoaded) {
      return [
        for (final path in imagePaths)
          ClassificationResult.failure(
            imagePath: path,
            error: '模型未加载',
          ),
      ];
    }

    // 当前使用 Mock 模式模拟 Isolate 批量处理
    // TODO: 集成真实推理后端后，使用 compute() 将推理放入 Isolate
    return compute(
      _mockBatchClassifier,
      _BatchClassifyRequest(
        imagePaths: imagePaths,
        config: config,
        backend: _backend,
      ),
    );
  }

  Future<List<String>> scanImages(String directory, {bool recursive = true}) async {
    final dir = Directory(directory);
    if (!await dir.exists()) {
      throw FileSystemException('目录不存在', directory);
    }

    final imagePaths = <String>[];
    final entities = recursive
        ? dir.list(recursive: true)
        : dir.list(recursive: false);

    await for (final entity in entities) {
      if (entity is File && ImageExtensions.isImage(entity.path)) {
        imagePaths.add(entity.path);
      }
    }

    return imagePaths;
  }

  Map<String, List<String>> classifyByRules(
    List<String> imagePaths,
    List<ClassificationRule> rules,
  ) {
    final groups = <String, List<String>>{};
    final classified = <String>{};

    final enabledRules = rules.where((r) => r.enabled).toList();

    for (final rule in enabledRules) {
      final matched = <String>[];

      for (final imagePath in imagePaths) {
        if (classified.contains(imagePath)) continue;

        final file = File(imagePath);
        final fileName = p.basename(imagePath);
        final extension = p.extension(imagePath).toLowerCase();

        bool matches = false;

        switch (rule.type) {
          case RuleType.extension:
            final extensions = rule.pattern
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .where((e) => e.isNotEmpty)
                .toList();
            matches = extensions.contains(extension);
            break;

          case RuleType.size:
            try {
              final fileSize = file.lengthSync();
              if (rule.pattern.startsWith('>')) {
                final threshold = int.parse(rule.pattern.substring(1));
                matches = fileSize > threshold;
              } else if (rule.pattern.startsWith('<')) {
                final threshold = int.parse(rule.pattern.substring(1));
                matches = fileSize < threshold;
              } else if (rule.pattern.contains('-')) {
                final parts = rule.pattern.split('-');
                final min = int.parse(parts[0]);
                final max = int.parse(parts[1]);
                matches = fileSize >= min && fileSize <= max;
              }
            } catch (_) {}
            break;

          case RuleType.namePattern:
            try {
              final regex = RegExp(rule.pattern, caseSensitive: false);
              matches = regex.hasMatch(fileName);
            } catch (_) {}
            break;
        }

        if (matches) {
          matched.add(imagePath);
          classified.add(imagePath);
        }
      }

      if (matched.isNotEmpty) {
        groups[rule.targetFolder] = matched;
      }
    }

    final unclassified = imagePaths
        .where((path) => !classified.contains(path))
        .toList();
    if (unclassified.isNotEmpty) {
      groups['未分类'] = unclassified;
    }

    return groups;
  }

  Future<int> moveToGroups(
    Map<String, List<String>> groups, {
    String? baseDirectory,
    void Function(int current, int total)? onProgress,
  }) async {
    int movedCount = 0;
    int total = 0;

    for (final entry in groups.entries) {
      total += entry.value.length;
    }

    for (final entry in groups.entries) {
      final targetDir = baseDirectory != null
          ? p.join(baseDirectory, entry.key)
          : entry.key;

      final dir = Directory(targetDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      for (final imagePath in entry.value) {
        try {
          final sourceFile = File(imagePath);
          if (!await sourceFile.exists()) continue;

          final fileName = p.basename(imagePath);
          var targetPath = p.join(targetDir, fileName);

          if (imagePath == targetPath) continue;

          if (await File(targetPath).exists()) {
            final baseName = p.basenameWithoutExtension(imagePath);
            final ext = p.extension(imagePath);
            int counter = 1;
            while (await File(targetPath).exists()) {
              targetPath = p.join(targetDir, '${baseName}_$counter$ext');
              counter++;
            }
          }

          await sourceFile.rename(targetPath);
          movedCount++;
          onProgress?.call(movedCount, total);
        } catch (_) {
          onProgress?.call(movedCount, total);
        }
      }
    }

    return movedCount;
  }

  /// 释放模型资源
  void releaseModel() {
    // TODO: 释放 ONNX/TFLite 会话资源
    _currentModel = null;
    _isModelLoaded = false;
    _backend = InferenceBackend.mock;
    _notifyModelReleased('模型已释放');
  }

  // ============================================================
  // 预定义模型信息
  // ============================================================

  /// 获取预训练模型列表
  static List<ModelInfo> getAvailableModels() {
    return [
      const ModelInfo(
        name: 'ResNet18',
        path: '',
        inputSize: 224,
        labels: [],
        accuracy: 0.698,
        description: '轻量级残差网络，适合快速推理',
        category: 'ResNet',
        size: '44 MB',
        speed: '快',
        params: '11.7M',
        useCase: '实时分类、移动设备、资源受限环境',
      ),
      const ModelInfo(
        name: 'ResNet50',
        path: '',
        inputSize: 224,
        labels: [],
        accuracy: 0.809,
        description: '经典残差网络，性能优异',
        category: 'ResNet',
        size: '97 MB',
        speed: '中等',
        params: '25.6M',
        useCase: '通用图像分类、推荐首选',
      ),
      const ModelInfo(
        name: 'EfficientNet B0',
        path: '',
        inputSize: 224,
        labels: [],
        accuracy: 0.777,
        description: '高效网络V1最小版',
        category: 'EfficientNet',
        size: '20 MB',
        speed: '快',
        params: '5.3M',
        useCase: '高效分类、移动端',
      ),
      const ModelInfo(
        name: 'EfficientNet B4',
        path: '',
        inputSize: 380,
        labels: [],
        accuracy: 0.829,
        description: 'EfficientNet V1标准版',
        category: 'EfficientNet',
        size: '75 MB',
        speed: '较慢',
        params: '19.3M',
        useCase: '高精度分类',
      ),
      const ModelInfo(
        name: 'ConvNeXt Tiny',
        path: '',
        inputSize: 224,
        labels: [],
        accuracy: 0.821,
        description: '现代化CNN架构，轻量版',
        category: 'ConvNeXt',
        size: '109 MB',
        speed: '快',
        params: '28.6M',
        useCase: '现代分类任务、高效推理',
      ),
      const ModelInfo(
        name: 'MobileNet V2',
        path: '',
        inputSize: 224,
        labels: [],
        accuracy: 0.720,
        description: '移动端优化网络',
        category: 'MobileNet',
        size: '14 MB',
        speed: '极快',
        params: '3.4M',
        useCase: '移动端实时分类',
      ),
    ];
  }

  // ============================================================
  // 统计信息
  // ============================================================

  /// 计算分类统计信息
  Map<String, dynamic> calculateStatistics(List<ClassificationResult> results) {
    final total = results.length;
    final successCount = results.where((r) => r.status == 'success').length;
    final errorCount = results.where((r) => r.status == 'error').length;
    final successRate = total > 0 ? successCount / total : 0.0;

    // 统计类别分布
    final classDistribution = <String, int>{};
    for (final result in results) {
      if (result.status == 'success') {
        classDistribution[result.className] =
            (classDistribution[result.className] ?? 0) + 1;
      }
    }

    // 计算平均置信度
    final avgConfidence = successCount > 0
        ? results
                .where((r) => r.status == 'success')
                .map((r) => r.confidence)
                .reduce((a, b) => a + b) /
            successCount
        : 0.0;

    return {
      'total': total,
      'success': successCount,
      'error': errorCount,
      'successRate': successRate,
      'avgConfidence': avgConfidence,
      'classDistribution': classDistribution,
    };
  }

  // ============================================================
  // 回调通知（预留，可用于未来事件广播）
  // ============================================================
  void Function(String message)? onModelLoading;
  void Function(String message)? onModelLoaded;
  void Function(String message)? onModelReleased;

  void _notifyModelLoading(String path, String message) {
    debugPrint('[ImageClassifier] Loading: $message');
    onModelLoading?.call(message);
  }

  void _notifyModelLoaded(String message) {
    debugPrint('[ImageClassifier] Loaded: $message');
    onModelLoaded?.call(message);
  }

  void _notifyModelReleased(String message) {
    debugPrint('[ImageClassifier] Released: $message');
    onModelReleased?.call(message);
  }

  // ============================================================
  // 辅助方法
  // ============================================================

  /// 默认类别标签（ImageNet 1000 类的简化版本）
  List<String> _defaultLabels() {
    return [
      'tench',
      'goldfish',
      'great white shark',
      'tiger shark',
      'hammerhead shark',
      'electric ray',
      'stingray',
      'cock',
      'hen',
      'ostrich',
      // ... 完整列表有 1000 个类别
    ];
  }
}

/// 批量推理请求（用于 Isolate 通信）
class _BatchClassifyRequest {
  final List<String> imagePaths;
  final ClassificationConfig config;
  final InferenceBackend backend;

  const _BatchClassifyRequest({
    required this.imagePaths,
    required this.config,
    required this.backend,
  });
}

/// Mock 批量分类器（Isolate 入口函数，必须是顶层函数）
List<ClassificationResult> _mockBatchClassifier(
    _BatchClassifyRequest request) {
  return MockClassificationResult.generateBatch(
    request.imagePaths,
    onProgress: (current, total, path) {
      debugPrint(
          '[MockClassifier] Progress: $current/$total - $path');
    },
  );
}
