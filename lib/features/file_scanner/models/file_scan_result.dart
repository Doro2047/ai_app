/// 文件扫描器数据模型
///
/// 包含扫描结果、扫描配置和统计信息的数据模型。
library file_scan_result;


/// 文件扫描结果
class FileScanResult {
  /// 文件完整路径
  final String path;

  /// 文件名
  final String name;

  /// 文件扩展名（小写，含点号）
  final String extension;

  /// 文件大小（字节）
  final int size;

  /// 修改时间
  final DateTime modifiedTime;

  /// 是否为目录
  final bool isDirectory;

  /// 文件类型分类（如：图片、文档、代码文件等）
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

  /// 格式化的文件大小
  String get sizeFormatted => formatSize(size);

  /// 格式化的修改时间
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

/// 扫描配置
class ScanConfig {
  /// 扫描目录列表
  final List<String> directories;

  /// 扩展名过滤（如 ['.jpg', '.png']），为空则不过滤
  final List<String> extensions;

  /// 最大文件大小（字节），null 则不限制
  final int? maxSize;

  /// 最小文件大小（字节），null 则不限制
  final int? minSize;

  /// 是否包含隐藏文件
  final bool includeHidden;

  /// 是否递归扫描子目录
  final bool recursive;

  /// 是否保留扩展名（用于显示）
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

/// 扫描统计信息
class ScanStatistics {
  /// 总文件数
  final int totalFiles;

  /// 总文件大小
  final int totalSize;

  /// 按扩展名分组统计
  final Map<String, int> byExtension;

  /// 按文件类型分组统计
  final Map<String, int> byFileType;

  /// 按大小范围分组统计
  final Map<String, int> bySize;

  const ScanStatistics({
    this.totalFiles = 0,
    this.totalSize = 0,
    this.byExtension = const {},
    this.byFileType = const {},
    this.bySize = const {},
  });

  /// 格式化的总大小
  String get totalSizeFormatted => formatSize(totalSize);

  /// 文件类型数量
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
// 工具函数
// ============================================================

/// 文件大小范围定义
const Map<String, (int, int)> sizeRanges = {
  '极小 (< 1KB)': (0, 1024),
  '小 (1KB - 100KB)': (1024, 100 * 1024),
  '中 (100KB - 1MB)': (100 * 1024, 1024 * 1024),
  '大 (1MB - 10MB)': (1024 * 1024, 10 * 1024 * 1024),
  '极大 (10MB - 100MB)': (10 * 1024 * 1024, 100 * 1024 * 1024),
  '超大 (> 100MB)': (100 * 1024 * 1024, 0x7FFFFFFFFFFFFFFF), // max int
};

/// 扩展名到文件类型的映射
const Map<String, String> extensionTypeMap = {
  '.txt': '文本文件', '.md': '文本文件', '.log': '文本文件', '.csv': '文本文件',
  '.tsv': '文本文件', '.rtf': '文本文件', '.ini': '文本文件', '.cfg': '文本文件',
  '.conf': '文本文件', '.toml': '文本文件', '.yaml': '文本文件', '.yml': '文本文件',
  '.doc': '文档', '.docx': '文档', '.odt': '文档', '.wps': '文档',
  '.pdf': 'PDF文档',
  '.xls': '电子表格', '.xlsx': '电子表格', '.ods': '电子表格',
  '.jpg': '图片', '.jpeg': '图片', '.png': '图片', '.gif': '图片', '.bmp': '图片',
  '.svg': '图片', '.webp': '图片', '.ico': '图片', '.tiff': '图片', '.tif': '图片',
  '.mp3': '音频', '.wav': '音频', '.flac': '音频', '.aac': '音频', '.ogg': '音频',
  '.wma': '音频', '.m4a': '音频',
  '.mp4': '视频', '.avi': '视频', '.mkv': '视频', '.mov': '视频', '.wmv': '视频',
  '.flv': '视频', '.webm': '视频', '.m4v': '视频',
  '.zip': '压缩文件', '.rar': '压缩文件', '.7z': '压缩文件', '.tar': '压缩文件',
  '.gz': '压缩文件', '.bz2': '压缩文件', '.xz': '压缩文件',
  '.exe': '可执行文件', '.msi': '可执行文件', '.dll': '可执行文件',
  '.py': '代码文件', '.js': '代码文件', '.ts': '代码文件', '.java': '代码文件',
  '.c': '代码文件', '.cpp': '代码文件', '.h': '代码文件', '.cs': '代码文件',
  '.go': '代码文件', '.rs': '代码文件', '.rb': '代码文件', '.php': '代码文件',
  '.sh': '代码文件', '.bat': '代码文件', '.ps1': '代码文件', '.html': '代码文件',
  '.css': '代码文件', '.sql': '代码文件', '.vue': '代码文件', '.jsx': '代码文件',
  '.tsx': '代码文件', '.dart': '代码文件',
  '.apk': '安装包', '.dmg': '安装包', '.deb': '安装包', '.rpm': '安装包',
  '.iso': '镜像文件', '.img': '镜像文件',
};

/// 所有文件类型列表（用于过滤下拉框）
const List<String> allFileTypes = [
  '全部', '文本文件', '文档', 'PDF文档', '电子表格', '图片',
  '音频', '视频', '压缩文件', '可执行文件', '代码文件',
  '安装包', '镜像文件', '其他文件', '无扩展名',
];

/// 根据文件名获取文件类型
String getFileType(String filename) {
  if (!filename.contains('.') || filename.endsWith('.')) {
    return '无扩展名';
  }
  final ext = '.${filename.split('.').last.toLowerCase()}';
  return extensionTypeMap[ext] ?? '其他文件';
}

/// 格式化文件大小
String formatSize(int sizeBytes) {
  if (sizeBytes == 0) return '0 B';
  if (sizeBytes < 1024) return '$sizeBytes B';
  if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
  if (sizeBytes < 1024 * 1024 * 1024) {
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

/// 获取文件大小范围名称
String getSizeRangeName(int sizeBytes) {
  for (final entry in sizeRanges.entries) {
    final (min, max) = entry.value;
    if (sizeBytes >= min && sizeBytes < max) {
      return entry.key;
    }
  }
  return '超大 (> 100MB)';
}
