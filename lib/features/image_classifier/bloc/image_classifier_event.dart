library;

import '../models/models.dart';

abstract class ImageClassifierEvent {
  const ImageClassifierEvent();
}

class ImageClassifierModelLoading extends ImageClassifierEvent {
  final String modelPath;
  const ImageClassifierModelLoading(this.modelPath);
}

class ImageClassifierModelLoaded extends ImageClassifierEvent {
  final ModelInfo modelInfo;
  const ImageClassifierModelLoaded(this.modelInfo);
}

class ImageClassifierModelLoadFailed extends ImageClassifierEvent {
  final String error;
  const ImageClassifierModelLoadFailed(this.error);
}

class ImageClassifierImagesSelected extends ImageClassifierEvent {
  final List<String> imagePaths;
  const ImageClassifierImagesSelected(this.imagePaths);
}

class ImageClassifierImageRemoved extends ImageClassifierEvent {
  final String imagePath;
  const ImageClassifierImageRemoved(this.imagePath);
}

class ImageClassifierImagesCleared extends ImageClassifierEvent {
  const ImageClassifierImagesCleared();
}

class ImageClassifierClassificationStarted extends ImageClassifierEvent {
  const ImageClassifierClassificationStarted();
}

class ImageClassifierClassificationCancelled extends ImageClassifierEvent {
  const ImageClassifierClassificationCancelled();
}

class ImageClassifierClassificationComplete extends ImageClassifierEvent {
  final List<ClassificationResult> results;
  const ImageClassifierClassificationComplete(this.results);
}

class ImageClassifierProgressUpdated extends ImageClassifierEvent {
  final int current;
  final int total;
  final String currentImagePath;
  const ImageClassifierProgressUpdated({
    required this.current,
    required this.total,
    required this.currentImagePath,
  });
}

class ImageClassifierClassificationFailed extends ImageClassifierEvent {
  final String error;
  const ImageClassifierClassificationFailed(this.error);
}

class ImageClassifierConfigChanged extends ImageClassifierEvent {
  final ClassificationConfig config;
  const ImageClassifierConfigChanged(this.config);
}

class ImageClassifierModelReleased extends ImageClassifierEvent {
  const ImageClassifierModelReleased();
}

class ImageClassifierLogAdded extends ImageClassifierEvent {
  final String message;
  final String level;
  const ImageClassifierLogAdded(this.message, {this.level = 'info'});
}

class DirectorySelected extends ImageClassifierEvent {
  final String directory;
  const DirectorySelected(this.directory);
}

class RuleAdded extends ImageClassifierEvent {
  final ClassificationRule rule;
  const RuleAdded(this.rule);
}

class RuleRemoved extends ImageClassifierEvent {
  final int index;
  const RuleRemoved(this.index);
}

class RuleUpdated extends ImageClassifierEvent {
  final int index;
  final ClassificationRule rule;
  const RuleUpdated(this.index, this.rule);
}

class PreviewRequested extends ImageClassifierEvent {
  const PreviewRequested();
}

class ExecuteRequested extends ImageClassifierEvent {
  const ExecuteRequested();
}

class CancelRequested extends ImageClassifierEvent {
  const CancelRequested();
}
