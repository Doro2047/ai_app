/// 扩展名修改器仓库
///
/// 负责文件扫描、扩展名规则应用和批量重命名操作。
/// 使用 Isolate 进行批量操作，避免阻塞 UI 线程。
library;

import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import '../../file_scanner/models/file_scan_result.dart';
import '../models/extension_rule.dart';
import '../models/file_preview.dart';

/// 文件扩展名修改器仓库
class ExtensionChangerRepository {
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

  /// 应用扩展名规则到文件列表，生成预览结果
  ///
  /// [files] 文件扫描结果列表
  /// [rules] 扩展名修改规则列表
  List<FilePreview> applyRules(
    List<FileScanResult> files,
    List<ExtensionRule> rules,
  ) {
    final previews = <FilePreview>[];

    for (final file in files) {
      final newName = _applyExtensions(file.name, rules);

      previews.add(FilePreview(
        originalPath: file.path,
        originalName: file.name,
        newName: newName,
        status: ExtensionChangeStatus.pending,
      ));
    }

    return previews;
  }

  /// 对单个文件名应用扩展名规则
  String _applyExtensions(String filename, List<ExtensionRule> rules) {
    // 获取当前扩展名
    final currentExt = filename.contains('.')
        ? '.${filename.split('.').last}'
        : '';

    // 查找匹配的规则
    final matchedRule = rules.firstWhere(
      (rule) {
        final ruleExt = rule.originalExtension.toLowerCase();
        final fileExt = currentExt.toLowerCase();
        // 支持匹配 "无扩展名" 的情况
        if (ruleExt.isEmpty || ruleExt == '(none)') {
          return currentExt.isEmpty;
        }
        return ruleExt == fileExt || ruleExt == fileExt.substring(1);
      },
      orElse: () => const ExtensionRule(
        originalExtension: '',
        newExtension: '',
      ),
    );

    // 如果没有匹配的规则或新扩展名为空，返回原文件名
    if (matchedRule.originalExtension.isEmpty && matchedRule.newExtension.isEmpty) {
      return filename;
    }

    // 替换扩展名
    final nameWithoutExt = currentExt.isNotEmpty
        ? filename.substring(0, filename.length - currentExt.length)
        : filename;

    // 处理新扩展名格式
    var newExt = matchedRule.newExtension;
    if (newExt.isNotEmpty && !newExt.startsWith('.')) {
      newExt = '.$newExt';
    }

    return '$nameWithoutExt$newExt';
  }

  /// 执行批量重命名
  ///
  /// [previews] 包含新名称的预览列表
  /// [onProgress] 进度回调 (当前索引, 总数)
  /// 返回 (成功列表, 失败列表)
  Future<(List<FilePreview>, List<FilePreview>)> executeRename(
    List<FilePreview> previews, {
    void Function(int current, int total)? onProgress,
  }) async {
    final successList = <FilePreview>[];
    final failedList = <FilePreview>[];

    // 只处理有变化的文件
    final itemsToRename = previews
        .where((p) => p.hasChange)
        .map((p) => {
          'originalPath': p.originalPath,
          'newName': p.newName,
        })
        .toList();

    // 标记无变化的为成功
    for (final preview in previews) {
      if (!preview.hasChange) {
        successList.add(preview.copyWith(status: ExtensionChangeStatus.success));
      }
    }

    // 执行实际重命名
    if (itemsToRename.isNotEmpty) {
      try {
        final results = await Isolate.run<List<Map<String, dynamic>>>(() {
          return _isolateRename(itemsToRename);
        });

        for (final preview in previews) {
          if (!preview.hasChange) continue;

          final result = results.where((r) => r['originalPath'] == preview.originalPath).firstOrNull;
          if (result != null && result['success'] == true) {
            successList.add(preview.copyWith(status: ExtensionChangeStatus.success));
          } else {
            failedList.add(preview.copyWith(
              status: ExtensionChangeStatus.failed,
              error: result?['error'] as String? ?? '未知错误',
            ));
          }
          onProgress?.call(successList.length + failedList.length, previews.length);
        }
      } catch (e) {
        // Isolate 失败时回退到主线程逐个重命名
        for (final preview in previews) {
          if (!preview.hasChange) continue;

          try {
            final file = File(preview.originalPath);
            final newPath = preview.newPath;
            await file.rename(newPath);
            successList.add(preview.copyWith(status: ExtensionChangeStatus.success));
          } catch (e) {
            failedList.add(preview.copyWith(
              status: ExtensionChangeStatus.failed,
              error: e.toString(),
            ));
          }
          onProgress?.call(successList.length + failedList.length, previews.length);
        }
      }
    }

    return (successList, failedList);
  }

  /// Isolate 中执行的批量重命名
  static List<Map<String, dynamic>> _isolateRename(
    List<Map<String, String>> items,
  ) {
    final results = <Map<String, dynamic>>[];

    for (final item in items) {
      final originalPath = item['originalPath']!;
      final newName = item['newName']!;

      try {
        final file = File(originalPath);
        final dir = p.dirname(originalPath);
        final newPath = p.join(dir, newName);
        file.renameSync(newPath);
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
