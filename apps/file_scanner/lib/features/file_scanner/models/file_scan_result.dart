library;

class FileScanResult {
  final String path;
  final String name;
  final String extension;
  final int size;
  final DateTime modifiedTime;
  final bool isDirectory;
  final String fileType;

  const FileScanResult({
    required this.path,
    required this.name,
    required this.extension,
    required this.size,
    required this.modifiedTime,
    required this.isDirectory,
    required this.fileType,
  });

  String get sizeFormatted => formatSize(size);

  String get modifiedFormatted {
    final y = modifiedTime.year.toString();
    final m = modifiedTime.month.toString().padLeft(2, '0');
    final d = modifiedTime.day.toString().padLeft(2, '0');
    final h = modifiedTime.hour.toString().padLeft(2, '0');
    final min = modifiedTime.minute.toString().padLeft(2, '0');
    final s = modifiedTime.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s';
  }

  FileScanResult copyWith({
    String? path,
    String? name,
    String? extension,
    int? size,
    DateTime? modifiedTime,
    bool? isDirectory,
    String? fileType,
  }) {
    return FileScanResult(
      path: path ?? this.path,
      name: name ?? this.name,
      extension: extension ?? this.extension,
      size: size ?? this.size,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      isDirectory: isDirectory ?? this.isDirectory,
      fileType: fileType ?? this.fileType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileScanResult && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}

class ScanConfig {
  final List<String> directories;
  final List<String> extensions;
  final int? maxSize;
  final int? minSize;
  final bool includeHidden;
  final bool recursive;
  final bool keepExtension;

  const ScanConfig({
    this.directories = const [],
    this.extensions = const [],
    this.maxSize,
    this.minSize,
    this.includeHidden = false,
    this.recursive = true,
    this.keepExtension = true,
  });

  ScanConfig copyWith({
    List<String>? directories,
    List<String>? extensions,
    int? maxSize,
    int? minSize,
    bool? includeHidden,
    bool? recursive,
    bool? keepExtension,
  }) {
    return ScanConfig(
      directories: directories ?? this.directories,
      extensions: extensions ?? this.extensions,
      maxSize: maxSize ?? this.maxSize,
      minSize: minSize ?? this.minSize,
      includeHidden: includeHidden ?? this.includeHidden,
      recursive: recursive ?? this.recursive,
      keepExtension: keepExtension ?? this.keepExtension,
    );
  }
}

class ScanStatistics {
  final int totalFiles;
  final int totalSize;
  final Map<String, int> byExtension;
  final Map<String, int> byFileType;
  final Map<String, int> bySize;

  const ScanStatistics({
    this.totalFiles = 0,
    this.totalSize = 0,
    this.byExtension = const {},
    this.byFileType = const {},
    this.bySize = const {},
  });

  String get totalSizeFormatted => formatSize(totalSize);

  int get fileTypeCount => byFileType.length;

  ScanStatistics copyWith({
    int? totalFiles,
    int? totalSize,
    Map<String, int>? byExtension,
    Map<String, int>? byFileType,
    Map<String, int>? bySize,
  }) {
    return ScanStatistics(
      totalFiles: totalFiles ?? this.totalFiles,
      totalSize: totalSize ?? this.totalSize,
      byExtension: byExtension ?? this.byExtension,
      byFileType: byFileType ?? this.byFileType,
      bySize: bySize ?? this.bySize,
    );
  }
}

// ============================================================
// Utility Functions
// ============================================================

const Map<String, (int, int)> sizeRanges = {
  'Tiny (< 1KB)': (0, 1024),
  'Small (1KB - 100KB)': (1024, 100 * 1024),
  'Medium (100KB - 1MB)': (100 * 1024, 1024 * 1024),
  'Large (1MB - 10MB)': (1024 * 1024, 10 * 1024 * 1024),
  'Huge (10MB - 100MB)': (10 * 1024 * 1024, 100 * 1024 * 1024),
  'Massive (> 100MB)': (100 * 1024 * 1024, 0x7FFFFFFFFFFFFFFF),
};

const Map<String, String> extensionTypeMap = {
  '.txt': 'Text', '.md': 'Text', '.log': 'Text', '.csv': 'Text',
  '.tsv': 'Text', '.rtf': 'Text', '.ini': 'Text', '.cfg': 'Text',
  '.conf': 'Text', '.toml': 'Text', '.yaml': 'Text', '.yml': 'Text',
  '.doc': 'Document', '.docx': 'Document', '.odt': 'Document', '.wps': 'Document',
  '.pdf': 'PDF',
  '.xls': 'Spreadsheet', '.xlsx': 'Spreadsheet', '.ods': 'Spreadsheet',
  '.jpg': 'Image', '.jpeg': 'Image', '.png': 'Image', '.gif': 'Image', '.bmp': 'Image',
  '.svg': 'Image', '.webp': 'Image', '.ico': 'Image', '.tiff': 'Image', '.tif': 'Image',
  '.mp3': 'Audio', '.wav': 'Audio', '.flac': 'Audio', '.aac': 'Audio', '.ogg': 'Audio',
  '.wma': 'Audio', '.m4a': 'Audio',
  '.mp4': 'Video', '.avi': 'Video', '.mkv': 'Video', '.mov': 'Video', '.wmv': 'Video',
  '.flv': 'Video', '.webm': 'Video', '.m4v': 'Video',
  '.zip': 'Archive', '.rar': 'Archive', '.7z': 'Archive', '.tar': 'Archive',
  '.gz': 'Archive', '.bz2': 'Archive', '.xz': 'Archive',
  '.exe': 'Executable', '.msi': 'Executable', '.dll': 'Executable',
  '.py': 'Code', '.js': 'Code', '.ts': 'Code', '.java': 'Code',
  '.c': 'Code', '.cpp': 'Code', '.h': 'Code', '.cs': 'Code',
  '.go': 'Code', '.rs': 'Code', '.rb': 'Code', '.php': 'Code',
  '.sh': 'Code', '.bat': 'Code', '.ps1': 'Code', '.html': 'Code',
  '.css': 'Code', '.sql': 'Code', '.vue': 'Code', '.jsx': 'Code',
  '.tsx': 'Code', '.dart': 'Code',
  '.apk': 'Installer', '.dmg': 'Installer', '.deb': 'Installer', '.rpm': 'Installer',
  '.iso': 'Disk Image', '.img': 'Disk Image',
};

const List<String> allFileTypes = [
  'All', 'Text', 'Document', 'PDF', 'Spreadsheet', 'Image',
  'Audio', 'Video', 'Archive', 'Executable', 'Code',
  'Installer', 'Disk Image', 'Other', 'No Extension',
];

String getFileType(String filename) {
  if (!filename.contains('.') || filename.endsWith('.')) {
    return 'No Extension';
  }
  final ext = '.${filename.split('.').last.toLowerCase()}';
  return extensionTypeMap[ext] ?? 'Other';
}

String formatSize(int sizeBytes) {
  if (sizeBytes == 0) return '0 B';
  if (sizeBytes < 1024) return '$sizeBytes B';
  if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
  if (sizeBytes < 1024 * 1024 * 1024) {
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

String getSizeRangeName(int sizeBytes) {
  for (final entry in sizeRanges.entries) {
    final (min, max) = entry.value;
    if (sizeBytes >= min && sizeBytes < max) {
      return entry.key;
    }
  }
  return 'Massive (> 100MB)';
}
