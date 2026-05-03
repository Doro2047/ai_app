/// 文件移动器仓库
///
/// 负责文件扫描、移动规则应用和批量文件移动操作。
/// 使用 Isolate 进行批量操作，避免阻塞 UI 线程。
library;

import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import '../../file_scanner/models/file_scan_result.dart';
import '../models/move_rule.dart';
import '../models/move_preview.dart';

/// 文件移动器仓库
class FileMoverRepository {
  /// 扫描目录获取文件列表
  ///
  /// [directory] 目录路径
  /// [recursive] 是否递归扫描子目录
  /// [cancelToken] 取消令牌（暂不实现）
  Future<List<FileScanResult>> scanFiles(
    String directory, {
    bool recursive = false,
    dynamic cancelToken,
  }) async {
    final dir = Directory(directory);
    if (!await dir.exists()) {
      return [];
    }

    try {
      final results = await Isolate.run<List<Map<String, dynamic>>>(() {
        return _isolateScan(directory, recursive);
      });

      return results.map((map) => FileScanResult(
        path: map['path'] as String,
        name: map['name'] as String,
        extension: map['extension'] as String,
        size: map['size'] as int,
        modifiedTime: DateTime.fromMillisecondsSinceEpoch(map['modifiedTime'] as int),
        isDirectory: map['isDirectory'] as bool,
        fileType: map['fileType'] as String,
      )).toList();
    } catch (e) {
      // Isolate 失败时回退到主线程
      return _scanOnMainThread(dir, recursive: recursive);
    }
  }

  /// Isolate 中执行的扫描函数
  static List<Map<String, dynamic>> _isolateScan(
    String directory,
    bool recursive,
  ) {
    final results = <Map<String, dynamic>>[];
    final dir = Directory(directory);

    try {
      _scanRecursive(dir, recursive, results);
    } catch (_) {
      // 忽略权限错误
    }

    return results;
  }

