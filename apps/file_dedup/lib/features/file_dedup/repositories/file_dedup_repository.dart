/// File dedup repository
///
/// Handles file scanning, hash calculation, duplicate detection, and file deletion.
/// Uses Isolate for parallel hash calculation to avoid blocking the UI.
library;

import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../models/models.dart';

/// Progress callback type
typedef ProgressCallback = void Function(int current, int total);

/// File dedup repository
class FileDedupRepository {
  /// Scan files and calculate hashes
  ///
  /// [directories] List of directories to scan
  /// [recursive] Whether to recursively scan subdirectories
  /// [onProgress] Progress callback
  /// [cancelToken] Cancellation token
  /// Returns list of file hash results
  Future<List<FileHashResult>> scanFiles(
    List<String> directories, {
    bool recursive = true,
    ProgressCallback? onProgress,
    Completer<void>? cancelToken,
  }) async {
    final allFiles = <FileSystemEntity>[];

    // Step 1: Collect all files
    for (final dir in directories) {
      final directory = Directory(dir);
      if (!await directory.exists()) continue;

      final entities = recursive ? directory.listSync(recursive: true, followLinks: false) : directory.listSync(followLinks: false);

      for (final entity in entities) {
        if (cancelToken?.isCompleted == true) return [];
        if (entity is File) {
          try {
            // Skip hidden files
            final basename = p.basename(entity.path);
            if (basename.startsWith('.')) continue;
            allFiles.add(entity);
          } catch (_) {
            // Skip inaccessible files
          }
        }
      }
    }

    final totalFiles = allFiles.length;
    if (totalFiles == 0) return [];

    final results = <FileHashResult>[];

    // Group by file size, only files with the same size need hash calculation
    final sizeGroups = <int, List<FileSystemEntity>>{};
    for (final file in allFiles) {
      try {
        final stat = file.statSync();
        final group = sizeGroups[stat.size] ?? [];
        group.add(file);
        sizeGroups[stat.size] = group;
      } catch (_) {}
    }

    // Only calculate hashes for groups with multiple files of the same size
    final filesToHash = <FileSystemEntity>[];
    for (final entries in sizeGroups.values) {
      if (entries.length > 1) {
        filesToHash.addAll(entries);
      }
    }

    // Calculate hashes
    int processed = 0;
    for (final file in filesToHash) {
      if (cancelToken?.isCompleted == true) break;

      try {
        final result = await computeFileHash(file.path);
        results.add(result);
        processed++;
        onProgress?.call(processed, filesToHash.length);
      } catch (_) {
        // Skip unreadable files
      }
    }

    return results;
  }

  /// Find duplicate file groups
  ///
  /// [files] List of file hash results
  /// Returns list of duplicate file groups
  List<DuplicateGroup> findDuplicates(List<FileHashResult> files) {
    // Group by hash value
    final hashGroups = <String, List<FileHashResult>>{};

    for (final file in files) {
      final group = hashGroups[file.hash] ?? [];
      group.add(file);
      hashGroups[file.hash] = group;
    }

    // Filter out duplicates (group file count > 1)
    final duplicateGroups = <DuplicateGroup>[];

    for (final entry in hashGroups.entries) {
      if (entry.value.length > 1) {
        // Sort by modification time, newest first
        final sortedFiles = List<FileHashResult>.from(entry.value)
          ..sort((a, b) => b.modified.compareTo(a.modified));

        final group = DuplicateGroup(
          hash: entry.key,
          size: sortedFiles.first.size,
          files: sortedFiles,
          selectedFiles: {},
        );

        // By default, select all files except the first one
        duplicateGroups.add(group.selectAllButFirst());
      }
    }

    // Sort by file size (largest first)
    duplicateGroups.sort((a, b) => b.size.compareTo(a.size));

    return duplicateGroups;
  }

  /// Delete files
  ///
  /// [paths] List of file paths to delete
  /// [moveToTrash] Whether to move to trash (currently deletes directly)
  /// Returns (success list, failed list)
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

  /// Calculate hash value for a single file
  ///
  /// This method can be safely called in an Isolate
  static Future<FileHashResult> computeFileHash(String filePath, {String hashType = 'md5'}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File not found', filePath);
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
