/// Scan statistics model
///
/// Stores statistical results of file dedup scanning.
library;

/// Scan statistics
class ScanStatistics {
  /// Total number of files found
  final int totalFiles;

  /// Number of files scanned
  final int scannedFiles;

  /// Number of duplicate file groups
  final int duplicateGroups;

  /// Total number of duplicate files
  final int duplicateFiles;

  /// Total size of duplicate files in bytes
  final int duplicateSize;

  /// Number of files skipped
  final int skippedFiles;

  const ScanStatistics({
    this.totalFiles = 0,
    this.scannedFiles = 0,
    this.duplicateGroups = 0,
    this.duplicateFiles = 0,
    this.duplicateSize = 0,
    this.skippedFiles = 0,
  });

  /// Freeable space (formatted)
  String get duplicateSizeFormatted => _formatSize(duplicateSize);

  /// Format file size
  static String _formatSize(int sizeBytes) {
    if (sizeBytes == 0) return '0 B';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  ScanStatistics copyWith({
    int? totalFiles,
    int? scannedFiles,
    int? duplicateGroups,
    int? duplicateFiles,
    int? duplicateSize,
    int? skippedFiles,
  }) {
    return ScanStatistics(
      totalFiles: totalFiles ?? this.totalFiles,
      scannedFiles: scannedFiles ?? this.scannedFiles,
      duplicateGroups: duplicateGroups ?? this.duplicateGroups,
      duplicateFiles: duplicateFiles ?? this.duplicateFiles,
      duplicateSize: duplicateSize ?? this.duplicateSize,
      skippedFiles: skippedFiles ?? this.skippedFiles,
    );
  }

  @override
  String toString() => 'ScanStatistics(total: $totalFiles, groups: $duplicateGroups, duplicates: $duplicateFiles, size: $duplicateSizeFormatted)';
}