  /// 递归扫描目录
  static void _scanRecursive(
    Directory dir,
    bool recursive,
    List<Map<String, dynamic>> results,
  ) {
    try {
      for (final entity in dir.listSync(followLinks: false)) {
        final name = p.basename(entity.path);

        // 跳过隐藏文件
        if (name.startsWith('.')) continue;

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
          _scanRecursive(entity, recursive, results);
        }
      }
    } catch (_) {
      // 忽略权限错误
    }
  }

  /// 主线程扫描（回退方案）
  Future<List<FileScanResult>> _scanOnMainThread(
    Directory dir, {
    bool recursive = false,
  }) async {
    final results = <FileScanResult>[];

    try {
      await for (final entity in dir.list(followLinks: false)) {
        final name = p.basename(entity.path);

        if (name.startsWith('.')) continue;

        if (entity is File) {
          try {
            final stat = await entity.stat();
            final ext = name.contains('.')
                ? '.${name.split('.').last.toLowerCase()}'
                : '';
            results.add(FileScanResult(
              path: entity.path,
              name: name,
              extension: ext,
              size: stat.size,
              modifiedTime: stat.modified,
              isDirectory: false,
              fileType: getFileType(name),
            ));
          } catch (_) {
            // 忽略权限错误
          }
        } else if (entity is Directory && recursive) {
          final subResults = await _scanOnMainThread(
            entity,
            recursive: recursive,
          );
          results.addAll(subResults);
        }
      }
    } catch (_) {
      // 忽略权限错误
    }

    return results;
  }

  /// 应用移动规则到文件列表，生成预览结果
  ///
  /// [files] 文件扫描结果列表
  /// [rules] 移动规则列表
  /// [targetDirectory] 默认目标目录
  List<MovePreview> applyRules(
    List<FileScanResult> files,
    List<MoveRule> rules, {
    String targetDirectory = '',
  }) {
    final previews = <MovePreview>[];

    for (final file in files) {
      // 查找第一个匹配的规则
      final matchedRule = _findMatchingRule(file, rules);

      String targetDir;
      if (matchedRule != null) {
        targetDir = matchedRule.targetDirectory;

        // 如果启用了子目录创建
        if (matchedRule.createSubdirs && matchedRule.subDirPattern.isNotEmpty) {
          final subDir = _resolveSubDirPattern(matchedRule.subDirPattern, file);
          targetDir = p.join(targetDir, subDir);
        }
      } else if (targetDirectory.isNotEmpty) {
        targetDir = targetDirectory;
      } else {
        // 没有规则也没有目标目录，保持原位
        targetDir = p.dirname(file.path);
      }

      // 确保目标目录存在（在预览中标记）
      final targetPath = p.join(targetDir, file.name);

      previews.add(MovePreview(
        originalPath: file.path,
        originalName: file.name,
        targetPath: targetPath,
        status: MoveStatus.pending,
      ));
    }

    return previews;
  }

  /// 查找匹配的规则
  MoveRule? _findMatchingRule(FileScanResult file, List<MoveRule> rules) {
    final name = file.name;
    final ext = file.extension.toLowerCase();
    final nameWithoutExt = ext.isNotEmpty
        ? name.substring(0, name.length - ext.length)
        : name;

    for (final rule in rules) {
      final pattern = rule.matchPattern.toLowerCase();

      switch (rule.matchType) {
        case MatchType.extension:
          final ruleExt = pattern.startsWith('.') ? pattern : '.$pattern';
          if (ext == ruleExt) return rule;
          break;
        case MatchType.name:
          if (nameWithoutExt.toLowerCase() == pattern) return rule;
          break;
        case MatchType.contains:
          if (name.toLowerCase().contains(pattern)) return rule;
          break;
        case MatchType.regex:
          try {
            final regex = RegExp(pattern);
            if (regex.hasMatch(name)) return rule;
          } catch (_) {
            // 正则表达式无效，跳过
          }
          break;
      }
    }
    return null;
  }

  /// 解析子目录模式
  String _resolveSubDirPattern(String pattern, FileScanResult file) {
    var result = pattern;

    // 替换 {extension}
    if (result.contains('{extension}')) {
      final ext = file.extension.startsWith('.')
          ? file.extension.substring(1)
          : file.extension;
      result = result.replaceAll('{extension}', ext.isNotEmpty ? ext : 'other');
    }

    // 替换 {date} (基于修改时间)
    if (result.contains('{date}')) {
      final date = file.modifiedTime;
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result = result.replaceAll('{date}', dateStr);
    }

    // 替换 {year}
    if (result.contains('{year}')) {
      result = result.replaceAll('{year}', file.modifiedTime.year.toString());
    }

    // 替换 {month}
    if (result.contains('{month}')) {
      result = result.replaceAll('{month}', file.modifiedTime.month.toString().padLeft(2, '0'));
    }

    // 替换 {size} (文件大小分类)
    if (result.contains('{size}')) {
      final sizeKB = file.size / 1024;
      String sizeCategory;
      if (sizeKB < 100) {
        sizeCategory = 'small';
      } else if (sizeKB < 10240) {
        sizeCategory = 'medium';
      } else {
        sizeCategory = 'large';
      }
      result = result.replaceAll('{size}', sizeCategory);
    }

    return result;
  }

  /// 执行批量移动
  ///
  /// [previews] 包含目标路径的预览列表
  /// [onProgress] 进度回调 (当前索引, 总数)
  /// 返回 (成功列表, 失败列表)
  Future<(List<MovePreview>, List<MovePreview>)> executeMove(
    List<MovePreview> previews, {
    void Function(int current, int total)? onProgress,
  }) async {
    final successList = <MovePreview>[];
    final failedList = <MovePreview>[];

    // 只处理有变化的文件
    final itemsToMove = previews
        .where((p) => p.hasChange)
        .map((p) => {
          'originalPath': p.originalPath,
          'targetPath': p.targetPath,
        })
        .toList();

    // 标记无变化的为成功
    for (final preview in previews) {
      if (!preview.hasChange) {
        successList.add(preview.copyWith(status: MoveStatus.success));
      }
    }

    // 执行实际移动
    if (itemsToMove.isNotEmpty) {
      try {
        final results = await Isolate.run<List<Map<String, dynamic>>>(() {
          return _isolateMove(itemsToMove);
        });

        for (final preview in previews) {
          if (!preview.hasChange) continue;

          final result = results.where((r) => r['originalPath'] == preview.originalPath).firstOrNull;
          if (result != null && result['success'] == true) {
            successList.add(preview.copyWith(status: MoveStatus.success));
          } else {
            failedList.add(preview.copyWith(
              status: MoveStatus.failed,
              error: result?['error'] as String? ?? '未知错误',
            ));
          }
          onProgress?.call(successList.length + failedList.length, previews.length);
        }
      } catch (e) {
        // Isolate 失败时回退到主线程逐个移动
        for (final preview in previews) {
          if (!preview.hasChange) continue;

          try {
            final file = File(preview.originalPath);
            final targetDir = p.dirname(preview.targetPath);

            // 确保目标目录存在
            final targetDirEntity = Directory(targetDir);
            if (!await targetDirEntity.exists()) {
              await targetDirEntity.create(recursive: true);
            }

            await file.rename(preview.targetPath);
            successList.add(preview.copyWith(status: MoveStatus.success));
          } catch (e) {
            failedList.add(preview.copyWith(
              status: MoveStatus.failed,
              error: e.toString(),
            ));
          }
          onProgress?.call(successList.length + failedList.length, previews.length);
        }
      }
    }

    return (successList, failedList);
  }

  /// Isolate 中执行的批量移动
  static List<Map<String, dynamic>> _isolateMove(
    List<Map<String, String>> items,
  ) {
    final results = <Map<String, dynamic>>[];

    for (final item in items) {
      final originalPath = item['originalPath']!;
      final targetPath = item['targetPath']!;

      try {
        final file = File(originalPath);
        final targetDir = p.dirname(targetPath);

        // 确保目标目录存在
        final targetDirEntity = Directory(targetDir);
        if (!targetDirEntity.existsSync()) {
          targetDirEntity.createSync(recursive: true);
        }

        file.renameSync(targetPath);
        results.add({
          'originalPath': originalPath,
          'success': true,
        });
      } catch (e) {
        results.add({
          'originalPath': originalPath,
          'success': false,
          'error': e.toString(),
        });
      }
    }

    return results;
  }
}
