/// Scan configuration model
///
/// Stores configuration parameters for file dedup scanning.
library;

/// Scan configuration
class ScanConfig {
  /// Directories to scan
  final List<String> directories;

  /// Hash algorithm type (md5/sha1/sha256)
  final String hashType;

  /// Minimum file size in bytes, files smaller than this are skipped
  final int minFileSize;

  /// Maximum file size in bytes, 0 means no limit
  final int maxFileSize;

  /// Whether to recursively scan subdirectories
  final bool recursive;

  /// Whether to include hidden files
  final bool includeHidden;

  const ScanConfig({
    this.directories = const [],
    this.hashType = 'md5',
    this.minFileSize = 0,
    this.maxFileSize = 0,
    this.recursive = true,
    this.includeHidden = false,
  });

  /// Valid hash algorithm list
  static const List<String> validHashTypes = ['md5', 'sha1', 'sha256'];

  /// Hash algorithm display name mapping
  static const Map<String, String> hashTypeLabels = {
    'md5': 'MD5 (Recommended)',
    'sha1': 'SHA-1',
    'sha256': 'SHA-256 (Most Secure)',
  };

  ScanConfig copyWith({
    List<String>? directories,
    String? hashType,
    int? minFileSize,
    int? maxFileSize,
    bool? recursive,
    bool? includeHidden,
  }) {
    return ScanConfig(
      directories: directories ?? this.directories,
      hashType: hashType ?? this.hashType,
      minFileSize: minFileSize ?? this.minFileSize,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      recursive: recursive ?? this.recursive,
      includeHidden: includeHidden ?? this.includeHidden,
    );
  }

  @override
  String toString() => 'ScanConfig(directories: ${directories.length}, hashType: $hashType, minSize: $minFileSize, recursive: $recursive)';
}
