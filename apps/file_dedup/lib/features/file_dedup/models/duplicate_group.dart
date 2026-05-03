/// Duplicate file group model
///
/// Stores a collection of duplicate files with the same hash value.
library;

import 'file_hash_result.dart';

/// Duplicate file group
class DuplicateGroup {
  /// Hash value
  final String hash;

  /// Single file size
  final int size;

  /// All files in this group
  final List<FileHashResult> files;

  /// User-selected file paths to delete
  final Set<String> selectedFiles;

  DuplicateGroup({
    required this.hash,
    required this.size,
    required this.files,
    Set<String>? selectedFiles,
  }) : selectedFiles = selectedFiles ?? {};

  /// Get selected file paths
  List<String> getSelectedPaths() {
    return selectedFiles.toList();
  }

  /// Space that can be freed by this group of duplicate files
  int get spaceSavings => size * selectedFiles.length;

  /// Total file count in this group
  int get fileCount => files.length;

  /// Number of selected files
  int get selectedCount => selectedFiles.length;

  /// Check if a file is selected
  bool isFileSelected(String filePath) {
    return selectedFiles.contains(filePath);
  }

  /// Toggle file selection state
  DuplicateGroup copyWithFileSelection({
    required String filePath,
    required bool isSelected,
  }) {
    final newSelected = Set<String>.from(selectedFiles);
    if (isSelected) {
      newSelected.add(filePath);
    } else {
      newSelected.remove(filePath);
    }
    return DuplicateGroup(
      hash: hash,
      size: size,
      files: files,
      selectedFiles: newSelected,
    );
  }

  /// Select all files in this group (except the first one)
  DuplicateGroup selectAllButFirst() {
    final newSelected = <String>{};
    for (int i = 1; i < files.length; i++) {
      newSelected.add(files[i].path);
    }
    return DuplicateGroup(
      hash: hash,
      size: size,
      files: files,
      selectedFiles: newSelected,
    );
  }

  /// Deselect all files in this group
  DuplicateGroup deselectAll() {
    return DuplicateGroup(
      hash: hash,
      size: size,
      files: files,
      selectedFiles: {},
    );
  }

  @override
  String toString() => 'DuplicateGroup(hash: $hash, files: $fileCount, size: ${files.firstOrNull?.sizeFormatted ?? "0 B"})';
}
