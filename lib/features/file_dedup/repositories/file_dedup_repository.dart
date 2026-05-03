/// 文件查重仓库
///
/// 负责文件扫描、哈希计算、重复检测和文件删除操作。
/// 使用 Isolate 进行并行哈希计算以避免阻塞 UI。
library;

import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../models/models.dart';

/// 进度回调类型
typedef ProgressCallback = void Function(int current, int total);

/// 文件查重仓库
class FileDedupRepository {
  /// 扫描文件并计算哈希
  ///
  /// [directories] 要扫描的目录列表
  /// [recursive] 是否递归子目录
  /// [onProgress] 进度回调
  /// [cancelToken] 取消令牌
  /// 返回文件哈希结果列表
  Future<List<FileHashResult>> scanFiles(
    List<String> directories, {
    bool recursive = true,
    ProgressCallback? onProgress,
    Completer<void>? cancelToken,
  }) async {
    final allFiles = <FileSystemEntity>[];

    // 第一步：收集所有文件
    for (final dir in directories) {
      final directory = Directory(dir);
      if (!await directory.exists()) continue;

      final entities = recursive ? directory.listSync(recursive: true, followLinks: false) : directory.listSync(followLinks: false);

      for (final entity in entities) {
        if (cancelToken?.isCompleted == true) return [];
        if (entity is File) {
          try {
            // 跳过隐藏文件
            final basename = p.basename(entity.path);
            if (basename.startsWith('.')) continue;
            allFiles.add(entity);
          } catch (_) {
            // 跳过无法访问的文件
          }
        }
      }
    }

    final totalFiles = allFiles.length;
    if (totalFiles == 0) return [];

    final results = <FileHashResult>[];

    // 按文件大小分组，相同大小的文件才需要计算哈希
    final sizeGroups = <int, List<FileSystemEntity>>{};
    for (final file in allFiles) {
      try {
        final stat = file.statSync();
        final group = sizeGroups[stat.size] ?? [];
        group.add(file);
        sizeGroups[stat.size] = group;
      } catch (_) {}
    }

    // 只对有多个相同大小文件的组计算哈希
    final filesToHash = <FileSystemEntity>[];
    for (final entries in sizeGroups.values) {
      if (entries.length > 1) {
        filesToHash.addAll(entries);
      }
    }

    // 使用 Isolate 并行计算哈希
    int processed = 0;
    for (final file in filesToHash) {
      if (cancelToken?.isCompleted == true) break;

      try {
        final result = await computeFileHash(file.path);
        results.add(result);
        processed++;
        onProgress?.call(processed, filesToHash.length);
      } catch (_) {
        // 跳过无法读取的文件
      }
    }

    return results;
  }

  /// 查找重复文件组
  ///
  /// [files] 文件哈希结果列表
  /// 返回重复文件组列表
  List<DuplicateGroup> findDuplicates(List<FileHashResult> files) {
    // 按哈希值分组
    final hashGroups = <String, List<FileHashResult>>{};

    for (final file in files) {
      final group = hashGroups[file.hash] ?? [];
      group.add(file);
      hashGroups[file.hash] = group;
    }

    // 过滤出重复文件（组内文件数 > 1）
    final duplicateGroups = <DuplicateGroup>[];

    for (final entry in hashGroups.entries) {
      if (entry.value.length > 1) {
        // 按修改时间排序，最新的放前面
        final sortedFiles = List<FileHashResult>.from(entry.value)
          ..sort((a, b) => b.modified.compareTo(a.modified));

        final group = DuplicateGroup(
          hash: entry.key,
          size: sortedFiles.first.size,
          files: sortedFiles,
          selectedFiles: {},
        );

        // 默认选中除第一个外的所有文件
        duplicateGroups.add(group.selectAllButFirst());
      }
    }

    // 按文件大小排序（大的放前面）
    duplicateGroups.sort((a, b) => b.size.compareTo(a.size));

    return duplicateGroups;
  }

  /// 删除文件
  ///
  /// [paths] 要删除的文件路径列表
  /// [moveToTrash] 是否移动到回收站（当前实现为直接删除）
  /// 返回 (成功列表, 失败列表)
  Future<(List<String> success, List<String> failed)> deleteFiles(
    List<String> paths, {
    bool moveToTrash = true,
  }) async {
    final success = <String>[];
    final failed = <String>[];

    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          success.add(path);
        } else {
          failed.add(path);
        }
      } catch (e) {
        failed.add(path);
      }
    }

    return (success, failed);
  }

  /// 计算单个文件的哈希值
  ///
  /// 此方法可以在 Isolate 中安全调用
  static Future<FileHashResult> computeFileHash(String filePath, {String hashType = 'md5'}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('文件不存在', filePath);
    }

    final stat = await file.stat();
    final bytes = await file.readAsBytes();

    Digest digest;
    switch (hashType.toLowerCase()) {
      case 'sha1':
        digest = sha1.convert(bytes);
        break;
      case 'sha256':
        digest = sha256.convert(bytes);
        break;
      case 'md5':
      default:
        digest = md5.convert(bytes);
        break;
    }

    return FileHashResult(
      path: filePath,
      name: p.basename(filePath),
      size: stat.size,
      hash: digest.toString(),
      hashType: hashType.toLowerCase(),
      modified: stat.modified,
    );
  }
}
