library;

import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import '../../file_scanner/models/file_scan_result.dart';
import '../models/move_rule.dart';
import '../models/move_preview.dart';

class FileMoverRepository {
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
      return _scanOnMainThread(dir, recursive: recursive);
    }
  }

  static List<Map<String, dynamic>> _isolateScan(
    String directory,
    bool recursive,
  ) {
    final results = <Map<String, dynamic>>[];
    final dir = Directory(directory);

    try {
      _scanRecursive(dir, recursive, results);
    } catch (_) {
      // Ignore permission errors
    }

    return results;
  }

  static void _scanRecursive(
    Directory dir,
    bool recursive,
    List<Map<String, dynamic>> results,
  ) {
    try {
      for (final entity in dir.listSync(followLinks: false)) {
        final name = p.basename(entity.path);

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
            // Ignore permission errors
          }
        } else if (entity is Directory && recursive) {
          _scanRecursive(entity, recursive, results);
        }
      }
    } catch (_) {
      // Ignore permission errors
    }
  }

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
            // Ignore permission errors
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
      // Ignore permission errors
    }

    return results;
  }

  List<MovePreview> applyRules(
    List<FileScanResult> files,
    List<MoveRule> rules, {
    String targetDirectory = '',
  }) {
    final previews = <MovePreview>[];

    for (final file in files) {
      final matchedRule = _findMatchingRule(file, rules);

      String targetDir;
      if (matchedRule != null) {
        targetDir = matchedRule.targetDirectory;

        if (matchedRule.createSubdirs && matchedRule.subDirPattern.isNotEmpty) {
          final subDir = _resolveSubDirPattern(matchedRule.subDirPattern, file);
          targetDir = p.join(targetDir, subDir);
        }
      } else if (targetDirectory.isNotEmpty) {
        targetDir = targetDirectory;
      } else {
        targetDir = p.dirname(file.path);
      }

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
            // Invalid regex, skip
          }
          break;
      }
    }
    return null;
  }

  String _resolveSubDirPattern(String pattern, FileScanResult file) {
    var result = pattern;

    if (result.contains('{extension}')) {
      final ext = file.extension.startsWith('.')
          ? file.extension.substring(1)
          : file.extension;
      result = result.replaceAll('{extension}', ext.isNotEmpty ? ext : 'other');
    }

    if (result.contains('{date}')) {
      final date = file.modifiedTime;
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result = result.replaceAll('{date}', dateStr);
    }

    if (result.contains('{year}')) {
      result = result.replaceAll('{year}', file.modifiedTime.year.toString());
    }

    if (result.contains('{month}')) {
      result = result.replaceAll('{month}', file.modifiedTime.month.toString().padLeft(2, '0'));
    }

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

  Future<(List<MovePreview>, List<MovePreview>)> executeMove(
    List<MovePreview> previews, {
    void Function(int current, int total)? onProgress,
  }) async {
    final successList = <MovePreview>[];
    final failedList = <MovePreview>[];

    final itemsToMove = previews
        .where((p) => p.hasChange)
        .map((p) => {
          'originalPath': p.originalPath,
          'targetPath': p.targetPath,
        })
        .toList();

    for (final preview in previews) {
      if (!preview.hasChange) {
        successList.add(preview.copyWith(status: MoveStatus.success));
      }
    }

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
              error: result?['error'] as String? ?? 'Unknown error',
            ));
          }
          onProgress?.call(successList.length + failedList.length, previews.length);
        }
      } catch (e) {
        for (final preview in previews) {
          if (!preview.hasChange) continue;

          try {
            final file = File(preview.originalPath);
            final targetDir = p.dirname(preview.targetPath);

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
