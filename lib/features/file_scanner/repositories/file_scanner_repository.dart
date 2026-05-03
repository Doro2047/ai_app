/// 文件扫描器仓库
///
/// 负责文件系统扫描、筛选和统计计算。
/// 使用 Isolate 进行并行计算，避免阻塞 UI 线程。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import '../models/file_scan_result.dart';

/// 文件扫描器仓库
class FileScannerRepository {
  /// 扫描目录
  ///
  /// [config] 扫描配置
  /// [onProgress] 进度回调 (当前目录索引, 总目录数)
  /// [onBatchFound] 批量发现文件回调
  Stream<FileScanResult> scanDirectory(
    ScanConfig config, {
    void Function(int current, int total)? onProgress,
  }) async* {
    final totalDirs = config.directories.length;

    for (var dirIdx = 0; dirIdx < totalDirs; dirIdx++) {
      onProgress?.call(dirIdx, totalDirs);

      final dirPath = config.directories[dirIdx];
      final dir = Directory(dirPath);
      if (!await dir.exists()) continue;

      await for (final result in _scanSingleDirectory(dir, config)) {
        yield result;
      }
    }

    onProgress?.call(totalDirs, totalDirs);
  }

  /// 使用 Isolate 扫描目录（并行计算）
  Future<List<FileScanResult>> scanDirectoryWithIsolate(
    ScanConfig config, {
    void Function(int current, int total)? onProgress,
  }) async {
    final results = <FileScanResult>[];
    final totalDirs = config.directories.length;

    for (var dirIdx = 0; dirIdx < totalDirs; dirIdx++) {
      onProgress?.call(dirIdx, totalDirs);

      final dirPath = config.directories[dirIdx];
      final dir = Directory(dirPath);
      if (!await dir.exists()) continue;

      try {
        final dirResults = await Isolate.run<List<Map<String, dynamic>>>(() {
          return _isolateScan(dirPath, config.recursive, config.includeHidden);
        });

        for (final map in dirResults) {
          // 应用扩展名和大小过滤
          if (!_matchesFilter(map, config)) continue;
          results.add(FileScanResult(
            path: map['path'] as String,
            name: map['name'] as String,
            extension: map['extension'] as String,
            size: map['size'] as int,
            modifiedTime: DateTime.fromMillisecondsSinceEpoch(map['modifiedTime'] as int),
            isDirectory: map['isDirectory'] as bool,
            fileType: map['fileType'] as String,
          ));
        }
      } catch (e) {
        // Isolate 执行失败时回退到主线程扫描
        await for (final result in _scanSingleDirectory(dir, config)) {
          results.add(result);
        }
      }
    }

    onProgress?.call(totalDirs, totalDirs);
    return results;
  }

  /// Isolate 中执行的扫描函数
  static List<Map<String, dynamic>> _isolateScan(
    String directory,
    bool recursive,
    bool includeHidden,
  ) {
    final results = <Map<String, dynamic>>[];
    final dir = Directory(directory);

    try {
      _scanRecursive(dir, recursive, includeHidden, results);
    } catch (_) {
      // 忽略权限错误
    }

    return results;
  }

  /// 递归扫描目录
  static void _scanRecursive(
    Directory dir,
    bool recursive,
    bool includeHidden,
    List<Map<String, dynamic>> results,
  ) {
    try {
      for (final entity in dir.listSync(followLinks: false)) {
        final name = entity.path.split(Platform.pathSeparator).last;

        // 跳过隐藏文件
        if (!includeHidden && name.startsWith('.')) continue;

        if (entity is File) {
          try {
            final stat = entity.statSync();
            final ext = name.contains('.')
                ? '.${name.split('.').last.toLowerCase()}'
                : '';
            results.add({
              'path': entity.path,
              'name': name,
              'extension': ext,
              'size': stat.size,
              'modifiedTime': stat.modified.millisecondsSinceEpoch,
              'isDirectory': false,
              'fileType': getFileType(name),
            });
          } catch (_) {
            // 忽略权限错误
          }
        } else if (entity is Directory && recursive) {
          _scanRecursive(entity, recursive, includeHidden, results);
        }
      }
    } catch (_) {
      // 忽略权限错误
    }
  }

  /// 扫描单个目录（非 Isolate 方式，用于流式输出）
  Stream<FileScanResult> _scanSingleDirectory(
    Directory dir,
    ScanConfig config,
  ) async* {
    try {
      await for (final entity in dir.list(followLinks: false)) {
        final name = entity.path.split(Platform.pathSeparator).last;

        // 跳过隐藏文件
        if (!config.includeHidden && name.startsWith('.')) continue;

        if (entity is File) {
          try {
            final stat = await entity.stat();
            final ext = name.contains('.')
                ? '.${name.split('.').last.toLowerCase()}'
                : '';
            final result = FileScanResult(
              path: entity.path,
              name: name,
              extension: ext,
              size: stat.size,
              modifiedTime: stat.modified,
              isDirectory: false,
              fileType: getFileType(name),
            );

            // 应用过滤
            if (_matchesFilterResult(result, config)) {
              yield result;
            }
          } catch (_) {
            // 忽略权限错误
          }
        } else if (entity is Directory && config.recursive) {
          await for (final result
              in _scanSingleDirectory(entity, config)) {
            yield result;
          }
        }
      }
    } catch (_) {
      // 忽略权限错误
    }
  }

