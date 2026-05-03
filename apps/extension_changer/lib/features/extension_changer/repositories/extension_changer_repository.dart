library;

import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import '../models/file_scan_result.dart';
import '../models/extension_rule.dart';
import '../models/file_preview.dart';

class ExtensionChangerRepository {
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
      // ignore permission errors
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
            // ignore permission errors
          }
        } else if (entity is Directory && recursive) {
          _scanRecursive(entity, recursive, results);
        }
      }
    } catch (_) {
      // ignore permission errors
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
            // ignore permission errors
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
      // ignore permission errors
    }

    return results;
  }

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

  String _applyExtensions(String filename, List<ExtensionRule> rules) {
    final currentExt = filename.contains('.')
        ? '.${filename.split('.').last}'
        : '';

    final matchedRule = rules.firstWhere(
      (rule) {
        final ruleExt = rule.originalExtension.toLowerCase();
        final fileExt = currentExt.toLowerCase();
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

    if (matchedRule.originalExtension.isEmpty && matchedRule.newExtension.isEmpty) {
      return filename;
    }

    final nameWithoutExt = currentExt.isNotEmpty
        ? filename.substring(0, filename.length - currentExt.length)
        : filename;

    var newExt = matchedRule.newExtension;
    if (newExt.isNotEmpty && !newExt.startsWith('.')) {
      newExt = '.$newExt';
    }

    return '$nameWithoutExt$newExt';
  }

  Future<(List<FilePreview>, List<FilePreview>)> executeRename(
    List<FilePreview> previews, {
    void Function(int current, int total)? onProgress,
  }) async {
    final successList = <FilePreview>[];
    final failedList = <FilePreview>[];

    final itemsToRename = previews
        .where((p) => p.hasChange)
        .map((p) => {
          'originalPath': p.originalPath,
          'newName': p.newName,
        })
        .toList();

    for (final preview in previews) {
      if (!preview.hasChange) {
        successList.add(preview.copyWith(status: ExtensionChangeStatus.success));
      }
    }

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
