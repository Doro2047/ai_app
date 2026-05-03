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
  '.iso': 'Image File', '.img': 'Image File',
};

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
