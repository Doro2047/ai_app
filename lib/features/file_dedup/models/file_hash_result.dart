/// 文件哈希结果模型
///
/// 存储单个文件的哈希计算结果和元数据。
library;

/// 文件哈希计算结果
class FileHashResult {
  /// 文件完整路径
  final String path;

  /// 文件名
  final String name;

  /// 文件大小（字节）
  final int size;

  /// 文件哈希值（MD5/SHA1/SHA256）
  final String hash;

  /// 哈希算法类型
  final String hashType;

  /// 文件修改时间
  final DateTime modified;

  const FileHashResult({
    required this.path,
    required this.name,
    required this.size,
    required this.hash,
    required this.hashType,
    required this.modified,
  });

  /// 格式化的文件大小
  String get sizeFormatted => _formatSize(size);

  /// 格式化的修改时间
  String get modifiedFormatted {
    final y = modified.year.toString();
    final m = modified.month.toString().padLeft(2, '0');
    final d = modified.day.toString().padLeft(2, '0');
    final h = modified.hour.toString().padLeft(2, '0');
    final min = modified.minute.toString().padLeft(2, '0');
    final s = modified.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s';
  }

  /// 转换为 Map（用于序列化）
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'name': name,
      'size': size,
      'hash': hash,
      'hashType': hashType,
      'modified': modified.toIso8601String(),
    };
  }

  /// 从 Map 创建实例
  factory FileHashResult.fromMap(Map<String, dynamic> map) {
    return FileHashResult(
      path: map['path'] as String,
      name: map['name'] as String,
      size: map['size'] as int,
      hash: map['hash'] as String,
      hashType: map['hashType'] as String,
      modified: DateTime.parse(map['modified'] as String),
    );
  }

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

  @override
  String toString() => 'FileHashResult(name: $name, size: $sizeFormatted, hash: $hash)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileHashResult && path == other.path;

  @override
  int get hashCode => path.hashCode;
}
