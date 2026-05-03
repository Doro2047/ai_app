/// 重复文件组模型
///
/// 存储具有相同哈希值的重复文件集合。
library;

import 'file_hash_result.dart';

/// 重复文件组
class DuplicateGroup {
  /// 哈希值
  final String hash;

  /// 单个文件大小
  final int size;

  /// 该组所有文件
  final List<FileHashResult> files;

  /// 用户选中的要删除的文件路径列表
  final Set<String> selectedFiles;

  DuplicateGroup({
    required this.hash,
    required this.size,
    required this.files,
    Set<String>? selectedFiles,
  }) : selectedFiles = selectedFiles ?? {};

  /// 获取选中文件的路径列表
  List<String> getSelectedPaths() {
    return selectedFiles.toList();
  }

  /// 该组重复文件可释放的空间
  int get spaceSavings => size * selectedFiles.length;

  /// 该组文件总数
  int get fileCount => files.length;

  /// 已选中的文件数
  int get selectedCount => selectedFiles.length;

  /// 判断文件是否被选中
  bool isFileSelected(String filePath) {
    return selectedFiles.contains(filePath);
  }

  /// 切换文件选中状态
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

  /// 选中该组所有文件（除第一个外）
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

  /// 取消选中该组所有文件
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
