library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/bloc/feature_bloc_base.dart';
import '../models/models.dart';
import '../repositories/image_classifier_repository.dart';
import 'image_classifier_event.dart';
import 'image_classifier_state.dart';

class ImageClassifierBloc
    extends FeatureBlocBase<ImageClassifierEvent, ImageClassifierState> {
  final ImageClassifierRepository _repository;
  final CancelToken _cancelToken = CancelToken();

  ImageClassifierBloc({ImageClassifierRepository? repository})
      : _repository = repository ?? ImageClassifierRepository(),
        super(ImageClassifierState.initial()) {
    on<ImageClassifierModelLoading>(_onModelLoading);
    on<ImageClassifierModelLoaded>(_onModelLoaded);
    on<ImageClassifierModelLoadFailed>(_onModelLoadFailed);
    on<ImageClassifierImagesSelected>(_onImagesSelected);
    on<ImageClassifierImageRemoved>(_onImageRemoved);
    on<ImageClassifierImagesCleared>(_onImagesCleared);
    on<ImageClassifierClassificationStarted>(_onClassificationStarted);
    on<ImageClassifierClassificationCancelled>(_onClassificationCancelled);
    on<ImageClassifierClassificationComplete>(_onClassificationComplete);
    on<ImageClassifierClassificationFailed>(_onClassificationFailed);
    on<ImageClassifierProgressUpdated>(_onProgressUpdated);
    on<ImageClassifierConfigChanged>(_onConfigChanged);
    on<ImageClassifierModelReleased>(_onModelReleased);
    on<ImageClassifierLogAdded>(_onLogAdded);
    on<DirectorySelected>(_onDirectorySelected);
    on<RuleAdded>(_onRuleAdded);
    on<RuleRemoved>(_onRuleRemoved);
    on<RuleUpdated>(_onRuleUpdated);
    on<PreviewRequested>(_onPreviewRequested);
    on<ExecuteRequested>(_onExecuteRequested);
    on<CancelRequested>(_onCancelRequested);

    _repository.onModelLoading = (msg) {
      add(ImageClassifierLogAdded(msg));
    };
    _repository.onModelLoaded = (msg) {
      add(ImageClassifierLogAdded(msg));
    };
    _repository.onModelReleased = (msg) {
      add(ImageClassifierLogAdded(msg));
    };
  }

  Future<void> _onModelLoading(
    ImageClassifierModelLoading event,
    Emitter<ImageClassifierState> emit,
  ) async {
    emit(state.copyWith(
      isModelLoading: true,
      clearError: true,
    ));
    emit(state.addLog('正在加载模型: ${event.modelPath}', level: 'info'));

    try {
      final success = await _repository.loadModel(event.modelPath);

      if (success && _repository.currentModel != null) {
        add(ImageClassifierModelLoaded(_repository.currentModel!));
      } else {
        add(const ImageClassifierModelLoadFailed('模型加载失败'));
      }
    } catch (e) {
      add(ImageClassifierModelLoadFailed(e.toString()));
    }
  }

  void _onModelLoaded(
    ImageClassifierModelLoaded event,
    Emitter<ImageClassifierState> emit,
  ) {
    emit(state.copyWith(
      modelInfo: event.modelInfo,
      isModelLoading: false,
      clearError: true,
    ));
    emit(state.addLog(
      '模型加载成功: ${event.modelInfo.name} (${event.modelInfo.inputSize}x${event.modelInfo.inputSize})',
      level: 'info',
    ));
  }

  void _onModelLoadFailed(
    ImageClassifierModelLoadFailed event,
    Emitter<ImageClassifierState> emit,
  ) {
    emit(state.copyWith(
      isModelLoading: false,
      error: event.error,
    ));
    emit(state.addLog('模型加载失败: ${event.error}', level: 'error'));
  }

  void _onImagesSelected(
    ImageClassifierImagesSelected event,
    Emitter<ImageClassifierState> emit,
  ) {
    final newImages = List<String>.from(state.images)
      ..addAll(event.imagePaths);
    emit(state.copyWith(
      images: newImages,
      clearError: true,
    ));
    emit(state.addLog('已添加 ${event.imagePaths.length} 张图片'));
  }

  void _onImageRemoved(
    ImageClassifierImageRemoved event,
    Emitter<ImageClassifierState> emit,
  ) {
    final newImages = List<String>.from(state.images)
      ..remove(event.imagePath);

    final newResults = List<ClassificationResult>.from(state.results)
      ..removeWhere((r) => r.imagePath == event.imagePath);

    emit(state.copyWith(
      images: newImages,
      results: newResults,
    ));
    emit(state.addLog('已移除图片: ${event.imagePath.split('/').last}'));
  }

  void _onImagesCleared(
    ImageClassifierImagesCleared event,
    Emitter<ImageClassifierState> emit,
  ) {
    emit(state.copyWith(
      images: const [],
      results: const [],
      progress: 0.0,
      progressText: '',
      currentProcessingImage: null,
      statistics: const {},
    ));
    emit(state.addLog('已清空图片列表'));
  }

  Future<void> _onClassificationStarted(
    ImageClassifierClassificationStarted event,
    Emitter<ImageClassifierState> emit,
  ) async {
    if (state.images.isEmpty) {
      emit(state.copyWith(error: '请先选择图片'));
      emit(state.addLog('分类失败: 没有选择图片', level: 'warn'));
      return;
    }

    _cancelToken.reset();

    emit(state.copyWith(
      isClassifying: true,
      progress: 0.0,
      progressText: '0/${state.images.length}',
      results: const [],
      currentProcessingImage: null,
      clearError: true,
    ));
    emit(state.addLog(
      '开始分类: ${state.images.length} 张图片',
      level: 'info',
    ));

    try {
      final results = await _repository.classifyBatchWithIsolate(
        state.images,
        config: state.config,
        onProgress: (current, total) {
          add(ImageClassifierProgressUpdated(
            current: current,
            total: total,
            currentImagePath: state.images[current - 1],
          ));
        },
        cancelToken: _cancelToken,
      );

      if (_cancelToken.isCancelled) {
        emit(state.addLog('分类已取消', level: 'warn'));
        emit(state.copyWith(
          isClassifying: false,
          results: results,
          currentProcessingImage: null,
        ));
        return;
      }

      add(ImageClassifierClassificationComplete(results));
    } catch (e) {
      add(ImageClassifierClassificationFailed(e.toString()));
    }
  }

  void _onClassificationCancelled(
    ImageClassifierClassificationCancelled event,
    Emitter<ImageClassifierState> emit,
  ) {
    _cancelToken.cancel();
    emit(state.copyWith(
      isClassifying: false,
    ));
    emit(state.addLog('正在取消分类...', level: 'warn'));
  }

  void _onClassificationComplete(
    ImageClassifierClassificationComplete event,
    Emitter<ImageClassifierState> emit,
  ) {
    final stats = _repository.calculateStatistics(event.results);

    emit(state.copyWith(
      isClassifying: false,
      results: event.results,
      progress: 1.0,
      progressText: '${event.results.length}/${state.images.length}',
      currentProcessingImage: null,
      statistics: stats,
    ));
    emit(state.addLog(
      '分类完成: ${stats['success']} 成功, ${stats['error']} 失败',
      level: 'info',
    ));
  }

  void _onClassificationFailed(
    ImageClassifierClassificationFailed event,
    Emitter<ImageClassifierState> emit,
  ) {
    emit(state.copyWith(
      isClassifying: false,
      error: event.error,
      currentProcessingImage: null,
    ));
    emit(state.addLog('分类失败: ${event.error}', level: 'error'));
  }

  void _onProgressUpdated(
    ImageClassifierProgressUpdated event,
    Emitter<ImageClassifierState> emit,
  ) {
    emit(state.copyWith(
      progress: event.total > 0 ? event.current / event.total : 0.0,
      progressText: '${event.current}/${event.total}',
      currentProcessingImage: event.currentImagePath,
    ));
  }

  void _onConfigChanged(
    ImageClassifierConfigChanged event,
    Emitter<ImageClassifierState> emit,
  ) {
    emit(state.copyWith(config: event.config));
    emit(state.addLog(
      '配置已更新: TopK=${event.config.topK}, '
      'Threshold=${event.config.threshold}, '
      'BatchSize=${event.config.batchSize}',
    ));
  }

  void _onModelReleased(
    ImageClassifierModelReleased event,
    Emitter<ImageClassifierState> emit,
  ) {
    _repository.releaseModel();
    emit(state.copyWith(
      modelInfo: null,
      results: const [],
      progress: 0.0,
      progressText: '',
      statistics: const {},
    ));
    emit(state.addLog('模型已释放'));
  }

  void _onLogAdded(
    ImageClassifierLogAdded event,
    Emitter<ImageClassifierState> emit,
  ) {
    emit(state.addLog(event.message, level: event.level));
  }

  Future<void> _onDirectorySelected(
    DirectorySelected event,
    Emitter<ImageClassifierState> emit,
  ) async {
    emit(state.copyWith(
      directory: event.directory,
      isScanning: true,
      images: const [],
      classifiedGroups: const {},
      clearError: true,
    ));
    emit(state.addRuleLog('正在扫描目录: ${event.directory}'));

    try {
      final images = await _repository.scanImages(event.directory);
      emit(state.copyWith(
        images: images,
        isScanning: false,
      ));
      emit(state.addRuleLog('扫描完成: 发现 ${images.length} 张图片'));
    } catch (e) {
      emit(state.copyWith(
        isScanning: false,
        error: '扫描失败: $e',
      ));
      emit(state.addRuleLog('扫描失败: $e'));
    }
  }

  void _onRuleAdded(
    RuleAdded event,
    Emitter<ImageClassifierState> emit,
  ) {
    final newRules = List<ClassificationRule>.from(state.rules)
      ..add(event.rule);
    emit(state.copyWith(rules: newRules));
    emit(state.addRuleLog('添加规则: ${event.rule.name}'));
  }

  void _onRuleRemoved(
    RuleRemoved event,
    Emitter<ImageClassifierState> emit,
  ) {
    if (event.index >= 0 && event.index < state.rules.length) {
      final removed = state.rules[event.index];
      final newRules = List<ClassificationRule>.from(state.rules)
        ..removeAt(event.index);
      emit(state.copyWith(rules: newRules));
      emit(state.addRuleLog('删除规则: ${removed.name}'));
    }
  }

  void _onRuleUpdated(
    RuleUpdated event,
    Emitter<ImageClassifierState> emit,
  ) {
    if (event.index >= 0 && event.index < state.rules.length) {
      final newRules = List<ClassificationRule>.from(state.rules);
      newRules[event.index] = event.rule;
      emit(state.copyWith(rules: newRules));
      emit(state.addRuleLog('更新规则: ${event.rule.name}'));
    }
  }

  void _onPreviewRequested(
    PreviewRequested event,
    Emitter<ImageClassifierState> emit,
  ) {
    if (state.images.isEmpty) {
      emit(state.copyWith(error: '请先扫描图片目录'));
      return;
    }

    if (state.rules.isEmpty) {
      emit(state.copyWith(error: '请至少添加一条分类规则'));
      return;
    }

    final groups = _repository.classifyByRules(state.images, state.rules);
    emit(state.copyWith(classifiedGroups: groups));

    final total = groups.values.fold(0, (sum, list) => sum + list.length);
    emit(state.addRuleLog('预览完成: ${groups.length} 个分组, 共 $total 张图片'));
  }

  Future<void> _onExecuteRequested(
    ExecuteRequested event,
    Emitter<ImageClassifierState> emit,
  ) async {
    if (state.classifiedGroups.isEmpty) {
      emit(state.copyWith(error: '请先预览分类结果'));
      return;
    }

    emit(state.copyWith(isClassifying: true, clearError: true));
    emit(state.addRuleLog('开始执行分类移动...'));

    try {
      final moved = await _repository.moveToGroups(
        state.classifiedGroups,
        baseDirectory: state.directory,
        onProgress: (current, total) {
          emit(state.copyWith(
            progress: total > 0 ? current / total : 0.0,
            progressText: '$current/$total',
          ));
        },
      );

      emit(state.copyWith(
        isClassifying: false,
        progress: 1.0,
        classifiedGroups: const {},
      ));
      emit(state.addRuleLog('分类移动完成: 已移动 $moved 张图片'));
    } catch (e) {
      emit(state.copyWith(
        isClassifying: false,
        error: '执行失败: $e',
      ));
      emit(state.addRuleLog('执行失败: $e'));
    }
  }

  void _onCancelRequested(
    CancelRequested event,
    Emitter<ImageClassifierState> emit,
  ) {
    emit(state.copyWith(
      isScanning: false,
      isClassifying: false,
      progress: 0.0,
    ));
    emit(state.addRuleLog('操作已取消'));
  }

  @override
  Future<void> close() {
    _cancelToken.cancel();
    _repository.releaseModel();
    return super.close();
  }
}
