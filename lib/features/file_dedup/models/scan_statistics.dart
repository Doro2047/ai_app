/// 扫描统计信息模型
///
/// 存储文件查重扫描的统计结果。
library;

/// 扫描统计信息
class ScanStatistics {
  /// 发现的文件总数
  final int totalFiles;

  /// 已扫描的文件数
  final int scannedFiles;

  /// 重复文件组数
  final int duplicateGroups;

  /// 重复文件总数
  final int duplicateFiles;

  /// 重复文件总大小（字节）
  final int duplicateSize;

  /// 跳过的文件数
  final int skippedFiles;

  const ScanStatistics({
    this.totalFiles = 0,
    this.scannedFiles = 0,
    this.duplicateGroups = 0,
    this.duplicateFiles = 0,
    this.duplicateSize = 0,
    this.skippedFiles = 0,
  });

  /// 可释放的空间（格式化）
  String get duplicateSizeFormatted => _formatSize(duplicateSize);

  /// 格式化文件大小
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
