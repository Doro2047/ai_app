library;

import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import '../models/rename_rule.dart';
import '../models/rename_preview.dart';

class FileRenamerRepository {
  Future<List<String>> scanFiles(
    String directory, {
    bool recursive = true,
  }) async {
    final dir = Directory(directory);
    if (!await dir.exists()) {
      return [];
    }

    try {
      final results = await Isolate.run<List<String>>(() {
        return _isolateScan(directory, recursive);
      });
      return results;
    } catch (e) {
      return _scanOnMainThread(dir, recursive: recursive);
    }
  }

  static List<String> _isolateScan(String directory, bool recursive) {
    final results = <String>[];
    final dir = Directory(directory);

    try {
      _scanRecursive(dir, recursive, results);
    } catch (_) {}

    return results;
  }

  static void _scanRecursive(
    Directory dir,
    bool recursive,
    List<String> results,
  ) {
    try {
      for (final entity in dir.listSync(followLinks: false)) {
        final name = p.basename(entity.path);

        if (name.startsWith('.')) continue;

        if (entity is File) {
          results.add(entity.path);
        } else if (entity is Directory && recursive) {
          _scanRecursive(entity, recursive, results);
        }
      }
    } catch (_) {}
  }

  Future<List<String>> _scanOnMainThread(
    Directory dir, {
    bool recursive = true,
  }) async {
    final results = <String>[];

    try {
      await for (final entity in dir.list(followLinks: false)) {
        final name = p.basename(entity.path);

        if (name.startsWith('.')) continue;

        if (entity is File) {
          results.add(entity.path);
        } else if (entity is Directory && recursive) {
          final subResults = await _scanOnMainThread(
            entity,
            recursive: recursive,
          );
          results.addAll(subResults);
        }
      }
    } catch (_) {}

    return results;
  }

  List<RenamePreview> generatePreview(
    List<String> files,
    List<RenameRule> rules,
  ) {
    final enabledRules = rules.where((r) => r.enabled).toList();
    final previews = <RenamePreview>[];

    for (var i = 0; i < files.length; i++) {
      final filePath = files[i];
      var currentName = p.basename(filePath);

      for (final rule in enabledRules) {
        currentName = rule.apply(currentName, i);
      }

      previews.add(RenamePreview(
        originalPath: filePath,
        newName: currentName,
      ));
    }

    final conflictNames = <String>{};
    final nameCounts = <String, int>{};
    for (final preview in previews) {
      if (preview.hasChange) {
        nameCounts[preview.newName] = (nameCounts[preview.newName] ?? 0) + 1;
      }
    }
    for (final entry in nameCounts.entries) {
      if (entry.value > 1) {
        conflictNames.add(entry.key);
      }
    }

    final result = <RenamePreview>[];
    for (final preview in previews) {
      if (conflictNames.contains(preview.newName) && preview.hasChange) {
        result.add(preview.copyWith(
          hasConflict: true,
          error: 'Name conflict: ${preview.newName}',
        ));
      } else {
        result.add(preview);
      }
    }

    return result;
  }

  Future<List<RenamePreview>> executeRename(
    List<RenamePreview> previews,
  ) async {
    final results = <RenamePreview>[];

    for (final preview in previews) {
      if (!preview.hasChange) {
        results.add(preview);
        continue;
      }
      if (preview.hasConflict) {
        results.add(preview.copyWith(error: 'Name conflict, skipped'));
        continue;
      }

      try {
        final file = File(preview.originalPath);
        await file.rename(preview.newPath);
        results.add(preview);
      } catch (e) {
        results.add(preview.copyWith(error: e.toString()));
      }
    }

    return results;
  }

  Future<List<RenamePreview>> undoRename(
    List<RenamePreview> previews,
  ) async {
    final results = <RenamePreview>[];

    for (final preview in previews) {
      if (!preview.hasChange) {
        results.add(preview);
        continue;
      }

      try {
        final file = File(preview.newPath);
        if (await file.exists()) {
          await file.rename(preview.originalPath);
          results.add(RenamePreview(
            originalPath: preview.originalPath,
            newName: p.basename(preview.originalPath),
          ));
        } else {
          results.add(preview.copyWith(error: 'File not found, cannot undo'));
        }
      } catch (e) {
        results.add(preview.copyWith(error: 'Undo failed: $e'));
      }
    }

    return results;
  }
}