  /// 检查扫描结果是否匹配过滤条件（Map 版本）
  bool _matchesFilter(Map<String, dynamic> map, ScanConfig config) {
    // 扩展名过滤
    if (config.extensions.isNotEmpty) {
      final ext = map['extension'] as String;
      if (!config.extensions.contains(ext)) return false;
    }

    // 最小大小过滤
    if (config.minSize != null) {
      final size = map['size'] as int;
      if (size < config.minSize!) return false;
    }

    // 最大大小过滤
    if (config.maxSize != null) {
      final size = map['size'] as int;
      if (size > config.maxSize!) return false;
    }

    return true;
  }

  /// 检查扫描结果是否匹配过滤条件（对象版本）
  bool _matchesFilterResult(FileScanResult result, ScanConfig config) {
    // 扩展名过滤
    if (config.extensions.isNotEmpty) {
      if (!config.extensions.contains(result.extension)) return false;
    }

    // 最小大小过滤
    if (config.minSize != null && result.size < config.minSize!) return false;

    // 最大大小过滤
    if (config.maxSize != null && result.size > config.maxSize!) return false;

    return true;
  }

  /// 筛选扫描结果
  List<FileScanResult> filterResults(
    List<FileScanResult> results, {
    String? fileType,
    int? minSizeKB,
    int? maxSizeKB,
    String? extensionFilter,
  }) {
    var filtered = results;

    if (fileType != null && fileType != '全部') {
      filtered = filtered.where((r) => r.fileType == fileType).toList();
    }

    if (extensionFilter != null && extensionFilter.isNotEmpty) {
      filtered =
          filtered.where((r) => r.extension == extensionFilter).toList();
    }

    if (minSizeKB != null) {
      final minBytes = minSizeKB * 1024;
      filtered = filtered.where((r) => r.size >= minBytes).toList();
    }

    if (maxSizeKB != null) {
      final maxBytes = maxSizeKB * 1024;
      filtered = filtered.where((r) => r.size <= maxBytes).toList();
    }

    return filtered;
  }

  /// 计算统计信息
  ScanStatistics calculateStatistics(List<FileScanResult> results) {
    final byExtension = <String, int>{};
    final byFileType = <String, int>{};
    final bySize = <String, int>{};

    int totalSize = 0;

    for (final result in results) {
      totalSize += result.size;

      // 按扩展名
      final ext = result.extension.isEmpty ? '(无扩展名)' : result.extension;
      byExtension[ext] = (byExtension[ext] ?? 0) + 1;

      // 按文件类型
      byFileType[result.fileType] = (byFileType[result.fileType] ?? 0) + 1;

      // 按大小范围
      final rangeName = getSizeRangeName(result.size);
      bySize[rangeName] = (bySize[rangeName] ?? 0) + 1;
    }

    return ScanStatistics(
      totalFiles: results.length,
      totalSize: totalSize,
      byExtension: Map.unmodifiable(byExtension),
      byFileType: Map.unmodifiable(byFileType),
      bySize: Map.unmodifiable(bySize),
    );
  }

  /// 按文件名搜索
  Future<String> exportToCsv(List<FileScanResult> results, String outputPath) async {
    final buffer = StringBuffer();
    buffer.writeln('路径,文件名,扩展名,大小(字节),大小(格式化),修改时间,文件类型');

    for (final r in results) {
      final path = _escapeCsvField(r.path);
      final name = _escapeCsvField(r.name);
      final ext = _escapeCsvField(r.extension);
      final type = _escapeCsvField(r.fileType);
      buffer.writeln('$path,$name,$ext,${r.size},${r.sizeFormatted},${r.modifiedFormatted},$type');
    }

    final file = File(outputPath);
    await file.writeAsString(
      '\uFEFF${buffer.toString()}',
      encoding: utf8,
    );

    return outputPath;
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  List<FileScanResult> searchByFilename(
    List<FileScanResult> results,
    String keyword, {
    bool useRegex = false,
  }) {
    if (keyword.isEmpty) return results;

    if (useRegex) {
      try {
        final regex = RegExp(keyword, caseSensitive: false);
        return results.where((r) => regex.hasMatch(r.name)).toList();
      } catch (_) {
        return [];
      }
    } else {
      final lower = keyword.toLowerCase();
      return results.where((r) => r.name.toLowerCase().contains(lower)).toList();
    }
  }
}
