/// File hash result model
///
/// Stores the hash calculation result and metadata for a single file.
library;

/// File hash calculation result
class FileHashResult {
  /// Full file path
  final String path;

  /// File name
  final String name;

  /// File size in bytes
  final int size;

  /// File hash value (MD5/SHA1/SHA256)
  final String hash;

  /// Hash algorithm type
  final String hashType;

  /// File modification time
  final DateTime modified;

  const FileHashResult({
    required this.path,
    required this.name,
    required this.size,
    required this.hash,
    required this.hashType,
    required this.modified,
  });

  /// Formatted file size
  String get sizeFormatted => _formatSize(size);

  /// Formatted modification time
  String get modifiedFormatted {
    final y = modified.year.toString();
    final m = modified.month.toString().padLeft(2, '0');
    final d = modified.day.toString().padLeft(2, '0');
    final h = modified.hour.toString().padLeft(2, '0');
    final min = modified.minute.toString().padLeft(2, '0');
    final s = modified.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s';
  }

  /// Convert to Map (for serialization)
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

  /// Create instance from Map
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

  @override
  String toString() => 'FileHashResult(name: $name, size: $sizeFormatted, hash: $hash)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileHashResult && path == other.path;

  @override
  int get hashCode => path.hashCode;
}
